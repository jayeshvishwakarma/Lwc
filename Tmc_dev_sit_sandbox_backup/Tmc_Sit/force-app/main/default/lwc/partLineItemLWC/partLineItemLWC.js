import { LightningElement, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAccessories from '@salesforce/apex/AddLineItemCtrl.getAccessories';
import getAccessoryPrice from '@salesforce/apex/AddLineItemCtrl.getAccessoryPrice';
import getPartLineItemDetails from '@salesforce/apex/PartLineItemCtrl.getPartLineItemDetails';
import ceratePartLineItemDetails from '@salesforce/apex/PartLineItemCtrl.ceratePartLineItemDetails';
import retriveQuoteTemplateInfo from '@salesforce/apex/EmailQuotePDFCtrl.retriveQuoteTemplateInfo';

export default class PartLineItemLWC extends LightningElement {

    // API Properties
    @api recordId;
    @api SObjecttype;
    @api deviceFormFactor;
    @api formType;

    // Local Variables
    sectionName = 'Add Parts and Accessories';
    headerValue = [];

    @track accesList = [];
    allAccesList;
    selectedName;
    selectedCode;

    isQuote = false;
    showData = false;
    isLoading = true;
    showConfirm = false;
    showInvoiceDetail = false;
    browserFormFactor = true;
    Opportunity;

    msgpaSelected = false;
    selectedRecord = false;
    selectedRecordCode = false;

    opportunityData;
    opportunityVariant;
    iconname = "standard:product";
    searchfield = 'Name';
    searchfieldCode = 'ProductCode';

    deafaultMinimumQty = 1;
    maxQuantity = 1000000;
    selectedQuantity;
    totalAmount = 0;
    finalAccAmount = 0;
    partOfferAmount;
    

    get showAccesList() {
        return this.accesList && this.accesList.length;
    }

    validateInputs(query) {
        return Array.from(this.template.querySelectorAll(query)).filter(input => !input.reportValidity()).length === 0;
    }

    showToast({ message, mode = '', variant = 'error' }) {
        this.dispatchEvent(new ShowToastEvent({ message, mode, variant }));
    }

    connectedCallback() {
        console.log('== this.deviceFormFactor ',this.deviceFormFactor);
        this.browserFormFactor = (this.deviceFormFactor && this.deviceFormFactor === 'DESKTOP') ? true : false;
        this.isQuote = (this.formType && this.formType === 'Quote') ? true : false;

        getPartLineItemDetails({
            recordId : this.recordId
        }).then(result => {
            console.log('== load result ', result);
            if(result){
                this.Opportunity = result;
                this.loadDetails(this.Opportunity);
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('== On load ',error);
        })

    }

    loadDetails(Opportunity){
        let opportunityKeys = Object.keys(Opportunity);
        console.log('== result ',Opportunity);
        console.log('== opportunityKeys ',opportunityKeys);

        if(opportunityKeys){
            let headerValueData = [];
            headerValueData.push(opportunityKeys.includes('SVOC_Customer_Name__c') ? 'Customer Name : ' + Opportunity.SVOC_Customer_Name__c : '');
            headerValueData.push(opportunityKeys.includes('DMS_Enquiry_Name__c') ? 'DMS Enquiry Number : ' + Opportunity.DMS_Enquiry_Name__c : '');
            console.log('== headerValueData ',headerValueData);
            this.headerValue = [];
            this.headerValue = headerValueData;
            console.log('== headerValue ',this.headerValue);

            this.showConfirm = (Opportunity.StageName === 'New') ? true : false;
            this.showInvoiceDetail =((Opportunity.StageName === 'Partially Invoiced' || Opportunity.StageName === 'Invoiced') && !this.isQuote) ? true : false;

            if(opportunityKeys.includes('OpportunityLineItems')){
                this.loadLineItemDetails(Opportunity.OpportunityLineItems);
            }

            let opportunityDataValue = {
                Name : opportunityKeys.includes('Name') ? Opportunity.Name : '',
                Variant__c : opportunityKeys.includes('Variant__c') ? Opportunity.Variant__c : '',
                Email__c : opportunityKeys.includes('Email__c') ? Opportunity.Email__c : '',
                Mobile__c : opportunityKeys.includes('Mobile__c') ? Opportunity.Mobile__c : '',
                Pricebook2Id : opportunityKeys.includes('Pricebook2Id') ? Opportunity.Pricebook2Id : '',
            };

            this.opportunityData = opportunityDataValue;

            if(opportunityKeys.includes('Variant__c')){
                this.opportunityVariant = Opportunity.Variant__c;
            }
            if(opportunityKeys.includes('Name')){
                this.opportunityName = Opportunity.Name;
            }
            console.log('== this.showConfirm ', this.showConfirm);
        }

        this.showData = true;
        this.isLoading = false;
    }

    loadLineItemDetails(lineItemsRecords){
        if(lineItemsRecords){
            let selectedParts = [];
            for (var value of lineItemsRecords) {
                console.log('== value.PricebookEntry.Product2.Name ', value.PricebookEntry.Product2.Name);
                if(value.PricebookEntry.Product2.Name !== 'Offer'){
                    let selectedPartRec = {
                        Id : value.PricebookEntry.Product2Id,
                        Name : value.PricebookEntry.Product2.Name,
                        quantity : value.Quantity,
                        ProductCode : value.PricebookEntry.Product2.ProductCode,
                        Status__c : value.Status__c,
                        price : value.UnitPrice * value.Quantity,
                        unitPrice : value.UnitPrice,
                        priceBookEntryId : value.PricebookEntry.Id,
                        Invoice_Number__c : value.Invoice_Number__c,
                        Invoice_Date__c : value.Invoice_Date__c
                    };
                    selectedParts.push(selectedPartRec);
                }else if(value.PricebookEntry.Product2.Name === 'Offer'){
                    let offerValue = value.UnitPrice;
                    console.log('== offerValue ', offerValue);
                    this.partOfferAmount = !isNaN(offerValue) ? Math.abs(value.UnitPrice) : undefined;
                }
            }
            if(selectedParts){
                this.accesList = [];
                this.accesList = selectedParts;
                this.countTotalAmontOnchange();
            }
        }

    }

    // Handle quantity change of any parts
    quantityChange(event) {
        let ind = this.accesList.findIndex(record => record.Id === event.target.dataset.id);
        this.accesList[ind].quantity = event.detail.value;
        this.accesList[ind].price = event.detail.value * this.accesList[ind].unitPrice;
        this.countTotalAmontOnchange();
    }

    // Handle delete single parts from selection
    deleteAccessory(event) {
        let ind = this.accesList.findIndex(record => record.Id === event.target.dataset.id);
        this.accesList.splice(ind, 1);
        this.countTotalAmontOnchange();
    }

    calculateTotalAmount(event) {
        console.log('== In calculate Part Offer amount ', event.target.value);
        this.partOfferAmount = event.target.value;
        
        this.calculateFinalAmountChanges();
    }

    countTotalAmontOnchange() {
        this.totalAmount = 0;
        this.accesList.forEach(element => {
            this.totalAmount = this.totalAmount + element.price;
        });
        this.calculateFinalAmountChanges();
    }

    calculateFinalAmountChanges() {

        let totalAmount = 0.0;
        let discountAmount = 0.0;
        if (parseFloat(this.totalAmount) > 0) {
            totalAmount = parseFloat(this.totalAmount);
        }

        if (parseFloat(this.partOfferAmount) > 0) {
            discountAmount = this.partOfferAmount;
        }
        this.finalAccAmount = totalAmount - discountAmount;
    }

    // Search Parts and Accessories Name
    handleNameChange(event) {
        this.isLoading = true;
        if (event.detail.value && this.Opportunity) {
            this.selectedName = event.detail.value;
            this.selectedType = 'Name';
            this.getAccessories(this.selectedName);
        } else {
            this.isLoading = false;
            this.allAccesList = null;
        }
    }

    // Search Parts and Accessories Code
    handleNumberChange(event) {
        this.isLoading = true;
        if (event.detail.value) {
            this.selectedRecordCode = true;
            this.selectedRecord = false;
            this.selectedCode = event.detail.value;
            this.selectedType = 'Code';
            this.getAccessories(this.selectedCode);
        } else {
            this.isLoading = false;
            this.selectedRecordCode = false;
            this.selectedRecord = false;
            this.allAccesList = null;
        }
    }

    getAccessories(searchKey) {
        getAccessories({
            enquiryRecordType: this.Opportunity.RecordType.Name,
            model: null,
            var: searchKey,
            type: this.selectedType
        }).then(result => {
            if (result && result.code === 200) {
                console.log('== All Acc/Parts ', result);
                this.allAccesList = [];
                this.allAccesList = result.dataList;
                console.log('== In getAccessories ', this.allAccesList);
                if (this.selectedRecordCode === false) {
                    this.selectedRecord = true;
                }
                this.isLoading = false;
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('== On get Accessories ',error);
        })
    }

    // Handle Quantity change
    handleQuantityChange(event) {
        this.selectedQuantity = event.detail.value;
    }

    // Handle selecttion process for Parts
    handleSelect(event) {
        this.selectedRecord = false;
        this.selectedRecordCode = false;
        this.selectedAcc = this.allAccesList.find(record => record.Id === event.detail);
        console.log('== In handleSelct ', this.selectedAcc);
        this.selectedName = this.allAccesList.find(record => record.Id === event.detail).Name;
        this.selectedCode = this.allAccesList.find(record => record.Id === event.detail).ProductCode;
        
    }

    addAccessory() {
        this.isLoading = true;
        if (this.validateInputs('lightning-input')) {
            let findResult = this.accesList.find(record => record.Id === this.selectedAcc.Id);
            if (!findResult) {
                
                let selectedAccess = {
                    Id : this.selectedAcc.Id,
                    Name : this.selectedName,
                    quantity : this.selectedQuantity,
                    ProductCode : this.selectedAcc.ProductCode,
                    Status__c : 'Open'
                };
                getAccessoryPrice({ productId: this.selectedAcc.Id }).then(result => {
                    if(result.code === 200){
                        selectedAccess.price = result.dataList[0].UnitPrice * this.selectedQuantity;
                        selectedAccess.unitPrice = result.dataList[0].UnitPrice;
                        selectedAccess.priceBookEntryId = result.dataList[0].Id;
                        //selectedAccess.ProductCode = result.dataList[0].ProductCode;
                        this.accesList.push(selectedAccess);
                        this.selectedName = '';
                        this.selectedQuantity = '';
                        this.selectedCode = '';
                        this.totalAmount = this.totalAmount + parseInt(selectedAccess.price);

                        console.log('== this.accesList ', this.accesList);

                        this.calculateFinalAmountChanges();
                        this.showToast({message: 'Item added successfully', variant : 'success'});
                    }else{
                        this.showToast({message: 'Price not found.'});
                    }
                    this.isLoading = false;
                }).catch(error => {
                    this.isLoading = false;
                })
            } else {
                this.isLoading = false;
                this.showToast({message: 'This item is already added'});
            }
        }
    }

    // Handle Submit to DMS funcationality
    handleSubmitToDMS(){
        this.msgpaSelected = true;
        this.handleSave();
    }


    // Handle Save button funcationality
    handleSave() {
        this.isLoading = true;

        console.log('== Final Parts List ', this.accesList);
        if (this.validateInputs(".inputCmp") & this.validateInputs(".checkValid")) {
            ceratePartLineItemDetails({
                recordList : JSON.stringify(this.accesList),
                recordId : this.recordId,
                opportunityData : JSON.stringify(this.opportunityData),
                formType : this.formType,
                msgpaSelected : this.msgpaSelected,
                partOfferAmount : this.partOfferAmount
            }).then(result => {
                
                console.log('== load result ', result);
                if (result === 'success' && this.msgpaSelected) {
                    this.handleReload();
                } else if (result === 'success' && !this.msgpaSelected) {
                    this.showToast({ message: 'Line Item Added Successfully !', variant : 'success' });
                    this.handleReload();
                }else{
                    this.showToast({ message: 'Insufficient privileges. Please contact your administration.'});
                }
                this.isLoading = false;
            }).catch(error => {
                this.isLoading = false;
                console.log('== On load ',error);
            })
        }

    }

    // Handle Create Quote 
    createQuotation(){
        this.isLoading = true;
        if (this.validateInputs(".inputCmp") & this.validateInputs(".checkValid")) {
            
            ceratePartLineItemDetails({
                recordList : JSON.stringify(this.accesList),
                recordId : this.recordId,
                opportunityData : JSON.stringify(this.opportunityData),
                formType : this.formType,
                msgpaSelected : this.msgpaSelected,
                partOfferAmount : this.partOfferAmount
            }).then(result => {
                
                console.log('== quote result ', result);
                let quoteId = result.split('#')[0];
                let message = result.split('#')[1];
                if(message === 'success' && quoteId){
                    retriveQuoteTemplateInfo({
                        recordId : quoteId
                    }).then(result1 => {
                        if(result1){
                            let quoteDetail = { recordId: quoteId };
                            this.dispatchEvent(new CustomEvent("quotecreatesuccess", { detail : quoteDetail }));
                            if(this.opportunityData.Email__c){
                                this.showToast({ message: 'The quote is being sent to the Customer.', variant : 'success' });
                            }else{
                                this.showToast({ message: 'The quote is generated successfully!', variant : 'success' });
                            }
                            // this.handleReload();
                        }
                        this.isLoading = false;
                    }).catch(error => {
                        this.isLoading = false;
                        console.log('== On load ',error);
                    })
                }
            }).catch(error => {
                this.isLoading = false;
                console.log('== On load ',error);
            })

        }

    }

    // Handle close popup action
    handleReload(){
        this.dispatchEvent(new CustomEvent('CloseCmp'));
        
    }
}