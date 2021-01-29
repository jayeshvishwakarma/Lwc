import {
  LightningElement,
  track,
  api,
  wire
} from "lwc";
import {
  NavigationMixin
} from "lightning/navigation";

import searchAccounts from "@salesforce/apex/CustomAccountSearchCtrl.searchAccounts";
import searchAccountsByAsset from "@salesforce/apex/CustomAccountSearchCtrl.searchAccountsByAsset";

import ONE_FIELD_REQUIRED_ERROR from "@salesforce/label/c.CAS_One_Field_Required_Error";
import ADDITIONAL_FIELD_REQUIRED_ERROR from "@salesforce/label/c.CAS_Additional_Field_Required_Error";
import SERVER_ERROR from "@salesforce/label/c.UI_Error_Message";

//****************Change added for Dealer Inbound calling****************//
import userprofile from "@salesforce/schema/User.Profile.Name";
import serviceProfile from "@salesforce/label/c.Service_Custom_Account_Search";
import serviceMobileOTP from "@salesforce/label/c.Service_Mobile";
import {
  getRecord
} from "lightning/uiRecordApi";
import currentUserId from "@salesforce/user/Id";
//****************Change added for Dealer Inbound calling****************//

export default class CustomAccountSearch extends NavigationMixin(
  LightningElement
) {
  @api deviceFormFactor;
  //****************Change added for Dealer Inbound calling****************//
  @track servicePersona = false;
  buttonsource;
  // This method is used to fetch Logged in User profile
  @wire(getRecord, {
    recordId: currentUserId,
    fields: [userprofile]
  })
  currentUser({
    error,
    data
  }) {
    if (data) {
      let profileRec;
      profileRec = serviceProfile.split(';');
      if (profileRec.includes(data.fields.Profile.displayValue)) {
        this.servicePersona = true;
      }
    } else if (error) {
      console.log('error------------->', error);
    }
  }
  //****************Change added for Dealer Inbound calling****************//

  columns = [{
      label: "Name",
      fieldName: "name",
      type: "text"
    },
    {
      label: "Mobile",
      fieldName: "mobile",
      type: "text"
    },
    { //****************Change added for Dealer Inbound calling****************//
      label: "Service Mobile",
      fieldName: "serviceMobile",
      type: "text"
    }, //****************Change added for Dealer Inbound calling****************//
    {
      label: "Email",
      fieldName: "email",
      type: "text"
    },
    {
      label: "Birthdate",
      fieldName: "birthday",
      type: "text"
    },
    {
      label: "Customer Mood",
      fieldName: "mood",
      type: "text"
    },
    {
      label: "Customer Type",
      fieldName: "customerType",
      type: "text"
    }
  ];
  assetFields = [{
      name: "regnum",
      label: "Registration Number",
      min: 2,
      max: 20
    },
    {
      name: "vin",
      label: "VIN",
      min: 2,
      max: 20
    },
    {
      name: "polnum",
      label: "Policy Number",
      min: 2,
      max: 80
    },
    {
      name: "loynum",
      label: "Loyalty Card Number",
      min: 2,
      max: 80
    },
    {
      name: "engnum",
      label: "Engine Number",
      min: 2,
      max: 80
    },
    {
      name: "chanum",
      label: "Chassis Number",
      min: 2,
      max: 20
    }
  ];
  data = [];
  accountFilters = {};
  assetFilters = {};

  @track assetField;
  @track selectedCustomer;
  @track isLoading = false;
  @track accountErrorMessage = "";
  @track assetErrorMessage = "";
  @track searchErrorMessage = "";

  get assetInput() {
    return this.template.querySelector(".asset-filters lightning-input");
  }
  get mobileFormFactor() {
    return this.deviceFormFactor !== "DESKTOP";
  }

  constructor() {
    super();
    this.assetField = this.assetFields[0];
    this.columns.push({
      type: "action",
      typeAttributes: {
        rowActions: this.getRowActions
      }
    });
  }


  getRowActions(row, doneCallback) {
    try {
      let profileRec;
      profileRec = serviceProfile.split(';');
      const actions = [];
      if (row.accessible) {
        actions.push({
          label: "View Account",
          name: "view_account"
        });
      } else {
        actions.push({
          label: "Send OTP",
          name: "send_otp"
        });
        //****************Change added for Dealer Inbound calling****************//
        if (profileRec.includes(row.loggedinProfileName)) {
          actions.push({
            label: serviceMobileOTP,
            name: "send_otp_service_Mobile"
          });
        }
        //****************Change added for Dealer Inbound calling****************//
      }
      doneCallback(actions);
    } catch (error) {
      console.log('error----------->', error);
    }
  }
  handleRowAction(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    this.buttonsource = action.name ? action.name : '';
    switch (action.name) {
      case "view_account":
        this.navidateToRecord(row.id);
        break;
      case "send_otp":
        this.selectedCustomer = row;
        break;
      case "send_otp_service_Mobile": //****************Change added for Dealer Inbound calling****************//
        this.selectedCustomer = row;
        break; //****************Change added for Dealer Inbound calling****************//
      default:
    }
  }
  handleAccountFilterChange(event) {
    this.accountFilters[event.target.dataset.name] = event.target.value.trim();
  }
  handleAssetFilterChange(event) {
    this.assetFilters[event.target.dataset.name] = (
      event.target.value ||
      event.detail.value ||
      ""
    ).trim();
  }
  handleAssetTypeChange(event) {
    this.assetFilters = {
      model: this.assetFilters.model,
      [event.target.value]: this.assetInput.value
    };
    this.assetField = this.assetFields.find(
      field => field.name === event.target.value
    );
  }
  handleAccountSearch() {
    if (this.validateAccountFilters()) {
      this.searchAccounts(searchAccounts, this.accountFilters);
    }
  }
  handleAssetSearch() {
    if (this.validateAssetFilters()) {
      this.searchAccounts(searchAccountsByAsset, this.assetFilters);
    }
  }
  handleCloseModal() {
    this.selectedCustomer = null;
  }
  searchAccounts(action, filter) {
    this.data = [];
    this.isLoading = true;
    action({
        filter
      })
      .then(data => {
        this.data = data.map(item => Object.assign({}, item));
        this.isLoading = false;
      })
      .catch(error => {
        this.searchErrorMessage = SERVER_ERROR;
        this.isLoading = false;
        // eslint-disable-next-line no-console
        console.error(error);
      });
  }
  validateAccountFilters() {
    let errorMessage = "";
    let inputs = Array.from(
      this.template.querySelectorAll(".account-filters lightning-input")
    );
    let valid = inputs.filter(input => !input.reportValidity()).length === 0;
    if (valid) {
      valid =
        this.accountFilters.phone ||
        this.accountFilters.email ||
        this.accountFilters.aadhaar ||
        this.accountFilters.pan;
      if (this.accountFilters.name && !valid) {
        errorMessage = ADDITIONAL_FIELD_REQUIRED_ERROR;
      } else if (!valid) {
        errorMessage = ONE_FIELD_REQUIRED_ERROR;
      }
    } else {
      errorMessage = "Please review errors on the page";
    }
    this.accountErrorMessage = errorMessage;
    return this.accountErrorMessage ? false : true;
  }
  validateAssetFilters() {
    let errorMessage = "";
    let valid = this.assetInput.reportValidity();
    if (this.assetInput.reportValidity()) {
      valid =
        this.assetFilters.vin ||
        this.assetFilters.regnum ||
        this.assetFilters.polnum ||
        this.assetFilters.loynum ||
        this.assetFilters.engnum ||
        this.assetFilters.chanum;
      if (this.assetFilters.model && !valid) {
        errorMessage = ADDITIONAL_FIELD_REQUIRED_ERROR;
      } else if (!valid) {
        errorMessage = ONE_FIELD_REQUIRED_ERROR;
      }
    } else {
      errorMessage = "Please review errors on the page";
    }
    this.assetErrorMessage = errorMessage;
    return this.assetErrorMessage ? false : true;
  }
  navidateToRecord(recordId) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId,
        actionName: "view"
      }
    });
  }
}