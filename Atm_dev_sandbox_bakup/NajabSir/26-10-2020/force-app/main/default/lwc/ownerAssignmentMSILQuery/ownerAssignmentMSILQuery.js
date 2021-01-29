import { LightningElement, api,wire } from 'lwc';
//import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getQueueIdApex from '@salesforce/apex/CaseActionCreation.getQueueId';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PREVIOUS_OWNER_FIELD from '@salesforce/schema/Case.Previous_Owner__c';
import MSIL_NON_SF_FIELD from '@salesforce/schema/Case.MSIL_Non_SF_Stakeholder_Email__c';

export default class OwnerAssignmentMSILQuery extends NavigationMixin(LightningElement) {
@api recordId;
 options=[{label:'Reassign to CCM',value:'Reassign to CCM'},
 {label:'Update Category Details',value:'Update Category Details'},
 {label:'Send Back to Previous Stakeholder',value:'Send Back to Previous Stakeholder'},
 {label:'Pending Customer Response',value:'Pending Customer Response'},
 {label:'Pending MSIL Response',value:'Pending MSIL Response'},
 {label:'Closed',value:'Closed'}
];
value;
remarks;
message='Please click on save to send the Query back to the previous stakeholder';
showFirstScreen=true;
 showNextScreen=false;
 showReassigntoCCMScreen=false;
 showScreen=false;
 showsendBacktoPreviousScreen=false;
 showstatusField=false;
 showUpdateCategoryDetailsScreen=false;
isSpinnerShow = false;
spocQueuId;
pendingCustomerQueuId;
pendingMsilQueuId;
@wire(getRecord, { recordId: '$recordId', fields: [ PREVIOUS_OWNER_FIELD, MSIL_NON_SF_FIELD] }) case;

get previousOwner() { return getFieldValue(this.case.data, PREVIOUS_OWNER_FIELD); }
get msilNonSf() { return getFieldValue(this.case.data, MSIL_NON_SF_FIELD); }

connectedCallback(){
    if(this.msilNonSf!=undefined){
        this.message ='Please use the send Email function to send it back to Non-SF Stakeholder.';
    }
    getQueueIdApex()
    .then(result => {
        if(result){
            for(var queue=0 ; queue<result.length;queue++){
                
                if(result[queue].DeveloperName==='CRM_1_SPOCs'){
                    this.spocQueuId=result[queue].Id;
                }else if(result[queue].DeveloperName==='Pending_Customer_Response'){
                    this.pendingCustomerQueuId=result[queue].Id;
                }else if(result[queue].DeveloperName==='Pending_MSIL_Response'){
                    this.pendingMsilQueuId=result[queue].Id;
                }
            }
    }
    })
}
handleChange(event){
    if(event.target.value) {
    this.showNextScreen=true;
    this.value=event.target.value}
    else this.showNextScreen=false;
}
handleremarkchange(event){
    if(event.target.value) {
    this.remarks=event.target.value}
}

handleNext(event){
    this.showNextScreen=false;
    this.showFirstScreen=false;
    this.showScreen=false;
    this.showsendBacktoPreviousScreen=false;
    this.showReassigntoCCMScreen=false;
    this.showstatusField=false;
if(this.value==='Update Category Details'){
    this.showUpdateCategoryDetailsScreen=true; 
}else{
    this.showScreen=true;
    if(this.value==='Send Back to Previous Stakeholder'){ 
    this.showsendBacktoPreviousScreen=true;
    }else if(this.vakue==='Reassign to CCM'){
        this.showReassigntoCCMScreen=true;
    }else{
        this.showstatusField=true;
    }
}
}

handlePrevious(event){
this.showFirstScreen=true;
this.value=undefined;
this.showScreen=false;
}
handleOnload(event) {
   // this.isSpinnerShow = false;
}
handleError(event) {
    this.isSpinnerShow = false;
}
saveOwner(event) {
    this.isSpinnerShow = true;
        const submitBtn = this.template.querySelector('.submit-btn');
        submitBtn.click();
}
// Method Called on submit of Record Edit Form
handleSubmit(event) {
    this.isSpinnerShow = true;
    event.preventDefault();
    const fields = event.detail.fields;
    if(this.spocQueuId && this.value==='Reassign to CCM')
    fields.OwnerId=this.spocQueuId;
    else if(this.pendingCustomerQueuId && this.value==='Pending Customer Response')
    fields.OwnerId=this.pendingCustomerQueuId;
    else if(this.pendingMsilQueuId && this.value==='Pending MSIL Response')
    fields.OwnerId=this.pendingMsilQueuId;
    else if(this.value==='Closed')
    fields.Status='Closed';
    if(this.value==='Send Back to Previous Stakeholder' &&  this.previousOwner != undefined)
    fields.OwnerId=this.previousOwner;
    if(this.remarks)
    fields.MSIL_Remarks__c=this.remarks;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    
}
handleSuccess(event){
    this.isSpinnerShow = false;
    const toastEvt = new ShowToastEvent({
        "title": "Success!",
        "message": 'Details has been updated successfully' ,
        "variant" :"success"
    });
    this.dispatchEvent(toastEvt);
    eval("$A.get('e.force:refreshView').fire();");
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Case',
            actionName: 'view'
        }
      });
}

}