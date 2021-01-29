/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import { LightningElement,api } from 'lwc';
// import getResults from '@salesforce/apex/dynamicDashboardController.getResults';
import getReportQueryCount from '@salesforce/apex/dynamicDashboardController.getReportQueryCount';

import { NavigationMixin } from 'lightning/navigation';

// const columns = [
//     { label: 'Stage Name', fieldName: 'StageName' },
//     { label: 'Count', fieldName: 'c'}
// ];

export default class DynamicDashboardChild extends NavigationMixin(LightningElement) {
    @api dashBoardTitleMessage = '';
    // @api sObjectApiName;
    // @api recordField;
    // @api showSummary = false;
    // @api recordStatusValue;
    // @api reportRecordId;
    // data=[];
    // columns = columns;
@api reportId;

    recordCount;
    loading = true;

    connectedCallback(){

        getReportQueryCount({reportId:this.reportId})
            .then(result => {
                let data = result;
                console.log('data',data);
                for(let k in data){
                    this.reportRecordId = data[k];
                    this.recordCount = k;
                }
            })
            .catch(error => {
                console.error(error);
            });
        
            setTimeout(function () {
                this.loading = false
            }.bind(this), 5000);
            this.activeSections = [];
    }


    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.reportRecordId,
                objectApiName: 'Report', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

}