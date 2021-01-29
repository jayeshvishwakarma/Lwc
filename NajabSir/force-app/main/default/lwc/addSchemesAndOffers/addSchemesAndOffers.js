/*eslint-disable no-console*/
import Base from 'c/addLineItemBase';
import retrieveOffersSchemes from '@salesforce/apex/AddLineItemCtrl.retriveOffersSchemes';
import retriveConsumerOffer from '@salesforce/apex/AddLineItemCtrl.retriveConsumerOffer';

export default class AddSchemesAndOffers extends Base {

    connectedCallback() {
        this.setSavePoint();
    }

    handleCorporateDiscountChange(event) {
        if (this.state.addSchemes.ruralOffersValue) {
            this.showToast({ message: 'You can only select either Corporate Discount or Rural Offer', variant: 'info' });
        }
        this.setData({ 
            registrationAmountVariant: { opporrtunityId: this.recordId },
            addSchemes: { 
                corporateDiscountValue: event.target.checked, 
                ruralOffersValue: event.target.checked ? false : this.state.addSchemes.ruralOffersValue
            }
        });
    }

    handleExchangeBonusChange(event) {
        this.setData({ addSchemes: { exchangeBonusValue: event.target.checked } });
    }

    handleExchangeChange(event) {
        this.setData({ addSchemes: { exchangeValue: event.target.checked } });
    }

    handleRuralOffersChange(event) {
        if (this.state.addSchemes.corporateDiscountValue) {
            this.showToast({ message: 'You can only select either Corporate Discount or Rural Offer', variant: 'info' });
        }
        this.setData({ 
            registrationAmountVariant: { opporrtunityId: this.recordId },
            addSchemes: { 
                ruralOffersValue: event.target.checked, 
                corporateDiscountValue : event.target.checked ? false : this.state.addSchemes.corporateDiscountValue
            }
        });
    }

    handleOtherDiscountChange(event) {
        this.setData({ addSchemes: { otherDiscountValue: event.target.checked } });
    }

    handleSave() {
        this.executeAction(retrieveOffersSchemes, { dataList: JSON.stringify(this.state) }).then(result1 => {
            
            let offerResult = JSON.parse(result1);
            this.setData({
                addSchemes: { 
                    exchangeBonusData : offerResult.addSchemes.exchangeBonusData,
                    corporateDiscountData : offerResult.addSchemes.corporateDiscountData,
                    schemeCode : offerResult.addSchemes.schemeCode,
                    ruralDiscountData : offerResult.addSchemes.ruralDiscountData
                }
            });

            this.executeAction(retriveConsumerOffer, {
                forCode: this.state.opportunityInfo.forCode,
                fuelType: this.state.selectedVariant.Fuel_Type__c,
                model : this.state.selectedVariant.Model__c,
                schemeRegion : this.state.opportunityInfo.regionCode,
                state : this.state.opportunityInfo.billingState,
                selectedVariant : this.state.selectedVariant.ProductCode
            }).then(result => {
                let consumerOfferList = [];
                let priceBookEntryId = Object.keys(result);
                let totalAmount = 0;
                for(let i = 0; i < priceBookEntryId.length; i++){
                    let product = result[priceBookEntryId[i]];
                    let productKeys = Object.keys(product);
                    if (productKeys.includes('Discount_Price__c')) {
                        totalAmount = totalAmount + product.Discount_Price__c;
                        consumerOfferList.push({priceBookEntryId : priceBookEntryId[i], UnitPrice : product.Discount_Price__c, Quantity : 1});
                    }
                }
                this.setData({
                    consumerOffer : consumerOfferList,
                    addSchemes: {
                        OfferData: totalAmount
                    }
                });
                this.commit().dispatchEvent('select');
            }).catch(error => {
                console.error('Error While Query Consumer Offer ', error);
            });
            
        })
    }

    handleCancel() {
        this.revert().dispatchEvent('select');
    }
}