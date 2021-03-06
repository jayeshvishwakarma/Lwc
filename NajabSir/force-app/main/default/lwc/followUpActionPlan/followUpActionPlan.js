/*eslint-disable  no-console*/

import { LightningElement, api, track, wire } from 'lwc';
//import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Enquiry_FIELD from '@salesforce/schema/Opportunity.Enquiry_Scoring__c';
import EnquiryStage_FIELD from '@salesforce/schema/Opportunity.Enquiry_Stage__c';

import Enquiry_Reason_FIELD from '@salesforce/schema/Opportunity.Reason__c';
import Enquiry_SubReason_FIELD from '@salesforce/schema/Opportunity.SubReason__c';

import Server_Error from '@salesforce/label/c.Server_Error';

import retriveEnquiryInfo from '@salesforce/apex/GenerateEnquiryfollowUp.retriveEnquiryInfo';
import retriveEnquiryDetail from '@salesforce/apex/GenerateEnquiryfollowUp.retriveEnquiryDetail';
import retriveOpenTaskInfo from '@salesforce/apex/GenerateEnquiryfollowUp.retriveOpenTaskInfo';
import retriveReasonList from '@salesforce/apex/GenerateEnquiryfollowUp.retriveReasonList';
import retriveSubReasonList from '@salesforce/apex/GenerateEnquiryfollowUp.retriveSubReasonList';
import createPreOrPostOpenFollowUp from '@salesforce/apex/GenerateEnquiryfollowUp.createPreOrPostOpenFollowUp';
import updatePreOpenFollowUp from '@salesforce/apex/GenerateEnquiryfollowUp.updatePreOpenFollowUp';
import updatePostOpenFollowUp from '@salesforce/apex/GenerateEnquiryfollowUp.updatePostOpenFollowUp';
import retriveGeneralFollowUpDetail from '@salesforce/apex/GenerateEnquiryfollowUp.retriveGeneralFollowUpDetail';
import updateGeneralFollowUpInfo from '@salesforce/apex/GenerateEnquiryfollowUp.updateGeneralFollowUpInfo';
import checkUserPermissions from '@salesforce/apex/GenerateEnquiryfollowUp.checkUserPermissions';

export default class followUpActionPlan extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    @track error;
    @track enqName;
    @track taskId;
    @track openTaskActivityDate;
    @track openTaskType;

    @api deviceFormFactor;

    @track enquiryScoringOptions = [];
    @track reasonOptions = [];
    @track subReasonOptions = [];
    @track enquiryStageOptions = [];
    @track remarkValue = '';
    
    @track taskTypeOptions = [];
    @track isPending = '';
    @track enquiryApprovalStatus = '';
    @track stageData = '';

    @track preBooking = '';
    @track postBooking = '';
    @track followUpType = '';

    @track newTaskDetail = {ReminderDateTime : '', type : '', Enquiry_Stage__c : ''};
    @track updateTaskDetail = {type : '', Enquiry_Scoring__c : '', Reason__c : '', SubReason__c : '', Enquiry_Stage__c : ''};

    // Used In Creating Post Follow Up 
    @track post_actionType = [];

    @track post_Booking_Stage = [
        {label : 'Customer contact', value: 'Customer contact'},
        {label : 'Full amount received', value: 'Full amount received'},
        {label : 'Partial amount received', value: 'Partial amount received'}
    ];

    @track post_newTaskDetail = {ReminderDateTime: '', type : '', Enquiry_Stage__c : ''};
    @track post_updateTaskDetail = {type : '', Enquiry_Stage__c : '', Description : ''};

    @track generalStatusOptions;
    @track generalActionOptions;
    @track generalEnquiryStageOptions;

    @track generalFollowUp = false;
    @track generalOpenTaskType;
    @track generalopenTaskActivityDate;

    @track generalUpdateTaskDetail = {Enquiry_Scoring__c : '', Type : '', Enquiry_Stage__c : 'E', Description : ''};
    @track generalNewTaskDetail = {ReminderDateTime : '', Type : '', Enquiry_Stage__c : 'E'};
    @track isLoading = false;

    currentEnquiryId = '';
    followUpFrom = '';

    reasonField;
    subReasonField;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Enquiry_Reason_FIELD })
    enqReasonValues({ data }) {
        if (data) {
            this.reasonField = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Enquiry_SubReason_FIELD })
    enqSubReasonValues({ data }) {
        if (data) {
            this.subReasonField = data.values;
        }
    }

    get showReminderLabel(){
        return this.deviceFormFactor==='DESKTOP' ? '' : 'Reminder DateTime';
    }

    get makeRequiredNextAction() {
        if (this.updateTaskDetail.Enquiry_Scoring__c !== "F") {
            return true;
        } else if(this.updateTaskDetail.Enquiry_Scoring__c === "F"){
            return false;
        }
        return false;
    }

    get makeReasonRequired() {
        if (this.updateTaskDetail.Enquiry_Scoring__c === "F" || this.updateTaskDetail.Enquiry_Scoring__c === 'E') {
            return true;
        } else if(this.updateTaskDetail.Enquiry_Scoring__c !== "F" || this.updateTaskDetail.Enquiry_Scoring__c !== 'E'){
            return false;
        }
        return false;
    }

    get makeSubReasonRequired() {
        if (this.updateTaskDetail.Enquiry_Scoring__c === "F") {
            return true;
        } else if(this.updateTaskDetail.Enquiry_Scoring__c !== "F"){
            return false;
        }
        return false;
    }

    // GET Enquiry Scoring PICKIST VALUES
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Enquiry_FIELD })
    wiredEnquiryValue({error, data}){
        if (data) {
            this.enquiryScoringOptions = data.values;
        } else if(error){
            console.log('== Enquiry Scoring PickList Error ', error);
        }
    }

    // GET Enquiry Stage PICKIST VALUES
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: EnquiryStage_FIELD })
    wiredEnquiryStageValue({error, data}){
        if (data) {
            this.enquiryStageOptions = data.values;
            console.log('== enquiryStageOptions ', this.enquiryStageOptions);
        } else if(error){
            /*eslint-disable  no-console*/
            console.log('== Enquiry Stage PickList Error ', error);
        }
    }

    connectedCallback(){
        this.isLoading = true;
        checkUserPermissions({recordId : this.recordId}).then(result => {
            console.log('== Permission Result  ', result);
            this.isLoading = false;
            if(result){
                if(this.recordId.startsWith('00T')){
                    this.followUpFrom = 'Task';
                    this.conditionalConnectedCallBack(retriveEnquiryInfo);
                }else if(this.recordId.startsWith('006')){
                    this.followUpFrom = 'Enquiry';
                    this.conditionalConnectedCallBack(retriveEnquiryDetail);
                }
            }else{
                this.error = true;
            }

        })
        .catch(error => {
            this.isLoading = false;
            console.log('== Permission Error ',error);
            this.showErrorDetails(error);
        })

        
    }

    conditionalConnectedCallBack(retriveInfoFrom){
        this.isLoading = true;
        retriveInfoFrom({
            recordId : this.recordId
        }).then(result => {
            console.log('== Enquiry result ', result);
            this.isLoading = false;
            if(result === Server_Error){
                this.error = result;
            }else{
                this.record = result;
                this.error = undefined;
                this.currentEnquiryId = result.Id;
                this.enqName = result.Name;
                this.taskId = result.Current_Open_Follow_up__c;
                this.stageData = result.StageName;

                if(result.RecordTypeId && result.RecordType.Name === 'Vehicle Sales'){    
                    if(this.stageData !== '' && (this.stageData === 'New' || this.stageData === 'Pre-Booking')){
                        this.preBooking = 'Show';
                        this.postBooking = '';
                        this.followUpType = 'Pre Booking Follow-up';
                    }else if(this.stageData !== '' && (this.stageData === 'Booking' || this.stageData === 'Retail' || this.stageData === 'Delivery/Closed Won' || this.stageData === 'Closed Lost')){
                        this.preBooking = '';
                        this.postBooking = 'Show';
                        this.followUpType = 'Post Booking Follow-up';
                    }
                    this.retriveTaskDetails();
                }else if(result.RecordTypeId && result.RecordType.Name === 'Accessories Sales'){
                    console.log('== In Accessories Data ', this.stageData);
                    this.generalFollowUp = true;
                    this.retriveGeneralFollowUpDetails();
                }

            }
        }).catch(error => {
            this.isLoading = false;
            console.log('== Task Error ',error);
            this.showErrorDetails(error);
        })
    }

    /*
    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.Name','Opportunity.StageName','Opportunity.Current_Open_Follow_up__c','Opportunity.Variant__r.Name','Opportunity.Enquiry_Scoring__c','Opportunity.Enquiry_Stage__c', 'Opportunity.RecordTypeId', 'Opportunity.RecordType.Name'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.enqName = this.record.fields.Name.value;
            this.taskId = this.record.fields.Current_Open_Follow_up__c.value;

            console.log('== Current Open Follow up Id Value ',this.record.fields.Current_Open_Follow_up__c.value);
            console.log('== Data ',data);
            console.log('== Name taskId ',this.taskId);
            
            if(data.fields.RecordTypeId && data.fields.RecordType.value.fields.Name.value === 'Vehicle Sales'){
                this.stageData = data.fields.StageName.value;
                if(this.stageData !== '' && (this.stageData === 'New' || this.stageData === 'Pre-Booking')){
                    this.preBooking = 'Show';
                    this.postBooking = '';
                    this.followUpType = 'Pre Booking Follow-up';
                }else if(this.stageData !== '' && (this.stageData === 'Booking' || this.stageData === 'Retail' || this.stageData === 'Delivery/Closed Won' || this.stageData === 'Closed Lost')){
                    this.preBooking = '';
                    this.postBooking = 'Show';
                    this.followUpType = 'Post Booking Follow-up';
                }
                this.retriveTaskDetails();
            }else if(data.fields.RecordTypeId && data.fields.RecordType.value.fields.Name.value === 'Accessories Sales'){
                console.log('== In Accessories Data ');
                this.generalFollowUp = true;
                this.retriveGeneralFollowUpDetails();
            }
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    */

    get name() {
        return this.record.fields.Name.value;
    }


    // To Fetch Task Information and Enquiry Approval Status
    retriveTaskDetails(){
        /*eslint-disable  no-console*/
        console.log('== In Handle Call method ');
        this.isLoading = true;
        retriveOpenTaskInfo({
            enquiryId : this.currentEnquiryId,
            stageName : this.stageData,
            taskId : this.taskId
        })
        .then(result => {
            console.log('== Task Result ',result);
            this.isLoading = false;

            this.taskId = result.tsk.Id;
            this.enquiryApprovalStatus = result.approvalStatus;

            // Task Type field value for record type pre booking
            this.taskTypeOptions = result.preBookingTaskTypeList;

            // Task Type field value for record type post booking
            this.post_actionType = result.postBookingTaskTypeList;

            this.openTaskActivityDate = result.tsk.ReminderDateTime;
            // For Pre Booking Open Task
            this.updateTaskDetail.type = result.tsk.Type;
            // For Post Booking Open Task
            this.post_updateTaskDetail.type = result.tsk.Type;
            this.post_updateTaskDetail.Enquiry_Stage__c = result.tsk.Enquiry_Stage__c;

            this.openTaskType = this.retriveTypeLabelValue(result);

            if(this.enquiryApprovalStatus === 'Pending'){
                this.isPending = '';
            }else{
                this.isPending = 'Hide';
            }
            console.log('== isPending status ', this.isPending);

            if(this.enquiryApprovalStatus === 'Pending'){
                const evt = new ShowToastEvent({
                    title: 'Enquiry',
                    message: 'Enquiry is pending for approval.',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            }

            console.log('== status ',this.enquiryApprovalStatus);
            console.log('== openTaskActivityDate ',this.openTaskActivityDate);
            console.log('== openTaskType ',this.openTaskType);
        })
        .catch(error => {
            this.isLoading = false;
            console.log('== Task Error ',error);
            this.showErrorDetails(error);
        })
    }

    retriveTypeLabelValue(result){
        let typeDataValue = '';
        if(result && result.tsk && result.tsk.Type){
            let typeValue = result.tsk.Type;

            for(let i = 0; i< this.taskTypeOptions.length; i++){
                let tempData = this.taskTypeOptions[i];
                if(tempData.value === typeValue){
                    typeDataValue = tempData.label;
                }
            }
            if(!typeDataValue){
                for(let i = 0; i< this.post_actionType.length; i++){
                    let tempData = this.post_actionType[i];
                    if(tempData.value === typeValue){
                        typeDataValue = tempData.label;
                    }
                }
            }

        }
        return typeDataValue;
    }

    retriveGeneralFollowUpDetails(){
        this.isLoading = true;
        retriveGeneralFollowUpDetail({
            enquiryId : this.currentEnquiryId,
            taskId : this.taskId
        })
        .then(result => {
            console.log('== General FollowUp result ',result);

            this.taskId = result.tsk.Id;
            this.generalopenTaskActivityDate = result.tsk.ReminderDateTime;
            this.generalOpenTaskType = this.retriveGeneralTypeLabelValue(result);
            
            // Task Type field value for record type pre booking
            this.generalStatusOptions = result.generalStatusList;

            // Task Type field value for record type post booking
            this.generalActionOptions = result.generalActionList;

            // Task Type field value for record type pre booking
            this.generalEnquiryStageOptions = result.generalEnquiryStageList;
            
            let taskKeys = Object.keys(result.tsk);
            // Added on 14 Nov 2019 Requested By (Prabhav)
            this.generalUpdateTaskDetail.Enquiry_Stage__c = taskKeys.includes('Enquiry_Stage__c') ? result.tsk.Enquiry_Stage__c : 'E';
            this.generalNewTaskDetail.Enquiry_Stage__c = this.generalUpdateTaskDetail.Enquiry_Stage__c;

            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('== General FollowUp Error ',error);
            this.showErrorDetails(error);
        })
    }

    retriveGeneralTypeLabelValue(result){
        let typeDataValue = '';
        if(result && result.tsk && result.tsk.Type){
            let typeValue = result.tsk.Type;

            for(let i = 0; i< result.generalActionList.length; i++){
                let tempData = result.generalActionList[i];
                if(tempData.value === typeValue){
                    typeDataValue = tempData.label;
                }
            }

        }
        return typeDataValue;

    }



    // To Fetch Enquiry dependent Reason picklist value
    handleChange(event) {
        this.isLoading = true;
        console.log('== Selected Enquiry Scoring ',event.detail.value);

        retriveReasonList({
            selectedEnquiryScoring : event.detail.value
        })
        .then(result => {
            console.log('== Final reasonOptions  ', result);
            this.reasonOptions = [];
            for(let i = 0; i<result.length; i++){
                let objInfo = {};
                objInfo.value = result[i];

                let eachValue = this.reasonField.find((item) => item.value === result[i]);
                if(eachValue){
                    objInfo.label = eachValue.label;
                }
                //objInfo.label = result[i];
                this.reasonOptions.push(objInfo);
            }
            this.isLoading = false;

        })
        .catch(error => {
            this.isLoading = false;
            console.log('== reasonOptions Error ',error);
            this.showErrorDetails(error);
        })
    }

    // To Fetch Enquiry dependent Reason picklist value

    handleSubReasonChange(event) {
        console.log('== Selected Reason ',event.detail.value);
        this.isLoading = true;
        retriveSubReasonList({
            selectedReason : event.detail.value
        })
        .then(result => {
            this.subReasonOptions = [];
            for(let i = 0; i<result.length; i++){
                let objInfo = {};
                objInfo.value = result[i];

                let eachValue = this.subReasonField.find((item) => item.value === result[i]);
                if(eachValue){
                    objInfo.label = eachValue.label;
                }

                this.subReasonOptions.push(objInfo);
            }
            console.log('== Final subReasonOptions  ', this.subReasonOptions);
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('== subReasonOptions Error ',error);
            this.showErrorDetails(error);
        })
    }

    // Handle Remark On Change Events
    handleUpdateTaskRemarkData(event){
        this.remarkValue = event.target.value;
    }

    // Handle On Change Events
    handleNewTaskData(event){
        let proTyname = event.target.name;

        if(proTyname === 'ReminderDateTime'){
            if(this.validateDateTimeFieldValue(event, ".inputCmp", this.openTaskActivityDate)){
                this.newTaskDetail[proTyname] = event.target.value;
            }
        }else{
            this.newTaskDetail[proTyname] = event.target.value;
        }
        
    }

    validateDateTimeFieldValue(event, className, openFollowUpActivityDate){
        let selectedDate = new Date(event.target.value);
        let todayValue = new Date();
        let inputCmp = Array.from(this.template.querySelectorAll(className));
        let validData = true;
        console.log('== ',openFollowUpActivityDate);
        for (let i = 0; i < inputCmp.length; i++) {
            let tempInputCmp = inputCmp[i];
            tempInputCmp.setCustomValidity("");
            if (selectedDate < todayValue) {
                validData = false;
                tempInputCmp.setCustomValidity("Please select future date only!");
            }
            tempInputCmp.reportValidity();
        }

        return validData;
    }

    // Handle On Change Events
    handleUpdateTaskData(event){
        let proTyname = event.target.name;
        if(proTyname === 'Enquiry_Scoring__c'){
            this.handleChange(event);
            this.updateTaskDetail.Reason__c = '';
            this.updateTaskDetail.SubReason__c = '';
        }
        if(proTyname === 'Enquiry_Stage__c'){
            // Added On 25 SEP 2019 -- As Suggested By Prabhav
            this.newTaskDetail[proTyname] = event.target.value;
        }
        if(proTyname === 'Reason__c'){
            this.handleSubReasonChange(event);
        }
        this.updateTaskDetail[proTyname] = event.target.value;
    }
    

    // Handle the Change Events For New Post Follow Up
    handlePostNewTask(event){
        let fieldName = event.target.name;

        if(fieldName === 'ReminderDateTime'){
            if(this.validateDateTimeFieldValue(event, ".inputCmp2", this.openTaskActivityDate)){
                this.post_newTaskDetail[fieldName] = event.target.value;
            }
        }else{
            this.post_newTaskDetail[fieldName] = event.target.value;
        }
    }

    // Handle the Change Events For Update Post Follow Up
    handlePostUpdateTask(event){
        let fieldName = event.target.name;
        // Added On 25 SEP 2019 -- As Suggested By Prabhav
        if(fieldName === 'Enquiry_Stage__c'){
            this.post_newTaskDetail[fieldName] = event.target.value;
        }
        this.post_updateTaskDetail[fieldName] = event.target.value;
    }

    // Handle the Change Events For General Follow Up
    handleGeneralUpdateTask(event){
        let fieldName = event.target.name;
        // Added On 25 SEP 2019 -- As Suggested By Prabhav
        if(fieldName === 'Enquiry_Stage__c'){
            this.generalNewTaskDetail[fieldName] = event.target.value;
        }
        this.generalUpdateTaskDetail[fieldName] = event.target.value;
    }

    // Handle the Change Events For New Post Follow Up
    handleGeneralNewTask(event){
        let fieldName = event.target.name;

        if(fieldName === 'ReminderDateTime'){
            if(this.validateDateTimeFieldValue(event, ".inputCmp3", this.generalopenTaskActivityDate)){
                this.generalNewTaskDetail[fieldName] = event.target.value;
            }
        }else{
            this.generalNewTaskDetail[fieldName] = event.target.value;
        }
    }

    // To Handle the data validation and perform Save and Update Operations for Post Follow up
    handleGeneralFollowSaveMethod(){
        this.isLoading = true;
        console.log('== In General follow Up ',this.currentEnquiryId);
        
        console.log('== In General follow Up ',this.validationCheckMethod());
        console.log('== In General follow Up ',this.toCheckInputField());

        if(this.validationCheckMethod() && this.toCheckInputField()){

            // For General Follow Up
            if(this.taskId !== null && this.taskId !== ''){
            
                updateGeneralFollowUpInfo({
                        enquiryId : this.currentEnquiryId,
                        enquiryStage : this.stageData,
                        taskId : this.taskId,
                        updateTaskData : JSON.stringify(this.generalUpdateTaskDetail),
                        newTaskData : JSON.stringify(this.generalNewTaskDetail),
                        recordTypeName : 'General Follow-up'
                    })
                    .then(result => {
                        console.log('== Update General Result  ', result);
                        this.isLoading = false;

                        if(this.followUpFrom === 'Task' && result && result.includes("00T")){
                            this.redirectToTaskDetail(result.split('#')[1]);
                        }else if(this.followUpFrom === 'Enquiry' && result && result.includes("SUCCESS")){
                            this.reloadPage();
                        }else if(result === 'RequestToLost'){
                            this.reloadPage();
                        }else{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: '',
                                    message: result,
                                    variant: 'error'
                                })
                             );
                        }

                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('== Update Case Error ',error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: error,
                                variant: 'error'
                            })
                        );
                    })
            }

        }else{
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your inputs and try again.',
                    variant: 'error'
                })
            );
        }
    }

    // To Close the Component
    redirectToTaskDetail(taskId){

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": taskId,
                "objectApiName": "Task",
                "actionName": "view"
            },
        });
       // window.location.reload();
    }

    reloadPage(){
        //window.location.reload();
        this.dispatchEvent(new CustomEvent('CloseCmp'));
    }

    // To Handle the data validation and perform Save and Update Operations for Pre Follow up

    //Temp Function
    validationCheckMethod(){
        const allValid1 = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid1;
    }

    toCheckInputField(){
        const allValid2 = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid2;
    }

    handleSaveMethod(){
        console.log('== Outer Enquiry Id ',this.currentEnquiryId);
        this.isLoading = true;
        if(this.validationCheckMethod() && this.toCheckInputField()){
            
            // For Pre Or Post Open Follow Up
            if(this.taskId === undefined || this.taskId === null || this.taskId === ''){
                
                console.log('== Inner Enquiry Id ',this.currentEnquiryId);
                console.log('== New Task Due Date ',this.newTaskDetail);
                
                createPreOrPostOpenFollowUp({
                    enquiryId : this.currentEnquiryId,
                    newTaskData : JSON.stringify(this.newTaskDetail),
                    recordTypeName : this.followUpType
                })
                .then(result => {
                    this.isLoading = false;
                    console.log('== Final reasonOptions  ', result);
                    this.reloadPage();
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('== reasonOptions Error ',error);
                    this.showErrorDetails(error);
                })
            }
            // For Pre Or Post Open Follow Up
            else if(this.taskId !== null && this.taskId !== ''){
                console.log('== In Update Task Method', this.updateTaskDetail);
            
                updatePreOpenFollowUp({
                    enquiryId : this.currentEnquiryId,
                    enquiryStage : this.stageData,
                    taskId : this.taskId,
                    remarkValue : this.remarkValue,
                    updateTaskData : JSON.stringify(this.updateTaskDetail),
                    newTaskData : JSON.stringify(this.newTaskDetail),
                    recordTypeName : this.followUpType
                })
                .then(result => {
                    let isModelClose = true;
                    this.isLoading = false;
                    console.log('== Pre Booking Case Result  ', result);
                        if(this.followUpFrom === 'Task' && result && result.includes("00T")){
                            this.redirectToTaskDetail(result.split('#')[1]);
                        }else if(this.followUpFrom === 'Enquiry' && result && result.includes("SUCCESS")){
                            this.reloadPage();
                        }else if(result === 'RequestToLost'){
                            this.reloadPage();
                        }else{
                            isModelClose = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: '',
                                    message: result,
                                    variant: 'error'
                                })
                             );
                        }
                        console.log(isModelClose);
                        if(isModelClose){
                            this.dispatchEvent(new CustomEvent('SubmitReq'));
                            console.log('close');
                        }
                        
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('== Update Case Error ',error);
                    this.showErrorDetails(error);
                })
            }

        }else{
            this.isLoading = false;
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your inputs and try again.',
                    variant: 'error'
                })
             );
        }

    }

    // To Handle the data validation and perform Save and Update Operations for Post Follow up
    handlePostFollowSaveMethod(){
        this.isLoading = true;
        console.log('== In post follow Up ',this.currentEnquiryId);
        
        console.log('== In post follow Up ',this.validationCheckMethod());
        console.log('== In post follow Up ',this.toCheckInputField());

        if(this.validationCheckMethod() && this.toCheckInputField()){

            if(this.taskId === undefined || this.taskId === null || this.taskId === ''){
            
                    console.log('== Inner Enquiry Id ',this.currentEnquiryId);
                    console.log('== New Task Due Date ',this.post_newTaskDetail);
                    
                    createPreOrPostOpenFollowUp({
                        enquiryId : this.currentEnquiryId,
                        newTaskData : JSON.stringify(this.post_newTaskDetail),
                        recordTypeName : this.followUpType
                    })
                    .then(result => {
                        this.isLoading = false;
                        console.log('== Final reasonOptions  ', result);
                        this.reloadPage();
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('== reasonOptions Error ',error);
                        this.showErrorDetails(error);
                    })
            }
            // For Pre Or Post Open Follow Up
            else if(this.taskId !== null && this.taskId !== ''){
                console.log('== In Update Task Method', this.updateTaskDetail);
            
                    updatePostOpenFollowUp({
                        enquiryId : this.currentEnquiryId,
                        enquiryStage : this.stageData,
                        taskId : this.taskId,
                        updateTaskData : JSON.stringify(this.post_updateTaskDetail),
                        newTaskData : JSON.stringify(this.post_newTaskDetail),
                        recordTypeName : this.followUpType
                    })
                    .then(result => {
                        let isModelClose = true;
                        this.isLoading = false;
                        console.log('== Post Booking Case Result  ', result);

                        if(this.followUpFrom === 'Task' && result && result.includes("00T")){
                            this.redirectToTaskDetail(result.split('#')[1]);
                        }else if(this.followUpFrom === 'Enquiry' && result && result.includes("SUCCESS")){
                            this.reloadPage();
                        }else if(result === 'RequestToLost'){
                            this.reloadPage();
                        }else{
                            isModelClose = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: '',
                                    message: result,
                                    variant: 'error'
                                })
                             );
                        }
                        console.log(isModelClose);
                        if(isModelClose){
                            this.dispatchEvent(new CustomEvent('SubmitReq'));
                            console.log('close');
                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('== Update Case Error ',error);
                        this.showErrorDetails(error);
                    })
            }

        }else{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your inputs and try again.',
                    variant: 'error'
                })
            );
        }
    }

    showErrorDetails(error){
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: error,
                variant: 'error'
            })
        );
    }

    //Method to close the quick action
    closeModal(){ 
        // Fire the custom event
        this.dispatchEvent(new CustomEvent('SubmitReq'));
    }

}