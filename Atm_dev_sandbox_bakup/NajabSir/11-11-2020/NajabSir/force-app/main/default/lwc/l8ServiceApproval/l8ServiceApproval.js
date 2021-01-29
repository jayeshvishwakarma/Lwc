import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getOnloadInfo from '@salesforce/apex/L8ServiceApprovalController.getCaseActionL8Approver';
import updateCaseAction from '@salesforce/apex/L8ServiceApprovalController.updateCaseAction';
import Id from '@salesforce/user/Id';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import WORKSHOP_REASON from '@salesforce/schema/Case_Actions__c.Workshop_Reason__c';



//import caseUpdateProfiles from '@salesforce/label/c.Case_Update_Profiles';
const columns = [
    { label: 'Approver', fieldName: 'approver' },
    { label: 'Decision', fieldName: 'decision'},
    { label: 'Workshop Reason', fieldName: 'workshopReason'},
    { label: 'Remarks', fieldName: 'remarks' }
];
export default class L8ServiceApproval extends LightningElement {
    currentUserId = Id;
    @api recordId;
    isSpinnerShow = false;
    approverData = [];
    decision = '';
    workshopReason = '';
    remarks = '';
    isTableShow = false;
    isValidApprover = false;
    isEditTrue = true;

    decisionOption = [
        { label: '--None--', value: '' },
        { label: 'Approve', value: 'Approve' },
        { label: 'Reject', value: 'Reject' }
    ]
    reasonOption = [];
    isReasonDisabled = true;
   // isRemarksRequired = false;

    @wire(getPicklistValues, { recordTypeId: '0121s0000008mTB', fieldApiName: WORKSHOP_REASON })
    options({ data }) {
        let arr = [];
        if (data) {
            //this.reasonOption = data.values;
        }       
    }
    connectedCallback() {
        this.getOnloadInfo();
    }
    async getOnloadInfo(){
        try {
          //  console.log(this.recordId);
            this.error = '';
            this.isSpinnerShow = true;
            await getOnloadInfo({
                    recordId: this.recordId
                })
                .then(result => {
                    console.log('getOnloadInfo :: ' ,result);
                    if (result) {
                        this.approverData =  JSON.parse(result.l8Json);
                        this.reasonOption =  JSON.parse(result.workshopReasons);
                    }
                    this.setActionVisibility();
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (error && Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (error && typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in getOnloadInfo JS method');
            console.log(e.message);
        }
    }
    setActionVisibility(){
        if(this.approverData){
          // this.currentUserId = '0051s000000eKQZAA2';
            let approveCount = 0;
            let rejectCount = 0;
            this.approverData.forEach(data => {
                if(data.approverId === this.currentUserId && data.decision !== 'Pending'){
                    this.isTableShow = true;
                }
                if(this.currentUserId === data.approverId){
                    this.isValidApprover = true;
                }

                if(data.decision && data.decision === 'Approve'){
                    approveCount++;
                }if(data.decision && data.decision === 'Reject'){
                    rejectCount++;
                }
                

            });
            if(this.approverData && (this.approverData.length === approveCount || this.approverData.length === rejectCount)){
                this.isEditTrue = false;
            }
        }if (!this.approverData || this.approverData.length === 0){
            this.isValidApprover =  false;
        }
    }
    /** Handle change functions */
    handleDecisionChange(event){
        let decision =  event.detail.value;
        this.decision =  decision;
        this.workshopReason = '';
        let required = decision === 'Reject' ? false: true; 
        this.isReasonDisabled = required;
      //  this.isRemarksRequired = required;
    }
    handleReasonChange(event){
        let reason =  event.detail.value;
        this.workshopReason = reason;
    }
    handleRemarksChange(event){
        let remarks =  event.detail.value;
        this.remarks = remarks;
    }
    /** Buttons function */
    handleSave(){
        try{
            if(!this.checkRequired()){
                return;
            }
            let approveCount = 0;
            let rejectCount = 0;
            this.approverData.forEach(data => {
                if(data.approverId === this.currentUserId){
                    data.decision = this.decision;
                    data.remarks = this.remarks;
                    data.workshopReason = this.workshopReason;
                }
            });
            this.updateCaseAction();
        } catch (e) {
            console.log('Exception in handleSave JS Function');
            console.log(e.message);
        }

    }
    updateCaseAction(){
        this.isSpinnerShow = true;
        updateCaseAction({
                recordId : this.recordId,
                approverData: JSON.stringify(this.approverData)
            })
            .then(result => {
                console.log('updateCaseAction :: ' ,result);
                if (result) {
                    this.showToast('Success','Action Completed Successfully','success');
                    this.handleCancel();
                }
                this.isSpinnerShow = false;
            })
            .catch(error => {
                this.error = error;
                console.log(JSON.stringify(error));
                if (error && Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (error && typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                this.isSpinnerShow = false;
            });
    }
    handleCancel(){
        console.log('handleCancel');
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
    checkRequired(){
        const allValid = [...this.template.querySelectorAll('.input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;

    }
    showToast(title,message,type){
        const toastEvt = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": type
        });
        this.dispatchEvent(toastEvt);
    }
}