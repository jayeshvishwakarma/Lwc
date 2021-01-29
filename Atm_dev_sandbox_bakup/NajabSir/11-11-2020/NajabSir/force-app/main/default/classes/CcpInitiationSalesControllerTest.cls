/**
* @File Name          : CcpInitiationSalesControllerTest.cls
* @Description        : Test Class of the apex class 'CcpInitiationSalesController'
* @Author             : Deepak Kumar
**/
@IsTest
private class CcpInitiationSalesControllerTest {
    
    @testSetup static void createTestData() {
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;
        List<Contentversion> contentVersions = TestDataFactory.createContentversion(1,'Others');
        insert contentVersions;
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = casesList[0].id;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.ContentDocumentId = [select Id,ContentDocumentId from ContentVersion WHERE Id = :contentVersions[0].Id].ContentDocumentId;
        insert contentDocumentLink;
        
        Case_Actions__c caseActions = new Case_Actions__c();
        caseActions.Name = 'Transfer';
        caseActions.Case_Number__c = casesList[0].Id;
        caseActions.RecordTypeId = ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID;
        caseActions.Approval_Status__c = ConstantsUtility.In_Progress;
        insert caseActions;
        
    }
    static testMethod void getCcpOnloadInfoTest() {
        Test.startTest();
        Case caseObj = [SELECT Id,Case_Type__c FROM Case LIMIT 1];
        Case_Actions__c actions  = [SELECT Approval_Status__c FROM Case_Actions__c LIMIT 1];
        actions.Approval_Status__c  = ConstantsUtility.In_Progress;
        update actions;
        CcpInitiationSalesController.getCcpOnloadInfo(caseObj.Id, 'CCP');
        Test.stopTest();
    }
    static testMethod void updateFileUniqueNameTest() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id,ContentDocumentId,FileUniqueName__c,ContentUrl,title FROM ContentVersion LIMIT 1];
        Case caseObj = [SELECT Id,Case_Type__c FROM Case LIMIT 1];
        CcpInitiationSalesController.updateFileUniqueName(contentVersion.ContentDocumentId, '1234',caseObj.Id,'CCP');
        Test.stopTest();
    }
    static testMethod void updateCaseWithCCPP_RejectedTest() {
        Test.startTest();
        Case caseObj = [SELECT Id,Case_Type__c FROM Case LIMIT 1];
        CcpInitiationSalesController.updateCaseWithCCP(caseObj,true);
        Test.stopTest();
    }
    static testMethod void updateCaseWithCCPP_InProgressTest() {
        Test.startTest();
        Case caseObj = [SELECT Id,Case_Type__c FROM Case LIMIT 1];
        Case_Actions__c actions  = [SELECT Approval_Status__c FROM Case_Actions__c LIMIT 1];
        actions.Approval_Status__c  = ConstantsUtility.In_Progress;
        update actions;
        CcpInitiationSalesController.updateCaseWithCCP(caseObj,true);
        Test.stopTest();
    }
    static testMethod void updateCaseWithCCPP_NoCaseActionTest() {
        Test.startTest();
        Case caseObj = [SELECT Id,Case_Type__c FROM Case LIMIT 1];
        Case_Actions__c actions  = [SELECT Id FROM Case_Actions__c LIMIT 1];
        delete actions;
        CcpInitiationSalesController.updateCaseWithCCP(caseObj,true);
        Test.stopTest();
    }
}