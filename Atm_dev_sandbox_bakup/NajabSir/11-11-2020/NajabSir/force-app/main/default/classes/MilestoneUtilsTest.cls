/**
 * @File Name          : MilestoneUtilsTest.cls
 * @Description        : Test Class of the apex class 'MilestoneUtils'
 * @Author             : Deepak Kumar
**/

@IsTest
private class MilestoneUtilsTest {

    @testSetup static void createTestData() {
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert businessAccountList;
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        Entitlement entitlement = new entitlement(name = 'Test Entitlement', accountId = personAccountList[0].id, type = 'Gateway Support', StartDate = Date.today().addDays(-2), EndDate = Date.today().addYears(2));
        insert entitlement;
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name = 'ATM Complaints Entitlement Process' and IsActive = true LIMIT 1];
        if (lstEntitlementProcess.size() > 0) {
            entitlement.SlaProcessId = lstEntitlementProcess[0].id;
            update entitlement;
        }
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Priority = 'High';
            c.FCR_Conducted__c = 'No';
            c.Channel__c = 'Arena';
            c.Case_Type__c = 'Complaint';
            c.Business_Area__c = 'Sales';
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Dealer_Code__c = '098';
            c.EntitlementId = entitlement.Id;
            c.slaStartDate =  Date.today();
            c.FCR_Conducted__c =  ConstantsUtility.YES;
        }
        insert casesList;
    }
    static testMethod void sendChatterNotificationTest() {
        Test.startTest();

     //   List<Account> accounts = [SELECT Id FROM Account LIMIT 1];

        List<Case> cases = [SELECT Id,EntitlementId FROM Case LIMIT 1];
        Set<Id> caseIdsToCompleteFirstMileStone = new Set<Id>();
        caseIdsToCompleteFirstMileStone.add(cases[0].Id);
        List<String> milestoneNames = new List<String>();
        milestoneNames.add(ConstantsUtility.CASE_MILESTONE_FIRST_RESPONSE);
        MilestoneUtils.completeMilestone(caseIdsToCompleteFirstMileStone, milestoneNames, DateTime.now());
        Test.stopTest();
    }
}