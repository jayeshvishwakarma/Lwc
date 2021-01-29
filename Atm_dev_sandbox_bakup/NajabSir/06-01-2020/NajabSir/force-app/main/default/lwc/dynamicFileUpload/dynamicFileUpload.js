import { LightningElement, api, track, wire } from 'lwc';
import fetchDocumentUploadLists from '@salesforce/apex/dynamicFileUploadController.fetchDocumentUploadList';
import OnUploadFinishs from '@salesforce/apex/dynamicFileUploadController.OnUploadFinish';
import deleteDocLists from '@salesforce/apex/dynamicFileUploadController.deleteDocList';
import sentotpapex from '@salesforce/apex/dynamicFileUploadController.sendOtp';
import verifyOtpapex from '@salesforce/apex/dynamicFileUploadController.verifyOtp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Responded_via_SF_Error_Message from '@salesforce/label/c.Responded_via_SF_Error';
import Responded_via_Outlook_Text_Error_Message from '@salesforce/label/c.Responded_via_Outlook_Text_Error';
import SBTQM_NRR_Error_Message from '@salesforce/label/c.SBTQM_NRR_Error';
import OTP_Sent_Message from '@salesforce/label/c.OTP_Sent_Message';
import OTP_Verification_Message from '@salesforce/label/c.OTP_Verification_message';
import OTP_does_not_match_message from '@salesforce/label/c.OTP_does_not_match_message';
import General_Closure_Error_message from '@salesforce/label/c.General_Closure_Error';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Clarification_Note_reason_FIELD from '@salesforce/schema/Case.Clarification_Note_reason__c';

export default class DynamicFileUpload extends NavigationMixin(LightningElement) {
    @api documentHeader='Documents'
    @api processName;
    @api processDetail;
    picklistValueWithActionMap;
    // stores current record  id
    @api recordId;
    // for spinner check
    isLoading = false;
    // wrapper to stores Document details
    Filewrapper;
    // OTP verified check
    isNotVerifed ;
    // check to enable button after 5 mins of OTP 
    disableOtpSendBtn;
    // stores case action data , mapped from dealerResolution LWC 
    @api caseActionRecord;
    // stores case  data 
    caseRecord;
    // stores edit check , mapped from dealerResolution LWC 
    @api cannoteditCheck;
    // check for mobile
    ismobile = false;
    // check to show resolution code.
    showOtpScreen ;
    // check to show satisfaction/clarification code.
    showUploadScreen ;
	showTextScreen;
    // stores OTP entered value
    enteredOTPvalue='';
    // stores case record id
    @api caseObjectId;
    // check to make closure mode readonly
    isReadonly;
    // check to upload required doc before submission.
    cannotsave;
    // check to disable upload functionality.
    cannotUpload ;
    // check to disable delete functionality.
    candelete;
    // stores closure mode value
    value ;
    // stores closure mode options
    options;
    // stores comments for MSIL Query
    comment;
    // stores error;
    error;
    isResolved;
    // boolean variable to show custom message when process is MSIL Query and Option is No Response Required
    showMessageIfNoResponseRequired;
    // stores clarification Note Reason value
    clarificationNoteReasonValue;
    // stores clarification Note Reason options
    clarificationNoteReasonoptions;
    // show clarification Note Reason When Process is Service Complaint closure and Closure mode is Clarification Note
    showClarificationNoteReason;

    @track caseDetail = {Id : '', Closure_Mode__c : '', MSIL_Query_Response__c : '', Clarification_Note_reason__c : ''};
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Clarification_Note_reason_FIELD })
    clarificationNoteValues({ data }) {
        if (data) {
            this.clarificationNoteReasonoptions = data.values;
        }
    }

handleRequiredCheckEvent(check,message){
    var documentChecks = {cannotsave:check, isResolved:this.isResolved,errormsg:message };
    const selectedEvent = new CustomEvent("documentupload", { detail: documentChecks });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);  
}
handleMSILQueryEvent(msilResponse,comment){
    var msilQuery = {picklistValue:msilResponse, comment:comment };
    const msilQueryEvent = new CustomEvent("msilqueryresponse", { detail: msilQuery });
    // Dispatches the event.
this.dispatchEvent(msilQueryEvent);  
}

// method to capture Closure Mode Value
handleChange(event) {

this.value = event.detail.value;

this.showOtpScreen=false;
this.showUploadScreen=false;
this.showTextScreen=false;
this.showMessageIfNoResponseRequired=false;
this.showClarificationNoteReason=false;

if(this.value != undefined){
    if(this.processName==='MSIL_Query_Closure'){
        this.caseDetail.MSIL_Query_Response__c=this.value
    }else{
        this.caseDetail.Closure_Mode__c=this.value
    }
    
   if(this.value==='Responded Via SF' && this.caseRecord.No_of_Outbound_Emails__c===0){
       this.handleRequiredCheckEvent(true,Responded_via_SF_Error_Message);
   }
   else if(this.value==='Responded Via SF' && this.caseRecord.No_of_Outbound_Emails__c!=0){
    this.handleRequiredCheckEvent(false,Responded_via_SF_Error_Message);
    this.handleMSILQueryEvent(this.value,this.comment);
   }
   else if(this.value==='Responded via Outlook/Text'){
    this.handleRequiredCheckEvent(this.cannotsave,Responded_via_Outlook_Text_Error_Message);
    this.handleMSILQueryEvent(this.value,this.comment);
   }
   else if((this.value==='Send back to Query Management Team' || this.value==='No Response Required') && this.comment===undefined){
    this.handleRequiredCheckEvent(true,SBTQM_NRR_Error_Message);
   }
   else if((this.value==='Send back to Query Management Team' || this.value==='No Response Required') && this.comment!=undefined){
    this.handleRequiredCheckEvent(false,SBTQM_NRR_Error_Message);
    this.handleMSILQueryEvent(this.value,this.comment);
   }
   else if(this.value==='Clarification Note' && this.processName==='Service_Complaint_Closure'){
       this.showClarificationNoteReason=true;
   }
   if(this.value==='No Response Required'){
       this.showMessageIfNoResponseRequired=true;
   }
   if(this.picklistValueWithActionMap.has(this.value)){
     this.setActions(this.picklistValueWithActionMap.get(this.value)); 
    }
    
   }
}

setActions(actionName){
    if(actionName=='otp'){
        this.showOtpScreen=true;  
    }
    else if(actionName=='upload'){
        this.showUploadScreen=true;
    }
    else if(actionName=='text'){
        this.showTextScreen=true;  
    }
}
handleClarificationNoteChange(event){
    this.clarificationNoteReasonValue = event.detail.value;
    if(this.clarificationNoteReasonValue){
        this.caseDetail.Clarification_Note_reason__c=this.clarificationNoteReasonValue;
        if(!this.cannotsave){
            this.handleRequiredCheckEvent(false,'Please Choose Clarification Note Reason'); 
      
        }
    }
}
handlecomment(event){
    this.comment=event.target.value;
     if((this.value==='Send back to Query Management Team' || this.value==='No Response Required') && this.comment===undefined){
        this.handleRequiredCheckEvent(true,SBTQM_NRR_Error_Message);
       }
     else if((this.value==='Send back to Query Management Team' || this.value==='No Response Required') && this.comment!=undefined){
        this.handleRequiredCheckEvent(false,SBTQM_NRR_Error_Message);
        this.handleMSILQueryEvent(this.value,this.comment);
       }
}
//  Method called on load
connectedCallback(){
    this.resetvalues();
    this.checkForMobileDevice();
    this.fetchUploadedDocList();
}
//  Method to reset values  
resetvalues(){
    
    this.Filewrapper=null;
    this.cannotsave=false;
    this.isReadonly =false;
    this.isNotVerifed=true;
    this.showOtpScreen=false;
    this.showUploadScreen=false;
	this.showTextScreen=false;
    this.cannotUpload=true;
    this.value=null;
}
//  Method to check Mobile 
checkForMobileDevice(){
    // Mobile device check
    let mobileCheck = function() {
       let check = false;
       (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
       return check;
     };
   this.ismobile = mobileCheck();
}
@api
onHoldDocumentUploadCheck(event){
    for(var i=0;i<this.Filewrapper.length;i++){
        if(this.Filewrapper[i].MasterDocName==='Proof Of Hold' && this.Filewrapper[i].isuploaded===false){
            this.handleRequiredCheckEvent(true,'Please Upload Proof Of Hold');   
        }
    }
   
}
//  Method to fetch Uploaded documentList from Apex
@api
fetchUploadedDocList(){
    this.isResolved=false;
    this.isLoading = true;
    var disableduploadActionpicklist = false;
    if(this.caseObjectId===undefined){
        this.caseObjectId=this.recordId;
    }
    fetchDocumentUploadLists({
        recordId : this.caseObjectId,
        processName : this.processName
    })
    .then(result => {
        if(result.message.includes('SUCCESS')){
            if(this.processDetail.Pick_List_Doc_Values_with_Action__c != undefined){
                this.setPicklistValues();
            }
           
            for(var i=0;i<result.parentwrapper.length;i++){

                if((result.parentwrapper[i].MasterDocName==='Closure Mode' || result.parentwrapper[i].MasterDocName==='MSIL Query Response') && result.parentwrapper[i].isuploaded===true){
                    this.isResolved=true; 
                    disableduploadActionpicklist=true;
                }
                if(result.parentwrapper[i].required===true && result.parentwrapper[i].isuploaded===false){
                    if(result.parentwrapper[i].MasterDocName != 'Closure Mode'){
                        this.cannotsave=true;
                    }
                    if(result.parentwrapper[i].MasterDocName === 'Closure Mode' && result.caseObj.OTP_Entered__c === undefined){
                        this.cannotsave=true;
                    }
                }
            }
           
            this.Filewrapper = result.parentwrapper;
            this.disableOtpSendBtn=result.disableSentOtp;
            this.caseRecord=result.caseObj;

            this.caseDetail.Id = this.caseObjectId;

            if(this.cannoteditCheck===false ){
                this.candelete=true;
                this.cannotUpload=false;
            }
            
            if(this.processName==='MSIL_Query_Closure'){
                 if(this.caseRecord.MSIL_Query_Response__c != undefined){
                    this.value = this.caseRecord.MSIL_Query_Response__c;
                }
            }else if(this.caseRecord.OTP_Entered__c != undefined){
                if(this.caseRecord.Closure_Mode__c != undefined){
                    this.value = this.caseRecord.Closure_Mode__c;
                }
                this.isResolved=true;
                this.isNotVerifed=false;
            }else if(this.caseRecord.Closure_Mode__c != undefined){
                this.value = this.caseRecord.Closure_Mode__c;
                // special requirment for service complaint
                if(this.value==='Clarification Note' && this.caseRecord.Clarification_Note_reason__c != undefined && this.processName==='Service_Complaint_Closure'){
                     this.clarificationNoteReasonValue=this.caseRecord.Clarification_Note_reason__c;
                     this.showClarificationNoteReason=true;
                }
                
            }
            
            
            if(this.value != undefined && this.picklistValueWithActionMap!= undefined){
                if(this.processName==='MSIL_Query_Closure'){
                    this.caseDetail.MSIL_Query_Response__c=this.value
                }else{
                    this.caseDetail.Closure_Mode__c=this.value
                }

                if(this.picklistValueWithActionMap.has(this.value)){

                  this.setActions(this.picklistValueWithActionMap.get(this.value));

                  if(disableduploadActionpicklist===true && this.picklistValueWithActionMap.get(this.value)==='upload'){
                    this.isReadonly =true;  
                    }
                    if(this.value==='Clarification Note' && this.caseRecord.Clarification_Note_reason__c === undefined && this.processName==='Service_Complaint_Closure'){
                        this.isReadonly =false; 
                
                    }
                  if(this.picklistValueWithActionMap.get(this.value)!='upload'){
                        if(this.caseRecord.MSIL_Query_Response__c==='No Response Required' && result.caseAcObj.Approval_Status__c==='Rejected'){
                            this.isReadonly =false;  
                        }else if(this.caseRecord.MSIL_Query_Response__c ==='Send back to Query Management Team' && this.caseRecord.Status!='Closed'){
                            this.isReadonly =false;  
                        }else{
                            this.isReadonly =true;   
                        }
                    }
                 }
                 
                }

                if(result.caseAcObj.Id !=undefined && result.caseAcObj.MSIL_Remarks__c != undefined && this.caseRecord.MSIL_Query_Response__c==='No Response Required'){
                    this.comment = result.caseAcObj.MSIL_Remarks__c ;
                }
                else if(this.caseRecord.MSIL_Remarks__c != undefined){
                    this.comment = this.caseRecord.MSIL_Remarks__c ; 
                }

            this.isLoading = false;
            if(this.processName==='MSIL_Query_Closure' ){ 
                if( this.value==='Responded via Outlook/Text'){
               this.handleRequiredCheckEvent(this.cannotsave,Responded_via_Outlook_Text_Error_Message);
            }
            }else if(this.caseRecord.Closure_Mode__c && this.caseRecord.Closure_Mode__c==='Clarification Note' && this.caseRecord.Clarification_Note_reason__c === undefined && this.processName==='Service_Complaint_Closure'){
                this.handleRequiredCheckEvent(true,General_Closure_Error_message);
                this.showClarificationNoteReason=true;
           }
            else{
            this.handleRequiredCheckEvent(this.cannotsave,General_Closure_Error_message);
            }
            
            
        }
        // Apex Exception handling
        else{
            this.messageHandler(result.message,'error','ERROR!');
            this.isLoading = false;
        }

    })
    // Javascript Exception handling
    .catch(error => {
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.message === 'string') {
            this.error = error.message;
        }
        this.isLoading = false;
        const toastEvt = new ShowToastEvent({
            "title": "ERROR!",
            "message": this.error,
            "variant" :"error"
        });
        this.dispatchEvent(toastEvt);
    }) 
}
setPicklistValues(){
    let map = new Map();
    var pickvalues =[];
for(var str of this.processDetail.Pick_List_Doc_Values_with_Action__c.split(",")){
     var data = str.split(';');
    pickvalues.push({ label: data[0], value: data[0] });
    map.set(data[0],data[1]);
 }
   this.options=pickvalues;
   this.picklistValueWithActionMap=map;
}

// Method to called after document upload is finished
handleUploadFinished(event) {
    this.isLoading = true;
    var uploadedFiles = event.detail.files;
    var name = event.target.name;
    OnUploadFinishs({
        recordId : this.caseObjectId,
        filedata :JSON.stringify(uploadedFiles),
        fileUniquename : event.target.name,
        processName : this.processName,
        caseDetail : JSON.stringify(this.caseDetail),
        isResolved : this.isResolved
    })
    .then(result => {
        console.log('Result  ', result);
        this.isLoading = false;
        if(result.includes('SUCCESS')){
           this.connectedCallback();
           /* for(var i =0;i<this.Filewrapper.length;i++){
                if(this.Filewrapper[i].MasterDocName===name){
                    let childrecord ={};
                    childrecord.documentid=uploadedFiles[0].documentId;
                    childrecord.fileuniquename=uploadedFiles[0].name;
                    childrecord.isDownloded=true;
                    this.Filewrapper[i].childRecordList.push(childrecord);
                }

            }*/
        }
        // Apex Exception handling
        else{
            this.messageHandler(result,'error','ERROR!');
        }

    })
    // Javascript Exception handling
    .catch(error => {
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
        this.isLoading = false;
        
        this.messageHandler(this,error,'error','ERROR!');
        
    })
}

// Method to preview document
preview(event){
    
    var idx = event.target.getAttribute('data-index');
    console.log('== IN Child File ', idx);
        if(idx){
           let recordId =  idx;
            const selectedEvent = new CustomEvent("viewfile", {
                detail: { recordId}
              });
            this.dispatchEvent(selectedEvent);
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__namedPage',
            //     attributes: {
            //         pageName: 'filePreview'
            //     },
            //     state : {
            //         // assigning ContentDocumentId to show the preview of file
            //         selectedRecordId:idx
            //     }
            //   })
        } 
    
}

// Method to delete document
deletedoc(event){
    this.isLoading = true;
    deleteDocLists({
        docId :event.target.getAttribute('data-index')
    })
    .then(result => {
        console.log('Result  ', result);
        this.isLoading = false;
        if(result.includes('SUCCESS')){
            this.connectedCallback();
        }
        // Apex Exception handling
        else{ 
            this.messageHandler(result,'error','ERROR!');
        }

    })
    // Javascript Exception handling
    .catch(error => {
        
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
        this.isLoading = false;
        this.messageHandler(this.error,'error','ERROR!');
    })  
}

// Method to generate OTP
sendOTP(event){
    this.isLoading = true;
    sentotpapex({
        recordId : this.caseObjectId
    })
    .then(result => {
        if(result.includes('SUCCESS')){
            this.disableOtpSendBtn=true;
            this.isLoading = false;
           
            this.messageHandler(OTP_Sent_Message,'success','Success!');
            var timmer = 5*60*60*1000;
            setTimeout(() => {
                this.disableOtpSendBtn=false;
            }, timmer);
        }
        else{
            this.isLoading = false;
            this.messageHandler(result,'error','ERROR!');
        }
        

    })
    // Javascript Exception handling
    .catch(error => {
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
        this.isLoading = false;
        this.messageHandler(this.error,'error','ERROR!');
    }) 
}

// Method to store OTP Entered Value
enteredOTP(event){
    this.enteredOTPvalue = event.target.value;   
}

// Method to verify OTP
VerifyOTP(event){
    this.isLoading = true;
    verifyOtpapex({
            recordId : this.caseObjectId,
            otpentered : this.enteredOTPvalue,
            closuremode : this.value
    })
    .then(result => {
        console.log('Result  ', result);
        
            if(result.includes('SUCCESS')){
                this.isNotVerifed=false;
                this.isLoading = false;
              
                this.messageHandler(OTP_Verification_Message,'success','Success!');

                this.connectedCallback();
            }
            else if(result.includes('ERROR')){
                this.isLoading = false;
                this.messageHandler(OTP_does_not_match_message,'error','ERROR!');
            }
            // Apex Exception handling
            else{
                this.isLoading = false;
                this.messageHandler(result,'error','ERROR!');
                    
            }
    })
    // Javascript Exception handling
    .catch(error => {
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
        this.isLoading = false;
        this.messageHandler(this.error,'error','ERROR!');
    })
    
}
messageHandler(message,errortype,header){
    if(this.ismobile){
        alert(message);
    }
    else{
        const toastEvt = new ShowToastEvent({
            "title": header,
            "message": message,
            "variant" :errortype
        });
        this.dispatchEvent(toastEvt);
    }
}
}