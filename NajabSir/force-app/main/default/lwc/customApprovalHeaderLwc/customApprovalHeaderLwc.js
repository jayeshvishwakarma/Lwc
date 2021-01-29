import { LightningElement, api, wire, track } from 'lwc';
import fetchApprovalData from "@salesforce/apex/ApprovalHeaderLwcController.fetchApprovalData";
import saveData from "@salesforce/apex/ApprovalHeaderLwcController.saveData";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class CustomApprovalHeaderLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    actorName;
    originalActorName;
    createdDate;
    submittedBy;
    status;
    isModalOpen = false;
    forApprove=false;
    forReject = false;
    showSpinner = false;
    targetObjId;
    deviceFormFactor=false;
    processInsId;

    connectedCallback() {
        fetchApprovalData({
            recordId: this.recordId
        })
            .then(result => {
                if(FORM_FACTOR==='Small'){
                    this.deviceFormFactor = true;
                }
                console.log('result is-------', result);
                let monthMap = new Map([
                    ['01', 'Jan'],
                    ['02', 'Feb'],
                    ['03', 'Mar'],
                    ['04', 'Apr'],
                    ['05', 'May'],
                    ['06', 'Jun'],
                    ['07', 'Jul'],
                    ['08', 'Aug'],
                    ['09', 'Sep'],
                    ['10', 'Oct'],
                    ['11', 'Nov'],
                    ['12', 'Dec'],
                  ])
                if(result.ProcessInstance.CreatedDate){
                    let temp = result.ProcessInstance.CreatedDate.split('T')[0];
                    console.log('temp-----1',temp.split('-')[0]);//for year
                    console.log('temp-----2',temp.split('-')[1]);//for mon
                    console.log('temp-----3',temp.split('-')[2]);//for day
                    if((monthMap.has(temp.split('-')[1]))){
                        this.createdDate = temp.split('-')[2] +' '+ monthMap.get(temp.split('-')[1])+', '+temp.split('-')[0];
                    }
                }
                this.actorName = result.Actor.Name;
                this.originalActorName = result.OriginalActor.Name;
                this.submittedBy = result.ProcessInstance.SubmittedBy.Name;
                this.status = result.ProcessInstance.Status;
                this.targetObjId = result.ProcessInstance.TargetObjectId;
                this.processInsId = result.ProcessInstance.Id;
            })
            .catch(error => {
                console.log('error0-------------',error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error '+JSON.stringify(error),
                        variant: 'error'
                    })
                );
            })
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleApprove() {
        this.isModalOpen = true;
        this.forApprove = true;
        this.forReject = false;
    }
    handleReject() {
        this.isModalOpen = true;
        this.forReject = true;
        this.forApprove = false;
    }


    handleApproveRecSave(event) {
        var inputCmp = this.template.querySelector(".requiredValue"); //getting element
        var comm = inputCmp.value; //assigning value to variable
        if (comm === "") {
            inputCmp.setCustomValidity("Complete this field.");
            console.log('coming in here');
        } else {
            inputCmp.setCustomValidity("");
            this.showSpinner = true;
            saveData({
                'recordId': this.recordId,
                'actionName': event.target.title,
                'comments' : comm,
                'processInstanceId' : this.processInsId
            })
            .then(result=>{
                console.log('result-------',result)

                this.showSpinner = false;
                if(result.split('@@')[0] === 'success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Approved Successfully',
                            variant: 'SUCCESS'
                        })
                    );
                    this.isModalOpen = false;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.split('@@')[1],
                            objectApiName: 'ProcessInstanceStep',
                            actionName: 'view'
                        },
                    });
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                    this.isModalOpen = false;
                }
            })
            .catch(error=>{
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
            })
        }
        inputCmp.reportValidity();
    }

    handleRejctRecSave(event) {
        var inputCmp = this.template.querySelector(".requiredValue"); //getting element
        var comm = inputCmp.value; //assigning value to variable
        if (comm === "") {
            inputCmp.setCustomValidity("Complete this field.");
            console.log('coming in here');
        } else {
            inputCmp.setCustomValidity("");
            this.showSpinner = true;
            saveData({
                'recordId': this.recordId,
                'actionName': event.target.title,
                'comments' : comm,
                'processInstanceId' : this.processInsId
            })
            .then(result=>{
                this.showSpinner = false;
                if(result.split('@@')[0] === 'success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Rejected Successfully',
                            variant: 'SUCCESS'
                        })
                    );
                    this.isModalOpen = false;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.split('@@')[1],
                            objectApiName: 'ProcessInstanceStep',
                            actionName: 'view'
                        },
                    });
                }
            })
            .catch(error=>{
                console.log('error is--------------',error);
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
            })
        }
        inputCmp.reportValidity();
    }

}