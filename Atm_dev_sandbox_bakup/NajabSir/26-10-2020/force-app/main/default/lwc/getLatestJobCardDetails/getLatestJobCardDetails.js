/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import {
    LightningElement,
    track,
    api
} from "lwc";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    NavigationMixin
} from "lightning/navigation";

import fetchData from "@salesforce/apex/GetLatestJobCardDetails.fetchData";
import getAssetName from "@salesforce/apex/GetLatestJobCardDetails.getAssetName";
import fetchAssetApiResponse from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import getAssets from "@salesforce/apex/CreateAppointment.getCustomerAssets";
import historyLimit from '@salesforce/label/c.JobCard_history_limit';
import caseCreationError from '@salesforce/label/c.Service_History_Case_Creation';

const actions = [{
    label: 'Show details',
    name: 'show_details'
},
{
    label: 'Case CaseCaseCase',
    name: 'Case_Case'
}

];



const lastVisitDeatilscolumns = [{
    label: 'Service Date',
    fieldName: 'serviceDate',
    type: "date",
    typeAttributes: {
        year: "numeric",
        month: "long",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
    }
},
{
    label: 'Service Type',
    fieldName: 'serviceType'
},
{
    label: 'Mileage',
    fieldName: 'mileage',
    type: 'number',
    cellAttributes: {
        alignment: 'left'
    }
},
{
    label: 'Dealer Description',
    fieldName: 'dealerName'
},
{
    type: 'button',
    initialWidth: 150,
    typeAttributes: {
        rowActions: actions,
        menuAlignment: 'left',
        label: 'View Details',
        title: 'View Details',
        name: 'viewDetails',
        value: 'viewDetails',
        variant: 'brand'

    }
},
{
    type: 'button',           // Added under Inbound Calling change
    initialWidth: 150,
    typeAttributes: {
        rowActions: actions,
        menuAlignment: 'left',
        label: 'Create Case',
        title: 'Create Case',
        name: 'createCase',
        value: 'createCase',
        variant: 'brand'

    }
}
];

const repairsDemandedColumns = [{
    label: "Repairs Demanded",
    fieldName: "description"
},
{
    label: "Repairs Demanded",
    fieldName: "code"
}
];

const labourDetailsColumns = [{
    label: "Description",
    fieldName: "description"
},
{
    label: "Code",
    fieldName: "code"
},
{
    label: "Amount",
    fieldName: "amount"
},
{
    label: "Billable Type",
    fieldName: "billableType"
}
];

const partDetailsColumns = [{
    label: "Code",
    fieldName: "code"
},
{
    label: "Description",
    fieldName: "description"
},
{
    label: "Quantity",
    fieldName: "qty"
},
{
    label: "Amount",
    fieldName: "amount"
},
{
    label: "Billable Type",
    fieldName: "billableType"
},

];


export default class getLatestJobCardDetails extends NavigationMixin(
    LightningElement
) {
    @api recordId;
    lastVisitDeatilscolumns = lastVisitDeatilscolumns;

    repairsDemandedColumns = repairsDemandedColumns;
    partDetailsColumns = partDetailsColumns;
    labourDetailsColumns = labourDetailsColumns;

    dealerData = {};
    @track jobCardNumberForCaseCreation;
    serviceAdvisorName; //New Added for Create Case Inound
    dealerCodeRec; //New Added for Create Case Inound
    @track responseData = [];
    repairsDemandedData = [];
    labourDetailsData = [];
    partDetailsData = [];
    pricingData = [];
    assetNameParam;
    cmpVisible = true;  // Added under Inbound Calling change
    assetList = [];
    lookupEnable = false;
    searchButton = true;
    cancelButton = true;
    assetSelected = false; // Div to show the asset service history table for last 5 entries
    loading = false;
    @track errorMessage;
    @track assetSearchResultList = []; //This field is used to store asset search result
    @track asset;
    @track loaded = false; // Changes
    allDealerShipOutlets;
    serviceHistory = {
        "serviceAdvisor": "",
        "jobCardNumber": "",
        "registrationNumber": "",
        "dealerSfId": ""
    }   // This variable is created for Inbound calling these values will be passed as param for Case Creation
    tempKey;

    apiData = {
        regNumber: '',
        limit: historyLimit
    }

    connectedCallback() {
        this.loading = true;
        fetchData({
            recordId: this.recordId

        })
            .then(response => this.handleResponse(response))
            .catch(error => this.handleError(error));



        let cacheObject = JSON.parse(localStorage.getItem('DailingListCacheKey'));

        if (cacheObject != null) {
            if (cacheObject.Asset__c != null || cacheObject.Asset__c !== undefined) {
                //If the current cache data is related to current customer only then pre-populate
                if (cacheObject.Contact_ID__c === this.recordId) {
                    this.tempKey = cacheObject.Asset__c;
                    getAssetName({
                        assetCacheId: this.tempKey
                    })
                        .then(result => {
                            this.asset = result;
                            this.assetNameParam = this.asset.Registration_Number__c;
                        })
                }
            }
        }
    }


    /*****  This method is used for asset search *****/
    handleAssetSearch(event) {
        this.assetSearchResultList = [];
        getAssets({
            customerId: this.recordId,
            searchKey: event.detail.value
        })
            .then(result => {
                this.assetSearchResultList = result;
            })
            .catch(error => this.handleError(error));
    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        this.asset = this.assetList.find(item => item.Id === selectedRecordId);
        this.assetNameParam = this.assetList.find(item => item.Id === selectedRecordId).Registration_Number__c;
    }

    // This method is used for removal of selected Asset
    handleRemove(event) {
        event.preventDefault();
        this.asset = undefined;
        this.assetNameParam = undefined;
        this.assetSearchResultList = undefined;
    }


    handleResponse(response) {
        this.loading = false;
        this.lookupEnable = true;
        if (response && response.length !== 0) {
            this.assetList = response.assetRec;
            this.allDealerShipOutlets = [];
            this.allDealerShipOutlets = response.dealerRec;
        } else if (response) {
            this.loading = false;
            this.lookupEnable = false;
            this.searchButton = false; // To hide search Button
            //Change added if Call Start is done and if Customer has no related Asset
            let cacheObject = JSON.parse(localStorage.getItem('DailingListCacheKey'));
            if (cacheObject && cacheObject.Vehicle_Registration_Number__c) {
                this.assetNameParam = cacheObject.Vehicle_Registration_Number__c;
                this.handleSearch();
            } //Change added if Call Start is done and if Customer has no related Asset
            else {
                this.errorMessage = 'Asset details are missing';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Something is wrong",
                        message: this.errorMessage,
                        variant: "error"
                    })
                );
                this.closeModal();
            }

        }
    }

    handleSearch() {
        if (this.assetNameParam) {
            this.loading = true;
            this.searchButton = false; // To hide search Button
            this.lookupEnable = false; // To hide Custom lookup and Search,Cancel buttons
            this.cancelButton = false; // To hide Cancel Button
            this.apiData.regNumber = this.assetNameParam;
            fetchAssetApiResponse({
                jitName: 'Job_Card',
                jsonBody: '',
                urlParam: JSON.stringify(this.apiData)
            })
                .then(response => this.apiHistoryDetails(response))
                .catch(error => this.handleError(error))
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Something is wrong",
                    message: "Required field is missing",
                    variant: "error"
                })
            );
        }
    }

    apiHistoryDetails(response) {
        if (!response.data) {
            throw response;
        } else {
            this.responseData = JSON.parse(response.data).serviceHistory;
            this.assetSelected = true;
            this.loading = false;
            this.cancelButton = true;
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        const action = event.detail.action; // Added under Inbound Calling change
        if (action.name === 'viewDetails') {
            let data = row;
            this.apiResponseCapture(row);
            this.assetSelected = false;
            this.jobCardNumberForCaseCreation = data.jobCardNo;
            this.dealerCodeRec = data.dealerCode ? data.dealerCode : '';
            this.serviceAdvisorName = data.serviceAdvisorName ? data.serviceAdvisorName : '';
            this.dealerCodeRec = data.dealerCode ? data.dealerCode : '';
        } else {
            let data = row;
            this.serviceHistory.jobCardNumber = data.jobCardNo ? data.jobCardNo : '';
            this.serviceHistory.registrationNumber = this.assetNameParam ? this.assetNameParam : '';
            this.serviceHistory.serviceAdvisor = data.serviceAdvisorName ? data.serviceAdvisorName : '';
            this.dealerCodeRec = data.dealerCode ? data.dealerCode : '';
            if (this.dealerCodeRec) {
                this.ValidateDealerAccount(this.dealerCodeRec);
            }

        }
    }

    ValidateDealerAccount(dealerCodeData) {
        if (dealerCodeData && this.allDealerShipOutlets.length > 0) {
            for (let i = 0; i < this.allDealerShipOutlets.length; i++) {
                if (this.allDealerShipOutlets[i].Dealer_Code__c + '-' + this.allDealerShipOutlets[i].For_Code__r.For_Code__c + '-' + this.allDealerShipOutlets[i].Outlet_Code__c === dealerCodeData) {
                    this.serviceHistory.dealerSfId = this.allDealerShipOutlets[i].Id;
                }
            }
        }
        if (!this.serviceHistory.dealerSfId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Something is wrong",
                    message: caseCreationError,
                    variant: "error"
                })
            );
        } else {
            this.cmpVisible = false;
        }
    }


    handleOpenCreateCase(event) {
        //this.cmpVisible = false;
        this.serviceHistory.jobCardNumber = this.jobCardNumberForCaseCreation;
        this.serviceHistory.registrationNumber = this.assetNameParam ? this.assetNameParam : '';
        this.serviceHistory.serviceAdvisor = this.serviceAdvisorName;
        this.ValidateDealerAccount(this.dealerCodeRec);
    }

    apiResponseCapture(response) {
        this.cancelButton = true;
        if (!response) {
            throw response;
        } else {
            let data = response;
            this.repairsDemandedData = data.repairsDemanded;
            this.labourDetailsData = data.labourDetails;
            this.partDetailsData = data.partDetails;
            this.pricingData = data.pricing;
            this.dealerData = this.prepareDealerData(data);
        }
    }


    prepareDealerData(data) {
        this.loaded = true; // To enable Data recived from API
        this.loading = false; // To show spinner
        this.phone = data.phone; // To show the phone field
        return [{
            id: "1",
            list: [{
                label: "Dealer Code",
                value: data.dealerCode
            },
            {
                label: "Dealer Name",
                value: data.dealerName
            }
            ]
        },
        {
            id: "2",
            list: [{
                label: "Service Date",
                value: Date.parse(data.serviceDate),
                isDate: true
            },
            {
                label: "Service Type",
                value: data.serviceType
            }
            ]
        },
        {
            id: "3",
            list: [{
                label: "Model",
                value: data.model
            },
            {
                label: "Mileage (in Kms)",
                value: data.mileage
            }
            ]
        },
        {
            id: "4",
            list: [{
                label: "Job Card Number",
                value: data.jobCardNo
            },
            {
                label: "CloseAt",
                value: data.closeAt
            }
            ]
        },
        {
            id: "5",
            list: [{
                label: "Bill Date",
                value: Date.parse(data.billDate),
                isDate: true
            },
            {
                label: "Service Advisor Name",
                value: data.serviceAdvisorName
            }
            ]
        },
        {
            id: "6",
            list: [{
                label: "Technician Name",
                value: data.technicianName
            },
            {
                label: "PSF Status",
                value: data.psfStatus
            }
            ]
        },
        {
            id: "7",
            list: [{
                label: "Attendent Through",
                value: data.attendentThrough
            },
            {
                label: "Satisfied",
                value: data.satisfied
            }
            ]
        },
        // {
        //     id: "8",
        //     list: [{
        //         label: "Phone",
        //         value: data.phone
        //     }
        //         // ,
        //         // {
        //         //     label: "CSI",
        //         //     value: data.csi
        //         // }
        //     ]
        // },
        {
            id: "9",
            list: [{
                label: "Remarks",
                value: data.remarks
            },
            {
                label: "Unapproved Fitment",
                value: data.unapprovedFitness
            }
            ]
        }
        ];
    }

    showHistoryTable() {
        this.loaded = false;
        this.assetSelected = true;
    }

    handleError(error = {}) { //
        this.loading = false;
        this.cancelButton = true;
        if (error.status === "Asset_Missing_Error") {
            this.errorMessage = "Asset details are missing";
        } else {
            this.errorMessage = error.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: this.errorMessage,
                variant: "error"
            })
        );
        console.error(error);
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
}