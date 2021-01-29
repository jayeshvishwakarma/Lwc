import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import fetchData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import { getRecord } from "lightning/uiRecordApi";
const columns = [
  { label: 'Policy No', fieldName: 'policyNo' },
  { label: 'Previous Policy No', fieldName: 'previousPolicyNo' },
  { label: 'Expiry Date', fieldName: 'expiryDate' },
  { label: 'Registration No', fieldName: 'registrationNo' },
  { label: 'Sub Model', fieldName: 'subModel'},
  { label: 'Insurance Company', fieldName: 'insuranceCompany'},
  { label: 'PG Attempt Date', fieldName: 'pgAttemptDate' },
  { label: 'Policy Status', fieldName: 'policyStatus' },
  { label: 'Proposal No', fieldName: 'proposalNo' },
  { label: 'Premium Amount', fieldName: 'premiumAmount' },
  { label: 'Refund Status', fieldName: 'refundStatus' },
  { label: 'Reference Number', fieldName: 'referenceNumber' }
];

export default class IndtOnlineTrans extends LightningElement {
    data;
    columns = columns;
    loading = false;
    errorMessage;
    @api recordId;
  
    @api handleFetchData(policynumber) {
      console.log('Inside onlineTransDetails');
      console.log(policynumber);
      if (policynumber)
        this.fetchData(policynumber);
    }
  
    @wire(getRecord, {
      recordId: "$recordId",
      fields: ["Case.Policy_No__c"]
    })
    wiredCurrentUser({ error, data }) {
      if (this.recordId) {
        this.loading = true;
        if (data) {
          console.log('data.fields.Policy_No__c.value----->', data.fields.Policy_No__c.value);
          if (data.fields.Policy_No__c.value) {
            //this.policyNumberValue = data.fields.Policy_No__c.value;
            this.fetchData(data.fields.Policy_No__c.value);
          } else {
            let errMsg;
            errMsg = 'Policy Number is missing in Case object.' + ' ' + Server_Error;
            this.handleErrorCondition(errMsg);
          }
        } else if (error) {
          console.log('error------->', error);
          this.handleErrorCondition(Server_Error);
        }
      }
    }
  
    handleErrorCondition(message) {
      this.errorMessage = message;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Something is wrong",
          message: this.errorMessage,
          variant: "error"
        })
      );
      this.loading = false;
    }
  
  
    fetchData(policynumber) {
      console.log('Inside fetchData');
      this.loading = true;
      // prepare request
      let urlParams = {
        policyNumber: policynumber
      };
      let params = {
        jitName: "InsOnlineTrans_Details",
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
        const selectedEvent = new CustomEvent('datafetched', { detail: false });
        this.dispatchEvent(selectedEvent);
        throw response;
      } else {
        this.dataLoaded = true;
        console.log(response.data);
        let policyPaymentArray = [];
        policyPaymentArray.push(JSON.parse(response.data).policyPaymentDetails);
        //this.data = policyPaymentArray;
        this.data=JSON.parse(response.data).policyPaymentDetails;
        console.log(this.data);
  
      }
    }
    handleError(error) {
      this.errorMessage = error.message;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Something is wrong",
          message: error.message,
          variant: "error"
        })
      );
      this.loading = false;
      //console.error(error);
    }


}