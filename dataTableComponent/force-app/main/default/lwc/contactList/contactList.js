import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import LAST_NAME from '@salesforce/schema/Contact.LastName';
import EMAIL_ID from '@salesforce/schema/Contact.Email';
import {reduceErrors} from 'c/ldsUtils';

const COLUMNS = [
    { label: 'First Name', fieldName: FIRST_NAME.fieldApiName, type: 'text' },
    { label: 'Last Name', fieldName: LAST_NAME.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: EMAIL_ID.fieldApiName, type: 'email' }
];

export default class ContactList extends LightningElement {

    columns = COLUMNS;
    @wire(getContacts)
    contacts;

    get errors(){
        return (this.contacts.error) ? reduceErrors(this.contacts.error) : [];
    }
}