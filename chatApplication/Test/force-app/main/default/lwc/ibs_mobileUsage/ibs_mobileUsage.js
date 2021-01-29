import { LightningElement, track, api } from 'lwc';
import getRefreshData from '@salesforce/apex/IBSRefreshMobileUsageController.refreshData';
import getRefreshPortMobDataFromSf from '@salesforce/apex/IBSRefreshMobileUsageController.refreshPortMobData';
import getId from '@salesforce/apex/IBSReadOnlyRelatedListController.getUserId';
export default class Ibs_mobileUsage extends LightningElement {
    @api recordId;
    @track parentType = 'Record Detail';
    @track showSpinner = false;
    index = 0;

    connectedCallback() {
        console.log('this.recordId->', this.recordId);
        if (this.recordId == undefined) {
            this.getIdFromController();
            this.parentType = 'Current Account';
        }
        this.index = 0;
    }

    getIdFromController() {
        getId().
            then(result => {
                this.recordId = result;
            }).catch(error => {
                console.log('Error while gettinId', error);
            });
    }

    onHandleRefersh() {
        this.showSpinner = true;
        getRefreshData({ accId: this.recordId })
            .then(result => {
                console.log('refersh result', result);
                this.getRefreshPortMobData();
            }).catch(error => {
                this.showSpinner = false;
                console.log('Error Refersh Data', error);
            });
    }

    getRefreshPortMobData() {
        getRefreshPortMobDataFromSf({ accId: this.recordId, index: this.index })
            .then(result => {
                console.log('Port result', result);
                if (result == null) {
                    this.index = this.index + 1;
                    this.getRefreshPortMobData();
                } else if (result == 'completed') {
                    console.log('need to be refersh');
                    this.showSpinner = false;
                    this.callRefershChlid();
                }
            }).catch(error => {
                this.showSpinner = false;
                console.log('Error while Port MOB Data', error);
            });
    }

    callRefershChlid() {
        this.template.querySelector("c-ibs_read-only-related-list").refershList();
        this.template.querySelector("c-totaal-verbruik-cmp").refershList();
    }
}