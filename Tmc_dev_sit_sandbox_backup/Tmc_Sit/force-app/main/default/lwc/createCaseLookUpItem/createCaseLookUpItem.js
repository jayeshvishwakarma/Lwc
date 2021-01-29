import { LightningElement,api } from 'lwc';

export default class CreateCaseLookUpItem extends LightningElement {
    @api iconName= 'standard:account';
    @api record;
    @api isMobileDevice = false;

    connectedCallback(){
    }
    handleSelect(event){
        event.preventDefault();
        /*let obj ={};
        obj.Name = this.record.Name;
        obj.Id = this.record.Id;
        if(this.record.Type){
            obj.Type = this.record.Type;
        }
        if(this.record.Dealer_Code__c){
            obj.Dealer_Code__c = this.record.Dealer_Code__c;
        }
        if(this.record.Region_Code__c){
            obj.Region_Code__c = this.record.Region_Code__c;
        }
        if(this.record.Dealer_Type__c){
            obj.Dealer_Type__c = this.record.Dealer_Type__c;
        }
        if(this.record.BillingCity){
            obj.BillingCity = this.record.BillingCity;
        }
        if(this.record.BillingPostalCode){
            obj.BillingPostalCode = this.record.BillingPostalCode;
        }
        if(this.record.BillingState){
            obj.BillingState = this.record.BillingState;
        }
        if(this.record.BillingState){
            obj.Zone__c = this.record.Zone__c;
        }*/
        const searchEvent = new CustomEvent('select',{detail : this.record});
        this.dispatchEvent(searchEvent);
    }
}