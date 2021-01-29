import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

/* Import Apex Methods */
import getMDTListData from '@salesforce/apex/PreliminaryChecklistCtrl.getMDTListData';
import getAccContRelationValidataion from '@salesforce/apex/PreliminaryChecklistCtrl.getAccContRelationValidataion';

/* import Preliminary Checklist Fields*/
import PC_FM_STATUS from '@salesforce/schema/Preliminary_Checklist__c.FM_Status__c';
import PC_ACM_STATUS from '@salesforce/schema/Preliminary_Checklist__c.ACM_Status__c';


export default class PreliminaryChecklist extends LightningElement {

    @api recordId;
    @api checklistType;
    @api selectedType;

    @track readOnlyMode = false;
    @track editOnlyMode = true;
    @track authUser;

    /* fetch the metaDataType info using Apex Method */
    @wire(getMDTListData, { fieldType: '$checklistType', employeeType: '$selectedType' })
    wiredPreCheckListMDT;

    /* fetch the field's value from the current record */
    @wire(getRecord, { recordId: '$recordId', fields: [PC_FM_STATUS, PC_ACM_STATUS] })
    preCheckRecordData({ error, data }) {
        if (data) {
            /* get the mode of the mode based on the status */
            if ((this.checklistType === 'Checklist FM' && getFieldValue(data, PC_FM_STATUS) === 'Completed') ||
                (this.checklistType === 'Checklist ACM' && getFieldValue(data, PC_ACM_STATUS) === 'Completed')) {
                this.readOnlyMode = true;
                this.editOnlyMode = false;
            }
        }
    }

    /* Get the info of the user that he/she is Authorized or Non-Authorized for view the form */
    @wire(getAccContRelationValidataion, { BtnClickStr: '$checklistType', sobjectId: '$recordId' })
    wiredIsAuthorize({ error, data }) {
        if (data) {
            console.log(data);
            if (data === 'Not Authorized') {
                this.notAuthUser = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'You are not an authorized user',
                        variant: 'error'
                    })
                );
                this.closeQuickAction();

            } else if (data === 'Authorized') {
                this.authUser = true;
            }
        }
        else if (error) {
            console.log('error : ' + error);
        }
    }

    /* fire event for closing the quick Action popup  */
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    handleSubmitClick() {
        var validValue = true;
        /* validate the required fields */
        this.wiredPreCheckListMDT.data.forEach(data => {
            var apiname = data.Field_API_Name__c;
            var fieldvalue = this.template.querySelector('[data-field="' + apiname + '"]').value;
            validValue = data.Is_Mandatory__c ? (fieldvalue ? validValue : false) : validValue;
        });

        if (validValue) {
            const fields = {};
            fields['Id'] = this.recordId;
            this.wiredPreCheckListMDT.data.forEach(data => {
                var apiname = data.Field_API_Name__c;
                console.log(apiname);
                var fieldvalue = this.template.querySelector('[data-field="' + apiname + '"]').value;
                fields[apiname] = fieldvalue;
            });

            const recordInput = { fields };
            console.log(recordInput);
            if (this.checklistType === 'Checklist FM') {
                fields['FM_Status__c'] = 'Completed';
                fields['Profession_Type__c'] = this.selectedType;
            } else if (this.checklistType === 'Checklist ACM') {
                fields['ACM_Status__c'] = 'Completed';
            } else if (this.checklistType === 'MGA Manager Checklist') {
                fields['MGAM_Status__c'] = 'Completed';
            } else if (this.checklistType === 'PDI Coordinator Checklist') {
                fields['PDI_Status__c'] = 'Completed';
            } else if (this.checklistType === 'RTO Coordinator Checklist') {
                fields['RTO_Status__c'] = 'Completed';
            } else if (this.checklistType === 'Delivery coordinator Checklist') {
                fields['DC_Status__c'] = 'Completed';
            }

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Checklist Submitted',
                            variant: 'success'
                        })
                    );
                    //Close the form
                    this.closeQuickAction();
                })
                .catch(error => {
                    console.log(error);
                    var errormsg = '';
                    if (error.body.output && error.body.output.errors[0] && error.body.output.errors[0].message) {
                        //validation and trigger errror
                        errormsg = error.body.output.errors[0].message;
                    } else {
                        errormsg = error.body.message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: errormsg,
                            variant: 'error'
                        })
                    );
                });
        }
        else {
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
            );
        }
    }

}