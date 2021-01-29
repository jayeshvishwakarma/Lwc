import { LightningElement,api } from 'lwc';
import getObjects from '@salesforce/apex/CreateCaseController.getObjects';

export default class CreateCaseLookUp extends LightningElement {
    @api queryString;
    @api isSpinnerShow = false;
    @api iconName  = 'standard:account';
    @api selectedRecordId;
    @api selectedRecordName;
        selectedRecord;
    @api sObjectName;
    @api fieldLabel = 'Default Label';
    @api isRequired = false;
    @api isDisabled = false;
    @api placeholder='Enter text to search';

    @api isMobileDevice = false;

    sObjectList ;
    searchKey = '';
   
    isSearching =false;
    requiredSign='';
    ShowLookUpPop= false;
    isShowAllShow = false;
    recordsLength = 0;
    
    connectedCallback() {
      //  console.log(this.queryString);
        if(this.isRequired){
            this.requiredSign = '*';
        }
        if(this.selectedRecordId && this.selectedRecordName){
            let dealer = {};
            dealer.Name = this.selectedRecordName;
            dealer.Id = this.selectedRecordId;
            this.selectedRecord = dealer;
        }
    }
    getData(){
        try{
            this.error = '';
            if(!this.queryString){
                return;
            }
            if(!this.searchKey || this.searchKey === ''){
                this.clear();
                this.isShowAllShow = false;
                return;
            }
            this.isSpinnerShow = true;
            this.isSearching = true;
            getObjects({
                    'query': this.queryString,
                    'searchKey' : this.searchKey
                })
                .then(result => {
                    //console.log(JSON.parse(result));
                    if (result) {
                        this.sObjectList = JSON.parse(result);
                        this.isShowAllShow=true;
                        this.recordsLength = this.sObjectList.length;
                    }
                    this.isSpinnerShow = false;
                    this.isSearching = false;
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.isSpinnerShow = false;
                    this.isSearching = false;
                });
        }catch(e){
            console.log('Exception in getData JS method');
            console.log(e.message);
        }
    }
    clear(){
        this.sObjectList = undefined;
        this.recordsLength = 0;
    }

    handleScreenType(){
        if(this.isMobileDevice){
            const evt = new CustomEvent('hideparent');
           // this.dispatchEvent(evt);   
        }
        
    }
    handleChange(event){
        console.log(this.queryString);
        this.searchKey =event.target.value;
        this.getData();
    }
    selectRecord(event){
        this.selectedRecord = event.detail;
        this.selectedRecordId =this.selectedRecord.Id;
        this.sObjectList = undefined;
        this.searchKey = undefined;
        this.fireEvent();
        this.handleClosePopUp();
    }
    handleRemove(){
        this.selectedRecord = undefined;
        this.selectedRecordId = undefined;
        this.fireEvent();
    }
    fireEvent(){
        const evt = new CustomEvent('change',{detail : this.selectedRecord});
        this.dispatchEvent(evt);   
    }
    @api
    checkRequired(){
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if(this.selectedRecordId){
            return true;
        }
        return allValid;
        
    }
    handleShowResult(){
        this.ShowLookUpPop = true;
    }
    handleClosePopUp(){
        this.ShowLookUpPop = false;
    }
    handleSearch(event){
        console.log(event.detail);
        this.searchKey = event.detail;
        this.getData();
    }
    handleSelect(event){
        this.selectedRecord = event.detail;
        this.selectedRecordId =this.selectRecord.Id;
        this.sObjectList = undefined;
        this.searchKey = undefined;
        this.fireEvent();
    }
}