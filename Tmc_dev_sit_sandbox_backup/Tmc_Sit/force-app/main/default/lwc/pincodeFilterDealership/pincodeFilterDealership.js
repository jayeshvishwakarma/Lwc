import { LightningElement, api, track } from 'lwc';

import fetchDealerWorkshopList from "@salesforce/apex/FetchLeadSurveyDetail.fetchDealerWorkshopList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
const actions = [{ label: 'Select Workshop', name: 'Select_Workshop' }];
export default class PincodeFilterDealership extends NavigationMixin(LightningElement) {
    // String type variables
    mainCss = ' slds-brand-band slds-brand-band_narrow slds-template_default forceBrandBand slds-p-vertical--none';
    // Undefined type variables
    @api forcodeinternallist;
    @api recordid;
    @api delaerrecordid;
    @api appointmentCmp;
    @api variantId;
    forCodeRecordId;
    forCodeName;
    dealerList;
    pinCodeArr;
    pincodeSet;

    // Array type variables
    pincodeSetOption = [];
    @track dealerShipList = [];
    forCodeFilteredList = [];

    // Boolean type variables
    forCodeData = false;
    showTable = false;
    cmpVisible = true;
    loading = false;
    isForCodeSelected = false;

    // Integer type variables
    optionLimit = 100;

    //Dealer Internal user related changes
    handleForCodeList(event) {
        try {
            this.forCodeFilteredList = [];
            if (event.detail.value) {
                let forCodeRec;
                forCodeRec = event.detail.value;
                if (forCodeRec.length > 2) {
                    forCodeRec = forCodeRec.toUpperCase();
                    // for (let i = 0; i < this.forcodeinternallist.length; i++) {
                    //     if ((this.forcodeinternallist[i].Name.toUpperCase()).startsWith(forCodeRec.toUpperCase())) {
                    //         this.forCodeFilteredList.push(this.forcodeinternallist[i]);
                    //     }
                    // }
                    this.forCodeFilteredList = this.forcodeinternallist.filter(obj => obj.Name.toUpperCase().startsWith(forCodeRec));
                }
            }
        } catch (error) {
            console.log('error---------->', error);
        }
    }

    handleForCodeSelection(event) {
        try {
            this.loading = true;
            this.forCodeData = true;
            this.showTable = false;
            this.forCodeRecordId = event.detail;
            this.dealerList =
                this.forCodeName = (this.forcodeinternallist.find(item => item.Id === event.detail).Name);
            this.pinCodeArr = [];
            fetchDealerWorkshopList({
                forCodeId: this.forCodeRecordId,
                variantId: this.variantId
            }).then(result => {
                if (result && result.length > 0) {
                    this.dealerList = result;
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].BillingPostalCode)
                            this.pinCodeArr.push(result[i].BillingPostalCode);
                    }
                    this.pincodeSet = [...new Set(this.pinCodeArr)];
                    this.pincodeSet.forEach(item => {
                        this.pincodeSetOption.push({ label: item, value: item })
                    });
                    this.isForCodeSelected = true;
                    this.loading = false;
                } else {
                    this.handleError('No Workshop is available for the selected For Code');
                    this.showTable = false;
                    this.loading = false;
                }
            }).catch(error => {
                console.log('error-------->', error);
                this.loading = false;
            })
        } catch (error) {
            console.log('errooo--------', error);
            this.loading = false;
        }
    }

    handleMultiSelect(event) {
        let parentSelectedMultiVal = [];
        parentSelectedMultiVal = JSON.parse(JSON.stringify(event.detail));
        if (parentSelectedMultiVal && parentSelectedMultiVal.length > 0) {
            this.dealerShipList = [];
            let tempDealerShipList = [];
            for (let i = 0; i < parentSelectedMultiVal.length; i++) {
                for (let j = 0; j < this.dealerList.length; j++) {
                    if (this.dealerList[j].BillingPostalCode === parentSelectedMultiVal[i]) {
                        const dealer = { "variant": "", ...this.dealerList[j] };
                        tempDealerShipList = tempDealerShipList.concat(dealer);
                    }
                }
            }
            this.dealerShipList = tempDealerShipList;
            this.showTable = true;
        } else {
            this.showTable = false;
        }
    }

    handleSelect(event) {
        let selectedId = event.target.dataset.id;
        let currentRecord;

        try {
            this.dealerShipList = this.dealerShipList.map(item => {
                if (item.Id == selectedId) {
                    currentRecord = item;
                    const selectedEvent = new CustomEvent("dealeridchange", {
                        detail: currentRecord
                    });
                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                    this.cmpVisible = false;
                    item.variant = 'brand';
                } else {
                    item.variant = '';
                }
                return item;
            });
        } catch (e) {
            console.error(e);
            console.error('e.name => ' + e.name);
            console.error('e.message => ' + e.message);
            console.error('e.stack => ' + e.stack);
        }
    }

    // This method is used for removal of For Code
    handleRemove(event) {
        try {
            this.isForCodeSelected = false;
            this.pincodeSetOption = [];
            event.preventDefault();
            this.showTable = false;
            this.forCodeName = '';
            this.forCodeRecordId = '';
            this.forCodeData = false;
            this.forCodeFilteredList = [];

        } catch (error) {
            console.log('errooo--------', error);
        }
    }

    // This method is used to close the LWC and navigate to record page
    cancel() {
        this.loading = true;
        if (this.appointmentCmp === 'true') {
            console.log('in if')
            const custEvent = new CustomEvent(
                'forclose', {
                detail: false
            });
            this.dispatchEvent(custEvent);
        } else {
            console.log('coming in else');
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.recordid,
                    objectApiName: "Lead", // objectApiName is optional
                    actionName: "view"
                }
            });
        }
        this.loading = false;
    }

    handleError(errmsg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: errmsg,
                variant: "error"
            })
        );
        this.loading = false;
    }

}