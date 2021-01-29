/* eslint-disable no-console */
import { LightningElement } from 'lwc';
import getConfigs from '@salesforce/apex/dynamicDashboardController.getConfigs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';


export default class DynamicDashboardParent extends LightningElement {
    showData = false;
    reportsData = [];
    userId = Id;

    connectedCallback() {
        getConfigs()
            .then(result => {
                console.log('>>>>', result);
                let data = result;
                if (data.length > 0) {
                    this.showData = true;
                    this.reportsData = data;
                } else {
                    const evt = new ShowToastEvent({
                        title: 'No Configuration found',
                        message: 'Please Contact Your admin',
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

}