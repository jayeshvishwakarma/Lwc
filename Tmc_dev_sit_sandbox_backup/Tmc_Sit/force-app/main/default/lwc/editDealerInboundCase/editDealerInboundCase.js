import { LightningElement, api, wire } from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';

import Server_Error from "@salesforce/label/c.UI_Error_Message";
import fetchCaseRecord from "@salesforce/apex/EditInboundCase.fetchCaseData";
import fetchCategoryData from '@salesforce/apex/CreateInboundCase.fetchCategoryData';
import fetchCaseOwnerData from '@salesforce/apex/CreateInboundCase.fetchCaseOwner';
import updateCaseRecord from "@salesforce/apex/EditInboundCase.updateCaseData";
import internalProfiles from "@salesforce/label/c.Dealer_Internal_Profiles";
import currentUserId from "@salesforce/user/Id";
import profileName from "@salesforce/schema/User.Profile.Name";
import restrcitEdit from "@salesforce/label/c.Restrcit_Edit_Case";
import restrictEditCase from "@salesforce/label/c.Restrict_Edit";
import miEmail from "@salesforce/label/c.MI_Dealer_Internal";
import workshopCode from "@salesforce/schema/User";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    getRecord
} from "lightning/uiRecordApi";

export default class EditInboundCase extends NavigationMixin(LightningElement) {

    primaryCategoryOptions = [];
    isPrimaryCategoryDisabled = false;
    secondaryCategoryOptions = [];
    isSecondaryCategoryDisabled = false;
    tertiaryCategoryOptions = [];
    dealerOutletName;
    categoryFilter;
    isTertiaryCategoryDisabled = false;
    errorMessage;
    caseOwnerSearchResult;
    ownerData = false;
    caseOwnerName;
    //caseOwnerId;
    previousOwnerId;
    sObjectName = 'Case';
    recordTypeId;
    @api recordId;
    isSpinnerShow = true;
    isFormReadyToShow = false;
    CategoryRecords = [];
    loggedinUserProfile;
    parentWorkshopCode = '';
    miCode = '';
    caseObject = {
        "Business_Area__c": "",
        "Case_Type__c": "",
        "Dealer_Name__c": "",
        "OwnerId": "",
        "Primary_Category__c": "",
        "Primary_Category_ID__c": "",
        "Secondary_Category__c": "",
        "Secondary_Category_ID__c": "",
        "Tertiary_Category__c": "",
        "Tertiary_Category_ID__c": "",
        "Id": "",
        "Primary_Dealer_QCM__c": "",
        "Insurance_Direct_Case_Closure__c": false,
        "Insurance_Direct_Case_Closure_Email__c": ""
    }

    @wire(getRecord, {
        recordId: currentUserId,
        fields: [profileName]
    })
    currentUser({
        error,
        data
    }) {
        if (data) {
            this.loggedinUserProfile = data.fields.Profile.displayValue;
        } else {
            console.log('error----->', error);
        }
    }


    connectedCallback() {
        if (this.recordId) {
            this.getCaseData();
        } else {
            this.errorMessage = Server_Error;
            this.showErrorMessage(Server_Error);
        }
    }

    cmpAccessibilityCheck(data) {
        let profileNBame = internalProfiles.split(';');
        let response = false;
        if (data && this.loggedinUserProfile) {
            if (currentUserId != data.caseData[0].OwnerId && !profileNBame.includes(this.loggedinUserProfile) && data.userRec[0].ManagerId && currentUserId != data.userRec[0].ManagerId) {
                this.showErrorMessage(restrictEditCase);
                response = false;
            } else {
                response = true;
            }
        }
        return response;
    }

    getCaseData() {
        fetchCaseRecord({
            caseId: this.recordId,
            sourceObject: "Edit Cmp",
            workshopCodeData: this.parentWorkshopCode,
            miCodeData: this.miCode
        }).then(result => {
            if (this.cmpAccessibilityCheck(result)) {
                if (result && result.caseData && result.categoryData) {
                    this.categoryFilter = result.categoryFilterData ? result.categoryFilterData : '';
                    if (result.categoryData.length > 0) {
                        if (result.caseData[0].Status !== 'Closed' && result.caseData[0].Status !== 'Transferred') {
                            this.CategoryRecords = result.categoryData;

                            //Primary Category Options
                            this.primaryCategoryOptions = [];
                            this.primaryCategoryOptions.push({
                                label: '-- None --',
                                value: ''
                            });
                            for (let i = 0; i < result.categoryData.length; i++) {
                                if (result.categoryData[i].Type__c === 'Primary') {
                                    //this.primaryCategoryRecords = result.categoryData[i];
                                    this.primaryCategoryOptions.push({
                                        label: result.categoryData[i].Name,
                                        value: result.categoryData[i].Id
                                    });
                                }
                            }

                            //Secondary Category Options
                            this.secondaryCategoryOptions = [];
                            this.secondaryCategoryOptions.push({
                                label: '-- None --',
                                value: ''
                            });
                            for (let i = 0; i < result.categoryData.length; i++) {
                                if (result.categoryData[i].Type__c === 'Secondary') {
                                    //this.secondaryCategoryRecords = result.categoryData[i];
                                    this.secondaryCategoryOptions.push({
                                        label: result.categoryData[i].Name,
                                        value: result.categoryData[i].Id
                                    });
                                }
                            }

                            //Tertiary Category Options
                            this.tertiaryCategoryOptions = [];
                            this.tertiaryCategoryOptions.push({
                                label: '-- None --',
                                value: ''
                            });
                            for (let i = 0; i < result.categoryData.length; i++) {
                                if (result.categoryData[i].Type__c === 'Tertiary') {
                                    //this.tertiaryCategoryRecords = result.categoryData[i];
                                    this.tertiaryCategoryOptions.push({
                                        label: result.categoryData[i].Name,
                                        value: result.categoryData[i].Id
                                    });
                                }
                            }

                            this.caseObject.Id = this.recordId ? this.recordId : '';
                            this.caseObject.Primary_Dealer_QCM__c = result.caseData[0].Primary_Dealer_QCM__c ? result.caseData[0].Primary_Dealer_QCM__c : '';
                            this.caseObject.Business_Area__c = result.caseData[0].Business_Area__c ? result.caseData[0].Business_Area__c : '';
                            this.caseObject.Case_Type__c = result.caseData[0].Case_Type__c ? result.caseData[0].Case_Type__c : '';
                            this.caseObject.Dealer_Name__c = result.caseData[0].Dealer_Name__c ? result.caseData[0].Dealer_Name__c : '';
                            this.caseObject.OwnerId = result.caseData[0].OwnerId ? result.caseData[0].OwnerId : '';
                            this.dealerOutletName = result.caseData[0].Dealer_Name__c ? result.caseData[0].Dealer_Name__c : '';
                            this.ownerData = true;
                            //this.caseOwnerId = result.caseData[0].OwnerId;
                            this.previousOwnerId = result.caseData[0].OwnerId ? result.caseData[0].OwnerId : '';
                            this.caseObject.OwnerId = result.caseData[0].OwnerId ? result.caseData[0].OwnerId : '';
                            this.caseOwnerName = result.caseData[0].Owner.Name ? result.caseData[0].Owner.Name : '';

                            this.caseObject.Primary_Category_ID__c = result.caseData[0].Primary_Category_ID__c ? result.caseData[0].Primary_Category_ID__c : '';
                            this.caseObject.Primary_Category__c = result.caseData[0].Primary_Category__c ? result.caseData[0].Primary_Category__c : '';

                            this.caseObject.Secondary_Category_ID__c = result.caseData[0].Secondary_Category_ID__c ? result.caseData[0].Secondary_Category_ID__c : '';
                            this.caseObject.Secondary_Category__c = result.caseData[0].Secondary_Category__c ? result.caseData[0].Secondary_Category__c : '';

                            this.caseObject.Tertiary_Category_ID__c = result.caseData[0].Tertiary_Category_ID__c ? result.caseData[0].Tertiary_Category_ID__c : '';
                            this.caseObject.Tertiary_Category__c = result.caseData[0].Tertiary_Category__c ? result.caseData[0].Tertiary_Category__c : '';

                            this.isFormReadyToShow = true;
                            this.isSpinnerShow = false;

                        } else {
                            this.isSpinnerShow = false;
                            this.errorMessage = restrcitEdit;
                            this.showErrorMessage(this.errorMessage);
                        }
                    } else {
                        this.showErrorMessage(Server_Error);
                    }

                }
            }
        }).catch(error => {
            console.log('error------>', error);
            this.showErrorMessage(Server_Error);
        })
    }



    handleOwnerSearch(event) {
        if (this.dealerOutletName) {
            this.caseOwnerSearchResult = [];
            let ownerResult;
            ownerResult = event.detail.value;
            if (ownerResult.length > 2) {
                fetchCaseOwnerData({
                    dealerId: this.dealerOutletName,
                    userName: ownerResult
                }).then(result => {
                    console.log('result----->', result);
                    this.caseOwnerSearchResult = result;
                }).catch(error => {
                    this.handleServerError(error);
                });
            }
        }
    }

    handleOwnerSelection(event) {
        const selectedRecordId = event.detail;
        this.caseOwnerName = (this.caseOwnerSearchResult.find(item => item.Id === event.detail).Name);
        this.ownerData = true;
        //this.caseOwnerId = event.detail;
        this.caseObject.OwnerId = event.detail;
    }

    handlePrimaryCategoryChange(event) {
        this.isSpinnerShow = true;
        this.emptyCategory();
        if (this.categoryFilter) {
            this.caseObject.Primary_Category_ID__c = event.detail.value;
            this.getCategoryData('Secondary');
            this.caseObject.Primary_Category__c = event.detail.value ? (this.CategoryRecords.find(item => item.Id === event.detail.value).Name) : '';
        }
    }

    handleSecondaryCategoryChange(event) {
        if (this.categoryFilter) {
            this.isSpinnerShow = true;
            this.caseObject.Secondary_Category_ID__c = event.detail.value;
            this.getCategoryData('Tertiary');
            this.caseObject.Secondary_Category__c = event.detail.value ? (this.CategoryRecords.find(item => item.Id === event.detail.value).Name) : '';
        }
    }

    handleTertiaryCategoryChange(event) {
        this.caseObject.Tertiary_Category_ID__c = event.detail.value;
        this.caseObject.Tertiary_Category__c = event.detail.value ? (this.CategoryRecords.find(item => item.Id === event.detail.value).Name) : '';
    }

    emptyCategory() {
        this.caseObject.Secondary_Category_ID__c = '';
        this.caseObject.Secondary_Category__c = '';
        this.caseObject.Tertiary_Category__c = '';
        this.caseObject.Tertiary_Category_ID__c = '';
        this.secondaryCategoryOptions = [];
        this.tertiaryCategoryOptions = [];
        this.isSecondaryCategoryDisabled = true;
        this.isTertiaryCategoryDisabled = true;
        this.isSpinnerShow = false;
    }

    getCategoryData(categoryType) {
        let clause = '';
        if (categoryType === 'Secondary') {
            clause = this.categoryFilter + '_' + 'Secondary' + '_' + this.caseObject.Primary_Category_ID__c;
        } else if (categoryType === 'Tertiary') {
            clause = this.categoryFilter + '_' + 'Tertiary' + '_' + this.caseObject.Primary_Category_ID__c + '_' + this.caseObject.Secondary_Category_ID__c;
        }

        fetchCategoryData({
            queryFilter: clause
        }).then(result => {
            // This part is covered to fetch and display the Picklist values for Service type
            if (categoryType === 'Secondary') {
                this.secondaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.secondaryCategoryOptions.push({
                        label: '-- None --',
                        value: ''
                    });
                    for (let i = 0; i < result.length; i++) {
                        this.CategoryRecords.push(result[i]);
                        if (result[i].Type__c === 'Secondary') {
                            this.isSecondaryCategoryDisabled = false;
                            this.secondaryCategoryOptions.push({
                                label: result[i].Name,
                                value: result[i].Id
                            });
                        }
                    }
                } else {
                    this.isSecondaryCategoryDisabled = true;
                    this.isTertiaryCategoryDisabled = true;
                    this.caseObject.Secondary_Category_ID__c = '';
                    this.caseObject.Secondary_Category__c = '';
                    this.caseObject.Tertiary_Category_ID__c = '';
                    this.caseObject.Tertiary_Category__c = '';
                }
            } else if (categoryType === 'Tertiary') {
                this.tertiaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.caseObject.Tertiary_Category_ID__c = '';
                    this.caseObject.Tertiary_Category__c = '';
                    this.tertiaryCategoryOptions.push({
                        label: '-- None --',
                        value: ''
                    });
                    for (let i = 0; i < result.length; i++) {
                        this.CategoryRecords.push(result[i]);
                        if (result[i].Type__c === 'Tertiary') {
                            this.isTertiaryCategoryDisabled = false;
                            this.tertiaryCategoryOptions.push({
                                label: result[i].Name,
                                value: result[i].Id
                            });
                        }
                    }
                } else {
                    this.isTertiaryCategoryDisabled = true;
                    this.caseObject.Tertiary_Category_ID__c = '';
                    this.caseObject.Tertiary_Category__c = '';
                }
            }
            this.isSpinnerShow = false;
        }).catch(error => {
            console.log('error----->', error);
            this.error = error;
            this.showErrorMessage(Server_Error);
        });
    }

    // This method is used for removal of Case Owner
    handleRemove(event) {
        event.preventDefault();
        this.caseOwnerName = '';
        //this.caseOwnerId = '';
        this.caseObject.OwnerId = '';
        this.ownerData = false;
        this.caseOwnerSearchResult = [];
    }

    handleServerError(error) {
        var concatErrMessage = error.message + '. ' + Server_Error;
        this.showErrorMessage(concatErrMessage);
        console.error(error);
    }

    saveCase() {
        this.isSpinnerShow = true;
        if (this.caseObject.Primary_Category_ID__c && this.caseObject.OwnerId) {
            let autoassignClose = false;
            if (this.caseObject.Business_Area__c === 'MIBPL (Insurance)') {
                if (this.caseObject.Tertiary_Category_ID__c && (this.CategoryRecords.find(item => item.Id === this.caseObject.Tertiary_Category_ID__c).Direct_Case_Closure__c) === true) {
                    autoassignClose = true;
                }
                else if (this.caseObject.Secondary_Category_ID__c && (this.CategoryRecords.find(item => item.Id === this.caseObject.Secondary_Category_ID__c).Direct_Case_Closure__c) === true) {
                    autoassignClose = true;
                }
                else if (this.caseObject.Primary_Category_ID__c && (this.CategoryRecords.find(item => item.Id === this.caseObject.Primary_Category_ID__c).Direct_Case_Closure__c) === true) {
                    autoassignClose = true;
                }
                if (autoassignClose === true) {
                    this.caseObject.Insurance_Direct_Case_Closure__c = true;
                    this.caseObject.Insurance_Direct_Case_Closure_Email__c = miEmail;
                }
            }
            updateCaseRecord({
                caseJson: JSON.stringify(this.caseObject),
                previousCaseOwner: this.previousOwnerId,
                miCaseClosure: autoassignClose
            }).then(result => {
                if (result.status === 'Success') {
                    this.showSuccessMessage('Case has been updated Successfully');
                    this.closeQuickAction();
                    this.isSpinnerShow = false;
                } else {
                    this.showErrorMessage(result.message);
                }
            }).catch(error => {
                this.showErrorMessage(Server_Error);
            })

        } else {
            this.showErrorMessage('Either Primary Category / Case Owner is missing');
        }
    }

    navigateDetail() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Case", // objectApiName is optional
                actionName: "view"
            }
        });
        this.loading = false;
    }

    closeQuickAction() {
        this.isSpinnerShow = true;
        this.navigateDetail();
        this.dispatchEvent(new CustomEvent('closeCmp'));
    }

    //method to show success toast message
    showSuccessMessage(successMessage) {
        this.showMessage("Success!", successMessage, "success");
    }

    //method to show error toast message
    showErrorMessage(error) {
        this.isSpinnerShow = false;
        if (error) {
            this.errorMessage = error;
        } else {
            this.errorMessage = Server_Error;
        }
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