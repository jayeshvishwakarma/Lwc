import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOnloadInfo from '@salesforce/apex/CreateCaseController.getOnloadInfoForCaseAction';
import getCategoryRecordsApex from '@salesforce/apex/CreateCaseController.getCategoryRecordsApex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class CreateCaseAction extends NavigationMixin(LightningElement) {
    @api recordId;
    @api parentCaseId;
    defaultCaseActionStatus = 'In Progress';
    defaultCaseActionName = 'Transfer';
    dealerSelectionMatrices = [];
    caseActionTransferRecordTypeId;
    caseObj;
    isMobileDevice = false;
    isSpinnerShow = true;
    caseActionFieldNames;
    valuesObj ={};
    businessAreaWithCaseStage; // GITIKA
    businessAreaWithCaseStageLength = 0; 
    category = {}; 
    categoryQuery;
   
    cityQuery;
    selectedCityId;
    isCityFieldShow= true;
    
    dealerQuery;
    selectedDealer;
    selectedDealerId;
    selectedDealerName;
    isDealerFieldShow= false;
    dealerRecordTypeName = 'Dealer';

    currentLoggedInUser = 'System Administrator';
    isAssignedApprover = true;
    isRMManager = false;

    allFieldsIsReadOnly = false;

    connectedCallback(){
        this.setCategories();
        this.setConstantFieldNames();
        this.checkForMobileDevice();
        this.getOnloadInfo();
        if(this.recordId){
           
        }
    }
    /* Onload functions */
    setConstantFieldNames(){
        this.caseActionFieldNames = {}
        let fieldNames ={};
        fieldNames.channel = 'Channel__c';
        fieldNames.caseType = 'Case_Type__c';
        fieldNames.businessArea = 'Business_Area__c';
        fieldNames.caseStage = 'Case_Stage__c';
        fieldNames.regionCode = 'Region_Code__c';
        fieldNames.city = 'For_Code__c'; 
        fieldNames.dealerName = 'Dealer_Name__c';
        fieldNames.primaryCategory = 'Primary_Category__c';
        fieldNames.secondaryCategory = 'Secondary_Category__c';
        fieldNames.tertiaryCategory = 'Tertiary_Category__c';
        this.caseActionFieldNames = fieldNames;
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
            console.log('recordId   ' + this.recordId);
            console.log('parentCaseId  '  + this.parentCaseId);
            this.error = '';
            this.isSpinnerShow = true;
            getOnloadInfo({
                caseId : this.parentCaseId,
                recordId : this.recordId
            })
            .then(result => {
                if (result) {
                    console.log('getOnloadInfo Result ::',result);
                    if(result.dealerSelectionMatrices){
                        this.dealerSelectionMatrices = result.dealerSelectionMatrices;
                    }
                    if(result.caseActionTransferRecordTypeId){
                        this.caseActionTransferRecordTypeId = result.caseActionTransferRecordTypeId;
                        this.valuesObj.caseTypeValue = 'Complaint';
                    }
                    if(result.caseActions){
                        this.setCaseActionValue(result.caseActions);
                    }
                    else if(result.caseObj){
                        this.caseObj = result.caseObj;
                        this.setCaseActionValueFromCase(result.caseObj);
                    }
                    if(result.businessAreaWithCaseStage){
                        this.businessAreaWithCaseStage = result.businessAreaWithCaseStage;
                    }
                    if(result.category){
                        this.setCategoryOnload(result.category);
                    }if(result.currentLoggedInUser){
                        this.setLoggedInUser(result.currentLoggedInUser);
                      
                    }
                }
                this.isDealerFieldShow = true;
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
        if(caseActions.For_Code__c){
            this.valuesObj.cityValue = caseActions.For_Code__c;
        }
        if(caseActions.Region_Code__c){
            this.valuesObj.regionCodeValue = caseActions.Region_Code__c;
        }
        if(caseActions.For_Code__c){
            this.valuesObj.cityValue = caseActions.For_Code__c;
        }
        if(caseActions.Dealer_Name__c){
            this.selectedDealerId = caseActions.Dealer_Name__c;
            this.selectedDealerName = caseActions.Dealer_Name__r.Name;
        }
        if(caseActions.Id){
            this.recordId = caseActions.Id;
        }
        if(caseActions.RecordTypeId){
            this.caseActionTransferRecordTypeId = caseActions.RecordTypeId;
        }
        if(caseActions.Approval_Status__c == 'Approved'){
            this.allFieldsIsReadOnly = true;
        }
        this.updateDealerQuery();
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
        }
        if(caseObj.Case_Stage__c){
            this.valuesObj.caseStageValue = caseObj.Case_Stage__c;
        }
        if(caseObj.For_Code__c){
            this.valuesObj.cityValue = caseObj.For_Code__c;
        }
        if(caseObj.Region_Code__c){
            this.valuesObj.regionCodeValue = caseObj.Region_Code__c;
        }
        if(caseObj.For_Code__c){
            this.valuesObj.cityValue = caseObj.For_Code__c;
        }
        if(caseObj.Dealer_Name__c){
            this.selectedDealerId = caseObj.Dealer_Name__c;
            this.selectedDealerName = caseObj.Dealer_Name__r.Name;
        }
        if(caseObj.isClosed){
          //  this.allFieldsIsReadOnly = true;
        }
        this.updateDealerQuery();   
    }
    setCategoryOnload(category){
        if(category.primaryCategoryOptions && category.primaryCategoryOptions.length > 0){
            this.category.primaryCategoryOptions =  category.primaryCategoryOptions;
            this.category.isPrimaryCategoryDisabled =  false;
        }if(category.primaryCategoryValue){
            this.category.primaryCategoryValue =  category.primaryCategoryValue;
            this.valuesObj.primaryCategoryValue = category.primaryCategoryValue;
        }
        if(category.secondaryCategoryOptions  && category.secondaryCategoryOptions.length > 0 ){
            this.category.secondaryCategoryOptions =  category.secondaryCategoryOptions;
            this.category.isSecondaryCategoryDisabled =  false;
        }if(category.secondaryCategoryValue){
            this.category.secondaryCategoryValue =  category.secondaryCategoryValue;
            this.valuesObj.secondaryCategoryValue = category.secondaryCategoryValue;
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
        if(this.recordId){
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
            if(fieldName){
                this.setValueInObject(fieldName,fieldValue);
                this.checkAndSetCategoryChange(fieldName);
                this.updateDealerQuery();
            }
            
        }catch(e){
            console.log(e.message);
        }
    }
    setValueInObject(fieldName,fieldValue){
        // Values setting only for the fields which all are taking part in dependency
        if(fieldName == this.caseActionFieldNames.channel){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.channelValue = fieldValue;
            }else{
                this.valuesObj.channelValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.caseType){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.caseTypeValue = fieldValue;
            }else{
                this.valuesObj.caseTypeValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.businessArea){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.businessAreaValue = fieldValue;
                this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
                if(this.businessAreaWithCaseStageLength === 0){
                    this.valuesObj.caseStageValue = undefined;    
                }
            }else{
                this.valuesObj.businessAreaValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.caseStage){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.caseStageValue = fieldValue;
            }else{
                this.valuesObj.caseStageValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.regionCode){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.regionCodeValue = fieldValue;
            }else{
                this.valuesObj.regionCodeValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.city){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.cityValue = Object.values(fieldValue)[0];
            }else{
                this.valuesObj.cityValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.dealerName){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.dealerNameValue = fieldValue;
            }else{
                this.valuesObj.dealerNameValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.primaryCategory){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.primaryCategoryValue = fieldValue;
            }else{
                this.valuesObj.primaryCategoryValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.secondaryCategory){
            if(fieldValue && fieldValue !=='' ){
                this.valuesObj.secondaryCategoryValue = fieldValue;
            }else{
                this.valuesObj.secondaryCategoryValue = undefined;
            }
        }else if(fieldName == this.caseActionFieldNames.tertiaryCategory){
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
            this.businessAreaWithCaseStageLength = this.businessAreaWithCaseStage[this.valuesObj.businessAreaValue].length;
        }
        if(fieldName === this.caseActionFieldNames.channel || fieldName === this.caseActionFieldNames.caseType  || fieldName === this.caseActionFieldNames.businessArea  || fieldName === this.caseActionFieldNames.caseStage ){
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
                this.setCategoryQuery(this.caseActionFieldNames.caseStage);
            }else{
                this.setCategoryQuery(this.caseActionFieldNames.businessArea);
            }
        }else if(fieldName === this.caseActionFieldNames.primaryCategory ){
            this.resetDependentCategory('lastTwo');
            this.setCategoryQuery(this.caseActionFieldNames.primaryCategory);
        }else if(fieldName === this.caseActionFieldNames.secondaryCategory ){
            this.resetDependentCategory('lastOne');
            this.setCategoryQuery(this.caseActionFieldNames.secondaryCategory);
        }
        // For Dealer Reset
        if(fieldName === this.caseActionFieldNames.channel || fieldName === this.caseActionFieldNames.businessArea || this.caseActionFieldNames.city){
           this.resetDealer();
        }
       
    }
    resetDependentCategory(resetType){ 
        if(resetType === 'allThree'){ // primary, secondary and tertiary reset 
            this.setCategories();
        }else if(resetType === 'lastTwo'){ // secondary and tertiary reset 
            this.category.secondaryCategoryOptions =  [];
            this.category.secondaryCategoryValue =  undefined;
            this.category.isSecondaryCategoryDisabled =  true;
            this.category.tertiaryCategoryOptions =  [];
            this.category.tertiaryCategoryValue =  undefined;
            this.category.isTertiaryCategoryDisabled =  true;

        }else if(resetType === 'lastOne'){ // only tertiary reset 
            this.category.tertiaryCategoryOptions =  [];
            this.category.tertiaryCategoryValue =  undefined;
            this.category.isTertiaryCategoryDisabled =  true;
        }
    }
    setCategoryQuery(fieldName){
        let clause = '';
        this.categoryQuery = 'SELECT Name FROM Category__c WHERE Active__c = true';        
        clause = this.valuesObj.channelValue;
        clause += '_' + this.valuesObj.caseTypeValue;
        clause += '_' + this.valuesObj.businessAreaValue;

        if(fieldName === this.caseActionFieldNames.businessArea && this.businessAreaWithCaseStageLength === 0){
            clause += '_Primary';
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";
        }
        else if(fieldName === this.caseActionFieldNames.caseStage){
            clause += '_' + this.valuesObj.caseStageValue;
            clause += '_Primary';
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";

        }else if(fieldName === this.caseActionFieldNames.primaryCategory){
            if(this.valuesObj.caseStageValue){
                clause += '_' + this.valuesObj.caseStageValue;
            }
            clause += '_Secondary_' + this.valuesObj.primaryCategoryValue;
            this.categoryQuery +=' AND External_ID_Query__c ='+ "'" + clause + "'";

        }else if(fieldName === this.caseActionFieldNames.secondaryCategory){
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
                    if(fieldName === this.caseActionFieldNames.caseStage){
                        this.category.primaryCategoryOptions =  result;
                        if(result.length > 0){
                            this.category.isPrimaryCategoryDisabled =  false;
                        }
                    }else if(fieldName === this.caseActionFieldNames.primaryCategory){
                        this.category.secondaryCategoryOptions =  result;
                        if(result.length > 0){
                            this.category.isSecondaryCategoryDisabled =  false;
                        }
                    }else if(fieldName === this.caseActionFieldNames.secondaryCategory){
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
    updateDealerQuery(){
        this.dealerQuery = undefined;
        this.dealerQuery = 'SELECT Name,Type,Dealer_Code__c,Region_Code__c,City__c,Dealer_Type__c,BillingCity,BillingPostalCode,BillingState FROM Account'; 
        this.dealerQuery +=' WHERE RecordType.Name ='+ "'" +this.dealerRecordTypeName + "'";
        
        let allFilterFieldsHaveValues = false;
        if(this.valuesObj.cityValue && this.valuesObj.channelValue && this.valuesObj.businessAreaValue){
            allFilterFieldsHaveValues = true;
        }
     
        if(allFilterFieldsHaveValues){
            this.dealerQuery +=' AND For_Code__c ='+ "'" +this.valuesObj.cityValue + "'";
            let whereClause = this.getDealerFilterQuery();
            if(whereClause){
                this.dealerQuery +=' AND '+ whereClause;
            }
        }else{
            this.dealerQuery= undefined;
        }
        console.log(this.dealerQuery);
    }
    getDealerFilterQuery(){
        let whereClause;
        let selectedMatrix;
        for(let i=0 ; i < this.dealerSelectionMatrices.length ; i++){
            let obj = this.dealerSelectionMatrices[i];
            if(obj.Channel__c === this.valuesObj.channelValue && obj.Business_Area__c === this.valuesObj.businessAreaValue){
                selectedMatrix = obj;
            }else if(obj.Channel__c === this.channel_Value && obj.Business_Area__c === 'All'){  // Special Case
                selectedMatrix = obj;
            }
        }
       //console.log('selectedMatrix :: ',selectedMatrix);
        if(selectedMatrix){
            whereClause ='Channel__c ='+ "'" + selectedMatrix.Channel_Short_Code__c + "'";
            let types = selectedMatrix.Dealer_Type__c.split(",");
            whereClause +=' AND ';
            if(types.length > 1){
                whereClause +='(';
            }
            for(let i = 0 ; i < types.length ;i++){
                if(i === 0){
                    whereClause +='Dealer_Type__c ='+ "'" +types[i] + "'";
                }else{
                    whereClause +=' OR Dealer_Type__c ='+ "'" +types[i] + "'";
                }
            }
            if(types.length > 1){
                whereClause +=')';
            }
           
        }
        return whereClause;  
    }
    resetDealer(){
        this.selectedDealer = undefined;
        this.isDealerFieldShow =  false;
        this.valuesObj.dealerType = undefined;
        this.valuesObj.dealerCode = undefined;
        this.selectedDealerId = undefined;
        setTimeout( f=>{
            this.isDealerFieldShow =  true;
        }, 0);
        
    }
    handleLookupChange(event){
        try{
        let txt = JSON.stringify(event.detail);
        this.selectedDealer = JSON.parse(txt);
       // console.log(this.selectedDealer);
        if(this.selectedDealer && this.selectedDealer.Id){
            this.selectedDealerId = this.selectedDealer.Id;
            this.valuesObj.dealerCode = this.selectedDealer.Dealer_Code__c;
            this.valuesObj.dealerType = this.selectedDealer.Dealer_Type__c;
        }
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
            if(!categoryFieldCheck || !fields.Primary_Category_ID__c){
                allValid =  false;
                return;
            }
            /** Dealers fields check */
            if(!this.selectedDealer ){
                const dealer = this.template.querySelector('c-create-case-look-up');
                if(dealer !==null){
                    allValid = dealer.checkRequired();
                }
               
            }
            if(!allValid){
                return;
            }
            fields.Dealership_ID__c =  this.selectedDealerId;
            fields.Dealer_Name__c =  undefined;
            this.isSpinnerShow = true;
            console.log('Submitting this one ',JSON.stringify(fields));
            console.log('Ready To submit');
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }catch(e){
            console.log(e.message);
            this.isSpinnerShow = false;
        }
    }
    setDefaultValues(fields){
        fields.Name = this.defaultCaseActionName;
        if(this.parentCaseId){
            fields.Case_Number__c = this.parentCaseId;
        }
        //Set Dealer Related fields
        if(this.selectedDealer){
            fields.Dealer_Name__c = this.selectedDealer.Id;
        }
        fields = this.setCategoryValues(fields);
        return fields;
    }
    setCategoryValues(fields){
        if(this.valuesObj.primaryCategoryValue){
            const primaryCategoryObj = this.category.primaryCategoryOptions.find(primaryCategoryObj => primaryCategoryObj.value === this.valuesObj.primaryCategoryValue);
            fields.Primary_Category__c = primaryCategoryObj.label;
            fields.Primary_Category_ID__c = primaryCategoryObj.value;
        }else{
            fields.Primary_Category__c = undefined;
            fields.Primary_Category_ID__c = undefined;
        }if(this.valuesObj.secondaryCategoryValue){
            const secondaryCategoryObj = this.category.secondaryCategoryOptions.find(secondaryCategoryObj => secondaryCategoryObj.value === this.valuesObj.secondaryCategoryValue);
            fields.Secondary_Category__c = secondaryCategoryObj.label;
            fields.Secondary_Category_ID__c = secondaryCategoryObj.value;
        }else{
            fields.Secondary_Category__c = undefined;
            fields.Secondary_Category_ID__c = undefined;
        }if(this.valuesObj.tertiaryCategoryValue){
            const tertiaryCategoryObj = this.category.tertiaryCategoryOptions.find(tertiaryCategoryObj => tertiaryCategoryObj.value === this.valuesObj.tertiaryCategoryValue);
            fields.Tertiary_Category__c = tertiaryCategoryObj.label;
            fields.Tertiary_Category_ID__c = tertiaryCategoryObj.value;
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
       // console.log(updatedRecord);
       let message = "Case transfer has been initiated successfully."
       if(this.recordId){
        message = "Case transfer has been updated successfully.";
       }
        const toastEvt = new ShowToastEvent({
            "title": "Success!",
            "message": "Case transfer has been initiated successfully.",
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
                objectApiName: 'Case_Actions__c',
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
            this.handleReset(event);
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.parentCaseId,
                    objectApiName: 'Case_Actions__c',
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

}