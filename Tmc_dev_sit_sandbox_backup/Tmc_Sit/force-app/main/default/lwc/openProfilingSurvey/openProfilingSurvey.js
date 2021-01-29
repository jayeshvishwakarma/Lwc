import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import PSF_Surveys from '@salesforce/label/c.PSF_Surveys';
import createProfiling from '@salesforce/apex/OpenProfilingSurveyApex.createProfiling';
import Survey_Type from '@salesforce/schema/Survey_Taker_CTI__c.Survey__r.Type';
import Generic4 from '@salesforce/schema/Survey_Taker_CTI__c.Generic4__c';

const fields = [Survey_Type, Generic4];

export default class OpenProfilingSurvey extends NavigationMixin(LightningElement) {

    @api recordId;
    isPSFSurvey = false;
    recordData;
    PSF_Surveys_List = PSF_Surveys.split(',');
    refrencedDPSId = '';

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredSurveyTaker({ error, data }) {
        if (data) {
            this.recordData = data;
            let surveyType = getFieldValue(data, Survey_Type);
            console.log('surveyType=== ', surveyType);
            if (this.PSF_Surveys_List.indexOf(surveyType) > -1) {
                this.isPSFSurvey = true;
                this.refrencedDPSId = getFieldValue(data, Generic4);
            } else {
                this.isPSFSurvey = false;
            }
        }
    }


    handleClick() {

        if (this.refrencedDPSId) {
            createProfiling({
                refrencedDPSId: this.refrencedDPSId
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
}