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
        List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        Implementation_Strategy__c ImplementationStrategyRecord2 = TestDataFactory.createImplementation('CaseMIRenewalTriggerServiceImpl','MI_Renewal');
        Implementation_Strategy__c ImplementationStrategyRecord3 = TestDataFactory.createImplementation('CaseDoNoCallRequestsTriggerServiceImpl','Do_No_Call_Requests');
        Implementation_Strategy__c ImplementationStrategyRecord4 = TestDataFactory.createImplementation('CaseDICTriggerServiceImpl','Dealer_Internal_Complaint');
        Implementation_Strategy__c ImplementationStrategyRecord5 = TestDataFactory.createImplementation('CaseDIFTriggerServiceImpl','Dealer_Internal_Feedback');
        Implementation_Strategy__c ImplementationStrategyRecord6 = TestDataFactory.createImplementation('CaseDIRTriggerServiceImpl','Dealer_Internal_Request');
        Implementation_Strategy__c ImplementationStrategyRecord7 = TestDataFactory.createImplementation('CaseDIQTriggerServiceImpl','Dealer_Internal_Query');
        impList.add(ImplementationStrategyRecord1);
        impList.add(ImplementationStrategyRecord2);
        impList.add(ImplementationStrategyRecord3);
        impList.add(ImplementationStrategyRecord4);
        impList.add(ImplementationStrategyRecord5);
        impList.add(ImplementationStrategyRecord6);
        impList.add(ImplementationStrategyRecord7);
        Database.insert(impList,false);
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dealer_Internal_Complaint').getRecordTypeId();
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