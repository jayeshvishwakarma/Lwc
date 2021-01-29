/* eslint-disable no-restricted-globals */
/* eslint-disable eqeqeq */
/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable vars-on-top */
/* eslint-disable no-useless-escape */
/* eslint-disable no-unused-expressions */
/* eslint-disable no-unused-vars */
import { LightningElement, api , wire} from 'lwc';
import getAccount from  '@salesforce/apex/ServerGlasvezelRequestFormController.getAccount';
import createGlasvezel from  '@salesforce/apex/ServerGlasvezelRequestFormController.createRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import sendPdf from  '@salesforce/apex/ServerGlasvezelRequestFormController.sendPdf';
import { NavigationMixin } from 'lightning/navigation';
import AANTAL_ERROR from '@salesforce/label/c.Antal_error';
import ERROR_MESSAGE from '@salesforce/label/c.Error_message';
import GLASVEZEL_THANKS_URL from '@salesforce/label/c.glasvezel_thanks_url';
import GRATIS_KPN from '@salesforce/label/c.Gratis_Kpn';

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
     vastNummer = 'Nieuw 085-nummer';
     aantalOptionValue = "5";
     gratisKpnLabel = GRATIS_KPN;
     
    constructor(){
        super(); 
        this.defaultValue = true;
        this.recordId = this.getUrlParameter("id");
        console.log(this.recordId);
        this.cources="RAZENDSNEL";
      //  document.getElementById("razen").checked=true;
      // eslint-disable-next-line @lwc/lwc/no-document-query
      console.log(document.querySelectorAll('input[id="razen"]').checked);
       document.querySelectorAll('input[id="razen"]').checked;
    }


    get aantalOptions(){
        return [
                    {label:"5", value:"5"},
                    {label:"6", value:"6"},
                    {label:"7", value:"7"},
                    {label:"8", value:"8"},
                    {label:"9", value:"9"},
                    {label:"4", value:"4"},
                    {label:"3", value:"3"},
                    {label:"2", value:"2"},
                    {label:"Geen", value:"Geen"}
                ];
    }

    get vastNummerOptions(){
        return [
                    {label:"Nieuw 085-nummer", value:"Nieuw 085-nummer"},
                    {label:"Nieuw regionaal nummer", value:"Nieuw regionaal nummer"},
                    {label:"Bestaand nummer porteren", value:"Bestaand nummer porteren"}
                ];
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
            this.aantal = event.currentTarget.value;
    }
    handleChange(event){
        console.log('handleChange',event.currentTarget.dataset.value);
       this.cources = event.currentTarget.value;
       if(this.cources != 'RAZENDSNEL'){
            this.defaultValue = false;
       }else{
        this.defaultValue = true;      
       }
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


    aantalChange(event){
        this.aantalOptionValue = event.target.value;
        console.log(this.aantalOptionValue);
    }
    vastNummerChange(event){
        this.vastNummer = event.target.value;
        console.log(this.vastNummer);
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
                'Bankrekeningnummer__c' : this.bankrekeningnummer,
                'aantal_VoIP__c' : this.aantalOptionValue,
                'Vast_nummer__c' : this.vastNummer
                };
                console.log("Glasvezel : "+JSON.stringify(this.objGlasvezel));
                console.log("signature : "+this.signature);
                 createGlasvezel({objGlasvezelRequest : this.objGlasvezel,signUrl : this.signature}).then(result=>{
                    console.log(result);
                    this.isLoading = false;
                          this[NavigationMixin.Navigate]({
                              "type": "standard__webPage",
                              "attributes": {
                                  "url": this.glasvezel_thanks_url
                             }
                          },
                          true
                         );                       
                //     if(result){
                //         console.log('PdfResult'+result);
                //     // sendPdf({id : result,emailId : this.emailadres }).then(pdfResult=>{
                //     //     console.log('PdfResult'+pdfResult);
                //     //     this.isLoading = false;
                //     //     this[NavigationMixin.Navigate]({
                //     //         "type": "standard__webPage",
                //     //         "attributes": {
                //     //             "url": this.glasvezel_thanks_url
                //     //         }
                //     //     },
                //     //     true
                //     //     );                       
                //     // }).catch(error=>{
                //     //     console.log(error);
                //     //     this.isLoading = false;
                //     //     this.signature=null;
                //     //     this[NavigationMixin.Navigate]({
                //     //         "type": "standard__webPage",
                //     //         "attributes": {
                //     //             "url": this.glasvezel_thanks_url
                //     //         }
                //     //     },
                //     //     true
                //     //     );
                //     // });

                // }   
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