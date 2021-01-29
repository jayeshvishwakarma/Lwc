import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';

import shareCustomerRecord from '@salesforce/apex/CustomAccountSearchCtrl.shareCustomerRecord';
import SERVER_ERROR from '@salesforce/label/c.UI_Error_Message';

const STATUS_OTP_REQUIRED = "otp_required";
const STATUS_OTP_VERIFIED = "otp_verified";
const STATUS_RECORD_SHARED = "record_shared";

export default class CustomAccountShare extends NavigationMixin(LightningElement) {
    @api recordId;
    @api mobile;
    @track status = STATUS_OTP_REQUIRED;
    @track errorMessage;
    
    //****************Change added for Dealer Inbound calling****************//
    @api servicemobile;
    @api loggedinprofile;
    @api buttonsource;
    //****************Change added for Dealer Inbound calling****************//

    get isOTPRequired() {
        return this.status === STATUS_OTP_REQUIRED;
    }
    get isOTPVerified() {
        return this.status === STATUS_OTP_VERIFIED;
    }
    get isRecordShared() {
        return this.status === STATUS_RECORD_SHARED;
    }

    handleVerifyOTPSuccess(event) {
        this.status = STATUS_OTP_VERIFIED;
        this.executeAction(shareCustomerRecord, {
            recordId: this.recordId,
            otp: event.detail
        }).then(() => {
            this.status = STATUS_RECORD_SHARED;
        });
    }
    handleViewAcocunt() {
        this.navidateToRecord(this.recordId);
    }
    navidateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view',
            }
        });
    }
    executeAction(action, params) {
        return action(params).catch(this.handleError.bind(this));
    }
    handleError(error) {
        this.errorMessage = SERVER_ERROR;
        // eslint-disable-next-line no-console
        console.error(error);
    }
}