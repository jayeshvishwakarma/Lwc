import { LightningElement, wire } from 'lwc';
import getTriggerSettings from  '@salesforce/apex/TriggerSettingsController.getTriggerSettings';
import updateTriggerSettings from  '@salesforce/apex/TriggerSettingsController.updateTriggerSettings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerSettings extends LightningElement {

    isSelectAll;
    isAccountTrigger;
    isBestellingMMTrigger;
    isOpportunityTrigger;
    isPorteringenMobielTrigger;
    isQuoteTrigger;
    isVolPTrigger;
    isAvailableSpeedTrigger;
    isBestellingproduct;
    error;
    objTrigger = {};
    Id;
    constructor (){
        super();  
        this.isSelectAll = false;

    }


    handleChangeSelectAll(event){
    this.isSelectAll = event.target.checked;
    this.isAccountTrigger = event.target.checked;
    this.isBestellingMMTrigger = event.target.checked;
    this.isOpportunityTrigger = event.target.checked;
    this.isPorteringenMobielTrigger = event.target.checked;
    this.isQuoteTrigger = event.target.checked;
    this.isVolPTrigger = event.target.checked;
    this.isAvailableSpeedTrigger = event.target.checked;
    this.isBestellingproduct = event.target.checked;
    }

    handleChangeAccountTrigger(event){
        this.isAccountTrigger = event.target.checked;
    }

    handleChangeBestellingMMTrigger(event){
        this.isBestellingMMTrigger = event.target.checked;
    }

    handleOpportunityTrigger(event){
        this.isOpportunityTrigger = event.target.checked;
    }

    handlePorteringenMobielTrigger(event){
        this.isPorteringenMobielTrigger = event.target.checked;
    }

    handleQuoteTrigger(event){
        this.isQuoteTrigger = event.target.checked;
    }

    handleVolPTrigger(event){
        this.isVolPTrigger = event.target.checked;
    }

    handleAvailableSpeedTrigger(event){
        this.isAvailableSpeedTrigger = event.target.checked;
    }

    handleBestellingproductTrigger(event){
        this.isBestellingproduct = event.target.checked;
    }

    handleSave(){
         this.objTrigger = {
                            'Id' : this.Id,
                            'Account_Trigger__c' :   this.isAccountTrigger ,
                            'Bestellingproduct_Trigger__c' : this.isBestellingMMTrigger,
                            'Opportunity_Trigger__c' : this.isOpportunityTrigger,
                            'Porteringen_mobiel_Trigger__c' : this.isPorteringenMobielTrigger,
                            'Quote_Trigger__c' : this.isQuoteTrigger,
                            'VolP_Trigger__c' : this.isVolPTrigger,
                            'AvailableSpeed_Trigger__c' : this.isAvailableSpeedTrigger,
                            'Bestelling_MM_Trigger__c' : this.isBestellingproduct
                            };
                            console.log(this.objTrigger);
         updateTriggerSettings({objTriggerSetting : this.objTrigger})
         .then(result => {
            console.log(result);
                const toastEventfirst = new ShowToastEvent({
                title : "Trigger Settings",
                message : "Successfully updated",
                variant : "success",
                mode : "dismissable"
               })   
            this.dispatchEvent(toastEventfirst); 

         })
         .catch(error =>{
            console.log(error);
                this.error = error;
                const toastEventSecond = new ShowToastEvent({
                    title : "Trigger Settings",
                    message : "Update failed",
                    variant : "error",
                    mode : "dismissable"
                   }) 
                   this.dispatchEvent(toastEventSecond); 
         });
    }

    @wire(getTriggerSettings)
    getSettings({data,error}){
        if(data){
                    this.Id = data.Id;
                    this.isAccountTrigger = data.Account_Trigger__c;
                    this.isBestellingMMTrigger = data.Bestellingproduct_Trigger__c;
                    this.isOpportunityTrigger = data.Opportunity_Trigger__c;
                    this.isPorteringenMobielTrigger = data.Porteringen_mobiel_Trigger__c;
                    this.isQuoteTrigger = data.Quote_Trigger__c;
                    this.isVolPTrigger = data.VolP_Trigger__c;
                    this.isAvailableSpeedTrigger = data.AvailableSpeed_Trigger__c;
                    this.isBestellingproduct = data.Bestelling_MM_Trigger__c;
        }else if(error){
                    this.error = error;
        }
        
    }
}