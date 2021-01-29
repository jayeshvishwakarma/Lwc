import {
    LightningElement,
    track,
    api
} from 'lwc';
import sendOTP from '@salesforce/apex/CustomAccountSearchCtrl.sendOTPAccSearch';
import verifyOTP from '@salesforce/apex/CustomAccountSearchCtrl.verifyOTP';
import SERVER_ERROR from '@salesforce/label/c.UI_Error_Message';

//****************Change added for Dealer Inbound calling****************//
import serviceProfile from "@salesforce/label/c.Service_Custom_Account_Search";

export default class CustomerOtpVerification extends LightningElement {
    @api recordId;
    @api mobile;
    @track isOTPSent = false;
    @track isLoading = false;
    @track errorMessage = "";
    isOTPVerified = false;
    //****************Change added for Dealer Inbound calling****************//
    @api servicemobile;
    @api loggedinprofile;
    servicePersona = false;
    @api buttonsource;
    //****************Change added for Dealer Inbound calling****************//

    connectedCallback() {
        let servicemobile;
        servicemobile = serviceProfile.split(';');
        if (this.servicemobile && servicemobile.includes(this.loggedinprofile) && this.buttonsource === "send_otp_service_Mobile") {
            this.servicePersona = true;
        }
        this.sendOTP();
    }
    sendOTP() {
        this.executeAction(sendOTP, {
            recordId: this.recordId,
            isServiceProfile: this.servicePersona
        }).then(() => {
            this.isOTPSent = true;
        });
    }
    handleVerifyOTP() {
        let otpInput = this.template.querySelector("lightning-input");
        otpInput.setCustomValidity("");
        if (otpInput.reportValidity()) {
            this.isLoading = true;
            this.executeAction(verifyOTP, {
                recordId: this.recordId,
                otp: otpInput.value
            }).then(result => {
                this.isOTPVerified = result;
                if (this.isOTPVerified) {
                    this.dispatchEvent(new CustomEvent('success'));
                } else {
                    otpInput.setCustomValidity("Invalid OTP");
                    otpInput.reportValidity();
                }
                this.isLoading = false;
            });
        }
    }
    executeAction(action, params) {
        return action(params).catch(this.handleError);
    }
    handleError = error => {
        this.isLoading = false;
        this.errorMessage = SERVER_ERROR;
        // eslint-disable-next-line no-console
        console.error(error);
    }
}