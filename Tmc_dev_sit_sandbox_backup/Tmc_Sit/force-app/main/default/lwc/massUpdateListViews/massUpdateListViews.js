/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, wire } from 'lwc';
import UserId from '@salesforce/user/Id';
import getUserProfileName from '@salesforce/apex/listViewFilterApex.getUserProfileName';
import insuranceProfiles from '@salesforce/label/c.insurance_mass_update';
import serviceProfiles from '@salesforce/label/c.service_mass_update';

export default class MassUpdateListViews extends LightningElement {

    currentUserId = UserId;

    serviceView = false;
    insuranceView = false;
    errorTab = false;
    


    connectedCallback() {
        console.log(this.currentUserId);
        if (this.currentUserId) {
            getUserProfileName({})
                .then(result => {
                    console.log('result', result);
                    if (insuranceProfiles.includes(result.userRec.Profile.Name)) {
                        console.log('insurance profile');
                        this.insuranceView = true;
                    } else if(serviceProfiles.includes(result.userRec.Profile.Name)) {
                        this.serviceView = true;
                    }else{
                        this.errorTab = true;
                    }
                })
                .catch(error => {
                    console.log(error)
                });
        }

    }
}