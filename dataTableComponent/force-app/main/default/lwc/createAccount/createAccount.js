import { LightningElement, wire } from 'lwc';
import { createRecord} from 'lightning/uiRecordApi';
import IPHONE12_IMAGE from '@salesforce/resourceUrl/Iphone12';
import {CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_PHONE from '@salesforce/schema/Account.Phone';
import ACCOUNT_CITY from '@salesforce/schema/Account.BillingCity';
import { fireEvent } from 'c/pubsub';

export default class CreateAccount extends LightningElement {

    accountId;
    isSaveButton;
    isCreated;
    imageUrl;
    constructor()
    {
        super();
        this.isSaveButton=false;
        this.isCreated = false;
        this.imageUrl = IPHONE12_IMAGE;
    }

    @wire(CurrentPageReference) pageRef;

    handleSave()
    {
        const accountName = this.template.querySelector("lightning-input[data-my-id=txtName]").value;
        const accountPhone = this.template.querySelector("lightning-input[data-my-id=txtPhone]").value;
        const accountCity = this.template.querySelector("lightning-input[data-my-id=txtCity]").value;
        const fieldsObj={};
        fieldsObj[ACCOUNT_NAME.fieldApiName]=accountName;
        fieldsObj[ACCOUNT_PHONE.fieldApiName] = accountPhone;
        fieldsObj[ACCOUNT_CITY.fieldApiName] = accountCity;
        createRecord({apiName:ACCOUNT_NAME.objectApiName,fields:fieldsObj})
        .then(
            (objAccount)=>{
                this.accountId = objAccount.id;
                this.isSaveButton = true;
                this.isCreated = true;
                const toastEvent = new ShowToastEvent({
                    title : "New Account",
                    message : "Account Created Successfully",
                    variant : "success",
                    mode : "dismissable"
                })
                this.dispatchEvent(toastEvent);
                fireEvent(this.pageRef,'newAccount',objAccount);
            }
        )
        .catch((error)=>{
            const toastEvent = new ShowToastEvent({
                title : "New Account",
                message : "Account Creation Failed",
                variant : "error",
                mode : "dismissable"
            })
        });
    }

    handleClear()
    {
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        this.isSaveButton = false;
        this.isCreated = false;   }
}