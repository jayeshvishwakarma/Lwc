import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';

import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    NavigationMixin
} from "lightning/navigation";
import {
    getPicklistValues
} from "lightning/uiObjectInfoApi";
import recTypeId from "@salesforce/schema/WorkOrder.RecordTypeId";
import appCancelReason from "@salesforce/schema/WorkOrder.Appointment_Cancellation_Reason__c";
import fetchWorkShopRec from "@salesforce/apex/CancelAppointment.fetchWorkShopRec";
import deleteAppointment from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import profileId from "@salesforce/schema/User.ProfileId";
import currentUserId from "@salesforce/user/Id";
import {
    getRecord,
    updateRecord
} from "lightning/uiRecordApi";

import Appointment_Canceled from "@salesforce/label/c.Appointment_Canceled";
import canncelApp from "@salesforce/label/c.Cancel_Appointment";
import SAProfileId from "@salesforce/label/c.Service_Advisor_Profile_Id";

export default class CancelAppointmentLWC extends LightningElement {
    @api recordId;
    @track workOrderRecordTypeId;
    @track cancelOptions;
    @track loading = true;
    appointmentStatus;
    errorMessage;
    serviceNumber;
    userProfileId; //This field is used to store loggedin user's profile Id

    @track cancellationRequest = {
        "dealerCode": "",
        "locationCode": "",
        "userID": "CRMUSER",
        "appointmentCancelReason": ""
    }
@wire(getRecord, {
    recordId: currentUserId,
    fields: [profileId]
  })
  currentUser({
    error,
    data
  }) {
    if (data) {   
      this.userProfileId = data.fields.ProfileId.value;
    }
  }



    @wire(getRecord, {
        recordId: '$recordId',
        fields: [recTypeId]
    })
    currentAccountData({
        error,
        data
    }) {
        if (data) {
            console.log('data------>', data);
            this.workOrderRecordTypeId = data.recordTypeId;
        } else {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$workOrderRecordTypeId",
        fieldApiName: appCancelReason
    })
    cancelOptions;

    get loaded() {
        return !this.errorMessage && !this.loading;
    }


    connectedCallback() {
        if (this.recordId) {
           // console.log('Working----------->');
            fetchWorkShopRec({
                    appointmentId: this.recordId
                })
                .then(response => this.handleUpdateResponse(response))
                .catch(error => this.handleError(error));
        }
    }

    handleFieldUpdate(event) {
        this.appointmentStatus = event.target.value;
        this.cancellationRequest.appointmentCancelReason=event.target.value;
    }

    handleUpdateResponse(response) {
        if (response) {
            if(SAProfileId===this.userProfileId.substring(0,15) && currentUserId!==response.OwnerId){
                this.showMessage("Something is wrong", 'You are not allowed to cancel this appointment', "error");
                this.closeModal();
              }
            console.log('response--------------->',response);
            this.loading = false;
            // fetch today's date and format in YYYY-MM-DD 
            let today = new Date(); // Today's Date
            var dd = today.getDate();
            var mm = today.getMonth() + 1;
            var yyyy = today.getFullYear();
            if (dd < 10) {
                dd = '0' + dd;
            }
            if (mm < 10) {
                mm = '0' + mm;
            }
            today = yyyy + '-' + mm + '-' + dd;

            // Appointment Date
            var appDate = (response.Appointment_Datetime__c).split("T");
            var todaysDate = new Date(today);
            var appointmentDate = new Date(appDate[0]);
            //if (appointmentDate >= todaysDate) {
                console.log('response----->', response);
                if (response.Status !== 'Canceled') {
                    this.loading = false;
                    if (response.Workshop__r.Dealer_Map_Code__c && response.Workshop__r.Dealer_Location__c && response.Service_Number__c) {
                        this.cancellationRequest.dealerCode=response.Workshop__r.Dealer_Map_Code__c;
                        this.cancellationRequest.locationCode=response.Workshop__r.Dealer_Location__c;
                        this.serviceNumber=response.Service_Number__c;
                        console.log('this.cancellationRequest--->',this.cancellationRequest);
                    } else {
                        this.showErrorMessage('Either Dealer Map code/ Dealer Location Code/ Service NUmber are missing');
                        this.closeModal();
                    }
                } else {
                    this.showErrorMessage(canncelApp);
                    this.closeModal();
                }
            /*} else {
                this.showErrorMessage('Past Appoinments cannot be changed');
                this.closeModal();
            }*/

        } else {
            this.loading = false;
        }

    }

    deleteAppointment(apiReqData) {
        console.log('request-------->',apiReqData);
        let params = {
            jitName: "Cancel_Appointment",
            jsonBody: JSON.stringify(apiReqData),
            urlParam: "",
            urlPart :this.serviceNumber
        };

        // make JIT call
        deleteAppointment(params)
            .then(response => this.handleAPIResponse(response))
            .catch(error => this.handleError(error));
    }

    handleAPIResponse(response) {
        console.log('response-----API---->',response);
        if (response.status === "Success") {
            this.updateAppointment();
        } else {
            this.handleError(response);
        }
    }

    handleError(error) {
        this.loading = false;
        this.showErrorMessage(error.message);
    }

    updateAppointment(){
        let record = {
            fields: {
              Id: this.recordId,
              Status: 'Canceled',
              Appointment_Cancellation_Reason__c : this.cancellationRequest.appointmentCancelReason
            },
          };
          updateRecord(record)
            // eslint-disable-next-line no-unused-vars
            .then(response => this.handleSuccess(response))
            .catch(error => {
              this.errorMessage = this.error.message.body;
              this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Error on data save',
                  message: error.message.body,
                  variant: 'error',
                }),
              );
            });
    }

    handleSuccess(response){
        console.log('handleSuccess------------>',response);
        this.showSuccessMessage(Appointment_Canceled);
        this.closeModal();
    }

    cancelAppRec() {
        if (this.validateInputs()) {
            this.loading=true;
            this.deleteAppointment(this.cancellationRequest);
        } else {
            this.showErrorMessage("Required field is Missing");
        }
    }

    //method to show success toast message
    showSuccessMessage(message) {
        this.showMessage("Success", message, "success");
    }
    //method to show error toast message
    showErrorMessage(error) {
        this.showMessage("Something is wrong", error, "error");
    }
    showMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    //method to close the quick action
    closeModal() {
        //fire the custom event to be handled by parent aura component
        this.dispatchEvent(new CustomEvent("finish"));
    }


    //to handle the data validation
    validateInputs() {
        let inps = [].concat(
            this.template.querySelector(".inputCmp"),
            //this.template.querySelector(".inputText")
        );
        return inps.filter(inp => !inp.reportValidity()).length === 0;
    }
}