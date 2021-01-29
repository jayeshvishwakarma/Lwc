import { LightningElement, track, api } from 'lwc';
import getRecordsFromSF from '@salesforce/apex/IBSReadOnlyRelatedListController.getUserId';
import { registerListener, unregisterAllListeners } from 'c/pubSub';

export default class Ibs_accountDetailSection extends LightningElement {

    @track recordId;
    @track displayModal = false;
    connectedCallback() {
        registerListener('selectedAccountUpdate'
            , this.handleAccountChange,
            this);

        this.getUserAccId();
    }

    getUserAccId() {
        getRecordsFromSF()
        .then(result => {
            console.log('userId Account ', result);
            this.recordId = result;
        }).catch(error => {
            console.log('Erro while geeting Id',error);
        })
    }

    get moblieMilesFlds() {
        return ['Totaal_MobileMiles_gespaard__c', 'Verzilverd_MM__c', 'Saldo_MobileMiles__c'];
    }

    showMobileModal() {
        this.displayModal = true;
    }
    hideMobileModal() {
        this.displayModal = false;
    }
    handleAccountChange(value) {
        console.log('events', event);
        this.recordId = value;
    }
}