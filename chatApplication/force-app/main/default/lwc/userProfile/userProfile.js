import { LightningElement, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_PHONE from '@salesforce/schema/User.Phone';
import USER_EMAIL from '@salesforce/schema/User.Email';
import USER_COMPANY from '@salesforce/schema/User.CompanyName';

const FIELDS = [USER_NAME, USER_PHONE, USER_COMPANY, USER_EMAIL];

export default class UserProfile extends LightningElement {

    userRecordId;

    constructor()
    {
        super()
        this.userRecordId = USER_ID;
    }

    @wire(
            getRecord,
            {
                recordId : '$userRecordId',
                fields : FIELDS 
            }
        ) userRecord;

    get userName()
    {
        return getFieldValue(this.userRecord.data,USER_NAME);
    }

    get userPhone()
    {
        return getFieldValue(this.userRecord.data,USER_PHONE);
    }
    get userCompany()
    {
        return getFieldValue(this.userRecord.data,USER_COMPANY);
    }
    get userEmail()
    {
        return getFieldValue(this.userRecord.data,USER_EMAIL);
    }
}