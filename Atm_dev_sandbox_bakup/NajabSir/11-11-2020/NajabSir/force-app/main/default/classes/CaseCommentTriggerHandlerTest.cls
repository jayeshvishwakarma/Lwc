/**
* @File Name          : CaseCommentTriggerHandlerTest.cls
* @Description        : Test Class of the apex class 'CaseCommentTriggerHandler'
* @Author             : Deepak Kumar
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    24/9/2020, 9:26:51 AM          Gitika                     
*/
@IsTest
private class CaseCommentTriggerHandlerTest {
    @testSetup static void createTestData() {
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;
        List<CaseComment> caseComments = TestDataFactory.createCaseComments(1,casesList[0].Id);
        insert caseComments;
    }
    static testMethod void allEventsTest() {
        Test.startTest();
        List<Case> cases  = [SELECT Id,Additional_Information__c FROM Case];
        List<CaseComment> caseComments  = [SELECT Id,CommentBody FROM CaseComment];
        System.assertEquals(cases[0].Additional_Information__c,caseComments[0].CommentBody,'Case Addition info and Case Comment body should be same');
        caseComments[0].CommentBody='test';
        update caseComments[0];
        Test.stopTest();
    }
}