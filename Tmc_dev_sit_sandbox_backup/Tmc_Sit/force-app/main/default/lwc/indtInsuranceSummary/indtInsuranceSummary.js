/* eslint-disable no-console */
import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import fetchData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import { getRecord } from "lightning/uiRecordApi";

export default class IndtInsuranceSummary extends LightningElement {
  @api recordId;

  @api parentComponent;

  @track loading = false;
  @track errorMessage;
  dataLoaded=false;
  policyNumberValue;
  responseData = {};
  idvValue;
  idvPercent;
  upperRegNum;
  showAccessories=false;
  showExistingAddOns=false;

  get loaded() {
    console.log(this.loading);
    console.log(this.globalpolicynumber);
    if(this.parentComponent=='Policy Search Details'){
      console.log('inside if');
      return this.dataLoaded;
    }
    else{
      console.log('inside else');
      return !this.errorMessage && !this.loading;
    }
    
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: ["Case.Policy_No__c"]
  })
  wiredCurrentUser({ error, data }) {
    if (data) {
      this.policyNumberValue = data.fields.Policy_No__c.value;
      this.fetchData();
    } else if (error) {
      this.handleError(error);
    }
  }

  connectedCallback() {
    //this.loading = true;
    //if(this.globalpolicynumber)
    //this.policyNumberValue = this.globalpolicynumber;

    //this.fetchData();
  }

  @api handleFetchData(globalpolicynumber){
    console.log('Inside handlePolicyNumberChange');
    this.loading = true;
    if(globalpolicynumber)
    this.policyNumberValue = globalpolicynumber;
    this.fetchData();
  }

  fetchData() {
    console.log('Inside fetchData');
    this.loading = true;
    // prepare request
    let urlParams = {
      policyNumber: this.policyNumberValue
    };
    let params = {
      jitName: "IndtInsuranceSummary",
      urlParam: JSON.stringify(urlParams)
    };
    console.log(urlParams);
    // make JIT call
    fetchData(params)
      .then(response => this.handleResponse(response))
      .catch(error => this.handleError(error))
      .finally(() => (this.loading = false));
  }
  handleResponse(response) {
    if (!response.data) {
      const selectedEvent = new CustomEvent('datafetched', { detail:false });
      this.dispatchEvent(selectedEvent);
      throw response;
    } else {
      this.dataLoaded=true;
      this.responseData = JSON.parse(response.data).policySummaryDetails;
      console.log(this.responseData);
      //this.VBStatus=this.responseData.64VBStatus;
      this.idvValue=this.responseData.idvDepreciation.split('(')[0];
      this.idvPercent='('+this.responseData.idvDepreciation.split('(')[1];
      this.upperRegNum=this.responseData.registrationNo.toUpperCase();
      if(this.responseData.accessories.length>0){
        this.showAccessories=true;
      }
      if(this.responseData.existingAddOns.length>0){
        this.showExistingAddOns=true;
      }
      console.log('Hi');
      const selectedEvent = new CustomEvent('datafetched', { detail:true });
      this.dispatchEvent(selectedEvent);
      console.log('Hi 1');
    }
  }
  handleError(error) {
    this.errorMessage = Server_Error;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Something is wrong",
        message: error.message,
        variant: "error"
      })
    );
    console.error(error);
  }
}