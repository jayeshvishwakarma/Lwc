import {
    LightningElement,
    api
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import fetchCustomerData from '@salesforce/apex/CreateInboundCase.fetchCustomerDetails';
import fetchCategoryData from '@salesforce/apex/CreateInboundCase.fetchCategoryData';
import fetchCaseOwnerData from '@salesforce/apex/CreateInboundCase.fetchCaseOwner';
import saveCaseRecord from '@salesforce/apex/CreateInboundCase.updateCaseData';
import fetchSalesAccessoryOwner from '@salesforce/apex/CreateInboundCase.fetchenquiryDealerRec';
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import salesSPOCMissing from "@salesforce/label/c.Sales_SPOC_Missing";
import accessorySPOCMissing from "@salesforce/label/c.Accessory_SPOC_Missing";
import miEmail from "@salesforce/label/c.MI_Dealer_Internal";
import currentUserId from "@salesforce/user/Id";
import caseAutoAssignService from "@salesforce/label/c.Create_Case_Service";
import emMCPerrMsg from "@salesforce/label/c.EW_MCP_Create_Case";


export default class CreateDealerInboundCase extends NavigationMixin(LightningElement) {
    mainCss = ' slds-brand-band slds-brand-band_narrow slds-template_default forceBrandBand slds-p-vertical--none';
    isMobileDevice = false;
    isSpinnerShow = true;
    isFormReadyToShow = false;
    cancelButtonLabel = 'Cancel';
    newCaseLabel = 'New Case';
    sObjectName = 'Case';
    salesAccesoriesBusinessArea = false; // For Business Area Sales & Accessories
    insuranceBusinessArea = false;
    accessoriesBusinessArea = false;
    serviceBusinessArea = false;
    fcrResponse; //Variable to store value for FCR_Conducted__c
    searchKey;
    ownerData = false;
    caseOwnerSearchResult;
    caseOwnerName;
    caseOwnerId;
    manulOwnerAssign = false;
    primcategoryData = [];
    seconcategoryData = [];
    tertiarycategoryData = [];
    dealerData = [];
    dealerCityData;
    dealerCityId;
    dealerOutletOptions;
    primaryCategoryOptions;
    secondaryCategoryOptions;
    tertiaryCategoryOptions;
    isPrimaryCategoryDisabled = true;
    isSecondaryCategoryDisabled = true;
    isTertiaryCategoryDisabled = true;
    valuesObj = {};
    salesAccessoryData = [];
    fromSearchPolicy = false;
    @api sourceCmp; // Variable to store Info from where the Case Creation is getting called
    caseRecordTypedata = [];
    assetData = [];
    istesting;
    caseRecordTypeDevelopername;
    businessAreaReadOnly = true;
    insuranceAutoClosure = false;
    dealerReadonly = false;
    parentWorkshopDealerList;
    parentMiCodeDealerList;
    insuranceDirectCaseClosure;
    insuranceDirectCaseClosureEmail;
    enquiryData;
    disableSaveButton = false;
    loggedInUserDealerId;
    agentProfileName;
    serviceAutoAssign;
    @api caseRecTypeName;
    @api customerEnquiryId; //This will contain Customer/Opportunity Record Id on the basis from where the Create Case cmp is getting called
    @api caseId;
    @api recordTypeId;

    //EW & MCP Calculator changes
    @api vehicleodometer;
    @api vehicleregistrationnumber;
    @api vehiclevinnumber;
    @api packagename;
    @api mcpdealerid;
    //EW & MCP Calculator changes

    // This variable will contain values passed from Service History
    @api serviceHistory = {
        "serviceAdvisor": "",
        "jobCardNumber": "",
        "registrationNumber": "",
        "dealerSfId": ""
    }

    // This variable will contain values passed from Policy Details Tab
    @api policyNumber;

    connectedCallback() {
        try {
            if (this.sourceCmp === 'Policy Search') {
                this.valuesObj.channelValue = 'MI';
            } else if (this.sourceCmp === 'EW Calculator' || this.sourceCmp === 'MCP Calculator') {
                this.serviceHistory.registrationNumber = this.vehicleregistrationnumber;
            }
            this.getCustomerEnquiryData();
        } catch (error) {
            this.error = error;
            this.handleServerError(error);
            this.closeModal();
        }

    }

    //Server call to fetch Data related to Customer(Account) or Opportunity, Parent Workshop Code/Parent MI Code, Asset data, Profile Name and Dealer ID
    getCustomerEnquiryData() {
        fetchCustomerData({
            recordId: this.customerEnquiryId
        }).then(result => {
            if (result.dealerOutletName && result.dealerOutletName.length > 0) {
                let outletData = result.dealerOutletName;
                this.dealerData = result.dealerOutletName;
                this.agentProfileName = result.agentProfileName;
                this.parentWorkshopDealerList = [];
                this.parentMiCodeDealerList = [];

                for (let i = 0; i < outletData.length; i++) {
                    if (result.parentWorkhopCode && outletData[i].Parent_Workshop_Code__c === result.parentWorkhopCode) {
                        this.parentWorkshopDealerList.push({
                            label: outletData[i].Name,
                            value: outletData[i].Id
                        });
                    }
                    if (result.parentMiCode && outletData[i].Parent_MI_Code__c === result.parentMiCode) {
                        this.parentMiCodeDealerList.push({
                            label: outletData[i].Name,
                            value: outletData[i].Id
                        });
                    }
                }
            }
            if (result.dealerOutletName && result.dealerOutletName.length === 0) {
                let errMessage = 'No Outlet exist for the logged in User.' + ' ' + Server_Error;
                this.showErrorMessage(errMessage);
            }
            if (result.caseRecMetadata && result.caseRecMetadata.length > 0) {
                this.caseRecordTypedata = result.caseRecMetadata;
            }
            if (result.registrationNumberList && result.registrationNumberList.length > 0) {
                this.assetData = result.registrationNumberList;
            }
            this.loggedInUserDealerId = result.agentDealerId ? result.agentDealerId : '';

            if ((result.loggedUserChannel === 'Arena' || result.loggedUserChannel === 'Nexa') && (this.sourceCmp === 'EW Calculator' || this.sourceCmp === 'MCP Calculator')) {
                this.dealerOutletOptions = this.parentWorkshopDealerList;
                this.caseRecordTypeDevelopername = (this.caseRecordTypedata.find(item => item.MasterLabel === 'Dealer Internal Query').Record_Type_Developer_Name__c);
                this.valuesObj.channelValue = result.loggedUserChannel;
                this.valuesObj.caseType = 'Dealer Internal Query';
                this.valuesObj.businessArea = 'Service-Workshop';
                this.autoPopulateDealerShip();
                this.handleBusinessAreaChange();
                this.getCategoryData('Primary');
                let profileName = caseAutoAssignService.split(';');
                if (profileName.includes(this.agentProfileName)) {
                    this.manulOwnerAssign = false; // manually select Case Owner
                } else {
                    this.manulOwnerAssign = true; // manually select Case Owner
                }
                this.isPrimaryCategoryDisabled = true;
            }

            if (result.enquiryData && result.enquiryData.Id) {
                this.enquiryData = result.enquiryData;
                this.getEnquiryCustomerData(result);
            } else {
                if (result.customerdata.FirstName) {
                    this.valuesObj.customerFirstName = result.customerdata.FirstName;
                }
                if (result.customerdata.LastName) {
                    this.valuesObj.customerLastName = result.customerdata.LastName;
                }
                if (result.customerdata.PersonMobilePhone) {
                    this.valuesObj.customerMobile = result.customerdata.PersonMobilePhone;
                }
                if (result.customerdata.PersonEmail) {
                    this.valuesObj.customerEmail = result.customerdata.PersonEmail;
                }
                if (result.customerdata.PersonContactId) {
                    this.valuesObj.contactId = result.customerdata.PersonContactId;
                }
            }
            this.isFormReadyToShow = true;
            this.isSpinnerShow = false;
        }).catch(error => {
            this.error = error;
            this.isSpinnerShow = false;
            this.handleServerError(error);
            this.closeModal();
        });
    }

    //method to take customer data from enquiry
    getEnquiryCustomerData(result) {
        try {
            if (result.enquiryData.Id) {
                this.valuesObj.enquiryId = result.enquiryData.Id;
            }
            if (result.enquiryData.First_Name__c) {
                this.valuesObj.customerFirstName = result.enquiryData.First_Name__c;
            }
            if (result.enquiryData.Last_Name__c) {
                this.valuesObj.customerLastName = result.enquiryData.Last_Name__c;
            }
            if (result.enquiryData.Mobile__c) {
                this.valuesObj.customerMobile = result.enquiryData.Mobile__c;
            }
            if (result.enquiryData.Email__c) {
                this.valuesObj.customerEmail = result.enquiryData.Email__c;
            }
            if (result.enquiryData.Customer__r.PersonContactId) {
                this.valuesObj.contactId = result.enquiryData.Customer__r.PersonContactId;
            }
            if (result.enquiryData.Customer__c) {
                this.customerEnquiryId = result.enquiryData.Customer__c;
            }
            if (result.enquiryData.Dealership_Channel__c && (result.enquiryData.Dealership_Channel__c === 'Arena' ||
                result.enquiryData.Dealership_Channel__c === 'Nexa' || result.enquiryData.Dealership_Channel__c === 'MIBPL (Insurance)')) {
                if (result.enquiryData.Dealership_Channel__c === 'MIBPL (Insurance)') {
                    this.valuesObj.channelValue = 'MI';
                } else {
                    this.valuesObj.channelValue = result.enquiryData.Dealership_Channel__c;
                }
            }
            if (result.enquiryData.Booking_Number__c) {
                this.valuesObj.Booking_No__c = result.enquiryData.Booking_Number__c;
            }
            if (result.enquiryData.Invoice_Number__c) {
                this.valuesObj.Invoice_No__c = result.enquiryData.Invoice_Number__c;
            }
            if (result.enquiryData.Model_Code__c) {
                this.valuesObj.Model__c = result.enquiryData.Model_Code__c;
            }
            if (result.enquiryData.Variant__c) {
                this.valuesObj.Variant__c = result.enquiryData.Variant__c;
            }
            if (result.enquiryData.Color__c) {
                this.valuesObj.Color__c = result.enquiryData.Color__c;
            }
            if (result.enquiryData.VIN__c) {
                this.valuesObj.VIN_No__c = result.enquiryData.VIN__c;
            }
            if (result.enquiryData.Vehicle_Registration__c) {
                this.valuesObj.Registration_No__c = result.enquiryData.Vehicle_Registration__c;
            }
        } catch (error) {
            this.isSpinnerShow = false;
            this.handleServerError(error);
            this.closeModal();
        }
    }

    handleRegistrationNumberChange(event) {
        var businessArea = this.template.querySelector('[data-id="bsinessArea"]');
        if (this.assetData && businessArea.value !== undefined && businessArea.value === 'MIBPL (Insurance)') {
            for (let i = 0; i < this.assetData.length; i++) {
                //to remove space while typing and keep the data in lower case
                if (event.target.value.match(/\s/g)) {
                    event.target.value = event.target.value.replace(/\s/g, '');
                  }
                //to remove space while typing and keep the data in lower case
                if (this.assetData[i].Name.toLowerCase().replace(/ /g, "") === event.target.value.toLowerCase().replace(/ /g, "")) {
                    this.policyNumber = this.assetData[i].Current_Insurance_Reference_Number__c;
                    break;
                } else {
                    this.policyNumber = '';
                }
            }
        }
    }

    //To pull List of users which are the part of Dealership
    handleOwnerSearch(event) {
        if (this.valuesObj.dealerOutletName) {
            this.caseOwnerSearchResult = [];
            let ownerResult;
            ownerResult = event.detail.value;
            if (ownerResult.length > 2) {
                fetchCaseOwnerData({
                    dealerId: this.valuesObj.dealerOutletName,
                    userName: ownerResult
                }).then(result => {
                    this.caseOwnerSearchResult = result;
                }).catch(error => {
                    this.handleServerError(error);
                });
            }
        }
    }

    //This method is used for Case Owner selection
    handleOwnerSelection(event) {
        const selectedRecordId = event.detail;
        this.caseOwnerName = (this.caseOwnerSearchResult.find(item => item.Id === event.detail).Name);
        this.ownerData = true;
        this.caseOwnerId = event.detail;
    }

    // This method is used for removal of Case Owner
    handleRemove(event) {
        event.preventDefault();
        this.caseOwnerName = '';
        this.caseOwnerId = '';
        this.ownerData = false;
        this.caseOwnerSearchResult = [];
    }

    // To handle changes in Channel,Case Type,Business Area, Case Stage, Dealer, FCR Conducted & Enquiry
    handleFieldChange(event) {
        this.isSpinnerShow = true;
        let fieldName = event.target.name;
        if (fieldName === 'Channel__c') {
            this.emptyCategory();
            this.valuesObj.channelValue = event.detail.value;
            this.valuesObj.businessArea = '';
            this.valuesObj.caseStage = '';
            this.valuesObj.caseType = '';
            var businessArea = this.template.querySelector('[field-name="Business_Area__c"]');
            businessArea.value = null;
            businessArea.reset();
        }
        if (fieldName === 'Case_Type__c') {
            this.emptyCategory();
            this.valuesObj.businessArea = '';
            this.valuesObj.caseType = event.detail.value;
            if (event.detail.value && this.valuesObj.channelValue === 'MI') {
                this.valuesObj.businessArea = 'MIBPL (Insurance)';
                this.getCategoryData('Primary');
                this.dealerOutletOptions = this.parentMiCodeDealerList;
                this.autoPopulateDealerShip();
                this.handleBusinessAreaChange();
            }
            this.businessAreaReadOnly = event.detail.value ? false : true;
            this.caseRecordTypeDevelopername = (this.caseRecordTypedata.find(item => item.MasterLabel === event.detail.value).Record_Type_Developer_Name__c);
        }
        if (fieldName === 'Business_Area__c') {
            this.valuesObj.businessArea = '';
            this.emptyCategory();
            this.valuesObj.businessArea = event.detail.value === 'None' ? null : event.detail.value;

            this.caseOwnerName = '';
            this.caseOwnerId = '';
            this.dealerCityData = '';
            this.dealerCityId = '';
            this.ownerData = false;
            this.caseOwnerSearchResult = '';
            this.valuesObj.dealerOutletName = '';
            let miProfileName = caseAutoAssignService.split(';');            
            if (this.valuesObj.businessArea === 'MIBPL (Insurance)') {
                this.dealerOutletOptions = this.parentMiCodeDealerList;
                //manulOwnerAssign=false;
            } else if (miProfileName.includes(this.agentProfileName)){
                //mi agent can assign to any outlet in region
                this.dealerOutletOptions = this.parentMiCodeDealerList;
            } 
            else if (this.valuesObj.businessArea !== 'MIBPL (Insurance)') {
                this.dealerOutletOptions = this.parentWorkshopDealerList;
            }

            this.autoPopulateDealerShip();
            this.valuesObj.caseStage = '';
            this.handleRemove(event);
            if (this.sourceCmp !== 'EW Calculator' && this.sourceCmp !== 'MCP Calculator') {
            this.handleFieldDataReset(event);
            }
            this.handleBusinessAreaChange();
            if (this.valuesObj.channelValue && this.valuesObj.caseType && this.valuesObj.businessArea) {
                this.getCategoryData('Primary');
            }
        }
        if (fieldName === 'Case_Stage__c') {
            this.emptyCategory();
            this.valuesObj.caseStage = event.detail.value;
            if (this.valuesObj.channelValue && this.valuesObj.caseType && this.valuesObj.businessArea && this.valuesObj.caseStage) {
                this.isSpinnerShow = true;
                this.getCategoryData('Primary');
            }
        }
        if (fieldName === 'dealerName') {
            this.caseOwnerName = '';
            this.caseOwnerId = '';
            this.dealerCityData = '';
            this.dealerCityId = '';
            this.ownerData = false;
            this.caseOwnerSearchResult = '';
            this.valuesObj.dealerOutletName = event.detail.value;
            this.dealerCityData = (this.dealerData.find(item => item.Id === event.detail.value).For_Code__r.Name);
            this.dealerCityId = (this.dealerData.find(item => item.Id === event.detail.value).For_Code__c);
            this.handleBusinessAreaChange();
        }
        if (fieldName === 'FCR_Conducted__c') {
            this.fcrResponse = event.detail.value;
        }
        if (fieldName === 'Enquiry__c') {
            let enqId;
            enqId = event.detail.value;
            if (Array.isArray(enqId)) {
                this.valuesObj.enquiryId = enqId ? enqId[0] : '';
            } 
            else {
                this.valuesObj.enquiryI = enqId;
            }
            if (!this.valuesObj.enquiryId && this.valuesObj.dealerOutletName && (this.valuesObj.businessArea === 'Sales' || this.valuesObj.businessArea === 'Finance') && (this.valuesObj.caseType === 'Dealer Internal Complaint' || this.valuesObj.caseType === 'Dealer Internal Feedback')) {
                this.handleRemove(event);
                this.manulOwnerAssign = true;
            }

        }
        this.isSpinnerShow = false;
    }

    //Method to auto populate Dealer Name
    autoPopulateDealerShip() {
        if (this.dealerOutletOptions && this.serviceHistory.dealerSfId && this.sourceCmp === 'Service History') {
            this.dealerReadonly = true;
            this.valuesObj.dealerOutletName = this.serviceHistory.dealerSfId;
            this.dealerCityId = (this.dealerData.find(item => item.Id === this.serviceHistory.dealerSfId).For_Code__c);
            this.dealerCityData = (this.dealerData.find(item => item.Id === this.serviceHistory.dealerSfId).For_Code__r.Name);
        } else if (this.enquiryData && this.sourceCmp === 'Opportunity' && this.enquiryData.Dealership__c) {
            this.dealerReadonly = true;
            this.valuesObj.dealerOutletName = this.enquiryData.Dealership__c;
            this.dealerCityData = this.enquiryData.Dealership__r.For_Code__r.Name;
            this.dealerCityId = this.enquiryData.Dealership__r.For_Code__c;
        } else if (this.dealerOutletOptions && this.sourceCmp === 'MCP Calculator' && this.mcpdealerid) {
            this.valuesObj.dealerOutletName = this.mcpdealerid;
            this.dealerReadonly = true;
        } else {
            this.valuesObj.dealerOutletName = this.loggedInUserDealerId;
            this.dealerCityId = (this.dealerData.find(item => item.Id === this.loggedInUserDealerId).For_Code__c);
            this.dealerCityData = (this.dealerData.find(item => item.Id === this.loggedInUserDealerId).For_Code__r.Name);
        }
        return true;
    }

    //Method to reset data
    handleFieldDataReset(event) {
        try {
            this.template.querySelectorAll('[data-id="resteData"]').forEach(each => {
                each.value = null;
            });
            if (this.sourceCmp === 'Opportunity') {
                this.template.querySelectorAll('[data-id="AssetData"]').forEach(each => {
                    each.value = null;
                });
                this.template.querySelectorAll('[data-id="PolicyData"]').forEach(each => {
                    each.value = null;
                });
            } else if (this.sourceCmp === 'Policy Search') {
                this.valuesObj.enquiryId = '';
                this.template.querySelectorAll('[data-id="resteTransactionData"]').forEach(each => {
                    each.value = null;
                    each.reset();
                });
                this.template.querySelectorAll('[data-id="AssetData"]').forEach(each => {
                    each.value = null;
                    each.reset();
                });
            } else if (this.sourceCmp === 'Service History') {
                this.valuesObj.enquiryId = '';
                this.template.querySelectorAll('[data-id="resteTransactionData"]').forEach(each => {
                    each.value = null;
                });
                this.template.querySelectorAll('[data-id="PolicyData"]').forEach(each => {
                    each.value = null;
                });
            } else {
                this.valuesObj.enquiryId = '';
                this.template.querySelectorAll('[data-id="AssetData"]').forEach(each => {
                    each.value = null;
                });
                this.template.querySelectorAll('[data-id="PolicyData"]').forEach(each => {
                    each.value = null;
                });

                this.template.querySelectorAll('[data-id="resteTransactionData"]').forEach(each => {
                    each.value = null;
                });
            }
        } catch (error) {
        }
    }

    //Method to remove Category data
    emptyCategory() {
        this.valuesObj.primaryCategoryValue = '';
        this.valuesObj.primaryCategoryName = '';
        this.valuesObj.secondaryCategoryValue = '';
        this.valuesObj.secondaryCategoryName = '';
        this.valuesObj.tertiaryCategoryValue = '';
        this.valuesObj.tertiaryCategoryName = '';
        this.secondaryCategoryOptions = [];
        this.primaryCategoryOptions = [];
        this.tertiaryCategoryOptions = [];
        this.isSecondaryCategoryDisabled = true;
        this.isPrimaryCategoryDisabled = true;
        this.isTertiaryCategoryDisabled = true;
        this.isSpinnerShow = false;
    }


    //Method to show/hide fields on the basis of different LOB's
    handleBusinessAreaChange() {
        this.businessAreaNull();
        if (this.valuesObj.businessArea === 'Accessories') {
            this.salesAccesoriesBusinessArea = true;
            this.accessoriesBusinessArea = true;
        } else if (this.valuesObj.businessArea === 'Sales' || this.valuesObj.businessArea === 'Finance') {
            if (!this.valuesObj.enquiryId && this.valuesObj.dealerOutletName && (this.valuesObj.caseType === 'Dealer Internal Complaint' || this.valuesObj.caseType === 'Dealer Internal Feedback')) {
                this.manulOwnerAssign = true;
            }
            this.salesAccesoriesBusinessArea = true;
        } else if (this.valuesObj.businessArea === 'MIBPL (Insurance)') {
            this.insuranceBusinessArea = true;
            /*if (this.valuesObj.dealerOutletName) {
                //this.manulOwnerAssign = true; // For Service & Insurance agent has to manually select Case Owner
                this.manulOwnerAssign=false;
            }*/
        } else if (this.valuesObj.businessArea === 'Service-Workshop' || this.valuesObj.businessArea === 'Service-Bodyshop') {
            this.serviceBusinessArea = true;
            let profileName = caseAutoAssignService.split(';');
            if (this.valuesObj.dealerOutletName) //&& !this.serviceHistory.serviceAdvisor
            {
                if (profileName.includes(this.agentProfileName)) {
                    this.manulOwnerAssign = false; // manually select Case Owner
                } else {
                    this.manulOwnerAssign = true; // manually select Case Owner
                }
            }
        }
        this.isSpinnerShow = false;
    }

    businessAreaNull() {
        this.salesAccesoriesBusinessArea = false;
        this.accessoriesBusinessArea = false;
        this.insuranceBusinessArea = false;
        this.manulOwnerAssign = false;
        this.serviceBusinessArea = false;
    }

    //Primary Category data & pull the related Secondary Category data
    handlePrimaryCategoryChange(event) {
        if (event.detail.value) {
            this.valuesObj.primaryCategoryName = (this.primcategoryData.find(item => item.Id === event.detail.value).Name);
            if ((this.valuesObj.primaryCategoryName === 'EW' && this.sourceCmp !== 'EW Calculator') || (this.valuesObj.primaryCategoryName === 'MCP' && this.sourceCmp !== 'MCP Calculator')) {
                this.showErrorMessage(emMCPerrMsg);
            } else {
            this.valuesObj.primaryCategoryValue = event.detail.value;
            this.valuesObj.primaryCategoryName = (this.primcategoryData.find(item => item.Id === event.detail.value).Name);
            this.isSpinnerShow = true;
            this.getCategoryData('Secondary');
            }
        } else {
            this.isSecondaryCategoryDisabled = true;
            this.isTertiaryCategoryDisabled = true;
            this.valuesObj.primaryCategoryValue = '';
            this.valuesObj.primaryCategoryName = '';
            this.valuesObj.secondaryCategoryValue = '';
            this.valuesObj.secondaryCategoryName = '';
            this.valuesObj.tertiaryCategoryValue = '';
            this.valuesObj.tertiaryCategoryName = '';
            this.secondaryCategoryOptions = [];
            this.tertiaryCategoryOptions = [];
        }
    }

    //Secondary Category data & pull the related Tertiary Category data
    handleSecondaryCategoryChange(event) {
        if (event.detail.value) {
            this.valuesObj.secondaryCategoryValue = event.detail.value;
            this.valuesObj.secondaryCategoryName = (this.seconcategoryData.find(item => item.Id === event.detail.value).Name);
            this.isSpinnerShow = true;
            this.getCategoryData('Tertiary');
        } else {
            this.valuesObj.secondaryCategoryValue = '';
            this.valuesObj.secondaryCategoryName = '';
            this.valuesObj.tertiaryCategoryValue = '';
            this.valuesObj.tertiaryCategoryName = '';
            this.tertiaryCategoryOptions = [];
            this.isTertiaryCategoryDisabled = true;
        }
    }

    //Tertiary Category data
    handleTertiaryCategoryChange(event) {
        if (event.detail.value) {
            this.valuesObj.tertiaryCategoryValue = event.detail.value;
            this.valuesObj.tertiaryCategoryName = (this.tertiarycategoryData.find(item => item.Id === event.detail.value).Name);
        } else {
            this.valuesObj.tertiaryCategoryValue = '';
            this.valuesObj.tertiaryCategoryName = '';
        }
    }

    //Method to fetch the Primary,Secondary & Tertiary data on the basis of Category type
    getCategoryData(categoryType) {
        let clause = '';
        clause = this.valuesObj.channelValue;
        clause += '_' + this.valuesObj.caseType;
        clause += '_' + this.valuesObj.businessArea;
        if (this.valuesObj.caseStage) {
            clause += '_' + this.valuesObj.caseStage
        }
        if (categoryType === 'Primary') {
            clause += '_' + 'Primary';
        } else if (categoryType === 'Secondary') {
            clause += '_' + 'Secondary' + '_' + this.valuesObj.primaryCategoryValue;
        } else if (categoryType === 'Tertiary') {
            clause += '_' + 'Tertiary' + '_' + this.valuesObj.primaryCategoryValue + '_' + this.valuesObj.secondaryCategoryValue;
        }
        fetchCategoryData({
            queryFilter: clause
        }).then(result => {
            // This part is covered to fetch and display the Picklist values for Service type
            if (categoryType === 'Primary') {
                this.primaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.primcategoryData = result;
                    this.emptyCategory();
                    this.primaryCategoryOptions.push({
                        label: '-- None --',
                        value: ''
                    });
                    this.isSecondaryCategoryDisabled = true;
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].Type__c === 'Primary') {
                            this.isPrimaryCategoryDisabled = false;
                            this.primaryCategoryOptions.push({
                                label: result[i].Name,
                                value: result[i].Id
                            });
                        }
                        if (this.sourceCmp === 'EW Calculator' && result[i].Name === 'EW') {
                            this.valuesObj.primaryCategoryValue = result[i].Id;
                            this.valuesObj.primaryCategoryName = result[i].Name;
                        } else if (this.sourceCmp === 'MCP Calculator' && result[i].Name === 'MCP') {
                            this.valuesObj.primaryCategoryValue = result[i].Id;
                            this.valuesObj.primaryCategoryName = result[i].Name;
                        }
                    }

                    this.isSpinnerShow = false;
                } else {
                    this.isSpinnerShow = false;
                }
            } else if (categoryType === 'Secondary') {
                this.secondaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.valuesObj.secondaryCategoryValue = '';
                    this.valuesObj.secondaryCategoryName = '';
                    this.seconcategoryData = result;
                    this.secondaryCategoryOptions.push({
                        label: '-- None --',
                        value: ''
                    });
                    for (let i = 0; i < result.length; i++) {
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
                    this.valuesObj.secondaryCategoryValue = '';
                    this.valuesObj.secondaryCategoryName = '';
                    this.valuesObj.tertiaryCategoryValue = '';
                    this.valuesObj.tertiaryCategoryName = '';
                }
            } else if (categoryType === 'Tertiary') {
                this.tertiaryCategoryOptions = [];
                if (result && result.length > 0) {
                    this.valuesObj.tertiaryCategoryValue = '';
                    this.valuesObj.tertiaryCategoryName = '';
                    this.tertiarycategoryData = result;
                    this.tertiaryCategoryOptions.push({
                        label: '-- None --',
                        value: ''
                    });
                    for (let i = 0; i < result.length; i++) {
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
                    this.valuesObj.tertiaryCategoryValue = '';
                    this.valuesObj.tertiaryCategoryName = '';
                }
            }
            this.isSpinnerShow = false;
        }).catch(error => {
            this.error = error;
            this.isSpinnerShow = false;
        });
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


    /* Method to save the Case Record */
    handleSubmitRec(event) {
        try {
            this.disableSaveButton = true;
            this.isSpinnerShow = true;
            event.preventDefault();
            let fields = event.detail.fields;

            fields.AssetId = fields.Registration_No__c && this.assetData.find(item => item.Name.toLowerCase() === fields.Registration_No__c.toLowerCase()) ? this.assetData.find(item => item.Name.toLowerCase() === fields.Registration_No__c.toLowerCase()).Id : null;
            //Category Data//
            fields.Primary_Category_ID__c = this.valuesObj.primaryCategoryValue;
            fields.Primary_Category__c = this.valuesObj.primaryCategoryName;
            fields.Secondary_Category_ID__c = this.valuesObj.secondaryCategoryValue;
            fields.Secondary_Category__c = this.valuesObj.secondaryCategoryName;
            fields.Tertiary_Category__c = this.valuesObj.tertiaryCategoryName;
            fields.Tertiary_Category_ID__c = this.valuesObj.tertiaryCategoryValue;
            
            //Category Data//

            fields.Registration_No__c = fields.Registration_No__c ? fields.Registration_No__c.toUpperCase().replace(/ /g, "") : '';

            //Dealer data//
            fields.Dealer_Name__c = this.valuesObj.dealerOutletName;

            let dealerQCM = (this.dealerData.find(item => item.Id === this.valuesObj.dealerOutletName).Primary_Dealer_QCM__c);

            fields.Insurance_Direct_Case_Closure__c = this.insuranceDirectCaseClosure;
            fields.Insurance_Direct_Case_Closure_Email__c = this.insuranceDirectCaseClosureEmail;

            fields.RecordTypeId = this.recordTypeId;
            fields.Customer__c = this.customerEnquiryId ? this.customerEnquiryId : '';
            fields.contactId = this.valuesObj.contactId ? this.valuesObj.contactId : '';

            fields.Status = 'New';

            //EW & MCP Calculator changes
            fields.Veh_Odometer__c = this.vehicleodometer ? this.vehicleodometer : '';
            fields.MCP_Package_Name__c = this.packagename ? this.packagename : '';
            fields.VIN_No__c = this.vehiclevinnumber && (this.sourceCmp === 'EW Calculator' || this.sourceCmp === 'MCP Calculator') ? this.vehiclevinnumber : '';
            //EW & MCP Calculator changes

            if (this.valuesObj.businessArea === 'Sales' || this.valuesObj.businessArea === 'Accessories' || this.valuesObj.businessArea === 'Finance') {
                if (this.valuesObj.businessArea === 'Accessories' && this.fcrResponse === 'Yes') {
                    fields.OwnerId = currentUserId;
                    fields.Status = 'Resolved';
                } else {
                    fields.OwnerId = this.caseOwnerId;
                }
            } else if (this.valuesObj.businessArea === 'MIBPL (Insurance)') {
                if (this.insuranceAutoClosure) {
                    fields.OwnerId = currentUserId;
                    fields.Status = 'Closed';
                } else {
                    fields.OwnerId = this.caseOwnerId;
                }
            } else if (this.serviceAutoAssign && (this.valuesObj.businessArea === 'Service-Workshop' || this.valuesObj.businessArea === 'Service-Bodyshop')) {
                fields.OwnerId = this.serviceAutoAssign;
            } else {
                fields.OwnerId = this.caseOwnerId;
            }
            saveCaseRecord({
                caseJson: JSON.stringify(fields),
                primaryDealerQCM: dealerQCM,
                caseRecType: this.caseRecordTypeDevelopername
            }).then(result => {
                if (result) {
                    if (result && result.status === 'Success') {
                        this.handleSuccess(event);
                        if (result.createdId) {
                            this.navigateCmp('Case', result.createdId);
                        }
                    } else if (result.status === 'Error' && result.message) {
                        this.showErrorMessage(result.message);
                    } else {
                        this.handleError(event);
                    }
                } else {
                    this.handleError(event);
                }

            }).catch(error => {
                this.handleServerError(error);
            })


        } catch (e) {

            this.handleServerError(e);
        }
    }

    //Method to close the Case popup
    closeCreateCase() {
        if (this.sourceCmp === 'Service History') {
            this.navigateCmp('Account', this.customerEnquiryId);
        } else if (this.sourceCmp === 'Policy Search') {
            this.dispatchEvent(new CustomEvent('casecancel'));
        } else if (this.sourceCmp === 'EW Calculator' || this.sourceCmp === 'MCP Calculator') {
            this.navigateCmp('Account', this.customerEnquiryId);
        } else {
            this.dispatchEvent(new CustomEvent('closeCmp'));
        }

    }

    //Method to close the navigate to detail page
    navigateCmp(objectNAme, recId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recId,
                objectApiName: objectNAme, // objectApiName is optional
                actionName: "view"
            }
        });
        this.isSpinnerShow = false;
    }

    handleSuccess() {
        const toastEvt = new ShowToastEvent({
            "title": "Success!",
            "message": "Case has been created successfully!",
            "variant": "success"
        });
        this.dispatchEvent(toastEvt);

        this.handleReset();
        //this.isSpinnerShow = false;
        this.closeCreateCase();
    }
    handleError(event) {
        const toastEvt = new ShowToastEvent({
            "title": "Error Occured!",
            "message": "Case is not created, Please review your data once again",
            "variant": "error"
        });
        this.dispatchEvent(toastEvt);
        this.isSpinnerShow = false;
        this.disableSaveButton = false;
    }
    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }


    handleServerError(error) {
        var concatErrMessage = error.message + '. ' + Server_Error;
        this.showErrorMessage(concatErrMessage);
        console.error(error);
    }

    //method to show error toast message
    showErrorMessage(error) {
        this.showMessage("Something is wrong", error, "error");
        this.isSpinnerShow = false;
        this.disableSaveButton = false;
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
        this.dispatchEvent(new CustomEvent("closeCmp"));
    }

    //Method to auto assign Case owner on the basis of different LOB's
    handleSalesAccessorydata(businessAreaType) {
        this.isSpinnerShow = true;
        let oppId;
        let optyid = this.valuesObj.enquiryId;
        if (Array.isArray(optyid)) {
            oppId = this.valuesObj.enquiryId ? this.valuesObj.enquiryId[0] : '';
        } else {
            oppId = optyid;
        }
        fetchSalesAccessoryOwner({
            enquiryRecId: oppId,
            dealerId: this.valuesObj.dealerOutletName,
            businessArea: this.valuesObj.businessArea
        }).then(result => {
            this.salesAccessoryData = result;
            var arr = [];
            if (result) {
                if (businessAreaType === 'Sales') {
                    if (this.salesAccessoryData.enquiryOwner && this.salesAccessoryData.enquiryOwner.OwnerId) {
                        this.caseOwnerId = this.salesAccessoryData.enquiryOwner.OwnerId;
                        const submitBtn = this.template.querySelector('.submit-btn');
                        submitBtn.click();
                    } else if (this.salesAccessoryData.dealerdata && (this.salesAccessoryData.dealerdata.Sales_SPOC_1__c ||
                        this.salesAccessoryData.dealerdata.Sales_SPOC_2__c || this.salesAccessoryData.dealerdata.Sales_SPOC_3__c ||
                        this.salesAccessoryData.dealerdata.Sales_SPOC_4__c || this.salesAccessoryData.dealerdata.Sales_SPOC_5__c)) {
                        if (this.salesAccessoryData.dealerdata.Sales_SPOC_1__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Sales_SPOC_1__c);
                        }
                        if (this.salesAccessoryData.dealerdata.Sales_SPOC_2__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Sales_SPOC_2__c);
                        }
                        if (this.salesAccessoryData.dealerdata.Sales_SPOC_3__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Sales_SPOC_3__c);
                        }
                        if (this.salesAccessoryData.dealerdata.Sales_SPOC_4__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Sales_SPOC_4__c);
                        }
                        if (this.salesAccessoryData.dealerdata.Sales_SPOC_5__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Sales_SPOC_5__c);
                        }
                        if (arr.length > 0) {
                            this.caseOwnerId = arr[Math.floor(Math.random() * arr.length)];
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                        }

                    } else {
                        this.showErrorMessage(salesSPOCMissing);
                    }
                } else if (businessAreaType === 'Accessories') {
                    if (this.salesAccessoryData.dealerdata && (this.salesAccessoryData.dealerdata.Accessories_SPOC_1__c || this.salesAccessoryData.dealerdata.Accessories_SPOC_2__c)) {
                        if (this.salesAccessoryData.dealerdata.Accessories_SPOC_1__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Accessories_SPOC_1__c);
                        }
                        if (this.salesAccessoryData.dealerdata.Accessories_SPOC_2__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Accessories_SPOC_2__c);
                        }
                        if (arr.length > 0) {
                            this.caseOwnerId = arr[Math.floor(Math.random() * arr.length)];
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                        }
                    } else {
                        this.showErrorMessage(accessorySPOCMissing);
                    }
                } else if (businessAreaType === 'MIBPL (Insurance)') {
                    if (this.salesAccessoryData.dealerdata && (this.salesAccessoryData.dealerdata.Insurance_SPOC_1__c || this.salesAccessoryData.dealerdata.Insurance_SPOC_2__c)) {
                        if (this.salesAccessoryData.dealerdata.Insurance_SPOC_1__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Insurance_SPOC_1__c);
                        }
                        if (this.salesAccessoryData.dealerdata.Insurance_SPOC_2__c) {
                            arr.push(this.salesAccessoryData.dealerdata.Insurance_SPOC_2__c);
                        }
                        if (arr.length > 0) {
                            this.caseOwnerId = arr[Math.floor(Math.random() * arr.length)];
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                        }
                    } else {
                        this.manulOwnerAssign = true;
                        this.showErrorMessage('Please select Case Owner');
                    }
                }
            } else {
                this.showErrorMessage('Error occured Please try after sometime');
            }
        }).catch(error => {
            this.isSpinnerShow = false;
        })
    }

    //Mandatory Field and Case auto assign logic check
    saveCase() {
        try {
            if (this.validateInputs()) {
                if ((this.valuesObj.primaryCategoryName === 'EW' && this.sourceCmp !== 'EW Calculator') || (this.valuesObj.primaryCategoryName === 'MCP' && this.sourceCmp !== 'MCP Calculator')) {
                    this.showErrorMessage(emMCPerrMsg);
                } else {
                    if (this.valuesObj.businessArea === 'MIBPL (Insurance)') { //!this.caseOwnerId
                        let autoassignOwner = false;
                        if (this.valuesObj.tertiaryCategoryValue && (this.tertiarycategoryData.find(item => item.Id === this.valuesObj.tertiaryCategoryValue).Direct_Case_Closure__c) === true) {
                            autoassignOwner = true;
                        } else if (this.valuesObj.secondaryCategoryValue && (this.seconcategoryData.find(item => item.Id === this.valuesObj.secondaryCategoryValue).Direct_Case_Closure__c) === true) {
                            autoassignOwner = true;
                        } else if (this.valuesObj.primaryCategoryValue && (this.primcategoryData.find(item => item.Id === this.valuesObj.primaryCategoryValue).Direct_Case_Closure__c) === true) {
                            autoassignOwner = true;
                        }
                        if (autoassignOwner === true || this.fcrResponse === 'Yes') {
                            this.insuranceDirectCaseClosure = autoassignOwner === true ? autoassignOwner : false;
                            this.insuranceDirectCaseClosureEmail = autoassignOwner === true ? miEmail : '';
                            this.insuranceAutoClosure = true;
                            this.isSpinnerShow = true;
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                            } else if (autoassignOwner === false && this.fcrResponse === 'No' && !this.caseOwnerId) {
                            this.handleSalesAccessorydata('MIBPL (Insurance)');
                        } else {
                            this.isSpinnerShow = true;
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                        }
                    } else if (this.valuesObj.businessArea === 'Sales' || this.valuesObj.businessArea === 'Finance') {
                        if (!this.valuesObj.enquiryId && this.valuesObj.dealerOutletName && (this.valuesObj.caseType === 'Dealer Internal Complaint' || this.valuesObj.caseType === 'Dealer Internal Feedback') && !this.caseOwnerId) {
                            this.showErrorMessage('Please select Case Owner');
                        } else if (this.valuesObj.caseType === 'Dealer Internal Query' || this.valuesObj.enquiryId && (this.valuesObj.caseType === 'Dealer Internal Complaint' || this.valuesObj.caseType === 'Dealer Internal Feedback')) {
                            this.handleSalesAccessorydata('Sales');
                        } else {
                            this.isSpinnerShow = true;
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                        }
                    } else if (this.valuesObj.businessArea === 'Accessories' && this.fcrResponse === 'No') {
                        this.handleSalesAccessorydata('Accessories');
                    } else if ((this.valuesObj.businessArea === 'Service-Workshop' || this.valuesObj.businessArea === 'Service-Bodyshop') && !this.caseOwnerId) {
                        let profileName = caseAutoAssignService.split(';');
                        let serviceCCM = (this.dealerData.find(item => item.Id === this.valuesObj.dealerOutletName).Service_CCM__c);
                        if (profileName.includes(this.agentProfileName) && serviceCCM) {
                            this.serviceAutoAssign = serviceCCM;
                            this.isSpinnerShow = true;
                            const submitBtn = this.template.querySelector('.submit-btn');
                            submitBtn.click();
                        } else {
                            this.manulOwnerAssign = true;
                            this.showErrorMessage('Please select Case Owner');
                        }
                    } else {
                        this.isSpinnerShow = true;
                        const submitBtn = this.template.querySelector('.submit-btn');
                        submitBtn.click();
                    }
                }
            } else {
                this.showErrorMessage('Required Fields are missing');
            }
        } catch (error) {
            this.handleServerError(error);
        }

    }
}