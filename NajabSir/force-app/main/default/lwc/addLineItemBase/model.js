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
    opportunityInfo : { Name : '', Pricebook2Id : '', Email__c : '',  Mobile__c : '', StageName : '', Amount : 0, Model_Code__c : '', Variant_Modified_Count__c : 0, Old_Variant__c : null, forCode : '', regionCode : '', billingState : '', dealerForCodeId: ''},
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
        OfferData : 0,
        exchangeData : 0,
        exchangeBonusData : 0,
        corporateDiscountData : 0,
        ruralDiscountData : 0,
        otherDiscountData : 0,
        financeAmountData : 0,
        cashPaymentData : null,
        schemeCode : null,
        offersText : null
    }
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