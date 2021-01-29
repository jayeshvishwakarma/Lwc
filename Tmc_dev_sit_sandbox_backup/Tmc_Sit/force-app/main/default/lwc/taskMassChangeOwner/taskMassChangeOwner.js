/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable eqeqeq */
/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import {
    LightningElement,
    track
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getTeamUsers from '@salesforce/apex/listViewFilterApex.getCurrentTeamUsers';
import {
    NavigationMixin
} from "lightning/navigation";
import UserId from '@salesforce/user/Id';
import saveTaskChangeOwners from '@salesforce/apex/listViewFilterApex.saveTaskChangeOwners';
import fetchWorkShopList from "@salesforce/apex/CreateAppointment.fetchWorkShopList";
import getpicklistValues from '@salesforce/apex/listViewFilterApex.getpicklistValues';
import getTasks from '@salesforce/apex/listViewFilterApex.getTasks';
import getUserProfileName from '@salesforce/apex/listViewFilterApex.getUserProfileName';
import taskPrioritypicklistValues from '@salesforce/label/c.CCM_Service_Task_Priority_Values';
import search from '@salesforce/apex/SampleLookupController.search';



const columns = [{
    label: "Subject",
    fieldName: "nameUrl",
    type: "url",
    typeAttributes: {
        label: {
            fieldName: "Subject"
        },
        target: "_self"
    },
    sortable: true
},
{
    label: 'Customer',
    fieldName: 'customerName',
    sortable: true
},
{
    label: 'Due Date',
    fieldName: 'ActivityDate',
    sortable: true
},
{
    label: 'Campaign Name',
    fieldName: 'campaignName',
    sortable: true
},
{
    label: 'Campaign Type',
    fieldName: 'Service_Type__c',
    sortable: true
},
{
    label: 'Follow up Date',
    fieldName: 'Call_back_Date_Time__c',
    sortable: true
},
{
    label: 'Vehicle Model',
    fieldName: 'Vehicle_Model__c',
    sortable: true
},
{
    label: 'Status',
    fieldName: 'Status',
    sortable: true
},
{
    label: 'Priority',
    fieldName: 'Priority',
    sortable: true
},
{
    label: 'Vehicle Sale Date',
    fieldName: 'saleDate',
    sortable: true
},
{
    label: 'Owner Name',
    fieldName: 'OwnerName',
    sortable: true
},
];

const resultDataColumns = [{
    label: 'Record',
    fieldName: 'recordName'
},
{
    label: 'Message',
    fieldName: 'message'
}
]


export default class TaskMassChangeOwner extends NavigationMixin(LightningElement) {
    ownerNames = []; // To show the dropdown with all users belonging to the current Team of current user
    campaingType = [];
    caseRecordTypes = [];
    taskPriority = [];
    workshopOptions = [];
    campaignOptions = [];
    modelOptions = [];
    ownerNameValue = UserId;
    campaingTypeValue;
    taskPriorityValue;
    workshopValue;
    startSaleDateValue;
    endSaleDateValue;
    modelValue;
    cmpSubTypeValue;
    columns = columns;
    @track data = [];
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
    endDate = '';

    campaignPillSelected = [];//For storing values selected Camapign Type
    OwnersPillSelected = [];//For storing values selected Owner Names
    ModelPillSelected = [];//For storing values selected Vehicle Model
    activeSections = ['A'];
    @track sortBy;
    @track sortDirection;




    connectedCallback() {
        getTeamUsers({
            searchTerm: ''
        })
            .then(result => {
                let data = result;

                let userMap = [];
                for (let i = 0; i < data.length; i++) {
                    userMap.push({
                        label: data[i].Name,
                        value: data[i].Id
                    });
                }
                this.ownerNames = userMap;

            })
            .catch(error => {
                console.error(error);
            });

        getpicklistValues({ sobjectApiName: 'Case', picklistfiledName: 'Type' })
            .then(result => {
                let data = result;

                let dataMap = [];
                for (let k in data) {

                    dataMap.push({
                        label: k,
                        value: data[k]
                    });
                }
                this.campaingType = dataMap;
                console.log(this.campaingType);

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

        let priorityValuesMap = [];
        let priorityArray = taskPrioritypicklistValues.split(',');
        for (let i = 0; i < priorityArray.length; i++) {
            priorityValuesMap.push({ label: priorityArray[i], value: priorityArray[i] })
        }
        this.taskPriority = priorityValuesMap;

        fetchWorkShopList()
            .then(result => {
                let data = result;
                let workshopMap = [];
                workshopMap.push({
                    label: 'All',
                    value: ''
                })
                for (let i = 0; i < data.length; i++) {
                    workshopMap.push({
                        label: data[i].Name,
                        value: data[i].Id
                    });
                }
                this.workshopOptions = workshopMap;

            })
            .catch(error => {
                console.error(error);
            });


        getpicklistValues({ sobjectApiName: 'Case', picklistfiledName: 'VehicleModel__c' })
            .then(result => {
                let data = result;
                let dataMap = [];
                dataMap.push({
                    label: 'All',
                    value: ''
                })
                for (let k in data) {
                    dataMap.push({
                        label: k,
                        value: k
                    });
                }
                this.modelOptions = dataMap;
            })
            .catch(error => {
                console.error(error);
            });
    }


    campaignNameChangeHandler(event) {
        this.campaingName = event.target.value;
    }


    campaignTypeChangeHandler(event) {
        // this.campaingTypeValue = event.detail.value
        let value = event.detail.value;
        let label = event.target.options.find(opt => opt.value === event.detail.value).label;
        let someMap = [];
        someMap = this.campaignPillSelected;
        this.campaignPillSelected = [];
        if (!someMap.includes(label)) {
            someMap.push(label);

        }
        this.campaignPillSelected = someMap;
    }

    handleRemoveCampaignType(event) {
        let currentPill = event.currentTarget.dataset.id;
        let someMap = [];
        someMap = this.campaignPillSelected;
        this.campaignPillSelected = [];
        someMap.splice(someMap.indexOf(currentPill), 1)
        this.campaignPillSelected = someMap;
    }

    arrayFromMap(valueArray, mapToBeCompared) {
        let array = [];
        for (let k = 0; k < mapToBeCompared.length; k++) {
            for (let i = 0; i < valueArray.length; i++) {
                if (valueArray[i] == mapToBeCompared[k].label) {
                    array.push(mapToBeCompared[k].value);
                }
            }
        }
        return array;
    }

    cmpSubTypeChangeHandler(event) {
        this.cmpSubTypeValue = event.target.value;
    }


    startDateEndDateCheck() {
        if (this.startDate && this.endDate && this.startDate > this.endDate) {
            this.showErrorMessage('Start Due Date cannot be greater than End Due Date');
        }

        if (this.startSaleDateValue && this.endSaleDateValue && this.startSaleDateValue > this.endSaleDateValue) {
            this.showErrorMessage('Start Sale Date cannot be greater than End Sale Date');
        }
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

    startDateDateChangeHandler(event) {
        this.startDate = event.target.value;
        this.startDateEndDateCheck();
    }

    endDateDateChangeHandler(event) {
        this.endDate = event.target.value;
        this.startDateEndDateCheck();
    }

    ownerNameChangeHandler(event) {
        // this.ownerId = event.detail.value;
        // let value = event.detail.value;
        let label = event.target.options.find(opt => opt.value === event.detail.value).label;
        let someMap = [];
        someMap = this.OwnersPillSelected;
        this.OwnersPillSelected = [];
        if (!someMap.includes(label)) {
            someMap.push(label);

        }
        this.OwnersPillSelected = someMap;
    }

    handleRemoveOwnerName(event) {
        let currentPill = event.currentTarget.dataset.id;
        let someMap = [];
        someMap = this.OwnersPillSelected;
        this.OwnersPillSelected = [];
        someMap.splice(someMap.indexOf(currentPill), 1)
        this.OwnersPillSelected = someMap;

    }



    taskPriorityChangeHandler(event) {
        this.taskPriorityValue = event.detail.value;
    }

    workshopChangeHandler(event) {
        this.workshopValue = event.detail.value;
    }

    modelChangeHandler(event) {
        let label = event.target.options.find(opt => opt.value === event.detail.value).label;
        let someMap = [];
        someMap = this.ModelPillSelected;
        this.ModelPillSelected = [];
        if (!someMap.includes(label)) {
            someMap.push(label);

        }
        this.ModelPillSelected = someMap;
    }

    handleRemoveModel(event) {
        let currentPill = event.currentTarget.dataset.id;
        let someMap = [];
        someMap = this.ModelPillSelected;
        this.ModelPillSelected = [];
        someMap.splice(someMap.indexOf(currentPill), 1)
        this.ModelPillSelected = someMap;
    }

    searchClickHandler() {
        if ((this.startDate && this.endDate && this.startDate > this.endDate) || (this.startSaleDateValue && this.endSaleDateValue && this.startSaleDateValue > this.endSaleDateValue)) {
            this.showErrorMessage('Start Dates cannot be greater than End Dates');
        } else {
            this.showlistView = false;
            this.showResult = false;
            this.loading = true;
            getTasks({
                campaignName: this.campaingName,
                campaignType: this.arrayFromMap(this.campaignPillSelected, this.campaingType),
                startDate: this.startDate,
                endDate: this.endDate,
                OwnerId: this.arrayFromMap(this.OwnersPillSelected, this.ownerNames),
                taskPriority: this.taskPriorityValue,
                dealerName: this.workshopValue,
                startSaleDate: this.startSaleDateValue,
                endSaleDate: this.endSaleDateValue,
                model: this.arrayFromMap(this.ModelPillSelected, this.modelOptions),
                campSubType: this.cmpSubTypeValue
            })
                .then(result => {

                    let tempData = JSON.parse(JSON.stringify(result));
                    tempData.forEach((row) => {
                        if (row.Owner) {
                            row.OwnerName = row.Owner.Name;
                        }
                        if (row.Contact_ID__r) {
                            row.customerName = row.Contact_ID__r.Name;
                        }
                        if (row.CampaignId__r) {
                            row.campaignName = row.CampaignId__r.Name;
                        }
                        if (row.Case__r) {
                            row.saleDate = row.Case__r.Vehicle_Sale_Date__c;
                        }
                    });

                    let defers = tempData.map(row => this.generateUrl(row.Id));
                    Promise.all(defers).then(urls => {
                        this.data = tempData.map((row, ind) => ({
                            ...row,
                            nameUrl: urls[ind]
                        }));
                    });
                    this.showlistView = true;
                    let recCount = tempData.length;
                    if (recCount === 100) {
                        this.recordCount = '100+';
                    } else {
                        this.recordCount = recCount;
                    }


                })
                .catch(error => {
                    console.error(error);
                });

            setTimeout(function () {
                this.loading = false
            }.bind(this), 5000);
            this.activeSections = [];


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


    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1 : -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.data = parseData;
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
            this.selectedTasksList = selected;
            this.recordsLength = selected.length;
            if (this.recordsLength < 1) {
                const event = new ShowToastEvent({
                    "title": "Error!",
                    "message": "Select atleast one record!",
                    "variant": "error"
                });
                this.dispatchEvent(event);

            } else {
                this.selectedTasksList = selected;
                this.changeOwnerPopup = true;
                this.inputDiv = true;
            }
        }



    }




    saveChangeOwner() {
        this.changeOwnerPopup = false;
        this.loading = true;
        saveTaskChangeOwners({
            tasksList: this.selectedTasksList,
            newOwnerId: this.selectedUserId,
            saveCaseChange: true
        })
            .then(result => {
                let obj = result;
                let dataMap = [];
                let i = 0
                for (let key in obj) {
                    dataMap.push({
                        Id: i,
                        recordName: key,
                        message: obj[key]
                    });
                    i++;
                }
                this.resultData = dataMap;
                this.showlistView = false;
                this.showResult = true;
            })
            .catch(error => {
                console.error(error);
            });
        this.loading = false;
    }

    getUsersHandler(event) {
        this.resultDropDown = false;
        // let searchKey = event.target.value;
        let searchKey = event.target.value;
        if (search.length > 0) {
            getTeamUsers({
                searchTerm: searchKey
            })
                .then(result => {
                    this.userList = result;
                    this.resultDropDown = true;
                })
                .catch(error => {
                    console.error(error);
                });
        }


    }
    cancelChangeOwner() {
        this.changeOwnerPopup = false;
        this.resultDropDown = false;
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

    startSaleDateChangeHandler(event) {
        this.startSaleDateValue = event.target.value;
        this.startDateEndDateCheck();
    }

    saleEndDateDateChangeHandler(event) {
        this.endSaleDateValue = event.target.value;
        this.startDateEndDateCheck();
    }

}