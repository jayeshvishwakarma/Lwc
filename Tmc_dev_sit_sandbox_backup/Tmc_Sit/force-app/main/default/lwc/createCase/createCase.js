import { LightningElement,api,wire,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getPicklistValues } from 'lightning/uiObjectInfoApi'; // Added for Suzuki Connect to get picklist (by Sunit)
import { getObjectInfo } from 'lightning/uiObjectInfoApi' // Added for getting object detail (Suzuki connect by Sunit)
import Case from '@salesforce/schema/Case' // Added for getting object detail (Suzuki connect by Sunit)
import getSuzukiConnectConstant from '@salesforce/apex/ProjectUtility.getConstantValue'; // Added for getting custom setting detail (Suzuki connect by Sunit)
import getOnloadInfo from '@salesforce/apex/CreateCaseController.getOnloadInfoForCase';
import getObjects from '@salesforce/apex/CreateCaseController.getObjects';
import getCategoryRecordsApex from '@salesforce/apex/CreateCaseController.getCategoryRecordsApex';
import getCaseInfo from '@salesforce/apex/CreateCaseController.getCaseInfo';
import getCaseRecordTypeApex from '@salesforce/apex/CreateCaseController.getCaseRecordType';
import getDealerDetails from '@salesforce/apex/CreateCaseController.getDealerInfo';
import caseNumberLength from '@salesforce/label/c.Case_Number_Length';
import caseUpdateProfiles from '@salesforce/label/c.Case_Update_Profiles';

import createCase from '@salesforce/apex/CreateCaseController.createCase';
import suzukiConnectPrimaryCategoryErrorMessage from '@salesforce/label/c.Suzuki_Connect_Primary_Check_Error_Message'; // Added for Suzuki Connect (by Sunit)
import STATE from '@salesforce/schema/Case.State__c';

export default class CreateCase extends NavigationMixin(LightningElement) {
    mainCss = ' slds-brand-band slds-brand-band_narrow slds-template_default forceBrandBand slds-p-around_none';
    isFormReadyToShow = false;
    @api sObjectName = 'Case';
    @api parentRecordId;
    @api caseId;
    /****** Added by Sunit for Suzuki connect ******/
    @api suzukiConnectAssetData; // JIT data for Asset(Suzuki Connect) added by Sunit
    recordTypeList; // This will contain all record type detail of Case Object added by Sunit
    @api sourceCmp; // This will contain Cmp Name from where it is getting called added Nitin
    suzukiConnectType=false;
    tcuDealerPhone;
    vinReadonly=false;
    stateList;
    /***********************************************/
    recordTypeId;
    existingCaseNumber;
    isExistingCaseNumberShow = false;
    isDescriptionDisabled = false;
    caseNumberLength =  caseNumberLength;
    isKnowledgeRequired =  false;
    error;
    caseStageDisabled = true; //Special case
    isCaseStageRequired = true;
    // caseRecordTypeOptions ;
    personAccount;
    enquiry;
    dealerSelectionMatrices;
    isMobileDevice = false;
    isSpinnerShow = true;
    cancelButtonLabel = 'Cancel';
    newCaseLabel = 'New Case';
    defaultCaseStatus = 'Open';
    caseFieldNames;
    valuesObj = {};

    businessAreaOptions;
    channelCaseTypeVsBusinessAreasMap;
    businessAreaValueDisabled = true;

    businessAreaWithCaseStage; // GITIKA
    businessAreaWithCaseStageLength = 0;
    @track category = {};
    categoryQuery;

    dealerQuery;
    selectedDealer;
    selectedDealerName;
    selectedDealerId;
    isDealerFieldShow = false;
    dealerRecordTypeName = 'Dealer';
    isTopManagementExecutiveDisabled = true;
    isFieldChangeReady = false;
    
    isPrimaryRequired = true;
    isSecondaryRequired = false;
    isTertiaryRequired = false;
    serviceHistoryJsonObj ;
    /******** Added for getting object detail (Suzuki connect by Sunit) ********/
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATE})
    typePicklistValuesState({error, data}){
        if (data) {
            console.log('Inside typePicklistValuesState');
            this.stateList=data;
            console.log(this.stateList);
        } else if(error){
            console.log('Inside error');
        }
    }
    @wire(getObjectInfo, {
        objectApiName: Case
    })
    getObjectDetails({
        error,
        data
    }) {
        if (data) {
            this.recordTypeList = data.recordTypeInfos;
            // perform your custom logic here
        } else if (error) {
            // perform your logic related to error 
        }
    };
    /**************************************************************************/
    connectedCallback() {
        //this.checkAndSetCaseId();
       // if (!this.caseId) { // Only for Create Case
            this.setConstantFieldNames();
            this.setCategories();
            this.checkForMobileDevice();
            this.getOnloadInfo();
            this.suzukiConnectDetails();
            if(this.parentRecordId &&  this.parentRecordId.length  > 18){
               console.log(typeof this.parentRecordId);
                //if(typeof this.parentRecordId === 'object'){
                   this.serviceHistoryJsonObj = JSON.parse(this.parentRecordId)['createFrom'] && JSON.parse(this.parentRecordId).createFrom === 'ServiceHistory' ? JSON.parse(this.parentRecordId) : undefined;
                   if(this.serviceHistoryJsonObj && this.serviceHistoryJsonObj['asset']){
                    this.valuesObj.enquiryVehicleRegistrationNumber = this.serviceHistoryJsonObj.asset.Registration_Number__c;
                    this.valuesObj.enquiryVINNumber = this.serviceHistoryJsonObj.asset.VIN__c;
                    this.valuesObj.channelValue = this.serviceHistoryJsonObj.asset.Product2Id ? this.serviceHistoryJsonObj.asset.Product2.LOB__c :undefined;
                    this.valuesObj.enquiryVariantId = this.serviceHistoryJsonObj.asset.Product2Id;
                    this.valuesObj.enquiryModel = this.serviceHistoryJsonObj.asset.Model_Code__c;
                //}                  
                   console.log('Service History loaded');
                   console.log(this.serviceHistoryJsonObj);
               }
             }
        //}
    }
    /******** Added for getting dealership detail (Suzuki connect by Sunit) ********/
    suzukiConnectDetails() {
        if (this.suzukiConnectAssetData) {
            this.valuesObj.tcuCustomerCountry='India';
            this.vinReadonly=true;
            this.suzukiConnectType=true;
            console.log(this.suzukiConnectAssetData.dealerCode);
            let dealerAPIDetails = this.suzukiConnectAssetData.dealerCode.split('_');
            console.log(dealerAPIDetails);
            getDealerDetails({
                    'externalId': this.suzukiConnectAssetData.dealerCode
                })
                .then(result => {
                    console.log(result);
                    if (result) {
                        this.setDealerInfo(result);
                        this.tcuDealerPhone=result.Phone;
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.isSpinnerShow = false;
                });
        }
    }
    /********************************************************************************/
    /* Onload functions */
    checkAndSetCaseId() {
        if (this.caseId) {
            this.mainCss = ' slds-brand-band slds-template_default slds-p-around_none';
            this.cancelButtonLabel = 'Close';
            this.newCaseLabel = 'Edit Case';
        }
    }
    setConstantFieldNames() {
        this.caseFieldNames = {}
        let fieldNames = {};
        fieldNames.channel = 'Channel__c';
        fieldNames.caseType = 'Case_Type__c';
        fieldNames.businessArea = 'Business_Area__c';
        fieldNames.caseStage = 'Case_Stage__c';
        fieldNames.model = 'Model__c';
        fieldNames.mode = 'Mode__c';
        fieldNames.outletType = 'Outlet_Type__c';
        fieldNames.regionCode = 'Region_Code__c';
        fieldNames.city = 'For_Code__c';
        fieldNames.dealerName = 'Dealer_Name__c';
        fieldNames.primaryCategory = 'Primary_Category__c';
        fieldNames.secondaryCategory = 'Secondary_Category__c';
        fieldNames.tertiaryCategory = 'Tertiary_Category__c';
        fieldNames.bookingNo = 'Booking_No__c';
        fieldNames.invoiceNo = 'Invoice_No__c';
        fieldNames.enquiry = 'Enquiry__c';
        fieldNames.dealerType = 'Dealer_Type__c';
        fieldNames.dealerCode = 'Dealer_Code__c';
        fieldNames.variant = 'Variant__c';

        fieldNames.fCRConducted = 'FCR_Conducted__c';
        this.caseFieldNames = fieldNames;
    }
    setCategories() {
        this.category = {
            primaryCategoryOptions: [],
            primaryCategoryValue: undefined,
            isPrimaryCategoryDisabled: true,
            secondaryCategoryOptions: [],
            secondaryCategoryValue: undefined,
            isSecondaryCategoryDisabled: true,
            tertiaryCategoryOptions: [],
            tertiaryCategoryValue: undefined,
            isTertiaryCategoryDisabled: true
        };
    }
    checkForMobileDevice() {
        // Mobile device check
        let mobileCheck = function() {
            let check = false;
            (function(a) {
                if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true;
            })(navigator.userAgent || navigator.vendor || window.opera);
            return check;
        };
        this.isMobileDevice = mobileCheck();
    }
    getOnloadInfo() {
        try {
            this.error = '';
            this.isSpinnerShow = true;
            getOnloadInfo({
                    parentRecordId: this.parentRecordId,
                    caseId: this.caseId
                })
                .then(result => {
                    if (result) {
                        console.log('getOnloadInfo Result ::', result);
                        this.valuesObj.caseTypeValue = 'Complaint';
                        console.log(result.currentUserProfileName);
                        this.channelCaseTypeVsBusinessAreasMap = result.channelCaseTypeVsBusinessAreasMap;
                        if(result.currentUserProfileName){
                            this.isExistingCaseNumberShow = caseUpdateProfiles.split(',').includes(result.currentUserProfileName)?true:false;
                        console.log(this.isExistingCaseNumberShow);
                        }
                        if (result.personAccount) {
                            this.personAccount = result.personAccount;
                            this.setCustomInfo();
                        }
                        
                        if (result.enquiry) {
                            this.enquiry = result.enquiry;
                            this.setEnquiryInfo();
                        }
                        
                        if (result.dealerSelectionMatrices) {
                            this.dealerSelectionMatrices = result.dealerSelectionMatrices;
                        }
                       
                        if (result.businessAreaWithCaseStage) {
                            this.businessAreaWithCaseStage = result.businessAreaWithCaseStage;
                        }
                    
                        if(result.dealerAccount){
                            this.setDealerInfo(result.dealerAccount);
                        }
                       
                        if(result.caseObj){
                            this.setCaseObjInfo(result.caseObj);
                        }
                        // Added by Najab Maghirbi 12-November-2020
                        //console.log('Result by najab ==> ', result);
                        //console.log('surveyTakerCustomer by najab ==> ', result.surveyTakerCustomer);
                        if (result.surveyTakerCustomer) {
                            this.setCustomerDetailInfo(result.surveyTakerCustomer);
                        }
                        if (result.category) {
                            this.setCategoryInfo(result.category);
                        }
                       
                        this.isFormReadyToShow = true;
                        // Setting the default value only for on load;
                        //  this.valuesObj.caseTypeValue = 'Complaint';
                        this.isDealerFieldShow = true;
                        this.setBusinessAreaOptions();// For Case created from API's
                    }
                    this.isSpinnerShow = false;
                    
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (error && Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (error && typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in getOnloadInfo JS method');
            console.log(e.message);
        }
    }
    setCustomInfo() {
        if (this.personAccount) {
            if (this.personAccount.FirstName) {
                this.valuesObj.customerFirstName = this.personAccount.FirstName;
            }
            if (this.personAccount.LastName) {
                this.valuesObj.customerLastName = this.personAccount.LastName;
            }
            if (this.personAccount.PersonMobilePhone) {
                this.valuesObj.customerMobile = this.personAccount.PersonMobilePhone;
            }
            if (this.personAccount.PersonEmail) {
                this.valuesObj.customerEmail = this.personAccount.PersonEmail;
            }
        }
    }
    setDealerInfo(dealerAccount){
        // Specific when populating the dealer from Customer History
        if(dealerAccount.Id){
           // console.log('dealer Id '+dealerAccount.Id);
            if(dealerAccount.Channel__c){
                if(dealerAccount.Channel__c === 'NRM'){
                    //this.valuesObj.channelValue =  'Arena';
                }else if(dealerAccount.Channel__c === 'EXC'){
                    //this.valuesObj.channelValue =  'Nexa';
                }
            }
            this.selectedDealerId = dealerAccount.Id;
            this.selectedDealerName = dealerAccount.Name;
            this.valuesObj.cityValue = dealerAccount.For_Code__c;
            this.valuesObj.regionCodeValue = dealerAccount.Region_Code__c;
            this.valuesObj.dealerCode = this.getDealerCode(dealerAccount);
            this.setDealerAddress(dealerAccount);
            this.valuesObj.dealerZone = dealerAccount.Zone__c;
            this.setOutletType(dealerAccount);
        }
    }
    getDealerCode(dealerAccount){
        let dealerCode = '';
        dealerCode = dealerAccount.Dealer_Code__c ? dealerAccount.Dealer_Code__c : '' ;
        dealerCode += dealerAccount.Outlet_Code__c ? '-'+ dealerAccount.Outlet_Code__c : '' ;
        dealerCode += dealerAccount.For_Code__c ? '-'+ dealerAccount.For_Code__r.For_Code__c : '' ;
        return dealerCode;
    }
    setEnquiryInfo() {
        if (this.enquiry) {
            if (this.enquiry.First_Name__c) {
                this.valuesObj.customerFirstName = this.enquiry.First_Name__c;
            }
            if (this.enquiry.Last_Name__c) {
                this.valuesObj.customerLastName = this.enquiry.Last_Name__c;
            }
            if (this.enquiry.Mobile__c) {
                this.valuesObj.customerMobile = this.enquiry.Mobile__c;
            }
            if (this.enquiry.Email__c) {
                this.valuesObj.customerEmail = this.enquiry.Email__c;
            }
            // enquiry info
            if (this.enquiry.Booking_Number__c) {
                this.valuesObj.enquiryBookingNumber = this.enquiry.Booking_Number__c;
            }
            if (this.enquiry.Invoice_Number__c) {
                this.valuesObj.enquiryInvoiceNumber = this.enquiry.Invoice_Number__c;
            }
            if (this.enquiry.Model_Code__c) {
                this.valuesObj.enquiryModel = this.enquiry.Model_Code__c;
            }
            if (this.enquiry.Variant__c) {
                this.valuesObj.enquiryVariantId = this.enquiry.Variant__c;
            }
            if (this.enquiry.Color__c) {
                this.valuesObj.enquiryColorId = this.enquiry.Color__c;
            }
            if (this.enquiry.Vehicle_Registration__c) {
                this.valuesObj.enquiryVehicleRegistrationNumber = this.enquiry.Vehicle_Registration__c;
            }
            if (this.enquiry.VIN__c) {
                this.valuesObj.enquiryVINNumber = this.enquiry.VIN__c;
            }
            if (this.enquiry.Id) {
                this.valuesObj.enquiryId = this.enquiry.Id;
            }
            if (this.enquiry.Dealership__c) {
                this.selectedDealerId = this.enquiry.Dealership__c;
                this.selectedDealerName = this.enquiry.Dealership__r.Name;
                this.valuesObj.cityValue = this.enquiry.Dealership__r.For_Code__c;
                this.valuesObj.regionCodeValue = this.enquiry.Dealership__r.Region_Code__c;
                this.valuesObj.dealerType = this.enquiry.Dealership__r.Dealer_Type__c;
                this.valuesObj.dealerCode = this.getDealerCode(this.enquiry.Dealership__r);
                this.setDealerAddress(this.enquiry.Dealership__r);
                if (this.enquiry.Dealership__r.Zone__c) {
                    this.valuesObj.dealerZone = this.enquiry.Dealership__r.Zone__c;
                }

                this.setOutletType(this.enquiry.Dealership__r);
            }
            /* Channel value auto populate */
            if (this.enquiry.OwnerId && this.enquiry.Owner.Channel__c) {
                //const channel = this.dealerSelectionMatrices.find( ({ Channel_Short_Code__c }) => Channel_Short_Code__c === this.enquiry.Dealership_Channel__c);
               this.valuesObj.channelValue = this.enquiry.Owner.Channel__c;
            }else if (this.enquiry.Dealership_Channel__c ) {
                this.valuesObj.channelValue = this.enquiry.Dealership_Channel__c;
            }
            console.log('enquiry default values set');
        }
    }
    setOutletType(dealer){
        let outletType = '';
        if(dealer.Dealer_Type__c){
            if(dealer.Dealer_Type__c === 'M'){
                outletType = 'MASS';
            }
            if(dealer.Dealer_Type__c === '3S'){
                if(dealer.Channel__c === 'NRM'){
                    outletType =  'Arena Sales Outlets';
                }else if(dealer.Channel__c === 'EXC'){
                    outletType =  'Nexa Sales Outlets';
                }else if(dealer.Channel__c === 'COM' || dealer.Channel__c === 'NRC'){
                    outletType = 'Commercial Sales Outlets' ;
                }
            }
            if(dealer.Dealer_Type__c === '2S'){
                if(dealer.Channel__c === 'NRM'){
                    outletType =  'Arena WS';
                }else if(dealer.Channel__c === 'EXC'){
                    outletType =  'Nexa WS';
                }
            }
            if(dealer.Dealer_Type__c === 'S'){
                if(dealer.Channel__c === 'NRM'){
                    outletType =  'Arena Sales Outlets';
                }else if(dealer.Channel__c === 'EXC'){
                    outletType =  'Nexa Sales Outlets';
                }else if(dealer.Channel__c === 'COM' || dealer.Channel__c === 'NRC'){
                    outletType = 'Commercial Sales Outlets' ;
                }
            }
            if(dealer.Dealer_Type__c === 'TV'){
                outletType = 'TV';
            }
        }else if(dealer.Channel__c){
            if(dealer.Channel__c === 'NRM' && dealer.Dealer_Category__c && dealer.Dealer_Category__c === 'DDT'){
                outletType = 'Parts Distributor';
            }else if(dealer.Channel__c === 'MDS'){
                outletType = 'MSDS';
            }
        }
        console.log('outletType '+outletType);
        this.valuesObj.outletTypeValue = outletType;
    }
    setDealerAddress(dealer){
        this.valuesObj.dealerBillingStreet = dealer.BillingStreet;
        this.valuesObj.dealerBillingCity = dealer.BillingCity;
        this.valuesObj.dealerBillingCountry = dealer.BillingCountry;
        this.valuesObj.dealerBillingState = dealer.BillingState;
        this.valuesObj.dealerBillingPostalCode = dealer.BillingPostalCode;
    }
    setCaseObjInfo(caseObj){
        this.caseId = caseObj.Id;
        this.valuesObj.channelValue = caseObj.Channel__c;
        this.valuesObj.caseTypeValue = caseObj.Case_Type__c;
        this.valuesObj.businessAreaValue = caseObj.Business_Area__c;
        this.valuesObj.caseStageValue = caseObj.Case_Stage__c;
        this.valuesObj.outletTypeValue = caseObj.Outlet_Type__c;
        this.valuesObj.cityValue = caseObj.For_Code__c;

        this.valuesObj.enquiryModel = caseObj.Model__c;
        this.valuesObj.enquiryVariantId = caseObj.Variant__c;
        this.valuesObj.enquiryColorId = caseObj.Color__c;
        // make dealerQueryReady
        this.updateDealerQuery('onload');
    }
    // Populate Survey Taker Customer Detail Info Added by Najab Maghirbi 23-October-2020
    setCustomerDetailInfo(surveyTakerCustomer) {
        if (surveyTakerCustomer.customerDetail) {
            for (let k in surveyTakerCustomer.surveyCaseMappingRecords) {
                if (surveyTakerCustomer.surveyCaseMappingRecords[k].Source_field__c == 'First_Name__c' && (surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == 'All' || surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == surveyTakerCustomer.customerDetail.survey__r.Type)) {
                    this.valuesObj.customerFirstName = surveyTakerCustomer.customerDetail.First_Name__c;
                }
                if (surveyTakerCustomer.surveyCaseMappingRecords[k].Source_field__c == 'Middle_Name__c' && (surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == 'All' || surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == surveyTakerCustomer.customerDetail.survey__r.Type)) {
                    this.valuesObj.customerMiddleName = surveyTakerCustomer.customerDetail.Middle_Name__c;
                }
                if (surveyTakerCustomer.surveyCaseMappingRecords[k].Source_field__c == 'Last_Name__c' && (surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == 'All' || surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == surveyTakerCustomer.customerDetail.survey__r.Type)) {
                    this.valuesObj.customerLastName = surveyTakerCustomer.customerDetail.Last_Name__c;
                }
                if (surveyTakerCustomer.surveyCaseMappingRecords[k].Source_field__c == 'Email__c' && (surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == 'All' || surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == surveyTakerCustomer.customerDetail.survey__r.Type)) {
                    this.valuesObj.customerEmail = surveyTakerCustomer.customerDetail.Email__c;
                }
                if (surveyTakerCustomer.surveyCaseMappingRecords[k].Source_field__c == 'Mobile_Number__c' && (surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == 'All' || surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == surveyTakerCustomer.customerDetail.survey__r.Type)) {
                    this.valuesObj.customerMobile = surveyTakerCustomer.customerDetail.Mobile_Number__c;
                }
                if (surveyTakerCustomer.surveyCaseMappingRecords[k].Source_field__c == 'Survey_Taker_Dealer_Channel__c' && (surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == 'All' || surveyTakerCustomer.surveyCaseMappingRecords[k].Survey_type__c == surveyTakerCustomer.customerDetail.survey__r.Type)) {
                    this.valuesObj.channelValue = surveyTakerCustomer.customerDetail.Survey_Taker_Dealer_Channel__c;
                }
                if(this.parentRecordId != null){
                    this.valuesObj.surveyTakerId = this.parentRecordId;
                }
                console.log('Survey Taker Id => ' , this.parentRecordId);
            }
        }
    }
    setCategoryInfo(category) {
        if (category.primaryCategoryOptions) {
            this.category.primaryCategoryOptions = category.primaryCategoryOptions;
            this.category.primaryCategoryValue = category.primaryCategoryValue;
            this.valuesObj.primaryCategoryValue = category.primaryCategoryValue;
            this.category.isPrimaryCategoryDisabled = false;
        }
        if(category.secondaryCategoryOptions){
            this.category.secondaryCategoryOptions = category.secondaryCategoryOptions;
            this.category.secondaryCategoryValue = category.secondaryCategoryValue;
            this.valuesObj.secondaryCategoryValue = category.secondaryCategoryValue;
            this.category.isSecondaryCategoryDisabled = false;
        }
        if(category.tertiaryCategoryOptions){
            this.category.tertiaryCategoryOptions= category.tertiaryCategoryOptions;
            this.category.tertiaryCategoryValue = category.tertiaryCategoryValue;
            this.valuesObj.tertiaryCategoryValue = category.tertiaryCategoryValue;
            this.category.isTertiaryCategoryDisabled = false;
        }
    }
    sourceChange(event) {
        let sourceValue = event.detail.value;
        if (sourceValue === 'Top Management') {
            this.isTopManagementExecutiveDisabled = false;
            this.valuesObj.topManagementFlagValue = true;
        } else {
            this.valuesObj.topManagementExecutiveValue = '';
            this.isTopManagementExecutiveDisabled = true;
            this.valuesObj.topManagementFlagValue = false;
        }
        if (sourceValue === 'NCH') {
            this.valuesObj.NCHFlagValue = true;
        } else {
            this.valuesObj.NCHFlagValue = false;
        }
        if (sourceValue === 'Social') {
            this.valuesObj.SocialMediaFlagValue = true;
        } else {
            this.valuesObj.SocialMediaFlagValue = false;
        }
    }
    /* Field change functions */
    handleFieldChange(event) {
        try {
            let fieldName = event.target.name;
            let fieldValue = event.detail.value;
            /******** Added for primary category check (Suzuki connect by Sunit) ********/
            let selectedPrimaryCat='';
            if(fieldName==='Primary_Category__c'){
                selectedPrimaryCat=this.category.primaryCategoryOptions.find(element=>element.value===fieldValue).label;
            }
            if(fieldName==='TCU_Customer_State__c'){
                this.valuesObj.tcuCustomerState=fieldValue;
            }
            if(!this.suzukiConnectAssetData && fieldName==='Primary_Category__c' && selectedPrimaryCat==='Suzuki Connect Product Complaint'){
                this.category.primaryCategoryValue=undefined;
                this.valuesObj.primaryCategoryValue=undefined;
                this.category.secondaryCategoryOptions=[];
                this.showToast('Error',suzukiConnectPrimaryCategoryErrorMessage,'error');
            }
            /****************************************************************************/
            else{
                if(fieldValue) {
                this.isFieldChangeReady = true;
                }
                if (fieldName && this.isFieldChangeReady) {
                    this.setValueInObject(fieldName, fieldValue);
                    // Special Case
                    this.caseStageDisabled = false;
                    this.isCaseStageRequired = true;
                    if (this.valuesObj.businessAreaValue) {
                        this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
                        console.log(this.businessAreaWithCaseStageLength);
                        if(this.businessAreaWithCaseStageLength == 0){
                            this.valuesObj.caseStageValue = ''
                            this.caseStageDisabled = true;
                            this.isCaseStageRequired = false;
                        }
                    }
                    if (this.valuesObj.caseTypeValue === 'MSIL Query') {
                        console.log('Special condition true');
                        this.valuesObj.caseStageValue = ''
                        this.caseStageDisabled = true;
                        this.isCaseStageRequired = false;
                    }  
                    this.checkAndSetCategoryChange(fieldName);
                    this.updateDealerQuery(fieldName);
                    this.setBusinessAreaOptions();
                
                    // Make KB Article required
                    // if(fieldName === this.caseFieldNames.fCRConducted && fieldValue ==='Yes'){
                    //     this.isKnowledgeRequired = true;
                    // } else if(fieldName === this.caseFieldNames.fCRConducted && fieldValue !=='Yes'){
                    //     this.isKnowledgeRequired = false;
                    // }

                }
            }

        } catch (e) {
            console.log(e.message);
        }
    }
    setBusinessAreaOptions(){
        if(this.valuesObj.channelValue && this.valuesObj.caseTypeValue){
            let key = this.valuesObj.channelValue + '_' + this.valuesObj.caseTypeValue;
            let list = this.channelCaseTypeVsBusinessAreasMap[key];
            let objList = [];
             for(let i = 0 ;  i < list.length ; i++){
                 let obj = {};
                 obj.label = list[i];
                 obj.value = list[i];
                 objList.push(obj);
            }
            this.businessAreaOptions = objList;
            this.businessAreaValueDisabled = objList.length > 0 ? false :true;
        }
    }
    setValueInObject(fieldName, fieldValue) {
        // Values setting only for the fields which all are taking part in dependency
       
        if (fieldName == this.caseFieldNames.channel) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.channelValue = fieldValue;
                this.valuesObj.caseTypeValue = '';
                this.valuesObj.businessAreaValue = '';
                this.valuesObj.caseStageValue = '';
                this.businessAreaOptions = [];
                this.businessAreaValueDisabled = true;
            } else {
                this.valuesObj.channelValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.caseType) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.caseTypeValue = fieldValue;
                this.valuesObj.businessAreaValue = '';
                this.valuesObj.caseStageValue = '';
                this.businessAreaOptions = [];
                this.businessAreaValueDisabled = true;
            } else {
                this.valuesObj.caseTypeValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.businessArea) {
            if (fieldValue) {
                this.valuesObj.businessAreaValue = fieldValue;
                this.valuesObj.caseStageValue = '';
                this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
                if (this.businessAreaWithCaseStageLength === 0) {
                    this.valuesObj.caseStageValue = undefined;
                }
            } else {
                this.valuesObj.businessAreaValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.caseStage) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.caseStageValue = fieldValue;
            } else {
                this.valuesObj.caseStageValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.outletType) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.outletTypeValue = fieldValue;
            } else {
                this.valuesObj.outletTypeValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.regionCode) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.regionCodeValue = fieldValue;
            } else {
                this.valuesObj.regionCodeValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.city) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.cityValue = Object.values(fieldValue)[0];
            } else {
                this.valuesObj.cityValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.dealerName) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.dealerNameValue = fieldValue;
            } else {
                this.valuesObj.dealerNameValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.primaryCategory) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.primaryCategoryValue = fieldValue;
            } else {
                this.valuesObj.primaryCategoryValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.secondaryCategory) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.secondaryCategoryValue = fieldValue;
            } else {
                this.valuesObj.secondaryCategoryValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.tertiaryCategory) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.tertiaryCategoryValue = fieldValue;
            } else {
                this.valuesObj.tertiaryCategoryValue = undefined;
            }
        } else if (fieldName == this.caseFieldNames.enquiry) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.enquiryValue = fieldValue;
            } else {
                this.valuesObj.enquiryValue = undefined;
            }
        }else if (fieldName == this.caseFieldNames.model) {
            if (fieldValue && fieldValue !== '') {
                this.valuesObj.enquiryModel = fieldValue;
            } else {
                this.valuesObj.enquiryModel = undefined;
            }
        }
    }
    checkAndSetCategoryChange(fieldName) {
        let categoryParentChange = false;
        if (this.valuesObj.businessAreaValue) {
            this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
        }
        if (fieldName === this.caseFieldNames.channel || fieldName === this.caseFieldNames.caseType) {
            this.setCaseRecordType();
        }
        if (fieldName === this.caseFieldNames.channel || fieldName === this.caseFieldNames.caseType ||
            fieldName === this.caseFieldNames.businessArea || fieldName === this.caseFieldNames.caseStage) {
            categoryParentChange = true;
        }
        // If changed to blank
        if (categoryParentChange && (!this.valuesObj.channelValue || !this.valuesObj.businessAreaValue ||
                !this.valuesObj.caseTypeValue || (this.valuesObj.businessAreaValue && this.businessAreaWithCaseStageLength > 0 && !this.valuesObj.caseStage))) {
            this.resetDependentCategory('allThree');
        }
        if (categoryParentChange) {
             this.resetDependentCategory('allThree');
            if (this.businessAreaWithCaseStageLength > 0) {
                this.setCategoryQuery(this.caseFieldNames.caseStage);
            } else {
                this.setCategoryQuery(this.caseFieldNames.businessArea);
            }
        } else if (fieldName === this.caseFieldNames.primaryCategory) {
            this.resetDependentCategory('lastTwo');
            this.setCategoryQuery(this.caseFieldNames.primaryCategory);
        } else if (fieldName === this.caseFieldNames.secondaryCategory) {
            this.resetDependentCategory('lastOne');
            this.setCategoryQuery(this.caseFieldNames.secondaryCategory);
        }

    }
    resetDependentCategory(resetType) {
       
        if (resetType === 'allThree') { // primary, secondary and tertiary reset 
            this.category.primaryCategoryOptions = [];
            this.category.primaryCategoryValue = '';
            this.category.isPrimaryCategoryDisabled = true;
            this.category.secondaryCategoryOptions = [];
            this.category.secondaryCategoryValue = undefined;
            this.category.isSecondaryCategoryDisabled = true;
            this.category.tertiaryCategoryOptions = [];
            this.category.tertiaryCategoryValue = undefined;
            this.category.isTertiaryCategoryDisabled = true;
            this.valuesObj.primaryCategoryValue = undefined;
            this.valuesObj.secondaryCategoryValue = undefined;
            this.valuesObj.tertiaryCategoryValue = undefined;

        } else if (resetType === 'lastTwo') { // secondary and tertiary reset 
            this.category.secondaryCategoryOptions = [];
            this.category.secondaryCategoryValue = undefined;
            this.category.isSecondaryCategoryDisabled = true;
            this.category.tertiaryCategoryOptions = [];
            this.category.tertiaryCategoryValue = undefined;
            this.category.isTertiaryCategoryDisabled = true;
            this.valuesObj.secondaryCategoryValue = undefined;
            this.valuesObj.tertiaryCategoryValue = undefined;        

        } else if (resetType === 'lastOne') { // only tertiary reset 
            this.category.tertiaryCategoryOptions = [];
            this.category.tertiaryCategoryValue = undefined;
            this.category.isTertiaryCategoryDisabled = true;
            this.valuesObj.tertiaryCategoryValue = undefined;        
        }
    }
    setCategoryQuery(fieldName) {
        console.log(fieldName);
        let clause = '';
        this.categoryQuery = 'SELECT Name FROM Category__c WHERE Active__c = true';
        clause = this.valuesObj.channelValue;
        clause += '_' + this.valuesObj.caseTypeValue;
        clause += this.valuesObj.businessAreaValue ? '_' + this.valuesObj.businessAreaValue :'';

        console.log(this.categoryQuery);
        if (fieldName === this.caseFieldNames.businessArea && this.businessAreaWithCaseStageLength === 0) {
            clause += '_Primary';
            this.categoryQuery += ' AND External_ID_Query__c =' + "'" + clause + "'";
        } else if (fieldName === this.caseFieldNames.caseStage) {
            //clause += !this.caseStageDisabled ? '_' + this.valuesObj.caseStageValue : '';
            if (this.valuesObj.caseStageValue) {
                clause += '_' + this.valuesObj.caseStageValue;
                
            }
           // clause += this.valuesObj.caseStageValue ?  '_' + this.valuesObj.caseStageValue : '';
            clause += '_Primary';
            this.categoryQuery += ' AND External_ID_Query__c =' + "'" + clause + "'";
        
        } else if (fieldName === this.caseFieldNames.primaryCategory) {
            if (this.valuesObj.caseStageValue) {
                clause += '_' + this.valuesObj.caseStageValue;
            }
            clause += '_Secondary_' + this.valuesObj.primaryCategoryValue;
            this.categoryQuery += ' AND External_ID_Query__c =' + "'" + clause + "'";

        } else if (fieldName === this.caseFieldNames.secondaryCategory) {
            if (this.valuesObj.caseStageValue) {
                clause += '_' + this.valuesObj.caseStageValue;
            }
            clause += '_Tertiary_' + this.valuesObj.primaryCategoryValue;
            clause += '_' + this.valuesObj.secondaryCategoryValue;
            this.categoryQuery += ' AND External_ID_Query__c =' + "'" + clause + "'";
        } else {
            this.categoryQuery = undefined;
        }
        if (this.categoryQuery) {
            this.getCategoryRecords(this.categoryQuery, fieldName);
        }
    }
    getCategoryRecords(categoryQuery, fieldName) {
        try {
            console.log(categoryQuery);
            this.error = '';
            this.isSpinnerShow = true;
            getCategoryRecordsApex({
                    'query': categoryQuery
                })
                .then(result => {
                    console.log(result);
                    if (result) {
                        console.log(fieldName);
                        if (fieldName === this.caseFieldNames.businessArea || fieldName === this.caseFieldNames.caseStage) {
                            this.category.primaryCategoryOptions = result;
                            if (result.length > 0) {
                                this.category.isPrimaryCategoryDisabled = false;
                            }
                        } else if (fieldName === this.caseFieldNames.primaryCategory) {
                            this.category.secondaryCategoryOptions = result;
                            if (result.length > 0) {
                                this.category.isSecondaryCategoryDisabled = false;
                            }
                        } else if (fieldName === this.caseFieldNames.secondaryCategory) {
                            this.category.tertiaryCategoryOptions = result;
                            if (result.length > 0) {
                                this.category.isTertiaryCategoryDisabled = false;
                            }
                        }
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in getCategoryRecords JS method');
            console.log(e.message);
        }
    }
    setCaseRecordType() {
        try {
            let caseType = this.valuesObj.caseTypeValue;
            if (!caseType) {
                return;
            }
            if (caseType.includes('/')) {
                caseType = caseType.replace('/', '');
            }
            this.error = '';
            this.isSpinnerShow = true;
            getCaseRecordTypeApex({
                    'caseType': caseType
                })
                .then(result => {
                    console.log('getCaseRecordTypeApex ' + result);
                    if (result) {
                        this.recordTypeId = result;
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in getCaseRecordType JS method');
            console.log(e.message);
        }
    }
    /* Dealer related functions */
    updateDealerQuery(fieldName) {
    
        // For Dealer Reset
        if (fieldName === 'onload' ||fieldName === this.caseFieldNames.outletType || fieldName === this.caseFieldNames.city) {
            if(fieldName !== 'onload'){
                this.resetDealer();
            }
            this.dealerQuery = undefined;
            this.dealerQuery = 'SELECT Name,Type,Dealer_Code__c,Region_Code__c,City__c,Dealer_Type__c,BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode,Zone__c,Outlet_Code__c,For_Code__r.For_Code__c FROM Account';
            this.dealerQuery += ' WHERE RecordType.Name =' + "'" + this.dealerRecordTypeName + "'";

            if (this.valuesObj.cityValue && this.valuesObj.outletTypeValue) {
                this.dealerQuery += ' AND For_Code__c =' + "'" + this.valuesObj.cityValue + "'";
                let whereClause = this.getDealerFilterQuery();
                if (whereClause && whereClause !== '') {
                    this.dealerQuery += whereClause;
                }
            } else {
                this.dealerQuery = undefined;
            }
        }
    }
    getDealerFilterQuery() {
        let whereClause = '';
        const selectedMatrix = this.dealerSelectionMatrices.find(dealerSelectionMatrix => dealerSelectionMatrix.Outlet_Type__c === this.valuesObj.outletTypeValue);
        // console.log(selectedMatrix);
        let getFilterValue = (name, value) => {
            let returnValue;
            let valuesOptions = value.split(",");
            returnValue = valuesOptions.length > 1 ? '(' : '';
            valuesOptions.forEach((value, index) => {
                returnValue = index === 0 ? returnValue += name + '=' + "'" + value + "'" : returnValue += ' OR ' + name + ' =' + "'" + value + "'";
            });
            returnValue += valuesOptions.length > 1 ? ')' : '';
            return returnValue;
        };
        if (selectedMatrix) {
            if (selectedMatrix.Dealer_Channel__c) {
                whereClause += ' AND ' + getFilterValue('Channel__c', selectedMatrix.Dealer_Channel__c);
            }
            if (selectedMatrix.Dealer_Category__c) {
                whereClause += ' AND ' + getFilterValue('Dealer_Category__c', selectedMatrix.Dealer_Category__c);
            }
            if (selectedMatrix.Dealer_Type__c) {
                whereClause += ' AND ' + getFilterValue('Dealer_Type__c', selectedMatrix.Dealer_Type__c);
            }
        }
        return whereClause;
    }
    resetDealer() {
        console.log('reset dealer called')
        this.selectedDealer = undefined;
        this.isDealerFieldShow = false;
        this.valuesObj.dealerType = '';
        this.valuesObj.dealerCode = '';
        this.selectedDealerId = undefined;
        this.valuesObj.dealerBillingStreet = '';
        this.valuesObj.dealerBillingCity = '';
        this.valuesObj.dealerBillingCountry = '';
        this.valuesObj.dealerBillingState ='';
        this.valuesObj.dealerBillingPostalCode = '';

        this.valuesObj.dealerZone = '';
        setTimeout(f => {
            this.isDealerFieldShow = true;
        }, 0);

    }
    handleLookupChange(event) {
        try {
            let txt = JSON.stringify(event.detail);
           // console.log(txt);
            this.selectedDealer = JSON.parse(txt);
            this.valuesObj.dealerCode = '';
            this.valuesObj.dealerType = '';
            this.valuesObj.regionCodeValue = '';
            this.valuesObj.dealerZone = '';
            this.valuesObj.dealerBillingStreet = '';
            this.valuesObj.dealerBillingCity = '';
            this.valuesObj.dealerBillingCountry = '';
            this.valuesObj.dealerBillingState = '';
            this.valuesObj.dealerBillingPostalCode = '';
            this.selectedDealerId = undefined;
            let address = '';
            if (this.selectedDealer && this.selectedDealer.Id) {
                this.selectedDealerId = this.selectedDealer.Id;
                if (this.selectedDealer.Dealer_Code__c) {
                    this.valuesObj.dealerCode = this.getDealerCode(this.selectedDealer); 
                }
                if (this.selectedDealer.Dealer_Type__c) {
                    this.valuesObj.dealerType = this.selectedDealer.Dealer_Type__c;
                }
                if (this.selectedDealer.Region_Code__c) {
                    this.valuesObj.regionCodeValue = this.selectedDealer.Region_Code__c;
                }
                if (this.selectedDealer.Zone__c) {
                    this.valuesObj.dealerZone = this.selectedDealer.Zone__c;
                }
                
                this.valuesObj.dealerBillingStreet = this.selectedDealer.BillingStreet;
                this.valuesObj.dealerBillingCity = this.selectedDealer.BillingCity;
                this.valuesObj.dealerBillingCountry = this.selectedDealer.BillingCountry;
                this.valuesObj.dealerBillingState = this.selectedDealer.BillingState;
                this.valuesObj.dealerBillingPostalCode = this.selectedDealer.BillingPostalCode;
                if(this.selectedDealer.BillingStreet){
                    address += this.selectedDealer.BillingStreet;
                }
                if(this.selectedDealer.BillingStreet){
                    address += ', ' + this.selectedDealer.BillingCity;
                }
                if(this.selectedDealer.BillingStreet){
                    address += ', ' + this.selectedDealer.BillingState;
                }
                if(this.selectedDealer.BillingStreet){
                    address += ', ' + this.selectedDealer.BillingCountry;
                }
                if(this.selectedDealer.BillingStreet){
                    address += ', ' + this.selectedDealer.BillingPostalCode;
                }
            }
            this.valuesObj.dealerAddress = address;
        } catch (e) {
            console.log(e.message);
        }
    }
    /* submit functions */
    handleSubmit(event) {
        try {
            let allValid = true;
            event.preventDefault();
            let fields = event.detail.fields;
			if(this.valuesObj.enquiryVariantId!=undefined)
            fields.Variant__c=this.valuesObj.enquiryVariantId;
            fields.Primary_Category_ID__c = this.valuesObj.primaryCategoryValue;
            fields.Secondary_Category_ID__c = this.valuesObj.secondaryCategoryValue;
            fields.Tertiary_Category_ID__c = this.valuesObj.tertiaryCategoryValue;
            
            let categoryFieldCheck = this.customFieldsRequiredCheck('lightning-combobox');

            if (!categoryFieldCheck) {
                allValid = false;
                return;
            }
            if (!this.valuesObj.primaryCategoryValue) {
                console.log('Please select Primary category');
                this.showToast('Error','Please Select Primary Category','error');
                return;
            }
            if (!this.valuesObj.secondaryCategoryValue && this.category.secondaryCategoryOptions && this.category.secondaryCategoryOptions.length > 0) {
                console.log('Please select Secondary category');
                this.showToast('Error','Please Select Secondary Category','error');
                return;
            }
            if (!this.valuesObj.tertiaryCategoryValue && this.category.tertiaryCategoryOptions && this.category.tertiaryCategoryOptions.length > 0) {
                console.log('Please select Tertiary category');
                this.showToast('Error','Please Select Tertiary Category','error');
                return;
            }
            fields = this.setDefaultValues(fields);
            /** Category fields check */
            
            /** Dealers fields check */
            if (!this.selectedDealer) {
                const dealer = this.template.querySelector('c-create-case-look-up');
                //  allValid = dealer.checkRequired();
            }
            if (!allValid) {
                return;
            }
            if(this.serviceHistoryJsonObj){
                fields =  this.setValuesFromServiceHistoryJsonObj(fields);
            }
            this.isSpinnerShow = true;
            /***** Added for Suzuki connect by Sunit *****/
            if (this.sourceCmp === 'Suzuki Connect Child Case' && this.caseId) {
                fields.ParentId = this.caseId;
                fields.Id = undefined;
            }else if(this.caseId){
                fields.Id = this.caseId;
            }
            if (this.suzukiConnectAssetData && (fields.Primary_Category__c === 'Suzuki Connect Product Complaint' ||
                    fields.Primary_Category__c === 'Suzuki Connect Sales Related' ||
                    fields.Primary_Category__c === 'Suzuki Connect Dealer Assistance')) {
                getSuzukiConnectConstant({
                    'name': 'Suzuki Connect'
                })
                .then(result => {
                    console.log('getSuzukiConnectConstant ' + result);
                    if (result) {
                        console.log(result);
                        for (var eachRecordtype in this.recordTypeList) {
                            console.log(this.recordTypeList[eachRecordtype].name);
                            if (this.recordTypeList[eachRecordtype].name === 'Suzuki Connect') {
                                fields.RecordTypeId = this.recordTypeList[eachRecordtype].recordTypeId;
                            }
                        }
                        fields.IMEI_No__c = this.suzukiConnectAssetData.tcuImeiNumber;
                        fields.Sim_No__c = this.suzukiConnectAssetData.tcuSimNumber;
                        let tcuExpDate = this.suzukiConnectAssetData.serviceEndDate.split('\/');
                        fields.TCU_Expiry_Date__c = tcuExpDate[2] + '-' + tcuExpDate[1] + '-' + tcuExpDate[0];
                        let tcuSalDate = this.suzukiConnectAssetData.tcuSaleDate.split('\/');
                        fields.TCU_Sale_Date__c = tcuSalDate[2] + '-' + tcuSalDate[1] + '-' + tcuSalDate[0];
                        fields.TCU_Customer_Name__c = this.suzukiConnectAssetData.custName;
                        fields.VIN_No__c = this.suzukiConnectAssetData.vin;
                        fields.Odometer_Reading__c = this.suzukiConnectAssetData.odometerReading;
                        fields.Model__c = this.suzukiConnectAssetData.modelCode;
                        fields.TCU_Dealer_Code__c = this.suzukiConnectAssetData.mulDealerCode;
                        fields.TCU_Dealer_Name__c = this.suzukiConnectAssetData.dealerName;
                        let serviceActDate = this.suzukiConnectAssetData.servActiveDate.split('\/');
                        fields.Service_Activation_Date__c = serviceActDate[2] + '-' + serviceActDate[1] + '-' + serviceActDate[0];
                        fields.TCU_Service_Status__c = this.suzukiConnectAssetData.tcuServiceStatus;
                        fields.TCU_Dealer_Address__c = this.suzukiConnectAssetData.dealerAddress;
                        fields.Dealer_Phone__c=this.tcuDealerPhone;
                        fields.Customer_Address__c=this.suzukiConnectAssetData.custAddress;
                        fields.EntitlementId = result.EntitlementId__c; // Meed to be put in custom label
                        fields.Status = 'Assigned to Panasonic';
                        fields.TCU_Customer_State__c=this.valuesObj.tcuCustomerState;
                        //console.log('Submitting this one ', JSON.stringify(fields));
                        this.createCaseApex(JSON.stringify(fields));
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                });
                
            }
            else{
                console.log('Submitting this one ', JSON.stringify(fields));
                this.createCaseApex(JSON.stringify(fields));
            }
            /*****************************************************/

            //console.log('Submitting this one ', JSON.stringify(fields));
            //this.createCaseApex(JSON.stringify(fields));
            //this.template.querySelector('lightning-record-edit-form').submit(fields);
        } catch (e) {
            console.log(e.message);
            this.isSpinnerShow = false;
        }
    }
    setDefaultValues(fields) {
        fields.Status = this.defaultCaseStatus;
        if (!fields.ContactId && this.personAccount) {
           // fields.ContactId = this.personAccount.PersonContactId; 
        }
        if (this.personAccount) {
            fields.Customer__c = this.personAccount.Id;
        }if (this.enquiry ) {
            fields.Customer__c = this.enquiry.Customer__c;
        }
        //Set Dealer Related fields
        if (this.selectedDealer) {
            fields.Dealer_Name__c = this.selectedDealer.Id;
        }
        fields = this.setCategoryValues(fields);
        // Map Case RecordTypeId
        if (this.recordTypeId) {
            fields.RecordTypeId = this.recordTypeId;
        }
        return fields;
    }
    setCategoryValues(fields) {
        console.log(this.valuesObj.primaryCategoryValue);
        if (this.valuesObj.primaryCategoryValue) {
            const primaryCategoryObj = this.category.primaryCategoryOptions.find(primaryCategoryObj => primaryCategoryObj.value === this.valuesObj.primaryCategoryValue);
            fields.Primary_Category__c = primaryCategoryObj.label;
        }
        if (this.valuesObj.secondaryCategoryValue) {
            const secondaryCategoryObj = this.category.secondaryCategoryOptions.find(secondaryCategoryObj => secondaryCategoryObj.value === this.valuesObj.secondaryCategoryValue);
            fields.Secondary_Category__c = secondaryCategoryObj.label;
        }
        console.log('---',this.valuesObj.tertiaryCategoryValue);
        if (this.valuesObj.tertiaryCategoryValue) {
            const tertiaryCategoryObj = this.category.tertiaryCategoryOptions.find(tertiaryCategoryObj => tertiaryCategoryObj.value === this.valuesObj.tertiaryCategoryValue);
            fields.Tertiary_Category__c = tertiaryCategoryObj.label;
        }
        return fields;
    }
    customFieldsRequiredCheck(chkField) {
        const allValid = [...this.template.querySelectorAll(chkField)]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }
    handleSuccess(id) {
        let updatedRecord = id;//event.detail.id;
        console.log(updatedRecord);
        let message =  "Case has been created successfully!";
        if (this.caseId) {
            if (this.sourceCmp === 'Suzuki Connect Child Case') {
                message = "Case has been created successfully!";
            } else {
                message = "Case has been updated successfully!";
            }
        }
        this.showToast('Success',message,'success');
        if (this.sourceCmp !== 'Suzuki Connect Child Case') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: updatedRecord,
                    objectApiName: this.sObjectName,
                    actionName: 'view'
                }
            });
        }
        const closeQA = new CustomEvent('close', {
            detail: {
                caseId: updatedRecord
            }
        });
        this.dispatchEvent(closeQA);
        //this.handleReset(event);
        this.isSpinnerShow = false;


    }
    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
    handleError(event) {
        this.isSpinnerShow = false;
        this.showToast(event.detail.message,event.detail.detail,'error');
        // console.log(JSON.stringify(event.detail));
       // console.log(JSON.stringify(event.detail.message));
      //  console.log(JSON.stringify(event.detail.output.fieldErrors));
        //console.log(JSON.stringify(event.detail.output.errors));
    }
    handleOnload(event) {
        console.log('onload');
        // this.isSpinnerShow = false;


    }
    closeModal(event) {
        try {
            this.handleReset(event);
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);

        } catch (e) {
            console.log(e.message);
        }
    }
    saveCase() {
        const submitBtn = this.template.querySelector('.submit-btn');
        submitBtn.click();
    }
    loadExistingCase(event){
        try {
            let caseNumber = event.target.value;
            // console.log(caseNumber);
            if (caseNumber) {
                if (caseNumber.length != this.caseNumberLength) {
                   // console.log('return false');
                    this.valuesObj.description = '';
                    this.caseId = undefined;
                    this.isDescriptionDisabled = false;
                    return;
                }
                this.isSpinnerShow = true;
                getCaseInfo({
                        caseId: caseNumber,
                        isEmailCase :  true
                    })
                    .then(result => {
                        this.isSpinnerShow = false;
                        if (result && result.Description ) {
                            this.valuesObj.description = result.Description;
                            this.caseId = result.Id;
                            this.valuesObj.channelValue = '';
                            this.valuesObj.caseTypeValue = '';
                            this.isDescriptionDisabled = true;
                            this.showToast('Success','Case details loaded','success');
                            return;
                        }
                        this.showToast('Error','No Records Found.','error');
                    })
                    .catch(error => {
                        this.error = error;
                        console.log(JSON.stringify(error));
                        if (error && Array.isArray(error.body)) {
                            this.error = error.body.map(e => e.message).join(', ');
                        } else if (error && typeof error.body.message === 'string') {
                            this.error = error.body.message;
                        }
                        this.isSpinnerShow = false;
                    });
            }
        } catch (e) {
            console.log('Exception in loadExistingCase JS method');
            console.log(e.message);
        }

    }
    showToast(title,message,type){
        const toastEvt = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": type
        });
        this.dispatchEvent(toastEvt);
    }
    createCaseApex(caseObjString){
       // console.log(caseObjString);
        try {
            this.error = '';
            this.isSpinnerShow = true;
            createCase({
                    caseString: caseObjString,
                    parentRecordId : this.parentRecordId
                })
                .then(result => {
                    console.log('createCase Result ::', result);
                    if (result) {
                        this.handleSuccess(result);
                    }
                    this.isSpinnerShow = false;
                })
                .catch(error => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    if (error && Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } else if (error && typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    this.showToast('Error', this.error,'error');
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in createCaseApex JS method');
            console.log(e.message);
        }
    }
    setValuesFromServiceHistoryJsonObj(fields){
       
        // Setting Values From Asset Object
        if(this.serviceHistoryJsonObj['asset']){
            fields.AssetId = this.serviceHistoryJsonObj.asset.Id;
            fields.Vehicle_Sale_Date__c = this.serviceHistoryJsonObj.asset.Date_of_Vehicle_Purchase__c; 
            fields.Registration_No__c = this.serviceHistoryJsonObj.asset.Registration_Number__c;
            fields.Chassis_Number__c = this.serviceHistoryJsonObj.asset.Chassis_Number__c;
            //fields.Variant_Description__c  = this.serviceHistoryJsonObj.asset.Registration_Number__c; /// No Asset Field
        }
        fields.Last_PSF_Status__c = this.serviceHistoryJsonObj['psfStatus'] ? this.serviceHistoryJsonObj['psfStatus'] : undefined;
        fields.Preferred_SA__c = this.serviceHistoryJsonObj['serviceAdvisorName'] ? this.serviceHistoryJsonObj['serviceAdvisorName'] : undefined;
        fields.Vehicle_Model_Description__c = this.serviceHistoryJsonObj['model'] ? this.serviceHistoryJsonObj['model'] : undefined;
        //fields.technicianName = this.serviceHistoryJsonObj['technicianName'] ? this.serviceHistoryJsonObj['technicianName'] : undefined;
        fields.Last_Service_Mileage__c = this.serviceHistoryJsonObj['mileage'] ? this.serviceHistoryJsonObj['mileage'] : undefined;
        fields.Customer__c = this.serviceHistoryJsonObj['personAccountId'] ? this.serviceHistoryJsonObj['personAccountId'] : undefined;
        console.log('field mapped with Service History');
        return fields;

    }
    handleCustomSearch(event){
        try{
            let searchKey  = event.detail.searchTerm;
            if(!this.valuesObj.enquiryModel){
                return;
            }
            let query = 'Select Id,Name from Product2 ';
            query += 'WHERE Model__c = \'' + this.valuesObj.enquiryModel + '\'';
            let rcType = 'Variants';
            query += ' AND RecordType.DeveloperName = \'' + rcType + '\'';
            console.log(query);
            console.log(searchKey);
            getObjects({
                'query': query,
                'searchKey': searchKey
            })
            .then(result => {
                //c/changeOwnerCaseLWCconsole.log(result);
                    if (result &&result.length > 0) {
                    let list = [];
                    result = JSON.parse(result);
                    for(let i = 0 ; i < result.length  ; i++){
                        let obj= {};
                        obj.id = result[i].Id;
                        obj.title = result[i].Name;
                        list.push(obj);
                    }
                    let lookup = this.template.querySelectorAll('c-lookup-input-field');
                    //for (i = 0; i < lookup.length; i++) {
                      //  if(lookup[i].label == 'Variant'){
                            lookup[0].updateSearchResults(list);
                       // }
                    //}
                }
                
            })
            .catch(error => {
                this.error = error;
                console.log('error ',JSON.stringify(error));
                if (Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (error.body && typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                this.isSpinnerShow = false;
            });
        }catch(e){
            console.log(e.message);
        }
    }
    handleAssetFilterChange(event) {
        this.valuesObj.enquiryVariantId = undefined;
        if(event.detail.value){
            this.valuesObj.enquiryVariantId = event.detail.value;
        }
    }
    handleColorCustomSearch(event){
        try{
            let searchKey  = event.detail.searchTerm;
            if(!this.valuesObj.enquiryVariantId){
                return;
            }
            let query = 'Select Id,Name from Color_Variant_Master__c ';
            query += 'WHERE Variant__c = \'' + this.valuesObj.enquiryVariantId + '\'';
            let rcType;
            getObjects({
                'query': query,
                'searchKey': searchKey
            })
            .then(result => {
                    if (result &&result.length > 0) {
                    let list = [];
                    result = JSON.parse(result);
                    for(let i = 0 ; i < result.length  ; i++){
                        let obj= {};
                        obj.id = result[i].Id;
                        obj.title = result[i].Name;
                        list.push(obj);
                    }
                    let lookup = this.template.querySelectorAll('c-lookup-input-field');
                   // for (i = 0; i < lookup.length; i++) {
                       // if(lookup[i].label == 'Color'){
                            lookup[1].updateSearchResults(list);
                        //}
                    //}
                }
                
            })
            .catch(error => {
                this.error = error;
                console.log('error ',JSON.stringify(error));
                if (Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (error.body && typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                this.isSpinnerShow = false;
            });
        }catch(e){
            console.log(e.message);
        }
    }
    handleColorFilterChange(event){
        this.valuesObj.enquiryColorId = undefined;
        if(event.detail.value){
            this.valuesObj.enquiryColorId = event.detail.value;
        }
    }
}