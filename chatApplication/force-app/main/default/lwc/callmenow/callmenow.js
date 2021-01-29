import { LightningElement, track } from 'lwc';
import callNow from '@salesforce/apex/CallMeNowController.callNow';

export default class Callmenow extends LightningElement {
    @track isSuccess = false;
    @track isError = false;
    @track errMsg;

    handleOk(event){
        this.isSuccess = false;
        this.isError = false;
        this.errMsg = null;
        let telNumber = this.template.querySelector("lightning-input[data-txt-id=telNo]").value;
        //let input = this.template.querySelector(".phone");
        

        //if(input.validity.valid === true){
            let spinner = this.template.querySelector(".processing");
            spinner.classList.add("show");
            this.sendPhoneNumber(telNumber);
        //}
    }
    sendPhoneNumber(telNumber){
        let spinner = this.template.querySelector(".processing");
        callNow({telNumber : telNumber })
        .then(result => {                        
            if(result === true)
                this.isSuccess = true;      
            else    
                this.isError = true;

            spinner.classList.remove("show");
        })
        .catch(error => {
            console.log('callNow Error', error);       
            this.errMsg = error;    
            spinner.classList.remove("show"); 
        });
    }
}