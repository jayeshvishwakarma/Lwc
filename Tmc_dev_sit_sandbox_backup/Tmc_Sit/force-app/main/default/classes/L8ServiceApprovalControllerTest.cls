/**
 * @File Name          : L8ServiceApprovalControllerTest.cls
 * @Description        : Test Class of the apex class 'L8ServiceApprovalController'
 * @Author             : Deepak Kumar
**/
@IsTest
private class L8ServiceApprovalControllerTest {
    @testSetup static void createTestData() {
        String stakeholderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Approval_Notification_Setting__c notificationSetting = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.UNJUSTIFIED_APPROVAL_L8_DECISION_NOT_UNIFIED, true);
        insert notificationSetting;
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeholderJson;
        insert businessAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;

        List<Category__c> primaryCategories = TestDataFactory.createCategories(1, 'Primary');
        insert primaryCategories;
        List<Category__c> secondaryCategories = TestDataFactory.createCategories(1, 'Secondary');
        secondaryCategories[0].Primary_Category__c = primaryCategories[0].Id;
        insert secondaryCategories;

        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.FCR_Conducted__c = 'No';
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Primary_Category_ID__c = primaryCategories[0].Id;
            c.Secondary_Category_ID__c = secondaryCategories[0].Id;
        }
        insert casesList;

        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        caseActions[0].Primary_Category_ID__c = primaryCategories[0].Id;
        caseActions[0].Secondary_Category_ID__c = secondaryCategories[0].Id;
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress;
        caseActions[0].L8A_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L8B_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L8C_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L8D_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L8E_Stakeholder__c = UserInfo.getUserId();

        insert caseActions;

    }
    static testMethod void getOnloadInfoForCaseActionWithCaseActionTest() {
        Test.startTest();
      //  Case caseObj = [SELECT Id FROM Case LIMIT 1];
        Case_Actions__c caseActions = [SELECT Id,Approval_Status__c FROM Case_Actions__c LIMIT 1];
        L8ServiceApprovalController.getCaseActionL8Approver(caseActions.Id);
        caseActions = [SELECT Id,Approval_Status__c,Service_Revalidation_JSON__c FROM Case_Actions__c LIMIT 1];

        // Updated Case
        List<L8ServiceApprovalController.ApproverWrapper> approverWrappers = (List<L8ServiceApprovalController.ApproverWrapper>) System.JSON.deserialize(caseActions.Service_Revalidation_JSON__c, List<L8ServiceApprovalController.ApproverWrapper>.class);
        for(L8ServiceApprovalController.ApproverWrapper approverWrapper : approverWrappers){
            approverWrapper.decision = 'Reject';
        }
        L8ServiceApprovalController.updateCaseAction(caseActions.Id,JSON.serialize(approverWrappers));
        approverWrappers[0].decision = 'Approve';
        L8ServiceApprovalController.updateCaseAction(caseActions.Id,JSON.serialize(approverWrappers));
        Test.stopTest();
    }
    static testMethod void updateCaseActionTest() {
        Test.startTest();
        //  Case caseObj = [SELECT Id FROM Case LIMIT 1];
        Case_Actions__c caseActions = [SELECT Id,Approval_Status__c,Service_Revalidation_JSON__c FROM Case_Actions__c LIMIT 1];
        System.debug(caseActions.Service_Revalidation_JSON__c);
      //  System.debug(jsonString);

        //L8ServiceApprovalController.updateCaseAction(caseActions.Id,jsonString);
        Test.stopTest();
    }
}