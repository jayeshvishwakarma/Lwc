/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchCloseFollowUpDetails from '@salesforce/apexContinuation/ClosedFollowUpsCtrl.fetchCloseFollowUpDetails';
import retriveEnquiryInfo from '@salesforce/apex/ClosedFollowUpsCtrl.retriveEnquiryInfo';
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';


export default class ClosedFollowUps extends LightningElement {
    @api recordId;
    @api typeOfSection; 
    @api deviceFormFactor;

    @track isLoading = false;
    
    // Paramaters Details
    @track parentGroup = '';
    @track dealerMapCode = '';
    @track dealerLocation = '';
    @track DMSEnquiryNumber = '';

    generalFollowUpDetail = '';

    @track responseResult = [];
    @track labelDataList = [];

    connectedCallback(){
        if(this.deviceFormFactor !== 'DESKTOP'){
            this.typeOfSection = 'Card';
        }

        retriveEnquiryInfo({
            recordId : this.recordId
        })
        .then(result => {
            if(result !== undefined && result !== null){
                if(result.DMS_Enquiry_Name__c !== null)
                    this.DMSEnquiryNumber = result.DMS_Enquiry_Name__c;
                    this.generalFollowUpDetail = result.Closed_General_FollowUp_Details__c;

                if(result.Dealership__c && result.Dealership__r){
                    this.dealerLocation = result.Dealership__r.Dealer_Location__c;
                    this.dealerMapCode = result.Dealership__r.Dealer_Map_Code__c;
                    this.parentGroup = result.Dealership__r.Parent_Group__c;
                }

                console.log('== this.DMSEnquiryNumber ', this.DMSEnquiryNumber);
                console.log('== this.dealerLocation ', this.dealerLocation);
                console.log('== this.dealerMapCode ', this.dealerMapCode);
                console.log('== this.parentGroup ', this.parentGroup);


                if(this.DMSEnquiryNumber != null && this.DMSEnquiryNumber !== undefined &&
                    this.dealerLocation != null && this.dealerLocation !== undefined &&
                    this.dealerMapCode != null && this.dealerMapCode !== undefined &&
                    this.parentGroup != null && this.parentGroup !== undefined){
         
                     this.isLoading = true;
                     fetchCloseFollowUpDetails({
                         apiType : 'Closed Follow Ups',
                         parentGroup : this.parentGroup,
                         dealerMapCode : this.dealerMapCode,
                         locationCode : this.dealerLocation,
                         enquiryNumber : this.DMSEnquiryNumber,
                         generalFollowUpDetail : this.generalFollowUpDetail
                     })
                     .then(result1 =>{
                         console.log('== In Fetch Result ', result1);
                         if(result1 === UI_Error_Message){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: '',
                                    message: UI_Error_Message,
                                    variant: 'error'
                                })
                            );
                         }else{
                            this.labelDataList = result1.fieldLabelList;
                            this.responseResult = result1.fieldValueList;
                            console.log('== List Result ', this.responseResult);
                            if(this.responseResult.length === 0){
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: '',
                                        message: 'No Record Found !!',
                                        variant: 'error'
                                    })
                                );
                            }
                         }
                         this.isLoading = false;
                     })
                     .catch(error =>{
                         this.isLoading = false;
                         /*eslint-disable  no-console*/
                         console.log('== In Fetch Error ', error);
                         this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: UI_Error_Message,
                                variant: 'error'
                            })
                        );
                     })
                 }
                 
                    let errorMessage = '';
                    if(!this.DMSEnquiryNumber){
                        errorMessage += 'DMS Enquiry Number, ';
                    }
                    if(!this.dealerLocation){
                        errorMessage += 'Dealer Location Code, ';
                    }
                    if(!this.dealerMapCode){
                        errorMessage += 'Dealer Map Code, ';
                    }
                    if(!this.parentGroup){
                        errorMessage += 'Parent Group ';
                    }

                    if(errorMessage){
                        errorMessage += 'is Missing';
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: errorMessage,
                                variant: 'error'
                            })
                        );
                    }

                 

            }
             
        })
        .catch(error => {
            console.log('== Error Data ', error);
        });

    }

    get table(){
        return this.typeOfSection==='Table' ? true : false;
    }

    get browserFormFactor(){
        return this.deviceFormFactor==='DESKTOP' ? true : false;
    }

    closeModal(){
        window.location.reload();
    }

}