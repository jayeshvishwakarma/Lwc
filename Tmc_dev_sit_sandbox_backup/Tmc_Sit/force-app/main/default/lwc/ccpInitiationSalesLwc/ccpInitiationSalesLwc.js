import { LightningElement,api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import updateCaseWithCCP from '@salesforce/apex/CcpInitiationSalesController.updateCaseWithCCP';
import getCcpOnloadInfo from '@salesforce/apex/CcpInitiationSalesController.getCcpOnloadInfo';
import updateFileUniqueName from '@salesforce/apex/CcpInitiationSalesController.updateFileUniqueName';
import { deleteRecord } from 'lightning/uiRecordApi';

//import Id from '@salesforce/user/Id';
const FIELDS = ['Case.CCP_Mode__c', 'Case.CaseNumber', 'Case.CCP_Status__c'];
export default class CcpInitiationSalesLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    isSpinnerShow = true;
    isMobile = false;
    documentType = 'CCP'
    // Conditional render variables
    isSubmitShow = false;
    isReadOnly = true;
    // Onload Variables
    currentUserIsL3L4OrSystemAdmin = true;
    caseObj;
    isCaseActionApprovedOrInProgress;
    @track documentList = [];

    connectedCallback() {
        this.checkForMobileDevice();
        this.getOnloadInfo();
    }
    // method to check mobile
    checkForMobileDevice() {
        // Mobile device check
        let mobileCheck = function() {
            let check = false;
            (function(a) {
                if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true;
            })(navigator.userAgent || navigator.vendor || window.opera);
            return check;
        };
        this.isMobile = mobileCheck();
    }
    getOnloadInfo() {
        try {
            this.isSpinnerShow = true;
            getCcpOnloadInfo({
                    recordId: this.recordId,
                    documentType : this.documentType
                })
                .then(result => {
                    console.log(result);
                    if (result) {
                        if (result.contentVersions) {
                            // To show thw documents name wise
                            this.updateDocumentNumber(result.contentVersions);
                        }
                        if (result.caseObj) {
                            this.caseObj = result.caseObj;
                        }
                        this.isCaseActionApprovedOrInProgress = result.isCaseActionApprovedOrInProgress;
                     //   this.currentUserIsL3L4OrSystemAdmin = result.currentUserIsL3L4OrSystemAdmin
                        this.setFieldsVisibility();
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    let errorMessage = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        errorMessage = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        errorMessage = error.body.message;
                    }
                    this.showToast('error', 'Error', errorMessage);
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in getOnloadInfo JS function');
            console.log(e.message);
        }
    }
    setFieldsVisibility() {
        let caseObj = this.caseObj;
        console.log(this.currentUserIsL3L4OrSystemAdmin );
        if( !caseObj.CCP_Mode__c){
            this.isReadOnly = false;
        }
        if (caseObj.CCP_Mode__c) {
            this.isReadOnly = true;
        }
        if (this.isReadOnly && this.currentUserIsL3L4OrSystemAdmin && caseObj.Trigger_CCP_Not_Responded_Flow__c) {
            this.isSubmitShow = true;
            this.isReadOnly = false;
        }
        if(this.isCaseActionApprovedOrInProgress){
            //this.isReadOnly = true;
            //this.isSubmitShow = false;
        }
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log(this.uploadedFiles);
        this.updateFileUniqueName(uploadedFiles[0].documentId);
    }
    isUploadedFileMissing(event) {
        if (this.documentList.length === 0) {
            this.isSpinnerShow = false;
            let errorMessage = 'Please upload a proof of CCP.'
            if (this.isMobile) {
                alert(errorMessage);
            } else {
                this.showToast('error', 'Error!', errorMessage);
            }
            return true;
        }
        return false;
    }
    handleOnload(event) {
        this.isSpinnerShow = false;
        console.log('CCP Remarks loaded');
    }
    handleError(event) {
        this.isSpinnerShow = false;
    }
    handleSave(event) {
        //  this.isSpinnerShow = true;
        if (!this.isUploadedFileMissing(event)) {
            const submitBtn = this.template.querySelector('.submit-btn');
            submitBtn.click();
        }
    }
    // Method Called on submit of Record Edit Form
    handleSubmit(event) {
        event.preventDefault();
        let fields = event.detail.fields;
        let caseObj = {};
        caseObj.Id = this.recordId;
        caseObj.CCP_Mode__c = this.isSubmitShow ? this.caseObj.CCP_Mode__c : fields.CCP_Mode__c;
        caseObj.CCP_Remarks__c = fields.CCP_Remarks__c;
        console.log(caseObj);
        this.updateCaseWithCCP(caseObj);
    }
    // Method to shoe the toast message
    showToast(type, title, message) {
        const toastEvt = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": type
        });
        this.dispatchEvent(toastEvt);
    }
    cancel() {
        try {
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
            return;
        } catch (e) {
            console.log(e.message);
        }
    }
    updateCaseWithCCP(caseObj) {
        try {
            this.isSpinnerShow = true;
            updateCaseWithCCP({
                    caseObj: caseObj,
                    isCreateCaseAction:  this.isSubmitShow
                })
                .then(result => {
                    console.log(result);
                    if(result){
                        this.isReadOnly = true;
                        let redirectId = this.isSubmitShow ? result : this.recordId;
                        let objectName = this.isSubmitShow ? 'Case_Actions__c' :'Case';
                        if(result.length === 15 || result.length === 18){
                            eval("$A.get('e.force:refreshView').fire();");
                            let message = this.isSubmitShow ? 'CPP Updated and Submitted for Approval' : 'CCP initiated successfully!';
                            this.showToast('success', 'Success', message);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: redirectId,
                                    objectApiName: objectName,
                                    actionName: 'view'
                                }
                            });  
                        }else{
                            let message = result;;
                            this.showToast('error', 'Error', message);
                        }
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    let errorMessage = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        errorMessage = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        errorMessage = error.body.message;
                    }
                    this.showToast('error', 'Error', errorMessage);
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in updateCaseWithCCP JS function');
            console.log(e.message);
        }
    }
    updateFileUniqueName(fileId) {
        try {
            this.isSpinnerShow = true;
            updateFileUniqueName({
                    contentVersionId: fileId,
                    caseNumber: this.caseObj.CaseNumber,
                    recordId: this.recordId,
                    documentType: this.documentType
                })
                .then(result => {
                    console.log(result);
                    if (result) {
                        this.updateDocumentNumber(result);
                        //this.documentList  = result;
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    let errorMessage = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        errorMessage = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        errorMessage = error.body.message;
                    }
                    this.showToast('error', 'Error', errorMessage);
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in updateFileUniqueName JS function');
            console.log(e.message);
        }
    }
    updateDocumentNumber(documentList) {
        let i = 1
        documentList.forEach((doc) => {
            doc.number = i;
            i++;
        })
        this.documentList = documentList;
    }
    viewFile(event){
        try{
            event.preventDefault();
            let value =  event.currentTarget.dataset.value;
            const selectedEvent = new CustomEvent("openFile", {
                detail: { value}
              });
            this.dispatchEvent(selectedEvent);
            // event.preventDefault();   
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__namedPage',
            //     attributes: {
            //         pageName: 'filePreview'
            //     },
            //     state : {
            //         // assigning ContentDocumentId to show the preview of file
            //         selectedRecordId: event.currentTarget.dataset.value
            //     }
            // });
        }catch(e){
            console.log(e.message); 
        }      
    }
    deleteFile(event) {
        if(this.isReadOnly){
            return;
        }
        let id = event.currentTarget.dataset.value;
        deleteRecord(id)
            .then(() => {
               this.showToast('success','Success','File Deleted Successfully.');
               const documentList = this.documentList.filter(item => item.ContentDocumentId !== id);
               this.updateDocumentNumber(documentList);
            })
            .catch(error => {
                this.showToast('error','Error',error.body.message );
            });
    }
}