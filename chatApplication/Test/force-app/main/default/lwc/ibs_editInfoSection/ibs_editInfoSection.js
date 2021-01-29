import { LightningElement, track, api } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import getRecordsFromSF from '@salesforce/apex/IBSReadOnlyRelatedListController.getUserId';
export default class Ibs_editInfoSection extends LightningElement {
    @api layoutytype;
    @api headerTitle;
    @api themeType;
    @api headerType;
    @api iconName;
    @api fieldsToShow;
    @api objectName = 'Account';
    @track showHeader = false;
    @track showModal = false;
    @track showSpinner = false;
    @track recordId;

    connectedCallback() {
        if (this.headerType == 'With header') {
            this.showHeader = true;
        }
        registerListener('selectedAccountUpdate'
            , this.handleAccountChange,
            this);
        this.getUserAccId();
    }

    getUserAccId() {
        getRecordsFromSF()
            .then(result => {
                console.log('userId Edit', result);
                this.recordId = result;
            }).catch(error => {
                console.log('Erro while geeting Id', error);
            })
    }
    get columns() {
        if (this.layoutytype) {
            if (this.layoutytype == '4 Cols') {
                return 'slds-col slds-size_3-of-12';
            } else if (this.layoutytype == '3 Cols') {
                return 'slds-col slds-size_4-of-12';
            } else {
                return 'slds-col slds-size_6-of-12';
            }
        }
        return '1';
    }
    get fields() {
        if (this.fieldsToShow) {
            console.log('this.fieldsToShow->', this.fieldsToShow);
            return this.fieldsToShow.split(',');
        }
        return [];
    }

    get divHeaderCls() {
        if (this.headerType == 'With header') {
            return 'slds-col slds-size_1-of-1 custom-header';
        }
        return 'slds-col slds-size_1-of-1';
    }

    get themeCls() {
        if (this.themeType == 'Grey theme') {
            return 'slds-grid slds-wrap slds-m-top_xx-small grey-theme';
        }

        return 'slds-grid slds-wrap slds-m-top_xx-small white-theme';
    }

    get themeDiv(){
        if (this.themeType == 'Grey theme') {
            return 'slds-grid slds-wrap grey-back';
        }
        return 'slds-grid slds-wrap';
    }

    displayModal() {
        this.showModal = true;
        console.log('as');
    }

    hideModal() {
        this.showModal = false;
    }

    handleSubmit(event) {
        console.log('onsubmit: ', event.detail.fields);
        this.showSpinner = true;

    }

    handleSuccess(event) {
        this.showSpinner = false;
        this.showModal = false;
        const updatedRecord = event.detail.id;
        console.log('onsuccess: ', updatedRecord);
    }

    handleError(event) {
        console.log(event.detail.message);
        this.showSpinner = false;
    }

    handleAccountChange(value) {
        this.recordId = value;
    }
}