import { LightningElement, api , wire} from 'lwc';
import getAccount from  '@salesforce/apex/ServerGlasvezelRequestFormController.getAccount';
import createGlasvezel from  '@salesforce/apex/ServerGlasvezelRequestFormController.createRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendPdf from  '@salesforce/apex/ServerGlasvezelRequestFormController.sendPdf';
import { NavigationMixin } from 'lightning/navigation';
import AANTAL_ERROR from '@salesforce/label/c.Antal_error';
import ERROR_MESSAGE from '@salesforce/label/c.Error_message';
import GLASVEZEL_THANKS_URL from '@salesforce/label/c.glasvezel_thanks_url';

export default class GlasvezelRequestForm extends NavigationMixin(LightningElement){

     anatal='';
     bedrijfsnaam='';
     kvk_nummer='';
     straat='';
     huisnummer='';
     toevoeging='';
     Postcode='';
     Plaats='' ;
     Phone='';
     voornaam='';
     achternaam='';
     emailadres='';
     bankrekeningnummer='';
     accountId='';
     foxSports=false;
     ziggoSports=false;
     objGlasvezel={};
     error='';
     aantal = 0;    
     cources='';
     signature='';
     recordId = '';
     errorMessage = ERROR_MESSAGE;
     aantalError = AANTAL_ERROR;
     glasvezel_thanks_url = GLASVEZEL_THANKS_URL;
     isError = false;
     formCompleted = true;
     isLoading = false;
     defaultValue = true;
     
    constructor(){
        super(); 
        this.recordId = this.getUrlParameter("id");
        console.log(this.recordId);
        this.cources="RAZENDSNEL";
      //  document.getElementById("razen").checked=true;
      console.log(document.querySelectorAll('input[id="razen"]').checked);
       document.querySelectorAll('input[id="razen"]').checked;
    
        
    }
    
    getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search); 
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }   

    @wire(getAccount, {recordId : '$recordId' }) 
    objAccount({data,error}){
        if(data){
            this.formCompleted = false;
            console.log(data);
            this.Bedrijfsnummer=data.Bedrijfsnummer__c;
            this.accountId=data.Id;
            this.bedrijfsnaam=data.Name;
            this.kvk_nummer=data.KvK_nummer__c;
            this.straat=data.Straat__c;
            this.huisnummer=data.Huisnummer__c
            this.toevoeging=data.Huisnummer_toevoeging__c;
            this.postcode=data.Postcode__c;
            this.plaats=data.ShippingCity;
            this.phone=data.Phone;

        }else if(error){
            this.error=error;
            console.log(error);
        }

    }
    handleaantalchange(event){
            this.aantal = event.target.value;
    }
    handleChange(event){
        console.log('handleChange',event.currentTarget.dataset.value);
       this.cources = event.currentTarget.value;
       this.defaultValue = false;
       console.log(this.cources); 
    }
    handlecheckboxfoxsports(event){
     this.foxSports=event.currentTarget.checked;
    }
    handlecheckboxziggosports(event){
        this.ziggoSports=event.currentTarget.checked; 
    }
    emailchange(event){
        this.emailadres=event.target.value;
    }
    voornaamchange(event){
       this.voornaam = event.target.value; 
    }
    achternaamchange(event){
        this.achternaam = event.target.value;
    }
    phonechange(event){
        this.phone = event.target.value;
    }
    bankrekeningnummerchange(event){
        this.bankrekeningnummer = event.target.value;
    }
    handleClear(event){
        console.log("signature blank");
        this.signature=null;
    }
    handleClick(){    
        this.signature = this.template.querySelector("c-signature").getSignatureUrl();
        console.log('signature : '+this.signature);
        /*if(this.kvk_nummer =='' || this.bedrijfsnaam=='' || this.voornaam=='' || this.achternaam=='' || this.emailadres=='' || this.signature==null || this.aantal<= '0'){
            console.log("if runs");
            this.isError = true;     
            if(this.aantal <='0'){
                const aantalErr = new ShowToastEvent({
                    title : "Glasvezel Request",
                    message : 'please enter a Aantal greater than 0',
                    variant : "error",
                    mode : "dismissable"
                })  
                this.dispatchEvent(aantalErr);  
            }            
            const requiredFieldError = new ShowToastEvent({
                title : "Glasvezel Request",
                message : this.errorMessage ,
                variant : "error",
                mode : "dismissable"
            })           
            this.template.querySelector("c-signature").handleClearClick();
            this.signature=null;
            this.dispatchEvent(requiredFieldError);
        }else{*/
            console.log("else runs");
            this.isLoading = true;
         
      
            this.objGlasvezel = {
                'KvK_nummer__c':this.kvk_nummer,
                'Bedrijfsnaam__c': this.bedrijfsnaam,
                'Straat__c' : this.straat,
                'Huisnummer__c' : this.huisnummer,
                'Huisnummer_toevoeging__c' : this.toevoeging,
                'Postcode__c': this.postcode,
                'ShippingCity__c': this.plaats,
                'Phone__c': this.phone,
                'Aantal__c' : this.aantal,
                'Account__c' : this.accountId,
                'Fox_Sports__c': this.foxSports ,
                'Ziggo_Sports__c':this.ziggoSports,
                'E_mailadres_bedrijf__c':this.emailadres,
                'Cources__c' : this.cources,
                'Bedrijfsnummer__c' : this.Bedrijfsnummer,
                'Voornaam_CP__c' : this.voornaam,
                'Achternaam_CP__c' : this.achternaam,
                'Bankrekeningnummer__c' : this.bankrekeningnummer
                };
                console.log("Glasvezel : "+JSON.stringify(this.objGlasvezel));
                console.log("signature : "+this.signature);
                 createGlasvezel({objGlasvezelRequest : this.objGlasvezel,signUrl : this.signature}).then(result=>{
                    console.log(result);
                    if(result){
                        console.log('PdfResult'+result);
                    sendPdf({id : result,emailId : this.emailadres }).then(pdfResult=>{
                        console.log('PdfResult'+pdfResult);
                        this.isLoading = false;
                        this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                "url": this.glasvezel_thanks_url
                            }
                        },
                        true
                        );                       
                    }).catch(error=>{
                        console.log(error);
                        this.isLoading = false;
                        this.signature=null;
                        this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                "url": this.glasvezel_thanks_url
                            }
                        },
                        true
                        );
                    });

                }   
            }
            
            ).catch(error=>{
                    console.log(error);
                    this.signature=null;
                    this.isLoading = false;
                const toastEvent = new ShowToastEvent({
                    title : "Glasvezel Request",
                    message : "Glasvezel request failed",
                    variant : "error",
                    mode : "dismissable"
                })
                this.dispatchEvent(toastEvent);
            });
        
        
        //}   
    }   
    
}