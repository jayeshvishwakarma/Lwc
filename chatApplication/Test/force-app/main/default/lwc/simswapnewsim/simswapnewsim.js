/* eslint-disable consistent-return */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import fetchActivePMRecords from '@salesforce/apex/SimSwapComponentController.fetchActivePMRecords';
import fetchAllAccounts from '@salesforce/apex/SimSwapComponentController.fetchAllAccounts';
import fetchHuidigeProviders from '@salesforce/apex/SimSwapComponentController.fetchHuidigeProviders';
import saveRecords from '@salesforce/apex/SimSwapComponentController.saveRecords';
import callGrexxService from '@salesforce/apex/SimSwapComponentController.callGrexxService';

export default class Simswapnewsim extends LightningElement { 
    
    @api selectedPortMobId;    
    @track ActivateSim = false; 
    @track NewMobileSubscription = false;
    @track NewNumber = false;
    @track Portering = false; 
    pmrecords = [];
    providers = [];
    @track pm  = {}; 
    @track selectProduct;
    @track selectedProvider;
    @track inputSimKaartNumber = '';
    @track label = '';
    @track inputPorteringName = '';
    @track inputKlantnummer = '';
    @track inputVamo;
    @track errMsg;
    @track isSuccess = false;
    allAccounts = [];    
    @track selAcc = {};
    

    fetchPmRecords(accId){
        fetchActivePMRecords({accId : accId })
        .then(result => {            
            console.log(result);
            this.pmrecords = result;                      
        })
        .catch(error => {
            console.log('fetchActivePMRecords Error', error);            
        });
    } 

   
    accountChange(event){
        console.log(event.target.value);
        let accId = event.target.value;
        this.fetchPmRecords(accId);
        this.pm=null;
        if(this.allAccounts){
            this.allAccounts.map(accR => {
                if(accR.Id === event.target.value){
                    this.selAcc = accR;
                }
            })
        }
    }
    typeChange(event){
        if(event.target.value === 'NewMobileSubscription'){
            this.NewMobileSubscription = true;  
            this.ActivateSim = false;  
            this.NewNumber = false;
            this.Portering = false;
        }
        if(event.target.value === 'ActivateSim'){
            this.ActivateSim = true;   
            this.NewMobileSubscription = false; 
            this.NewNumber = false;
            this.Portering = false;
        }
        if(event.target.value === 'NewNumber'){
            this.Portering = false;   
            this.NewNumber = true;
        }
        if(event.target.value === 'Portering'){
            this.Portering = true;   
            this.NewNumber = false;
        }        
    }

    pmChange(event){
        if(this.pmrecords){
            this.pmrecords.map(pmR => {
                if(pmR.Id === event.target.value){
                    this.pm = pmR;
                }
            })
        }
        
    }

    get simKaartNumber(){
        //console.log(this.NewMobileSubscription, this.ActivateSim, this.NewNumber, this.selectedProvider);
        if(this.Portering){
            switch(this.selectedProvider) {
                case 'KPN Service Provider Mobiel (KPN Telecom mobile)':
                case 'RoutIt Mobiel (KPN Telecom mobile)':
                case 'Sympac (KPN Telecom mobile)':
                case 'Telfort Mobile (Telfort Mobile)':
                case 'Yes telecom (KPN Telecom mobile)':
                case 'Dekatel (KPN Telecom mobile)':
                case 'Mobile Services (KPN Telecom mobile))':
                case '':
                case undefined:
                  return false;
                default:
                  return true;
              }
        }else if(this.ActivateSim  || (this.NewMobileSubscription && this.NewNumber)){
            return true;
        }
        return false;
    }

    isPorteringName(){
        if(this.Portering){
            switch(this.selectedProvider) {
                case 'KPN Service Provider Mobiel (KPN Telecom mobile)':
                case 'RoutIt Mobiel (KPN Telecom mobile)':
                case 'Sympac (KPN Telecom mobile)':
                case 'Telfort Mobile (Telfort Mobile)':
                case 'Yes telecom (KPN Telecom mobile)':
                case 'Dekatel (KPN Telecom mobile)':
                case 'Mobile Services (KPN Telecom mobile))':
                  return true;
                default:
                  return false;
              }
        }
        return false;
    }
    get products(){
        let flags = [], output = [];
        if(this.pmrecords){
        let l = this.pmrecords.length, i;
        for(  i=0; i<l; i++) {
            if( flags[this.pmrecords[i].Product_KPN_EEN__c]) continue;
            flags[this.pmrecords[i].Product_KPN_EEN__c] = true;
            output.push(this.pmrecords[i]);
        }
    }
        return output;
    }
    productChange(event){
        if(this.pmrecords){
        this.pmrecords.map(pmR => {
            if(pmR.Product_KPN_EEN__c === event.target.value){
                this.selectProduct = pmR;
            }
        })
    }
        
    }

    providerChange(event){
        this.selectedProvider = event.target.value;
    }

    handleVamoChange(event){
        this.inputVamo = event.target.checked;
    }

    handleSubmit(evt){
        evt.preventDefault();
        this.errMsg = null;
        if(this.isValid()){
            let spinner = this.template.querySelector(".processing");
            spinner.classList.add("show");                                                                         
            
            let localPmId = '';
            
            if(this.selectedPortMobId)
                localPmId = this.selectedPortMobId;
            
            console.log('this.inputSimKaartNumber' , this.inputSimKaartNumber);            
            console.log('this.inputKlantnummer' , localPmId);   

            let config = {
                            pmId: localPmId,
                            selectionType: 'ActivateSim',
                            simKaartNumber: this.inputSimKaartNumber,
                            name: '',
                            product: '',
                            vamo: 'false',
                            label: '',
                            klantnumber: '',
                            huidigeProvider: '',
                            selectedAccount: ''
                        };
            console.log('--- ' , config);
            saveRecords({configData: JSON.stringify(config)})
                .then(result => {
                    console.log('result', result);
                    if(result && result.startsWith('Error:')){
                        spinner.classList.remove("show");
                        this.errMsg = result;
                        return false;
                    }
                    
                    
                    if( result ) {
                        let response = JSON.parse(result);
                        console.log('response', response);
                        if(response && response.isWebCall === 'true') {
                            //call web callout
                            let webResonse = this.callGrexxWebService(response.pmId);
                            console.log('webResonse', webResonse);
                        }else {
                            spinner.classList.remove("show");
                            this.isSuccess = true;
                            this.errMsg = '';
                        }
                        
                    }
                    
                })
                .catch(error => {
                    spinner.classList.remove("show");
                    console.log('inside catch', error)
                    this.errMsg = error;
                });
        }
    }
    callGrexxWebService(pmId) {
        let spinner = this.template.querySelector(".processing");
        console.log('callGrexxService calling');
        callGrexxService({pmId : pmId })
        .then(result => {
            console.log('web callout result', result);
            if(result && result.startsWith('Error:')) {
                this.errMsg = result;
            }
            this.isSuccess = true;
            spinner.classList.remove("show");
        })
        .catch(error => {
            console.log('web callout error', error);
            this.errMsg = error;
            spinner.classList.remove("show");
        });
    }
    isValid(){
        
        if( (!this.inputSimKaartNumber || (this.inputSimKaartNumber.trim().length !== 8 
            && this.inputSimKaartNumber.trim().length !== 19))) {
            //console.log('active sim field is require11');
            this.addError('simKaartNum', "Een SIM-kaartnummer bestaat uit 8 of 19 cijfers");
            return false;
        }
        this.removeError('simKaartNum');
        
        return true;
    }


    addError(elementClass, errorMsg){
        //console.log('addError called');
        if(!(elementClass || errorMsg)) return false;
        let selectType = this.template.querySelector(`.${elementClass}`);
        if(!selectType) return false;
        selectType.classList.add("error");
        this.errMsg = errorMsg;
    }

    removeError(elementClass){
        //console.log('removeError called');
        if(!(elementClass)) return false;
        //console.log('elementClass ' + elementClass);
        let selectType = this.template.querySelector(`.${elementClass}`);
        if(!selectType) return false;
        selectType.classList.remove("error");
        this.errMsg = '';
    }
/*
    simKaartNumChange(event){
        this.inputSimKaartNumber = event.target.value;
    }

    inpPorteringNameChange(event){
        this.inputPorteringName = event.target.value;
    }

    labelChange(event){
        this.label = event.target.value;
    }

    inputKlantnummerChange(event) {
        this.inputKlantnummer = event.target.value;
    }
*/
    setInputValueOnChange(event) {
        console.log(event.target.name);
        if(! (event && event.target && event.target.name) ){
            return false;
        }
        if(event.target.name === 'simKaartNum'){
            this.inputSimKaartNumber = event.target.value;
        }else if(event.target.name === 'Portering'){
            this.inputPorteringName = event.target.value;
        }else if(event.target.name === 'Label'){
            this.label = event.target.value;
        }else if(event.target.name === 'Klantnummer'){
            this.inputKlantnummer = event.target.value;
        }
    }

    isNumberKey(evt){
        let charCode = (evt.which) ? evt.which : evt.keyCode;
        if (charCode > 31 && (charCode < 48 || charCode > 57)){
            evt.preventDefault();
        }
    }

    isEmptyObject(obj) {
        for(let key in obj) {
            if(obj.hasOwnProperty(key))
                return false;
        }
        return true;
    }
    
}