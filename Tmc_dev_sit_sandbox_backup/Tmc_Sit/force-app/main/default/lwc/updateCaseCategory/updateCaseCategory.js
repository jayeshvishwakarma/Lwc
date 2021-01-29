import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOnloadInfo from '@salesforce/apex/CreateCaseController.getOnloadInfoForCaseAction';
import getCategoryRecordsApex from '@salesforce/apex/CreateCaseController.getCategoryRecordsApex';
import updateCase from '@salesforce/apex/CreateCaseController.updateCase';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class updateCaseCategory extends NavigationMixin(LightningElement) {
    // variables for Case Update
    @api caseId;
    // variables for Case Actions Update and insert
    @api caseActionId;
    @api parentCaseId;
    defaultCaseActionStatus = '';
    defaultCaseActionName = 'Transfer';

    // Common variables
    caseStageDisabled = false; //Special case
    isCaseStageRequired = true;

    dealerSelectionMatrices = [];
    caseActionTransferRecordTypeId;
    caseObj;
    isMobileDevice = false;
    isSpinnerShow = true;
    fieldNames= {};
    valuesObj ={};

    businessAreaOptions;
    channelCaseTypeVsBusinessAreasMap;
    businessAreaValueDisabled = false;

    businessAreaWithCaseStage; // GITIKA
    businessAreaWithCaseStageLength = 0; 
    category = {}; 
    categoryQuery;
    dealerQuery;
    selectedDealer;
    selectedDealerId;
    selectedDealerName;
    isDealerFieldShow= false;
    dealerRecordTypeName = 'Dealer';

    // logged-in user info
    currentLoggedInUser = 'System Administrator';
    isAssignedApprover = true;
    isRMManager = false;

    allFieldsIsReadOnly = false;
    isFieldsReadyToChange = false;

    caseStageOptions = [];

    connectedCallback(){
        this.setCategories();
        this.setConstantFieldNames();
        this.checkForMobileDevice();
        this.getOnloadInfo();
    }
    /* Onload functions */
    setConstantFieldNames(){
        let fieldNames ={};
        fieldNames.channel = 'Channel__c';
        fieldNames.caseType = 'Case_Type__c';
        fieldNames.businessArea = 'Business_Area__c';
        fieldNames.caseStage = 'Case_Stage__c';
        fieldNames.outletType = 'Outlet_Type__c' ;
        fieldNames.city = 'For_Code__c'; 
        fieldNames.dealerName = 'Dealer_Name__c';
        fieldNames.primaryCategory = 'Primary_Category__c';
        fieldNames.secondaryCategory = 'Secondary_Category__c';
        fieldNames.tertiaryCategory = 'Tertiary_Category__c';
        this.fieldNames = fieldNames;
    }
    setCategories(){
        this.category = {
            primaryCategoryOptions : [],
            primaryCategoryValue : undefined,
            isPrimaryCategoryDisabled : true,
            secondaryCategoryOptions : [],
            secondaryCategoryValue : undefined,
            isSecondaryCategoryDisabled : true,
            tertiaryCategoryOptions : [],
            tertiaryCategoryValue : undefined,
            isTertiaryCategoryDisabled : true
        };
    }
    checkForMobileDevice(){
        // Mobile device check
        let mobileCheck = function() {
           let check = false;
           (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
           return check;
         };
       this.isMobileDevice = mobileCheck();
    }
    getOnloadInfo(){
        try{
            //console.log('caseActionId   ' + this.caseActionId);
            //console.log('parentCaseId  '  + this.parentCaseId);
            this.isSpinnerShow = true;
            getOnloadInfo({
                parentCaseId : this.parentCaseId,
                caseActionId : this.caseActionId,
                caseId : this.caseId
            })
            .then(result => {
                if (result) {
                    console.log('getOnloadInfo Result ::',result);
                    this.channelCaseTypeVsBusinessAreasMap = result.channelCaseTypeVsBusinessAreasMap;

                    if(result.dealerSelectionMatrices){
                        this.dealerSelectionMatrices = result.dealerSelectionMatrices;
                    }
                    if(result.caseActionTransferRecordTypeId){
                        this.caseActionTransferRecordTypeId = result.caseActionTransferRecordTypeId;
                        this.valuesObj.caseTypeValue = 'Complaint';
                    }
                    if(result.caseObj){
                        this.caseObj = result.caseObj;
                        this.setCaseActionValueFromCase(result.caseObj);
                    }
                    else if(result.caseActions){
                        this.setCaseActionValue(result.caseActions);
                    }
                    if(result.businessAreaWithCaseStage){
                        this.businessAreaWithCaseStage = result.businessAreaWithCaseStage;
                    }
                    if(result.category){
                        this.setCategoryOnload(result.category);
                    }
                    if(result.currentLoggedInUser){
                        this.setLoggedInUser(result.currentLoggedInUser);
                    }
                }
                this.isDealerFieldShow = true;
                this.isSpinnerShow = false;
                this.setBusinessAreaOptions();
                this.setCaseStageOption();
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
        }catch(e){
            console.log('Exception in getOnloadInfo JS method');
            console.log(e.message);
        }
    }
    setCaseActionValue(caseActions){
        if(caseActions.Channel__c){
            this.valuesObj.channelValue = caseActions.Channel__c;
        }
        if(caseActions.Case_Type__c){
            this.valuesObj.caseTypeValue = caseActions.Case_Type__c;
        }
        if(caseActions.Business_Area__c){
            this.valuesObj.businessAreaValue = caseActions.Business_Area__c;
        }
        if(caseActions.Case_Stage__c){
            this.valuesObj.caseStageValue = caseActions.Case_Stage__c;
        }
        if(!caseActions.Case_Stage__c){
            this.caseStageDisabled = true;
            this.isCaseStageRequired = false;
        }
        if(caseActions.Outlet_Type__c){
            this.valuesObj.outletTypeValue = caseActions.Outlet_Type__c;
        }
        if(caseActions.For_Code__c){
            this.valuesObj.cityValue = caseActions.For_Code__c;
        }
        if(caseActions.Dealer_Name__c){
            this.selectedDealerId = caseActions.Dealer_Name__c;
            this.selectedDealerName = caseActions.Dealer_Name__r.Name;
            this.valuesObj.regionCodeValue  = caseActions.Dealer_Name__r.Region_Code__c;
            this.valuesObj.dealerCode  = caseActions.Dealer_Name__r.Dealer_Code__c;
            this.valuesObj.dealerZone = caseActions.Dealer_Name__r.Zone__c;
            this.valuesObj.dealerBillingStreet = caseActions.Dealer_Name__r.BillingStreet;
            this.valuesObj.dealerBillingCity = caseActions.Dealer_Name__r.BillingCity;
            this.valuesObj.dealerBillingCountry = caseActions.Dealer_Name__r.BillingCountry;
            this.valuesObj.dealerBillingState =  caseActions.Dealer_Name__r.BillingState;
            this.valuesObj.dealerBillingPostalCode = caseActions.Dealer_Name__r.BillingPostalCode;
        }
        if(caseActions.Id){
            this.caseActionId = caseActions.Id;
        }
        if(caseActions.RecordTypeId){
            this.caseActionTransferRecordTypeId = caseActions.RecordTypeId;
        }
        if(caseActions.Approval_Status__c == 'Approved'){
            this.allFieldsIsReadOnly = true;
        }else{
            this.updateDealerQuery('onload');
        }
    }
    setCaseActionValueFromCase(caseObj){
        if(caseObj.Channel__c){
            this.valuesObj.channelValue = caseObj.Channel__c;
        }
        if(caseObj.Case_Type__c){
            this.valuesObj.caseTypeValue = caseObj.Case_Type__c;
        }
        if(caseObj.Business_Area__c){
            this.valuesObj.businessAreaValue = caseObj.Business_Area__c;
            this.setBusinessAreaOptions();
        }
        if(caseObj.Case_Stage__c){
            
            this.valuesObj.caseStageValue = caseObj.Case_Stage__c;
        }
        if(!caseObj.Case_Stage__c){
            this.caseStageDisabled = true;
            this.isCaseStageRequired = false;
        }
        if(caseObj.Outlet_Type__c){
            this.valuesObj.outletTypeValue = caseObj.Outlet_Type__c;
        }
        if(caseObj.For_Code__c){
            this.valuesObj.cityValue = caseObj.For_Code__c;
        }
        if(caseObj.Dealer_Name__c){
            this.selectedDealerId = caseObj.Dealer_Name__c;
            this.selectedDealerName = caseObj.Dealer_Name__r.Name;
            this.valuesObj.dealerCode  = caseObj.Dealer_Name__r.Dealer_Code__c;
            this.valuesObj.regionCodeValue  = caseObj.Dealer_Name__r.Region_Code__c;
            this.valuesObj.dealerZone = caseObj.Dealer_Name__r.Zone__c;
            this.valuesObj.dealerBillingStreet = caseObj.Dealer_Name__r.BillingStreet;
            this.valuesObj.dealerBillingCity = caseObj.Dealer_Name__r.BillingCity;
            this.valuesObj.dealerBillingCountry = caseObj.Dealer_Name__r.BillingCountry;
            this.valuesObj.dealerBillingState = caseObj.Dealer_Name__r.BillingState;
            this.valuesObj.dealerBillingPostalCode = caseObj.Dealer_Name__r.BillingPostalCode;
        }
        this.updateDealerQuery('onload');  
    }
    setCategoryOnload(category){
        if(category.primaryCategoryOptions && category.primaryCategoryOptions.length > 0){
            this.category.primaryCategoryOptions =  category.primaryCategoryOptions;
            this.category.isPrimaryCategoryDisabled =  false;
        }if(category.primaryCategoryValue){
            this.category.primaryCategoryValue =  category.primaryCategoryValue;
            this.valuesObj.primaryCategoryValue =  category.primaryCategoryValue;
        }
        if(category.secondaryCategoryOptions  && category.secondaryCategoryOptions.length > 0 ){
            this.category.secondaryCategoryOptions =  category.secondaryCategoryOptions;
            this.category.isSecondaryCategoryDisabled =  false;
        }if(category.secondaryCategoryValue){
            this.category.secondaryCategoryValue =  category.secondaryCategoryValue;
            this.valuesObj.secondaryCategoryValue =  category.secondaryCategoryValue;
        }
        if(category.tertiaryCategoryOptions  && category.tertiaryCategoryOptions.length > 0){
            this.category.tertiaryCategoryOptions =  category.tertiaryCategoryOptions;
            this.category.isTertiaryCategoryDisabled =  false;
        }if(category.tertiaryCategoryValue){
            this.category.tertiaryCategoryValue =  category.tertiaryCategoryValue;
            this.valuesObj.tertiaryCategoryValue =  category.tertiaryCategoryValue;
        }
    }
    setLoggedInUser(currentLoggedInUser){
        if(this.caseActionId){
            if(currentLoggedInUser === 'Assigned Approver'){
                this.isAssignedApprover = true;
            }else if(currentLoggedInUser === 'RM Manager'){
                this.isRMManager = true;
                this.isAssignedApprover = false;
            }else{
                // for admin
            }
        }
    }
    /* Field change functions */
    handleFieldChange(event){
        try{         
            let fieldName = event.target.name;
            let fieldValue = event.detail.value;
            console.log(fieldValue);
            if(fieldValue){
                this.isFieldsReadyToChange = true;
            }
            if(fieldName && this.isFieldsReadyToChange){
                this.setValueInObject(fieldName,fieldValue);
              
                 // Special Case
                 this.caseStageDisabled = false;
                 this.isCaseStageRequired = true;
                 this.caseStageOptions = [];
                 if (this.valuesObj.businessAreaValue) {
                    this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue] ? this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length : 0;
                   
                    console.log(this.businessAreaWithCaseStageLength);
                    if(this.businessAreaWithCaseStageLength == 0){
                        this.valuesObj.caseStageValue = ''
                        this.caseStageDisabled = true;
                        this.isCaseStageRequired = false;
                    }else {
                        this.setCaseStageOption();
                    }
                }
                if (this.valuesObj.caseTypeValue === 'MSIL Query') {
                    console.log('Special condition true');
                    this.valuesObj.caseStageValue = ''
                    this.caseStageDisabled = true;
                    this.isCaseStageRequired = false;
                }  
                //this.setValueInObject(fieldName,fieldValue);
             
                this.checkAndSetCategoryChange(fieldName);
             
                this.updateDealerQuery(fieldName);
                this.setBusinessAreaOptions();
            }
           // console.log(this.valuesObj);
        }catch(e){
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
    setCaseStageOption(){
        let options = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue];
        let optionsList =[];
        options.forEach(option => {
            let obj = {};
            obj.label = option;
            obj.value = option;
            optionsList.push(obj);
        });
        this.caseStageOptions = optionsList;
    }
    setValueInObject(fieldName,fieldValue){
        // Values setting only for the fields which all are taking part in dependency
        if(fieldName == this.fieldNames.channel){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.channelValue = fieldValue;
                //this.businessAreaOptions = [];
                this.businessAreaValueDisabled = true;
            }else{
                this.valuesObj.channelValue = undefined;
            }
        }else if(fieldName == this.fieldNames.caseType){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.caseTypeValue = fieldValue;
                this.businessAreaOptions = [];
                this.businessAreaValueDisabled = true;
            }else{
                this.valuesObj.caseTypeValue = undefined;
            }
        }else if(fieldName == this.fieldNames.businessArea){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.businessAreaValue = fieldValue;
                this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue] ? this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length : 0;

                //this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
                if(this.businessAreaWithCaseStageLength === 0){
                    this.valuesObj.caseStageValue = undefined;
                }
            }else{
                this.valuesObj.businessAreaValue = undefined;
            }
        }else if(fieldName == this.fieldNames.caseStage){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.caseStageValue = fieldValue;
            }else{
                this.valuesObj.caseStageValue = undefined;
            }
        }else if(fieldName == this.fieldNames.outletType){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.outletTypeValue = fieldValue;
            }else{
                this.valuesObj.outletTypeValue = undefined;
            }
        }else if(fieldName == this.fieldNames.city){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.cityValue = Object.values(fieldValue)[0];
            }else{
                this.valuesObj.cityValue = undefined;
            }
        }else if(fieldName == this.fieldNames.primaryCategory){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.primaryCategoryValue = fieldValue;
            }else{
                this.valuesObj.primaryCategoryValue = undefined;
            }
        }else if(fieldName == this.fieldNames.secondaryCategory){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.secondaryCategoryValue = fieldValue;
            }else{
                this.valuesObj.secondaryCategoryValue = undefined;
            }
        }else if(fieldName == this.fieldNames.tertiaryCategory){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.tertiaryCategoryValue = fieldValue;
            }else{
                this.valuesObj.tertiaryCategoryValue = undefined;
            }
        }
    }
    checkAndSetCategoryChange(fieldName){
        let categoryParentChange = false;
        if(this.valuesObj.businessAreaValue){
            //this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
            this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue] ? this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length : 0;

        }
        if(fieldName === this.fieldNames.channel || fieldName === this.fieldNames.caseType  || fieldName === this.fieldNames.businessArea  || fieldName === this.fieldNames.caseStage ){
            categoryParentChange = true;
        }
       
        // If changed to blank
        if(categoryParentChange && (!this.valuesObj.channelValue || !this.valuesObj.businessAreaValue 
            || !this.valuesObj.caseTypeValue || (this.valuesObj.businessAreaValue && this.businessAreaWithCaseStageLength > 0 && !this.valuesObj.caseStage ))){
                this.resetDependentCategory('allThree');
        }
        if(categoryParentChange ){
            this.resetDependentCategory('allThree');
            if(this.businessAreaWithCaseStageLength > 0){
                this.setCategoryQuery(this.fieldNames.caseStage);
            }else{
                this.setCategoryQuery(this.fieldNames.businessArea);
            }
        }else if(fieldName === this.fieldNames.primaryCategory ){
            this.resetDependentCategory('lastTwo');
            this.setCategoryQuery(this.fieldNames.primaryCategory);
        }else if(fieldName === this.fieldNames.secondaryCategory ){
            this.resetDependentCategory('lastOne');
            this.setCategoryQuery(this.fieldNames.secondaryCategory);
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
    setCategoryQuery(fieldName){
        let clause = '';
        this.categoryQuery = 'SELECT Name FROM Category__c WHERE Active__c = true';        
        clause = this.valuesObj.channelValue;
        clause += '_' + this.valuesObj.caseTypeValue;
        clause += '_' + this.valuesObj.businessAreaValue;

        if(fieldName === this.fieldNames.businessArea && this.businessAreaWithCaseStageLength === 0){
            clause += '_Primary';
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";
        }
        else if(fieldName === this.fieldNames.caseStage){
            clause += '_' + this.valuesObj.caseStageValue;
            clause += '_Primary';
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";

        }else if(fieldName === this.fieldNames.primaryCategory){
            if(this.valuesObj.caseStageValue){
                clause += '_' + this.valuesObj.caseStageValue;
            }
            clause += '_Secondary_' + this.valuesObj.primaryCategoryValue;
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";

        }else if(fieldName === this.fieldNames.secondaryCategory){
            if(this.valuesObj.caseStageValue){
                clause += '_' + this.valuesObj.caseStageValue;
            }
            clause += '_Tertiary_' + this.valuesObj.primaryCategoryValue;
            clause += '_' + this.valuesObj.secondaryCategoryValue;
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";
        }else{
            this.categoryQuery =undefined;
        } 
        if(this.categoryQuery){
            this.getCategoryRecords(this.categoryQuery,fieldName);
        }
    }
    getCategoryRecords(categoryQuery,fieldName){
        try{
            console.log('categoryQuery' +categoryQuery);
            this.error = '';
            this.isSpinnerShow = true;
            getCategoryRecordsApex({
                'query': categoryQuery
            })
            .then(result => {
               console.log(result);
                if (result) {
                    if (fieldName === this.fieldNames.businessArea || fieldName === this.fieldNames.caseStage) {
                        this.category.primaryCategoryOptions =  result;
                        if(result.length > 0){
                            this.category.isPrimaryCategoryDisabled =  false;
                        }
                    }else if(fieldName === this.fieldNames.primaryCategory){
                        this.category.secondaryCategoryOptions =  result;
                        if(result.length > 0){
                            this.category.isSecondaryCategoryDisabled =  false;
                        }
                    }else if(fieldName === this.fieldNames.secondaryCategory){
                        this.category.tertiaryCategoryOptions =  result;
                        if(result.length > 0){
                            this.category.isTertiaryCategoryDisabled =  false;
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
        }catch(e){
            console.log('Exception in getCategoryRecords JS method');
            console.log(e.message);
        }
    }
    /* Dealer related functions */
    updateDealerQuery(fieldName){
        // For Dealer Reset
        if (fieldName === 'onload' || fieldName === this.fieldNames.outletType || fieldName === this.fieldNames.city) {
            if(fieldName !== 'onload'){
                this.resetDealer();
            }
            this.dealerQuery = undefined;
            this.dealerQuery = 'SELECT Name,Type,Dealer_Code__c,Region_Code__c,City__c,Dealer_Type__c,BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode,Zone__c FROM Account';
            this.dealerQuery += ' WHERE RecordType.Name =' + "'" + this.dealerRecordTypeName + "'";
            console.log(this.valuesObj.cityValue);
            console.log(this.valuesObj.outletTypeValue);
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
       // console.log(this.dealerQuery);
    }
    getDealerFilterQuery(){
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
    resetDealer(){
        console.log('reset dealer called')
        this.selectedDealer = undefined;
        this.isDealerFieldShow = false;
        this.valuesObj.dealerType = '';
        this.valuesObj.dealerCode = '';
        this.selectedDealerId = undefined;
        this.valuesObj.dealerBillingStreet = '';
        this.valuesObj.dealerBillingCity = '';
        this.valuesObj.dealerBillingCountry = '';
        this.valuesObj.dealerBillingState = '';
        this.valuesObj.dealerBillingPostalCode = '';
        this.valuesObj.regionCodeValue= '';
        this.valuesObj.dealerZone = '';
        setTimeout(f => {
            this.isDealerFieldShow = true;
        }, 0);
        
    }
    handleLookupChange(event){
        try{
        //this.resetDealer();
        let txt = JSON.stringify(event.detail);
        console.log(txt);
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
        this.selectedDealer = txt && JSON.parse(txt) ? JSON.parse(txt) : undefined;
        if(this.selectedDealer && this.selectedDealer.Id){
            this.selectedDealerId = this.selectedDealer.Id;
            if (this.selectedDealer.Dealer_Code__c) {
                this.valuesObj.dealerCode = this.selectedDealer.Dealer_Code__c;
            }
            if (this.selectedDealer.Dealer_Type__c) {
                this.valuesObj.dealerType = this.selectedDealer.Dealer_Type__c;
            }
            if (this.selectedDealer.Region_Code__c) {
                this.valuesObj.regionCodeValue = this.selectedDealer.Region_Code__c;
            }
            this.valuesObj.dealerCode = this.selectedDealer.Dealer_Code__c;
            this.valuesObj.dealerZone = this.selectedDealer.Zone__c;
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
        }catch(e){
            console.log(e.message);
        }
    }
    /* submit functions */
    handleSubmit(event){
        try{
            let allValid =  true;
            event.preventDefault(); 
            let fields = event.detail.fields;
            fields = this.setDefaultValues(fields);
             /** Category fields check */
            let categoryFieldCheck = this.customFieldsRequiredCheck('lightning-combobox');
            if(!categoryFieldCheck ){
                allValid =  false;
               // return;
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
            /** Dealers fields check */
            if(!this.selectedDealer ){
                const dealer = this.template.querySelector('c-create-case-look-up');
                if(dealer !==null && !this.caseId){
                  //  allValid = dealer.checkRequired();
                }
            }
            if(!allValid){
                return;
            }
            if(this.selectedDealerId){
                if(!this.caseId){
                    fields.Dealership_ID__c =  this.selectedDealerId;
                    fields.Dealer_Name__c =  undefined;
                }else{
                    fields.Dealer_Name__c =  this.selectedDealerId;
                }
                fields.Region_Code__c =  this.valuesObj.regionCodeValue;
            }
            this.isSpinnerShow = true;
            console.log('Submitting this one ',JSON.stringify(fields));
            console.log('Ready To submit');
            if(this.caseId){
                console.log(' Case Update req');
                fields.Id = this.caseId;
                this.updateCaseFromApex(fields);
            }else{
                console.log('For Case Actions Only');
				 if(fields.Business_Area__c=='' && this.valuesObj.businessAreaValue!=undefined){
                    fields.Business_Area__c=this.valuesObj.businessAreaValue;
                }
                if(fields.Case_Stage__c=='' && this.valuesObj.caseStageValue!=undefined){
                    fields.Case_Stage__c=this.valuesObj.caseStageValue;
                }
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }catch(e){
            console.log(e.message);
            this.isSpinnerShow = false;
        }
    }
    setDefaultValues(fields){
        fields.Name = this.defaultCaseActionName;
        if(this.parentCaseId) {
            fields.Case_Number__c = this.parentCaseId;
        }
        fields = this.setCategoryValues(fields);
        return fields;
    }
    setCategoryValues(fields){
        if(this.valuesObj.primaryCategoryValue){
            const primaryCategoryObj = this.category.primaryCategoryOptions.find(primaryCategoryObj => primaryCategoryObj.value === this.valuesObj.primaryCategoryValue);
            fields.Primary_Category__c = primaryCategoryObj ? primaryCategoryObj.label : undefined;
            fields.Primary_Category_ID__c = primaryCategoryObj ? primaryCategoryObj.value : undefined;
        }else{
            fields.Primary_Category__c = undefined;
            fields.Primary_Category_ID__c = undefined;
        }if(this.valuesObj.secondaryCategoryValue){
            const secondaryCategoryObj = this.category.secondaryCategoryOptions.find(secondaryCategoryObj => secondaryCategoryObj.value === this.valuesObj.secondaryCategoryValue);
            fields.Secondary_Category__c = secondaryCategoryObj ? secondaryCategoryObj.label : undefined;  
            fields.Secondary_Category_ID__c = secondaryCategoryObj ? secondaryCategoryObj.value : undefined;  
        }else{
            fields.Secondary_Category__c = undefined;
            fields.Secondary_Category_ID__c = undefined;
        }if(this.valuesObj.tertiaryCategoryValue){
            const tertiaryCategoryObj = this.category.tertiaryCategoryOptions.find(tertiaryCategoryObj => tertiaryCategoryObj.value === this.valuesObj.tertiaryCategoryValue);
            fields.Tertiary_Category__c = tertiaryCategoryObj ? tertiaryCategoryObj.label : undefined; 
            fields.Tertiary_Category_ID__c = tertiaryCategoryObj ? tertiaryCategoryObj.value : undefined;  
        }else{
            fields.Tertiary_Category__c = undefined;
            fields.Tertiary_Category_ID__c = undefined;
        }
        return fields;
    }
    customFieldsRequiredCheck(chkField){
        const allValid = [...this.template.querySelectorAll(chkField)]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }
    handleSuccess(event){
        let updatedRecord = event.detail.id;
        let message = "Case transfer has been initiated successfully."
        let objectApiName = 'Case_Actions__c';
        if(this.caseId){
            objectApiName = 'Case';
            message = "Case has been updated successfully."
        }else if(this.caseActionId){
            message = "Case transfer has been updated successfully.";
        }
        const toastEvt = new ShowToastEvent({
            "title": "Success!",
            "message": message ,
            "variant" :"success"
        });
        this.dispatchEvent(toastEvt);
        eval("$A.get('e.force:refreshView').fire();");
        if(this.isMobileDevice){
             const evt = new CustomEvent('closequickaction');
            this.dispatchEvent(evt); 
        }
        this.isSpinnerShow = false; 
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: updatedRecord,
                objectApiName: objectApiName,
                actionName: 'view'
            }
        });
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
    handleError(event){
        this.isSpinnerShow = false;
       // console.log(JSON.stringify(event.detail));
       // console.log(JSON.stringify(event.detail.message));
       // console.log(JSON.stringify(event.detail.output.fieldErrors));
    }
    handleOnload(event){
        console.log('onload');
        this.isSpinnerShow = false;
    }
    closeModal(event) {
        try{
            let Id = this.parentCaseId;
            let objectApiName = 'Case';
            if(this.caseActionId){
                Id = this.caseActionId;
                objectApiName = 'Case_Actions__c';
            }
            this.handleReset(event);
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: Id,
                    objectApiName: objectApiName,
                    actionName: 'view'
                }
            });
           // window.history.back();
           // alert(0);
            return;
        }catch(e){
            console.log(e.message);
        }
    }
    saveCase(){
        const submitBtn = this.template.querySelector('.submit-btn');
        submitBtn.click();
    }
    showToast(title, message, type) {
        const toastEvt = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": type
        });
        this.dispatchEvent(toastEvt);
    }
    updateCaseFromApex(fields){
        try {
            this.error = '';
            this.isSpinnerShow = true;
            updateCase({
                caseString: JSON.stringify(fields),
                filedata: undefined
                })
                .then(result => {
                    console.log('Update Case Result ::', result);
                    if (result) {
                        let obj = {};
                        let detail = {};
                        detail.id = result;
                        obj.detail = detail;
                        this.handleSuccess(obj);
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
                    this.showToast('Error', this.error, 'error');
                    this.isSpinnerShow = false;
                });
        } catch (e) {
            console.log('Exception in updateCaseFromApex JS method');
            console.log(e.message);
        }
    }
}