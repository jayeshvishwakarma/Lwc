/**
 * Author - Sumit Gupta
 * Add Line Item Data Model
 */

import helper from './helper';

const data = {
    enquiryRecordType : null,
    accessoriesValidAmount : 0.0,
    otherValidAmount : 0.0,
    headerValue : [],
    addComponent : null,
    addAccessories : null,
    opportunityInfo : { Name : '', Pricebook2Id : '', Email__c : '',  Mobile__c : '', StageName : '', Amount : 0, Sales_Type__c : '', Model_Code__c : '', MGASelected : false},
    otherAccessoriesDiscount : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
    selectedVariant : null,
    selectedColorVariant : null,
    otherCharge : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null, Description : ''},
    exShowRoomVariant : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
    registrationAmountVariant : { opporrtunityId : null, Quantity : 1, UnitPrice : 0, priceBookEntryId : null },
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

let tmpData = {};
let savePoint = false;

export default {
    get data(){
        return savePoint ? tmpData : data;
    },
    set data(newData) {
        if(savePoint){
            helper.merge(tmpData, newData);
        } else {
            helper.merge(data, newData);
        }
    },
    set savePoint(value){
        savePoint = value;
        if(savePoint){
            tmpData = helper.merge({}, data);
        } else {
            tmpData = {};
        }
    },
    set commit(value){
        if(value){
            helper.merge(data, tmpData);
        } else {
            this.savePoint = false;
        }
    }
}