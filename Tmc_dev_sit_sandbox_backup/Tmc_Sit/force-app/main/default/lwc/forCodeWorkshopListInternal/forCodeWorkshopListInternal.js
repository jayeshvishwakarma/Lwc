import {
    LightningElement,
    api,track
} from 'lwc';

import fetchDealerWorkshopList from "@salesforce/apex/ServiceCalculator.fetchDealerWorkshopList";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    NavigationMixin
} from "lightning/navigation";

const actions = [{
    label: 'Select Workshop',
    name: 'Select_Workshop'
}

];
export default class ForCodeWorkshopListInternal extends NavigationMixin(LightningElement) {
    mainCss = ' slds-brand-band slds-brand-band_narrow slds-template_default forceBrandBand slds-p-vertical--none';
    @api forcodeinternallist;
    @api recordid;
    @api delaerrecordid;
    @api appointmentCmp;
    forCodeFilteredList = [];
    forCodeData = false;
    forCodeRecordId;
    forCodeName;
    dealerList;
    showTable = false;
    cmpVisible = true;
    loading = false;
    pinCodeArr;
    pincodeSet;
    isForCodeSelected = false;
    optionLimit = 100;
    pincodeSetOption = [];
    @track dealerShipList = [];
    
    columns = [{
        label: 'Dealer name',
        fieldName: 'Name',
        type: 'text',
        sortable: true,
        wrapText: true
    },
    {
        label: 'For Code',
        fieldName: 'For_Code__r.Name',
        type: 'text',
        sortable: true,
        wrapText: true
    },
    {
        label: 'Dealer Address',
        fieldName: 'Dealer_Address_F__c',
        type: 'Currency',
        sortable: true,
        wrapText: true
    }, {
        type: 'button', // Added under Inbound Calling change
        initialWidth: 150,
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'left',
            label: 'Select',
            title: 'Select',
            name: 'SelectWorkshop',
            value: 'SelectWorkshop',
            variant: 'brand'

        }
    }
    ];

    connectedCallback() {
        console.log('connectCallback');
        
        console.log('appointmentCmp------------------', this.appointmentCmp);
    }

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
            console.log('event.detail--------->' + event.detail);
            console.log('forcodeinternallist--------->', this.forcodeinternallist);
            this.forCodeData = true;
            this.showTable = false;
            this.forCodeRecordId = event.detail;
            this.dealerList =
                this.forCodeName = (this.forcodeinternallist.find(item => item.Id === event.detail).Name);
            console.log('forCodeName------>' + this.forCodeName);
            this.pinCodeArr = [];
            fetchDealerWorkshopList({
                forCodeId: this.forCodeRecordId
            }).then(result => {
                console.log('result-------->', result);
                if (result && result.length > 0) {
                    this.dealerList = result;
                    for(let i= 0;i<result.length;i++){
                        if(result[i].BillingPostalCode)
                        this.pinCodeArr.push(result[i].BillingPostalCode);
                    }
                    this.pincodeSet = [...new Set(this.pinCodeArr)];
                    console.log('-------this.pincodeSet---',this.pincodeSet);
                    this.pincodeSet.forEach(item => {
                        this.pincodeSetOption.push({label : item, value : item})
                    });
                    this.isForCodeSelected = true;
                    ///////////////////////////////////////////
                    //this.showTable = true;
                    /////////////////////////////////////////////
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

    handleMultiSelect(event){
        console.log('this.dealerList-------',this.dealerList);
        let multiSelectValue = event.detail.selectedQuesData;
        let parentSelectedMultiVal = [];
        parentSelectedMultiVal = JSON.parse( JSON.stringify(multiSelectValue));
        console.log('== parentSelectedMultiVal ', parentSelectedMultiVal);
        if(parentSelectedMultiVal && parentSelectedMultiVal.length > 0){
                //this.isPinCodeSelected = true;
                this.dealerShipList = [];
                let tempDealerShipList = [];
                for(let i =0 ;i<parentSelectedMultiVal.length;i++){
                    for(let j =0 ;j<this.dealerList.length;j++){
                        if(this.dealerList[j].BillingPostalCode === parentSelectedMultiVal[i]){
                            tempDealerShipList = tempDealerShipList.concat(this.dealerList[j]);
                        }
                    }
                }
                this.dealerShipList = tempDealerShipList;
                this.showTable = true;
                console.log('== this.showTable ', this.showTable);
                console.log('== Final DealerList ', this.dealerShipList);

                this.dealerShipList.forEach(item => {
                    item.variant = '';
                });
            }else{
                this.showTable = false;
            }
            console.log('this.dealerList again---------',this.dealerList);
    }

    handleSelect(event){
        let selectedId = event.target.dataset.id;
        console.log('== event.target.dataset.id ', selectedId);
        let currentRecord;
        this.dealerList.forEach(item => {
            if (item.Id == selectedId) {
                currentRecord = item;
                item.variant = 'brand';
                const selectedEvent = new CustomEvent("dealeridchange", {
                    detail: currentRecord
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
                this.cmpVisible = false;
            }else{
                item.variant = '';
            }
        });
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
            console.log('this.forCodeData -------->', this.forCodeData);

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
                'forclose',{
                   detail : false 
                });
                this.dispatchEvent(custEvent);
        } else {
            console.log('coming in else');
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.recordid,
                    objectApiName: "Account", // objectApiName is optional
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