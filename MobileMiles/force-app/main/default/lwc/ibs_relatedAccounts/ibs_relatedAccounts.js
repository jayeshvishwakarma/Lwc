import { LightningElement, wire } from 'lwc';
import getChildAccounts from '@salesforce/apex/IBSRelatedAccountsController.getChildAccounts';
import{CurrentPageReference} from 'lightning/navigation';
import { fireEvent } from 'c/pubSub';
export default class Ibs_relatedAccounts extends LightningElement {
   
    result;

    @wire(getChildAccounts)
    wiredData({ error, data }) {
      if (data) {
        this.result = data;
       // fireEvent(this.pageRef,'selectedAccountUpdate',this.result.selectedAcc);
        //this.error = undefined;
      } else if (error) {
        //this.error = error;
        this.result = undefined;
      }
    }

    handleChange(event) {
        let value = event.detail.value;
        fireEvent(this.pageRef,'selectedAccountUpdate',value);
        console.log('value '+value);
    }

    
}