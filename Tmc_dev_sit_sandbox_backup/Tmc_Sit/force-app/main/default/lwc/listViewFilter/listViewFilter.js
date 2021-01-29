/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import { LightningElement } from 'lwc';
//import getTeamUsers from '@salesforce/apex/listViewFilterApex.getCurrentTeamUsers';
import getTeamUsers from '@salesforce/apex/listViewFilterApexV1.getCurrentTeamUsers';
import getCases from '@salesforce/apex/listViewFilterApex.getCases';
import createTasks from '@salesforce/apex/listViewFilterApex.createDailingList';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getpicklistValues from '@salesforce/apex/listViewFilterApex.getpicklistValues';
//import picklistValues from '@salesforce/apex/listViewFilterApex.caseStatuspicklistValues';
import saveCaseChangeOwner from '@salesforce/apex/listViewFilterApex.saveCaseChangeOwner';
import updateAppointmentDates from '@salesforce/apex/listViewFilterApex.updateAppointmentDates';
import getUserProfileName from '@salesforce/apex/listViewFilterApex.getUserProfileName';


const columns = [
    {
        label: "Case Number",
        fieldName: "nameUrl",
        type: "url",
        typeAttributes: { label: { fieldName: "CaseNumber" }, target: "_self" },
        sortable: true
    },
    { label: 'Customer', fieldName: 'customerName' },
    { label: 'Campaign Name', fieldName: 'campaignName' },
    { label: 'Type', fieldName: 'Type' },
    { label: 'MI Expiry Date', fieldName: 'Expiry_Date__c' },
    { label: 'Policy Number', fieldName: 'Policy_No__c' },
    { label: 'Vehicle Registration Number', fieldName: 'Vehicle_Registration_Number__c' },
    { label: 'Status', fieldName: 'Status' },
    {
        label: 'Appointment', fieldName: 'Pickup_Date__c', type: "date",
        typeAttributes: {
            year: "numeric",
            month: "numeric",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    { label: 'Owner Name', fieldName: 'OwnerName' }
];

const resultDataColumns = [
    { label: 'Case Number', fieldName: 'CaseNumber' },
    { label: 'Message', fieldName: 'message' }
]



export default class ListViewFilter extends NavigationMixin(LightningElement) {
    ownerNames = [];// To show the dropdown with all users belonging to the current Team of current user
    caseRecordTypes = [];
    campaingType = [];
    ownerNameValue = '';
    statusPicklist = '';
    columns = columns;
    data = [];
    showlistView = false;
    showResult = false;
    resultDataColumns = resultDataColumns;
    resultData = [];
    changeOwnerPopup = false;
    inputDiv = true;
    changeOwnerPopup = false;
    resultDropDown = false;
    pillDiv = false;
    loading = false;
    appointmentDatePopup = false;
    disableButton = true;



    connectedCallback() {
        getTeamUsers({ searchTerm: '' })
            .then(result => {
                let data = result;

                let userMap = [];
                userMap.push({ label: 'None', value: '' })
                for (let i = 0; i < data.length; i++) {
                    userMap.push({ label: data[i].Name, value: data[i].Id });
                }
                this.ownerNames = userMap;

            })
            .catch(error => {
                console.error(error);
            });

            getpicklistValues({ sobjectApiName: 'Case', picklistfiledName: 'status' })
            .then(result => {
                if (result) {

                    let conts = result;
                    let tempArray = [];
                    tempArray.push({ label: 'None', value: '' })
                    // eslint-disable-next-line guard-for-in
                    for (let label in conts) {
                        tempArray.push({ label: label, value: conts[label] });
                    }
                    this.statusPicklist = tempArray;

                }

            })
            .catch(error => {
                console.error(error);
            });

        getpicklistValues({ sobjectApiName: 'Case', picklistfiledName: 'Type' })
            .then(result => {
                let data = result;

                let dataMap = [];
                dataMap.push({ label: 'None', value: '' })
                for (let k in data) {

                    dataMap.push({ label: k, value: data[k] });
                }
                this.campaingType = dataMap;

            })
            .catch(error => {
                console.error(error);
            });

        getUserProfileName()
            .then(result => {
                this.campaignOptions = [];
                this.campaignOptions.push({
                    label: 'All',
                    value: ''
                })
                if (result && result.campaignList.length > 0) {
                    for (let i = 0; i < result.campaignList.length; i++) {
                        this.campaignOptions.push({
                            label: result.campaignList[i].Name,
                            value: result.campaignList[i].Id
                        });
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });

    }



    campaignNameChangeHandler(event) {
        this.campaingName = event.target.value;

    }

    campaignTypeChangeHandler(event) {
        this.campaingTypeValue = event.detail.value
    }

    startExpiryDateChangeHandler(event) {
        this.startMIExpiryDate = event.target.value;
        this.startDateEndDateCheck();

    }

    endExpiryDateChangeHandler(event) {
        this.endMIExpiryDate = event.target.value;
        this.startDateEndDateCheck();
    }

    statusChangeHandler(event) {
        this.status = event.detail.value;
    }

    ownerNameChangeHandler(event) {
        this.ownerId = event.detail.value;
    }

    startDateChangeHandler(event) {
        let start = event.target.value;
        this.startDate = start
        this.startDateEndDateCheck();
    }

    endDateChangeHandler(event) {
        this.endDate = event.target.value;
        this.startDateEndDateCheck();
    }

    startDateEndDateCheck() {
        if (this.startDate && this.endDate && this.startDate > this.endDate) {
            this.showErrorMessage('Start Date cannot be greater than End Date');
        }

        if (this.startMIExpiryDate && this.endMIExpiryDate && this.startMIExpiryDate > this.endMIExpiryDate) {
            this.showErrorMessage('Start Date cannot be greater than End Date');
        }


    }




    searchClickHandler() {
        if ((this.startDate && this.endDate && this.startDate > this.endDate) || (this.startMIExpiryDate && this.endMIExpiryDate && this.startMIExpiryDate > this.endMIExpiryDate)) {
            this.showErrorMessage('Start Date cannot be greater than End Date');
        } else {
            this.showlistView = false;
            this.showResult = false;
            this.loading = true;
            this.data = [];
            getCases({ campaignName: this.campaingName, campaignType: this.campaingTypeValue, startMIExpiryDate: this.startMIExpiryDate, endMIExpiryDate: this.endMIExpiryDate, status: this.status, OwnerId: this.ownerId, startDate: this.startDate, endDate: this.endDate })
                .then(result => {
                    let tempData = result;
                    tempData.forEach((row) => {
                        if (row.Owner) {
                            row.OwnerName = row.Owner.Name;
                        }
                        if (row.RecordType) {
                            row.recordTypeName = row.RecordType.Name;
                        }
                        if (row.Customer__r) {
                            row.customerName = row.Customer__r.Name;
                        }
                        if (row.CampaignId__r) {
                            row.campaignName = row.CampaignId__r.Name;
                        }
                    });

                    let defers = tempData.map(row => this.generateUrl(row.Id));
                    Promise.all(defers).then(urls => {
                        this.data = tempData.map((row, ind) => ({ ...row, nameUrl: urls[ind] }));
                    });
                    this.showlistView = true;
                    this.loading = false;

                })
                .catch(error => {
                    console.error(error);
                });
        }


    }


    generateUrl(recordId) {
        return this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId,
                actionName: "view"
            }
        });

    }

    createDailingListHandler() {
        if (this.showlistView === false || this.showResult === true) {
            const event = new ShowToastEvent({
                "title": "Error!",
                "message": "Search and Select records for changing owner",
                "variant": "error"
            });
            this.dispatchEvent(event);
        } else {
            let el = this.template.querySelector('lightning-datatable');
            let selected = el.getSelectedRows();

            if (selected.length < 1) {
                const event = new ShowToastEvent({
                    "title": "Error!",
                    "message": "Select atleast one record!",
                    "variant": "error"
                });
                this.dispatchEvent(event);

            } else {

                createTasks({ caseIds: selected })
                    .then(result => {
                        let obj = result;
                        let dataMap = [];
                        let i = 0
                        for (let key in obj) {
                            dataMap.push({ Id: i, CaseNumber: key, message: obj[key] });
                            i++;
                        }
                        this.resultData = dataMap;
                        this.showlistView = false;
                        this.showResult = true;

                    })
                    .catch(error => {
                        console.error(error);
                    });
            }
        }
    }

    changeOwnerHandler() {
        if (this.showlistView === false || this.showResult === true) {
            const event = new ShowToastEvent({
                "title": "Error!",
                "message": "Search and Select records for changing owner",
                "variant": "error"
            });
            this.dispatchEvent(event);
        } else {
            let el = this.template.querySelector('lightning-datatable');
            let selected = el.getSelectedRows();
            this.recordsLength = selected.length;
            if (this.recordsLength < 1) {
                const event = new ShowToastEvent({
                    "title": "Error!",
                    "message": "Select atleast one record!",
                    "variant": "error"
                });
                this.dispatchEvent(event);

            } else {
                this.selectedCasesList = selected;
                this.changeOwnerPopup = true;
                this.inputDiv = true;
            }
        }

    }

    getUsersHandler(event) {
        let searchKey = event.target.value;
        getTeamUsers({ searchTerm: searchKey })
            .then(result => {
                this.userList = result;
                this.resultDropDown = true;
            })
            .catch(error => {
                console.error(error);
            });
    }


    cancelChangeOwner() {
        this.changeOwnerPopup = false;
        this.pillDiv = false;
        this.inputDiv = false;
    }

    selectUser(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        this.selectedUserName = selectedName;
        this.selectedUserId = selectedId;
        this.resultDropDown = false;
        this.inputDiv = false;
        this.pillDiv = true;
    }

    handleRemove() {
        this.selectedUserName = '';
        this.pillDiv = false;
        this.inputDiv = true;
    }


    //save case change owner
    saveChangeOwner() {
        this.changeOwnerPopup = false;
        this.loading = true;
        saveCaseChangeOwner({ caseList: this.selectedCasesList, newOwnerId: this.selectedUserId, taskChange: true })
            .then(result => {
                let obj = result;
                let dataMap = [];
                let i = 0
                for (let key in obj) {
                    dataMap.push({ Id: i, CaseNumber: key, message: obj[key] });
                    i++;
                }
                this.resultData = dataMap;
                this.showlistView = false;
                this.showResult = true;
                this.loading = false;
            })
            .catch(error => {
                console.error(error);
            });
    }

    appointmentDateTimeHandler() {
        if (this.showlistView === false || this.showResult === true) {
            const event = new ShowToastEvent({
                "title": "Error!",
                "message": "Search and Select records for changing owner",
                "variant": "error"
            });
            this.dispatchEvent(event);
        } else {
            let el = this.template.querySelector('lightning-datatable');
            let selected = el.getSelectedRows();
            this.recordsLength = selected.length;
            if (this.recordsLength < 1) {
                const event = new ShowToastEvent({
                    "title": "Error!",
                    "message": "Select atleast one record!",
                    "variant": "error"
                });
                this.dispatchEvent(event);

            } else {
                this.selectedCasesList = selected;
                this.appointmentDatePopup = true;

            }
        }

    }

    cancelUpdateAppointment() {
        this.appointmentDatePopup = false;

    }

    saveUpdateAppointment() {
        if (this.disableButton == true) {
            this.showErrorMessage('Start Dates cannot be greater than End Dates');
        } else {
            this.showlistView = false;
            this.showResult = false;
            this.loading = true;
            this.data = [];
            updateAppointmentDates({ casesList: this.selectedCasesList, updatedateTime: this.updateDate })
                .then(result => {
                    let obj = result;
                    let dataMap = [];
                    let i = 0
                    for (let key in obj) {
                        dataMap.push({ Id: i, CaseNumber: key, message: obj[key] });
                        i++;
                    }
                    this.resultData = dataMap;
                    this.showlistView = false;
                    this.appointmentDatePopup = false;
                    this.showResult = true;

                })
                .catch(error => {
                    console.error(error);
                });
            setTimeout(function () { this.loading = false }.bind(this), 4000);
        }
    }

    get today() {

        return new Date();
    }

    updateAppontmentHandler(event) {

        let selectedDate = event.target.value;
        let selected = selectedDate.split('T');


        if (new Date(selected[0]) > this.today) {
            this.disableButton = false;
            this.updateDate = selectedDate;
        }

        if (new Date(selectedDate).getDate() == this.today.getDate()) {
            if (new Date(selectedDate).getHours() > this.today.getHours()) {
                this.disableButton = false;
                this.updateDate = selectedDate;

            } else {
                this.disableButton = true;
                this.showMessage('Error', 'Appointment Date hour cannot be lesser than current Hour', 'error');
            }

        }

        if (new Date(selectedDate) < this.today) {

            if (new Date(selectedDate).getDate() < this.today.getDate()) {
                this.disableButton = true;
                this.showMessage('Error', 'Appointment Date cannot be lesser than Today\'s Date', 'error');
            }


        }
    }


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
}