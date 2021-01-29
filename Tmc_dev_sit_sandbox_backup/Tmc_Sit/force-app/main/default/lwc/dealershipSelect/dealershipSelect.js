import {LightningElement, api, track  } from 'lwc';

import getForCodeDetail from '@salesforce/apex/CreateCustomerCtrl.getForCodeDetail';
import getAccountDetail from '@salesforce/apex/CreateCustomerCtrl.getAccountDetail';

export default class DealershipSelect extends LightningElement {

    @api forcodeid;
    @api forcodename;
    @api dealershipid;
    @api dealershipname;
    @api dealerchannel;
    @api transtype;
    @api isDisabled;

    @track forCodeSelection = [];
    @track accountSelection = [];

    forCodeRecords;
    selectedForCodeRecordId;
    accountRecords;
    selectedAccountId;

    selectedForCodeRecord;
    selectedAccountRecord;
    error;

    isLoading = false;
    readOnlyMode = false;
    isForCodeSelected = false
    isPinCodeSelected = false;

    optionLimit = 100;

    selectedPinCode;
    dealershipOptions = [];
    pincodeWithDealerMap = new Map();

    @track dealerShipList = [];

    @api defaultvalue() {

        let forCodelookupInput = this.getLookupInputField('For_Code__c');
        console.log('== Selected For_Code__c Lookup ', forCodelookupInput);
        if (forCodelookupInput) {
            forCodelookupInput.setSelection([]);
        }

        let accountlookupInput = this.getLookupInputField('Account');
        console.log('== Selected accountlookupInput Lookup ', accountlookupInput);
        if (accountlookupInput) {
            accountlookupInput.setSelection([]);
        }

        this.isForCodeSelected = false;
        this.isPinCodeSelected = false;
        this.dealershipOptions = [];

    }

    connectedCallback(){
        console.log('== IN DelearShip Select ', this.isDisabled);
        console.log('== LWC forCodeId ', this.forcodeid);
        console.log('== LWC forCodeName ', this.forcodename);
        console.log('== LWC dealerShipId ', this.dealershipid);
        console.log('== LWC dealerShipName ', this.dealershipname);
        console.log('== LWC dealerchannel ', this.dealerchannel);


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

    getLookupInputField(name) {
        return this.template.querySelector("[data-name=" + name + "]");
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
                //lookupInputField.updateSearchResults(formatedResult);
                let lookupInput = this.getLookupInputField('For_Code__c');
                console.log('== Selected For_Code__c Lookup ', lookupInput);
                if (lookupInput) {
                    lookupInput.updateSearchResults(formatedResult);
                }
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
            
            this.searchDealership(this.selectedForCodeRecordId);

        }else if (event.detail.value === undefined) {
            this.isPinCodeSelected = false;
            this.isForCodeSelected = false;
            this.selectedForCodeRecordId = null;
            this.dispatchEvent(new CustomEvent("forcodeselect", {
                detail: {forCodeId: this.selectedForCodeRecordId}}));
            
                this.dispatchEvent(new CustomEvent("dealershipselect", {
                    detail: {dealerShipId: null}}));

            this.handleForCodeRemove();
        }
    }

    searchDealership(ForCodeId){
        this.isLoading = true;

        getAccountDetail({ forCodeId: ForCodeId, 
            dealerchannel : this.dealerchannel, transtype : this.transtype})
        .then(result => {
            if(result){
                this.isForCodeSelected = true;
                console.log('== == Account Result ', result);

                this.dealershipOptions = [];
                if(result.pinCodeList){
                    this.dealershipOptions = result.pinCodeList;
                }

                if(result.picodeWithAccountMap){
                    this.pincodeWithDealerMap = result.picodeWithAccountMap;
                }

                console.log('== this.pincodeWithDealerMap ', this.pincodeWithDealerMap);

            }
        })
        .catch(error => {
            console.log('== == ON Account Error ', error);
        })
        .finally(() => this.isLoading = false );
    }

    handleSelect(event){
        let selectedId = event.target.dataset.id;
        console.log('== event.target.dataset.id ', selectedId);

        this.dealerShipList.forEach(item => {
            if (item.Id == selectedId) {
                item.variant = 'brand';
            }else{
                item.variant = '';
            }
        });

        this.dispatchEvent(new CustomEvent("dealershipselect", {
            detail: {dealerShipId: selectedId}}));

    }

    handleMultiSelect(event){
        let multiSelectValue = event.detail.selectedQuesData;
        let parentSelectedMultiVal = [];
        parentSelectedMultiVal = JSON.parse( JSON.stringify(multiSelectValue));
        console.log('== parentSelectedMultiVal ', parentSelectedMultiVal);

        if(parentSelectedMultiVal && parentSelectedMultiVal.length > 0){
            this.isPinCodeSelected = true;

            this.dealerShipList = [];
            
            let tempDealerShipList = [];
            parentSelectedMultiVal.forEach(item => {
                tempDealerShipList = tempDealerShipList.concat(this.pincodeWithDealerMap[item]);
            });

            this.dealerShipList = tempDealerShipList;

            console.log('== Final DealerList ', this.dealerShipList);
            
            this.dealerShipList.forEach(item => {
                item.variant = '';
            });
            
        }else{
            this.isPinCodeSelected = false;
        }
        this.dispatchEvent(new CustomEvent("dealershipselect", {
            detail: {dealerShipId: null}}));
        
    }

    handleForCodeRemove() {
        console.log('== IN Handle For Code Remove');
        this.selectedForCodeRecord = undefined;
        this.selectedForCodeRecordId = undefined;
        this.forCodeRecords = undefined;
        this.error = undefined;
    }
}