import { LightningElement, api,wire } from 'lwc';
//import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getQueueIdApex from '@salesforce/apex/CaseActionCreation.getQueueId';
import checkMemberofQueue from '@salesforce/apex/CaseActionCreation.suzukiConnectQueueMemberCheck';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PREVIOUS_OWNER_FIELD from '@salesforce/schema/Case.Previous_Owner__c';
import MSIL_NON_SF_FIELD from '@salesforce/schema/Case.MSIL_Non_SF_Stakeholder_Email__c';
/**** Added by Sunit for Suzuki Connect process ****/
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import additionalInfo from '@salesforce/schema/Case.Additional_Information__c';
import closedWithoutSNSubtype from '@salesforce/schema/Case.Closed_Without_SN_Subtype__c';
import CHANNEL from '@salesforce/schema/Case.Channel__c'; //Added for Suzuki connect by Sunit
import updateCase from '@salesforce/apex/CreateCaseController.updateCase';
import getSuzukiConnectConstant from '@salesforce/apex/ProjectUtility.getConstantValue'; // Added for getting custom setting detail (Suzuki connect by Sunit)
import deleteDocLists from '@salesforce/apex/dynamicFileUploadController.deleteDocList'; // Added for deleting uploaded document (Suzuki Connect by Sunit)
/**************************************************/


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
suzukiConnectRemark; // Added to store remarks for Suzuki connect process(Added by Sunit)
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
pendingPanasonicQueuId; //Added to store Panasonic queue Id for suzuki connect added by Sunit
case={}; //Added to store case details fetched in wire method added by Sunit
suzukiconnect=false; // Added to show suzuki connect field added by sunit for Suzuki connect
suzukiConnectConstant; // Addec to store Suzuki Connect constant (Added by Sunit)
uploadedFiles; //This is used to store uploaded file
uploadClarification=false;
candelete=true;
selectedCloseWithoutSN=false;

@wire(getRecord, { recordId: '$recordId', fields: [ PREVIOUS_OWNER_FIELD, MSIL_NON_SF_FIELD,CHANNEL] })
caseDetails({ error, data }) {
    if (data) {
        this.case.data = data;
        this.suzukiConnectOptions();
    }
    else{
        console.log(error);
    }
}
get previousOwner() { return getFieldValue(this.case.data, PREVIOUS_OWNER_FIELD); }
get msilNonSf() { return getFieldValue(this.case.data, MSIL_NON_SF_FIELD); }
get channel() { return getFieldValue(this.case.data, CHANNEL); }
get caseAdditionalInfo() { return getFieldValue(this.case.data, additionalInfo); }

connectedCallback(){
    this.getSuzukiConnectConstantDetails(); // added for fetching suzuki connerct constant details from custom setting (Added by Sunit)
    
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
/***** Added for Suzuki Connect by Sunit *****/
@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: closedWithoutSNSubtype})
    typePicklistValuesClosedWithoutSNSubtype({error, data}){
        if (data) {
            console.log('Inside typePicklistValuesClosedWithoutSNSubtype');
            this.closedWithoutSNList=data;
        } else if(error){
            console.log('Inside error');
        }
    }
handleUploadFinished(event) {
    this.uploadedFiles = event.detail.files[0];
}
preview(event){
    var idx = event.target.getAttribute('data-index');
        if(idx){ 
             this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                 attributes: {
                    pageName: 'filePreview'
                 },
                 state : {
                     // assigning ContentDocumentId to show the preview of file
                     selectedRecordId:idx
                 }
               })
        } 
    
}
// Method to delete document
deletedoc(event){
    this.isLoading = true;
    deleteDocLists({
        docId :event.target.getAttribute('data-index')
    })
    .then(result => {
        this.isLoading = false;
        if(result.includes('SUCCESS')){
            this.uploadedFiles=null;
            this.connectedCallback();
        }
        // Apex Exception handling
        else{ 
            this.messageHandler(result,'error','ERROR!');
        }

    })
    // Javascript Exception handling
    .catch(error => {
        
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
        this.isLoading = false;
        this.messageHandler(this.error,'error','ERROR!');
    })  
}
suzukiConnectOptions(){
    if(this.case.data.recordTypeInfo.name=='Suzuki Connect'){
        this.options=[
        {label:'Pending Customer Response',value:'Pending Customer Response'},
        {label:'Pending Panasonic',value:'Pending Panasonic'},
        {label:'Close With SN',value:'Close With SN'},
        {label:'Close Without SN',value:'Close Without SN'}
        ];
        this.suzukiconnect=true;
        checkMemberofQueue({channel:this.channel})
        .then(result => {
            console.log(result);
            if(result){
                this.options=[
                    {label:'Pending Customer Response',value:'Pending Customer Response'},
                    {label:'Reassigned - Add Info',value:'Reassigned - Add Info'},
                    {label:'Reassigned - Customer Dissatisfied',value:'Reassigned - Customer Dissatisfied'},
                    {label:'Close With SN',value:'Close With SN'},
                    {label:'Close Without SN',value:'Close Without SN'}
                    ];
            }
            else{
                this.uploadClarification=true;
                this.options=[
                    {label:'Update Clarification',value:'Update Clarification'},
                    ];
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
}
updateCaseApex(caseObjString) {
    try {
        this.error = '';
        this.isSpinnerShow = true;
        updateCase({
                caseString: caseObjString,
                filedata :this.uploadedFiles!=null?this.uploadedFiles.documentId:null
            })
            .then(result => {
                if (result) {
                    this.handleSuccess(result);
                }
                this.isSpinnerShow = false;
            })
            .catch(error => {
                this.error = error;
                if (error && Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (error && typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                //this.showToast('Error', this.error, 'error');
                this.handl
                this.isSpinnerShow = false;
            });
    } catch (e) {
        console.log('Exception in updateCaseApex JS method');
        console.log(e);
    }
}
getSuzukiConnectConstantDetails(){
    getSuzukiConnectConstant({
        'name': 'Suzuki Connect'
    })
    .then(result => {
        console.log('getSuzukiConnectConstant ' + result);
        if (result) {
            console.log(result);
            this.suzukiConnectConstant=result;
        }
    })
    .catch(error => {
        this.error = error;
        console.log(JSON.stringify(error));
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
    });
}

/*********************************************/
handleChange(event){
    let previousValue;
    if(event.target.value) {
    this.showNextScreen=true;
    previousValue=this.value;
    this.value=event.target.value}
    else this.showNextScreen=false;
    /***** Added for Suzuki Connect by Sunit *****/
    if(event.target.value==='Close Without SN' && event.target.name==='Choose'){
        console.log(this.closedWithoutSNList);
        this.selectedCloseWithoutSN=true;
    }
    else if(event.target.name==='Choose'){
        this.selectedCloseWithoutSN=false;
    }
    if(event.target.name==='Closed Without SN Subtype'){
        this.selectedClosedWithoutSNSubtype=event.target.value;
        this.value=previousValue;
    }
    /*********************************************/
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
if(this.msilNonSf!=undefined){
    console.log('kk'+this.msilNonSf);
    this.message ='Please use the send Email function to send it back to Non-SF Stakeholder.';
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
    /***** Added for Suzuki Connect by Sunit *****/
    if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.pendingCustomerQueuId && this.value==='Pending Customer Response'){
        fields.Id=this.recordId;
        fields.Status='Pending Customer Response';
        fields.Suzuki_Connect_Status__c='Pending Customer Response';
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.IsStopped = false;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    else if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.pendingCustomerQueuId && this.value==='Pending Panasonic'){
        fields.Id=this.recordId;
        fields.Status='Pending Panasonic';
        fields.OwnerId=this.pendingPanasonicQueuId;
        fields.Suzuki_Connect_Status__c='Pending Panasonic';
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.IsStopped = false;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    else if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.pendingCustomerQueuId && this.value==='Update Clarification'){
        fields.Id=this.recordId;
        fields.Status='Open';
        if(this.channel=='Nexa'){
            fields.OwnerId=this.suzukiConnectConstant.Nexa_Suzuki_Connect_Queue_Id__c;
        }
        else if(this.channel=='Arena'){
            fields.OwnerId=this.suzukiConnectConstant.Arena_Suzuki_Connect_Queue_Id__c;
        } 
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.IsStopped = false;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    else if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.pendingCustomerQueuId && this.value==='Reassigned - Add Info'){
        fields.Id=this.recordId;
        fields.Status='Reassigned - Add Info';
        fields.Suzuki_Connect_Status__c='Reassigned - Add Info';
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.IsStopped = false;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    else if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.pendingCustomerQueuId && this.value==='Reassigned - Customer Dissatisfied'){
        fields.Id=this.recordId;
        fields.Status='Reassigned - Customer Dissatisfied';
        fields.Suzuki_Connect_Status__c='Reassigned - Customer Dissatisfied';
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.IsStopped = false;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    else if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.value==='Close With SN'){
        console.log('Inside if');
        fields.Id=this.recordId;
        fields.Status='Closed';
        fields.Closure_Mode__c='Satisfaction Note';
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    else if(this.case.data.recordTypeInfo.name=='Suzuki Connect' && this.value==='Close Without SN'){
        console.log('Inside if 1');
        fields.Id=this.recordId;
        fields.Status='Closed';
        fields.Suzuki_Connect_Remark__c=this.remarks;
        fields.MSIL_Remarks__c=null;
        fields.Additional_Information__c=this.caseAdditionalInfo;
    }
    console.log(fields);
    console.log(fields.Suzuki_Connect_Remark__c);
    if(this.case.data.recordTypeInfo.name=='Suzuki Connect'){
        this.updateCaseApex(JSON.stringify(fields));
    }
    else{
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    /********************************************/
    
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