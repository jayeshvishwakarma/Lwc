/**
     * @File Name          : CreateCaseController.cls
     * @Description        : This class is responsible to fetch the category records based on the query
     * @Author             : Deepak Kumar
     * @Group              :
     * @Last Modified By   : Deepak Kumar
     * @Last Modified On   : 03/06/2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        03/06/2020                Deepak Kumar              Initial Version
**/

public without sharing class CreateCaseController {

    /**
       Author: Sunit Kumar Chand
       Company: Techmatrix
       Description: This method is used to update case
       Inputs:  Case String
       Returns: Case id
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.2        09/11/2020               Sunit Kumar Chand         Initial Version
   **/
    @AuraEnabled
    public static Id updateCase(String caseString, String filedata) {
        try {
            Case caseObj = (Case) System.JSON.deserialize(caseString, Case.class);
            if(caseObj.Suzuki_Connect_Remark__c!=null && caseObj.Suzuki_Connect_Remark__c!=''){
            	caseObj.Additional_Information__c = caseObj.Additional_Information__c == null ? caseObj.Suzuki_Connect_Remark__c : caseObj.Additional_Information__c + '\n Date:- ' +System.now() +'\n'+ caseObj.Suzuki_Connect_Remark__c ;
            }            
            update caseObj;
            if(filedata!=null && filedata!=''){
            	ContentVersion conVer = [SELECT Id,ContentDocumentId,FileUniqueName__c,ContentUrl,title FROM ContentVersion Where ContentDocumentId = :filedata];
            	conVer.FileUniqueName__c = 'Upload Clarification';
            	update conVer; 
                CaseActionCreation.insertFeedItem(caseObj.Id,caseObj.Suzuki_Connect_Remark__c,ConstantsUtility.TEXT_POST, conVer.Id);
            }
            else{
            	CaseActionCreation.insertFeedItem(caseObj.Id,caseObj.Suzuki_Connect_Remark__c,ConstantsUtility.TEXT_POST, null); 
            } 
            return caseObj.Id;
        } catch (Exception exp) {
            System.debug('Exception Message ' + exp.getMessage() + ' At Line  ::' + exp.getLineNumber());
            throw new AuraHandledException(exp.getMessage());
        }
    }
    /**
       Author: Sunit Kumar Chand
       Company: Techmatrix
       Description: 
       Inputs:  String Account external id
       Returns: Account object
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.2        09/11/2020               Sunit Kumar Chand         Initial Version
   **/
    @AuraEnabled
    public static Account getDealerInfo(String externalId) {
       return getDealerAccountInfo(externalId);
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: This is responsible to get the initial data to create or edit the case action record
       Inputs:  String caseId  and String recordId
       Returns: InitialInfo wrapper object
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0        03/06/2020                Deepak Kumar              Initial Version
   **/
    @AuraEnabled
    public static InitialInfo getOnloadInfoForCaseAction(String parentCaseId, String caseActionId, String caseId) {
        InitialInfo initialInfo = new InitialInfo();
        try {
            initialInfo.dealerSelectionMatrices = getDealerSelectionMatrices();
            initialInfo.businessAreaWithCaseStage = getCaseStage();
            if (caseId != null) {
                initialInfo.caseObj = getCaseInfo(caseId, false);
                initialInfo.category = getCategoryRecord(initialInfo.caseObj.Primary_Category_ID__c, initialInfo.caseObj.Secondary_Category_ID__c, initialInfo.caseObj.Tertiary_Category_ID__c);
            } else if (caseActionId != null || parentCaseId != null) {
                initialInfo.caseActionTransferRecordTypeId = ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID;
                initialInfo.caseObj = parentCaseId != null ? getCaseInfo(parentCaseId, false) : null;
                initialInfo.caseActions = getCaseActionInfo(caseActionId, parentCaseId);
                if (initialInfo.caseActions != null) {
                    initialInfo.category = getCategoryRecord(initialInfo.caseActions.Primary_Category_ID__c, initialInfo.caseActions.Secondary_Category_ID__c, initialInfo.caseActions.Tertiary_Category_ID__c);
                    initialInfo.currentLoggedInUser = getCurrentUserInfo(initialInfo.caseActions);
                } else {
                    initialInfo.category = getCategoryRecord(initialInfo.caseObj.Primary_Category_ID__c, initialInfo.caseObj.Secondary_Category_ID__c, initialInfo.caseObj.Tertiary_Category_ID__c);
                }
            }
            initialInfo.channelCaseTypeVsBusinessAreasMap = getBusinessDependency();
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage());
            throw new AuraHandledException(exp.getMessage());
        }
        return initialInfo;
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This is responsible to get the initial data to create the case record
        Inputs:  String parentRecordId ,String caseId
        Returns: InitialInfo wrapper object
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        03/06/2020                Deepak Kumar              Initial Version
    **/
    @AuraEnabled
    public static InitialInfo getOnloadInfoForCase(String parentRecordId, String caseId) {
        InitialInfo initialInfo = new InitialInfo();
        try {
            String sObjName = '';
            // System.debug(parentRecordId);
            if (parentRecordId != null) {
                Object obj = parentRecordId;
                if (obj instanceof Id) {
                    sObjName = Id.valueOf(parentRecordId).getSObjectType().getDescribe().getName();
                } else {
                    initialInfo.enquiry = getEnquiryInfoViaJson(parentRecordId);
                    initialInfo.personAccount = gePersonAccountInfoViaJson(parentRecordId);
                    initialInfo.dealerAccount = geDealerAccountInfoViaJson(parentRecordId);
                    // initialInfo.outletType = getOutletType(initialInfo.dealerAccount);
                }
            }
            if (sObjName == 'Asset') {
                Asset asset = [SELECT Customer_Name__c,AccountId,VIN__c,Registration_Number__c,Product2Id,Model_Code__c,Product2.LOB__c FROM Asset WHERE Id = :parentRecordId LIMIT 1];
                initialInfo.personAccount = getAccountInfo(asset.AccountId);
                Opportunity opportunity = new Opportunity();
                opportunity.VIN__c = asset.VIN__c;
                opportunity.Vehicle_Registration__c = asset.Registration_Number__c;
                opportunity.Variant__c = asset.Product2Id;
                opportunity.Model_Code__c = asset.Model_Code__c;
                opportunity.Dealership_Channel__c = asset.Product2Id != null ? asset.Product2.LOB__c: null;
                initialInfo.enquiry = opportunity;
            }
            if (sObjName == 'Account') {
                initialInfo.personAccount = getAccountInfo(parentRecordId);
            }
            if (sObjName == 'Opportunity') {
                initialInfo.enquiry = getEnquiryInfo(parentRecordId);
            }
            if (caseId != null && caseId.startsWith(ConstantsUtility.CASE_PREFIX)) {
                //System.debug(caseId);
                initialInfo.caseObj = getCaseInfo(caseId, false); // For Edit the case default values
                if (initialInfo.caseObj.Dealer_Name__c != null) {
                    initialInfo.dealerAccount = getDealerAccountInfo(initialInfo.caseObj.Dealer_Name__c);
                }
                initialInfo.category = getCategoryRecord(initialInfo.caseObj.Primary_Category_ID__c, initialInfo.caseObj.Secondary_Category_ID__c, initialInfo.caseObj.Tertiary_Category_ID__c);
            }
            if(sObjName == 'Survey_Taker_CTI__c'){
                system.debug('survey taker id ==>' + parentRecordId);
                initialInfo.SurveyTakerCustomer = getSurveyTakerCustomerDetail(parentRecordId);
            }
            initialInfo.dealerSelectionMatrices = getDealerSelectionMatrices();
            initialInfo.businessAreaWithCaseStage = getCaseStage();
            initialInfo.channelCaseTypeVsBusinessAreasMap = getBusinessDependency();
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + 'At  ' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getMessage());
        }
        return initialInfo;
    }

    
    public class InitialInfo {
        @AuraEnabled public Account personAccount;
        @AuraEnabled public Opportunity enquiry;
        @AuraEnabled public Case caseObj;
        @AuraEnabled public String caseActionTransferRecordTypeId;
        @AuraEnabled public List <Dealer_Selection_Matrix__c> dealerSelectionMatrices;
        @AuraEnabled public Map<String, List<string>> businessAreaWithCaseStage;
        @AuraEnabled public Case_Actions__c caseActions;
        @AuraEnabled public Category category;
        @AuraEnabled public String currentLoggedInUser;
        @AuraEnabled public String outletType;
        @AuraEnabled public Account dealerAccount;
        @AuraEnabled public String currentUserProfileName = [SELECT Id,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
		@AuraEnabled public SurveyTakerCustomer surveyTakerCustomer;
        @AuraEnabled public Map<String, List<String>> channelCaseTypeVsBusinessAreasMap;

    }

    private static Account getAccountInfo(String parentAccountId) {
        return [SELECT PersonContactId,FirstName,LastName,PersonEmail,PersonMobilePhone FROM Account WHERE Id = :parentAccountId LIMIT 1];
    }
    private static Opportunity getEnquiryInfo(String parentEnquiryId) {
        return [
                SELECT First_Name__c,Last_Name__c,Mobile__c,Email__c,Booking_Number__c,Invoice_Number__c,Model_Code__c,Variant__c,Color__c,Vehicle_Registration__c,VIN__c,
                        Dealership__c,Dealership__r.Name,Dealership__r.Zone__c,Dealership__r.Dealer_Code__c, Dealership__r.Dealer_Type__c,Dealership__r.For_Code__c,
                        Dealership__r.Region_Code__c,Owner.Channel__c,Dealership_Channel__c,Dealership__r.Channel__c,Dealership__r.Dealer_Category__c,Customer__c,
                        Dealership__r.BillingStreet,Dealership__r.BillingCity,Dealership__r.BillingCountry,Dealership__r.BillingState,Dealership__r.BillingPostalCode,Dealership__r.Outlet_Code__c,Dealership__r.For_Code__r.For_Code__c
                FROM Opportunity
                WHERE Id = :parentEnquiryId
                LIMIT 1
        ];
    }

    /**
       Author: Najab Maghribi
       Company: Techmatrix
       Description: This methos is used to get the Survey Taker Customer Data.
       Inputs: String surveyTakerId
       Returns: Survey Taker CTI Object
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0        23/10/2020               Najab Maghribi            Initial Version
   **/
    public static SurveyTakerCustomer getSurveyTakerCustomerDetail(string surveyTakerId) {
        List<Survey_Taker_CTI__c> surveyTakerList = new List<Survey_Taker_CTI__c>();
        List<Survey_Case_Mapping__mdt> surveyCaseMappingList = [
                Select Id,
                        Default_value__c, Source_field__c,
                        Survey_type__c, Target_field__c
                From Survey_Case_Mapping__mdt
        ];

        Set<String> fieldsList = new Set<String>();
        for (Survey_Case_Mapping__mdt metaRec : surveyCaseMappingList) {
            if (String.isNotBlank(metaRec.Source_field__c)) {
                fieldsList.add(metaRec.Source_field__c);
            }
        }
        String query = 'SELECT ';
        for (String fields : fieldsList) {
            query += fields + ', ';
        }
        query += 'id, Customer__c, Survey__c, Survey__r.Name, Survey__r.Type FROM Survey_Taker_CTI__c WHERE Id =: surveyTakerId';
        system.debug('query ==>' + query);
        surveyTakerList = database.Query(query);
        SurveyTakerCustomer surveyTakerCustomer = new SurveyTakerCustomer();
        if (surveyTakerList.size() > 0) {
            surveyTakerCustomer.customerDetail = surveyTakerList[0];
        }
        if (surveyCaseMappingList.size() > 0) {
            surveyTakerCustomer.surveyCaseMappingRecords = surveyCaseMappingList;
        }

        return surveyTakerCustomer;
    }

    public class SurveyTakerCustomer {
        @AuraEnabled public Survey_Taker_CTI__c customerDetail;
        @AuraEnabled public List<Survey_Case_Mapping__mdt> surveyCaseMappingRecords ;
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: This methos is used to get the case data based on the case number or case record Id
       Inputs: String caseId
       Returns: Case Object
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0        03/06/2020                Deepak Kumar              Initial Version
   **/
    @AuraEnabled
    public static Case getCaseInfo(String caseId, Boolean isEmailCase) {
        try {
            List<Case> cases = new List<Case>();
            cases = [
                    Select Subject,RecordType.Name,Channel__c,Case_Type__c,Business_Area__c,Case_Stage__c,Outlet_Type__c,Description,
                            Primary_Category__c,Primary_Category_ID__c,Secondary_Category__c,Secondary_Category_ID__c,Tertiary_Category__c,
                            Tertiary_Category_ID__c,For_Code__c,Region_Code__c,Dealer_Name__c,Dealer_Name__r.Name,Dealer_Name__r.External_Id__c,isClosed,
                            Dealer_Name__r.Region_Code__c,Dealer_Name__r.Zone__c,Dealer_Name__r.BillingStreet,Dealer_Name__r.BillingCity,Dealer_Name__r.BillingPostalCode,
                            Dealer_Name__r.BillingCountry,Dealer_Name__r.BillingState,Dealer_Name__r.Dealer_Code__c,Model__c,Variant__c,Color__c
                    FROM Case
                    WHERE (Id = :caseId OR CaseNumber = :caseId)
                    LIMIT 1
            ];
            // Called from The Component
            if (cases.size() > 0 && isEmailCase && cases[0].RecordTypeId == ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID) {
                return cases[0];
            } else if (cases.size() > 0 && !isEmailCase) {  // Called from The this class
                return cases[0];
            }
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
        return null;
    }

    private static List<Dealer_Selection_Matrix__c> getDealerSelectionMatrices() {
        return [SELECT Id,Outlet_Type__c,Dealer_Type__c,Dealer_Category__c,Dealer_Channel__c FROM Dealer_Selection_Matrix__c];
    }
     private static Case_Actions__c getCaseActionInfo(String recordId, String caseId) {
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
        caseActions = [
                SELECT Id,Channel__c,Case_Type__c,Business_Area__c,RecordTypeId,Outlet_Type__c,
                        Case_Stage__c,Dealer_Name__r.Name,Dealer_Name__c,Region_Code__c,For_Code__c,
                        Primary_Category_ID__c,Secondary_Category_ID__c,Tertiary_Category_ID__c, Dealer_Name__r.Region_Code__c,Dealer_Name__r.Zone__c,
                        Transferred_Dealer_Approver__c,L2A_Stakeholder__c,L3A_Stakeholder__c,L4_Stakeholder__c,Approval_Status__c,
                        Dealer_Name__r.BillingStreet,Dealer_Name__r.BillingCity,Dealer_Name__r.BillingPostalCode,Dealer_Name__r.Dealer_Code__c,
                        Dealer_Name__r.BillingCountry,Dealer_Name__r.BillingState, Dealer_Name__r.Outlet_Code__c,Dealer_Name__r.For_Code__r.For_Code__c
                FROM Case_Actions__c
                WHERE (Id = :recordId OR Case_Number__c = :caseId) AND RecordTypeId = :ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID
                LIMIT 1
        ];
        if (caseActions.size() > 0) {
            return caseActions[0];
        }
        return null;


    }
    private static Category getCategoryRecord(String primaryCategoryId, String secondaryCategoryId, String tertiaryCategoryId) {
        Category category = new Category();
        Set<Id> categoryIds = new Set<Id>();
        if (primaryCategoryId != null) {
            categoryIds.add(primaryCategoryId);
        }
        if (secondaryCategoryId != null) {
            categoryIds.add(secondaryCategoryId);
        }
        if (tertiaryCategoryId != null) {
            categoryIds.add(tertiaryCategoryId);
        }
        String categoryQuery = 'SELECT Name FROM Category__c WHERE Active__c = true';
        String primaryTemp ;
        String secondaryTemp;
        String tertiaryTemp ;
        for (Category__c categoryObj : [SELECT External_ID_Query__c,Type__c FROM Category__c WHERE Id IN:categoryIds]) {
            if (categoryObj.Type__c == 'Primary') {
                primaryTemp = categoryObj.External_ID_Query__c;
                category.primaryCategoryValue = categoryObj.Id;
            } else if (categoryObj.Type__c == 'Secondary') {
                secondaryTemp = categoryObj.External_ID_Query__c;
                category.secondaryCategoryValue = categoryObj.Id;
            } else if (categoryObj.Type__c == 'Tertiary') {
                tertiaryTemp = categoryObj.External_ID_Query__c;
                category.tertiaryCategoryValue = categoryObj.Id;
            }
        }
        if (primaryTemp != null) {
            String primaryCategoryQuery = categoryQuery + ' AND External_ID_Query__c =\'' + primaryTemp + '\'';
            category.primaryCategoryOptions = getCategoryRecordsApex(primaryCategoryQuery);
        }if (secondaryTemp != null) {
            String secondaryCategoryQuery = categoryQuery + ' AND External_ID_Query__c =\'' + secondaryTemp + '\'';
            category.secondaryCategoryOptions = getCategoryRecordsApex(secondaryCategoryQuery);
        }if (tertiaryTemp != null) {
            String tertiaryCategoryQuery = categoryQuery + ' AND External_ID_Query__c =\'' + tertiaryTemp + '\'';
            category.tertiaryCategoryOptions = getCategoryRecordsApex(tertiaryCategoryQuery);
        }
        return category;

    }
    public class Category {
        @AuraEnabled public List<CustomPickList> primaryCategoryOptions;
        @AuraEnabled public Id primaryCategoryValue;
        @AuraEnabled public List<CustomPickList> secondaryCategoryOptions;
        @AuraEnabled public Id secondaryCategoryValue;
        @AuraEnabled public List<CustomPickList> tertiaryCategoryOptions;
        @AuraEnabled public Id tertiaryCategoryValue;
    }
    private static String getCurrentUserInfo(Case_Actions__c caseActions) {
        String currentLoggedInUser = 'System Administrator';
        String userId = UserInfo.getUserId();
        if (userId == caseActions.L2A_Stakeholder__c || userId == caseActions.L3A_Stakeholder__c || userId == caseActions.L4_Stakeholder__c) {
            currentLoggedInUser = 'Assigned Approver';
        } else if (userId == caseActions.Transferred_Dealer_Approver__c) {
            currentLoggedInUser = 'RM Manager';
        } else {
            List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
            if (profiles[0].Name == 'System Administrator') {
                currentLoggedInUser = 'System Administrator';
            }
        }
        return currentLoggedInUser;
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: Method to get the Record Type Id of Case Based on custom metadata
       Inputs: query String
       Returns: List of CustomPickList
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0        16/06/2020                Deepak Kumar              Initial Version
    **/
    @AuraEnabled
    public static String getCaseRecordType(String caseType) {
        try {
            String recordTypeId;
            List<Case_Type_And_Case_RecordType_Matrix__mdt> CaseRecordTypeMatrices = new List<Case_Type_And_Case_RecordType_Matrix__mdt>();
            CaseRecordTypeMatrices = [
                    SELECT Id,Record_Type_Developer_Name__c
                    FROM Case_Type_And_Case_RecordType_Matrix__mdt
                    WHERE MasterLabel = :caseType
                    LIMIT 1
            ];
            if (CaseRecordTypeMatrices.size() > 0) {
                String devName = CaseRecordTypeMatrices[0].Record_Type_Developer_Name__c;
                System.debug(devName);
                recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();
            }
            return recordTypeId;
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage());
            throw new AuraHandledException(exp.getMessage());
        }


    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: Method to get the Category records
        Inputs: query String
        Returns: List of CustomPickList
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        03/06/2020                Deepak Kumar              Initial Version
    **/
    @AuraEnabled
    public static List<CustomPickList> getCategoryRecordsApex(String query) {
        List<CustomPickList> picklist = new List<CustomPickList>();
        try {
            for (SObject sObj : Database.query(query)) {
                CustomPickList picklistObj = new CustomPickList();
                picklistObj.value = String.valueOf(sObj.get('Id'));
                picklistObj.label = String.valueOf(sObj.get('Name'));
                picklist.add(picklistObj);
            }

        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage());
            throw new AuraHandledException(exp.getMessage());
        }
        return picklist;
    }
    public class CustomPickList {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: Method to fetch the List of sObjects
        Inputs: query String
        Returns: String of sObject
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        210/05/2020              Deepak Kumar              Initial Version
    **/
    @AuraEnabled
    public static String getObjects(String query, String searchKey) {
        try {
            List<sObject> sObjects = new List<sObject>();

            if (searchKey != null && searchKey.trim() != '') {
                searchKey = '%' + searchKey + '%';
                if (query.containsIgnoreCase('where')) {
                    if(query.containsIgnoreCase('from Account')){
                        query += ' AND (Name Like :searchKey OR Dealer_Code__c Like :searchKey)';
                    }else{
                        query += ' AND Name Like :searchKey';
                    }
                } else {
                    if(query.containsIgnoreCase('from Account')) {
                        query += ' WHERE (Name Like :searchKey OR Dealer_Code__c Like :searchKey)';
                    }else{
                        query += ' WHERE Name Like :searchKey';
                    }
                }
            }
            query += ' LIMIT 15';
            sObjects = Database.query(query);
            return JSON.serialize(sObjects);
        } catch (Exception exp) {
            System.debug('Exception Message : ' + exp.getMessage() + ' At Line Number ::' + exp.getLineNumber());
            throw new AuraHandledException(exp.getMessage());
        }
    }

    private static map<String, List<string>> getCaseStage() {
        Map<String, List<string>> objbusinessAreaWithCaseStage = new Map<String, List<string>>();
        Schema.sObjectType objType = Case.getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        Schema.SObjectField theField = objFieldMap.get('Case_Stage__c');
        Schema.SObjectField ctrlField = objFieldMap.get('Business_Area__c');

        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        for (Schema.PicklistEntry pled : contrEntries) {
            String label = pled.getLabel();
            objbusinessAreaWithCaseStage.put(label, new List<String>());
            controllingValues.add(label);
        }

        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objbusinessAreaWithCaseStage.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        return objbusinessAreaWithCaseStage;
    }
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }

    private static final String base64Chars = '' +
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
            'abcdefghijklmnopqrstuvwxyz' +
            '0123456789+/';
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
                JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    public class PicklistEntryWrapper {
        public String active { get; set; }
        public String defaultValue { get; set; }
        public String label { get; set; }
        public String value { get; set; }
        public String validFor { get; set; }
        public PicklistEntryWrapper() {
        }
    }


    /** The below three methods are dedicated for population on data while creating case from Customer History SVOCId*/
    private static Account gePersonAccountInfoViaJson(String parentEnquiryJSON) {
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(parentEnquiryJSON);
        Account personAccount = new Account();
        String personAccountId = resultMap.containsKey('personAccountId') ? (String.IsNotBlank(String.valueOf(resultMap.get('personAccountId'))) ? +String.valueOf(resultMap.get('personAccountId')) : '') : '';
        if (personAccountId.length() > 0) {
            personAccount = getAccountInfo(personAccountId);
            return personAccount;
        }
        return personAccount;
    }
    
    private static Account geDealerAccountInfoViaJson(String parentEnquiryJSON) {
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(parentEnquiryJSON);
        Account acc = new Account();
        // FROM SERVICE HISTORY
        if (resultMap.containsKey('createFrom') && String.valueOf(resultMap.get('createFrom')) == 'ServiceHistory') {
            String UniqueKey = '';
            UniqueKey = resultMap.containsKey('parentGroup') ? (String.IsNotBlank(String.valueOf(resultMap.get('parentGroup'))) ? String.valueOf(resultMap.get('parentGroup')) : '') : '';
            UniqueKey += resultMap.containsKey('dealerMapCode') ? (String.IsNotBlank(String.valueOf(resultMap.get('dealerMapCode'))) ? +'_' + String.valueOf(resultMap.get('dealerMapCode')) : '') : '';
            UniqueKey += resultMap.containsKey('locationCode') ? (String.IsNotBlank(String.valueOf(resultMap.get('locationCode'))) ? +'_' + String.valueOf(resultMap.get('locationCode')) : '') : '';
            System.debug('UniqueKey ' +UniqueKey);
            if (UniqueKey.length() > 0) {
                acc = getDealerAccountInfo(UniqueKey);
            }
        } else {
            // FOR CUSTOMER HISTORY
            String UniqueKey = '';
            UniqueKey = resultMap.containsKey('parentGroup') ? (String.IsNotBlank(String.valueOf(resultMap.get('parentGroup'))) ? String.valueOf(resultMap.get('parentGroup')) : '') : '';
            UniqueKey += resultMap.containsKey('dealerMapCode') ? (String.IsNotBlank(String.valueOf(resultMap.get('dealerMapCode'))) ? +'_' + String.valueOf(resultMap.get('dealerMapCode')) : '') : '';
            UniqueKey += resultMap.containsKey('dealerLocationCode') ? (String.IsNotBlank(String.valueOf(resultMap.get('dealerLocationCode'))) ? +'_' + String.valueOf(resultMap.get('dealerLocationCode')) : '') : '';
            if (UniqueKey.length() > 0) {
                acc = getDealerAccountInfo(UniqueKey);
            }
        }

        return acc;
    }
    private static Opportunity getEnquiryInfoViaJson(String parentEnquiryJSON) {
        system.debug('parentEnquiryJSON' + parentEnquiryJSON);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(parentEnquiryJSON);
        Opportunity opp = new Opportunity();
        opp.Booking_Number__c = resultMap.containsKey('booking') ? (String.IsNotBlank(String.valueOf(resultMap.get('booking'))) ? String.valueOf(resultMap.get('booking')) : null) : null;
        opp.Invoice_Number__c = resultMap.containsKey('invoice') ? (String.IsNotBlank(String.valueOf(resultMap.get('invoice'))) ? String.valueOf(resultMap.get('invoice')) : null) : null;
        String variantCode = resultMap.containsKey('variantCode') ? (String.IsNotBlank(String.valueOf(resultMap.get('variantCode'))) ? String.valueOf(resultMap.get('variantCode')) : null) : null;
        String colorCode = resultMap.containsKey('colorCode') ? (String.IsNotBlank(String.valueOf(resultMap.get('colorCode'))) ? String.valueOf(resultMap.get('colorCode')) : null) : null;
        if (variantCode != null) {
            List<Product2> variants = new List<Product2>();
            variants = [SELECT Id,ProductCode, Model__c,LOB__c FROM Product2 WHERE ProductCode = :variantCode AND RecordType.DeveloperName = :ConstantsUtility.TD_PRODUCT_VARIANT_RECORDTYPE LIMIT 1];
            if (variants.size() > 0) {
                opp.Model_Code__c = variants[0].Model__c;
                opp.Variant__c = variants[0].Id;
                opp.Dealership_Channel__c = variants[0].LOB__c;
                if (colorCode != null) {
                    List<Color_Variant_Master__c> colorVariantMasters = new List<Color_Variant_Master__c>();
                    colorVariantMasters = [SELECT Id FROM Color_Variant_Master__c WHERE Variant__c = :variants[0].Id AND Color_Code__c = :colorCode];
                    opp.Color__c = colorVariantMasters.size() > 0 ? colorVariantMasters[0].Id : null;
                }
            }
        }
        return opp;
    }

    private static Account getDealerAccountInfo(String externalId) {
        List<Account> accounts = new List<Account>();
        accounts = [
                Select Id,Name,Zone__c,Dealer_Code__c,Dealer_Type__c,Channel__c,For_Code__c,Region_Code__c,Dealer_Category__c,
                        BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode,Phone,Outlet_Code__c,For_Code__r.For_Code__c
                from Account
                where (Id = :externalId OR External_Id__c = :externalId) AND RecordType.Name = :ConstantsUtility.DEALER_RECORDTYPE
                LIMIT 1
        ];
        if(accounts.size() > 0){
            return accounts[0];
        }
        return null;
    }
    @AuraEnabled
    public static Id createCase(String caseString,String parentRecordId) {
        try {
            Case caseObj = (Case) System.JSON.deserialize(caseString, Case.class);
            if (caseObj != null) {
                if(parentRecordId !=null){
                    Object obj = parentRecordId;
                    if (obj instanceof Id) {
                        caseObj.AssetId = Id.valueOf(parentRecordId).getSObjectType().getDescribe().getName() == 'Asset' ? parentRecordId : null;
                    }
                }
                upsert caseObj;
                return caseObj.Id;
            }
        } catch (DmlException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
        } catch (Exception exp) {
            System.debug('Exception Message ' + exp.getMessage() + ' At Line  ::' + exp.getLineNumber());
            throw new AuraHandledException(exp.getMessage());
        }
        return null;
    }
    private static Map<String, List<String>> getBusinessDependency() {
        Map<String, List<String>> channelCaseTypeVsBusinessAreasMap = new Map<String, List<String>>();
        for (Case_Picklist_Field_Filters__c fieldFilters : [SELECT Channel__c,Case_Type__c,Business_Area__c FROM Case_Picklist_Field_Filters__c]) {
            String key = fieldFilters.Channel__c + ConstantsUtility.UNDER_SCORE + fieldFilters.Case_Type__c;
            channelCaseTypeVsBusinessAreasMap.put(key, new List<String>());
            if (fieldFilters.Business_Area__c != null) {
                channelCaseTypeVsBusinessAreasMap.put(key, fieldFilters.Business_Area__c.split(ConstantsUtility.COMMA));
            }
        }
        return channelCaseTypeVsBusinessAreasMap;
    }

}