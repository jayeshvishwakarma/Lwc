/**
 * @File Name          : ApproveRejectComponentControllerTest.cls
 * @Description        : Test Class of the apex class 'ApproveRejectComponentController'
 * @Author             : Deepak Kumar
**/

@IsTest
private class ApproveRejectComponentControllerTest {
    @testSetup static void createTestData() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
        insert internalUsers;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;


        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;
        System.debug(casesList[0].Stakeholders_JSON__c);
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        insert caseActions;
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(caseActions[0].id);
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(internalUsers[0].Id);
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId(ConstantsUtility.CASE_TRANSFER_APPROVAL_NAME);
        req1.setSkipEntryCriteria(true);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1); //uncommented this to make test class work as request needs to be submitted for generating workitem object record
     //   System.debug('result :: '+result);
    }

    static testMethod void isCurrentAndAssignUserIsSameTest() {
        Test.startTest();
        List<Case_Actions__c> caseActions = [SELECT Id FROM Case_Actions__c LIMIT 1];
        ApproveRejectComponentController.isCurrentAndAssignUserIsSame(caseActions[0].Id);
        Test.stopTest();
    }
    static testMethod void isCurrentAndAssignUserIsSameTest2() {
        Test.startTest();
        List<Case> cases = [SELECT Id FROM Case LIMIT 1];
        ApproveRejectComponentController.isCurrentAndAssignUserIsSame(cases[0].Id);
        Test.stopTest();
    }
    static testMethod void updateApprovalActionTest() {
        Test.startTest();
        List<Case_Actions__c> caseActions = [SELECT Id FROM Case_Actions__c LIMIT 1];
        ApproveRejectComponentController.updateApprovalAction(caseActions[0].Id, 'Reject', 'none');
        Test.stopTest();
    }
}