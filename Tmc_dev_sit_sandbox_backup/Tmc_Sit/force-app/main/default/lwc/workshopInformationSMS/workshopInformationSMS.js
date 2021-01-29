/* eslint-disable no-console */
import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import fetchWorkShopDetails from "@salesforce/apex/WorkshopInformationSMS.fetchWorkShopDetails";
import createMcCommunicationrecord from "@salesforce/apex/WorkshopInformationSMS.createMcCommunicationrecord";
import UI_Error_Message from "@salesforce/label/c.UI_Error_Message";
import workShopSMSMessage from "@salesforce/label/c.workShopSMSMessage";
import profile_Name from "@salesforce/schema/User.Profile.Name";
import dealerId from "@salesforce/schema/User.AccountId";
import numberNotPresent from "@salesforce/label/c.Workshop_Information_SMS";
import Phone_Number_Length from "@salesforce/label/c.Phone_Number_Length";

import {
    getRecord
} from "lightning/uiRecordApi";
import currentUserId from "@salesforce/user/Id";
// To use the WorkshopSMSProfileCheck Custom Label
import WorkshopSMSProfileCheck from "@salesforce/label/c.WorkshopSMSProfileCheck";
import {
    NavigationMixin
} from "lightning/navigation";
import {
    retrieveObjectArrayFromCache
} from "c/cacheServiceLayerCMP";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

export default class WorkshopInformationSMS extends NavigationMixin(LightningElement) {

    @api recordId;
    personContactId;
    @track workshopList = [];
    @track loading = false;
    accCustomerData;
    sendWorkshopSMStoCustomer;
    workshopId;
    parentDealerId;
    errorMessage;
    activityId;
    templateId;
    @track templateList = [{label: "Sales",value: "Sales"}, {label: "Service",value: "Service"},{label: "MSDS",value: "MSDS"},{label: "Accessories",value: "Accessories"}];

    get loaded() {
        return !this.errorMessage && !this.loading;
    }

    // This method is used to fetch Profile of Logged in User
    @wire(getRecord, {
        recordId: currentUserId,
        fields: [profile_Name, dealerId]
    })
    currentUser({
        error,
        data
    }) {
        if (data) {
            if (data.fields.Profile.displayValue && WorkshopSMSProfileCheck && !WorkshopSMSProfileCheck.includes(data.fields.Profile.displayValue)) {
                this.closeModal();
                this.profileNameCheck();
            } else if (data.fields.AccountId.value && WorkshopSMSProfileCheck && WorkshopSMSProfileCheck.includes(data.fields.Profile.displayValue)) {
                this.parentDealerId = data.fields.AccountId.value;
            }
        }
    }

    connectedCallback() {
        this.loading = true;
        let response = retrieveObjectArrayFromCache();
        fetchWorkShopDetails({
                customerRecId: this.recordId
            })
            .then(result => {
                if (result) {
                    var data = result.workshopRec;
                    let i = 0;
                    for (i = 0; i < data.length; i++) {
                        this.workshopList = [...this.workshopList, {
                            value: data[i].Id,
                            label: data[i].Name
                        }];
                        if (data[i].Id === this.parentDealerId) {
                            this.workshopId = this.parentDealerId;
                        }
                    }
                    this.accCustomerData = result.customerRec[0] ? result.customerRec[0] : '';

                    if (response && response.Id && response.Customer_Mobile__c && response.Contact_ID__c &&
                        this.recordId === response.Contact_ID__c) {
                        this.sendWorkshopSMStoCustomer = response.Customer_Mobile__c;
                        this.activityId = response.Id;
                    } else if (this.accCustomerData && this.accCustomerData.PersonMobilePhone) {
                        this.sendWorkshopSMStoCustomer = this.accCustomerData.PersonMobilePhone;
                    } else {
                        this.loading = false;
                        this.showErrorMessage(numberNotPresent);
                    }
                }
                this.loading = false;
            })
            .catch(error => {
                this.loading = false;
                this.errorMessage = UI_Error_Message;;
                this.showErrorMessage(UI_Error_Message);
            });
    }

    profileNameCheck() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: "This component is not applicable for the logged in User",
                variant: "error"
            })
        );
        this.loading = false;

    }


    handleValueChange(event) {
        if (event.target.name === 'workshopDetails') {
            this.workshopId = event.target.value;
        } else if (event.target.name === 'PhoneNumber') {
            this.sendWorkshopSMStoCustomer = event.target.value;
        }  else if (event.target.name === 'templateDetails') {
            this.templateId = event.target.value;
        }
        
    }


    // To Handle the data validation for lightning-combobox fields
    validationCheckMethod() {
        let inps = [].concat(
            this.template.querySelector(".inputCmb"),
            this.template.querySelector(".inputCmp"),
            this.template.querySelector(".inputCmt"),
        );
        return inps.filter(inp => !inp.reportValidity()).length === 0;
    }


    handleSave() {
        this.loading = true;
        if (this.validationCheckMethod() && this.workshopId) //this.activityId add when Cache Component is working
        {
            console.log('(this.sendWorkshopSMStoCustomer)----->' + (this.sendWorkshopSMStoCustomer).length);
            if ((this.sendWorkshopSMStoCustomer).length === 10) {
                createMcCommunicationrecord({
                        workshopId: this.workshopId,
                        customerName: this.accCustomerData.Name,
                        customerMobile: this.sendWorkshopSMStoCustomer,
                        customerId: this.recordId,
                        personConId: this.accCustomerData.PersonContactId,
                        templateId: this.templateId
                    })
                    .then(result => {
                        if (result && result.createdId && result.message === 'Success') {
                            this.closeModal();
                            this.showSuccessMessage(workShopSMSMessage);
                        } else {
                            this.closeModal();
                            this.showErrorMessage(UI_Error_Message);
                        }
                        this.loading = false;
                    })
                    .catch(error => {
                        this.loading = false;
                    });
            } else {
                this.loading = false;
                this.showMessage("Something is wrong", Phone_Number_Length, "error");
            }
        } else {
            // To popup error message when required fields are missing message.
            //allValid1.reportValidity();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Something is wrong",
                    message: "Required fields are missing",
                    variant: "error"
                })
            );
            this.loading = false;
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

    closeModal() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Account", // objectApiName is optional
                actionName: "view"
            }
        });
    }

    taskDetailsMissing() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: "Task details are missing",
                variant: "error"
            })
        );
        this.loading = false;
    }


}