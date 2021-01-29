/* eslint-disable no-console */
import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import fetchData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import { getRecord } from "lightning/uiRecordApi";

export default class IndtEndorsementCancellations extends LightningElement {
  @api recordId;

  @track loading = false;
  @track errorMessage;

  policyNumberValue;
  responseData = {};

  get loaded() {
    return !this.errorMessage && !this.loading;
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
    this.loading = true;
    //this.fetchData();
  }
  fetchData() {
    // prepare request
    let urlParams = {
      policyNumber: this.policyNumberValue
    };
    let params = {
      jitName: "IndtEndorsementCancellations",
      urlParam: JSON.stringify(urlParams)
    };
    // make JIT call
    fetchData(params)
      .then(response => this.handleResponse(response))
      .catch(error => this.handleError(error))
      .finally(() => (this.loading = false));
  }
  handleResponse(response) {
    if (!response.data) {
      throw response;
    }
    this.responseData = JSON.parse(response.data);
    console.log(this.responseData);
  }
  handleError(error) {
    this.errorMessage = Server_Error;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Something is wrong",
        message:  error.message,
        variant: "error"
      })
    );
    console.error(error);
  }
}