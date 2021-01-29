/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import checkLoggedinUserType from '@salesforce/apex/ChangeOwnerFunctionality.checkLoggedinUserType';
import userList from '@salesforce/apex/ChangeOwnerFunctionality.getUserList';
import changeOwner from '@salesforce/apex/ChangeOwnerFunctionality.changeOwner';

import {getRecord} from 'lightning/uiRecordApi';

import changeAuthCheckErrorMessage from '@salesforce/label/c.Error_Message_Change_Owner_Auth_Check';
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';

const DELAY = 300;
export default class ChangeOwnerLWC extends NavigationMixin(LightningElement) {

    @api recordId;

    @track partnerUser;
    @track showList;
    @track selectedRecord;
    @track loadSpinner;
    
    record;
    iconname = "standard:user";
    searchfield = 'Name';
    dealerAccount;
    
    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.DSE_MSPIN__c'] })
    wiredOpportunity({ error, data }) {
        console.log('Inside wiredOpportunity');
        console.log('data----------->'+data);
        if (data) {
            this.record = data;
        }
        else{
            console.log(error);
        }
    }

    connectedCallback(){
        window.clearTimeout(this.delayTimeout);
        //const searchKey = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
        checkLoggedinUserType({recordId : this.recordId})
        .then(result =>{
            console.log('== result ', result);
            //console.log(result.dataList[0].Contact);
            if(result.dataList.length>0 && this.record.recordTypeInfo !== null && this.record.recordTypeInfo.name!=='Accessories Sales')
            {
                this.dealerAccount=result.dataList[0].Contact.AccountId;
            }
            else{
                this.tostMessage(changeAuthCheckErrorMessage,0,'Error','');
                this.cancel();
            }

        })
        .catch(error => {
            console.log('Inside error');
            console.log(error);
            this.loadSpinner=false;
            this.error = error;
            this.tostMessage(UI_Error_Message,0,'Error','');
            this.cancel();
        });   
        }, DELAY);
        
    }

    handleOnchange(event)
    {
        this.showList=false;
        userList({dealerId:this.dealerAccount, name:event.detail.value})
            .then(result =>{
                console.log(result);
                this.partnerUser=result.dataList;
            })
            .catch(error => {
                this.loadSpinner=false;
                this.error = error;
                this.tostMessage(UI_Error_Message,0,'Error','');
            });
        
        console.log(event.detail.value);
    }
    handleSelect(event)
    {
        const selectedRecordId = event.detail;
        this.showList=true;
        this.selectedRecord = this.partnerUser.find( record => record.Id === selectedRecordId);
        console.log(this.selectedRecord);
    }
    handleRemove(){
        
        this.selectedRecord = undefined;
       
    }
    changeOwner()
    {
        this.loadSpinner=true;
        changeOwner({id:this.recordId,ownerId:this.selectedRecord.Id})
        .then(result =>{
            console.log(result);
            if(result.status==='Success')
            {
              this.loadSpinner=false;
              this.tostMessage(result.message,result.code,result.status,'');  
              this.cancel();
            }
            else{
                this.loadSpinner=false;
                this.tostMessage(result.message,result.code,result.status,'');
            }

        })
        .catch(error => {
            this.loadSpinner=false;
            this.error = error;
            this.tostMessage(UI_Error_Message,0,'Error','');
        });

    }
    cancel()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    tostMessage(message,code,status,type)
    {
        console.log('== type ', type);
        const showSuccess = new ShowToastEvent({
            title: status,
            message: message,
            variant: status,
        });
        this.dispatchEvent(showSuccess);
        if(code===200)
        {
            console.log('Inside if');
            this.cancel();
        }
        
    }

}