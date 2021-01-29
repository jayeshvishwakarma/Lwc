/* eslint-disable no-console */
import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    NavigationMixin
} from "lightning/navigation";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    retrieveObjectArrayFromCache
} from "c/cacheServiceLayerCMP"
import createDNC from "@salesforce/apex/DNCRequestController.createDNCRequest";
import phoneNumberIssue from "@salesforce/label/c.Phone_Number_Length";

/********Custom Labels  *******/
import Do_Not_Call_Request_Success_Message from '@salesforce/label/c.Do_Not_Call_Request_Success_Message';

export default class DncRequest extends NavigationMixin(LightningElement) {
    @api recordId;
    @track mobile;
    @track loadSpinner;
    phoneNumError;
    caseData = {};
    cacheData;
    objName;
    connectedCallback() {
        this.cacheData = retrieveObjectArrayFromCache();
        this.objName = this.recordId.substring(0, 3) === '500' ? 'Case' : 'Account';
        console.log(this.cacheData);
        this.phoneNumError = phoneNumberIssue;
        try {
            if (this.cacheData) {
                if (this.objName === 'Account' && this.cacheData.Contact_ID__c && this.recordId === this.cacheData.Contact_ID__c) {
                    this.mobile = this.cacheData.Customer_Mobile__c;
                    this.caseData.Mobile_Number__c = this.mobile;
                } else if (this.objName === 'Case' && this.cacheData.Case__c && this.recordId === this.cacheData.Case__c) {
                    this.mobile = this.cacheData.Customer_Mobile__c;
                    this.caseData.Mobile_Number__c = this.mobile;
                }

            }
        } catch (err) {
            console.log(err);
        }

    }

    //to handle the data validation
    validateInputs() {
        let inps = [].concat(
            this.template.querySelector(".left-side-style"),
            //this.template.querySelector(".inputText")
        );
        return inps.filter(inp => !inp.reportValidity()).length === 0;
    }


    submitRequest() {
        if (this.validateInputs()) {
            if ((this.caseData.Mobile_Number__c).length === 10 &&
                (
                    (this.caseData.Mobile_Number__c).startsWith("6") ||
                    (this.caseData.Mobile_Number__c).startsWith("7") ||
                    (this.caseData.Mobile_Number__c).startsWith("8") ||
                    (this.caseData.Mobile_Number__c).startsWith("9")
                )
            ) {
                this.loadSpinner = true;

                //this.caseData.Customer__c = this.recordId;
                if (this.objName === 'Account' && this.cacheData && this.cacheData.CampaignId__c && this.cacheData.Contact_ID__c &&
                    this.recordId === this.cacheData.Contact_ID__c) {
                    this.caseData.CampaignId__c = this.cacheData.CampaignId__c;
                } else if (this.objName === 'Case' && this.cacheData && this.cacheData.CampaignId__c && this.cacheData.Case__c &&
                    this.recordId === this.cacheData.Case__c) {
                    this.caseData.CampaignId__c = this.cacheData.CampaignId__c;
                }

                this.caseData.Subject = 'Customer Opted for DNC';
                createDNC({
                        dncData: JSON.stringify(this.caseData),
                        parentRecordId: this.recordId
                    })
                    .then(result => {
                        console.log(result);
                        if (result.code === 200) {
                            this.showMessage('Success', Do_Not_Call_Request_Success_Message, 'Success');
                            this.navigateToObject(this.recordId, this.objName);
                        } else {
                            this.loadSpinner = false;
                            this.showMessage('Error', result.message, 'Error');
                        }
                    })
                    .catch(error => {
                        this.loadSpinner = false;

                        this.showMessage('Error', error, 'Error');
                    });
            } else {
                this.showMessage('Error', this.phoneNumError, 'Error');
            }
        } else {
            this.showMessage('Error', 'Required Field is missing', 'Error');
        }
    }
    handleFieldUpdate(event) {
        console.log('Inside handleFieldUpdate');
        this.caseData[event.target.name] = event.target.value || event.detail.value;
        console.log('(this.caseData.Mobile_Number__c).length---->' + (this.caseData.Mobile_Number__c).length);
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

    // This method is created to restrict Paste
    handlePaste(event) {
        event.preventDefault();
    }

    cancel() {
        console.log('this.recordId=-->' + this.recordId);
        console.log('this.objName=-->' + this.objName);
        this.navigateToObject(this.recordId, this.objName);
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
    navigateToObject(objId, objName) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: objId,
                actionName: "view",
                objectApiName: objName
            }
        });
    }
}