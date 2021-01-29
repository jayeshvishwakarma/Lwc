import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountByNumber from  '@salesforce/apex/ServerGlasvezelRequestFormController.getAccountByNumber';
import GLASVEZEL_REQUEST_FORM_URL from '@salesforce/label/c.glasvezel_request_form_url';
export default class GlasvezalGetAccount extends NavigationMixin(LightningElement) {
    accNumber;
    accountId; 
    isLoading = false;
    glasvezel_request_form_url = GLASVEZEL_REQUEST_FORM_URL;
    constructor(){
        super();
    }
    handleChangeAccNumber(event){
        this.accNumber = event.target.value;
    }
    handleClickNext(){

        if(this.accNumber == ''){
            const accError = new ShowToastEvent({
                title : "Glasvezel Request",
                message : "Account number is required !",
                variant : "error",
                mode : "dismissable"
            })   
            this.dispatchEvent(accError);    
           
        }else{
            this.isLoading = true; 
        getAccountByNumber({accountNumber : this.accNumber})
        .then(data => {

            if(data){
                  
                this.accountId = data.Id;  
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": this.glasvezel_request_form_url+'?id='+this.accountId
                    }
                },true               
                );
                this.isLoading = false;
            }else{
                const accNumberError = new ShowToastEvent({
                    title : "Glasvezel Request",
                    message : "Account number is invalid !",
                    variant : "error",
                    mode : "dismissable"
                })   
                this.dispatchEvent(accNumberError); 
                this.isLoading = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false; 
        });          
        }


       
    }
}