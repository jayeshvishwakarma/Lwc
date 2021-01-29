/*
        Name            :    Jayesh Vishwakarma
        Author          :    iBirds Services
        Date            :    29-10-2020
*/
import { LightningElement, wire } from 'lwc';
import createVoipReqRecord from  '@salesforce/apex/VoipRequestRecordController.createVoipRequestRecord';
import getAccountRecord from  '@salesforce/apex/VoipRequestRecordController.getAccount';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GRATISVOIP_THANKS_URL from '@salesforce/label/c.gratisvoip_thanks_url';

export default class VoipRequestForm extends NavigationMixin(LightningElement){
    accountId;
    antalGebruiker;
    vastNummer = 'Nieuw 085-nummer';
    tePorterenNummers = '';
    isOnbeperktBellen = "No";
    yealinkTelefoon;
    voornaam = '';
    achternaam = '';
    emailadres = '';
    telefoonnummer = '';
    isTeporteren = false;
    objVoipRequest = {};
    kostenOnbeperktBellen;
    kostenYealink;
    gratisvoip_thanks_url = GRATISVOIP_THANKS_URL;
    isMainBlock = false;
    isLoading = true;
    isMobileView = false;
    screenWidth;

    constructor(){
        super();
        this.accountId = this.getUrlParameter("id");
        if(this.accountId){
            this.getAccount();
            this.isMainBlock = true;
            this.isLoading = false;
        }else{
            this.isMainBlock = false;
            this.isLoading = false;
        }
        this.screenWidth = screen.width;
        if(this.screenWidth < 600){
            this.isMobileView = true;
        }else{
            this.isMobileView = false;
        }
    }

    get options(){
        return [
                {label:"Nieuw 085-nummer", value:"Nieuw 085-nummer"},
                {label:"Nieuw regionaal nummer", value:"Nieuw regionaal nummer"},
                {label:"Bestaand nummer porteren", value:"Bestaand nummer porteren"}
                ];
    }

    get onbeperktBellenOptions(){
        return [
                {label:"Ja", value:"Yes"},
                {label:"Nee", value:"No"}
                ];
    }

    getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search); 
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }

    /**
     * @method antalGebruikerChange
     * @param {any} event
     * @description : This method is binded on the voipRequestForm.html page and will be call when input value updates
     */
    antalGebruikerChange(event){
        this.antalGebruiker = event.currentTarget.value;
        this.calculateKostenOnbeperktBellen();
        
    }

    onbeperktBellenChange(event){
        this.isOnbeperktBellen = event.currentTarget.value; 
        this.calculateKostenOnbeperktBellen();
    }

    /**
     * calculateKostenOnbeperktBellen
     * @param {}
     * @description : This method will calculate value of this.kostenOnbeperktBellen & this.antalGebruiker also will not return anything
     */
    calculateKostenOnbeperktBellen(){
        if(this.isOnbeperktBellen == "Yes" && this.antalGebruiker > 0){
            this.kostenOnbeperktBellen = (this.antalGebruiker * 7).toLocaleString("nl-NL", {minimumFractionDigits: 2});;
            this.kostenOnbeperktBellen = '€ '+this.kostenOnbeperktBellen;
        }else{
            this.kostenOnbeperktBellen = '';
        }
    }

    changeVastNummer(event){
        this.vastNummer = event.currentTarget.value;
        if(this.vastNummer == 'Bestaand nummer porteren'){
            this.isTeporteren = true;
        }else{
            this.isTeporteren = false;
        }
    }

    tePorterenNummersChange(event){
        this.tePorterenNummers = event.currentTarget.value;
    }

    yealinkTelefoonChange(event){
        this.yealinkTelefoon = event.currentTarget.value;
        if(this.yealinkTelefoon > 0 ){
        this.kostenYealink = (this.yealinkTelefoon * 59.95).toLocaleString("nl-NL", {minimumFractionDigits: 2});
        this.kostenYealink = '€ '+this.kostenYealink;
        }else{
            this.kostenYealink = '';
        }
    }

    voornaamChange(event){
        this.voornaam = event.currentTarget.value;
    }

    achternaamChange(event){
        this.achternaam = event.currentTarget.value; 
    }

    emailadresChange(event){
        this.emailadres = event.currentTarget.value; 
    }

    telefoonnummerChange(event){
        this.telefoonnummer = event.currentTarget.value; 
    }

    tePorterenNummersChange(event){
        this.tePorterenNummers = event.currentTarget.value; 
    }

    getAccount(){
        getAccountRecord({recordId : this.accountId})
        .then(result =>{
            console.log('Result : ',JSON.stringify(result));
            this.voornaam = result.Voornaam_CP__c;
            this.achternaam = result.Achternaam_CP__c;
            this.emailadres = result.E_mailadres_bedrijf__c;
            this.telefoonnummer = result.Phone;
        })
        .catch(error => {
            const toastEvent = new ShowToastEvent({
                title : "Voip Request Record",
                message : JSON.stringify(error),
                variant : "error",
                mode : "dismissable"
            })
            this.dispatchEvent(toastEvent);
        });
    }

    /**
     * onSubmit
     * @param {}
     * @description : This method will create a record of voip request in the database and redirect to the thanks page
     */
    onSubmit(){
        this.isLoading = true;
        if(this.isOnbeperktBellen == "Yes"){
            this.isOnbeperktBellen = true;
        }else if(this.isOnbeperktBellen == "No"){
            this.isOnbeperktBellen = false;
        }
        this.objVoipRequest = {
                'Aantal_gebruikers__c' : this.antalGebruiker,
                'Achternaam_CP__c' : this.achternaam,
                'Bedrijf__c' : this.accountId,
                'E_mailadres__c' : this.emailadres,
                'Onbeperkt_bellen__c' : this.isOnbeperktBellen,
                'Phone__c': this.telefoonnummer,
                'Te_porteren_nummers__c': this.tePorterenNummers,
                'Vast_nummer__c': this.vastNummer,
                'Voornaam_CP__c' : this.voornaam,
                'Yealink_T41S__c' : this.yealinkTelefoon
        }
        console.log('Result : '+JSON.stringify(this.objVoipRequest));
        createVoipReqRecord({objVoipRequest : this.objVoipRequest})
        .then(result => {
            this.isLoading = false;
            console.log('Result : '+JSON.stringify(result));
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": this.gratisvoip_thanks_url
               }
            },
            true
           ); 
        })
        .catch(error => {
            this.isLoading = false;
            console.log('Error : '+JSON.stringify(error));
            const toastEvent = new ShowToastEvent({
                title : "Voip Request Record",
                message : JSON.stringify(error),
                variant : "error",
                mode : "dismissable"
            })
            this.dispatchEvent(toastEvent);
        });
    }
}