import { LightningElement } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import LAST_NAME from '@salesforce/schema/Contact.LastName';
import EMAIL_ID from '@salesforce/schema/Contact.Email';

export default class ContactCreator extends LightningElement {

    objectApiName = CONTACT_OBJECT;
    fields = [FIRST_NAME, LAST_NAME,EMAIL_ID ];

    handleSuccess(event){

         const toastEvent = new ShowToastEvent({
            title : "Contact Created",
            message : "Record Id : " +event.detail.id,
            variant : "success"
        });
        this.dispatchEvent(toastEvent);
    }

}