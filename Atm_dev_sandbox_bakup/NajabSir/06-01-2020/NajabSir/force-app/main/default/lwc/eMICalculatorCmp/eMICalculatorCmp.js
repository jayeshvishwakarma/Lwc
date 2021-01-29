/* eslint-disable radix */
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import isHostessProfile from '@salesforce/apex/StockCheckCtrl.isHostessProfile';
import queryFinancierRecords from '@salesforce/apex/EmiCalculatorCtrl.queryFinancierRecords';
import retrieveEnquiryDetails from '@salesforce/apex/EmiCalculatorCtrl.retrieveEnquiryDetails';

import Hostess_Profile_Name from '@salesforce/label/c.Hostess_Profile_Name';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Calculate_EMI_Amount from '@salesforce/label/c.Calculate_EMI_Amount';

export default class EMICalculatorCmp extends LightningElement {
    @api recordId;
    @api financeAmount;
    @api financierName;
    @api financierId;
    @api showFinancier;
    
    @api emiRate;
    @api emiTenure;
    @api downpayment;

    @api minnumbr= '10000';
    @api maxnumbr='2000000';
    @api showHeader = false;
    charcode;
    @track loanamountt;
    @track InterestRate;
    @track LoanTenure;
    emi;
    @track monthlyIntersetRatio;
    @track TotalAmountPayable;
    @track TotalInterestPayable;
    @track LoanEMii;
    @track checkbool = false;
    @track loanamountt2;
    @track LoanEMii2;
    @track emi2;
    @track tenure = 'month';
    @track hideComponent = false;

    @track records;
    @track error;
    iconname = "standard:product";
    objectName = 'Product2';
    searchfield = 'Name';
    @track selectedFinancier = '';
    dealerMapCode = ''
    @track downpaymentAmt;



    //Method to get called on load of the component
    connectedCallback(){
        console.log('== financeAmount ', this.financeAmount);

        if(this.financierName && this.financierId){
            this.selectedFinancier = {
                Name : this.financierName,
                Id : this.financierId
            }
        }
        
        if(this.financeAmount){
            this.loanamountt = this.financeAmount;
        }

        if(this.downpayment){
            this.downpaymentAmt = this.downpayment;
        }
        if(this.emiRate){
            this.InterestRate = this.emiRate;
        }
        if(this.emiTenure){
            this.LoanTenure = this.emiTenure;
        }

        console.log('== this.selectedFinancier ', this.selectedFinancier);
        retrieveEnquiryDetails({enquiryId : this.recordId})
        .then(result => {
            console.log('== dealerMapCode ', result);
            this.dealerMapCode = result;
        }) 
        .catch(error => {
            this.error = error;
        });
        this.handleLoad();        
    }

    //Map the result from server side to a javascript variable.
    handleLoad() {
        isHostessProfile({})
        .then(result => {
            console.log('== profile check result ', result);
            console.log('== profile check Hostess_Profile_Name  ', Hostess_Profile_Name);
            if(result && result === Hostess_Profile_Name){
                this.hideComponent = true;
            }else{
                this.hideComponent = false;
            }
            
        }) 
        .catch(error => {
            this.error = error;
        });
    } 

    //
    get isHostessCheck(){
        return this.hideComponent===true ? 'slds-container_x-large' : 'slds-container_x-large container';
    }

    get headerCheck(){
        return this.showHeader===true ? 'slds-page-header' : 'slds-page-header slds-hide';
    }

    isNumber(event){
        this.charcode = (event.which) ? event.which : event.keyCode;
        if(this.charcode !==46 && this.charcode >31 &&( this.charcode<48||this.charcode>57)){
            event.preventDefault();
        }
        return true;
    }

    get tenureoptions() {
        return [
            { label: 'Month', value: 'month' },
            { label: 'Year', value: 'year' },
        ];
    }

    handleamount(event){
        this.loanamountt = event.target.value;
    }

    handleinterest(event){
        this.InterestRate = event.target.value;
    }
  

    handletenure(event){
        this.LoanTenure = event.target.value;

    }

    handlecheck(event){
        this.checkbool = event.target.checked;
        
    }

    changeTenure(event){
        if(this.LoanTenure!==null && this.LoanTenure!==undefined){
            if(event.target.value==='month')
                this.LoanTenure = this.LoanTenure*12;
            else
                this.LoanTenure = this.LoanTenure/12;
        }
    }
    
    validateDetails(){
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

            return allValid;
    }

    validateZero(){ 
        var fieldLabel;
        var isValid = true;
        if(this.loanamountt===0 || parseInt(this.LoanTenure)===0 || parseInt(this.InterestRate)===0){
            if(this.loanamountt===0)
                fieldLabel = 'Loan Amount';
            if(parseInt(this.LoanTenure)===0)
                fieldLabel = 'Loan Tenure';
            if(parseInt(this.InterestRate)===0)
                fieldLabel = 'Interest Rate';
            
            isValid = false;
            
        }
        
        if(!isValid){
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: fieldLabel+ ' cannot be zero',
                variant: 'error',
                mode: 'dismissable'
            }); 
            this.dispatchEvent(evt);
        } 
        return isValid;
    }

    calculateemi(){
          
        if(this.validateDetails() && this.validateZero()){
        
            let selTenure = this.template.querySelector('[data-id="loantenureterm"]').value;
            let actualTenure = this.LoanTenure;
            if(selTenure==='year')
                actualTenure =  actualTenure*12;  

            if(this.checkbool){
                this.loanamountt2 = this.loanamountt;
                this.monthlyIntersetRatio = this.InterestRate/1200;
                
                this.emi = (this.loanamountt2 * (this.monthlyIntersetRatio) * Math.pow((1+this.monthlyIntersetRatio),actualTenure)) / (((Math.pow((1 + (this.monthlyIntersetRatio)), actualTenure)) - 1)*(1+this.monthlyIntersetRatio));
                 
                this.LoanEMii = Math.round(this.emi);
                this.TotalAmountPayable = Math.round(this.emi * actualTenure);
                this.TotalInterestPayable = Math.round(this.TotalAmountPayable)*1 - this.loanamountt2 * 1 ;
            }

            else{
                
                this.monthlyIntersetRatio = this.InterestRate/1200;
                this.emi = this.loanamountt * this.monthlyIntersetRatio / (1-(Math.pow(1/(1+this.monthlyIntersetRatio),actualTenure)));
                this.LoanEMii = Math.round(this.emi);
                this.TotalAmountPayable = Math.round(this.emi * actualTenure);
                this.TotalInterestPayable = Math.round(this.TotalAmountPayable)*1 - this.loanamountt * 1 ;
                 

            }

            const emiCalculatedEvent = new CustomEvent('emiCalculated', {
                detail: { "premium" : this.emi , "financeAmt" : this.loanamountt},
            });
            // Fire the custom event
            this.dispatchEvent(emiCalculatedEvent);

        }
    }

    handleOnchange(event) {
        const searchKey = event.detail.value;
        console.log('== Financier searchKey '+searchKey);

        queryFinancierRecords({
            name: searchKey,
            dealerMapCode: this.dealerMapCode
        }).then(result => {
            console.log('== Financier result ', result);
            this.records = result;
        }).catch(error => {
            this.error = error;
        });
    }

    handleSelect(event) {
        console.log('== Financier searchKey event '+event);
        const selectedRecordId = event.detail;
        this.selectedFinancier = this.records.find(record => record.Id === selectedRecordId);

        this.dispatchEvent(new CustomEvent('FinancierSelect', {
            detail: { "financireName" : this.selectedFinancier.Name , "financireId" : this.selectedFinancier.Id},
        }));

    }

    handleDownPayment(event){
        this.downpaymentAmt = event.target.value;
    }

    handleRemove(event) {
        this.records = null;
        this.selectedFinancier = null;
        console.log('== Remove Method '+event);
    }

    handlePrevious(){
        console.log('== In LWC Previous');
        this.dispatchEvent(new CustomEvent('previous'));
    }

    get makeRequire(){
        return ((this.LoanEMii && this.TotalAmountPayable && this.TotalInterestPayable) ||
        !this.financeAmount ) ? true : false;
    }

    handleNext(){
        console.log('== In LWC Next', this.toCheckInputFieldValue());
        if( this.toCheckInputFieldValue()){
            this.dispatchEvent(new CustomEvent('next', {
                detail: {   
                    "financeAmt" : this.loanamountt ? this.loanamountt : 0 , 
                    "emiRate" : this.InterestRate,
                    "emiTenure" : this.LoanTenure,
                    "downpayment" : this.downpaymentAmt
                },
            }));
        }else{
            this.dispatchEvent(new ShowToastEvent({title: '',
                message: Calculate_EMI_Amount,
                variant: 'error'
            }));
        }
        
    }

    toCheckInputFieldValue(){
        let valid = false;

        if((!this.loanamountt && !this.InterestRate && !this.LoanTenure) ||
            (this.loanamountt && this.InterestRate && this.LoanTenure && 
            this.LoanEMii && this.TotalAmountPayable && this.TotalInterestPayable)){
            valid = true;
        }else{
            valid = false;
        }

        return valid;
    }

}