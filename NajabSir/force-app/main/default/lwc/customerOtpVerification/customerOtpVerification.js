import { LightningElement, track, api } from 'lwc';
import sendOTP from '@salesforce/apex/CustomAccountSearchCtrl.sendOTP';
import verifyOTP from '@salesforce/apex/CustomAccountSearchCtrl.verifyOTP';
import SERVER_ERROR from '@salesforce/label/c.UI_Error_Message';

export default class CustomerOtpVerification extends LightningElement {
    @api recordId;
    @api mobile;
    @track isOTPSent = false;
    @track isLoading = false;
    @track errorMessage = "";
    isOTPVerified = false;

    connectedCallback() {
        this.sendOTP();
    }
    sendOTP() {
        this.executeAction(sendOTP, {
            recordId: this.recordId
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