import {
    LightningElement,
    api,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    getRecord
} from 'lightning/uiRecordApi';
import Asset_VIN_Number from "@salesforce/schema/Asset.VIN__c";
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';
import VIN_Missing from '@salesforce/label/c.VIN_Missing';
import getAssetDetails from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";


export default class SuzukiConnectAssetDetailsLWC extends NavigationMixin(LightningElement) {
    showSpinner = false;
    cmpVisibe = false;
    createCmp = false;
    @api recordId;
    vinNumber;
    apiRespone;
    errorMessage;

    //Method to pull VIN Number from Asset and do API callout to fetch TCU Details
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [Asset_VIN_Number]
    })
    assetData({
        error,
        data
    }) {
        if (data) {
            this.showSpinner = true;
            this.vinNumber = data.fields.VIN__c.value ? data.fields.VIN__c.value : '';
            if (this.vinNumber) {
                this.getTCUdetails();
            } else {
                this.errorMessage = VIN_Missing;
                this.handleMessage('Something is wrong', VIN_Missing, 'error');
                this.cancel();
            }
        } else if (error) {
            console.log('error-------->', error);
            this.errorMessage = error.message + '. ' + UI_Error_Message;
            this.handleMessage('Something is wrong', error.message + '. ' + UI_Error_Message, 'error');
        }
    }

    //HandleCaseClose
    handleClosure(event) {
        console.log('event.detail------->? ', event.detail.caseId);

        if (event.detail.caseId) {
            this.cmpVisibe=true;
            this.createCmp=false;
        }


    }

    //Handle Success & Error Messages
    handleMessage(title, message, response) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: response
            })
        );
    }

    //API callout to fetch TCU Details
    getTCUdetails() {
        let params = {
            jitName: "Suzuki_Connect_Asset_Details",
            jsonBody: " ",
            urlParam: JSON.stringify({
                vin: this.vinNumber
            })
        };
        getAssetDetails(params)
            .then(result => {
                console.log('API Response---------->', result);
                if (result.code === 200) {
                    let jsonResponse = JSON.parse(result.data);
                    this.apiRespone = jsonResponse.tcuDetails;
                    this.cmpVisibe = true;
                    this.showSpinner = false;
                    this.handleMessage('Success', 'Data has been retrieved successfully', 'success');
                } else {
                    this.showSpinner = false;
                    this.errorMessage = UI_Error_Message;
                    this.handleMessage('Something is wrong', UI_Error_Message, 'error');
                }

            }).catch(error => {
                console.log('error---------->', error);
                this.showSpinner = false;
                this.errorMessage = error.message + '. ' + UI_Error_Message;
                this.handleMessage('Something is wrong', error.message + '. ' + UI_Error_Message, 'error');
            })
    }

    // This method is used to close the LWC and navigate to record page
    cancel() {
        this.showSpinner = true;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Asset", // objectApiName is optional
                actionName: "view"
            }
        });
        this.showSpinner = false;
    }

    createCase() {
        this.cmpVisibe = false;
        this.createCmp = true;
    }
}