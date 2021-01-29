import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPublicLinkForFile from '@salesforce/apex/EmailQuotePDFCtrl.createPublicLinkForFile';

export default class EmailQuotePDF extends LightningElement {
    @api recordId;

    @track error = '';

    @track isLoading = true;

    connectedCallback(){
        
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