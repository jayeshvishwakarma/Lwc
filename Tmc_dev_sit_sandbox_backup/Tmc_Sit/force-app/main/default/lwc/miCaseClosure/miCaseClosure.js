import {
    LightningElement,
    api
} from 'lwc';
import policyDeliveryCaseType from "@salesforce/label/c.MI_Policy_Type";
import fetchCaseData from "@salesforce/apex/miCaseClosure.fetchCaseRecord";
import salesSecond from "@salesforce/label/c.MI_Sales_Secondary";
import caseUp from "@salesforce/label/c.MI_Case_Update";
import closedCAse from "@salesforce/label/c.Closed_Case";
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';


export default class MiCaseClosure extends NavigationMixin(LightningElement) {

    @api recordId;
    processNameData = 'Dealer_Internal_Case_Closure';
    hideChannel = false;
    showPolicyDelivery = false;
    showEndorse = false;
    showNCB = false;
    showClaim = false;
    showRenewal = false;
    showRefund = false;
    isSpinnerShow = true;
    showWebsite = false;
    errorMessage;
    caseTypeVal;
    showButton = true;
    miUpdateCmp = true;
    dealerResltion = false;
    caseObject = {
        "Mode_of_Delivery__c": "",
        "Date_of_Delivery__c": "",
        "Tracking_Number__c": "",
        "Courier_Company__c": "",
        "Hand_Delivered__c": "",
        "Customer_Intimated__c": "",
        "Endorsement_Type__c": "",
        "Endorsement_Status__c": "",
        "Documents_Pending__c": "",
        "Endorsement_Date__c": "",
        "Endorsement_Sent__c": "",
        "NCB_Sent_Date__c": "",
        "Claim_Final_Status__c": "",
        "Claim_Not_Honoured_Reason__c": "",
        "Policy_Renewal_Status__c": "",
        "Reason_for_non_renewal__c": "",
        "MI_Renewal_Remarks__c": "",
        "Refund_Date__c": "",
        "Refund_Amount__c": "",
        "Bank_Reference_No__c": "",
        "Id": "",
        "Primary_Category__c": "",
        "Secondary_Category__c": "",
        "Case_Type__c": ""
    }

    connectedCallback() {
        console.log('inside connectedCallback');
        this.isSpinnerShow = true;
        fetchCaseData({
            recordId: this.recordId
        }).then(result => {
            console.log('result----->', result);
            if (result.IsClosed === false) {
                if (result && result.Primary_Category__c && result.Secondary_Category__c) {
                    let checkPrimary = 'POLICY DELIVERY';
                    let primCat = (result.Primary_Category__c).toUpperCase(); //Value in UpperCase
                    let secCat = (result.Secondary_Category__c).toUpperCase(); //Value in UpperCase

                    this.caseTypeVal = policyDeliveryCaseType.split(';'); //Case Type Dealer Internal Request;Dealer Internal Complaint Values

                    this.caseObject = result;

                    let salesSecondaryCategory = salesSecond.split(';');
                    if (checkPrimary === primCat &&
                        ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY COPY NOT RECEIVED') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'DUPLICATE POLICY COPY REQUIRED') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY COPY NOT RECEIVED'))) {
                        this.showPolicyDelivery = true;
                        this.showEndorse = false;
                        this.showNCB = false;
                        this.showClaim = false;
                        this.showRenewal = false;
                        this.showRefund = false;
                        this.showWebsite = false;
                    } else if ((this.caseObject.Primary_Category__c).toUpperCase() === 'SALES RELATED' &&
                        ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'ENDORSEMENT RELATED') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'ENDORSEMENT RELATED') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'NON MI ENDORSEMENT RELATED') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'ENDORSEMENT NOT APPROVED')
                        )) {
                        this.showPolicyDelivery = false;
                        this.showEndorse = true;
                        this.showNCB = false;
                        this.showClaim = false;
                        this.showRenewal = false;
                        this.showRefund = false;
                        this.showWebsite = false;
                    } else if (primCat === 'SALES RELATED' &&
                        ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'NCB CERTIFICATE') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'NCB CERTIFICATE NOT RECEIVED'))) {
                        this.showPolicyDelivery = false;
                        this.showEndorse = false;
                        this.showNCB = true;
                        this.showClaim = false;
                        this.showRenewal = false;
                        this.showRefund = false;
                        this.showWebsite = false;
                    } else if (primCat === 'CLAIM RELATED' && secCat === 'FULL CLAIM NOT GIVEN' && result.Case_Type__c === 'Dealer Internal Complaint') {
                        this.showPolicyDelivery = false;
                        this.showEndorse = false;
                        this.showNCB = false;
                        this.showClaim = true;
                        this.showRenewal = false;
                        this.showRefund = false;
                        this.showWebsite = false;
                    } else if (primCat === 'SALES RELATED' &&
                        ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY RENEWAL') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY RENEWAL'))) {
                        this.showPolicyDelivery = false;
                        this.showEndorse = false;
                        this.showNCB = false;
                        this.showClaim = false;
                        this.showRenewal = true;
                        this.showRefund = false;
                        this.showWebsite = false;
                    } else if (primCat === 'SALES RELATED' &&
                        ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY CANCELLATION RELATED') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'CANCELLATION REFUND'))) {
                        this.showPolicyDelivery = false;
                        this.showEndorse = false;
                        this.showNCB = false;
                        this.showClaim = false;
                        this.showRenewal = false;
                        this.showRefund = true;
                        this.showWebsite = false;
                    } else if (primCat === 'WEBSITE RELATED' &&
                        ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'CANCELLATION REFUND') ||
                            (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'CANCELLATION REFUND'))) {
                        this.showPolicyDelivery = false;
                        this.showEndorse = false;
                        this.showNCB = false;
                        this.showClaim = false;
                        this.showRenewal = false;
                        this.showRefund = false;
                        this.showWebsite = true;
                    } else {
                        this.showButton = false;
                        this.dealerResltion = true;
                        this.isSpinnerShow = false;
                        /*this.showButton = false;
                        this.errorMessage = caseUp;
                        const evt = new ShowToastEvent({
                            title: 'Information',
                            message: caseUp,
                            variant: 'info',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);*/
                    }
                    this.isSpinnerShow = false;
                } else {
                    //this.handleError('Either Primary or Secondary Category data is missing');
                    this.showButton = false;
                    this.dealerResltion = true;
                    this.isSpinnerShow = false;
                }
            } else {
                this.isSpinnerShow = false;
                this.showButton = false;
                this.handleError(closedCAse);
            }
        }).catch(error => {
            console.log(error);
            this.handleError(error.message);
            this.isSpinnerShow = false;
        })
    }

    handleOnChange(event) {
        this.caseObject[event.target.name] = event.detail.value;
    }

    handleSubmitRec(event) {
        try {
            this.isSpinnerShow = true;
            event.preventDefault();
            let fields = event.detail.fields;
            console.log('Before Save--------->', this.caseObject);
            console.log(this.processNameData);
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.errorMessage = '';
            this.handleSuccess();
            this.dealerResltion = true; //To render Case closure
            this.miUpdateCmp = false;
            //this.navigateCmp('Case', this.recordId);
        } catch (error) {
            let msg = "Case could not be Updated, Please review your data once again";
            this.handleError(msg);
        }

    }

    mandatoryCheck(event) {
        try {
            this.errorMessage = '';
            if (this.validateInputs()) {
                if ((this.caseObject.Primary_Category__c).toUpperCase() === 'POLICY DELIVERY' &&
                    ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY COPY NOT RECEIVED') ||
                        (this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'DUPLICATE POLICY COPY REQUIRED') ||
                        (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY COPY NOT RECEIVED')) && this.caseObject.Mode_of_Delivery__c) {
                    if (!this.caseObject.Tracking_Number__c && (this.caseObject.Mode_of_Delivery__c === 'Courier' || this.caseObject.Mode_of_Delivery__c === 'Speed Post')) {
                        this.handleError('Tracking Number is mandatory');
                    } else if (!this.caseObject.Courier_Company__c && this.caseObject.Mode_of_Delivery__c === 'Courier') {
                        this.handleError('Courier Company is mandatory');
                    } else if (this.caseObject.Mode_of_Delivery__c === 'By Hand' && !this.caseObject.Hand_Delivered__c) {
                        this.handleError('Hand Delivered is mandatory');
                    } else {
                        this.isSpinnerShow = true;
                        const submitBtn = this.template.querySelector('.submit-btn');
                        submitBtn.click();
                    }
                } else if ((this.caseObject.Primary_Category__c).toUpperCase() === 'SALES RELATED' &&
                    ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'ENDORSEMENT RELATED') ||
                        (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'ENDORSEMENT RELATED') ||
                        (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'NON MI ENDORSEMENT RELATED') ||
                        (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'ENDORSEMENT NOT APPROVED')
                    )) {
                    if (!this.caseObject.Documents_Pending__c && this.caseObject.Endorsement_Status__c === 'Document Pending from Customer') {
                        this.handleError('Documents Pending is mandatory');
                    } else if (!this.caseObject.Endorsement_Date__c && this.caseObject.Endorsement_Status__c === 'Done') {
                        this.handleError('Ensorsement Date is mandatory');
                    } else if (!this.caseObject.Endorsement_Sent__c && this.caseObject.Endorsement_Status__c === 'Done') {
                        this.handleError('Ensorsement Sent is mandatory');
                    } else {
                        this.isSpinnerShow = true;
                        const submitBtn = this.template.querySelector('.submit-btn');
                        submitBtn.click();
                    }
                } else if (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Primary_Category__c).toUpperCase() === 'CLAIM RELATED' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'FULL CLAIM NOT GIVEN') {
                    if (!this.caseObject.Claim_Not_Honoured_Reason__c && this.caseObject.Claim_Final_Status__c === 'Not Given') {
                        this.handleError('Claim Not Honoured Reason is mandatory');
                    } else {
                        this.isSpinnerShow = true;
                        const submitBtn = this.template.querySelector('.submit-btn');
                        submitBtn.click();
                    }
                } else if ((this.caseObject.Primary_Category__c).toUpperCase() === 'SALES RELATED' &&
                    ((this.caseObject.Case_Type__c === 'Dealer Internal Request' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY RENEWAL') ||
                        (this.caseObject.Case_Type__c === 'Dealer Internal Complaint' && (this.caseObject.Secondary_Category__c).toUpperCase() === 'POLICY RENEWAL'))) {
                    if (this.caseObject.Policy_Renewal_Status__c === 'Not Renewed' && !this.caseObject.Reason_for_non_renewal__c) {
                        this.handleError('Reason for non renewal is mandatory');
                    } else if (this.caseObject.Reason_for_non_renewal__c === 'Others' && !this.caseObject.MI_Renewal_Remarks__c) {
                        this.handleError('MI Renewal Remarks is mandatory');
                    } else {
                        this.isSpinnerShow = true;
                        const submitBtn = this.template.querySelector('.submit-btn');
                        submitBtn.click();
                    }
                } else {
                    this.isSpinnerShow = true;
                    const submitBtn = this.template.querySelector('.submit-btn');
                    submitBtn.click();
                }
            } else {
                this.isSpinnerShow = false;
                this.handleError('Required Fields are missing');
            }

        } catch (e) {
            console.log('error------->', e);
            this.isSpinnerShow = false;
            this.handleError(e.message);
        }
    }

    queryAll(query) {
        return Array.from(this.template.querySelectorAll(query));
    }

    //to handle the data validation
    validateInputs() {
        let inps = [].concat(
            this.queryAll("lightning-input-field"),
        );
        return inps.filter(inp => !inp.reportValidity()).length === 0;
    }

    handleSuccess() {
        const toastEvt = new ShowToastEvent({
            "title": "Success!",
            "message": "Case has been updated successfully.",
            "variant": "success"
        });
        this.dispatchEvent(toastEvt);
        this.isSpinnerShow = false;
        //this.navigateCmp('Case',this.recordId);
    }

    handleError(message) {
        const toastEvt = new ShowToastEvent({
            "title": "Error Occured!",
            "message": message,
            "variant": "error"
        });
        this.dispatchEvent(toastEvt);
        this.isSpinnerShow = false;
        this.errorMessage = message;
    }

    navigateCmp(objectNAme, recId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recId,
                objectApiName: objectNAme, // objectApiName is optional
                actionName: "view"
            }
        });
        this.isSpinnerShow = false;
    }

}