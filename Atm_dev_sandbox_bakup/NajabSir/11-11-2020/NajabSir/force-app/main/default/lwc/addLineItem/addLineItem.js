/* eslint-disable no-console */
import Base from 'c/addLineItemBase';
import { api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import Model_of_Interest from '@salesforce/schema/Opportunity.Model_of_Interest__c';
import queryLineItemDetails from '@salesforce/apex/AddLineItemCtrl.queryLineItemDetail';
import fetchVariantProducts from '@salesforce/apex/AddLineItemCtrl.fetchVariantProducts';
import retriveExShowroomPrice from '@salesforce/apex/AddLineItemCtrl.retriveExShowroomPrice';

export default class AddLineItem extends Base {
    @api recordId;
    @api SObjecttype;
    @api sObjectFields;
    @api deviceFormFactor;
    @api type;

    // Screen flow controls
    @track showScreen = false;
    @track showError = false;
    @track showVariantScreen = false;
    @track showComponentScreen = false;
    @track showAccessoriesScreen = false;
    @track showSchemesAndOffersScreen = false;
    @track showSummaryScreen = false;

    @track stageName = '';
    @track dealerForCodeId = '';

    @track cashPaymentData;

    @track setColorDetail = false;

    modelOfInterest = [];

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Model_of_Interest })
    modelOfInterestPicklistValues({ data }) {
        if (data) {
            this.modelOfInterest = data.values;
            console.log('== modelOfInterestPicklistValues ', data.values);
        }
    }

    connectedCallback() {

        this.executeAction(queryLineItemDetails, {
            recordId: this.recordId,
            sobjectName: this.SObjecttype
        }).then(result => {
            console.log('== amountValidation ', result);
            if(result && result.amountValidation){
                this.setData({
                    otherValidAmount: result.amountValidation.Offer_Discount_Amount__c,
                    accessoriesValidAmount: result.amountValidation.Accessories_Discount_Amount__c
                });
            }
            this.offerFieldsConfig = result.offerFieldsConfig;
           /* if(result && result.offerFieldsConfig){
                this.setData({
                    offerFieldsConfiguration : result.offerFieldsConfig
                });
            }
            */
            
            if (result && result.obj) {
                let record = result.obj;
                if (this.SObjecttype === 'Opportunity') {
                    this.setOpportunityData(record, result.lineItemSummary);
                } else if (this.SObjecttype === 'Quote') {
                    if (record.Opportunity) {
                        this.modelAPIValue = record.Opportunity.Model_of_Interest__c;
                        if (record.Opportunity.Dealership__r !== null) {
                            this.dealerForCodeId = record.Opportunity.Dealership__r.For_Code__c;
                        }
                        this.setQuoteData(record);
                    }
                }
            } else {
                console.log('Blank Line item summary field');
            }
        }).catch(error => {
            this.showScreen = false;
            this.showError = true;
            console.log('Error While Query LineItem ', error);
        });
    }

    setOpportunityData(opportunity, lineItemSummary) {
        let opportunityKeys = Object.keys(opportunity);
        console.log('== opportunityKeys ', opportunityKeys);
        // Generate Header Details
        this.setData({
            headerValue: [
                opportunityKeys.includes('Customer__c') ? 'Customer Name : ' + opportunity.SVOC_Customer_Name__c : '',
                opportunityKeys.includes('DMS_Enquiry_Name__c') ? 'DMS Enquiry Number : ' + opportunity.DMS_Enquiry_Name__c : '',
                opportunityKeys.includes('Variant__r') ? 'Variant Name : '+opportunity.Variant__r.Name : ''
            ]
        })
        let lineItemSummaryData;
        if(lineItemSummary){
            lineItemSummaryData = JSON.parse(lineItemSummary);
        }
        // Make JSON from previous records
        if (lineItemSummaryData) {
            this.setData(lineItemSummaryData);
        }

        this.setData({
            // To Hold the opportunity record info in opportunityInfo json object
            opportunityInfo: {
                Name: opportunityKeys.includes('Name') ? opportunity.Name : this.state.opportunityInfo.Name,
                Pricebook2Id: opportunityKeys.includes('Pricebook2Id') ? opportunity.Pricebook2Id : this.state.opportunityInfo.Pricebook2Id,
                Email__c: opportunityKeys.includes('Email__c') ? opportunity.Email__c : this.state.opportunityInfo.Email__c,
                Mobile__c: opportunityKeys.includes('Mobile__c') ? opportunity.Mobile__c : this.state.opportunityInfo.Mobile__c,
                StageName: opportunityKeys.includes('StageName') ? opportunity.StageName : this.state.opportunityInfo.StageName,
                Amount: opportunityKeys.includes('Amount') ? opportunity.Amount : this.state.opportunityInfo.Amount,
                Sales_Type__c: opportunityKeys.includes('Sales_Type__c') ? opportunity.Sales_Type__c : this.state.opportunityInfo.Sales_Type__c,
                Model_Code__c: opportunityKeys.includes('Model_Code__c') ? opportunity.Model_Code__c : this.state.opportunityInfo.Model_Code__c,
                Variant_Modified_Count__c: opportunityKeys.includes('Variant_Modified_Count__c') ? opportunity.Variant_Modified_Count__c : this.state.opportunityInfo.Variant_Modified_Count__c,
                Old_Variant__c: opportunityKeys.includes('Variant__c') ? opportunity.Variant__c : this.state.opportunityInfo.Old_Variant__c,  
                First_Name__c: opportunityKeys.includes('First_Name__c') ? opportunity.First_Name__c : this.state.opportunityInfo.First_Name__c, //#DE622
                Last_Name__c: opportunityKeys.includes('Last_Name__c') ? opportunity.Last_Name__c : this.state.opportunityInfo.Last_Name__c,//#DE622
                Middle_Name__c: opportunityKeys.includes('Middle_Name__c') ? opportunity.Middle_Name__c : this.state.opportunityInfo.Middle_Name__c, //#DE622
              
            },
            // Generate Header Details
            
            // To show excahnge amount of vehicle only expiry date is greater than or equals to current date
            addSchemes: {
                employerName: opportunityKeys.includes('Employer_Name__c') ? opportunity.Employer_Name__r.Name : this.state.addSchemes.employerName,
                exchangeData: this.getSchemeExchangeData(opportunity.Exchange_Offer_Expiry_Date__c, opportunity.Exchange_Offered_Price__c)
            },
            enquiryRecordType: opportunityKeys.includes('RecordTypeId') ? opportunity.RecordType.Name : this.state.enquiryRecordType
        });

        this.stageName = this.state.opportunityInfo.StageName;
        this.setData({
            componentType : this.type
        });
        console.log('== componentType ', this.state.componentType);
        // Enqiry for Modal Name 
        /*  // Method not needed Logic need to change on Enquiry Model of Enquiry Field on 22 Oct 2019 (==> By: Anuj)
        if (opportunityKeys.includes('Model_of_Interest__c')) {
            let modelOfIntrestMap = this.modelOfInterest.reduce((map, item) => { map[item.value] = item.label; return map; }, {});
            this.modelAPIValue = opportunity.Model_of_Interest__c;
            this.modelValue = (opportunity.Model_of_Interest__c || '').split(';').map(item => modelOfIntrestMap[item]).join(';');
        }
        */

        if(this.offerFieldsConfig){
            this.setData({
                offerFieldsConfiguration : this.offerFieldsConfig
            });
        }
        console.log(' == After set Offer field ', this.state.offerFieldsConfiguration);
        
        // Dealer For Code info
        if (opportunityKeys.includes('Dealership__c')) {
            this.dealerForCodeId = opportunity.Dealership__r.For_Code__c;
            let dealerShipKeys = Object.keys(opportunity.Dealership__r);

            this.setData({
                opportunityInfo: {
                    billingState : dealerShipKeys.includes('BillingState') ? opportunity.Dealership__r.BillingState : this.state.opportunityInfo.billingState,
                    regionCode : dealerShipKeys.includes('Region_Code__c') ? opportunity.Dealership__r.Region_Code__c : this.state.opportunityInfo.regionCode,
                    dealerForCodeId : dealerShipKeys.includes('For_Code__c') ? opportunity.Dealership__r.For_Code__c : this.state.opportunityInfo.dealerForCodeId
                }
            })

            if(dealerShipKeys.includes('For_Code__c')){
                let forCodeKeys = Object.keys(opportunity.Dealership__r.For_Code__r);
                this.setData({
                    opportunityInfo: {
                        forCode : forCodeKeys.includes('For_Code__c') ? opportunity.Dealership__r.For_Code__r.For_Code__c : this.state.opportunityInfo.forCode
                    }
                })
            }

        }
        
        //if (opportunityKeys.includes('Variant__r') &&  this.state.selectedVariant === null) {
        // Available variant information
         if (opportunityKeys.includes('Variant__r') ) {
            let variantName = 'Variant Name : '+opportunity.Variant__r.Name;
            this.setData({
                selectedVariant: opportunity.Variant__r
            });
            let headerData = JSON.parse( JSON.stringify(this.state.headerValue));
            
            this.state.headerValue = [];
            
            for(let i = 0; i< headerData.length; i++){
                if(headerData[i].startsWith('Variant')){
                    this.state.headerValue.push(variantName);
                }else{
                    this.state.headerValue.push(headerData[i]);
                }
            }
            /*
            if(headerData.indexOf(variantName) < 0){
                this.setData({
                    headerValue: this.state.headerValue.concat('Variant Name : ' + this.state.selectedVariant.Name)
                });
            }
            */
        }

        // Available Color information      Added By: Anuj (07 Nov 2019)
        if (opportunityKeys.includes('Color__r') &&  this.state.selectedColorVariant === null) {
            this.setData({
                selectedColorVariant: opportunity.Color__r
            });
            if(this.state.selectedColorVariant && this.state.enquiryRecordType  === 'Vehicle Sales'){
                this.setColorDetail = true;
                this.updateExshowRoomDetails();
            }
        }

        // Hide Component Info Show Message
        if (opportunity.StageName !== null) {
            let stage2Exclude = ['New', 'Pre-Booking', 'Booking'];
            if (stage2Exclude.indexOf(opportunity.StageName) === -1) {
                this.showAddLineItemsCmp = false;
            }
        }

        // to Check the Record Type Details
        switch (this.state.enquiryRecordType) {
            case "Accessories Sales":
                if (opportunityKeys.includes('Variant__c') && opportunity.Variant__r) {
                    this.setData({
                        selectedVariant: opportunity.Variant__r,
                        headerValue: [
                            opportunity.Variant__r.Family ? 'Model Name : ' + opportunity.Variant__r.Family : '',
                            opportunity.Variant__r.Name ? 'Variant Name : ' + opportunity.Variant__r.Name : ''
                        ]
                    });
                }
                this.setAccessoriesScreen();
                break;
            default:
                if(!this.setColorDetail){
                    this.setData({
                        exShowRoomVariant: {
                            opporrtunityId: this.recordId
                        }
                    });
                    this.setSummaryScreen();
                }
        }
    }

    updateExshowRoomDetails(){
        this.executeAction(retriveExShowroomPrice, {
            variantId: this.state.selectedColorVariant.Variant__c,
            enquiryForCodeId: this.state.opportunityInfo.dealerForCodeId,
            paintType: this.state.selectedColorVariant.Color_Type__c,
            enquirySalesType : this.state.opportunityInfo.Sales_Type__c
        }).then(result => {
            this.cashPaymentData = this.cashPaymentData || parseFloat(result).toFixed(2);
            this.setData({
                exShowRoomVariant: { UnitPrice: (result !== null || result !== '' || result > 0) ?  parseFloat(result, 10) : 0 },
                addSchemes: { cashPaymentData: this.cashPaymentData }
            });
            this.subTotalAmount = parseFloat(result).toFixed(2);

            this.setData({
                exShowRoomVariant: {
                    opporrtunityId: this.recordId
                }
            });
            if(this.state.exShowRoomVariant.UnitPrice < 1){
                this.showToast({ message: 'No price found.' });
            }

            this.executeAction(fetchVariantProducts, { productId: this.state.selectedVariant.Id })
                .then(result1 => {
                    if (result1 === 'No PriceBook Found.') {
                        this.showToast({ message: 'No PriceBook Found.' });
                    } else {
                        this.setData({
                            exShowRoomVariant: { priceBookEntryId: result1 },
                            registrationAmountVariant: { priceBookEntryId: result1 }
                        });
                        this.setSummaryScreen();
                    }
                });

            

        });
    }

    getSchemeExchangeData(expiryDate, offeredPrice) {
        if (expiryDate && offeredPrice) {

            let expiryDateValue = new Date(expiryDate);
            let todayValue = new Date();

            todayValue.setDate(todayValue.getDate() - 1);

            if (expiryDateValue > todayValue) {
                return offeredPrice;
            }
        }
        return 0;
    }

    setQuoteData(quote) {
        this.setData({
            headerValue: [
                quote.Opportunity.Customer__r.value ? 'Customer Name : ' + quote.Opportunity.Customer__r.Name : '',
                quote.Opportunity.DMS_Enquiry_Name__c ? + 'DMS Enquiry Number : ' + quote.Opportunity.DMS_Enquiry_Name__c : ''
            ]
        });
    }

    setVariantScreen() {
        this.setCurrentScreen({ variantScreen: true });
    }

    setComponentScreen() {
        this.setCurrentScreen({ componentScreen: true });
    }

    setAccessoriesScreen() {
        this.setData({ exShowRoomVariant: { opporrtunityId: this.recordId } });
        this.setCurrentScreen({ accessoriesScreen: true });
    }

    setSchemesAndOffersScreen() {
        this.setCurrentScreen({ schemesAndOffersScreen: true });
    }

    setSummaryScreen() {
        this.setCurrentScreen({ summaryScreen: true });
    }

    setCurrentScreen({ variantScreen = false, componentScreen = false, accessoriesScreen = false, schemesAndOffersScreen = false, summaryScreen = false }) {
        this.isLoading = true;
        this.showVariantScreen = variantScreen;
        this.showComponentScreen = componentScreen;
        this.showAccessoriesScreen = accessoriesScreen;
        this.showSchemesAndOffersScreen = schemesAndOffersScreen;
        this.showSummaryScreen = summaryScreen;
        this.showScreen = true;
        this.isLoading = false;
    }

    submitReqMethod() {
        //this.dispatchEvent('SubmitReq');
        this.resetState().dispatchEvent('SubmitReq');
    }

    handleQuoteCreateSuccess(event) {
        this.resetState().dispatchEvent("quotecreatesuccess", { recordId: event.detail.recordId });
    }

    closeCmpMethod(){
        this.dispatchEvent('CloseCmp');
    }

}