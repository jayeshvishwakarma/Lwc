/* eslint-disable no-console */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Fetch dummy data from Apex. To be replaced with continuation for final integration
import fetchSelectedSVOCDetails from '@salesforce/apexContinuation/FetchSVOCDetails.fetchSelectedSVOCDetails';
import updateDSEAccountForSVOCCounter from '@salesforce/apex/FetchSVOCDetails.updateDSEAccountForSVOCCounter';
import fetchMGAHistoryDetails from '@salesforce/apex/FetchSVOCDetails.fetchMGAHistoryDetails';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SVOC_ID_FIELD from '@salesforce/schema/Opportunity.SVOC_ID__c';
import CUSTOMER_ID_FIELD from '@salesforce/schema/Opportunity.Customer__c';
import ASSET_SVCOID_FIELD from '@salesforce/schema/Asset.Account.SVOC_ID__c';
import ACCOUNT_SVCOID_FIELD from '@salesforce/schema/Account.SVOC_ID__c';
import VIN_FIELD from '@salesforce/schema/Asset.VIN__c';

import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';
import Missing_Field_Error_Message from '@salesforce/label/c.SVOC_Detail_Missing_Fields';
import { NavigationMixin } from 'lightning/navigation';

import tempmethodapex from '@salesforce/apex/FetchSVOCDetails.tempmethod';
export default class LightningExampleAccordionBasic extends NavigationMixin(LightningElement) {
@api recordId;
@api svocsection = 'Loyalty';
@api typeOfSection = 'Table';
@api typeOfaction;

@track activeIcon = 'utility:chevronright';
@track showSpinner = false;
@track SVOC_ID;
@track errorMessage;

@track data = [];
@track columns = [];
@track rawResponse;
@track filterWrapper;
@track visibleData;
@track filteredData=[];
@wire(getRecord, { recordId: '$recordId', fields: [ SVOC_ID_FIELD, CUSTOMER_ID_FIELD] }) opportunity;
@wire(getRecord, { recordId: '$recordId', fields: [VIN_FIELD, ASSET_SVCOID_FIELD] }) asset;
@wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_SVCOID_FIELD] }) account;

get svocId() { return getFieldValue(this.opportunity.data, SVOC_ID_FIELD); }
get accsvocId() { return getFieldValue(this.account.data, ACCOUNT_SVCOID_FIELD); }
get customerId() {return getFieldValue(this.opportunity.data, CUSTOMER_ID_FIELD); }
get vin() { return getFieldValue(this.asset.data, VIN_FIELD);}
get assetSvocId(){return getFieldValue(this.asset.data, ASSET_SVCOID_FIELD);}
    
//Function called when clicked on expand/collapse section
//Sets the value of svoc data to the sections
handleToggleSection() {
this.errorMessage=null;
let inputCmp = Array.from(this.template.querySelectorAll('lightning-input'));
for (let i = 0; i < inputCmp.length; i++) {
let tempInputCmp = inputCmp[i];
tempInputCmp.value='';
}
if(this.accsvocId){
this.SVOC_ID = this.accsvocId;  
}
if(this.svocId){
this.SVOC_ID = this.svocId;  
}
    let secObj = this.template.querySelector('[data-id="detail-section"]');
    if (secObj.classList.contains('slds-is-open')) {
        secObj.classList.remove('slds-is-open');
        this.activeIcon = 'utility:chevronright';
    } else {
        secObj.classList.add('slds-is-open');
        this.activeIcon = 'utility:chevrondown';

        if(this.svocsection !== 'MGA History' && this.svocsection !== 'MGP History'){
            if (this.SVOC_ID || this.vin)  {
                //  this.fetchSelectedSVOCDetails();
                this.fetchSelectedSVOCDetailsTemp();
            } else {
                this.handleError(Missing_Field_Error_Message);
            }
        }else {
            console.log('== Before  svocId', this.svocId);
            console.log('== assetSvocId', this.assetSvocId);

            if(this.recordId.startsWith('006')){
                console.log('== 1 record Id ', this.recordId);
                this.customerSVOCId = this.svocId;
            }else{
                console.log('== 2 record Id ', this.recordId);
                this.customerSVOCId = this.assetSvocId;
            }

            console.log('== customerSVOCId ', this.customerSVOCId);
            console.log('== vin', this.vin);
            console.log('== opp customerId ', this.customerId);
            this.fetchMGAHistory(this.customerSVOCId, this.vin);

        }
    }
}
//Call server method to get the API response and show it in table
fetchSelectedSVOCDetails() {
    this.showSpinner = true;
    fetchSelectedSVOCDetails({ 
        svocDetail: this.svocsection, 
        svocId: this.SVOC_ID, 
        vin: this.vin 
    }).then(result => {
        // console.log("rawResponse", result.data.rawResponse);
        // console.log("rawResponse", JSON.parse(result.data.rawResponse));
        if (result.code === 200 && result.status === 'Success') {
            this.rawResponse=JSON.parse(result.data.rawResponse);
            this.initDataTable(result.data);
            console.log('success rahul 62');
            this.updateDSEAccountForSVOCCounter(result.data);
        } else {
            this.handleError(UI_Error_Message);
            console.log('success rahul 67');
            this.updateDSEAccountForSVOCCounter(result.data);
        }
        this.showSpinner = false;
    }).catch(error => {
        this.showSpinner = false;
        this.handleError(UI_Error_Message);
        console.error(error);
    });
}
    //Call server method  temporarly to get the API response and show it in table - Not To be deployed 
    fetchSelectedSVOCDetailsTemp() {
        console.log('k');
        this.showSpinner = true;
        tempmethodapex({ 
            svocDetail: this.svocsection 
        }).then(result => {
            console.log("rawResponse", result.data.rawResponse);
            console.log("rawResponse", JSON.parse(result.data.rawResponse));
            console.log("rawResponseDATA", result.data);
            if (result.code === 200 && result.status === 'Success') {
                this.rawResponse=JSON.parse(result.data.rawResponse);
                this.visibleData = result.data;
                if(result.data.filterWrapperList != undefined){
                    this.filterWrapper = result.data.filterWrapperList;
               
                }
                this.initDataTable(result.data);
                console.log('success rahul 62');
                // this.updateDSEAccountForSVOCCounter(result.data);
            } else {
                this.handleError(UI_Error_Message);
                console.log('success rahul 67');
                // this.updateDSEAccountForSVOCCounter(result.data);
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.handleError(UI_Error_Message);
            console.error(error);
        });
    }

/* Author : Gitika
Description : used to filter data from list
*/

filterData(event){
console.log('value'+event.target.value);
var data = new Object();
var fieldValueWrapList=[];
data.svocFielLabelList = this.visibleData.svocFielLabelList;
data.keys = this.visibleData.keys;

let inputCmp = Array.from(this.template.querySelectorAll('lightning-input'));
        for (let i = 0; i < inputCmp.length; i++) {
            let tempInputCmp = inputCmp[i];
            if(event.target.name != tempInputCmp.name){
                tempInputCmp.value='';
            }
        }

if(event.target.value && (event.target.value).length>3){

     for(var i =0 ; i<this.rawResponse.customerEnquiriesList.length;i++){
         let objValue = this.rawResponse.customerEnquiriesList[i];
         if(objValue[event.target.name] && ((objValue[event.target.name]).toLowerCase()).includes((event.target.value).toLowerCase())){
             fieldValueWrapList.push(this.visibleData.fieldValueWrapList[i]);
             }
         }
     if(fieldValueWrapList.length>0){
         this.errorMessage='';
         data.fieldValueWrapList=fieldValueWrapList;
         this.filteredData=fieldValueWrapList;
         this.initDataTable(data);
     }else{
         console.log(this.visibleData.fieldValueWrapList.length);
         this.data=[];
         if(!this.data.length){
         this.errorMessage = "No data found";
         }
     }
}else{
     if(this.visibleData.fieldValueWrapList.length>0){
         this.errorMessage='';
         console.log(this.visibleData.fieldValueWrapList.length);
         this.initDataTable(this.visibleData); 
      }
}
    
}

// fetch MGA History Details 
fetchMGAHistory(svocId, vin){
    this.showSpinner = true;
    if(svocId){

        fetchMGAHistoryDetails({
            recordId: this.recordId, 
            svocId: svocId, 
            vin: vin,
            customerId: this.customerId,
            sectionType: this.svocsection
        }).then(result => {
            if (result.code === 200 && result.status === 'Success') {
                this.initDataTable(result.data);
                console.log('success rahul 62');
                this.updateDSEAccountForSVOCCounter(result.data);
            } else {
                this.handleError('Transaction timed out, Please try again later.');
                console.log('success rahul 67');
                this.updateDSEAccountForSVOCCounter(result.data);
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.handleError('Transaction timed out, Please try again later.');
        });
    }else{
        this.showSpinner = false;
        this.handleError('SVOC ID is absent, Please update SVOC ID and try again');
    }
}

    //Call server method to update the counter of SVOC accessed on DSE account
updateDSEAccountForSVOCCounter() {
    console.log('success rahul 77');
    updateDSEAccountForSVOCCounter( 
            ).then(result => {
        console.log('success rahul 83');
    }).catch(error => {
        console.log('error', error);
    });
}
initDataTable(data) {
    let types = { 
        boolean: new Set(),
        date: new Set() 
    };
        this.data = data.fieldValueWrapList.map((item, ind1) => {
            return item.svocFieldValue.reduce((row, value, ind2) => {
                let col = data.keys[ind2];
                row[col] = this.parseValue(col, value, types);
                return row;
            }, { id: ind1 });
        });
    
    
    this.columns = data.svocFielLabelList.map((item, ind) => {
        let col = data.keys[ind];
        return {
            label: item,
            fieldName: col,
            type: types.boolean.has(col) ? 'boolean' : 
                types.date.has(col) ? 'date' : 'text'
        };
    });
    if(this.typeOfaction != undefined){
        let rowactions ={
            type: 'action',
            typeAttributes: { rowActions:[{label : this.typeOfaction,name : this.typeOfaction}] },
        }
        this.columns.push(rowactions);
    }
    this.recordsCount = String(this.data.length > 25 ? '25+' : this.data.length);
    if(!this.data.length){
        this.errorMessage = "No data found";
    }
}
parseValue(key, value, types){
    if(value){
        switch(key){
            case 'StartDate':
                types.date.add(key);
                break;
            case 'EndDate': 
                if(new Date(value) > new Date()){
                    value = "";
                }
                types.date.add(key);
                break;
            default:
        }  
        switch(value){
            case 'true': 
            case 'false':
                value = (value === 'true'); 
                types.boolean.add(key); 
                break;
            default:
        }
    }
    return value;
}
handleError(message) {
    this.errorMessage = message;
    const toastEvent = new ShowToastEvent({
        title: status,
        message: message,
        variant: 'error',
    });
    this.dispatchEvent(toastEvent);
}
handleClick(event){
    const actionName = event.detail.action.name;
    let row = event.detail.row;
    if(this.rawResponse.customerEnquiriesList){
    let detail = this.rawResponse.customerEnquiriesList[parseInt(row.id)];
    detail.personAccountId=this.recordId;
    row.personAccountId=this.recordId; 
    //  var JSON = JSON.stringify(row)
    console.log(JSON.stringify(row));
    console.log('detail'+JSON.stringify(detail));
    this[NavigationMixin.Navigate]({
        "type": "standard__component",
        "attributes": {
            "componentName": "c__CreateCaseAura", 
        },
        state: {
            c__recordId: JSON.stringify(detail)
        }
    });
}
/*     switch (actionName) {
        case 'Create Case':
            this[NavigationMixin.GenerateUrl]({
                type: "standard__objectPage",
                    attributes: {
                        "objectApiName": "Case",
                        "actionName": "new"
                    },
                state:{
                    recordId :JSON.stringify(row),
                    override: "1"
                }
            }).then(generatedUrl => {
                    console.log('final generatedUrl ', generatedUrl);
                    location.replace(generatedUrl)
                });
            break;
        default:
    }*/
}
}