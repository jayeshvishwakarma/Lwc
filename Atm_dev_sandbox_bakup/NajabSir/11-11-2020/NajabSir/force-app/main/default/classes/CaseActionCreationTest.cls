/**
* @File Name          : MCCommunicationServiceTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationService'
* @Author             : Gitika
**/
@IsTest
public class CaseActionCreationTest {
    @testSetup static void createTestData() {
        
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.FCR_Conducted__c = 'Yes';
        }
        insert casesList;
    }
    static testMethod void method1() {
        Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,ConstantsUtility.SEND_BACK_TO_QUERY_MANAGEMENT_TEAM,'test');
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,ConstantsUtility.RESPONDED_VIA_SF,'test');
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,ConstantsUtility.RESPONDED_VIA_OUTLOOK,'test');
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,'No Response Required','test');
        Test.stopTest();
    }
    static testMethod void method2() {
        Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
        
        CaseActionCreation.updateCaseStatusResolved(casesList[0].id);
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        
        insert caseActions;
        CaseActionCreation.callApprovalFlow(caseActions[0].id,'Case_Closure');
        FileUtility__c FileUtilityRecord = TestDataFactory.createFileUtilitySetting('Case_Closure','Case_Closure');
        insert FileUtilityRecord;
        CaseActionCreation.fetchcaseAction(caseActions[0].id,'Case_Closure');
        CaseActionCreation.getQueueId();
        Test.stopTest();
    }
    static testMethod void method3() {
        Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        
        insert caseActions;
        
        Test.stopTest();
    }
}