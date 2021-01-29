/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import custom labels
import Quote_And_Opp_Info_Msg from '@salesforce/label/c.Quote_And_Opp_Info_Msg';
import Quote_Enquiry_Stage_Msg from '@salesforce/label/c.Quote_Enquiry_Stage_Msg';
import Quote_No_Msg from '@salesforce/label/c.Quote_No_Msg';

import retriveQuoteSyncType from '@salesforce/apex/UpdateSynchingCtrl.retriveQuoteSyncType';
import updateSyncing from '@salesforce/apex/UpdateSynchingCtrl.updateSyncing';

export default class UpdateSynching extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track error = '';
    @track isSyncing = '';

    @track showWarringError = '';

    @track enquiryStageName = '';
    @track quoteAndOppMsg = '';

    @track quoteName = '';
    @track opportunityId = '';
    @track opportunityName = '';

    @track quoteLineItemCount = 0;
    @track opportunityLineItemCount = 0;

    @track showContinue = false;
    @track showInforMsg = false;

    // Expose the labels to use in the template.
    label = {
        Quote_And_Opp_Info_Msg
    };

    @wire(getRecord, {recordId: '$recordId', fields: ['Quote.Name', 'Quote.IsSyncing', 'Quote.OpportunityId', 'Quote.Opportunity.Name']})
    wiredSelectedObjectInfo({error, data}){
        if(data){
            console.log('== data ', data);
            if(data.fields.Name.value !== null)
                this.quoteName = data.fields.Name.value;
            if(data.fields.OpportunityId.value !== null && data.fields.Opportunity.value.fields.Name.value !== null)
                this.opportunityName = data.fields.Opportunity.value.fields.Name.value;
            if(data.fields.OpportunityId.value !== null)
                this.opportunityId = data.fields.OpportunityId.value;
            this.isSyncing = data.fields.IsSyncing.value;
        }else if(error){
            console.log('error value ', error);
        }
    }

    connectedCallback(){
        retriveQuoteSyncType({
            recordId : this.recordId
        })
        .then(result => {
            if(result !== undefined && result !== null){
                this.quoteLineItemCount = result.quoteLineItemCount;
                this.opportunityLineItemCount = result.opportunityLineItemCount;
                this.quoteAndOppMsg = result.message;
                this.enquiryStageName = result.enquiryStageName;
            }
            let stageSet= ['New', 'Pre-Booking', 'Booking'];
            if((this.isSyncing === false) && (stageSet.indexOf(this.enquiryStageName) === -1)){
                console.log('== In 1');
                this.showWarringError = Quote_Enquiry_Stage_Msg;
            }else if(this.quoteLineItemCount === 0 && this.isSyncing === false){
                console.log('== In 2');
                this.showWarringError = Quote_No_Msg;
            }else if(this.quoteLineItemCount > 0){
                console.log('== In 3');
                this.showContinue = true;
                this.showInforMsg = true;
            }
        })
        .catch(error => {
            this.error = error;
        });
            
    }
    
    cancelBtn(){
        window.location.reload();
    }

    continueBtn(){
        this.isLoading = true;
        updateSyncing({
            quoteId : this.recordId,
            isSyncing : this.isSyncing,
            quoteName : this.quoteName,
            opportunityName : this.opportunityName,
            oppId : this.opportunityId
        })
        .then(result => {
            console.log('== result ', result);
            if(result){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: result.message,
                        variant: result.type
                    })
                );
                this.isLoading = false;
                if(result.type === 'success'){
                    this.cancelBtn();
                }
                
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Insufficient privileges. Please contact your administration.',
                        variant: 'error'
                    })
                );
                this.isLoading = false;
            }
                
        })
        .catch(error => {
            this.isLoading = false;
            console.log('== Error ',error);
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: this.error,
                    variant: 'error'
                })
            );
        });

    }

}