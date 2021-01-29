/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
// import USERID from '@salesforce/user/Id';
// import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// import USER_NAME from '@salesforce/schema/Account.Owner.Name';
// import USER_ALIAS from '@salesforce/schema/User.Alias';
// import USER_EMAIL_ID from '@salesforce/schema/Account.Owner.Email';
// import FULL_PHOTO_URL from '@salesforce/schema/Account.Owner.FullPhotoUrl';
// import EXTENSION from '@salesforce/schema/Account.Owner.Extension';
// import COUNTRY from '@salesforce/schema/Account.Owner.Country';
import getUserIdFromSF from '@salesforce/apex/IBSReadOnlyRelatedListController.getUserId';
import getUserRecordFromSF from '@salesforce/apex/IBSUserInfoController.getUserInfo';
import { registerListener, unregisterAllListeners } from 'c/pubSub';

//let FIELD_NAMES = [USER_NAME, USER_EMAIL_ID, FULL_PHOTO_URL, EXTENSION];

export default class Ibs_loggedInUser extends LightningElement {

    //currentUserId;
    @track userRecord;
    @track userName;
    @track userEmail;
    @track userExtension;
    @track userPhoto;
    currentUserAccId;
    connectedCallback() {
        registerListener('selectedAccountUpdate'
            , this.handleAccountChange,
            this);
        this.getCurrentUserAccId();
    }
    getCurrentUserAccId() {
        getUserIdFromSF()
            .then(result => {
                console.log('userId Account ', result);
                this.currentUserAccId = result;
                this.getUserRecord();
            }).catch(error => {
                console.log('Erro while geeting Id', error);
            })
    }
    getUserRecord() {
        getUserRecordFromSF({accId : this.currentUserAccId})
            .then(result => {
                console.log('userId Account ', result);
                this.userName = result[0].Owner.Name;
                this.userEmail= result[0].Owner.Email;
                this.userExtension = result[0].Owner.Extension;
                this.userPhoto = result[0].Owner.Pasfoto_ovaal__c;
                //this.currentUserId = result;
            }).catch(error => {
                console.log('Erro while geeting Id', error);
            })
    }
    // @wire(
    //     getRecord,
    //     {
    //         recordId: '$currentUserId',
    //         fields: FIELD_NAMES

    //     }
    // ) userRecord;



    // get userName() {
    //     console.log('userRecord', this.userRecord);
    //     return getFieldValue(this.userRecord.data, USER_NAME);
    // }

    // get userAlias() {
    //     return getFieldValue(this.userRecord.data, USER_ALIAS);
    // }

    // get userEmail() {
    //     return getFieldValue(this.userRecord.data, USER_EMAIL_ID);
    // }

    // get userPhoto() {
    //     return getFieldValue(this.userRecord.data, FULL_PHOTO_URL);
    // }

    // get userCountry() {
    //     return getFieldValue(this.userRecord.data, COUNTRY);
    // }

    // get userExtension() {
    //     return getFieldValue(this.userRecord.data, EXTENSION);
    // }

    handleAccountChange(value) {
        this.currentUserAccId = value;
        this.getUserRecord();
    }
}