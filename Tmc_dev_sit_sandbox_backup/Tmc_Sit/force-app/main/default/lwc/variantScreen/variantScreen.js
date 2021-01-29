/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import Base from 'c/addLineItemBase';
import { api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import Enq_Model from '@salesforce/schema/Opportunity.Model_Code__c';
import Variant_Changes_Count_Msg from '@salesforce/label/c.Variant_Changes_Count_Msg';

import retriveModelVarient from '@salesforce/apex/AddLineItemCtrl.retriveModelVarient';
import retriveColorVarient from '@salesforce/apex/AddLineItemCtrl.retriveColorVarient';
import retriveExShowroomPrice from '@salesforce/apex/AddLineItemCtrl.retriveExShowroomPrice';
import fetchVariantProducts from '@salesforce/apex/AddLineItemCtrl.fetchVariantProducts';
import retriveEnqModelList from '@salesforce/apex/AddLineItemCtrl.retriveEnqModelList';


export default class VariantScreen extends Base {
    @api recordId;
    @api deviceFormFactor;
    @api dealerForCodeId;

    @track records;
    @track error;

    @track colorOptions = [];
    @track colorName = '';

    @track subTotalAmount;
    @track financeAmountData;
    @track cashPaymentData;

    colorVarientsRecords = [];

    iconname = "standard:product";
    objectName = 'Product2';
    searchfield = 'Name';

    enquiryModelValue = '';    // If Enquiry Model is empty in database.
    @track enquiryModelOptions = [];

    @track allEnqModel = [];

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Enq_Model })
    enqModelValues({ data }) {
        if (data) {
            this.allEnqModel = data.values;
            console.log('== allEnqModel ', this.allEnqModel);
        }
    }

    handleEnquiryModelChange(event){
        this.enquiryModelValue = event.detail.value;
    }

    get showSaveHandle(){
        return this.state.selectedVariant ? true: false;
    }

    get hasEnquiryModel(){
        return (this.state.componentType && this.state.componentType === 'prebooking' && 
                this.state.opportunityInfo.Model_Code__c) ? true : false;
    }

    connectedCallback() {
        this.executeAction(retriveEnqModelList, {
            recordId: this.recordId
        }).then(result => {
            this.enquiryModelOptions = [];
            for(let i = 0; i<result.length; i++){
                let objInfo = {};
                objInfo.value = result[i];

                let eachValue = this.allEnqModel.find((item) => item.value === result[i]);
                if(eachValue){
                    objInfo.label = eachValue.label;
                }

                this.enquiryModelOptions.push(objInfo);
            }
            console.log('== Final value ', this.enquiryModelOptions);
        });
        this.setSavePoint();
        if (this.state.selectedVariant != null) {
            this.generateColorOptions(this.state.selectedVariant.Id);
            if(this.state.selectedColorVariant !== null){
                this.colorName = this.state.selectedColorVariant.Id;
            }
        }
        if (this.state.addSchemes != null) {
            this.financeAmountData = this.state.addSchemes.financeAmountData;
        }
        this.enquiryModelValue = this.state.opportunityInfo.Model_Code__c;
        this.calculateTotal();
    }

    handleOnchange(event) {
        const searchKey = event.detail.value;
        setTimeout(() => {
            this.executeAction(retriveModelVarient, {
                name: searchKey,
                modelName: this.enquiryModelValue,
                channel : this.state.opportunityInfo.dealerChannel
            }).then(result => {
                this.records = result;
            });
        });
    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
        this.setData({
            selectedVariant: this.selectedRecord,
            headerValue: this.state.headerValue.concat('Variant Name : ' + this.selectedRecord.Name)
        });
        //this.retriveOtherValidAmount();
        this.generateColorOptions(selectedRecordId);
    }

    generateColorOptions(selectedRecordId) {
        this.executeAction(retriveColorVarient, {
            productId: selectedRecordId
        }).then(result => {
            this.colorVarientsRecords = result;
            if (result.length > 0) {
                this.variantCode = result[0].Variant__r.ProductCode;
            }
            this.colorOptions = result.map(item => { return { value: item.Id, label: item.Name }; });
        });
    }

    handleRemove(event) {
        event.preventDefault();
        if(this.state.componentType && this.state.componentType === 'prebooking' && this.state.opportunityInfo.Variant_Modified_Count__c && this.state.opportunityInfo.Variant_Modified_Count__c > 1){
            this.showToast({ message: Variant_Changes_Count_Msg });
        }else{
            this.error = null;
            this.colorName = null;
            this.records = null;
            this.financeAmountData = 0;

            this.state.headerValue.pop();

            this.setData({
                selectedVariant: null,
                selectedColorVariant: null,
                exShowRoomVariant: { UnitPrice: 0 },
                registrationAmountVariant: { UnitPrice: 0 },
                addComponent: null,
                addAccessories: null,
                otherAccessoriesDiscount: { UnitPrice: 0 },
                otherCharge: { UnitPrice: 0 },
                consumerOffer : null,
                addSchemes: {
                    financeAmountData: 0,
                    cashPaymentData: 0,
                    corporateDiscountValue: false,
                    exchangeBonusValue: false,
                    exchangeValue: false,
                    ruralOffersValue: false,
                    otherDiscountValue: false,
                    OfferData: 0,
                    exchangeData: 0,
                    exchangeBonusData: 0,
                    corporateDiscountData: 0,
                    ruralDiscountData: 0,
                    otherDiscountData: 0
                }
            });
            this.calculateTotal();

        }

    }

    handleColorChange(event) {
        event.preventDefault();

        const selectedColorVarientRecord = this.colorVarientsRecords.find(record => record.Id === event.target.value);

        this.setData({ selectedColorVariant: selectedColorVarientRecord });

        this.colorName = selectedColorVarientRecord.Id;

        this.executeAction(retriveExShowroomPrice, {
            variantId: selectedColorVarientRecord.Variant__c,
            enquiryForCodeId: this.dealerForCodeId,
            paintType: selectedColorVarientRecord.Color_Type__c,
            enquirySalesType : this.state.opportunityInfo.Sales_Type__c
        }).then(result => {
            this.cashPaymentData = this.cashPaymentData || parseFloat(result).toFixed(2);
            this.setData({
                exShowRoomVariant: { UnitPrice: (result !== null || result !== '' || result > 0) ?  parseFloat(result, 10) : 0 },
                addSchemes: { cashPaymentData: this.cashPaymentData }
            });
            this.subTotalAmount = parseFloat(result).toFixed(2);
            if(this.state.exShowRoomVariant.UnitPrice < 1){
                this.showToast({ message: 'No Price Found.' });
            }
        });
    }

    handleRegistrationAmountChange(event) {
        this.setData({
            registrationAmountVariant: {
                UnitPrice: event.target.value || 0
            }
        });
        this.calculateTotal();
    }

    handleFinanceAmountChange(event) {
        this.financeAmountData = event.target.value || 0
        this.calculateTotal();
    }

    calculateTotal() {
        this.subTotalAmount = parseFloat(this.state.exShowRoomVariant.UnitPrice || 0) + parseFloat(this.state.registrationAmountVariant.UnitPrice || 0);
        this.cashPaymentData = parseFloat(this.subTotalAmount || 0) - parseFloat(this.financeAmountData || 0);
        this.setData({
            addSchemes: {
                financeAmountData: this.financeAmountData,
                cashPaymentData: this.cashPaymentData
            }
        });
    }

    showSummaryFromVariantCancel() {
        this.revert().dispatchEvent('variant');
    }

    handleSave() {
        if (this.reportValidity()) {
            
            /*Added on 22 Oct 2019 (By => Anuj)
            * Select Model from Enquiry Model field of Emquiry
            */
            this.setData({
                opportunityInfo: {
                    Model_Code__c : this.state.opportunityInfo.Model_Code__c || this.enquiryModelValue
                }
            });
        
            this.setData({
                exShowRoomVariant: { opporrtunityId: this.recordId },
                registrationAmountVariant: { opporrtunityId: this.recordId }
            });
            this.executeAction(fetchVariantProducts, { productId: this.state.selectedVariant.Id })
                .then(result => {
                    if (result === 'No PriceBook Found.') {
                        this.showToast({ message: 'No PriceBook Found.' });
                    } else {
                        this.setData({
                            exShowRoomVariant: { priceBookEntryId: result },
                            registrationAmountVariant: { priceBookEntryId: result }
                        });
                        this.commit().dispatchEvent('variant');
                    }
                });
        }
    }

    reportValidity() {
        return this.validateInputs('lightning-input') && this.validateInputs('lightning-combobox');
    }
}