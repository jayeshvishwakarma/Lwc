/*eslint-disable no-console */
import Base from 'c/addLineItemBase';
import { track, api, wire } from 'lwc';

import createLineItemRecords from '@salesforce/apex/AddLineItemCtrl.createLineItemRecords';
import generateQuotation from '@salesforce/apex/AddLineItemCtrlHelper.generateQuotation';
import retriveOpportunityAmount from '@salesforce/apex/AddLineItemCtrl.retriveOpportunityAmount';

import retriveQuoteTemplateInfo from '@salesforce/apex/EmailQuotePDFCtrl.retriveQuoteTemplateInfo';

import Refresh_Amount_Msg from '@salesforce/label/c.Refresh_Amount_Msg';
import Server_Error from '@salesforce/label/c.Server_Error';
import Tax_Amount from '@salesforce/label/c.Tax_Amount';
import Loyalty_Amount from '@salesforce/label/c.Loyalty_Amount';



import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Interested_In_Loyalty from '@salesforce/schema/Opportunity.Interested_In_Loyalty__c';
import Reason_not_Interested_in_Loyalty from '@salesforce/schema/Opportunity.Reason_not_Interested_in_Loyalty__c';
import COMM_POINT_BAL from '@salesforce/schema/Opportunity.Customer__r.COMM_Points_Balance__c';
import COMM_AVAIL_BONUS from '@salesforce/schema/Opportunity.Customer__r.COMM_Available_Bonus__c';
import COMM_TIER from '@salesforce/schema/Opportunity.Customer__r.COMM_Tier__c';
import POINT_BAL from '@salesforce/schema/Opportunity.Customer__r.Points_Balance__c';
import AVAIL_BONUS from '@salesforce/schema/Opportunity.Customer__r.Available_Bonus__c';
import TIER from '@salesforce/schema/Opportunity.Customer__r.Tier__c';


import { getRecord } from 'lightning/uiRecordApi';

const fields = [
    'Account.Tier__c',
    'Account.Points_Balance__c',
    'Account.Available_Bonus__c',
    'Account.COMM_Tier__c',
    'Account.COMM_Points_Balance__c',
    'Account.COMM_Available_Bonus__c'
];

export default class SummaryScreen extends Base {
    @api stage;

    @track showSchemeOffer = false;
    @track vehicleSubTotal = 0.0;
    @track componentSubTotal = 0.0;
    @track accessoriesSubTotal = 0.0;
    //Added by Prabhat on request by Rajesh (To show the subtotal for Offers)
    @track offersSubTotal = 0.0;
    @track totalOnRoadPrice = 0.0;

    Corporate_Offers_editable = false;
    Exchange_Bonus_editable = false;
    Exchange_Value_editable = false;
    Rural_Offers_editable = false;

    updated_AddComponent = [];
    extended_Warranty_Tax;
    loyalty_Tax = 0;



    // Added By Deepak for loyalty
    constantObj = {};

    customerId = this.state.opportunityInfo.Customer__c;
    /*
    @wire(getRecord, { recordId: '$customerId', fields })
    customer({ error, data }) {
        if (data) {
            if(this.state.opportunityInfo.Loyalty_Program_Type__c && this.state.opportunityInfo.Loyalty_Program_Type__c === 'Pragati'){
                this.tier =  data.fields.COMM_Tier__c.value;
                this.pointBalance =  data.fields.COMM_Points_Balance__c.value;
                this.loyaltyBonus =  data.fields.COMM_Available_Bonus__c.value;
            }else{
                this.tier =  data.fields.Tier__c.value;
                this.pointBalance =  data.fields.Points_Balance__c.value;
                this.loyaltyBonus =  data.fields.Loyalty_Bonus__c.value;
            }
        } else if (error) {
            console.log(JSON.stringify(error));
            console.log('Customer is Not accessible');
        }
        this.setLoyaltyBonusConditional();
        this.calculateCashPaymentAmount();
    }
    */

    /** Interested In loyalty Section Start */
    // showLoyaltyInterestTemp = this.state.opportunityInfo.Interested_In_Loyalty__c ? false:true;
    @track tier;
    @track isInterestedInLoyaltyShow = true;
    @track showLoyaltyInterest = this.state.componentType == "prebooking" ? true : false;
    @track interestedInLoyaltyOptions;
    @track reasonNotInterestedInLoyaltyOptions;
    @track copyOfReasonNotInterestedInLoyaltyOptions;
    @track reasonRequired = false;
    @track reasonDisabled = true;
    components = [
        { label: 'Extended Warranty', value: '', isChecked: false, isExchangedWarrenty: true, showLabel: false, isDisabled: true, year: '', showCheckBox: false },
        { label: 'Loyalty', value: '', isChecked: false, showLabel: true, isDisabled: true, showCheckBox: true },
        { label: 'Insurance', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'Municipal Charges', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'FASTag charges', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'Road Tax', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'MCP', value: '', isChecked: false, isMCP: true, showLabel: false, isDisabled: true, packageValue: '', validityValue: '', showCheckBox: false, amount: 0 },
    ];

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Interested_In_Loyalty })
    interestedInLoyaltyValues({ data }) {
        if (data) {
            this.interestedInLoyaltyOptions = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Reason_not_Interested_in_Loyalty })
    reasonNotInterestedInLoyaltyValues({ data }) {
        if (data) {
            this.copyOfReasonNotInterestedInLoyaltyOptions = data.values;
            this.reasonNotInterestedInLoyaltyOptions = data.values;
        }
    }
    handleInterestedInLoyaltyChange(event) {
        try {
            if (event.detail.value == this.constantObj.NotPitchedConst && (this.state.addSchemes.interestedInLoyaltyData === this.constantObj.YesConst || this.state.addSchemes.interestedInLoyaltyData === this.constantObj.NoConst)) {
                let message = 'You are not allowed to select Not Pitched if you have chosen Yes/No in Interested in Loyalty';
                this.showToast({ message: message });
                this.isInterestedInLoyaltyShow = false;
                setTimeout(f => {
                    this.isInterestedInLoyaltyShow = true;
                }, 0);
                return;
            }
            this.state.addSchemes.interestedInLoyaltyData = event.detail.value;
            this.state.addSchemes.interestedInLoyaltyDataTemp = event.detail.value;


            if (this.constantObj.NoConst === event.detail.value || this.constantObj.NotPitchedConst === event.detail.value) {
                this.reasonRequired = true;
                this.reasonDisabled = false;
                this.reasonNotInterestedInLoyaltyOptions = this.copyOfReasonNotInterestedInLoyaltyOptions;
            } else {
                this.reasonRequired = false;
                this.reasonDisabled = true;
                this.reasonNotInterestedInLoyaltyOptions = [];
                this.state.addSchemes.reasonNotInterestedLoyalty = null;
                this.state.addSchemes.reasonNotInterestedLoyaltyTemp = null;
            }
            if (this.state.opportunityInfo.StageName === 'New') {
                // Add the logic to check and unCheck the Loyalty box
                this.updateLoyaltyCheckBoxCheck(event.detail.value);

            }
        } catch (e) {
            console.log(e.message);
        }
    }
    handleReasonChange(event) {
        try {
            this.state.addSchemes.reasonNotInterestedLoyalty = event.detail.value;
            this.state.addSchemes.reasonNotInterestedLoyaltyTemp = event.detail.value;
        } catch (e) {
            console.log(e.message);
        }
    }

    updateLoyaltyCheckBoxCheck(interestedInLoyalty) {
        if (this.state.addComponent === null || this.state.addComponent === undefined) {
            this.state.addComponent = this.components;
        }
        const loyaltyChkBoxObj = this.state.addComponent.find(({ label }) => label === 'Loyalty');
        const loyaltyChkBoxObjIndex = this.state.addComponent.findIndex(label => label === "Loyalty");
        if (loyaltyChkBoxObj && loyaltyChkBoxObjIndex) {
            if (interestedInLoyalty === this.constantObj.YesConst) {
                loyaltyChkBoxObj.isChecked = true;
            } else {
                loyaltyChkBoxObj.isChecked = false;
            }
        }
        this.state.addComponent[loyaltyChkBoxObjIndex] = loyaltyChkBoxObj;
        this.conditionalConnectedCallBack();

        //this.setData({ addComponent: this.state.addComponent });
    }
    setLoyaltyDetails() {
        if (!this.state.addSchemes.interestedInLoyaltyDataTemp) {
            this.state.addSchemes.interestedInLoyaltyData = this.state.addSchemes.interestedInLoyaltyDataTemp;
        }
        if (!this.state.addSchemes.reasonNotInterestedLoyaltyTemp) {
            this.state.addSchemes.reasonNotInterestedLoyalty = this.state.addSchemes.reasonNotInterestedLoyaltyTemp;
        }
        if (this.state.addSchemes.reasonNotInterestedLoyalty) {
            this.reasonDisabled = false;
        }
        if (this.state.opportunityInfo.Interested_In_Loyalty__c) {
            if (this.state.opportunityInfo.Interested_In_Loyalty__c === this.constantObj.YesConst || this.state.opportunityInfo.Interested_In_Loyalty__c === this.constantObj.EnrolledInLoyaltyConst) {
                this.updateLoyaltyCheckBoxCheck(this.constantObj.YesConst);
            }
            else {
                this.updateLoyaltyCheckBoxCheck(this.constantObj.NoConst);
            }
            this.state.addSchemes.interestedInLoyaltyData = this.state.opportunityInfo.Interested_In_Loyalty__c;
            this.state.addSchemes.interestedInLoyaltyDataTemp = this.state.opportunityInfo.Interested_In_Loyalty__c;
            this.state.opportunityInfo.Interested_In_Loyalty__c = null;
        }
        if (this.state.opportunityInfo.Reason_not_Interested_in_Loyalty__c) {
            this.state.addSchemes.reasonNotInterestedLoyalty = this.state.opportunityInfo.Reason_not_Interested_in_Loyalty__c;
            this.state.opportunityInfo.Reason_not_Interested_in_Loyalty__c = null;
        }
        if (this.state.opportunityInfo.Reason_not_Interested_in_Loyalty) {
            this.state.addSchemes.reasonNotInterestedLoyalty = this.state.opportunityInfo.Reason_not_Interested_in_Loyalty;
            this.state.opportunityInfo.Reason_not_Interested_in_Loyalty = null;
        }
        if (this.state.addSchemes.interestedInLoyaltyData === this.constantObj.NoConst || this.state.addSchemes.interestedInLoyaltyData === this.constantObj.NotPitchedConst) {
            this.reasonDisabled = false;
            this.reasonRequired = true;
        }


    }
    /** Interested In loyalty Section End */

    /** Loyalty Redemption Section Start */
    @track showLoyaltyRedeem = this.state.componentType == "prebooking" ? true : false;
    @track pointBalance;
    @track pointsToBeRedeemed = 0;

    pointsToBeRedeemedChange(event) {
        this.pointsToBeRedeemed = event.detail.value;
    }
    /** Loyalty Redemption Section End */
    /** Loyalty Bonus for Create Quote Section Start */
    @track showLoyaltyBonus = false;
    @track loyaltyBonus;
    setLoyaltyBonusConditional() {
        this.state.loyaltyBonus.loyaltyBonusValid = false;
        this.state.loyaltyBonus.loyaltyBonusAmount = 0;
        // this.state.componentType === 'quote' &&
        if (this.state.offerFieldsConfiguration.Query_Loyalty_Bonus__c &&
            !this.state.offerFieldsConfiguration.Loyalty_Bonus_Editable__c) {
            if (this.loyaltyBonus && this.loyaltyBonus > 0 && this.tier) {
                this.showLoyaltyBonus = true;
                this.state.loyaltyBonus.loyaltyBonusValid = true;
                this.state.loyaltyBonus.loyaltyBonusAmount = this.loyaltyBonus;
            }
        }
    }
    /** Loyalty Bonus for Create Quote Section End */
    connectedCallback() {
        console.log('== Summary Screen ', this.state);
        this.constantObj = this.state.constantObj;
        this.setLoyaltyDetails();
        this.conditionalConnectedCallBack();
    }
    conditionalConnectedCallBack() {
        try {
            //#DE622 Start
            if (this.state) {
                this.setDefaulOppValues(this.state);
            }
            //#DE622 End
            this.populateAddComponentFields();
            this.populateOfferFieldsConfigurationFields();
            this.calculateVehicleSubTotal();
            this.calculateComponentSubTotal();
            this.calculateAddAccessoriesSubTotal();
            this.calculateOffersSubTotal();
            this.calculateTotalOnRoadPrice();
            this.calculateCashPaymentAmount();
            this.calculateTotalAmount();
        } catch (e) {
            console.log(e.message);
        }

    }
    populateAddComponentFields() {
        let taxAmount = !isNaN(Tax_Amount) ? Tax_Amount : 0;
        let addComponentTemp = JSON.parse(JSON.stringify(this.state.addComponent));
        if (addComponentTemp) {
            this.updated_AddComponent = [];
            for (let i = 0; i < addComponentTemp.length; i++) {
                if (addComponentTemp[i].label === 'Extended Warranty') {
                    let extendWarrantValue = addComponentTemp[i].value;
                    this.extended_Warranty_Tax = (taxAmount > 0 ? parseFloat((extendWarrantValue * taxAmount) / 100) : 0);
                    addComponentTemp[i].value = parseFloat(extendWarrantValue) + this.extended_Warranty_Tax;
                    // addComponentTemp[i].value = parseFloat(extendWarrantValue);
                }
                // Simple loyalty Population
                if (addComponentTemp[i].label === 'Loyalty') {
                    let loyaltyValue = parseFloat(Loyalty_Amount); // Updating Loyalty Amount
                    this.loyalty_Tax = (taxAmount > 0 ? parseFloat((loyaltyValue * taxAmount) / 100) : 0);
                    addComponentTemp[i].value = parseFloat(loyaltyValue) + this.loyalty_Tax;
                    this.state.addComponent[i].value = loyaltyValue;
                }
                if (this.state.addSchemes.interestedInLoyaltyData === this.constantObj.YesConst || this.state.addSchemes.interestedInLoyaltyData === this.constantObj.EnrolledInLoyaltyConst) {
                    if (addComponentTemp[i].label === 'Loyalty' && !this.tier) { //tier can be removed
                        let loyaltyValue = parseFloat(Loyalty_Amount); // Updating Loyalty Amount
                        this.loyalty_Tax = (taxAmount > 0 ? parseFloat((loyaltyValue * taxAmount) / 100) : 0);
                        addComponentTemp[i].value = parseFloat(loyaltyValue) + this.loyalty_Tax;
                        this.state.addComponent[i].value = loyaltyValue;
                    }
                }
                if (addComponentTemp[i].label === 'Loyalty') {
                    // FOR COMMERCIAL
                    if (this.state.opportunityInfo.Loyalty_Program_Type__c && this.state.opportunityInfo.Loyalty_Program_Type__c === 'Pragati') {
                        this.state.addComponent[i].value = 0.0;
                        addComponentTemp[i].value = 0.0;
                    }
                }
            }
            this.updated_AddComponent = addComponentTemp;
        }

    }
    populateOfferFieldsConfigurationFields() {
        if (this.state.offerFieldsConfiguration) {
            let offer_fields = Object.keys(this.state.offerFieldsConfiguration);
            this.Corporate_Offers_editable = offer_fields.includes('Corporate_Offers__c') ? this.state.offerFieldsConfiguration.Corporate_Offers__c : false;
            this.Exchange_Bonus_editable = offer_fields.includes('Exchange_Bonus__c') ? this.state.offerFieldsConfiguration.Exchange_Bonus__c : false;
            this.Exchange_Value_editable = offer_fields.includes('Exchange_Value__c') ? this.state.offerFieldsConfiguration.Exchange_Value__c : false;
            this.Rural_Offers_editable = offer_fields.includes('Rural_Offers__c') ? this.state.offerFieldsConfiguration.Rural_Offers__c : false;
        }
    }
    calculateVehicleSubTotal() {
        this.vehicleSubTotal = parseFloat(this.state.exShowRoomVariant.UnitPrice, 10);
        this.vehicleSubTotal = this.vehicleSubTotal + parseFloat(this.state.registrationAmountVariant.UnitPrice, 10);
    }
    calculateComponentSubTotal() {
        let taxAmount = !isNaN(Tax_Amount) ? Tax_Amount : 0;
        this.componentSubTotal = this.state.otherCharge.UnitPrice != null ? parseFloat(this.state.otherCharge.UnitPrice, 10) : 0;
        if (this.state.addComponent !== null && this.state.addComponent.length > 0) {
            let totalAmount = 0;
            for (let i = 0; i < this.state.addComponent.length; i++) {
                if (this.state.addComponent[i].isChecked && this.state.addComponent[i].value && this.state.addComponent[i].value !== 'null') {
                    if (this.state.addComponent[i].label === 'Extended Warranty') {
                        this.extended_Warranty_Tax = (taxAmount > 0 ? parseFloat((this.state.addComponent[i].value * taxAmount) / 100) : 0);
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.extended_Warranty_Tax);
                    } else if (this.state.addComponent[i].label === 'Loyalty' && this.state.opportunityInfo.Loyalty_Program_Type__c && this.state.opportunityInfo.Loyalty_Program_Type__c !== 'Pragati') {

                        this.loyalty_Tax = (taxAmount > 0 ? parseFloat((this.state.addComponent[i].value * taxAmount) / 100) : 0);
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.loyalty_Tax);
                    } else {
                        totalAmount = totalAmount + parseFloat(this.state.addComponent[i].value, 10);
                    }
                }
            }
            this.componentSubTotal += totalAmount;
        } else {
            this.componentSubTotal = 0.0;
        }
    }
    calculateAddAccessoriesSubTotal() {
        if (this.state.addAccessories !== null && this.state.addAccessories.length > 0) {
            let totalAmount = 0;
            for (let i = 0; i < this.state.addAccessories.length; i++) {
                totalAmount = totalAmount + parseFloat(this.state.addAccessories[i].price, 10);
            }
            this.accessoriesSubTotal = totalAmount - parseFloat(this.state.otherAccessoriesDiscount.UnitPrice, 10);
        } else {
            this.accessoriesSubTotal = 0.0;
        }
    }
    calculateOffersSubTotal() {
        this.offersSubTotal = this.state.addSchemes.OfferData +
            (this.state.addSchemes.corporateDiscountValue ? this.state.addSchemes.corporateDiscountData : 0) +
            (this.state.addSchemes.exchangeBonusValue ? this.state.addSchemes.exchangeBonusData : 0) +
            (this.state.addSchemes.exchangeValue ? this.state.addSchemes.exchangeData : 0) +
            (this.state.addSchemes.ruralOffersValue ? this.state.addSchemes.ruralDiscountData : 0) +
            (this.state.addSchemes.otherDiscountValue ? this.state.addSchemes.otherDiscountData : 0);
    }
    calculateTotalOnRoadPrice() {
        this.totalOnRoadPrice = (this.vehicleSubTotal + this.componentSubTotal + this.accessoriesSubTotal) - this.offersSubTotal;
    }
    setDefaulOppValues(state) {
        this.state.addSchemes.firstName = state.opportunityInfo.First_Name__c;
        this.state.addSchemes.lastName = state.opportunityInfo.Last_Name__c;
        this.state.addSchemes.middleName = state.opportunityInfo.Middle_Name__c;
        this.state.addSchemes.phoneNumber = state.opportunityInfo.Mobile__c;

        if (this.state.opportunityInfo.Loyalty_Program_Type__c && this.state.opportunityInfo.Loyalty_Program_Type__c === 'Pragati') {
            this.tier = this.state.opportunityInfo.COMM_Tier__c;
            this.pointBalance = this.state.opportunityInfo.COMM_Points_Balance__c;
            this.loyaltyBonus = this.state.opportunityInfo.COMM_Available_Bonus__c;
        } else {
            this.tier = this.state.opportunityInfo.Tier__c;
            this.pointBalance = this.state.opportunityInfo.Points_Balance__c;
            this.loyaltyBonus = this.state.opportunityInfo.Loyalty_Bonus__c;
        }
        this.setLoyaltyBonusConditional();
    }
    //#DE622 Start
    handleOppChange(event) {
        // eslint-disable-next-line default-case
        switch (event.target.name) {
            case 'FIRST_NAME':
                this.state.addSchemes.firstName = event.target.value;
                break;
            case 'LAST_NAME':
                this.state.addSchemes.lastName = event.target.value;
                break;
            case 'MIDDLE_FIELD':
                this.state.addSchemes.middleName = event.target.value;
                break;
            case 'MOBILE_FIELD':
                this.state.addSchemes.phoneNumber = event.target.value;
                break;
        }
    }

    @track showVehicle = false;
    @track showComponent = false;
    @track showAccessories = false;
    @track showOffer = false;

    get remarksRequired() {
        return this.state.otherCharge.UnitPrice > 0 ? true : false;
    }

    get showCreateQuotation() {
        return (this.state.opportunityInfo.StageName && this.state.opportunityInfo.StageName === 'New' &&
            this.state.componentType && this.state.componentType === 'quote' &&
            this.state.selectedVariant && this.state.exShowRoomVariant.UnitPrice &&
            this.state.exShowRoomVariant.UnitPrice !== 0) ? true : false;
    }

    get showPreBooking() {
        return (this.state.opportunityInfo.StageName && this.state.opportunityInfo.StageName === 'New' &&
            this.state.componentType && this.state.componentType === 'prebooking' &&
            this.state.selectedVariant && this.state.exShowRoomVariant.UnitPrice &&
            this.state.exShowRoomVariant.UnitPrice !== 0) ? true : false;
    }

    showHideVehicleSection() {
        this.showVehicle = !this.showVehicle;
    }

    showHideComponentSection() {
        this.populateAddComponentFields();
        this.showComponent = !this.showComponent;
    }

    showHideAccessoriesSection() {
        this.showAccessories = !this.showAccessories;
    }

    showHideOfferSection() {
        this.showOffer = !this.showOffer;
    }

    showVehicleCmp() {
        this.dispatchEvent('vehicle');
    }

    showSchemeOfferCmp() {
        if (this.validateVariant()) {
            this.dispatchEvent('select');
        }
    }

    showAccessoriescmp() {
        if (this.validateVariant()) {
            this.dispatchEvent('accessories');
        }
    }

    showComponents() {
        if (this.validateVariant()) {
            this.dispatchEvent('components');
        }
    }

    validateVariant() {
        if (!this.state.selectedVariant) {
            this.showToast({ message: 'Please Select Variant First!' });
            return false;
        }
        return true;
    }

    handleComponanetChange(event) {
        if (!isNaN(parseFloat(event.target.value))) {
            event.target.value = parseFloat(event.target.value);
        }
        for (let i = 0; i < this.state.addComponent.length; i++) {
            if (this.state.addComponent[i].label === event.target.name)
                this.state.addComponent[i].value = event.target.value;
        }

        this.calculateAddComponentSubTotal();
        this.calculateTotalAmount();
    }

    // Handle On Change Events
    handleData(event) {
        //Added by Prabhat 16-August-2019 -- To show the subtotal for offers
        if (!isNaN(parseFloat(event.target.value))) {
            event.target.value = parseFloat(event.target.value);
        }

        //Added by Prabhat - 19 Aug 2019 (Show total on raod price after reducing offer sub total)
        let proTyname = event.target.name;
        let addSchemesUsedAmountData = parseFloat(event.target.value, 10);
        if (proTyname === 'OfferData') {
            this.setData({ addSchemes: { OfferData: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'exchangeData') {
            this.setData({ addSchemes: { exchangeData: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'otherDiscountData') {
            this.setData({ addSchemes: { otherDiscountData: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }

        if (proTyname === 'exchangeBonusData') {
            this.setData({ addSchemes: { exchangeBonusData: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'corporateDiscountData') {
            this.setData({ addSchemes: { corporateDiscountData: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'ruralDiscountData') {
            this.setData({ addSchemes: { ruralDiscountData: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }

        if (proTyname === 'acquisitionDiscount') {
            this.setData({ addSchemes: { acquisitionDiscount: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'loyaltyDiscount') {
            this.setData({ addSchemes: { loyaltyDiscount: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }

        if (proTyname === 'bulkDiscount') {
            this.setData({ addSchemes: { bulkDiscount: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }

        if (proTyname === 'specialDiscount') {
            this.setData({ addSchemes: { specialDiscount: !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }

        if (proTyname === 'otherCharge') {

            let otherChargeAmount = parseFloat(event.target.value, 10);
            this.setData({
                otherCharge: { UnitPrice: !isNaN(otherChargeAmount) > 0 ? otherChargeAmount : 0 }
            });
            this.vehicleSubTotal = parseFloat(this.state.exShowRoomVariant.UnitPrice, 10);
            this.vehicleSubTotal = this.vehicleSubTotal + parseFloat(this.state.registrationAmountVariant.UnitPrice, 10);

            this.calculateAddComponentSubTotal();
        }

        this.calculateTotalAmount();
    }

    handleRemarksData(event) {
        this.setData({
            otherCharge: { Description: event.target.value }
        });
    }

    calculateAddComponentSubTotal() {
        this.componentSubTotal = parseFloat(this.state.otherCharge.UnitPrice, 10);

        if (this.state.addComponent !== null && this.state.addComponent.length > 0) {

            let totalAmount = 0;
            for (let i = 0; i < this.state.addComponent.length; i++) {
                if (this.state.addComponent[i].isChecked && this.state.addComponent[i].value !== '') {
                    if (this.state.addComponent[i].label === 'Extended Warranty') {
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.extended_Warranty_Tax);
                    } else if (this.state.addComponent[i].label === 'Loyalty' && this.state.opportunityInfo.Loyalty_Program_Type__c && this.state.opportunityInfo.Loyalty_Program_Type__c !== 'Pragati') {
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.loyalty_Tax);
                    } else {
                        totalAmount = totalAmount + parseFloat(this.state.addComponent[i].value, 10);
                    }
                }
            }
            this.componentSubTotal += totalAmount;
        }
    }

    calculateRegistrationAmount(event) {
        let registrationAmount = parseFloat(event.target.value, 10);
        this.setData({
            registrationAmountVariant: { UnitPrice: !isNaN(registrationAmount) > 0 ? registrationAmount : 0 }
        });

        this.vehicleSubTotal = parseFloat(this.state.exShowRoomVariant.UnitPrice, 10);
        this.vehicleSubTotal = this.vehicleSubTotal + parseFloat(this.state.registrationAmountVariant.UnitPrice, 10);

        this.componentSubTotal = parseFloat(this.state.otherCharge.UnitPrice, 10);

        if (this.state.addComponent !== null && this.state.addComponent.length > 0) {

            let totalAmount = 0;
            for (let i = 0; i < this.state.addComponent.length; i++) {
                if (this.state.addComponent[i].isChecked && this.state.addComponent[i].value !== '') {
                    if (this.state.addComponent[i].label === 'Extended Warranty') {
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.extended_Warranty_Tax);
                    } else if (this.state.addComponent[i].label === 'Loyalty') {
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.loyalty_Tax);
                    } else {
                        totalAmount = totalAmount + parseFloat(this.state.addComponent[i].value, 10);
                    }
                }
            }

            this.componentSubTotal += totalAmount;
        }
        if (this.state.addAccessories !== null && this.state.addAccessories.length > 0) {

            let totalAmount = 0;
            for (let i = 0; i < this.state.addAccessories.length; i++) {
                totalAmount = totalAmount + parseFloat(this.state.addAccessories[i].price, 10);
            }
            this.accessoriesSubTotal = totalAmount - parseFloat(this.state.otherAccessoriesDiscount.UnitPrice, 10);
        }
        this.offersSubTotal = this.state.addSchemes.OfferData +
            (this.state.addSchemes.corporateDiscountValue ? this.state.addSchemes.corporateDiscountData : 0) +
            (this.state.addSchemes.exchangeBonusValue ? this.state.addSchemes.exchangeBonusData : 0) +
            (this.state.addSchemes.exchangeValue ? this.state.addSchemes.exchangeData : 0) +
            (this.state.addSchemes.ruralOffersValue ? this.state.addSchemes.ruralDiscountData : 0) +
            (this.state.addSchemes.otherDiscountValue ? this.state.addSchemes.otherDiscountData : 0) +
            (this.state.addSchemes.acquisitionDiscountValue ? this.state.addSchemes.acquisitionDiscount : 0) +
            (this.state.addSchemes.loyaltyDiscountValue ? this.state.addSchemes.loyaltyDiscount : 0) +
            (this.state.addSchemes.bulkDiscountValue ? this.state.addSchemes.bulkDiscount : 0) +
            (this.state.addSchemes.specialDiscountValue ? this.state.addSchemes.specialDiscount : 0);

        this.totalOnRoadPrice = (this.vehicleSubTotal + this.componentSubTotal + this.accessoriesSubTotal) - this.offersSubTotal;
    }

    calculateTotalAmount() {
        this.offersSubTotal = this.state.addSchemes.OfferData +
            (this.state.addSchemes.corporateDiscountValue ? this.state.addSchemes.corporateDiscountData : 0) +
            (this.state.addSchemes.exchangeBonusValue ? this.state.addSchemes.exchangeBonusData : 0) +
            (this.state.addSchemes.exchangeValue ? this.state.addSchemes.exchangeData : 0) +
            (this.state.addSchemes.ruralOffersValue ? this.state.addSchemes.ruralDiscountData : 0) +
            (this.state.addSchemes.otherDiscountValue ? this.state.addSchemes.otherDiscountData : 0) +
            (this.state.addSchemes.acquisitionDiscountValue ? this.state.addSchemes.acquisitionDiscount : 0) +
            (this.state.addSchemes.loyaltyDiscountValue ? this.state.addSchemes.loyaltyDiscount : 0) +
            (this.state.addSchemes.bulkDiscountValue ? this.state.addSchemes.bulkDiscount : 0) +
            (this.state.addSchemes.specialDiscountValue ? this.state.addSchemes.specialDiscount : 0);


        this.totalOnRoadPrice = (this.vehicleSubTotal + this.componentSubTotal + this.accessoriesSubTotal) - this.offersSubTotal;
        this.calculateCashPaymentAmount();
    }

    // To check the selected component have value greater than Zero.
    validatePhoneNumber() {
        let validData = false;
        let errorMsg = '';
        let validationObj = {};
        let phoneNum = this.state.addSchemes.phoneNumber.trim();
        if (phoneNum == '' || phoneNum.length == 0) {
            errorMsg = 'Please Enter Mobile Number.'
            validData = false;
        } else {
            errorMsg = ''
            validData = true;
        }
        validationObj.isDataValid = validData;
        validationObj.errorMsg = errorMsg;
        return validationObj;
    }

    // To check the selected component have value greater than Zero.
    validateOtherChargeRemarks() {
        let notValidFields = '';
        let validData = true;
        let validationObj = {};

        if (this.state.otherCharge.UnitPrice && this.state.otherCharge.UnitPrice > 0 && !this.state.otherCharge.Description) {
            notValidFields += 'Other Charges Remarks ,';
            validData = false;
        }

        if (notValidFields.length > 0) {
            notValidFields = notValidFields.slice(0, -1);
        } else {
            validData = true;
        }
        validationObj.isDataValid = validData;
        validationObj.errorFields = notValidFields;
        return validationObj;
    }

    // To check the selected component have value greater than Zero.
    validateAddComponentsFields() {
        let notValidFields = '';
        let validData = true;
        let validationObj = {};
        if (this.state.addComponent) {
            for (let i = 0; i < this.state.addComponent.length; i++) {
                let singleComp = this.state.addComponent[i];
                if (singleComp.isChecked && singleComp.label !== 'Extended Warranty' && singleComp.label !== 'Loyalty' && singleComp.label !== 'MCP') {
                    let singleCompValue = singleComp.value ? parseFloat(singleComp.value, 10) : 0;
                    if (singleCompValue > 0) {
                        validData = true;
                    } else {
                        notValidFields += singleComp.label + ',';
                        validData = false;
                    }
                }
            }
        }

        if (notValidFields.length > 0) {
            notValidFields = notValidFields.slice(0, -1);
        } else {
            validData = true;
        }
        validationObj.isDataValid = validData;
        validationObj.errorFields = notValidFields;
        return validationObj;
    }

    // To check the selected schemes and offer have value greater than Zero.
    validateAddSchemesFields() {
        let notValidFields = '';
        let validData = true;
        let validationObj = {};
        if (this.state.addSchemes.exchangeValue) {
            let exchangeValue = this.state.addSchemes.exchangeData ? parseFloat(this.state.addSchemes.exchangeData, 10) : 0;
            if (exchangeValue > 0) {
                validData = true;
            } else {
                if (this.Exchange_Value_editable) {
                    notValidFields += ' Exchange Value, ';
                    validData = false;
                } else {
                    validData = true;
                }
            }
        }

        if (this.state.addSchemes.otherDiscountValue) {
            let otherDisValue = this.state.addSchemes.otherDiscountData ? parseFloat(this.state.addSchemes.otherDiscountData, 10) : 0;
            if (otherDisValue > 0) {
                validData = true;
            } else {
                notValidFields += 'Other Discount, ';
                validData = false;
            }
        }

        if (notValidFields.length > 0) {
            notValidFields = notValidFields.slice(0, -1);
        } else {
            validData = true;
        }
        validationObj.isDataValid = validData;
        validationObj.errorFields = notValidFields;
        return validationObj;
    }

    //To Check the Interested In Loyalty and Reason if no
    validateInterestedInLoyalty() {
        const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }
    //To Check the Loyalty Redeem validations
    validateLoyaltyRedemption() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

    createQuotationMethod() {

        let inputCmp = this.template.querySelectorAll(".inputCmp");
        let validData = true;
        for (let i = 0; i < inputCmp.length; i++) {
            let tempInputCmp = inputCmp[i];
            if (tempInputCmp.value > tempInputCmp.max) {
                validData = false;
                tempInputCmp.setCustomValidity("The number is too high.");
            }
            tempInputCmp.reportValidity();
        }
        //check if add cmp fields are valid
        let validationRes = this.validateAddComponentsFields();
        let validateOffer = this.validateAddSchemesFields();
        let validateOtherChargeRemarks = this.validateOtherChargeRemarks();

        if (validData && validationRes.isDataValid && validateOffer.isDataValid && validateOtherChargeRemarks.isDataValid) {
            this.executeAction(generateQuotation, {
                dataList: this.toJSON(this.state)
            }).then(result => {
                if (result) {
                    let quoteId = result.split('#')[0];
                    let message = result.split('#')[1];
                    if (message === 'success' && quoteId !== null && quoteId !== undefined) {
                        this.executeAction(retriveQuoteTemplateInfo, {
                            recordId: quoteId
                        }).then(result1 => {
                            if (result1) {
                                this.dispatchEvent("quotecreatesuccess", { recordId: quoteId });
                                this.showToast({ message: 'The quote is being sent to the Customer.', variant: 'success' });
                            }
                        });
                    }
                    //else block code is updated by suraj gurung on 08July2020 for showing accurate error and success messages.
                    else {
                        this.showToast({ message: '' + message });
                    }
                } else {
                    console.log('== result ', result);
                    this.showToast({ message: 'Error occur no result.' });
                }
            });
        } else {
            if (validationRes.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Component section - ' + validationRes.errorFields + ' field(s)' });
            }
            if (validateOffer.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Offer section - ' + validateOffer.errorFields + ' field(s)' });
            }
            if (validateOtherChargeRemarks.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Component section - ' + validateOtherChargeRemarks.errorFields + ' field(s)' });
            }

        }

    }

    confirmPreBookingBtnMethod() {
        console.log(this.state);

        let inputCmp = this.template.querySelectorAll(".inputCmp");
        let validData = true;
        for (let i = 0; i < inputCmp.length; i++) {
            let tempInputCmp = inputCmp[i];
            if (tempInputCmp.value > tempInputCmp.max) {
                validData = false;
                tempInputCmp.setCustomValidity("The number is too high.");
            }
            tempInputCmp.reportValidity();
        }
        //check if add cmp fields are valid
        let validationRes = this.validateAddComponentsFields();
        let validateOffer = this.validateAddSchemesFields();
        let validateOtherChargeRemarks = this.validateOtherChargeRemarks();
        let validatePhone = this.validatePhoneNumber();

        //Added By Deepak

        let validateInterestedInLoyaltyIsValid = this.validateInterestedInLoyalty();
        let interestedInLoyaltyData = this.state.addSchemes.interestedInLoyaltyData;
        if (interestedInLoyaltyData != null && interestedInLoyaltyData.length > 0) {
            this.setData({ opportunityInfo: { Interested_In_Loyalty: this.state.addSchemes.interestedInLoyaltyData } });
            this.setData({ opportunityInfo: { Reason_not_Interested_in_Loyalty: this.state.addSchemes.reasonNotInterestedLoyalty } });
            this.setData({ opportunityInfo: { Points_To_Be_Redeemed__c: null } });
        }

        let validateLoyaltyRedemptionIsValid = true;
        if (this.tier && this.pointsToBeRedeemed && this.pointsToBeRedeemed > 0) {
            validateLoyaltyRedemptionIsValid = this.validateLoyaltyRedemption();
            this.setData({ opportunityInfo: { Points_To_Be_Redeemed__c: this.pointsToBeRedeemed } });
        } else {
            this.setData({ opportunityInfo: { Points_To_Be_Redeemed__c: null } });
        }

        if (validateLoyaltyRedemptionIsValid && validateInterestedInLoyaltyIsValid && validData && validatePhone.isDataValid && validationRes.isDataValid && validateOffer.isDataValid && validateOtherChargeRemarks.isDataValid) {
            this.state.addSchemes.interestedInLoyaltyData = null;
            this.state.addSchemes.interestedInLoyaltyDataTemp = null;
            this.state.addSchemes.reasonNotInterestedLoyalty = null;
            this.state.addSchemes.reasonNotInterestedLoyaltyTemp = null;

            this.executeAction(createLineItemRecords, {
                dataList: this.toJSON(this.state),
                parentSobjectId: ''
            }).then(result => {
                if (result === 'success') {
                    this.executeAction(retriveOpportunityAmount, {
                        recordId: this.state.exShowRoomVariant.opporrtunityId
                    }).then(enquiryResult => {
                        let updatedAmount = enquiryResult.amount;
                        let previousAmount = parseFloat(this.state.opportunityInfo.Amount, 10);
                        this.setData(JSON.parse(enquiryResult.lineItemSummary));
                        if (previousAmount !== 0 && previousAmount > 0 && previousAmount !== updatedAmount) {
                            this.state.opportunityInfo.Amount = this.toJSON(updatedAmount);
                            this.showToast({ message: Refresh_Amount_Msg, variant: 'success' });
                            this.conditionalConnectedCallBack();
                        } else {
                            this.dispatchEvent('submitreq');
                        }
                    })
                } else {
                    var error = JSON.stringify(result);
                    this.showToast({ message: error });
                }
            });
        } else {
            if (validationRes.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Component section - ' + validationRes.errorFields + ' field(s)' });
            }
            if (validateOffer.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Offer section - ' + validateOffer.errorFields + ' field(s)' });
            }
            if (validateOtherChargeRemarks.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Component section - ' + validateOtherChargeRemarks.errorFields + ' field(s)' });
            }
            if (validatePhone.errorMsg.length > 0) {
                this.showToast({ message: validatePhone.errorMsg });
            }
        }
    }


    //Calculate Cash Payment
    calculateCashPayemntTotal(event) {
        if (event.target.value === '') {
            this.state.addSchemes.financeAmountData = 0;
        } else {
            this.state.addSchemes.financeAmountData = event.target.value;
        }
        this.state.addSchemes.cashPaymentData = (parseFloat(this.state.exShowRoomVariant.UnitPrice) + parseFloat(this.state.registrationAmountVariant.UnitPrice)) - parseFloat(this.state.addSchemes.financeAmountData);
        this.calculateCashPaymentAmount();
    }

    calculateCashPaymentAmount() {
        let vehicleAmount = parseFloat(this.vehicleSubTotal);
        let componentAmount = parseFloat(this.componentSubTotal);
        let accessoriesAmount = parseFloat(this.accessoriesSubTotal);
        let offerAmount = parseFloat(this.offersSubTotal);
        let financeAmount = parseFloat(this.state.addSchemes.financeAmountData);
        this.state.addSchemes.cashPaymentData = parseFloat(vehicleAmount + componentAmount + accessoriesAmount) - parseFloat(offerAmount + financeAmount);

        if (this.tier && this.loyaltyBonus) {
            console.log('loyaltyBonus deducted');
            this.state.addSchemes.cashPaymentData = parseFloat(this.state.addSchemes.cashPaymentData) - parseFloat(this.loyaltyBonus);
        }

    }

    handleReload() {
        this.dispatchEvent('closemethod');
    }


}