import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/serverAccount.getAccounts';

export default class ServerAccount extends LightningElement {

    @wire (getAccounts,) lstAccountRecords;
}