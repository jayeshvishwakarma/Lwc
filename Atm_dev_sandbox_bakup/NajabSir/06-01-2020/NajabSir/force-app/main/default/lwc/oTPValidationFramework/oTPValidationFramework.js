import { LightningElement, track, api} from 'lwc';
import saveOtp from '@salesforce/apex/GenerateOTPValidation.saveOtp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';	

export default class OtpValidationFunctionality extends LightningElement {

    @api closeModal = false;
    @track generatedOtpValue;  
    @api recordId; 
    @track error;
    @track showspinner = false;



    //Method to close the quick action
    closequickAction(){ 
        // Fire the custom event
        this.dispatchEvent(new CustomEvent('closequickacion'));
    }

    //Method to generate OTP and call apex and save the details in Contact record.
    generateOtp(){
        this.showspinner = true;
        this.generatedOtpValue = Math.floor(Math.random()*1000000);
     
        saveOtp({
            otpNumber: this.generatedOtpValue,
            recordId: this.recordId
        })
        .then(() => {
            //Show toast message
            const evt = new ShowToastEvent({
                title: 'Record Update',
                message: 'OTP has been generated successfully',
                variant: 'success',
                mode: 'dismissable'
            }); 
            this.dispatchEvent(evt);
            
            //Fire an event to handle in aura component to close the modal box
            if(this.closeModal)
                this.dispatchEvent(new CustomEvent('closequickacion'));
            else
                this.showspinner = false;
        })
        .catch(error => {
            this.error = error; 
            //Show toast message
            const evtErr = new ShowToastEvent({
                title: 'Record Error',
                message: 'failure occurred' + this.error,
                variant: 'failure',
                mode: 'dismissable'
            }); 
            this.dispatchEvent(evtErr);
        });
    }

}