import {
  LightningElement,
  api,
  track
} from 'lwc';
import fetchCityandAssestInfo from "@salesforce/apex/ServiceCalculator.fetchCityandAssestInfo";
import getServiceCalculatorData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import {
  NavigationMixin
} from "lightning/navigation";
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import VINerror from '@salesforce/label/c.VIN_error_message';
import formFactorPropertyName from '@salesforce/client/formFactor';

const actions = [{
  label: 'Create Case',
  name: 'create_case_record'
}];

export default class EwCostCalculatorLwc extends NavigationMixin(LightningElement) {
  registrationNumberValues = [];
  registrationNumber;
  assetList = [];
  Milage;
  data;
  regNumber;
  cmpVisible = true;
  mcppackageName;
  @api recordId;
  @track loading = false; // This varibale is used to control the visibility of spinner
  @track errorMessage;
  @track isVisible = false;
  obj; // This variable is used to store JSON result
  columns; // This variable is used to store the Lightning datatable columns data
  isSmallDevice = false; //This variable is used to check if used device is small or not
  connectedCallback() {
    if (formFactorPropertyName === 'Small') {
      this.isSmallDevice = true;
    }
    fetchCityandAssestInfo({
        recordId: this.recordId,
      })
      .then(result => {
        if (result && result.registrationNumberList && result.registrationNumberList.length > 0) {
          this.assetList = result.registrationNumberList;
          this.registrationNumberValues = [];
          for (let i = 0; i < result.registrationNumberList.length; i++) {
            if (result.registrationNumberList[i].VIN__c) {
              this.registrationNumberValues.push({
                label: result.registrationNumberList[i].Name,
                value: result.registrationNumberList[i].VIN__c
              });
            }
          }
        }
        if (this.registrationNumberValues.length === 0) {
          // To hide the Spinner
          this.loading = false;
          // To throw an error message if Registration Number is not present
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Something is wrong",
              message: VINerror,
              variant: "error"
            })
          );
          this.cancel();
        }
      })
      .catch(error => {
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Something is wrong",
            message: "Please try again later!",
            variant: "error"
          })
        );
        this.cancel();
      })
  }

  get loaded() {
    return !this.errorMessage && !this.loading;
  }

  handlechange(event) {
    if (event.target.name === "RegistrationNumber") {
      this.registrationNumber = event.detail.value;
      this.regNumber = (this.assetList.find(item => item.VIN__c === this.registrationNumber).Name);
    } else if (event.target.name === "Mileage") {
      this.Milage = event.detail.value;
    }
  }

  isDecimal(event) {
    var charCode = event.which ? event.which : event.keyCode;
    if (charCode < 48 || charCode > 57) {
      event.preventDefault();
    }
    return true;
  }

  handlePaste(event) {
    event.preventDefault();
  }

  // This method is used to close the LWC and navigate to record page
  cancel() {
    this.loading = true;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Account", // objectApiName is optional
        actionName: "view"
      }
    });
    this.loading = false;
  }

  handleRowAction(event) {
    const row = event.detail.row;
    const action = event.detail.action;
    let data = row;
    if (action.name === 'createCase' && this.registrationNumber) {
      this.mcppackageName = data.PackageName;
      this.cmpVisible = false;
    }


  }

  calculateAmount() {
    // To Handle the data validation for lightning-input field
    var vl = this.template.querySelector("lightning-input");
    if (this.validationCheckMethod() && vl.value !== "" && vl.value !== null && vl.value <= 500000) {
      this.loading = true;
      let params = {
        jitName: "EW_Cost_Calculator",
        jsonBody: " ",
        urlParam: JSON.stringify({
          vin: this.registrationNumber,
          currentMileage: this.Milage
        })
      };
      getServiceCalculatorData(params)
        .then(result => {
          this.isVisible = false;
          if (result && result.code === 200) {
            this.obj = JSON.parse(result.data);
            this.columns = [{
                label: "Package Name",
                fieldName: "PackageName",
                type: "text"
              },
              {
                label: "Cost (Taxes not included)",
                fieldName: "Cost",
                type: "text"
              },
              {
                label: "Valid upto Date",
                fieldName: "ValiduptoDate",
                type: "text"
              },
              {
                label: "Valid upto Kms",
                fieldName: "ValiduptoKms",
                type: "text"
              },
              {
                type: 'button',
                initialWidth: 130,
                typeAttributes: {
                  rowActions: actions,
                  menuAlignment: 'left',
                  label: 'Create Case',
                  title: 'Create Case',
                  name: 'createCase',
                  value: 'createCase',
                  variant: 'brand'

                }
              }
            ];

            const data = [];
            if (this.obj.serviceEwCostList && this.obj.serviceEwCostList !== 0) {
              let result = this.obj.serviceEwCostList;
              for (let i = 0; i < result.length; i++) {
                data.push({
                  PackageName: result[i].packageName,
                  Cost: result[i].cost,
                  ValiduptoDate: result[i].validUptoDate,
                  ValiduptoKms: result[i].validUptoKms
                })
              }
            }
            this.data = data;
            this.isVisible = true;
            this.loading = false;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Data has been retrieved successfully!",
                variant: "success"
              })
            );
            this.loading = false;

          } else {
            // To hide the Spinner
            this.loading = false;
            // To throw an error message if Registration Number is not present
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: result.message,
                variant: "Warning"
              })
            );
          }
        })
        .catch(error => {
          this.error = error;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Something is wrong",
              message: "Please try again later!",
              variant: "error"
            })
          );
          this.loading = false;
          this.cancel();
        });
    } else {
      // To popup error message when required fields are missing message.
      vl.reportValidity();
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Something is wrong",
          message: "Required fields are missing / Data entered is not correct",
          variant: "error"
        })
      );
    }
  }

  // To Handle the data validation for lightning-combobox fields
  validationCheckMethod() {
    const allValid1 = [
      ...this.template.querySelectorAll("lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    return allValid1;
  }
}