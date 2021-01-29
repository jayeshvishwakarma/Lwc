import { LightningElement, api, wire } from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';

import Server_Error from "@salesforce/label/c.UI_Error_Message";
import fetchCaseRecord from "@salesforce/apex/EditInboundCase.fetchCaseData";
import fetchCategoryData from '@salesforce/apex/CreateInboundCase.fetchCategoryData';
import createCaseAction from "@salesforce/apex/EditInboundCase.createCaseActionRecord";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import internalProfiles from "@salesforce/label/c.Dealer_Internal_Profiles";
import currentUserId from "@salesforce/user/Id";
import profileName from "@salesforce/schema/User.Profile.Name";
import miCode from "@salesforce/schema/User.Account.Parent_MI_Code__c";
import workshopCode from "@salesforce/schema/User.Account.Parent_Workshop_Code__c";
import codeMissing from "@salesforce/label/c.Code_Missing";
import restrictEdit from "@salesforce/label/c.Restrict_Edit";
import restrictStatus from "@salesforce/label/c.Restrict_Status";
import restrictRepeat from "@salesforce/label/c.Restrict_Repeat";
import caseAutoAssignService from "@salesforce/label/c.Create_Case_Service";
import {
    getRecord
} from "lightning/uiRecordApi";


export default class TransferDealerInboundCase extends NavigationMixin(LightningElement) {

    primaryCategoryOptions = [];
    isPrimaryCategoryDisabled = false;
    secondaryCategoryOptions = [];
    isSecondaryCategoryDisabled = false;
    tertiaryCategoryOptions = [];
    isTertiaryCategoryDisabled = false;
    errorMessage;
    sObjectName = 'Case';
    recordTypeId;
    @api recordId;
    isSpinnerShow = true;
    isFormReadyToShow = false;
    CategoryRecords = [];
    loggedinUserProfile;
    dealerOutletOptions;
    AllDealerOptions;
    parentWorkshopCode;
    parentWorkshoDealer;
    miCode;
    miWorkshopDealer;
    caseActionPrimaryDealerQCM;
    caseActionTransferredDealerCaseOwner;
    dealerQCM;
    dealerName;
    parentCaseBusinessArea;
    caseObject = {
        "Channel__c": "",
        "Business_Area__c": "",
        "Case_Type__c": "",
        "Dealer_Name__c": "",
        "Case_Stage__c": "",
        "OwnerId": currentUserId,
        "Primary_Category__c": "",
        "Primary_Category_ID__c": "",
        "Secondary_Category__c": "",
        "Secondary_Category_ID__c": "",
        "Tertiary_Category__c": "",
        "Tertiary_Category_ID__c": "",
        "Insurance_Direct_Case_Closure__c": false,
        "Case_Number__c": "",
        "Name": "Dealer Internal Case Transfer"
    }

    @wire(getRecord, {
        recordId: currentUserId,
        fields: [profileName, workshopCode, miCode]
    })
    currentUser({
        error,
        data
    }) {
        if (data) {
            this.loggedinUserProfile = data.fields.Profile.displayValue;
            this.parentWorkshopCode = data.fields.Account.value.fields.Parent_Workshop_Code__c.value ? data.fields.Account.value.fields.Parent_Workshop_Code__c.value : null;
            this.miCode = data.fields.Account.value.fields.Parent_MI_Code__c.value ? data.fields.Account.value.fields.Parent_MI_Code__c.value : null;
            if (this.recordId && (this.parentWorkshopCode || this.miCode)) {
                this.getCaseData();
            } else {
                this.errorMessage = codeMissing;
                this.showErrorMessage(codeMissing);
            }
        } else if (error) {
            console.log('error------>', error);
            this.errorMessage = Server_Error;
            this.showErrorMessage(Server_Error);
        }
    }

    cmpAccessibilityCheck(data) {
        let profileNBame = internalProfiles.split(';');
        let response = false;
        if (data && this.loggedinUserProfile) {
            if (currentUserId != data.caseData[0].OwnerId && !profileNBame.includes(this.loggedinUserProfile) && data.userRec[0].ManagerId && currentUserId != data.userRec[0].ManagerId) {
                this.errorMessage = restrictEdit;
                this.showErrorMessage(this.errorMessage);
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
            sourceObject: "Transfer Cmp",
            workshopCodeData: this.parentWorkshopCode,
            miCodeData: this.miCode
        }).then(result => {
            if (this.cmpAccessibilityCheck(result)) {
                if (result && result.caseData && result.categoryData) {
                    if (!result.caseData[0].Dealer_Internal_Repeat__c) {
                        if (result.caseData[0].Status !== 'Closed' && result.caseData[0].Status !== 'Transferred') {
                            if (result.caseData[0].Primary_Dealer_QCM__c && result.caseData[0].Dealer_Name__c) {
                                if (result.categoryData.length > 0) {
                                    this.CategoryRecords = result.categoryData;
                                    console.log('this.CategoryRecords--->', this.CategoryRecords);
                                    //Primary Category Options
                                    this.primaryCategoryOptions = [];
                                    this.primaryCategoryOptions.push({
                                        label: '-- None --',
                                        value: ''
                                    });
                                    for (let i = 0; i < result.categoryData.length; i++) {
                                        if (result.categoryData[i].Type__c === 'Primary') {

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

                                            this.tertiaryCategoryOptions.push({
                                                label: result.categoryData[i].Name,
                                                value: result.categoryData[i].Id
                                            });
                                        }
                                    }

                                    this.caseObject.Case_Number__c = this.recordId ? this.recordId : '';
                                    this.recordTypeId = result.caseData[0].RecordTypeId ? result.caseData[0].RecordTypeId : '';

                                    this.caseObject.Business_Area__c = result.caseData[0].Business_Area__c ? result.caseData[0].Business_Area__c : '';
                                    this.parentCaseBusinessArea=result.caseData[0].Business_Area__c ? result.caseData[0].Business_Area__c : '';
                                    this.caseObject.Channel__c = result.caseData[0].Channel__c ? result.caseData[0].Channel__c : '';
                                    this.caseObject.Case_Type__c = result.caseData[0].Case_Type__c ? result.caseData[0].Case_Type__c : '';
                                    this.caseObject.Case_Stage__c = result.caseData[0].Case_Stage__c ? result.caseData[0].Case_Stage__c : '';

                                    this.caseObject.Primary_Category_ID__c = result.caseData[0].Primary_Category_ID__c ? result.caseData[0].Primary_Category_ID__c : '';
                                    this.caseObject.Primary_Category__c = result.caseData[0].Primary_Category__c ? result.caseData[0].Primary_Category__c : '';

                                    this.caseObject.Secondary_Category_ID__c = result.caseData[0].Secondary_Category_ID__c ? result.caseData[0].Secondary_Category_ID__c : '';
                                    this.caseObject.Secondary_Category__c = result.caseData[0].Secondary_Category__c ? result.caseData[0].Secondary_Category__c : '';

                                    this.caseObject.Tertiary_Category_ID__c = result.caseData[0].Tertiary_Category_ID__c ? result.caseData[0].Tertiary_Category_ID__c : '';
                                    this.caseObject.Tertiary_Category__c = result.caseData[0].Tertiary_Category__c ? result.caseData[0].Tertiary_Category__c : '';

                                    if (result.parentWorshopCodeMicodeDealers.length > 0) {
                                        this.dealerOutletOptions = [];
                                        this.AllDealerOptions = [];
                                        this.parentWorkshoDealer = [];
                                        this.miWorkshopDealer = [];
                                        for (let i = 0; i < result.parentWorshopCodeMicodeDealers.length; i++) {
                                            if (result.parentWorshopCodeMicodeDealers[i].Parent_Workshop_Code__c === this.parentWorkshopCode) {
                                                this.parentWorkshoDealer.push({
                                                    label: result.parentWorshopCodeMicodeDealers[i].Name,
                                                    value: result.parentWorshopCodeMicodeDealers[i].Id
                                                });
                                            }
                                            if (result.parentWorshopCodeMicodeDealers[i].Parent_MI_Code__c === this.miCode) {
                                                this.miWorkshopDealer.push({
                                                    label: result.parentWorshopCodeMicodeDealers[i].Name,
                                                    value: result.parentWorshopCodeMicodeDealers[i].Id
                                                });
                                            }
                                        }
                                        this.AllDealerOptions = result.parentWorshopCodeMicodeDealers;

                                        let miProfileName = caseAutoAssignService.split(';');            
                                        if (miProfileName.includes(this.loggedinUserProfile)){
                                            //mi agent can assign to any outlet in region
                                            this.dealerOutletOptions = this.miWorkshopDealer;
                                        } 

                                        else if (result.caseData[0].Business_Area__c === 'MIBPL (Insurance)') {
                                            this.dealerOutletOptions = this.miWorkshopDealer;
                                        } else if (result.caseData[0].Business_Area__c === 'Sales' ||
                                            result.caseData[0].Business_Area__c === 'Accessories' ||
                                            result.caseData[0].Business_Area__c === 'Finance' ||
                                            result.caseData[0].Business_Area__c === 'Service-Workshop' ||
                                            result.caseData[0].Business_Area__c === 'Service-Bodyshop'
                                        ) {
                                            this.dealerOutletOptions = this.parentWorkshoDealer;
                                        }
                                        if (this.dealerOutletOptions.length > 0) {
                                            this.caseObject.Dealer_Name__c = result.caseData[0].Dealer_Name__c;
                                            this.dealerQCM = this.AllDealerOptions.find(item => item.Id === result.caseData[0].Dealer_Name__c).Primary_Dealer_QCM__c ? this.AllDealerOptions.find(item => item.Id === result.caseData[0].Dealer_Name__c).Primary_Dealer_QCM__c : null;
                                            this.dealerName = this.AllDealerOptions.find(item => item.Id === result.caseData[0].Dealer_Name__c).Name ? this.AllDealerOptions.find(item => item.Id === result.caseData[0].Dealer_Name__c).Name : null;
                                        }

                                        this.isSpinnerShow = false;
                                        this.isFormReadyToShow = true;
                                    } else {
                                        this.isSpinnerShow = false;
                                        this.errorMessage = 'Dealer Outlet is missing. Please contact support Team';
                                        this.showErrorMessage(this.errorMessage);
                                    }

                                } else {
                                    this.errorMessage = Server_Error;
                                    this.showErrorMessage(Server_Error);
                                }
                            }else{
                                this.errorMessage = 'Primary Dealer QCM is missing in'+' '+result.caseData[0].Dealer_Name__r.Name+'. '+'Please contact support Team';
                                this.showErrorMessage(this.errorMessage);
                            }
                        } else {
                            this.isSpinnerShow = false;
                            this.errorMessage = restrictStatus;
                            this.showErrorMessage(this.errorMessage);
                        }
                    }
                    else {
                        this.isSpinnerShow = false;
                        this.errorMessage = restrictStatus;
                        this.showErrorMessage(this.errorMessage);
                    }
                }
            }
        }).catch(error => {
            console.log('error------>', error);
            this.errorMessage = Server_Error;
            this.showErrorMessage(Server_Error);
        })
    }

    fetchDealerOptions(data) {
        if (data && data.parentWorshopCodeMicodeDealers.length > 0) {



            for (let i = 0; i < result.categoryData.length; i++) {
                if (result.categoryData[i].Type__c === 'Tertiary') {

                    this.tertiaryCategoryOptions.push({
                        label: result.categoryData[i].Name,
                        value: result.categoryData[i].Id
                    });
                }
            }
        }
    }

    handleFieldChange(event) {
        this.isSpinnerShow = true;
        let fieldName = event.target.name;
        if (fieldName === 'Channel__c') {
            this.emptyCategory();
            this.caseObject.Business_Area__c = '';
            this.caseObject.Channel__c = event.detail.value;
        }
        if (fieldName === 'Case_Type__c') {
            this.emptyCategory();
            this.caseObject.Business_Area__c = '';
            this.caseObject.Case_Type__c = event.detail.value;
        }
        if (fieldName === 'Business_Area__c') {
            this.emptyCategory();
            this.caseObject.Case_Stage__c = '';
            this.caseObject.Business_Area__c = event.detail.value;

            this.caseObject.Dealer_Name__c = '';
            this.dealerOutletOptions = [];
            let miProfileName = caseAutoAssignService.split(';');            
            if (miProfileName.includes(this.loggedinUserProfile)){
                //mi agent can assign to any outlet in region
                this.dealerOutletOptions = this.miWorkshopDealer;
            } 
            else if (this.caseObject.Business_Area__c && this.caseObject.Business_Area__c === 'MIBPL (Insurance)') {
                this.dealerOutletOptions = this.miWorkshopDealer;
            } else if (this.caseObject.Business_Area__c && this.caseObject.Business_Area__c !== 'MIBPL (Insurance)') {
                this.dealerOutletOptions = this.parentWorkshoDealer;
            }

            if (this.caseObject.Channel__c && this.caseObject.Case_Type__c && this.caseObject.Business_Area__c) {
                this.getCategoryData('Primary');
            }
        }
        if (fieldName === 'Case_Stage__c') {
            this.emptyCategory();
            this.caseObject.Case_Stage__c = event.detail.value;
            if (this.caseObject.Channel__c && this.caseObject.Case_Type__c && this.caseObject.Business_Area__c && this.caseObject.Case_Stage__c) {
                this.getCategoryData('Primary');
            }
        }
    }

    handleDealerchange(event) {
        this.caseObject.Dealer_Name__c = event.detail.value;
        this.dealerQCM = this.AllDealerOptions.find(item => item.Id === event.detail.value).Primary_Dealer_QCM__c;
        this.dealerName = this.AllDealerOptions.find(item => item.Id === event.detail.value).Name;
    }


    handlePrimaryCategoryChange(event) {
        this.isSpinnerShow = true;
        //this.emptyCategory();
        if (event.detail.value) {
            this.caseObject.Primary_Category_ID__c = event.detail.value;
            this.getCategoryData('Secondary');
            this.caseObject.Primary_Category__c = event.detail.value ? (this.CategoryRecords.find(item => item.Id === event.detail.value).Name) : '';
        } else {
            this.caseObject.Primary_Category_ID__c = '';
            this.caseObject.Primary_Category__c = '';
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
    }

    handleSecondaryCategoryChange(event) {
        if (event.detail.value) {
            this.isSpinnerShow = true;
            this.caseObject.Secondary_Category_ID__c = event.detail.value;
            this.getCategoryData('Tertiary');
            this.caseObject.Secondary_Category__c = event.detail.value ? (this.CategoryRecords.find(item => item.Id === event.detail.value).Name) : '';
        } else {
            this.caseObject.Secondary_Category_ID__c = '';
            this.caseObject.Secondary_Category__c = '';
            this.caseObject.Tertiary_Category__c = '';
            this.caseObject.Tertiary_Category_ID__c = '';
            this.tertiaryCategoryOptions = [];
            this.isTertiaryCategoryDisabled = true;
        }
    }

    handleTertiaryCategoryChange(event) {
        if (event.detail.value) {
            this.caseObject.Tertiary_Category_ID__c = event.detail.value;
            this.caseObject.Tertiary_Category__c = event.detail.value ? (this.CategoryRecords.find(item => item.Id === event.detail.value).Name) : '';
        } else {
            this.caseObject.Tertiary_Category__c = '';
            this.caseObject.Tertiary_Category_ID__c = '';
        }
    }

    emptyCategory() {
        this.caseObject.Primary_Category_ID__c = '';
        this.caseObject.Primary_Category__c = '';
        this.caseObject.Secondary_Category_ID__c = '';
        this.caseObject.Secondary_Category__c = '';
        this.caseObject.Tertiary_Category__c = '';
        this.caseObject.Tertiary_Category_ID__c = '';
        this.primaryCategoryOptions = [];
        this.secondaryCategoryOptions = [];
        this.tertiaryCategoryOptions = [];
        this.isSecondaryCategoryDisabled = true;
        this.isTertiaryCategoryDisabled = true;
        this.isSpinnerShow = false;
    }

    getCategoryData(categoryType) {
        let clause = '';
        clause = this.caseObject.Channel__c;
        clause += '_' + this.caseObject.Case_Type__c;
        clause += '_' + this.caseObject.Business_Area__c;
        if (this.caseObject.Case_Stage__c) {
            clause += '_' + this.caseObject.Case_Stage__c
        }
        if (categoryType === 'Primary') {
            clause += '_' + 'Primary';
        } else if (categoryType === 'Secondary') {
            clause += '_' + 'Secondary' + '_' + this.caseObject.Primary_Category_ID__c;
        } else if (categoryType === 'Tertiary') {
            clause += '_' + 'Tertiary' + '_' + this.caseObject.Primary_Category_ID__c + '_' + this.caseObject.Secondary_Category_ID__c;
        }
        fetchCategoryData({
            queryFilter: clause
        }).then(result => {
            if (categoryType === 'Primary') {
                this.primaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.emptyCategory();
                    this.primaryCategoryOptions.push({
                        label: '-- None --',
                        value: ''
                    });
                    this.isSecondaryCategoryDisabled = true;
                    for (let i = 0; i < result.length; i++) {
                        this.CategoryRecords.push(result[i]);
                        if (result[i].Type__c === 'Primary') {
                            this.isPrimaryCategoryDisabled = false;
                            this.primaryCategoryOptions.push({
                                label: result[i].Name,
                                value: result[i].Id
                            });
                        }
                    }
                } else {

                }
            } else if (categoryType === 'Secondary') {
                this.secondaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.caseObject.Secondary_Category_ID__c = '';
                    this.caseObject.Secondary_Category__c = '';
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
            this.errorMessage = Server_Error;
            this.error = error;
            this.showErrorMessage(Server_Error);
        });
    }

    handleServerError(error) {
        this.errorMessage = Server_Error;
        var concatErrMessage = error.message + '. ' + Server_Error;
        this.showErrorMessage(concatErrMessage);
        console.error(error);
    }

    updateCase() {
        this.isSpinnerShow = true;
        if (this.validateInputs()) {
            if (this.autoAssignOwnerlogic(this.caseObject)) {
                console.log('this.caseObject.Business_Area__c--->' + this.caseObject.Business_Area__c);
                if (this.caseObject.Business_Area__c === 'MIBPL (Insurance)') {
                    let autoassignClose = false;
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
                    }
                    console.log('this.caseObject.Insurance_Direct_Case_Closure__c---->' + this.caseObject.Insurance_Direct_Case_Closure__c);
                }
                createCaseAction({
                    recordJson: JSON.stringify(this.caseObject),
                    caseActionDealerQCM: this.dealerQCM,
                    transferDealerOwner: this.caseActionTransferredDealerCaseOwner,
                    dealerName: this.dealerName,
                    parentCaseBusinessArea : this.parentCaseBusinessArea
                }).then(result => {
                    if (result.status === 'Success') {
                        this.showSuccessMessage('Case Action has been created successfully');
                        this.closeQuickAction();
                        this.isSpinnerShow = false;
                    } else {
                        this.errorMessage = result.message;
                        this.showErrorMessage(this.errorMessage);
                        this.isSpinnerShow = false;
                    }
                }).catch(error => {
                    this.isSpinnerShow = false;
                    this.errorMessage = Server_Error;
                    this.showErrorMessage(Server_Error);
                })
            }
        } else {
            this.showErrorMessage('Required Fields is missing');
        }
    }

    autoAssignOwnerlogic(caseData) {
        let response = true;
        if (caseData && caseData.Business_Area__c && caseData.Dealer_Name__c && (caseData.Business_Area__c === 'Sales'
            || caseData.Business_Area__c === 'Finance' || caseData.Business_Area__c === 'Accessories' ||
            caseData.Business_Area__c === 'MIBPL (Insurance)')) {
            let ownerArray = [];
            if (caseData.Business_Area__c === 'Sales' || caseData.Business_Area__c === 'Finance') {
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_1__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_1__c);
                }
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_2__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_2__c);
                }
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_3__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_3__c);
                }
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_4__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_4__c);
                }
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_5__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Sales_SPOC_5__c);
                }
            } else if (caseData.Business_Area__c === 'Accessories') {
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Accessories_SPOC_1__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Accessories_SPOC_1__c);
                }
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Accessories_SPOC_2__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Accessories_SPOC_2__c);
                }
            } else if (caseData.Business_Area__c === 'MIBPL (Insurance)') {
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Insurance_SPOC_1__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Insurance_SPOC_1__c);
                }
                if (this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Insurance_SPOC_2__c) {
                    ownerArray.push(this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Insurance_SPOC_2__c);
                }
            }
            if (ownerArray.length > 0) {
                this.caseActionTransferredDealerCaseOwner = ownerArray[Math.floor(Math.random() * ownerArray.length)];
            } else {
                response = false;
                this.isSpinnerShow = false;
                this.showErrorMessage(caseData.Business_Area__c + ' SPOCs are missing in ' + this.AllDealerOptions.find(item => item.Id === caseData.Dealer_Name__c).Name + '. Please contact support Team.');
            }
        }
        return response;
    }

    queryAll(query) {
        return Array.from(this.template.querySelectorAll(query));
    }

    //to handle the data validation
    validateInputs() {
        let inps = [].concat(
            this.queryAll("lightning-combobox"),
            this.queryAll("lightning-input-field"),
        );
        return inps.filter(inp => !inp.reportValidity()).length === 0;
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