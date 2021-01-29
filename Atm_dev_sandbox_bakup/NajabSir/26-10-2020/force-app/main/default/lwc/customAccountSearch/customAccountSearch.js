import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

import searchAccounts from "@salesforce/apex/CustomAccountSearchCtrl.searchAccounts";
import searchAccountsByAsset from "@salesforce/apex/CustomAccountSearchCtrl.searchAccountsByAsset";

import ONE_FIELD_REQUIRED_ERROR from "@salesforce/label/c.CAS_One_Field_Required_Error";
import ADDITIONAL_FIELD_REQUIRED_ERROR from "@salesforce/label/c.CAS_Additional_Field_Required_Error";
import SERVER_ERROR from "@salesforce/label/c.UI_Error_Message";

export default class CustomAccountSearch extends NavigationMixin(
  LightningElement
) {
  @api deviceFormFactor;

  columns = [
    { label: "Name", fieldName: "name", type: "text" },
    { label: "Mobile", fieldName: "mobile", type: "text" },
    { label: "Email", fieldName: "email", type: "text" },
    { label: "Birthdate", fieldName: "birthday", type: "text" },
    { label: "Customer Mood", fieldName: "mood", type: "text" },
    { label: "Customer Type", fieldName: "customerType", type: "text" }
  ];
  assetFields = [
    { name: "vin", label: "VIN", min: 2, max: 20 },
    { name: "regnum", label: "Registration Number", min: 2, max: 20 },
    { name: "polnum", label: "Policy Number", min: 2, max: 80 },
    { name: "loynum", label: "Loyalty Card Number", min: 2, max: 80 },
    { name: "engnum", label: "Engine Number", min: 2, max: 80 },
    { name: "chanum", label: "Chassis Number", min: 2, max: 20 }
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
      typeAttributes: { rowActions: this.getRowActions }
    });
  }
  getRowActions(row, doneCallback) {
    const actions = [];
    if (row.accessible) {
      actions.push({ label: "View Account", name: "view_account" });
    } else {
      actions.push({ label: "Send OTP", name: "send_otp" });
    }
    doneCallback(actions);
  }
  handleRowAction(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    switch (action.name) {
      case "view_account":
        this.navidateToRecord(row.id);
        break;
      case "send_otp":
        this.selectedCustomer = row;
        break;
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
    action({ filter })
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