import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import PSF_Surveys from '@salesforce/label/c.PSF_Surveys';
import createProfiling from '@salesforce/apex/OpenProfilingSurveyApex.createProfiling';
import Survey_Type from '@salesforce/schema/Survey_Taker_CTI__c.Survey__r.Type';

const fields = [Survey_Type];

export default class OpenProfilingSurvey extends NavigationMixin(LightningElement) {

    @api recordId;
    isPSFSurvey = false;
    recordData;
    PSF_Surveys_List = PSF_Surveys.split(',');

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredSurveyTaker({ error, data }) {
        if (data) {
            this.recordData = data;
            let surveyType = getFieldValue(data, Survey_Type);
            console.log('surveyType=== ', surveyType);
            if (this.PSF_Surveys_List.indexOf(surveyType) > -1) {
                this.isPSFSurvey = true;
            } else {
                this.isPSFSurvey = false;
            }
        }
    }


    handleClick() {

        createProfiling({
            recordId: this.recordId
        }).then(result => {
            console.log('== result ', result);
            if (result) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Survey_Taker_CTI__c',
                        actionName: 'view'
                    }
                });
            }

        }).catch(error => {
            this.isLoading = false;
            console.log('== error ', error);
        })
    }
}