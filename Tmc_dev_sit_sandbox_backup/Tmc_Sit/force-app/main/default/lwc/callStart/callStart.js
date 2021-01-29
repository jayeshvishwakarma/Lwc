/* eslint-disable no-console */
import {
    LightningElement,
    api
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
import fetchData from '@salesforce/apex/CallStartController.fetchData';
import updateTaskStatus from '@salesforce/apex/CallStartController.updateTaskStatus';
import {
    saveJSONtoCache
} from "c/cacheServiceLayerCMP"
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import FORM_FACTOR from '@salesforce/client/formFactor';
import {
    retrieveObjectArrayFromCache
} from "c/cacheServiceLayerCMP";

/********Custom Labels  *******/
import Campaign_error_message from '@salesforce/label/c.Campaign_error_message';
import Campaign_not_linked_message from '@salesforce/label/c.Campaign_not_linked_message';
import Task_stage_error_message from '@salesforce/label/c.Task_stage_error_message';

export default class CallStart extends NavigationMixin(LightningElement) {
    @api recordId;
    phoneNumber;
    accountId;

    connectedCallback() {
        let response = retrieveObjectArrayFromCache();
        if (response && response.Id === this.recordId) {
            this.showMessage('Success', 'Call is already In Progress', 'Success');
            let recId = response.Contact_ID__c ? response.Contact_ID__c : '';
            this.navigate(response.Contact_ID__c, 'Account');
        } else if (response && this.recordId.substring(0, 3) === '500' && response.Case__c === this.recordId) {
            this.showMessage('Success', 'Call is already In Progress', 'Success');
            this.navigate(this.recordId, 'Case');
        } else {
            fetchData({
                recordId: this.recordId
            })
                .then(data => {
                    //localStorage.clear();
                    let objType1 = 'Task';
                    if (this.recordId.substring(0, 3) === '500') {
                        objType1 = 'Case';
                    }
                    if (data.code === 200) {
                        localStorage.clear();
                        if (data.dataList.length > 0) {
                            if (data.dataList[0].CampaignId__r !== undefined && data.dataList[0].CampaignId__r !== '') {
                                if (data.dataList[0].CampaignId__r.Status !== 'Paused') {
                                    saveJSONtoCache(JSON.stringify(data.dataList[0]));
                                    this.phoneNumber = data.dataList[0].Customer_Mobile__c;
                                    this.accountId = data.dataList[0].Contact_ID__c;
                                    let url = 'Tel:' + this.phoneNumber;
                                    if (FORM_FACTOR !== 'Large') {
                                        window.location = url;
                                    }
                                    let accId = this.accountId;
                                    let objType = 'Account';
                                    updateTaskStatus({
                                        recordId: data.dataList[0].Id,
                                        diallingRecId: data.dataList[0].Dialling_Record_ID__c
                                    })
                                        .then(result => {
                                            if (this.recordId.substring(0, 3) === '500') {
                                                accId = this.recordId;
                                                objType = 'Case';
                                                this.showMessage('Success', 'Call started', 'Success');
                                            }
                                            this[NavigationMixin.Navigate]({
                                                type: 'standard__recordPage',
                                                attributes: {
                                                    recordId: accId,
                                                    objectApiName: objType, // objectApiName is optional
                                                    actionName: 'view'
                                                }
                                            });
                                        })
                                        .catch(error1 => {
                                            console.error(error1);

                                        });

                                } else {
                                    this.showMessage('Error', Campaign_error_message, 'Error');
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__recordPage',
                                        attributes: {
                                            recordId: this.recordId,
                                            objectApiName: 'Task', // objectApiName is optional
                                            actionName: 'view'
                                        }
                                    });
                                }
                            } else {
                                this.showMessage('Error', Campaign_not_linked_message, 'Error');
                                this.navigate(this.recordId, objType1);
                            }
                        } else {
                            this.showMessage('Error', Task_stage_error_message, 'Error');
                            this.navigate(this.recordId, objType1);
                        }
                    } else {
                        this.showMessage('Error', data.message, 'Error');
                        /*let objType1='Task';
                                if(this.recordId.substring(0,3)==='500'){
                                    
                                    objType1='Case';
                                }*/
                        this.navigate(this.recordId, objType1);
                    }

                })
                .catch(error => {
                    this.error = error;

                });
        }

    }
    showMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    navigate(id, objectName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: objectName, // objectApiName is optional
                actionName: 'view'
            }
        });


    }

}