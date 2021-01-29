import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPublicLinkForFile from '@salesforce/apex/EmailQuotePDFCtrl.createPublicLinkForFile';

export default class EmailQuotePDF extends LightningElement {
    @api recordId;

    @track error = '';

    @track isLoading = true;

    @wire(getRecord, { recordId: '$recordId', fields: ['Quote.Opportunity.Email__c', 'Quote.Opportunity.RecordType.Name'] })
    retrieveQuotation({ error, data }) {
        if (data) {
            this.isLoading = false;
            console.log('== data ',data);
            let oppEmail = data.fields.Opportunity.value.fields.Email__c.value;
            let recTypeName = data.fields.Opportunity.value.fields.RecordType.value.fields.Name.value;
            console.log('== oppEmail ',oppEmail);
            if(recTypeName && recTypeName !== 'Parts'){
                this.isLoading = true;
                this.sendEmail();
            }else if(recTypeName && recTypeName === 'Parts' && oppEmail){
                this.isLoading = true;
                this.sendEmail();
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'No email available on the enquiry record. Please enter an email address on the Enquiry to email the quotation.',
                        variant: 'error'
                    })
                );

                this.dispatchEvent(new CustomEvent('SubmitReq'));

            }
        }
        if (error) {
            this.isLoading = false;
            console.log('== error ',error);
        }
    }

    sendEmail(){
        
        /*eslint-disable no-console */
        createPublicLinkForFile({recordId : this.recordId})
        .then(result => {
            this.isLoading = false;
            console.log('== result ', result);
            
            const submitReqEvent = new CustomEvent('SubmitReq');
            // Fire the custom event
            this.dispatchEvent(submitReqEvent);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'The quote is being sent to the Customer.',
                    variant: 'success'
                })
            );

        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
        });

    }

    cancelBtn(){
        window.location.reload();
    }

}