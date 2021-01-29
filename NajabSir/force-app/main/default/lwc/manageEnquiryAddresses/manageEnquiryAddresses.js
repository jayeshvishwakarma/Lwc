/* eslint-disable no-console */
import { LightningElement, api, wire, track } from "lwc";

import getEnquiryAddressFields from "@salesforce/apex/ManageEnquiryAddressesCtrl.getEnquiryAddressFields";
import validateDependencies from "@salesforce/apex/ManageEnquiryAddressesCtrl.validateDependencies";

import getPincodeSearchResults from "@salesforce/apex/ManageEnquiryAddressesCtrl.getPincodeSearchResults";
import getCitySearchResults from "@salesforce/apex/ManageEnquiryAddressesCtrl.getCitySearchResults";
import getVillageSearchResults from "@salesforce/apex/ManageEnquiryAddressesCtrl.getVillageSearchResults";
import getTehsilSearchResults from "@salesforce/apex/ManageEnquiryAddressesCtrl.getTehsilSearchResults";

//const PAN_PATTERN = /[A-Z]{3}[A|B|C|E|F|G|H|J|L|P|T]{1}[A-Z]{1}[0-9]{1}[0-9]{1}[0-9]{1}[0-9]{1}[A-Z]{1}/;
const PAN_PATTERN = /[A-Z]{5}[0-9]{1}[0-9]{1}[0-9]{1}[0-9]{1}[A-Z]{1}/;
export default class ManageEnquiryAddresses extends LightningElement {
  @api recordId;
  @api fieldSetName = "BillTo";
  @api record = {};
  @api deviceFormFactor;
  @api objectName = "Opportunity";

  cityFieldName;
  stateFieldName;
  pincodeFieldName;
  villageFieldName;
  districtFieldName;
  tehsilFieldName;
  docTypeFieldName;
  refNumberFieldName;

  cityFieldValue;
  stateFieldValue;
  pincodeFieldValue;
  villageFieldValue;
  tehsilFieldValue;
  districtFieldValue;
  docTypeFieldValue;
  refNumberFieldValue;

  pincodeSearchResults = {};
  citySearchResults = {};
  villageSearchResults = {};
  tehsilSearchResults = {};

  updatedRecord = {};
  fields = [];

  @track loaded = false;

  get mobileFormFactor() {
    return this.deviceFormFactor !== "DESKTOP";
  }

  @wire(getEnquiryAddressFields, { fieldSetName: "$fieldSetName", objectName: "$objectName" })
  wiredFields({ data }) {
    if (data) {
      console.log('data===', data);
      console.log('this.record===', this.record);
      let record = this.clone(this.record);
      this.fields = this.clone(data);
      this.fields.forEach(field => {
        field.value = record[field.name];
        this[field.type + "FieldName"] = field.name;
        this[field.type + "FieldValue"] = this.getFirstValue(field.value);
        switch (field.type) {
          case "district":
            field.isReadOnly = true;
            break;
          default:
        }
      });
      this.loaded = true;
      console.log('recordId===', this.recordId);
    }
  }
  handleCustomSearch(event) {
    switch (event.detail.customKey) {
      case this.pincodeFieldName:
        this.getSearchResults(getPincodeSearchResults, event.detail, "pincode");
        break;
      case this.cityFieldName:
        this.getSearchResults(getCitySearchResults, event.detail, "city");
        break;
      case this.villageFieldName:
        this.getSearchResults(getVillageSearchResults, event.detail, "village");
        break;
      case this.tehsilFieldName:
        this.getSearchResults(getTehsilSearchResults, event.detail, "tehsil");
        break;
      default:
    }
  }
  getSearchResults(action, params, key) {
    action(params)
      .then(searchResults => {
        this[key + "SearchResults"] = this.getSearchResultsMap(searchResults);
        let inputField = this.getInputField(key);
        if (inputField) {
          inputField.updateSearchResults(searchResults);
        }
      })
      .catch(error => {
        console.error(error);
      });
  }
  getSearchResultsMap(searchResults) {
    return searchResults.reduce((map, item) => {
      map[item.id] = item;
      return map;
    }, {});
  }
  handleValueChange(event) {
    let fname = event.target.dataset.fieldName;
    let fvalue = this.getFirstValue(event.detail.value);
    switch (fname) {
      case this.pincodeFieldName:
        this.pincodeFieldValue = fvalue;
        this.updatePincodeDependents();
        break;
      case this.cityFieldName:
        this.cityFieldValue = fvalue;
        this.updateCityDependents();
        break;
      case this.stateFieldName:
        this.stateFieldValue = fvalue;
        break;
      case this.villageFieldName:
        this.villageFieldValue = fvalue;
        this.updateVillageDependents();
        break;
      case this.tehsilFieldName:
        this.tehsilFieldValue = fvalue;
        this.updateTehsilDependents();
        break;
      case this.docTypeFieldName:
        this.docTypeFieldValue = fvalue;
        break;
      case this.refNumberFieldName:
        this.refNumberFieldValue = fvalue;
        break;
      default:
    }
    this.updatedRecord[fname] = event.detail.value;
  }
  updatePincodeDependents() {
    let pincode = this.pincodeSearchResults[this.pincodeFieldValue];
    if (pincode) {
      this.updateCityValue(pincode.city, pincode.city_name);
      this.updateStateValue(pincode.state);
    }
  }
  updateCityDependents() {
    let city = this.citySearchResults[this.cityFieldValue];
    if (city) {
      this.updateStateValue(city.state);
    }
  }
  updateVillageDependents() {
    let village = this.villageSearchResults[this.villageFieldValue];
    if (village) {
      this.updateTehsilValue(village.tehsil, village.tehsil_name);
      this.updateDistrictValue(village.district);
    }
  }
  updateTehsilDependents() {
    let tehsil = this.tehsilSearchResults[this.tehsilFieldValue];
    if (tehsil) {
      this.updateDistrictValue(tehsil.district);
    }
  }
  updateCityValue(value, name) {
    this.cityFieldValue = value;
    this.updatedRecord[this.cityFieldName] = value;
    this.setLookupInputFieldValue("city", value, name);
  }
  updateStateValue(value) {
    this.stateFieldValue = value;
    this.updatedRecord[this.stateFieldName] = value;
    this.setInputFieldValue("state", value);
  }
  updateTehsilValue(value, name) {
    this.tehsilFieldValue = value;
    this.updatedRecord[this.tehsilFieldName] = value;
    this.setLookupInputFieldValue("tehsil", value, name);
  }
  updateDistrictValue(value) {
    this.districtFieldValue = value;
    this.setInputFieldValue("district", value);
  }
  setLookupInputFieldValue(key, id, name) {
    let inputField = this.getInputField(key);
    if (inputField) {
      inputField.updateSelection(id, name);
    }
  }
  setInputFieldValue(key, value) {
    let inputField = this.getInputField(key);
    if (inputField) {
      inputField.value = value;
    }
  }
  @api validate() {
    return this.validateDependencies().then(validity => {
      let result = { isValid: false, errorMessage: "" };
      if (this.validateRequiredFields()) {
        if (!this.validateDocType()) {
          result.errorMessage = "Please enter PAN number in correct format and with 10 Characters";
        } else if (!validity) {
          result.errorMessage =
            "Please provide a valid City, State and Pincode";
        } else {
          result.isValid = true;
          result.record = this.updatedRecord;
          result.outCity = this.cityFieldValue || "";
          result.outPincode = this.pincodeFieldValue || "";
          result.outTehsil = this.tehsilFieldValue || "";
          result.outVillage = this.villageFieldValue || "";
        }
      } else {
        result.errorMessage = "Please review errors on the page";
      }
      return result;
    });
  }
  validateDependencies() {
    return validateDependencies({
      city: this.cityFieldValue,
      state: this.stateFieldValue,
      pincode: this.pincodeFieldValue
    }).catch(error => {
      this.error = error;
    });
  }
  validateRequiredFields() {
    let inputs = this.queryAll("lightning-input")
      .concat(this.queryAll("lightning-input-field"))
      .concat(this.queryAll("c-lookup-input-field"));
    let invalidCmps = inputs.filter(input => !input.reportValidity());
    return invalidCmps.length === 0;
  }
  validateDocType() {
    this.docTypeFieldValue = this.docTypeFieldValue || "";
    this.refNumberFieldValue = this.refNumberFieldValue || "";
    if (this.docTypeFieldValue.toUpperCase() === "PAN") {
      if (
        this.refNumberFieldValue.length !== 10 ||
        !PAN_PATTERN.test(this.refNumberFieldValue)
      ) {
        return false;
      }
    }
    return true;
  }
  getInputField(key) {
    return this.queryInputField(this[key + "FieldName"]);
  }
  queryInputField(name) {
    return this.template.querySelector("[data-field-name='" + name + "']");
  }
  queryAll(query) {
    return Array.from(this.template.querySelectorAll(query));
  }
  getFirstValue(array) {
    return Array.isArray(array) ? array[0] : array || "";
  }
  clone(data) {
    return JSON.parse(JSON.stringify(data));
  }
}