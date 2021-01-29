import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Stakeholder_Opp_FIELD from '@salesforce/schema/Opportunity.Dealership__r.Stakeholder_Hierarchy__c';
import Stakeholder_Case_FIELD from '@salesforce/schema/Case.Stakeholders_JSON__c';
import Hierarchy_Not_defined from '@salesforce/label/c.Hierarchy_not_defined_error';
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import retriveStakeHolderMapping from '@salesforce/apex/EscalationMatrix.getEscalationMatrix';

export default class EscalationMatrix extends LightningElement {
    @api recordId;
    @api businessArea;
    @track showSpinner = false;
    @track JSON;
    @track errorMessage;
    @track responseResult=[];
    @track activeIcon = 'utility:chevronright';
    @wire(getRecord, { recordId: '$recordId', fields: [Stakeholder_Opp_FIELD] }) opportunity;
    @wire(getRecord, { recordId: '$recordId', fields: [Stakeholder_Case_FIELD] }) case;

    get oppJSON() { return getFieldValue(this.opportunity.data, Stakeholder_Opp_FIELD); }
    get caseJSON() { return getFieldValue(this.case.data, Stakeholder_Case_FIELD); }
    Columns = [
         { label: 'Level', fieldName: 'Level' },
         { label: 'Designation', fieldName: 'Designation', type: 'string', cellAttributes: { alignment: 'left' } },
         { label: 'Name', fieldName: 'Name', type: 'string', cellAttributes: { alignment: 'left' } },
         { label: 'Phone', fieldName: 'Phone', type: 'string', cellAttributes: { alignment: 'left' } },
         { label: 'Email', fieldName: 'Email', type: 'string', cellAttributes: { alignment: 'left' } }
     ];
    handleToggleSection(){
    let secObj = this.template.querySelector('[data-id="detail-section"]');
        if (secObj.classList.contains('slds-is-open')) {
            secObj.classList.remove('slds-is-open');
            this.activeIcon = 'utility:chevronright';
        } else {
            secObj.classList.add('slds-is-open');
            this.activeIcon = 'utility:chevrondown';
            if (this.oppJSON || this.caseJSON) {
                this.JSON = this.oppJSON != undefined ? this.oppJSON : this.caseJSON;
                this.handleStakeHolderMapping();
            } else {
                this.handleError(Hierarchy_Not_defined);
            }
        }
}
handleStakeHolderMapping(){
    console.log("result", this.JSON);
    this.showSpinner = true;
    retriveStakeHolderMapping({ 
        JSON: this.JSON, 
        businessArea: this.businessArea
    }).then(result => {
        console.log("result", JSON.parse(JSON.stringify(result)));
        //console.log("rawResponse", JSON.parse(result.data.rawResponse));
        this.responseResult=result
        if(result.length===0){
            this.handleError(Hierarchy_Not_defined);
        }
        this.showSpinner = false;
    }).catch(error => {
        this.showSpinner = false;
        console.log('error---->',error);
        this.handleError(UI_Error_Message);
    }); 
}
handleError(message) {
    this.errorMessage = message;
    const toastEvent = new ShowToastEvent({
        title: status,
        message: message,
        variant: 'error',
    });
    this.dispatchEvent(toastEvent);
}
}