/*eslint-disable no-console */
import Base from 'c/addLineItemBase';
import { track, api } from 'lwc';

import createLineItemRecords from '@salesforce/apex/AddLineItemCtrl.createLineItemRecords';
import generateQuotation from '@salesforce/apex/AddLineItemCtrlHelper.generateQuotation';
import retriveOpportunityAmount from '@salesforce/apex/AddLineItemCtrl.retriveOpportunityAmount';

import retriveQuoteTemplateInfo from '@salesforce/apex/EmailQuotePDFCtrl.retriveQuoteTemplateInfo';

import Refresh_Amount_Msg from '@salesforce/label/c.Refresh_Amount_Msg';
import Server_Error from '@salesforce/label/c.Server_Error';
import Tax_Amount from '@salesforce/label/c.Tax_Amount'; 
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
    loyalty_Tax; 
    connectedCallback() {
        this.conditionalConnectedCallBack();
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
        //console.log('this.oppRecord', this.oppRecord);
    }

    setDefaulOppValues(state) { 
        this.state.addSchemes.firstName = state.opportunityInfo.First_Name__c;
        this.state.addSchemes.lastName = state.opportunityInfo.Last_Name__c;
        this.state.addSchemes.middleName = state.opportunityInfo.Middle_Name__c;
        this.state.addSchemes.phoneNumber = state.opportunityInfo.Mobile__c;
    }
    //#DE622 End
    /*
    get showQuoteAndPreBookingButton(){
        return (this.state.opportunityInfo.StageName && this.state.opportunityInfo.StageName === 'New') ? true : false;
    }
    */
    conditionalConnectedCallBack() {
        //console.log('== All Data Summary Value ', this.state);
        
        let taxAmount = !isNaN(Tax_Amount) ? Tax_Amount : 0;
        //console.log('== taxAmount ', taxAmount);
        
        let addComponentTemp = JSON.parse(JSON.stringify(this.state.addComponent));
        //#DE622 Start
        if (this.state) {
            this.setDefaulOppValues(this.state);
        }
        //#DE622 End
        if(addComponentTemp){
            for (let i = 0; i < addComponentTemp.length; i++) {
                if (addComponentTemp[i].label === 'Extended Warranty') {
                    let extendWarrantValue = addComponentTemp[i].value;
                    this.extended_Warranty_Tax = (taxAmount > 0 ? parseFloat((extendWarrantValue * taxAmount) / 100) : 0);
                    addComponentTemp[i].value = parseFloat(extendWarrantValue) + this.extended_Warranty_Tax;
                }
                if (addComponentTemp[i].label === 'Loyalty') {
                    let loyaltyValue = addComponentTemp[i].value;
                    this.loyalty_Tax = (taxAmount > 0 ? parseFloat((loyaltyValue * taxAmount) / 100) : 0);
                    addComponentTemp[i].value = parseFloat(loyaltyValue) + this.loyalty_Tax;
                }
                this.updated_AddComponent.push(addComponentTemp[i]);
            }
            //console.log('== updated_AddComponent ', this.updated_AddComponent);
        }
        

        if(this.state.offerFieldsConfiguration){
            let offer_fields = Object.keys(this.state.offerFieldsConfiguration);
            this.Corporate_Offers_editable = offer_fields.includes('Corporate_Offers__c') ? this.state.offerFieldsConfiguration.Corporate_Offers__c : false;
            this.Exchange_Bonus_editable = offer_fields.includes('Exchange_Bonus__c') ? this.state.offerFieldsConfiguration.Exchange_Bonus__c : false;
            this.Exchange_Value_editable = offer_fields.includes('Exchange_Value__c') ? this.state.offerFieldsConfiguration.Exchange_Value__c : false;
            this.Rural_Offers_editable = offer_fields.includes('Rural_Offers__c') ? this.state.offerFieldsConfiguration.Rural_Offers__c : false;
        }

        this.vehicleSubTotal = parseFloat(this.state.exShowRoomVariant.UnitPrice, 10);
        this.vehicleSubTotal = this.vehicleSubTotal + parseFloat(this.state.registrationAmountVariant.UnitPrice, 10);

        this.componentSubTotal = this.state.otherCharge.UnitPrice != null ? parseFloat(this.state.otherCharge.UnitPrice, 10) : 0;

        if (this.state.addComponent !== null && this.state.addComponent.length > 0) {

            let totalAmount = 0;
            for (let i = 0; i < this.state.addComponent.length; i++) {
                if (this.state.addComponent[i].isChecked && this.state.addComponent[i].value && this.state.addComponent[i].value !== 'null') {
                    if(this.state.addComponent[i].label === 'Extended Warranty'){
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.extended_Warranty_Tax);
                    }else if(this.state.addComponent[i].label === 'Loyalty'){
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.loyalty_Tax);
                    }else{
                        totalAmount = totalAmount + parseFloat(this.state.addComponent[i].value, 10);
                    }
                }
            }
            this.componentSubTotal += totalAmount;
        } else {
            this.componentSubTotal = 0.0;
        }
        //console.log('== this.componentSubTotal ', this.componentSubTotal);
        //console.log('== this.state.addAccessories ', this.state.addAccessories);
        if (this.state.addAccessories !== null && this.state.addAccessories.length > 0) {
            //console.log('== In If Condition', this.state.addAccessories.length);
            let totalAmount = 0;
            for (let i = 0; i < this.state.addAccessories.length; i++) {
                totalAmount = totalAmount + parseFloat(this.state.addAccessories[i].price, 10);
            }
            this.accessoriesSubTotal = totalAmount - parseFloat(this.state.otherAccessoriesDiscount.UnitPrice, 10);
        } else {
            //console.log('== In Else Condition');
            this.accessoriesSubTotal = 0.0;
        }

        //console.log('== this.accessoriesSubTotal ', this.accessoriesSubTotal);

        this.offersSubTotal = this.state.addSchemes.OfferData + 
                (this.state.addSchemes.corporateDiscountValue ? this.state.addSchemes.corporateDiscountData : 0) +
                (this.state.addSchemes.exchangeBonusValue ? this.state.addSchemes.exchangeBonusData : 0) +
                (this.state.addSchemes.exchangeValue ? this.state.addSchemes.exchangeData : 0) +
                (this.state.addSchemes.ruralOffersValue ? this.state.addSchemes.ruralDiscountData : 0) +
                (this.state.addSchemes.otherDiscountValue ? this.state.addSchemes.otherDiscountData : 0) ;
        
        this.totalOnRoadPrice = (this.vehicleSubTotal + this.componentSubTotal + this.accessoriesSubTotal) - this.offersSubTotal;

        this.calculateCashPaymentAmount();
    }

    @track showVehicle = false;
    @track showComponent = false;
    @track showAccessories = false;
    @track showOffer = false;

    get remarksRequired() {
        return this.state.otherCharge.UnitPrice > 0 ? true : false;
    }

    get showCreateQuotation(){
        return (this.state.opportunityInfo.StageName && this.state.opportunityInfo.StageName === 'New' && 
                this.state.componentType && this.state.componentType === 'quote' && 
                this.state.selectedVariant && this.state.exShowRoomVariant.UnitPrice && 
                this.state.exShowRoomVariant.UnitPrice !== 0) ? true : false;
    }

    get showPreBooking(){
        //console.log('== this.state IN pre booking ', this.state);
        return (this.state.opportunityInfo.StageName && this.state.opportunityInfo.StageName === 'New' && 
                this.state.componentType && this.state.componentType === 'prebooking' && 
                this.state.selectedVariant && this.state.exShowRoomVariant.UnitPrice && 
                this.state.exShowRoomVariant.UnitPrice !== 0) ? true : false;
    }

    showHideVehicleSection() {
        this.showVehicle = !this.showVehicle;
    }

    showHideComponentSection() {
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
            this.setData({ addSchemes: { OfferData : !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'exchangeData') {
            this.setData({ addSchemes: { exchangeData : !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'otherDiscountData') {
            this.setData({ addSchemes: { otherDiscountData : !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        
        if (proTyname === 'exchangeBonusData') {
            this.setData({ addSchemes: { exchangeBonusData : !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'corporateDiscountData') {
            this.setData({ addSchemes: { corporateDiscountData : !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
        }
        if (proTyname === 'ruralDiscountData') {
            this.setData({ addSchemes: { ruralDiscountData : !isNaN(addSchemesUsedAmountData) > 0 ? addSchemesUsedAmountData : 0 } });
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

    handleRemarksData(event){
        this.setData({
            otherCharge: { Description : event.target.value }
        });
    }

    calculateAddComponentSubTotal() {
        this.componentSubTotal = parseFloat(this.state.otherCharge.UnitPrice, 10);

        if (this.state.addComponent !== null && this.state.addComponent.length > 0) {

            let totalAmount = 0;
            for (let i = 0; i < this.state.addComponent.length; i++) {
                if (this.state.addComponent[i].isChecked && this.state.addComponent[i].value !== '') {
                    if(this.state.addComponent[i].label === 'Extended Warranty'){
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.extended_Warranty_Tax);
                    }else if(this.state.addComponent[i].label === 'Loyalty'){
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.loyalty_Tax);
                    }else{
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
                    if(this.state.addComponent[i].label === 'Extended Warranty'){
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.extended_Warranty_Tax);
                    }else if(this.state.addComponent[i].label === 'Loyalty'){
                        totalAmount = totalAmount + (parseFloat(this.state.addComponent[i].value, 10) + this.loyalty_Tax);
                    }else{
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
            (this.state.addSchemes.otherDiscountValue ? this.state.addSchemes.otherDiscountData : 0) ;

        this.totalOnRoadPrice = (this.vehicleSubTotal + this.componentSubTotal + this.accessoriesSubTotal) - this.offersSubTotal;
    }

    calculateTotalAmount() {
        this.offersSubTotal = this.state.addSchemes.OfferData + 
            (this.state.addSchemes.corporateDiscountValue ? this.state.addSchemes.corporateDiscountData : 0) +
            (this.state.addSchemes.exchangeBonusValue ? this.state.addSchemes.exchangeBonusData : 0) +
            (this.state.addSchemes.exchangeValue ? this.state.addSchemes.exchangeData : 0) +
            (this.state.addSchemes.ruralOffersValue ? this.state.addSchemes.ruralDiscountData : 0) +
            (this.state.addSchemes.otherDiscountValue ? this.state.addSchemes.otherDiscountData : 0) ;

        //console.log('== On value change this.offersSubTotal ', this.offersSubTotal);

        this.totalOnRoadPrice = (this.vehicleSubTotal + this.componentSubTotal + this.accessoriesSubTotal) - this.offersSubTotal;
        this.calculateCashPaymentAmount();
    }

    // To check the selected component have value greater than Zero.
    validatePhoneNumber() {
        let validData = false;
        let errorMsg = '';
        let validationObj = {};
        let phoneNum = this.state.addSchemes.phoneNumber.trim();
        if(phoneNum == '' || phoneNum.length == 0){
            errorMsg = 'Please Enter Mobile Number.'
            validData = false;
        }else{
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

        if(this.state.otherCharge.UnitPrice && this.state.otherCharge.UnitPrice > 0 && !this.state.otherCharge.Description){
            notValidFields += 'Other Charges Remarks ,';
            validData = false;
        }

        if (notValidFields.length > 0){
            notValidFields = notValidFields.slice(0, -1);
        }else {
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
        if(this.state.addComponent){
            for(let i = 0; i< this.state.addComponent.length; i++){
                let singleComp = this.state.addComponent[i];
                if(singleComp.isChecked && singleComp.label !== 'Extended Warranty' && singleComp.label !== 'Loyalty' && singleComp.label !== 'MCP'){
                    let singleCompValue = singleComp.value ? parseFloat(singleComp.value, 10) : 0;
                    if(singleCompValue > 0){
                        validData = true;
                    }else{
                        notValidFields += singleComp.label + ',';
                        validData = false;
                    }
                }
            }
        }

        if (notValidFields.length > 0){
            notValidFields = notValidFields.slice(0, -1);
        }else {
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
        if(this.state.addSchemes.exchangeValue){
           let exchangeValue = this.state.addSchemes.exchangeData ? parseFloat(this.state.addSchemes.exchangeData, 10) : 0;
            if(exchangeValue > 0){
                validData = true;
            }else{
                if(this.Exchange_Value_editable){
                    notValidFields +=  ' Exchange Value, ';
                    validData = false;
                }else{
                    validData = true;
                }
            }
        }

        if(this.state.addSchemes.otherDiscountValue){
            let otherDisValue = this.state.addSchemes.otherDiscountData ? parseFloat(this.state.addSchemes.otherDiscountData, 10) : 0;
             if(otherDisValue > 0){
                 validData = true;
             }else{
                 notValidFields +=  'Other Discount, ';
                 validData = false;
             }
         }

        if (notValidFields.length > 0){
            notValidFields = notValidFields.slice(0, -1);
        }else {
            validData = true;
        }
        validationObj.isDataValid = validData;
        validationObj.errorFields = notValidFields;
        return validationObj;
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
                    if(message === 'success' && quoteId !== null && quoteId !== undefined){
                        this.executeAction(retriveQuoteTemplateInfo, {
                            recordId : quoteId
                        }).then(result1 => {
                            if(result1){
                                this.dispatchEvent("quotecreatesuccess", { recordId: quoteId });
                                this.showToast({ message: 'The quote is being sent to the Customer.', variant : 'success' });
                            }
                        } );
                    }
                } else {
                    console.log('== result ',result);
                  //  this.showToast({ message: 'Status Message: ' + result });
                }
            });
        } else {
            if (validationRes.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Component section - ' + validationRes.errorFields + ' field(s)' });
            }
            if (validateOffer.errorFields.length > 0) {
                this.showToast({ message: 'Please Complete the Offer section - ' + validateOffer.errorFields + ' field(s)' });
            }
            if(validateOtherChargeRemarks.errorFields.length > 0){
                this.showToast({ message: 'Please Complete the Component section - ' + validateOtherChargeRemarks.errorFields + ' field(s)' });
            }

        }

    }

    confirmPreBookingBtnMethod() {

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
        console.log(validatePhone);
        if (validData && validatePhone.isDataValid && validationRes.isDataValid &&  validateOffer.isDataValid && validateOtherChargeRemarks.isDataValid) {
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
            if(validateOtherChargeRemarks.errorFields.length > 0){
                this.showToast({ message: 'Please Complete the Component section - ' + validateOtherChargeRemarks.errorFields + ' field(s)' });
            }
            if(validatePhone.errorMsg.length > 0){
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

    calculateCashPaymentAmount(){
        let vehicleAmount = parseFloat(this.vehicleSubTotal);
        let componentAmount = parseFloat(this.componentSubTotal);
        let accessoriesAmount = parseFloat(this.accessoriesSubTotal);
        let offerAmount = parseFloat(this.offersSubTotal);
        let financeAmount = parseFloat(this.state.addSchemes.financeAmountData);
        this.state.addSchemes.cashPaymentData = parseFloat(vehicleAmount + 
                                                componentAmount + 
                                                accessoriesAmount) - parseFloat(
                                                                offerAmount + financeAmount);
    }

    handleReload(){
        this.dispatchEvent('closemethod');
    }

}