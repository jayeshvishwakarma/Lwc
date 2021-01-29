import { subscribe, APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';
import BOATMC from "@salesforce/messageChannel/BoatMessageChannel__c";
import { LightningElement, wire, api, track } from 'lwc';
import getBoats from "@salesforce/apex/BoatDataService.getBoats";
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Length', fieldName: 'Length__c', type: 'number' },
    { label: 'Price', fieldName: 'Price__c', type: 'currency' },
    { label: 'Description', fieldName: 'Description__c', type: 'text', editable: true }
];
const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT = 'Ship it!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
export default class BoatSearchResults extends LightningElement {
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    selectedBoatId;
    columns = columns;
    @api boatTypeId = '';
    @track boats;
    @track draftValues = [];
    isLoading = false;
    subscription = false;
    @wire(MessageContext)
    messageContext;
    @wire(getBoats, { boatTypeId: '$boatTypeId' })
    wiredBoats(result) {
        if (result.data) {
            this.boats = result;
            console.log(result.data);
        }
    }
    @api
    searchBoats(boatTypeId) {
        this.boatTypeId = boatTypeId;
        this.notifyLoading();
    }
    @api
    async refresh() {
        this.notifyLoading();
        return refreshApex(this.boats);
    }

    // this function must update selectedBoatId and call sendMessageService
    updateSelectedTile(event) {
        this.selectedBoatId = event.detail.boatId;
        this.sendMessageService(this.selectedBoatId);
    }

    // Publishes the selected boat Id on the BoatMC.
    sendMessageService(boatId) {
        const message = {
            recordId: boatId
        };
        publish(this.messageContext, BOATMC, message);
    }
    // This method must save the changes in the Boat Editor
    // Show a toast message with the title
    // clear lightning-datatable draft values
    handleSave(event) {
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        const promises = recordInputs.map(recordInput =>
        //update boat record
        {
            updateRecord(recordInput)

        });
        Promise.all(promises)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: SUCCESS_TITLE,
                        message: MESSAGE_SHIP_IT,
                        variant: SUCCESS_VARIANT
                    })
                );
                // Display fresh data in the form
                this.refresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR_TITLE',
                        message: error.body.message,
                        variant: ERROR_VARIANT
                    })
                );
            })
            .finally(() => { }
            );
    }
    // Check the current value of isLoading before dispatching the doneloading or loading custom event
    notifyLoading(isLoading) {
        if (isLoading) {
            const myCustomEvent = new CustomEvent("doneloading");
            this.dispatchEvent(myCustomEvent);

        }
        else {
            const myCustomEvent = new CustomEvent("loading");
            this.dispatchEvent(myCustomEvent);

        }
    }
    handleMessage(message) {
        this.selectedBoatId = message.recordId;
    }
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                BOATMC,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
}