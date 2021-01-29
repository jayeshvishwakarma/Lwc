/* eslint-disable no-console */
import {
  LightningElement,
  api,
  track,
  wire
} from "lwc";
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
  getPicklistValues
} from "lightning/uiObjectInfoApi";
import {
  getRecord,
  updateRecord
} from "lightning/uiRecordApi";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import Insurance_Company from "@salesforce/label/c.Insurance_Company";
import fetchData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import CASE_RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import Reason_For_Lost from "@salesforce/schema/Case.Reason_for_Lost__c";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import UpdateTaskCasetoLost from "@salesforce/apex/LostCaseFeedback.updateCasetoLost";
import {
  NavigationMixin
} from "lightning/navigation";

const caseFieldsArray = [
  "Case.Policy_No__c",
  "Case.Customer__c",
  "Case.Customer__r.Name",
  "Case.Customer__r.Preferred_Languages__pc",
  "Case.Customer__r.Customer_Type__c",
  "Case.AssetId",
];

export default class IndtLostCaseAnalysis extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api lostCaseReason;
  @api insuranceCaseUser;
  @api taskString = {}; //In this value will be passed via callDetails cmp only when it is MI_Renewal Recordtype and it is lost case scenrio

  @track accountId;
  @track assetId;
  @track reasonforLostOptions;
  @track recordTypeId;
  @track Case;

  insuranceCompanyOptions;
  apiResponseMessage;

  @wire(getRecord, {
    recordId: '$recordId',
    fields: [CASE_RECORDTYPE_FIELD]
  })
  getCase({
    error,
    data
  }) {
    if (data) {
      var result = JSON.parse(JSON.stringify(data));
      console.log('case data: ', result);
      this.Case = result;
      if (result.fields) {
        this.recordTypeId = result.fields.RecordTypeId.value;
      }
    } else if (error) {
      //var result = JSON.parse(JSON.stringify(error));
      console.log('error: ', error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: Reason_For_Lost
  })
  PicklistValues({
    error,
    data
  }) {
    if (data) {
      this.reasonforLostOptions = data.values;
    }
  }

  @track displayData = {
    currentDate: new Date().toISOString().substring(0, 10)
  };
  @track loading = false;
  @track errorMessage;

  policyNumberValue;
  inputData = {
    customerName: "",
    customerType: "",
    contactNo1: "",
    contactNo2: "",
    contactNo3: "",
    preferredPrimaryLanguage: "",
    preferredSecondaryLanguage: "",
    emailId: "",
    policyNo: "",
    policyStartDate: "",
    policyEndDate: "",
    vehicleSaleDate: "",
    vehicleSubmodel: "",
    vehicleColor: "",
    yearManufacturing: "",
    engineNo: "",
    chassisNo: "",
    nonMIPolicyNo: "",
    insuranceCompany: "",
    newPolicyIssueDate: "",
    newPolicyExpiryDate: "",
    reasonForLost: "",
    lostFlag: "N",
    createdDate: "",
    createdBy: "",
    remarks: ""
  };

  get loaded() {
    return !this.errorMessage && !this.loading;
  }
  get inputs() {
    return Array.from(
      this.template.querySelectorAll(".slds-form-element_edit")
    );
  }



  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  })
  wiredUserData({
    error,
    data
  }) {
    if (data) {
      this.displayData.name = data.fields.Name.value;
    } else if (error) {
      this.handleError({
        error,
        message: "User Data Not Found"
      });
    }
  }
  @wire(getRecord, {
    recordId: "$recordId",
    fields: caseFieldsArray
  })
  wiredCaseData({
    data,
    error
  }) {

    if (data) {
      if (data.fields.Policy_No__c.value && data.fields.Customer__c.value && data.fields.AssetId.value) {
        this.accountId = data.fields.Customer__r.value.Id;
        this.assetId = data.fields.AssetId.value;
        this.displayData.Policy_No__c = data.fields.Policy_No__c.value;
        this.loading = false;
      } else {
        this.handleError({
          error,
          message: "Policy No, Customer and Asset are required on Case record"
        });
      }

    } else if (error) {
      this.handleError({
        error,
        message: "Error is Case data. Please try after sometime."
      });
      this.loading = false;
    }
  }

  connectedCallback() {

    //console.log('taskString------>' + JSON.stringify(this.taskString));
    this.loading = true;
    this.inputData.reasonForLost = this.lostCaseReason;
    this.insuranceCompanyOptions = [];
    let insComp = Insurance_Company.split(",");
    for (var key in insComp) {
      this.insuranceCompanyOptions.push({
        value: insComp[key],
        label: insComp[key]
      });
    }
  }


  mandatoryFieldCheck() {
    var inputCmp = this.template.querySelector(".inputCmp");
    var value = inputCmp.value;
    if (!value) {
      inputCmp.reportValidity();
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Something is wrong",
          message: "Reason For Lost is missing!",
          variant: "error"
        })
      );
    }
    return inputCmp;
  }


  handleValueChange(event) {
    if (event.target.value) {
      this.inputData[event.target.name] = event.target.value
    } else {
      this.inputData[event.target.name] = "";
    }

  }
  // Commented because in Lost Case, no field is mandatory for API callout
  /*handleSaveClick() {
    if (this.validateInputs()) {
      this.updateData();
    }
  }*/
  updateData() {
    if (this.mandatoryFieldCheck() && this.insuranceCompanyCompReq()) {
      console.log('Yes----->');
      this.inputData["policyNo"] = this.displayData.Policy_No__c;

      if (this.inputData["newPolicyIssueDate"] && this.inputData["newPolicyExpiryDate"] && this.inputData["newPolicyIssueDate"] > this.inputData["newPolicyExpiryDate"]) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Something is wrong",
            message: "Policy Issue Date cannot be greater than Policy Expiry date",
            variant: "error"
          })
        );

      } else {
        this.loading = true;
        if (this.inputData["reasonForLost"])
          this.inputData["lostFlag"] = "Y";
        // prepare request
        let urlParams = {
          policyNumber: this.policyNumberValue
        };
        console.log('this.inputData------->', this.inputData);
        let params = {
          jitName: "IndtUpdateLostCaseAnalysis",
          jsonBody: JSON.stringify(this.inputData),
          urlParam: " " //JSON.stringify(urlParams)
        };
        // make JIT call
        fetchData(params)
          .then(response => this.handleUpdateResponse(response))
          .catch(error => this.handleError(error));
        //.finally(() => (this.loading = false));
      }
    }
  }

  insuranceCompanyCompReq() {
    console.log('this.inputData["reasonForLost"]---->' + this.inputData["reasonForLost"]);
    console.log('this.inputData["insuranceCompany"]---->' + this.inputData["insuranceCompany"]);
    if (this.inputData["reasonForLost"] && this.inputData["reasonForLost"] === "Already Renewed" && !this.inputData["insuranceCompany"]) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "When Reason for Lost is Already Renewed then Insurance Company is required",
          variant: "error"
        })
      );
    } else {
      return this.inputData["reasonForLost"];
    }

  }

  handleUpdateResponse(response) {
    console.log('response------->',response);
    var apiError;
    if (response.status === "Success") {
      this.apiResponseMessage = JSON.parse(response.data).message;
    } else {
      this.handleError(response);
      apiError = (response.message).length>=256 ? (response.message).substring(0,255) : response.message;
      this.apiResponseMessage='Lost Case Feedback is not captured. Please contact Support Team.'
    }
    this.updateServerData(apiError);
  }


  updateServerData(ErrMessage) {

    UpdateTaskCasetoLost({
      recordId: this.recordId,
      taskJSON: JSON.stringify(this.taskString),
      apiErrorMessage : ErrMessage
    }).then(result => {
      if (result === 'SUCCESS') {
        localStorage.clear();
        this.apiResponseMessage='Disposition has been Updated, Case has been move to Lost &'+' ' +this.apiResponseMessage;
        this.handleSuccess(result);
      } else {
        this.handleError(Server_Error);
      }
    }).catch(error => {
      this.handleError(error);
    })
  }




  validateInputs() {
    let inps = Array.from(this.template.querySelectorAll("lightning-input"));
    return inps.filter(inp => !inp.reportValidity()).length === 0;
  }

  handleError(error) {
    this.errorMessage = error.message || Server_Error;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Something is wrong",
        message: this.errorMessage,
        variant: "error"
      })
    );
    this.loading = false;
    console.log(error);
  }

  // This method is used to close the LWC and navigate to record page
  handleSuccess(response) {
    window.location.reload();
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: this.apiResponseMessage,
        variant: "success"
      })
    );
    this.loading = false;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Case", // objectApiName is optional
        actionName: "view"
      }
    });

  }

}