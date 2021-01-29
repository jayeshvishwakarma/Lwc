/**
 * Author - Sumit Gupta
 * Add Line Item Data Model
 */

import helper from './helper';

const defaults = {
    componentType : '',
    enquiryRecordType : null,
    accessoriesValidAmount : 0.0,
    otherValidAmount : 0.0,
    headerValue : [],
    addComponent : null,
    addAccessories : null,
    opportunityInfo : { 
        Name : '', 
        Pricebook2Id : '', 
        Email__c : '',  
        Mobile__c : '', 
        StageName : '', 
        Amount : 0, 
        Model_Code__c : '', 
        Variant_Modified_Count__c : 0, 
        Old_Variant__c : null, 
        forCode : '', 
        regionCode : '', 
        billingState : '', 
        dealerForCodeId: '',
        Interested_In_Loyalty__c:'',
        Customer__c:'',
        Interested_In_Loyalty : '',
        Reason_not_Interested_in_Loyalty : '',
        Loyalty_Program_Type__c :'',
        Points_To_Be_Redeemed__c :0,
    },
    otherAccessoriesDiscount : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
    selectedVariant : null,
    selectedColorVariant : null,
    otherCharge : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
    exShowRoomVariant : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
    registrationAmountVariant : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
    consumerOffer : null,
    offerFieldsConfiguration : null,
    addSchemes : {
        employerName : null,
        corporateDiscountValue : false,
        exchangeBonusValue : false,
        exchangeValue : false,
        ruralOffersValue : false,
        otherDiscountValue : false,
        acquisitionDiscountValue : false,
        loyaltyDiscountValue : false,
        bulkDiscountValue : false,
        specialDiscountValue : false,
        isCommercial : false,
        OfferData : 0,
        exchangeData : 0,
        exchangeBonusData : 0,
        corporateDiscountData : 0,
        ruralDiscountData : 0,
        otherDiscountData : 0,
        financeAmountData : 0,
        acquisitionDiscount : 0,
        loyaltyDiscount : 0,
        bulkDiscount : 0,
        specialDiscount : 0,
        cashPaymentData : null,
        schemeCode : null,
        offersText : null,
        interestedInLoyaltyData : null,
        interestedInLoyaltyDataTemp : null,
        reasonNotInterestedLoyalty : null,
        reasonNotInterestedLoyaltyTemp : null
    },
    loyaltyBonus : {
        loyaltyBonusAmount : 0,
        loyaltyBonusValid: false
    }, 
    constantObj : {}
};

let state = helper.merge({}, defaults);

let localState = {};
let savePoint = false;

export default {
    get state(){
        return savePoint ? localState : state;
    },
    set state(newState) {
        if(savePoint){
            helper.merge(localState, newState);
        } else {
            helper.merge(state, newState);
        }
    },
    set savePoint(value){
        savePoint = value;
        if(savePoint){
            localState = helper.merge({}, state);
        } else {
            localState = {};
        }
    },
    set commit(value){
        if(value){
            helper.merge(state, localState);
        }
        this.savePoint = false;
    },
    reset(){
        state = helper.merge({}, defaults);
    }
}