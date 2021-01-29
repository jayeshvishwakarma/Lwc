/* eslint-disable consistent-return */
/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import fetchActivePMRecords from '@salesforce/apex/SimSwapComponentController.fetchActivePMRecords';
import fetchAllAccounts from '@salesforce/apex/SimSwapComponentController.fetchAllAccounts';
import fetchHuidigeProviders from '@salesforce/apex/SimSwapComponentController.fetchHuidigeProviders';
import saveRecords from '@salesforce/apex/SimSwapComponentController.saveRecords';
import callGrexxService from '@salesforce/apex/SimSwapComponentController.callGrexxService';
export default class Simswap extends LightningElement { 
    
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

    @wire(fetchAllAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.allAccounts = data;
            if(this.allAccounts.length > 0){
                console.log(this.allAccounts[0].Id);
                this.fetchPmRecords(this.allAccounts[0].Id);
                this.selAcc = this.allAccounts[0];
            }
            
        } else if (error) {
            console.log(error);            
        }
    }

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

    @wire(fetchHuidigeProviders)
    providers; 
    
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
            let selectionType = '';
            if(this.ActivateSim){
                selectionType = 'ActivateSim';
            }else if(this.NewNumber){
                selectionType = 'NewNumber';
            }else if(this.isPorteringName()){
                selectionType = 'PorteringName';
            }else if(!this.isPorteringName()){
                selectionType = 'PorteringNumber';
            }
            let selProduct = ''; 
            if(this.selectProduct)
                selProduct = this.selectProduct.Product_KPN_EEN__c;
            console.log('selProduct', this.pm);
            console.log('selProduct', selProduct);
            console.log('this.selectionType' , selectionType);
            console.log('this.selectedProvider' , this.selectedProvider);
            console.log('this.inputSimKaartNumber' , this.inputSimKaartNumber);
            console.log('this.inputPorteringName' , this.inputPorteringName);
            console.log('this.inputVamo' , this.inputVamo);
            console.log('this.label' , this.label);
            console.log('this.inputKlantnummer' , this.inputKlantnummer);
            console.log('this.selAcc' , this.selAcc);
            
            let localPmId = '';
            let localAccId = '';
            if(this.pm != null && this.pm.Id)
                localPmId = this.pm.Id;

            if(this.selAcc)
                localAccId = this.selAcc.Id;

            let config = {
                            pmId: localPmId,
                            selectionType: selectionType,
                            simKaartNumber: this.inputSimKaartNumber,
                            name: this.inputPorteringName,
                            product: selProduct,
                            vamo: this.inputVamo ? 'true' : 'false',
                            label: this.label,
                            klantnumber: this.inputKlantnummer,
                            huidigeProvider: this.selectedProvider,
                            selectedAccount: localAccId
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
        //Validations
        let porteringName = (this.isPorteringName()) ? 'isPorteringName': 'PorteringNumber';
        if(!(this.ActivateSim || this.NewMobileSubscription)){
            this.addError('selectType', "Verplicht: Type aanvraag");
            return false;
        }
        this.removeError('selectType');
        
        if(this.ActivateSim && this.isEmptyObject(this.pm)) {
            this.addError('porter-mobile', "Verplicht: Mobiel nummer");
            return false;
        }
        this.removeError('porter-mobile');

        if(this.NewMobileSubscription && !this.NewNumber && !this.Portering ) {
            this.addError('nummer-behoud', "Verplicht: Nieuw nummer");
            return false;
        }   
        this.removeError('nummer-behoud');


        if( this.ActivateSim && (!this.inputSimKaartNumber || (this.inputSimKaartNumber.trim().length !== 8 
            && this.inputSimKaartNumber.trim().length !== 19))) {
            //console.log('active sim field is require11');
            this.addError('simKaartNum', "Een SIM-kaartnummer bestaat uit 8 of 19 cijfers");
            return false;
        }
        this.removeError('simKaartNum');
        
        if(this.NewMobileSubscription && this.NewNumber &&  (!this.inputSimKaartNumber || 
            (this.inputSimKaartNumber.trim().length !== 8 && this.inputSimKaartNumber.trim().length !== 19))) {
            //console.log('active sim field is require22');
            this.addError('simKaartNum', "Een SIM-kaartnummer bestaat uit 8 of 19 cijfers"); 
            return false;
        } 
        this.removeError('simKaartNum');

        if(this.NewMobileSubscription && this.Portering && (!this.selectedProvider || this.selectedProvider.trim().length === 0)) {
            //console.log('huidige-provider is blank');
            this.addError('huidige-provider', "Verplicht: Huidige provider"); 
            return false;
        }
        this.removeError('huidige-provider');

        if(this.NewMobileSubscription && this.Portering && (!this.inputKlantnummer || this.inputKlantnummer.trim().length === 0 )) {
            //console.log('huidige-provider is blank');
            this.addError('klant-nummer', "Verplicht: Klantnummer bij huidige provider"); 
            return false;
        }
        this.removeError('klant-nummer');
        
        if(this.NewMobileSubscription &&  this.Portering && porteringName === 'PorteringNumber' &&  
        (!this.inputSimKaartNumber || (this.inputSimKaartNumber.trim().length !== 8 && this.inputSimKaartNumber.trim().length !== 19))) {
            //console.log('active sim field is require33');
            this.addError('simKaartNum', "Een SIM-kaartnummer bestaat uit 8 of 19 cijfers"); 
            return false;
        }
        this.removeError('simKaartNum');

        if(this.NewMobileSubscription && this.Portering && !this.selectProduct ) {
            //console.log('mobile-product is blank');
            this.addError('mobile-product', "Verplicht: KPN ÉÉN Mobiel product"); 
            return false;
        }
        this.removeError('mobile-product');
        
        if(this.NewMobileSubscription && this.NewNumber && !this.selectProduct) {
            //console.log('selectProduct is blank', this.selectProduct);
            this.addError('mobile-product', "Verplicht: KPN ÉÉN Mobiel product"); 
            return false;
        }
        this.removeError('mobile-product');
        
        if(this.NewMobileSubscription && this.Portering && !this.inputPorteringName) {
            this.addError('portering-name', `Noteer bij een portering de 8 cijfers van het 06-nummer of de 9 cijfers van het 097-nummer
                             (Data only) of Nieuw wanneer het een nieuwe aansluiting betreft`); 
            return false;
        }
        this.removeError('portering-name');

        
        if(this.NewMobileSubscription && this.Portering && (this.inputPorteringName.trim().length < 8 ||
            this.inputPorteringName.trim().length > 9)) {
            this.addError('portering-name', `Noteer bij een portering de 8 cijfers van het 06-nummer of de 9 cijfers van het 097-nummer
                             (Data only) of Nieuw wanneer het een nieuwe aansluiting betreft`); 
            return false;
        }
        this.removeError('portering-name');
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