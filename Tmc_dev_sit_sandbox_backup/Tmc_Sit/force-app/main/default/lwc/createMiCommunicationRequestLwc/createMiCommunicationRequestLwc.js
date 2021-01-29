import { LightningElement, api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getServiceCalculatorData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
//fields need to be fetched
const FIELDS = ['Case.CaseNumber', 'Case.First_Name__c','Case.Last_Name__c','Case.Mobile_Number__c','Case.Email__c','Case.Policy_No__c','Case.Case_Type__c','Case.CreatedDate'];
export default class CreateMiCommunicationRequestLwc extends LightningElement {
@api recordId;
caseData;
caseNumber;
miJSONBody;
claimNumber;
templateName;
@track loading = false; // This varibale is used to control the visibility of spinner
dbsErrorMsg;
// wire method to fetch all the case related fields using uiRecordApi
@wire(getRecord, { 
    recordId: '$recordId', 
    fields: FIELDS 
    })
    WiredCaseData({error,data}){
        if(error){
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            )
        } else if (data) {
            //assign data in property
                this.caseData = data;
                this.caseNumber = this.recordId;
    }
}

//method to hide save button while spinner is on
get loaded() {
    return !this.loading;
}
//method to save the data using record-edit-form
handleSubmit(event) {
    event.preventDefault();       // stop the form from submitting at initial level
    const fields = event.detail.fields;
    fields.Case_Number__c = this.recordId;
    fields.DPS_error_details__c = this.dbsErrorMsg;
    this.template.querySelector('lightning-record-edit-form').submit(fields);//submit fields after getting populated all the related value 
}
//method to call the api with JSON body and no paramter
handleApiCallout() {
    let tempName = this.template.querySelector('[data-id="tempName"]');
    let claimNum = this.template.querySelector('[data-id="claimNum"]');
    if(this.caseData && tempName.value !== null){
        this.loading = true;
            this.miJSONBody = {
                firstName : this.caseData.fields.First_Name__c.value ? this.caseData.fields.First_Name__c.value : '',
                lastName : this.caseData.fields.Last_Name__c.value ? this.caseData.fields.Last_Name__c.value : '',
                mobileNumberOfCustomer : this.caseData.fields.Mobile_Number__c.value ? this.caseData.fields.Mobile_Number__c.value : '',
                emailAddressOfCustomer : this.caseData.fields.Email__c.value ? this.caseData.fields.Email__c.value : '',
                policyNumber : this.caseData.fields.Policy_No__c.value ? this.caseData.fields.Policy_No__c.value : '',
                commType : "call",
                type : this.caseData.fields.Case_Type__c.value ? this.caseData.fields.Case_Type__c.value : '',
                templateName : tempName.value,
                claimNumber : claimNum.value,
                caseNumber : this.caseData.fields.CaseNumber.value ? this.caseData.fields.CaseNumber.value : '',
                createdDate : this.caseData.fields.CreatedDate.value ? this.caseData.fields.CreatedDate.value : '',
                id : this.recordId,
            }
            let params = {
                jitName: "MI_Communication_Request",
                jsonBody: JSON.stringify(this.miJSONBody),
                urlParam: " "
            }
            console.log('params is --------',params);
            //call the class method
            getServiceCalculatorData(params)
            .then(result=>{
                console.log('result---------',result);
                if(result.status === 'Success'){
                    const submitBtn = this.template.querySelector('.submit-btn');
                    submitBtn.click();
                    this.loading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Success",
                          message: "Communication request is submitted successfully",
                          variant: "Success"
                        })
                      );
                      tempName.reset();
                      claimNum.reset();
                }
                //if any error so still save the data in Mi Communication with error specified in DPS error field
                else{
                    this.dbsErrorMsg = result.message;
                    const submitBtn = this.template.querySelector('.submit-btn');
                    submitBtn.click(); 
                    this.loading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Error",
                          message: result.message,
                          variant: "Error"
                        })
                      );
                      tempName.reset();
                      claimNum.reset();
                }
            })
            .catch(error=>{
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Error",
                      message: error.message,
                      variant: "Error"
                    })
                  );
            })
    
    }else{
        // To popup error message when required fields are missing message.
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Something is wrong",
            message: "Required fields are missing",
            variant: "error"
          })
        );
    }
}
}