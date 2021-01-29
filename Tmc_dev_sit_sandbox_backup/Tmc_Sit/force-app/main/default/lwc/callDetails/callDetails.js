/* eslint-disable no-console */
import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import {
    retrieveObjectArrayFromCache
} from "c/cacheServiceLayerCMP";
import errMessage from "@salesforce/label/c.CallDetails";
import psfComplaint from "@salesforce/label/c.PSF_Complaints";
import UI_Error_Message from "@salesforce/label/c.UI_Error_Message";
import saveTaskData from "@salesforce/apex/CallDetailsController.saveTaskData";
import psfComplaintsCallOut from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import fetchTaskDetails from '@salesforce/apex/CallDetailsController.fetchTaskDetails';
import successMssg from "@salesforce/label/c.Disposition_Updated";
import smrFollowUpReq from "@salesforce/label/c.SMR_Follow_Up_Date_Req";
import generalFollowUpReq from "@salesforce/label/c.General_Follow_Up_Date";
import psfFollowUpReq from "@salesforce/label/c.PSF_Followup_Req";
import psfNumb from "@salesforce/label/c.Complaint_No_Issue";
import salesPsfFollowUp from "@salesforce/label/c.Sales_PSF_Call_Back";
import lostCaseButton from "@salesforce/label/c.Lost_Case_Feedback";
import smrServiceRec from "@salesforce/label/c.SMR_Service";
import mobileTaskTab from "@salesforce/label/c.Tab_Name";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from "lightning/navigation";
import pubsub from 'c/pubsub';
import {
    CurrentPageReference
} from 'lightning/navigation';
export default class CallDetails extends NavigationMixin(LightningElement) {
    activityId;
    dealerId;
    dialingRecordId;
    accountCustomerId;
    caseRecordId;
    errorMessage;
    apiResponseMessage;
    showCallDetails = false;
    successInfo = false;
    successMessage = null;
    cmpNotAvailable;
    taskRec;
    vehicleName;
    dueDate;
    serviceType;
    campaign;
    dncNumbers;
    buttonName = 'Update';
    vehilceId;
    callingNumber = [];
    smrFollowUpReq = [];
    psfFollowUpReq = [];
    salesPsfFollowUp = [];
    generalFollowUpReq = [];
    dispositionOptions = [];
    feedbackOptions = [];
    ratingOptions = [];
    primaryNumber;
    secondaryNumber;
    thirdNumber;
    fourthNumber;
    recordTypeName = false;
    accountObject = true;
    insuranceFollwUpDate = [];
    recordTypeDeveloperName;
    successUpdateDispositions = false;
    insuranceCaseUser = false;
    insuranceSuccess = false;
    lostCaseFeedbackValues = [];
    minimizeMaximizeCmp = true;
    collapseExpand = 'Expand';
    showDissatisfiedReason = true;
    showFollowUpDateCallBackNumber = false;
    appointmentCreated;
    smrServiceRecord=[];
    smrAppointmentRecordType=false;
    @track inputData = {
        Customer_Mobile__c: "",
        Disposition__c: "",
        Call_Notes__c: "",
        Call_back_Date_Time__c: "",
        Call_back_Phone_Number__c: "",
        Feedback_Outcome__c: "",
        Rating__c: "",
        Mobile_Number_2__c: "",
        Mobile_Number_3__c: "",
        Mobile_Number_4__c: "",
        Id: "",
        Complaint_No__c: "",
        Dialling_Record_ID__c: "",
        Call_End__c: '',
        Status: 'Completed',
        IsReminderSet: false,
        ReminderDateTime: "",
        Case__c: "",
        RecordTypeId: "",
        Rate_Customer__c: ""  // Added for Customer rating as part of Dealer Inbound development
    };
    /**** Added Customer rating as part of Dealer Inbound development ****/
    customerRatingValue = [''];
    get customerRatingOptions() {
        return [
            { label: 'Hot Lead', value: 'Customer Rating' }
        ];
    }
    /**********************************************************************/
    psfComp = {
        "dealerSFId": "",
        "dialingRecordId": "",
        "complaintMode": psfComplaint,
        "complaintDesc": ""
    }

    @track loading = false;
    @api recordId;
    @wire(CurrentPageReference) pageRef;

    get loaded() {
        return !this.errorMessage && !this.loading;
    }

    connectedCallback() {
        let response = retrieveObjectArrayFromCache();
        this.loading = true;
        console.log(response);
        if (response && response.Id) {
            this.activityId = response.Id;

            /**** Added Customer rating as part of Dealer Inbound development ****/
            if (response.Rate_Customer__c) {
                this.customerRatingValue = [response.Rate_Customer__c ? 'Customer Rating' : ''];
                this.inputData.Rate_Customer__c=response.Rate_Customer__c;
            }
            if(response.RecordType.DeveloperName === "SMR_Appointment"){
                console.log('inside test');
                this.smrAppointmentRecordType=true;
                console.log(this.smrAppointmentRecordType);
            }
            /*********************************************************************/
           
            if (response.Case__c) {
                this.dealerId = response.Case__r.Dealer_Name__c ? response.Case__r.Dealer_Name__c : '';
                this.caseRecordId = response.Case__c;
                this.inputData.Case__c = response.Case__c;
            }
            if (response.RecordType) {
                this.recordTypeDeveloperName = response.RecordType.DeveloperName ? response.RecordType.DeveloperName : '';
                this.inputData.RecordTypeId = response.RecordTypeId;
            }
            if (response.Asset__c) {
                this.vehicleName = response.Asset__r.Name ? response.Asset__r.Name : '';
                this.vehilceId = response.Asset__c ? response.Asset__c : '';
            }
            if (response.CampaignId__c) {
                this.campaign = response.CampaignId__r.Name ? response.CampaignId__r.Name : '';
            }
            if (this.recordTypeDeveloperName === 'SMR_Appointment') {
                pubsub.register('appointmentBooked', this.appChange.bind(this));
            }

            this.dialingRecordId = response.Dialling_Record_ID__c ? response.Dialling_Record_ID__c : '';
            this.inputData.Dialling_Record_ID__c = response.Dialling_Record_ID__c ? response.Dialling_Record_ID__c : '';
            this.dueDate = response.ActivityDate ? response.ActivityDate : '';
            this.serviceType = response.Service_Type__c ? response.Service_Type__c : '';
            this.dncNumbers = response.Do_Not_Call_Numbers__c ? response.Do_Not_Call_Numbers__c : '';
            this.accountCustomerId = response.Contact_ID__c ? response.Contact_ID__c : '';

            if (this.activityId && this.recordId.startsWith('001') && this.accountCustomerId && this.recordId !== this.accountCustomerId) {
                this.loading = false;
                this.cmpNotAvailable = errMessage;
            } else if (this.activityId && this.recordId.startsWith('500') && this.caseRecordId && this.recordId !== this.caseRecordId) {
                this.loading = false;
                this.cmpNotAvailable = errMessage;
            } else {
                this.loading = false;
                fetchTaskDetails({
                    recordId: this.recordId,
                    recordTypeName: this.recordTypeDeveloperName,
                    campaignType: this.serviceType
                }).then(result => {
                    console.log('Inside fetchTaskDetails');
                    this.showCallDetails = true;
                    if (this.recordTypeDeveloperName === "PSF_Follow_Up") {
                        this.recordTypeName = true;
                    }
                    if (!response.Customer_Mobile__c && !response.Mobile_Number_2__c && !response.Mobile_Number_3__c && !response.Mobile_Number_4__c) {
                        this.showCallDetails = false;
                        this.errorMessage = 'Phone Number is not present in Task for calling';
                    } else {
                        if (result.objectName === "Case") {
                            this.accountObject = false;
                        }

                        // fetch today's date and format in YYYY-MM-DD 
                        let today = new Date(); // Today's Date
                        var dd = today.getDate();
                        var mm = today.getMonth() + 1;
                        var yyyy = today.getFullYear();
                        if (dd < 10) {
                            dd = '0' + dd;
                        }
                        if (mm < 10) {
                            mm = '0' + mm;
                        }
                        today = yyyy + '-' + mm + '-' + dd;

                        if (result.callDispoitions) {
                            let dispObj = result.callDispoitions;
                            for (let i = 0; i < dispObj.length; i++) {
                                this.dispositionOptions.push({
                                    label: dispObj[i].Call_Details_Label__c,
                                    value: dispObj[i].Call_Details_Value__c
                                });
                                if (dispObj[i].Follow_up_Date_Required__c === true) {
                                    this.insuranceFollwUpDate.push(dispObj[i].Call_Details_Value__c);
                                }
                                if (dispObj[i].Lost_Case_Feedback__c === true) {
                                    this.lostCaseFeedbackValues.push(dispObj[i].Call_Details_Value__c)
                                }

                            }
                        }
                        // Follow Up Date
                        if (response.Call_back_Date_Time__c) {
                            var followUpDate = [];
                            this.followUpDate = (response.Call_back_Date_Time__c).split("T");
                        }

                        if (response.Customer_Mobile__c) {
                            this.primaryNumber = response.Customer_Mobile__c;
                            this.inputData.Customer_Mobile__c = response.Customer_Mobile__c;
                            this.callingNumber.push({
                                label: response.Customer_Mobile__c+' (F)',
                                value: response.Customer_Mobile__c
                            });
                        }

                        this.smrFollowUpReq = smrFollowUpReq.split(';');
                        this.psfFollowUpReq = psfFollowUpReq.split(';');
                        this.salesPsfFollowUp = salesPsfFollowUp.split(';');
                        this.generalFollowUpReq = generalFollowUpReq.split(';');
                        this.smrServiceRecord=  smrServiceRec.split(';');

                        // Follow for same date for SMR & Appointment Reminder Campaigns
                        if (response.Call_back_Date_Time__c && this.smrFollowUpReq.includes(response.Disposition__c) &&
                            response.Call_back_Phone_Number__c && today && this.followUpDate[0] && today === this.followUpDate[0] &&
                            this.recordTypeDeveloperName === "SMR_Appointment") {
                            this.inputData.Customer_Mobile__c = response.Call_back_Phone_Number__c;
                            this.callingNumber.push({
                                label: response.Call_back_Phone_Number__c,
                                value: response.Call_back_Phone_Number__c
                            });
                        }

                        // Follow for same date for Service PSF Campaigns
                        if (response.Call_back_Date_Time__c && this.psfFollowUpReq.includes(response.Disposition__c) &&
                            response.Call_back_Phone_Number__c && today && this.followUpDate[0] && today === this.followUpDate[0] &&
                            this.recordTypeDeveloperName === "PSF_Follow_Up") {
                                console.log('Inside if Psf');
                            this.inputData.Customer_Mobile__c = response.Call_back_Phone_Number__c;
                            this.callingNumber.push({
                                label: response.Call_back_Phone_Number__c,
                                value: response.Call_back_Phone_Number__c
                            });
                        }

                        // Follow for same date for MI Renewal Campaigns
                        if (response.Call_back_Date_Time__c && this.insuranceFollwUpDate.includes(response.Disposition__c) &&
                            response.Call_back_Phone_Number__c && today && this.followUpDate[0] && this.recordTypeDeveloperName === 'MI_Renewal_Call') {
                                console.log('Inside if Mi');
                                this.inputData.Customer_Mobile__c = response.Call_back_Phone_Number__c;
                            this.callingNumber.push({
                                label: response.Call_back_Phone_Number__c,
                                value: response.Call_back_Phone_Number__c
                            });
                        }

                        // Follow for same date for Sales PSF Campaigns
                        if (response.Call_back_Date_Time__c && this.salesPsfFollowUp.includes(response.Disposition__c) &&
                            response.Call_back_Phone_Number__c && today && this.followUpDate[0] && today === this.followUpDate[0] &&
                            this.recordTypeDeveloperName === "Sales_PSF_Follow_Up") {
                                console.log('hi Inside Sales');
                            this.inputData.Customer_Mobile__c = response.Call_back_Phone_Number__c;
                            this.callingNumber.push({
                                label: response.Call_back_Phone_Number__c,
                                value: response.Call_back_Phone_Number__c
                            });
                        }

                        // Follow for same date for General/Adhoc Campaigns
                        if (response.Call_back_Date_Time__c && this.generalFollowUpReq.includes(response.Disposition__c) &&
                            response.Call_back_Phone_Number__c && today && this.followUpDate[0] && today === this.followUpDate[0] &&
                            this.recordTypeDeveloperName === "General_Task") {
                                console.log('Inside if General');
                            this.inputData.Customer_Mobile__c = response.Call_back_Phone_Number__c;
                            this.callingNumber.push({
                                label: response.Call_back_Phone_Number__c,
                                value: response.Call_back_Phone_Number__c
                            });
                        }

                        if (response.Mobile_Number_2__c) {
                            this.secondaryNumber = response.Mobile_Number_2__c;
                            this.inputData.Mobile_Number_2__c = response.Mobile_Number_2__c;
                            this.callingNumber.push({
                                label: response.Mobile_Number_2__c+' (R)',
                                value: response.Mobile_Number_2__c
                            });
                        }
                        if (response.Mobile_Number_3__c) {
                            this.thirdNumber = response.Mobile_Number_3__c;
                            this.inputData.Mobile_Number_3__c = response.Mobile_Number_3__c;
                            this.callingNumber.push({
                                label: response.Mobile_Number_3__c,
                                value: response.Mobile_Number_3__c
                            });
                        }
                        if (response.Mobile_Number_4__c) {
                            this.fourthNumber = response.Mobile_Number_4__c;
                            this.inputData.Mobile_Number_4__c = response.Mobile_Number_4__c;
                            this.callingNumber.push({
                                label: response.Mobile_Number_4__c,
                                value: response.Mobile_Number_4__c
                            });
                        }
                        if (result.taskFeedbackOutcome) {
                            var contsTask = result.taskFeedbackOutcome;
                            this.feedbackOptions = [{
                                value: "",
                                label: "--None--"
                            }];
                            for (var key in contsTask) {
                                this.feedbackOptions.push({
                                    value: contsTask[key],
                                    label: key
                                }); //Here we are creating the array to show on UI.
                            }
                        }
                        if (result.taskRating) {
                            var contsTask1 = result.taskRating;
                            this.ratingOptions = [{
                                value: "",
                                label: "--None--"
                            }];
                            for (var key in contsTask1) {
                                this.ratingOptions.push({
                                    value: contsTask1[key],
                                    label: key
                                }); //Here we are creating the array to show on UI.
                            }
                        }

                    }
                }).catch(error => {
                    this.showCallDetails = false;
                    this.errorMessage = UI_Error_Message;
                })
            }
        } else {
            this.loading = false;
            this.cmpNotAvailable = errMessage;
        }
    }

    // When the Appointment is created/confirmed this will be used in SMR to prepopulate Dispostion
    appChange(val) {
        if (val) {
            this.appointmentCreated = val;
            this.inputData.Disposition__c = "CNF";
        }
    }

    handleValueChange(event) {
        
        this.inputData[event.target.name] = event.target.value;
        if(event.target.name==='Rate_Customer__c' && event.detail.value[0]==='Customer Rating'){
            this.inputData.Rate_Customer__c=true;
        }
        if(event.target.name==='Rate_Customer__c' && event.detail.value[0]!=='Customer Rating'){
            this.inputData.Rate_Customer__c=false;
        }
        if (this.inputData.Rating__c === "Poor" && event.target.name === "Rating__c" && this.recordTypeDeveloperName === "PSF_Follow_Up") {
            this.inputData.Disposition__c = 'D';
        }
        if (this.inputData.Rating__c === "Average" && event.target.name === "Rating__c" && this.recordTypeDeveloperName === "PSF_Follow_Up") {
            this.inputData.Disposition__c = 'D';
        }
        if (event.target.name === "Rating__c" && this.inputData.Rating__c && this.inputData.Rating__c !== "Poor" && this.inputData.Rating__c !== "Average" && this.recordTypeDeveloperName === "PSF_Follow_Up") {
            this.inputData.Disposition__c = "S";
            this.inputData.Feedback_Outcome__c = "";
        }
        if (event.target.name === "Disposition__c" && this.recordTypeDeveloperName === "PSF_Follow_Up" && this.inputData.Disposition__c !== 'D' && this.inputData.Disposition__c !== 'S') {
            this.inputData.Rating__c = "";
            this.inputData.Feedback_Outcome__c = "";
        }
        if (this.recordTypeDeveloperName === "PSF_Follow_Up" && this.inputData.Disposition__c === 'S') {
            this.inputData.Feedback_Outcome__c = "";
        }
        if (this.primaryNumber && this.inputData.Customer_Mobile__c === this.primaryNumber) {
            this.inputData.Customer_Mobile__c = this.primaryNumber;
            this.inputData.Mobile_Number_2__c = this.secondaryNumber;
            this.inputData.Mobile_Number_3__c = this.thirdNumber;
            this.inputData.Mobile_Number_4__c = this.fourthNumber;
        }
        if (this.secondaryNumber && this.inputData.Customer_Mobile__c === this.secondaryNumber) {
            this.inputData.Customer_Mobile__c = this.secondaryNumber;
            this.inputData.Mobile_Number_2__c = this.primaryNumber;
            this.inputData.Mobile_Number_3__c = this.thirdNumber;
            this.inputData.Mobile_Number_4__c = this.fourthNumber;
        }
        if (this.thirdNumber && this.inputData.Customer_Mobile__c === this.thirdNumber) {
            this.inputData.Customer_Mobile__c = this.thirdNumber;
            this.inputData.Mobile_Number_2__c = this.secondaryNumber;
            this.inputData.Mobile_Number_3__c = this.primaryNumber;
            this.inputData.Mobile_Number_4__c = this.fourthNumber;
        }
        if (this.fourthNumber && this.inputData.Customer_Mobile__c === this.fourthNumber) {
            this.inputData.Customer_Mobile__c = this.fourthNumber;
            this.inputData.Mobile_Number_2__c = this.secondaryNumber;
            this.inputData.Mobile_Number_3__c = this.thirdNumber;
            this.inputData.Mobile_Number_4__c = this.primaryNumber;
        }
        if (this.smrFollowUpReq.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "SMR_Appointment" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = this.inputData.Customer_Mobile__c;
        }
        if (!this.smrFollowUpReq.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "SMR_Appointment" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = null;
        }
        if (this.generalFollowUpReq.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "General_Task" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = this.inputData.Customer_Mobile__c;
        }
        if (!this.generalFollowUpReq.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "General_Task" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = null;
        }
        if (this.psfFollowUpReq.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "PSF_Follow_Up" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = this.inputData.Customer_Mobile__c;
        }
        if (!this.psfFollowUpReq.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "PSF_Follow_Up" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = null;
        }
        if (this.salesPsfFollowUp.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "Sales_PSF_Follow_Up" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = this.inputData.Customer_Mobile__c;
        }
        if (!this.salesPsfFollowUp.includes(this.inputData.Disposition__c) && this.recordTypeDeveloperName === "Sales_PSF_Follow_Up" && (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = null;
        }
        if (this.recordTypeDeveloperName === 'MI_Renewal_Call' && this.insuranceFollwUpDate.includes(this.inputData.Disposition__c) &&
            (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = this.inputData.Customer_Mobile__c;
        }
        if (this.recordTypeDeveloperName === 'MI_Renewal_Call' && !this.insuranceFollwUpDate.includes(this.inputData.Disposition__c) &&
            (event.target.name === "Customer_Mobile__c" || event.target.name === "Disposition__c")) {
            this.inputData.Call_back_Phone_Number__c = null;
        }
        if (this.inputData.Disposition__c === 'D') {
            this.showDissatisfiedReason = false;
        } else {
            this.inputData.Feedback_Outcome__c = '';
            this.showDissatisfiedReason = true;
        }
        if (this.inputData.Disposition__c === 'D' || this.inputData.Disposition__c === 'S') {
            this.inputData.Call_back_Phone_Number__c = '';
            this.inputData.Call_back_Date_Time__c = '';
            this.showFollowUpDateCallBackNumber = true;
        } else {
            this.showFollowUpDateCallBackNumber = false;
        }

        this.buttonName = this.recordTypeDeveloperName === 'MI_Renewal_Call' && this.lostCaseFeedbackValues.includes(this.inputData.Disposition__c) ? lostCaseButton : 'Update';
    }

    // This method is created to restrict Paste
    handlePaste(event) {
        event.preventDefault();
    }

    //This method is used to accept only Numerical value
    restrictAlphabets(event) {
        var x = event.which || event.keycode;
        if ((x >= 48 && x <= 57))
            return true;
        else {
            event.preventDefault();
            return false;
        }

    }

    handleUpdate() {
        var dt = new Date();
        if (this.validateInputs()) {
            if (this.recordTypeDeveloperName === 'MI_Renewal_Call' && !this.inputData.Call_back_Date_Time__c &&
                this.insuranceFollwUpDate.includes(this.inputData.Disposition__c)) {
                this.showErrorMessage('Follow Up Date is missing');
            } else if (this.recordTypeDeveloperName === 'MI_Renewal_Call' && !this.inputData.Call_back_Phone_Number__c &&
                this.insuranceFollwUpDate.includes(this.inputData.Disposition__c)) {
                this.showErrorMessage('Call Back Number is missing');
            } else if ((this.smrFollowUpReq.includes(this.inputData.Disposition__c) || 
						this.psfFollowUpReq.includes(this.inputData.Disposition__c) ||
						this.salesPsfFollowUp.includes(this.inputData.Disposition__c) || 
						this.generalFollowUpReq.includes(this.inputData.Disposition__c)) && 
						!this.inputData.Call_back_Date_Time__c &&  
						this.inputData.Disposition__c !== 'WN' &&  
						this.recordTypeDeveloperName !== 'MI_Renewal_Call') {
                this.showErrorMessage('Follow Up Date is missing');
            } else if ((this.smrFollowUpReq.includes(this.inputData.Disposition__c) || this.psfFollowUpReq.includes(this.inputData.Disposition__c) ||
                    this.salesPsfFollowUp.includes(this.inputData.Disposition__c) || this.generalFollowUpReq.includes(this.inputData.Disposition__c)) && !this.inputData.Call_back_Phone_Number__c && this.recordTypeDeveloperName !== 'MI_Renewal_Call') {
                this.showErrorMessage('Call Back Number is missing');
            } else if (this.inputData.Disposition__c === "D" && !this.inputData.Call_Notes__c && (this.recordTypeDeveloperName === "PSF_Follow_Up" || this.recordTypeDeveloperName === 'Sales_PSF_Follow_Up')) {
                this.showErrorMessage('Customer Voice is missing');
            } else if (this.inputData.Disposition__c === "D" && !this.inputData.Feedback_Outcome__c && this.recordTypeDeveloperName === "PSF_Follow_Up") {
                this.showErrorMessage('Dissatisfied Reason is missing');
            } else if ((this.inputData.Disposition__c === "D" || this.inputData.Disposition__c === "S" )&& !this.inputData.Rating__c && this.recordTypeDeveloperName === "PSF_Follow_Up") {
                this.showErrorMessage('Rating is Missing'); /*newly added as part of SCR */           
			} else if (this.inputData.Call_back_Phone_Number__c && (this.inputData.Call_back_Phone_Number__c).length !== 10 && (this.inputData.Call_back_Phone_Number__c).length !== 11 && (this.inputData.Call_back_Phone_Number__c).length !== 12) {
                this.showErrorMessage('Call Back Number can only be 10 or 11 or 12 digits');
            } else if (this.inputData.Call_back_Date_Time__c && this.inputData.Call_back_Date_Time__c <= dt.toISOString()) {
                this.showErrorMessage('Past Follow Up Date cannot be selected');
            } else if (!this.appointmentCreated && this.recordTypeDeveloperName === 'SMR_Appointment' && this.inputData.Disposition__c === 'CNF' && this.smrServiceRecord.includes(this.serviceType)) {
                this.showErrorMessage('Response/Dispostion cannot be Confirmed if Appointment is not booked');
            } else {
                this.loading = true;
                this.showCallDetails = false;
                this.inputData.Id = this.activityId;

                // When Task is for PSF and Customer is Dissatisfied then PSF Complaint need to be registered
                if (this.recordTypeDeveloperName === 'PSF_Follow_Up' && this.serverDataPrepare() && this.inputData.Disposition__c === "D") {
                    this.psfComp.dealerSFId = this.dealerId;
                    this.psfComp.complaintDesc = this.inputData.Call_Notes__c;
                    this.psfComp.dialingRecordId = this.dialingRecordId;
                    this.psfComplaints(this.psfComp);
                } else if (this.serverDataPrepare()) {

                    //This Conditon is applicable when its is MI Renewal Recordtype and Disposition is getting update for Lost scenarios
                    if (this.recordTypeDeveloperName === 'MI_Renewal_Call' && this.lostCaseFeedbackValues.includes(this.inputData.Disposition__c)) {
                        this.successUpdateDispositions = true;
                        this.showCallDetails = true;
                        this.insuranceCaseUser = true;
                        this.insuranceSuccess = true;
                        this.loading = false;
                        this.GiveInformation('Please enter Lost Case Feedback');
                    } else {
                        this.saveDispositioins(this.inputData); //server Method to save data
                    }

                } else {
                    this.showErrorMessage("Please try after sometime");
                }


            }

        } else {
            this.showErrorMessage("Required field is Missing");
        }
    }

    serverDataPrepare() {
        console.log('Inside serverDataPrepare');
        // fetch today's date and format in YYYY-MM-DD 
        try {
            let today = new Date(); // Today's Date
            var dd = today.getDate();
            var mm = today.getMonth() + 1;
            var yyyy = today.getFullYear();
            if (dd < 10) {
                dd = '0' + dd;
            }
            if (mm < 10) {
                mm = '0' + mm;
            }
            today = yyyy + '-' + mm + '-' + dd;

            if (this.inputData.Call_back_Date_Time__c) {
                //var callBackDate = [];
                this.callBackDate = (this.inputData.Call_back_Date_Time__c).split("T");
                this.inputData.Status = this.callBackDate[0] && today && this.callBackDate[0] === today ? 'Open' : 'Completed';
                this.inputData.IsReminderSet = this.callBackDate[0] && today && this.callBackDate[0] === today ? true : false;
                this.inputData.ReminderDateTime = this.callBackDate[0] && today && this.callBackDate[0] === today ? this.inputData.Call_back_Date_Time__c : '';
            }
            var dtTime = new Date();
            this.inputData.Call_End__c = dtTime;
            return true;
        } catch (error) {
            this.handleError(error);
            return false;
        }
    }

    get today() {
        return new Date();
    }
    get tomorrow() {
        return this.getNextDay(this.today);
    }
    get minAppointmentDate() {

        return this.toMinDatetimeString(this.tomorrow);
    }

    get currentDate() {
        return this.toMinDatetimeString(this.today);
    }

    saveDispositioins(response) {
        console.log('Inside saveDispositioins');
        saveTaskData({
                taskJSON: JSON.stringify(response),
                caseRecId: this.recordId,
                taskRecordTypeName: this.recordTypeDeveloperName
            })
            .then(this.handleServerResponse)
            .catch(error => this.handleServerError(error))

    }

    getNextDay(dt) {
        dt = new Date(dt);
        dt.setDate(dt.getDate());
        return dt;
    }

    toMinDatetimeString(dt) {
        dt = new Date(dt);
        dt.setMinutes(dt.getMinutes() + 2);
        return dt.toISOString();
    }

    toDatetimeString(dt) {
        return new Date(dt).toISOString();
    }

    handleServerResponse = data => {
        this.loading = false;
        console.log(this.inputData);
        if (data === 'SUCCESS') {
            console.log('handleServerResponse');
            localStorage.clear();
            var complaintNumber = this.inputData.Complaint_No__c ? this.inputData.Complaint_No__c : 'not received. Please contact Support team.';
            var psfComp = this.recordTypeDeveloperName === 'PSF_Follow_Up' && this.inputData.Disposition__c === 'D' ? '& PSF Complaint No is ' + ' ' + complaintNumber : '';
            this.showSuccessMessage(successMssg + ' ' + psfComp);
            this.successInfo = true;
            this.successMessage = successMssg + ' ' + psfComp;

            if (this.recordTypeDeveloperName === 'MI_Renewal_Call' && !this.insuranceCaseUser && !this.accountObject) {
                this.closeModal();
            } else if (this.recordTypeDeveloperName === 'SMR_Appointment' || (this.recordTypeDeveloperName === 'PSF_Follow_Up' && this.inputData.Disposition__c !== 'D')) {
                if(FORM_FACTOR==='Small'){
                    this.redirecttoTab(mobileTaskTab);
                }
                else{
                    this.redirectObjectHomePage('Task');
                }
                
            }
        } else {
            //this.errorMessage = UI_Error_Message;
            this.showCallDetails = true;
            this.showErrorMessage(UI_Error_Message);
        }


    }

    expandCollapse() {
        if (this.collapseExpand === 'Expand') {
            this.collapseExpand = 'Collapse';
            this.minimizeMaximizeCmp = false;
        } else {
            this.collapseExpand = 'Expand';
            this.minimizeMaximizeCmp = true;
        }
    }

    closeModal() {
        //fire the custom event to be handled by parent aura component
        this.dispatchEvent(new CustomEvent("finish"));
    }

    handleServerError(error) {
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: error.message,
                variant: "error"
            })
        );
    }

    //method to show success toast message
    showSuccessMessage(message) {
        this.showMessage("Success", message, "success");
    }
    //method to show error toast message
    showErrorMessage(error) {
        this.showMessage("Something is wrong", error, "error");
    }
    showMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    //to handle the data validation
    validateInputs() {
        let inps = [].concat(
            this.template.querySelector(".inputCmp"),
            //this.template.querySelector(".inputText")
        );
        return inps.filter(inp => !inp.reportValidity()).length === 0;
    }

    psfComplaints(apiReqData) {
        console.log('apiReqData-------->', apiReqData);
        let params = {
            jitName: "PSF_Complaints",
            jsonBody: JSON.stringify(apiReqData),
            urlParam: ""
        };
        // make JIT call
        psfComplaintsCallOut(params)
            .then(response => this.handleUpdateResponse(response))
            .catch(error => this.handleAPIerror(error));

    }

    handleAPIerror(error) {
        this.showCallDetails = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: error.message,
                variant: "error"
            })
        );
        this.loading = false;
    }


    handleUpdateResponse(response) {
        console.log('response----------->', response);
        if (response.status === "Success" && response.data) {
            this.apiResponseMessage = JSON.parse(response.data).message;
            this.inputData.Complaint_No__c = JSON.parse(response.data).complaintNumber;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Something is wrong",
                    message: response.message,
                    variant: "error"
                })
            );
            this.loading = false;
            //this.handleAPIerror(response);
        }
        this.saveDispositioins(this.inputData);
    }

    handleError(error) {
        this.errorMessage = error.message;
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: this.errorMessage,
                variant: "error"
            })
        );
        this.loading = false;
    }

    GiveInformation(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Attention Please!!",
                message: error,
                variant: "info"
            })
        );
        this.loading = false;
    }

    accountDetailPage(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Account", // objectApiName is optional
                actionName: "view"
            }
        });
    }
    redirectObjectHomePage(objectName) {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {

                objectApiName: objectName, // objectApiName is optional
                actionName: "home"
            }
        });
    }
    redirecttoTab(tabName) {
        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: tabName,
            }
        });
    }
}