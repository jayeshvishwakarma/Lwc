import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';

//Server Method
import fetchCustomerId from "@salesforce/apex/InteractionHistory.fetchCustomerId";
import fetchDealerAccounts from "@salesforce/apex/InteractionHistory.fetchDealerAccounts";
import fetchPickValues from "@salesforce/apex/InteractionHistory.fetchPickValues";
import currentUserId from "@salesforce/user/Id";
import UI_Error_Message from "@salesforce/label/c.UI_Error_Message";
import no_Records_Found from "@salesforce/label/c.Interaction_History_No_Records";
import dataLimit from "@salesforce/label/c.Interaction_History_data_limit";
import {
    NavigationMixin
} from "lightning/navigation";
import fetchData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    getRecord
} from "lightning/uiRecordApi";


const columns = [{
        label: 'LOB',
        fieldName: 'LOB',
        wrapText: true
    },
    {
        label: 'Call Purpose',
        fieldName: 'callPurpose',
        wrapText: true
    },
    {
        label: 'Related To',
        fieldName: 'serviceRelatedTo',
        wrapText: true
    },
    {
        label: 'Contact Method',
        fieldName: 'contactMethod',
        wrapText: true
    },
    {
        label: 'Contacted On',
        fieldName: 'contactedOn',
        //wrapText: true
    },
    {
        label: 'Contacted by',
        fieldName: 'contactedBy',
        wrapText: true
    },
    {
        label: 'Dealership Name',
        fieldName: 'dealershipNm',
        wrapText: true
    },
    {
        label: 'Interaction Date',
        fieldName: 'interactionDt',
        wrapText: true
    },
    {
        label: 'Disposition / Output',
        fieldName: 'callDisposition',
        wrapText: true
    },
    {
        label: 'Remarks',
        fieldName: 'remarks'//,
        //wrapText: true
    },
    {
        label: 'Communication Details',
        fieldName: 'communicationDtls'//,
        //wrapText: true
    },
    {
        label: 'Campaign Type',
        fieldName: 'campaignType',
        wrapText: true
    },
    {
        label: 'Call Type',
        fieldName: 'callType',
        wrapText: true
    },
    {
        label: 'Mood',
        fieldName: 'customerMood',
        wrapText: true
    },
];




export default class InteractionHistory extends NavigationMixin(LightningElement) {

    @api recordId;
    @track value = '';
    @track loading = false;
    @track selectedRecord;
    @track records;
    @track apiResponseData = [];
    @track columns = columns;
    @track dataArray = [];
    displayTable = false;
    dealerGroupName = '';
    loadingTable = false;
    errorMessage;
    parentGroup;
    userType = true;
    typeOptions;
    dispositionOptions;
    serviceInsuranceValues;
    apiRequestData=[];

    inputData = {
        customerSFID: "",
        dealerShipParentGrpNm: "",
        LOB: "",
        contactMethod: "",
        campaignType: "",
        callDisposition: "",
        limit:dataLimit
    };
	objName = '';

    /*get loaded() {
        return !this.errorMessage && !this.loading;
    }*/

    get loaded() {
        return !this.loading;
    }

    connectedCallback() {
        this.loading = true;
		this.objName = this.recordId.substring(0, 3) === '500' ? 'Case' : 'Account';
        if(this.objName === 'Case'){
            fetchCustomerId({recid : this.recordId}).then(result => {
                //console.log('res '+result);
                this.inputData.customerSFID = result;
            });
        }else{
            this.inputData.customerSFID = this.recordId;
        }
        //this.inputData.customerSFID = this.recordId;
        fetchPickValues()
            .then(result => {
                if (result && result.taskType && result.taskDisposition && result.serviceInsuranceValues) {

                    if (result.dealerGroupName) {
                        this.dealerGroupName = result.dealerGroupName;
                    }

                    this.typeOptions = [{value: "",label:"All"}];
                    this.dispositionOptions = [{value: "",label:"All"}];
                    this.serviceInsuranceValues = [{value: "",label:"All"}];
                    var contsTask = result.taskType;
                    var contsDispotion = result.taskDisposition;
                    var contsCampaignVal = result.serviceInsuranceValues;

                    for (var key in contsTask) {
                        this.typeOptions.push({
                            value: contsTask[key],
                            label: key
                        }); //Here we are creating the array to show on UI.
                    }
                    for (var key in contsDispotion) {
                        this.dispositionOptions.push({
                            value: contsDispotion[key],
                            label: key
                        }); //Here we are creating the array to show on UI.
                    }
                    for (var key in contsCampaignVal) {
                        this.serviceInsuranceValues.push({
                            value: contsCampaignVal[key],
                            label: key
                        }); //Here we are creating the array to show on UI.
                    }
                    if(!this.userType){
                        this.handleSearch(); // To trigger the API when a Component is loaded
                    }
                    

                    this.loading = false;
                }
            })
            .catch(error => {
                
                this.loading = false;
                this.errorMessage = 'Please try again after sometime';
                this.showErrorMessage(this.errorMessage);
            });
    }

    handleValueChange(event) {
        this.errorMessage='';
        this.inputData[event.target.name] = event.target.value;
    }


    @wire(getRecord, {
        recordId: currentUserId,
        fields: ["User.UserType"]
    })
    currentUser({
        error,
        data
    }) {
        if (data && data.fields.UserType.value === 'PowerPartner') {
            this.userType = false;
        } else {
            
        }
    }

    get loboptions() {
        return [{
            label: 'All',
            value: ''
            },
            {
                label: 'Sales',
                value: 'Sales'
            },
            {
                label: 'Service',
                value: 'Service'
            },
            {
                label: 'Insurance',
                value: 'Insurance'
            },
        ];
    }

    handleOnchange(event) {
        this.errorMessage='';
        const searchKey = event.detail.value;

        if (searchKey && searchKey.length >= 2)

            fetchDealerAccounts({
                dealerGroupName: searchKey
            })
            .then(result => {
                 this.records = result;
            })
            .catch(error => this.showErrorMessage(error))

    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        this.selectedRecord = this.records.find(record => record.Parent_Group__c === selectedRecordId);
    }

    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.inputData.dealerShipParentGrpNm="";
        this.records = undefined;
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

    handleSearch() {
        this.loadingTable = true;
        this.displayTable = false;
        this.errorMessage='';
        
        if (this.dealerGroupName) { //When External User is using Interaction History
            this.inputData.dealerShipParentGrpNm = this.dealerGroupName;
        } else if (this.selectedRecord && this.selectedRecord.Parent_Group__c) {//When Internal User is using Interaction History
            this.inputData.dealerShipParentGrpNm = this.selectedRecord.Parent_Group__c;
        }
        
        let params = {
            jitName: "Interaction_History",
            jsonBody: " ",
            urlParam: JSON.stringify(this.inputData)
        };

        fetchData(params)
            .then(response => this.handleUpdateResponse(response))
            .catch(error => this.handleError(error))
            .finally(() => (this.loadingTable = false));
    }



    handleUpdateResponse(response) {
        var dataAPI = response.data && JSON.parse(response.data).custInteractionHist ? JSON.parse(response.data).custInteractionHist : '';
        console.log('JSON.parse(response.data).custInteractionHist---->',dataAPI);
        if (response.status === "Success" && dataAPI.length>0) {
            this.displayTable = true;
            this.loadingTable = false;
            this.showSuccessMessage('Interactions with the Customer has been retrieved');
            this.dataArray=dataAPI;
        }else if(response.status === "Success" && dataAPI.length===0){
            this.errorMessage=no_Records_Found;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Interaction Information",
                    message: no_Records_Found,
                    variant: "info"
                })
            );
            this.loading = false;
        }
        else if (response.status === "Error") {
            if(response.message==='No Records Found'){
               this.errorMessage=no_Records_Found;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Interaction Information",
                    message: response.message,
                    variant: "info"
                })
            );
            this.loading = false;
        } else {
            this.handleError(response);
        }
    }

    handleError(error) {
        //this.errorMessage = error.message;
        this.errorMessage = UI_Error_Message;
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: UI_Error_Message,
                variant: "error"
            })
        );
        this.loading = false;
        
    }

    closeModal() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Account", // objectApiName is optional
                actionName: "view"
            }
        });
        this.loading = false;
    }
}