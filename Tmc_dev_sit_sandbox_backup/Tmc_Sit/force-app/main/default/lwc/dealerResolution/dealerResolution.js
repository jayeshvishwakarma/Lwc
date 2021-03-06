import {
  LightningElement,
  api,
  wire
} from 'lwc';
import {
  NavigationMixin
} from 'lightning/navigation';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent'
import strUserId from '@salesforce/user/Id';
import fetchcaseActionapex from '@salesforce/apex/CaseActionCreation.fetchcaseAction';
import updateCaseStatusResolvedapex from '@salesforce/apex/CaseActionCreation.updateCaseStatusResolved';
import initiateApprovalapex from '@salesforce/apex/CaseActionCreation.callApprovalFlow';
import updateMsilQueryResponseapex from '@salesforce/apex/CaseActionCreation.updateMsilQueryResponse';
import Tentative_Delivery_Date_FIELD from '@salesforce/schema/Case.Enquiry__r.Tentative_Delivery_Date__c';
import RestrictGenral from "@salesforce/label/c.Restrict_General";
import {
  getRecord,
  getFieldValue
} from 'lightning/uiRecordApi';
/** Added for Dealer Inbound By Sunit **/
import currentUserProfile from '@salesforce/apex/ProjectUtility.getCurrentUserProfile';
import caseClosedSuccessMessage from "@salesforce/label/c.Case_Close_Success_Message";
import checkApprovalRequired from '@salesforce/apex/CaseActionCreation.checkApprovalRequired';
import Business_Area from '@salesforce/schema/Case.Business_Area__c';
import Case_Type from '@salesforce/schema/Case.Case_Type__c';
import channel from '@salesforce/schema/Case.Channel__c';
import caseStage from '@salesforce/schema/Case.Case_Stage__c';
import primaryCategory from '@salesforce/schema/Case.Primary_Category__c';
import secondaryCategory from '@salesforce/schema/Case.Secondary_Category__c';
import caseOwnerId from '@salesforce/schema/Case.OwnerId';

const fields = [Business_Area, Case_Type, channel, caseStage, primaryCategory, secondaryCategory, Tentative_Delivery_Date_FIELD, caseOwnerId];
/*************************************/

export default class DealerResolution extends NavigationMixin(LightningElement) {
userId = strUserId;
caseActionObj;
  openInEditMode = false;
@api recordId;
@api Mode;
  cannotedit = true;
cannotUpload;
error;
  sObjectName = 'Case_Actions__c';
caseActionRecordtypeId;
name;
caseaccObjrecordId;
caseObjrecordId;
showecreateform;
  showviewform = false;
  isSpinnerShow = false;
  ismobile = true;
cannotsave;
fields;
fieldHeader;
DocumentHeader;
  @api caseupdate;
@api ProcessName;
processDetail;
isResolved;
  showFieldHeader = false;
customError;
picklistValue;
comment;
isServiceComplaintClosure;
sendForApprovalServiceComplaint;
showSaveMsgServiceComplaint;
showTDD=false;
//case;
//@wire(getRecord, { recordId: '$recordId', fields: [Tentative_Delivery_Date_FIELD] }) case;


/** Added for Dealer Inbound By Sunit **/
businessArea;
caseDetails;
approvalProcessName;
  @wire(getRecord, {
    recordId: '$recordId',
    fields
  })
  case ({
    error,
    data
  }) {
      if (data) {
      this.caseDetails = data;
      this.businessArea = data.fields.Business_Area__c.value;      
      this.ProcessName = this.caseupdate !== undefined ? this.caseupdate : this.ProcessName;
      if (this.ProcessName && this.ProcessName.includes('Dealer_Internal')) {
        currentUserProfile()
          .then(result => {
            if ((result === 'Call Center Executive Service' || result === 'CCE Insurance') && this.userId !== data.fields.OwnerId.value) {
                this.messageHandler('You are not allowed to close this case', 'error', 'ERROR!');
            } else {
              if ((this.caseDetails.fields.Business_Area__c.value === 'MIBPL (Insurance)' || this.caseDetails.fields.Business_Area__c.value === 'Service-Workshop' ||
                  this.caseDetails.fields.Business_Area__c.value === 'Service-Bodyshop') && this.caseDetails.fields.Primary_Category__c.value === 'General') {
                this.messageHandler(RestrictGenral, 'error', 'ERROR!');
              } else {
            this.fetchCaseAction();
            }
          }
          })
          // Javascript Exception handling
          .catch(error => {
            if (Array.isArray(error.body)) {
              this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.message === 'string') {
              this.error = error.message;
      }
            this.messageHandler(this.error, 'error', 'ERROR!');
          })
        
       
      }
    } else {
          console.log(error);
      }
  }
/*************************************/
  get TDD() {
    return getFieldValue(this.caseDetails, Tentative_Delivery_Date_FIELD);
  }


// method to check required doc uploaded before sending to approval
  handledocumentupload(event) {
var details = event.detail;
this.cannotsave = details.cannotsave;
this.isResolved = details.isResolved;
this.customError = details.errormsg;
}

// method to handle event from dynamicFileUploadTo store MSIL Query Response 
  handledMSILQueryResponse(event) {
var details = event.detail;
this.picklistValue = details.picklistValue;
this.comment = details.comment;
}

handleOpenFile(event){
  console.log('== IN parent File 1st');
  let value = event.detail.recordId;
  console.log('== IN parent File 2nd', value);
  const selectedEvent = new CustomEvent("openFile", {
    detail: { value}
  });
  this.dispatchEvent(selectedEvent);

}

// method called on Edit Button
handleedit(event){ 
this.showviewform=false;
this.showecreateform=true;
this.cannotUpload = this.cannotedit;
}

  connectedCallback() {
  this.checkForMobileDevice();
    this.ProcessName = this.caseupdate !== undefined ? this.caseupdate : this.ProcessName;
    if (this.ProcessName && !this.ProcessName.includes('Dealer_Internal')) {
    this.fetchCaseAction();
  }
}
// method to check mobile
  checkForMobileDevice() {
// Mobile device check
    let mobileCheck = function () {
  let check = false;
      (function (a) {
        if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true;
      })(navigator.userAgent || navigator.vendor || window.opera);
  return check;
};
this.ismobile = mobileCheck();
}

  fetchCaseAction() {
this.isSpinnerShow = true;
/******** Added for Dealer Inbound (Sunit) ***********/
    this.approvalProcessName = this.ProcessName;
    if (this.ProcessName.includes('Dealer_Internal_Case_Closure')) {
      if (this.businessArea.includes('Accessories')) {
        this.ProcessName = this.ProcessName + '_Acces'
      } else if (this.businessArea.includes('Service')) {
        this.ProcessName = this.ProcessName + '_Service'
      } else if (this.businessArea.includes('MIBPL')) {
        this.ProcessName = this.ProcessName + '_MIBPL'
      } else {
        this.ProcessName = this.ProcessName + '_' + this.businessArea
  }
 // this.ProcessName=this.businessArea.includes('Service')?this.ProcessName+'_'+'Service':this.ProcessName+'_'+this.businessArea;
}
/*****************************************************/
fetchcaseActionapex({
      recordId: this.recordId,
      ProcessName: this.ProcessName
})
.then(result => {
        console.log('result.message' + result.message);
        if (result.message.includes('SUCCESS')) {
          if(this.ProcessName==='On_Hold'){
            this.showTDD=true;
            }           
          var fieldsdetail = [];
          if (result.FieldList != undefined) {
            let arr = JSON.parse(result.FieldList);
            var fieldstobeexculded = '';
            var usersToBeShow = '';
            var userId = '';
            this.userId = this.userId.substring(0, (this.userId).length - 3);

            if (result.FileDetail.Fields_To_be_Excluded__c != undefined && result.FileDetail.Field_Name_Of_Stakeholder__c != undefined && result.stakeHolderids != undefined) {
              fieldstobeexculded = result.FileDetail.Fields_To_be_Excluded__c;
              if (result.stakeHolderids != undefined)
                usersToBeShow = result.stakeHolderids;
      }

            for (var i = 0; i < arr.length; i++) {
              if (!usersToBeShow.includes(this.userId)) {
                if (!fieldstobeexculded.includes(arr[i].name)) {
                  fieldsdetail.push(arr[i]); 
              }
              } else {
              fieldsdetail.push(arr[i]); 
          }
          }  
          this.fields = fieldsdetail;
        }
          if (fieldsdetail.length > 0) {
            this.showFieldHeader = true;
      }
          if (this.ProcessName === 'MSIL_Query_Closure') {
        this.handleOnLoadMSILQuery(result);
          } else if (this.ProcessName === 'Service_Complaint_Closure') {
        this.handleOnLoadServiceComplaint(result);
          } else if (this.ProcessName === 'On_Hold' || this.ProcessName === 'On_Hold_Service') {
            this.handleFormVisibilty(true, false, false, false);
          } else {
        this.handleOnLoadGeneral(result);
      }
          this.processDetail = result.FileDetail;
          this.caseActionRecordtypeId = result.RecordTypeId;
      this.name = result.FileDetail.Label__c;
          this.fieldHeader = result.FileDetail.Field_Section_Header__c;
          this.DocumentHeader = result.FileDetail.Document_Section_Header__c;
          this.caseActionObj = result.caseAction;
          this.caseObjrecordId = result.caseRecordId;
          this.openInEditMode = result.openInEditMode;
      

          if (this.openInEditMode === true && this.cannotedit === false) {
            this.showviewform = false;
            this.showecreateform = true;
        this.cannotUpload = this.cannotedit;
            if (this.ProcessName === 'On_Hold' || this.ProcessName === 'On_Hold_Service') {
          this.handleOnLoadGeneral(result);
        }
      }
          if (this.Mode === 'ReadOnly') {
            this.showviewform = true;
            this.showecreateform = false;
            this.cannotedit = true;
        this.cannotUpload = this.cannotedit;
      }
      this.isSpinnerShow = false;
  }
  // Apex Exception handling
        else {
    this.isSpinnerShow = false;
          this.messageHandler(this.message, 'error', 'ERROR!');
  }

})
// Javascript Exception handling
.catch(error => {
  if (Array.isArray(error.body)) {
      this.error = error.body.map(e => e.message).join(', ');
  } else if (typeof error.message === 'string') {
      this.error = error.message;
  }
  this.isSpinnerShow = false;
        this.messageHandler(this.error, 'error', 'ERROR!');
}) 
}
// Method for all process
  handleOnLoadServiceComplaint(result) {
this.isSpinnerShow = true;
    if (result.caseAction.Id === undefined) {
      this.isServiceComplaintClosure = true;
      this.handleFormVisibilty(true, false, false, false);
    } else {
      if (this.userId === result.caseAction.Current_Approver__c) {
        if (result.caseAction.Approval_Status__c) this.isServiceComplaintClosure = false;
        else this.isServiceComplaintClosure = true;
  } 
      if (this.userId === result.caseAction.Current_Approver__c && result.FileDetail.Can_Current_Approver_Edit__c === true)
        this.cannotedit = false;
      if (result.caseAction.Approval_Status__c === 'Rejected') {
        this.cannotedit = false;
        this.isServiceComplaintClosure = true;
  }
  if (result.caseAction.Approval_Status__c === undefined) {
    this.cannotedit = false;
    this.isServiceComplaintClosure = true;
}
  
      this.caseaccObjrecordId = result.caseAction.Id;
      if (result.caseAction.Approval_Status__c === 'Approved') {
        this.cannotedit = true;
  }
      this.handleFormVisibilty(false, true, this.cannotedit, true);
}
}
// Method for service complaint closure
  handleOnLoadGeneral(result) {
this.isSpinnerShow = true;
    if (result.caseAction.Id === undefined) {
      this.handleFormVisibilty(true, false, false, false);
    } else {
      if (this.userId === result.caseAction.Current_Approver__c && result.FileDetail.Can_Current_Approver_Edit__c === true)
        this.cannotedit = false;
      if (result.caseAction.Approval_Status__c === 'Rejected')
        this.cannotedit = false;
      this.caseaccObjrecordId = result.caseAction.Id;
      if (result.caseAction.Approval_Status__c === 'Approved') {
        this.cannotedit = true;
  }
  /**** Added for Dealer inbound (Sunit) ****/
      if ((result.caseAction.Case_Type__c === 'Dealer Internal Complaint' ||
        result.caseAction.Case_Type__c === 'Dealer Internal Feedback' ||
        result.caseAction.Case_Type__c === 'Dealer Internal Query' ||
        result.caseAction.Case_Type__c === 'Dealer Internal Request') &&
        result.caseAction.Approval_Status__c === 'Rejected')
        this.cannotedit = false;
  /******************************************/
      this.handleFormVisibilty(false, true, this.cannotedit, true);
}
}
// Method for Process Name 'MSIL_Query_Closure'
  handleOnLoadMSILQuery(result) {
this.isSpinnerShow = true;
    if (result.caseObj.MSIL_Query_Response__c === undefined) {
      this.handleFormVisibilty(true, false, false, false);
    } else {
      if (result.caseObj.MSIL_Query_Response__c === 'No Response Required' && result.caseAction.Id != undefined) {
        if (this.userId === result.caseAction.Current_Approver__c && result.FileDetail.Can_Current_Approver_Edit__c === true) {
          this.cannotedit = false;
        }
        this.caseaccObjrecordId = result.caseAction.Id;
        if (result.caseAction.Approval_Status__c === 'Approved') {
          this.cannotedit = true;
        }
        this.handleFormVisibilty(false, true, this.cannotedit, true);
      } else if (result.caseObj.Current_Approver__c != this.userId) {
        this.handleFormVisibilty(false, true, true, true);
      } else if (result.caseObj.Current_Approver__c === this.userId) {
        this.handleFormVisibilty(false, true, false, true);
  }
   if(result.caseObj.MSIL_Query_Response__c ==='Send back to Query Management Team' && result.caseObj.Status!='Closed'){
    this.cannotedit=false;
    this.handleFormVisibilty(false,true,this.cannotedit,true);
  }
}
}

  handleFormVisibilty(creationForm, viewForm, cannotEdit, cannotUpload) {
    this.showecreateform = creationForm;
    this.showviewform = viewForm;
    this.cannotedit = cannotEdit;
    this.cannotUpload = cannotUpload;
}
// Method Called on Load of Record Edit Form
  handleOnload(event) {
  this.isSpinnerShow = false;
}

// Method Called on Error of Record Edit Form
  handleError(event) {
    this.isSpinnerShow = false;
}

// Method Called on submit of Record Edit Form
handleSubmit(event) {
// alert('hhhg'+this.sendForApprovalServiceComplaint);
event.preventDefault();
    this.isSpinnerShow = true;
// check before submit
    if (this.cannotsave) {
        this.handleRequiredCheck(event);
    }
// Call Save Method
    if (!this.cannotsave) {
      if (this.ProcessName === 'On_Hold' || this.ProcessName === 'On_Hold_Service') {
    const fields = event.detail.fields;
        if (fields.Reason_For_Hold__c === 'Customer not available' || fields.Reason_For_Hold__c === 'Customer Unavailable') {
      this.template.querySelector('c-dynamic-file-upload').onHoldDocumentUploadCheck();
          if (this.cannotsave) {
        this.handleRequiredCheck(event);
            this.cannotsave = false;
          } else {
            this.handleSave(event);
          }
        } else {
      this.handleSave(event); 
    }
      } else {
    this.handleSave(event);
    }
        
    }
}

// Method used for required check before different process initiation
  handleRequiredCheck(event) {
    this.isSpinnerShow = false;
    if (this.ismobile) {
          alert(this.customError);
    } else {
      this.messageHandler(this.customError, 'error', 'ERROR!');
      }
}

// Method used to save/update Case Action
  handleSave(event) {
    this.isSpinnerShow = true;
    const fields = event.detail.fields;
    // save call
    if (this.caseaccObjrecordId === undefined) {
      if (this.ProcessName === 'MSIL_Query_Closure') {
        fields.MSIL_Remarks__c = this.comment;
           }
      if (this.ProcessName === 'On_Hold_Service') {
            var today = new Date();
        fields.Hold_Start_Date__c = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
          }
      if (this.ProcessName === 'On_Hold') {
            var today = new Date();
        fields.Hold_Start_Date__c = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        if (this.TDD)
          fields.Tentative_Delivery_Date__c = this.TDD;
            }
           /** Added for Dealer Inbound By Sunit **/
      if (this.ProcessName.includes('Dealer_Internal')) {
        try {
          if (this.ProcessName.includes('Dealer_Internal_Case_Closure')) {
                checkApprovalRequired({
              recordId: this.recordId,
              businessArea: this.businessArea,
              caseType: this.caseDetails.fields.Case_Type__c.value,
                })
                .then(result => {
                if (!result) {
                  this.messageHandler(caseClosedSuccessMessage, 'success', 'Success')
                  }
                })
                // Javascript Exception handling
                .catch(error => {
                  console.log(error);
                })
               }
        } catch (err) {
                console.log(err);
              }
        fields.Channel__c = this.caseDetails.fields.Channel__c.value;
        fields.Case_Type__c = this.caseDetails.fields.Case_Type__c.value;
        fields.Business_Area__c = this.caseDetails.fields.Business_Area__c.value;
        fields.Case_Stage__c = this.caseDetails.fields.Case_Stage__c.value;
        fields.Primary_Category__c = this.caseDetails.fields.Primary_Category__c.value;
        fields.Secondary_Category__c = this.caseDetails.fields.Secondary_Category__c.value;

           }
           /***************************************/
           fields.Name = this.name;
           fields.RecordTypeId = this.caseActionRecordtypeId;
      fields.Case_Number__c = this.recordId;
      if (this.sendForApprovalServiceComplaint) {
        fields.Approval_Status__c = 'In Progress';
           }
     }
     // update call
    if (this.caseaccObjrecordId != undefined) {
      if (this.ProcessName === 'MSIL_Query_Closure') {
        fields.MSIL_Remarks__c = this.comment;
        fields.Id = this.caseaccObjrecordId;
           }
      if (this.sendForApprovalServiceComplaint) {
        fields.Approval_Status__c = 'In Progress';
           }
      if (this.caseActionObj.Approval_Status__c === 'Rejected' && this.ProcessName != 'Service_Complaint_Closure') {
            // method to call approval process on Case action rejection 
            this.initiateApproval(event);
           }
       }
    
    
    // Record Edit Form submit operation
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    // mark case as Resolved
    if (this.isResolved === true && (this.ProcessName === 'Case_Closure' || this.ProcessName === 'Dealer_Query_Closure' || this.ProcessName === 'Service_Complaint_Closure')) {
            this.updateCaseStatusResolved();
      }
    
}

// Method used to mark case as Resolved
  updateCaseStatusResolved() {
    this.isSpinnerShow = true;
  updateCaseStatusResolvedapex({
      recordId: this.recordId
}).then(result => {
      if (result.includes('SUCCESS')) {
        this.isSpinnerShow = false;
  }
  // Apex Error handling
      else {
        this.isSpinnerShow = false;
        this.messageHandler(result, 'error', 'ERROR!');
  }
});
}

// Method used to initiate approval process on Case Action
  initiateApproval(event) {
    this.isSpinnerShow = true;
initiateApprovalapex({
      recordId: this.caseaccObjrecordId,
      processName: this.ProcessName.includes('Dealer_Internal') ? this.approvalProcessName : this.ProcessName
}).then(result => {
      if (result.includes('SUCCESS')) {
    // called for toast and redirection on Case Action when successfully initiated approval flow
    this.handleCaseActionCreation(this.caseaccObjrecordId);
  }
  // apex error handling
      else {
        this.isSpinnerShow = false;
        this.messageHandler(result, 'error', 'ERROR!');
  }
  });
}

// method called on successful save and update 
  handleSuccess(event) {

    this.isSpinnerShow = true;

    if (!this.cannotsave) {
    let updatedRecord = event.detail.id;
      if (this.caseaccObjrecordId != undefined) {
        if (this.sendForApprovalServiceComplaint) {
            this.initiateApproval(event);
          }
        if (this.caseActionObj.Approval_Status__c != 'Rejected') {
      this.handleUpdateOperation(updatedRecord); 
        }
      } else {
          this.handleCaseActionCreation(updatedRecord);
      }
  }
    this.isSpinnerShow = false;
}

// method used to show toast and redirection on case action
  handleCaseActionCreation(updatedRecord) {

    this.isSpinnerShow = true;
    if(this.showSaveMsgServiceComplaint){
      var message = "Case " + this.name + " has been saved successfully"; 
    }
    else{
      var message = "Case " + this.name + " has been initiated successfully";
    }
    this.messageHandler(message, 'success', 'SUCCESS!');

this[NavigationMixin.Navigate]({
type: 'standard__recordPage',
attributes: {
    recordId: updatedRecord,
    objectApiName: this.sObjectName,
    actionName: 'view'
}
});
}

// method used to show toast on update
  handleUpdateOperation(updatedRecord) {

    this.isSpinnerShow = false;
    var message = "Case " + this.name + " has been updated successfully";
    this.messageHandler(message, 'success', 'SUCCESS!');
    this.showviewform = true;
    this.showecreateform = false;
  this.cannotUpload = true;

    if (this.openInEditMode) {
    this.cancel();
  }
}

// method to close quick action
  cancel(event) {
  const handelClose = new CustomEvent('close');
// Dispatches the event.
  this.dispatchEvent(handelClose);
}

// method called on Save Button click 
  saveCase(event) {
    if (this.ProcessName === 'MSIL_Query_Closure') {
      this.isSpinnerShow = true;
      this.msilQueryFollow(event);
  }
    else {
		if(this.ProcessName === 'Service_Complaint_Closure'){
        this.showSaveMsgServiceComplaint=true;
      }
    const submitBtn = this.template.querySelector('.submit-btn');
    submitBtn.click();
}
}

  submitCase(event) {
    this.creationForm = true;
    this.sendForApprovalServiceComplaint = true;
// alert('hhh'+this.sendForApprovalServiceComplaint);
const submitBtn = this.template.querySelector('.submit-btn');
    submitBtn.click();
}

// method for ProcessName MSIL_Query_Closure
  msilQueryFollow(event) {
    this.isSpinnerShow = true;
    if (this.cannotsave) {
      this.isSpinnerShow = false;
      this.handleRequiredCheck(event);
    } else {
    // call to update MSIL Query Response
      this.updateMsilQueryResponse();
      if (this.picklistValue === 'No Response Required') {
        const submitBtn = this.template.querySelector('.submit-btn');
  submitBtn.click(); 
}
}
}

// Method Used to update MSIL Query Response
  updateMsilQueryResponse() {
    this.isSpinnerShow = true;
updateMsilQueryResponseapex({
      recordId: this.recordId,
      msilQueryResponse: this.picklistValue,
      Comment: this.comment
}).then(result => {
      if (result.includes('SUCCESS')) {
  // calling child dynamicFileUpload LWC
  this.template.querySelector('c-dynamic-file-upload').fetchUploadedDocList();
  
        if (this.picklistValue != 'No Response Required') {
      
          this.messageHandler('Case has been updated successfully', 'success', 'SUCCESS!');


          if (this.ismobile) {
this[NavigationMixin.Navigate]({
  type: 'standard__recordPage',
  attributes: {
      recordId: this.recordId,
      objectApiName: 'Case',
      actionName: 'view'
  }
});
}
          this.showviewform = true;
          this.showecreateform = false;
this.cannotUpload = true;
}
        this.isSpinnerShow = false;
      } else {
        this.isSpinnerShow = false;
        this.messageHandler(result, 'error', 'ERROR!');
}
});
}

  messageHandler(message, errortype, header) {

    const toastEvt = new ShowToastEvent({
        "title": header,
        "message": message,
      "variant": errortype
    });
    this.dispatchEvent(toastEvt);
}
}