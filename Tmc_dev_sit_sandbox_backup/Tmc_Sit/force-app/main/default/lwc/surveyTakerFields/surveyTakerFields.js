import { api, LightningElement } from 'lwc';
import IS_COMPLETED from '@salesforce/schema/Survey_Taker_CTI__c.Is_Completed__c';


export default class SurveyTakerFields extends LightningElement {

    @api recordId;
    fields = [IS_COMPLETED];

    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
    }
}