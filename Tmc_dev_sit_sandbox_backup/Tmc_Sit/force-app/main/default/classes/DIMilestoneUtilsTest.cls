/**
 * @File Name          : MilestoneUtilsTest.cls
 * @Description        : Test Class of the apex class 'MilestoneUtils'
 * @Author             : Deepak Kumar
**/

@IsTest
private class DIMilestoneUtilsTest {

    @testSetup static void createTestData() {
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert businessAccountList;
        //Custom setting
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
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        Entitlement entitlement = new entitlement(name = 'Test Entitlement', accountId = personAccountList[0].id, type = 'Gateway Support', StartDate = Date.today().addDays(-2), EndDate = Date.today().addYears(2));
        insert entitlement;
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name = 'Dealer Internal Entitlement Process' and IsActive = true LIMIT 1];
        if (lstEntitlementProcess.size() > 0) {
            entitlement.SlaProcessId = lstEntitlementProcess[0].id;
            update entitlement;
        }
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dealer_Internal_Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Priority = 'High';
            c.FCR_Conducted__c = 'No';
            c.Channel__c = 'Arena';
            c.Case_Type__c = 'Dealer Internal Complaint';
            c.Business_Area__c = 'Sales';
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Dealer_Code__c = '098';
            c.EntitlementId = entitlement.Id;
            c.slaStartDate =  Date.today();
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
        milestoneNames.add(ConstantsUtility.CASE_MILESTONE_CASE_CLOSURE_TIME);
        MilestoneUtils.completeMilestone(caseIdsToCompleteFirstMileStone, milestoneNames, DateTime.now());
        Test.stopTest();
    }
}