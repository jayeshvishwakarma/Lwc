/* eslint-disable no-console */
import {
    LightningElement,
    track,
    api,
    wire
} from "lwc";
//Server methods
import fetchCityandAssestInfo from "@salesforce/apex/ServiceCalculator.fetchCityandAssestInfo";
import fetchMCPcostCalculations from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    NavigationMixin
} from "lightning/navigation";
import {
    RecordFieldDataType
} from 'lightning/uiRecordApi';
import formFactorPropertyName from '@salesforce/client/formFactor';


const actions = [{
    label: 'Create Case',
    name: 'create_case_record'
}];

const columns = [{
        label: 'Package Name',
        fieldName: 'packageName'
    },
    {
        label: 'Price (Taxes not included)',
        fieldName: 'price'
    },
    {
        label: 'MCP Expiry Date',
        fieldName: 'expiryDate'
    },
    {
        type: 'button',
        initialWidth: 130,
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

export default class McpCalculator extends NavigationMixin(LightningElement) {

    @api customerRecorId;
    loading = true;
    vehicleOptions = [];
    vehicleData = '';
    mileage = '';
    loaded = false;
    data = [];
    columns = columns;
    forCodeAPIReq;
    loggedInUserDealerId;
    workshopOptions = [];
    isSmallDevice = false; //This variable is used to check if used device is small or not
    cmpVisible = true;
    mcppackageName;
    dealerId;
    regNumber;
    assetList = [];

    connectedCallback() {
        if (formFactorPropertyName === 'Small') {
            this.isSmallDevice = true;
        }
        fetchCityandAssestInfo({
            recordId: this.customerRecorId
        }).then(result => {
            if (result && result.registrationNumberList && result.registrationNumberList.length > 0 &&
                result.workShopList && result.workShopList.length > 0) {
                // To hide the Spinner
                this.vehicleOptions = [];
                this.assetList = result.registrationNumberList;
                for (let i = 0; i < result.registrationNumberList.length; i++) {
                    if (result.registrationNumberList[i].VIN__c) {
                        this.vehicleOptions.push({
                            label: result.registrationNumberList[i].Name,
                            value: result.registrationNumberList[i].VIN__c
                        });
                    } else {
                        this.showErrorMessage('VIN is missing');
                    }
                }

                this.workshopOptions = [];
                for (let i = 0; i < result.workShopList.length; i++) {
                    this.workshopOptions.push({
                        label: result.workShopList[i].Name,
                        value: result.workShopList[i].Id + '-' + result.workShopList[i].For_Code__r.For_Code__c
                    });
                }


                this.loading = false;
            } else {
                this.showErrorMessage('Asset details are missing');
                this.closeScreen();
            }
        }).catch(error => {
            this.showErrorMessage(Server_Error);
        })
    }

    handleRowAction(event) {
        const row = event.detail.row;
        const action = event.detail.action;
        let data = row;
        if (action.name === 'createCase') {
            this.mcppackageName = data.packageName;
            this.cmpVisible = false;
        }
    }

    // This method is used to close the LWC and navigate to record page
    closeScreen() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.customerRecorId,
                objectApiName: "Account", // objectApiName is optional
                actionName: "view"
            }
        });
        this.loading = false;
    }

    // To Handle the data validation
    validationCheckMethod() {
        const allValid1 = [
            ...this.template.querySelectorAll(".reqData")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid1;
    }

    handlechange(event) {
        if (event.target.name === "Vehicle") {
            this.vehicleData = event.detail.value;
            this.regNumber = (this.assetList.find(item => item.VIN__c === this.vehicleData).Name);
        } else if (event.target.name === "WorkShopName") {
            var forCodeVal = event.detail.value;
            var codeRec = forCodeVal.split('-');
            this.dealerId = codeRec[0];
            this.forCodeAPIReq = codeRec[1];
        } else {
            this.mileage = event.detail.value;
        }
    }

    // This method is created to restrict Copy and Paste
    handlePaste(event) {
        event.preventDefault();
    }

    fetchMCPdata(event) {
        this.loading = true;
        this.loaded = false;
        if (this.validationCheckMethod()) {
            let params = {
                jitName: "MCP_Calculator",
                jsonBody: " ",
                urlParam: JSON.stringify({
                    vin: this.vehicleData,
                    currentMileage: this.mileage,
                    forCD: this.forCodeAPIReq
                })
            };
            fetchMCPcostCalculations(params)
                .then(result => {
                    if (result && result.code === 200) {
                        let objData = JSON.parse(result.data);
                        if (objData.serviceMcpCostList && (objData.serviceMcpCostList).length > 0) {
                            this.data = objData.serviceMcpCostList;
                            this.loading = false;
                            this.loaded = true;
                            this.successMessage('Data has been retrieved successfully!');
                        } else {
                            this.successMessage('Data not available for the selected VIN & Mileage');
                        }
                    } else {
                        this.loading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error",
                                message: result.message,
                                variant: "Warning"
                            })
                        );
                    }
                }).catch(error => {
                    this.error = error;
                    this.showErrorMessage(Server_Error);
                })

        } else {
            // To popup error message when required fields are missing message.
            this.showErrorMessage('Required fields are missing / Data entered is not correct');
        }
    }

    successMessage(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: message,
                variant: "success"
            })
        );
        this.loading = false;
    }

    showErrorMessage(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: message,
                variant: "error"
            })
        );
        this.loading = false;
    }

}