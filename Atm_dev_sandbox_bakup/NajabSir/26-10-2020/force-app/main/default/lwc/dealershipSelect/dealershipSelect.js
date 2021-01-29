import {LightningElement, api, track  } from 'lwc';

import getForCodeDetail from '@salesforce/apex/CreateCustomerCtrl.getForCodeDetail';
import getAccountDetail from '@salesforce/apex/CreateCustomerCtrl.getAccountDetail';

export default class DealershipSelect extends LightningElement {

    @api forcodeid;
    @api forcodename;
    @api dealershipid;
    @api dealershipname;

    @track forCodeSelection = [];
    @track accountSelection = [];

    forCodeRecords;
    selectedForCodeRecordId;
    accountRecords;
    selectedAccountId;

    selectedForCodeRecord;
    selectedAccountRecord;
    error;

    connectedCallback(){
        console.log('== LWC forCodeId ', this.forcodeid);
        console.log('== LWC forCodeName ', this.forcodename);
        console.log('== LWC dealerShipId ', this.dealershipid);
        console.log('== LWC dealerShipName ', this.dealershipname);

        if(this.forcodeid && this.forcodename){
            this.selectedForCodeRecordId = this.forcodeid;

            let forCodedata = {};
            forCodedata.id = this.forcodeid;
            forCodedata.title = this.forcodename;
            this.forCodeSelection.push(forCodedata);
        }
        

        if(this.dealershipid && this.dealershipname){
            this.selectedAccountId = this.dealershipid;
            let accountdata = {};
            accountdata.id = this.dealershipid;
            accountdata.title = this.dealershipname;

            this.accountSelection.push(accountdata);
        }

    }

    get lookupInputField() {
        return this.template.querySelector("c-lookup-input-field");
    }

    handleForCodeCustomSearch(event) {
        console.log('== ForCode Text', event.detail.searchTerm);

        getForCodeDetail({ name: event.detail.searchTerm})
        .then(result => {
            console.log('== == ForCode Result ', result);
            this.forCodeRecords = result;
            let formatedResult = [];
            if (result) {
                for (let data of result) {
                    if (data) {
                        let obj = {
                            id: data.Id,
                            title: data.Name
                        };
                        formatedResult.push(obj);
                    }
                }
            }
            console.log('== formatedResult ', formatedResult);
            if (formatedResult) {
                this.lookupInputField.updateSearchResults(formatedResult);
            }
        })
        .catch(error => {
            console.log('== == ON For Code Error ', error);
        })

    }

    handleSelectForCode(event) {

        console.log('== Selected ForCode Id ', event.target.value);
        if (event.detail.value) {
            this.selectedForCodeRecordId = event.detail.value;
            this.selectedForCodeRecord = this.forCodeRecords.find(record => record.Id === this.selectedForCodeRecordId);

            console.log('== selectedForCodeRecord ', this.selectedForCodeRecord);

            this.dispatchEvent(new CustomEvent("forcodeselect", {
                detail: {forCodeId: this.selectedForCodeRecordId}}));

        }else if (event.detail.value === undefined) {
            this.selectedForCodeRecordId = null;
            this.dispatchEvent(new CustomEvent("forcodeselect", {
                detail: {forCodeId: this.selectedForCodeRecordId}}));

            this.handleForCodeRemove();
        }
    }

    handleAccountCustomSearch(event) {
        console.log('== Account Text', event.detail.searchTerm);
        console.log('== Selected Forcode Id ', this.selectedForCodeRecordId);

        if(this.selectedForCodeRecordId){
            getAccountDetail({ name: event.detail.searchTerm, forCodeId: this.selectedForCodeRecordId})
            .then(result => {
                console.log('== == Account Result ', result);
                this.accountRecords = result;
                let formatedResult = [];
                if (result) {
                    for (let data of result) {
                        if (data) {
                            let obj = {
                                id: data.Id,
                                title: data.Name
                            };
                            formatedResult.push(obj);
                        }
                    }
                }
                console.log('== Account Result ', formatedResult);
                if (formatedResult) {
                    this.lookupInputField.updateSearchResults(formatedResult);
                }
            })
            .catch(error => {
                console.log('== == ON Account Error ', error);
            })
        }
    }

    handleSelectAccount(event) {

        if (event.detail.value) {
            this.selectedAccountId = event.detail.value;
            console.log('== handle Search Account Id ', this.selectedAccountId);
            if(this.accountRecords){
                this.selectedAccountRecord = this.accountRecords.find(record => record.Id === this.selectedAccountId);
            }
            console.log('== selectedAccountRecord ', this.selectedAccountRecord);

            this.dispatchEvent(new CustomEvent("dealershipselect", {
                detail: {dealerShipId: this.selectedAccountId}}));

        }else if (event.detail.value === undefined) {
            this.selectedAccountId = null;
            this.dispatchEvent(new CustomEvent("dealershipselect", {
                detail: {dealerShipId: this.selectedAccountId}}));

            this.handleAccountRemove();
        }
    }


    handleForCodeRemove() {
        console.log('== IN Handle For Code Remove');
        this.selectedForCodeRecord = undefined;
        this.selectedForCodeRecordId = undefined;
        this.forCodeRecords = undefined;
        this.error = undefined;
        this.handleAccountRemove();
    }

    handleAccountRemove() {
        console.log('== IN Handle Account Remove');
        this.selectedAccountRecord = undefined;
        this.selectedAccountId = undefined;
        this.accountRecords = undefined;
        this.error = undefined;
    }
}