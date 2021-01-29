/* eslint-disable radix */
/*eslint-disable no-console*/
import Base from 'c/addLineItemBase';
import { track } from 'lwc';
import getAccessories from '@salesforce/apex/AddLineItemCtrl.getAccessories';
import getAccessoryPrice from '@salesforce/apex/AddLineItemCtrl.getAccessoryPrice';
import getOtherAmount from '@salesforce/apex/AddLineItemCtrl.getOtherAmount';
import createLineItemRecords from '@salesforce/apex/AddLineItemCtrl.createLineItemRecords';
//import queryAccessoriesVarient from '@salesforce/apex/AddLineItemCtrlHelper.queryAccessoriesVarient';

export default class AddAccessories extends Base {
    @track accesList = [];
    @track allAccesList;
    @track finalAccAmount = 0;
    @track selectedCode;
    @track selectedName;
    @track selectedRecord = false;
    @track selectedRecordCode = false;
    @track selectedQuantity;
    @track totalAmount = 0;

    iconname = "standard:product";
    searchfield = 'Name';
    searchfieldCode = 'ProductCode';

    deafaultMinimumQty = 1;

    get variant() {
        return this.state.selectedVariant ? this.state.selectedVariant.Family : null;
    }

    get showConfirm() {
        return this.state.opportunityInfo.StageName !== 'MGA Selected';
    }

    get isAccessoriesSales() {
        console.log('== this.state.enquiryRecordType ', this.state.enquiryRecordType);
        return this.state.enquiryRecordType === 'Accessories Sales';
    }

    get showAccesList() {
        return this.accesList && this.accesList.length;
    }

    get maxQuantity(){
        return this.selectedAcc && this.selectedAcc.Maximum_Quantity__c;
    }

    get minQuantity(){
        return this.selectedAcc && this.selectedAcc.Minimum_Quantity__c;
    }

    connectedCallback() {
        console.log('== this.state.enquiryRecordType From Accessories ', this.state.enquiryRecordType);
        this.setSavePoint();
        if (this.isAccessoriesSales) {
            this.executeAction(getOtherAmount, {}).then(result => {
                if (result) {
                    this.setData({
                        otherValidAmount: result.Offer_Discount_Amount__c,
                        accessoriesValidAmount: result.Accessories_Discount_Amount__c
                    });
                }
            });
        }
        if (this.state.addAccessories != null) {
            this.accesList = this.state.addAccessories;
            this.countTotalAmontOnchange();
        }
    }

    addAccessory() {
        if (this.validateInputs('lightning-input')) {
            let findResult = this.accesList.find(record => record.Id === this.selectedAcc.Id);
            if (!findResult) {
                let selectedAccess = {
                    Id : this.selectedAcc.Id,
                    Name : this.selectedName,
                    quantity : this.selectedQuantity,
                    Minimum_Quantity__c : this.selectedAcc.Minimum_Quantity__c,
                    Maximum_Quantity__c : this.selectedAcc.Maximum_Quantity__c
                };
                this.executeAction(getAccessoryPrice, { productId: this.selectedAcc.Id }).then(result => {
                    if(result.code === 200){
                        selectedAccess.price = result.dataList[0].UnitPrice * this.selectedQuantity;
                        selectedAccess.unitPrice = result.dataList[0].UnitPrice;
                        selectedAccess.priceBookEntryId = result.dataList[0].Id;
                        this.accesList.push(selectedAccess);
                        this.selectedName = '';
                        this.selectedQuantity = '';
                        this.selectedCode = '';
                        this.totalAmount = this.totalAmount + parseInt(selectedAccess.price);
                        this.calculateFinalAmountChanges();
                        this.showToast({message: 'Item added successfully', variant : 'success'});
                    }else{
                        this.showToast({message: 'Price not found.'});
                    }
                });
            } else {
                this.showToast({message: 'This item is already added'});
            }
        }
    }

    deleteAccessory(event) {
        let ind = this.accesList.findIndex(record => record.Id === event.target.dataset.id);
        this.accesList.splice(ind, 1);
        this.countTotalAmontOnchange();
    }

    getAccessories(searchKey) {
        let variantId = this.state.selectedVariant ? this.state.selectedVariant.Id : null;
        this.executeAction(getAccessories, {
            enquiryRecordType: this.state.enquiryRecordType,
            model: variantId,
            var: searchKey,
            type: this.selectedType
        }).then(result => {
            if (result.code === 200) {
                this.allAccesList = result.dataList;
                if (this.selectedRecordCode === false) {
                    this.selectedRecord = true;
                }
            }
        });
    }

    handleNameChange(event) {
        if (event.detail.value) {
            this.selectedName = event.detail.value;
            this.selectedType = 'Name';
            this.getAccessories(this.selectedName);
        } else {
            this.allAccesList = null;
        }
    }

    handleSelect(event) {

        // Need to remove the commented code for new update (By Anuj : 29/11)
        /*
        if(this.isAccessoriesSales){
            let selectedProductId = event.detail;

            this.executeAction(queryAccessoriesVarient, {
                productId : selectedProductId
            }).then(result => {
                this.selectedRecord = false;
                this.selectedRecordCode = false;
                if (result.Id) {
                    this.selectedAcc = result;
                    this.selectedName = result.Name;
                    this.selectedCode = result.ProductCode;
                }else{
                    this.selectedAcc = this.allAccesList.find(record => record.Id === event.detail);
                    this.selectedName = this.allAccesList.find(record => record.Id === event.detail).Name;
                    this.selectedCode = this.allAccesList.find(record => record.Id === event.detail).ProductCode;
                }
            });

        }else{
            console.log('== Need To Update this');
        }
        */
        this.selectedRecord = false;
        this.selectedRecordCode = false;
        this.selectedAcc = this.allAccesList.find(record => record.Id === event.detail);
        this.selectedName = this.allAccesList.find(record => record.Id === event.detail).Name;
        this.selectedCode = this.allAccesList.find(record => record.Id === event.detail).ProductCode;
        
    }

    handleNumberChange(event) {
        if (event.detail.value !== '') {
            this.selectedRecordCode = true;
            this.selectedRecord = false;
            this.selectedCode = event.detail.value;
            this.selectedType = 'Code';
            this.getAccessories(this.selectedCode);
        } else {
            this.selectedRecordCode = false;
            this.selectedRecord = false;
            this.allAccesList = null;
        }
    }

    handleQuantityChange(event) {
        this.selectedQuantity = event.detail.value;
    }

    quantityChange(event) {
        let ind = this.accesList.findIndex(record => record.Id === event.target.dataset.id);
        this.accesList[ind].quantity = event.detail.value;
        this.accesList[ind].price = event.detail.value * this.accesList[ind].unitPrice;
        this.countTotalAmontOnchange();
    }

    countTotalAmontOnchange() {
        this.totalAmount = 0;
        this.accesList.forEach(element => {
            this.totalAmount = this.totalAmount + element.price;
        });
        this.calculateFinalAmountChanges();
    }

    calculateTotalAmount(event) {
        this.setData({
            otherAccessoriesDiscount: {
                UnitPrice: event.target.value || 0
            }
        });
        this.calculateFinalAmountChanges();
    }

    calculateFinalAmountChanges() {
        let totalAmount = 0;
        let discountAmount = 0;
        if (parseInt(this.totalAmount) > 0) {
            totalAmount = parseInt(this.totalAmount);
        }
        if (parseInt(this.state.otherAccessoriesDiscount.UnitPrice) > 0) {
            discountAmount = parseInt(this.state.otherAccessoriesDiscount.UnitPrice);
        }
        this.finalAccAmount = totalAmount - discountAmount;
    }

    handleSubmitToDMS(){
        this.setData({
            // To Hold the opportunity record info in opportunityInfo json object
            opportunityInfo: {
                MGASelected : true
            }
        });

        this.handleSave();
    }

    handleSave() {
        if (this.validateInputs(".inputCmp") & this.validateInputs(".checkValid")) {
            this.setData({
                addAccessories: this.accesList
            });
            if (this.isAccessoriesSales) {
                this.executeAction(createLineItemRecords, {
                    dataList: this.toJSON(this.state)
                }).then(result => {
                    if (result === 'success' && this.state.opportunityInfo.MGASelected) {
                        this.handleReload();
                    } else if (result === 'success') {
                        this.showToast({ message: 'Line Item Addedd Successfully !', variant : 'success' });
                        this.handleReload();
                    }else{
                        this.showToast({ message: 'Insufficient privileges. Please contact your administration.'});
                    }
                })
            } else {
                this.commit().dispatchEvent('accessories');
            }
        }
    }

    handleCancel() {
        this.revert().dispatchEvent('accessories');
    }

    handleReload(){
        this.dispatchEvent('closemethod');
    }

}