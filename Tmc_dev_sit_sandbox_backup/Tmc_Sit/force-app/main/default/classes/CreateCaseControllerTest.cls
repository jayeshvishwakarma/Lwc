/**
* @File Name          : CreateCaseControllerTest.cls
* @Description        : Test Class of the apex class 'CreateCaseController'
* @Author             : Deepak Kumar
**/
@IsTest
private class CreateCaseControllerTest {
    @testSetup static void createTestData() {
        
        List<Implementation_Strategy__c> implList = new List<Implementation_Strategy__c>();
        
        implList.add(TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint'));
        implList.add(TestDataFactory.createIS('111', 'Record Type', 'OpportunityVehicleTriggerServiceImpl','Vehicle_Sales', 'OpportunityTriggers'));
        
        insert implList;
        
        Approval_Notification_Setting__c notificationSetting = TestDataFactory.createApprovalNotificationSetting('On_Hold', true);
        insert notificationSetting;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert businessAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        List<Category__c> primaryCategories = TestDataFactory.createCategories(1, 'Primary');
        insert primaryCategories;
        List<Category__c> secondaryCategories = TestDataFactory.createCategories(1, 'Secondary');
        secondaryCategories[0].Primary_Category__c = primaryCategories[0].Id;
        insert secondaryCategories;
        
        List<Category__c> tertiaryCategories = TestDataFactory.createCategories(1, 'Tertiary');
        tertiaryCategories[0].Primary_Category__c = primaryCategories[0].Id;
        insert tertiaryCategories;
        
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.FCR_Conducted__c = 'No';
            c.Primary_Category_ID__c = primaryCategories[0].Id;
            c.Secondary_Category_ID__c = secondaryCategories[0].Id;
            c.Tertiary_Category_ID__c = tertiaryCategories[0].Id;
        }
        insert casesList;
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        caseActions[0].Primary_Category_ID__c = primaryCategories[0].Id;
        caseActions[0].Secondary_Category_ID__c = secondaryCategories[0].Id;
        insert caseActions;
        
        //Product List
        list<Product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        productList[0].ProductCode = '12345';
        Insert productList;
        
        List<Asset> assets = TestDataFactory.CreateAssetsRecords(productList);
        assets[0].AccountId = personAccountList[0].Id;
        assets[0].ContactId = personAccountList[0].PersonContactId;
        insert assets;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = personAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c = personAccountList[0].PersonContactId;
        Opportunity opp = oppList[0];
        opp.First_Name__c = 'Test Dealer';
        opp.Dealership__c = businessAccountList[0].Id;
        insert oppList;
        
        List<Survey_Taker_CTI__c> lstSurveyTakers = TestDataFactory.createSurveyTakerCTI();
        insert lstSurveyTakers;
        
        List<ContentVersion> lstContentVersions = TestDataFactory.createContentVersion(1, 'TestRecord');
        insert lstContentVersions;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstContentVersions[0].Id].ContentDocumentId;
        
        ContentDocumentLink contentDocumentLink = TestDataFactory.createContentDocumentLink(conDoc, personAccountList[0].id); 
        insert contentDocumentLink;
        
        List<Case_Picklist_Field_Filters__c> casePicklistFilters = TestDataFactory.createCasePicklistFilters();
        insert casePicklistFilters;
        
        List<Color_Variant_Master__c> lstVariantMasters = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].id);
        insert lstVariantMasters;
        
    }
    static testMethod void getOnloadInfoForCaseActionWithCaseActionTest() {
        Test.startTest();
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        List<Case_Picklist_Field_Filters__c> casePicklistFilters = [SELECT Channel__c,Case_Type__c,Business_Area__c FROM Case_Picklist_Field_Filters__c LIMIT 1];
        Case_Actions__c caseActions = [SELECT Id FROM Case_Actions__c LIMIT 1];
        CreateCaseController.getOnloadInfoForCaseAction(caseObj.Id, caseActions.Id,null);
        Test.stopTest();
    }
    static testMethod void getOnloadInfoForCaseActionWithOutCaseActionTest() {
        Test.startTest();
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        List<Case_Picklist_Field_Filters__c> casePicklistFilters = [SELECT Channel__c,Case_Type__c,Business_Area__c FROM Case_Picklist_Field_Filters__c LIMIT 1];
        CreateCaseController.getOnloadInfoForCaseAction(caseObj.Id, null,caseObj.Id);
        Test.stopTest();
    }
    
    static testMethod void getOnloadInfoForCaseActionWithOutCaseActionAndWithoutparentCaseIdTest() {
        Test.startTest();
        CreateCaseController.getOnloadInfoForCaseAction(null, null, null);
        Test.stopTest();
    }
    
    static testMethod void getOnloadInfoForCaseFromAccountTest() {
        Test.startTest();
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Case_Picklist_Field_Filters__c> casePicklistFilters = [SELECT Channel__c,Case_Type__c,Business_Area__c FROM Case_Picklist_Field_Filters__c LIMIT 1];
        CreateCaseController.getOnloadInfoForCase(account.Id, null);
        Test.stopTest();
    }
    static testMethod void getOnloadInfoForCaseFromAssetTest() {
        Test.startTest();
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        CreateCaseController.getOnloadInfoForCase(asset.Id, null);
        Test.stopTest();
    }
    static testMethod void getOnloadInfoForCaseFromOpportunityTest() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        CreateCaseController.getOnloadInfoForCase(opp.Id, caseObj.Id);
        Test.stopTest();
    }
    static testMethod void getOnloadInfoForCaseFromCustomerHistoryJSONTest() {
        Test.startTest();
        List<Color_Variant_Master__c> lstVariantMasters = [SELECT Id, Variant__C FROM Color_Variant_Master__c LIMIT 1];
        list<Product2> productList = [SELECT Id, Name, Model__c, LOB__c, ProductCode FROM Product2 LIMIT1];
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account personAccount = [SELECT Id FROM Account WHERE RecordTypeId = :AccRecTypeId LIMIT 1];
        // Sample Json
        String JsonString = '{ "personAccountId": "' + personAccount.Id + '", "messageId": "6d811b50-dc55-11ea-954e-06a280817922", "status": "Success", "variantCode":"12345", "colorCode":"ZQM" , "customerEnquiriesList": [ { "Stage": "Invoiced ", "Model": "MARUTI ALTO LXI", "Source": "References", "TestDrive": false, "Exchange": false, "variant": "MARUTI ALTO LXI", "dealerName": "ATUL MOTORS PVT. LIMITED", "dateOfTransaction": "2020-03-12T16:00:32", "dealerAddress": "PLOT NO.49/1 & 2, GIDC, BHAKTI NAGAR INDUSTRIAL ESTATE RAJKOT", "outletType": "Outlet", "booking": "SOB19002594", "invoice": "VSL/19001736", "parentGroup": "ATUL", "dealerMapCode": 10720, "dealerLocationCode": "RAJ", "status": null, "enquiryType": null, "purchasedVehicle": null, "soldVehicle": null, "programType": null, "enrollmentDate": null, "enrollmentId": null, "invoiceTv": null } ] }';
        CreateCaseController.getOnloadInfoForCase(JsonString, null);
        Test.stopTest();
    }
    static testMethod void getOnloadInfoForCaseFromServiceHistoryJSONTest() {
        Test.startTest();
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account personAccount = [SELECT Id FROM Account WHERE RecordTypeId = :AccRecTypeId LIMIT 1];
        // Sample Json
        String JsonString = '{ "createFrom": "ServiceHistory","personAccountId": "' + personAccount.Id + '", "messageId": "6d811b50-dc55-11ea-954e-06a280817922", "status": "Success",  "colorCode":"ZQM", "variantCode":"12345" , "customerEnquiriesList": [ { "Stage": "Invoiced ", "Model": "MARUTI ALTO LXI", "Source": "References", "TestDrive": false, "Exchange": false, "variant": "MARUTI ALTO LXI", "dealerName": "ATUL MOTORS PVT. LIMITED", "dateOfTransaction": "2020-03-12T16:00:32", "dealerAddress": "PLOT NO.49/1 & 2, GIDC, BHAKTI NAGAR INDUSTRIAL ESTATE RAJKOT", "outletType": "Outlet", "booking": "SOB19002594", "invoice": "VSL/19001736", "parentGroup": "ATUL", "dealerMapCode": 10720, "locationCode": "RAJ", "status": null, "enquiryType": null, "purchasedVehicle": null, "soldVehicle": null, "programType": null, "enrollmentDate": null, "enrollmentId": null, "invoiceTv": null } ] }';
        CreateCaseController.getOnloadInfoForCase(JsonString, null);
        Test.stopTest();
    }
    
    static testMethod void getOnloadInfoForCaseFromCaseTest() {
        Test.startTest();
        Account account = [SELECT Id FROM Account LIMIT 1];
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        CreateCaseController.getOnloadInfoForCase(account.Id, caseObj.Id);
        Test.stopTest();
    }
    static testMethod void getCaseRecordTypeTest() {
        Test.startTest();
        Case caseObj = [SELECT Id,Case_Type__c FROM Case LIMIT 1];
        CreateCaseController.getCaseRecordType(caseObj.Case_Type__c);
        Test.stopTest();
    }
    static testMethod void getCategoryRecordsApexTest() {
        Test.startTest();
        String categoryQuery = 'SELECT Id,Name FROM Category__c';
        CreateCaseController.getCategoryRecordsApex(categoryQuery);
        Test.stopTest();
    }
    static testMethod void getObjectsTest() {
        Test.startTest();
        String categoryQuery = 'SELECT ID FROM Category__c';       
        CreateCaseController.getObjects(categoryQuery, 'Test');      
        Test.stopTest();
    }
    
    static testMethod void getObjectsTestWithWhere() {
        Test.startTest(); 
        string searchKey = 'test';
        String categoryQuery2 = 'SELECT ID FROM Account WHERE Name =: searchKey';
        CreateCaseController.getObjects(categoryQuery2, 'Test');
        Test.stopTest();
        
    }
    
    
    static testMethod void createCaseTest() {
        Test.startTest();
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Case caseObj = [SELECT Id,Case_Stage__c FROM Case LIMIT 1];
        CreateCaseController.createCase(JSON.serialize(caseObj),asset.Id);
        Test.stopTest();
    }
    
    static testMethod void getSurveyTakerCustomerDetail() {	
        Test.startTest();
        List<Survey_Taker_CTI__c> lstSurveyTakers = [SELECT id FROM Survey_Taker_CTI__c LIMIT 1];
        CreateCaseController.getSurveyTakerCustomerDetail(lstSurveyTakers[0].id);
        Test.stopTest();
    }
    
    static testMethod void getDealerInfo() {
        Test.startTest();
        List<Account> personAccountList = [SELECT id FROM Account LIMIT 1];
        CreateCaseController.getDealerInfo(personAccountList[0].id);
        Test.stopTest();
    }
    
    static testMethod void getDealerInfoWihoutAccountId() {
        Test.startTest();
        CreateCaseController.getDealerInfo(null);
        Test.stopTest();
    }
    
    static testMethod void getUpdateCase() {
        Test.startTest();   
        List<ContentVersion> lstContentVersions = [SELECT id FROM ContentVersion];
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstContentVersions[0].Id].ContentDocumentId;
        System.debug('Id==========<<<<<<<<<<<'+conDoc);
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Object obj = asset.id;
        
        Case caseObj = [SELECT Id,Case_Stage__c FROM Case LIMIT 1];
        if (obj instanceof Id) {
            caseObj.AssetId = Id.valueOf(asset.id).getSObjectType().getDescribe().getName() == 'Asset' ? asset.id : null;
        }
        caseObj.Suzuki_Connect_Remark__c = 'Suzuki Connect_Remark Test';
        upsert caseObj;
        CreateCaseController.updateCase(JSON.serialize(caseObj),conDoc);
        Test.stopTest();
    }
    
    static testMethod void getUpdateCaseWithoutContentId() {
        Test.startTest();   
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Object obj = asset.id;
        Case caseObj = [SELECT Id,Case_Stage__c FROM Case LIMIT 1];
        if (obj instanceof Id) {
            caseObj.AssetId = Id.valueOf(asset.id).getSObjectType().getDescribe().getName() == 'Asset' ? asset.id : null;
        }
        caseObj.Suzuki_Connect_Remark__c = 'Suzuki Connect_Remark Test';
        upsert caseObj;
        CreateCaseController.updateCase(JSON.serialize(caseObj),null);
        Test.stopTest();
    }
    
}