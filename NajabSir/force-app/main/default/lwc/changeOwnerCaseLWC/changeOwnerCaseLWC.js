/* eslint-disable no-alert */
/* eslint-disable no-console */
/**
 * @File Name          : ChangeOwnerCaseLWC.js
 * @Description        : This js class is used for Case Change Owner functionality
 * @Author             : Shalini Singh
 * @Group              : 
 * @Last Modified By   : Shalini Singh
 * @Last Modified On   : 27/10/2020, 12:37:23 PM 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    27/10/2020,   12:37:23 PM    Shalini Singh    Initial Version
 * 
 **/
import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import checkLoggedinUserType from '@salesforce/apex/ChangeOwnerCase.checkLoggedinUserType';
import userList from '@salesforce/apex/ChangeOwnerCase.getUserList';
import changeOwner from '@salesforce/apex/ChangeOwnerCase.changeOwner';
import {getRecord} from 'lightning/uiRecordApi';
import changeAuthCheckErrorMessage from '@salesforce/label/c.Error_mesage_change_owner_auth_for_case';
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';

const DELAY = 300;
export default class ChangeOwnerCaseLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @track partnerUser;
    @track showList;
    @track selectedRecord;
    @track loadSpinner;
    
    record;
    iconname = "standard:user";
    searchfield = 'Name';
    dealerAccount;
    isUserEligible = false;
    @wire(getRecord, { recordId: '$recordId'})
    wiredCase({ error, data }) {
        
        if (data) {
            this.record = data;
        }
        else{
            console.log(error);
        }
    }

    // Constructor
    connectedCallback(){
         window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
         this.delayTimeout = setTimeout(() => {
         checkLoggedinUserType({recordId : this.recordId})
        .then(result =>{
            
            if(result.dataList.length == 0 )
            {
                this.tostMessage(changeAuthCheckErrorMessage,0,'Error','');
                this.cancel(); 
            }else{
            this.isUserEligible =true;
            }
        })
        .catch(error => {
            
            this.loadSpinner=false;
            this.error = error;
            this.tostMessage(UI_Error_Message,0,'Error','');
            this.cancel();

        });   
        }, DELAY);
        
    }

    /*-------------------- Search Bar change-------------------------------------------------------------*/
    handleOnchange(event)
    {
       
        this.showList=false;
        userList({ name:event.detail.value})
            .then(result =>{
               this.partnerUser=result.dataList;
            })
            .catch(error => {
                this.loadSpinner=false;
                this.error = error;
                this.tostMessage(UI_Error_Message,0,'Error','');
            });
    }
    
    handleSelect(event)
    {
        const selectedRecordId = event.detail;
        this.showList=true;
        this.selectedRecord = this.partnerUser.find( record => record.Id === selectedRecordId);
        
    }
    handleRemove(){
        
        this.selectedRecord = undefined;
       
    }
    changeOwner()
    {
        this.loadSpinner=true;
        changeOwner({id:this.recordId,ownerId:this.selectedRecord.Id})
        .then(result =>{
           if(result.status==='Success')
            {
              this.loadSpinner=false;
              this.tostMessage(result.message,result.code,result.status,'');  
              this.cancel();
              location.reload();
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
      
        this.partnerUser = undefined;
        this.selectedRecord = false;
    }
    tostMessage(message,code,status,type)
    {
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