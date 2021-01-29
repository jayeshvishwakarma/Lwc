/**
 * @File Name          : CaseTriggerStrategyHelperTest.cls
 * @Description        : Test Class of the apex class 'CaseTriggerStrategyHelper'
 * @Author             : Deepak Kumar
**/
@IsTest
private class CaseTriggerStrategyHelperTest {
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
        List<Product2> productsList = TestDataFactory.createProducts( 'Variants',1);
     	productsList[0].Model__c = 'AK';
        insert productsList;
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Case_Type__c = ConstantsUtility.COMPLAINT_CASE_TYPE;
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'Yes';
            c.Assigned_Date__c = Date.today();
            c.Model__c = 'AK'; // Added for custom validation - Model and Variant Required for Selected Case Type
            c.Variant__c = productsList[0].id; // Added for custom validation - Model and Variant Required for Selected Case Type
            c.Vehicle_Registration_Number__c = 'MH';

        }
        casesList[0].Business_Area__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        casesList[1].Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
        insert casesList;

        List<Campaign> campaigns = TestDataFactory.createCampaign(3);
        for(Integer i = 0; i > campaigns.size() ; i++){
            campaigns[i].Campaign_Code__c = '67500'+i;
            campaigns[i].RecordTypeId = ConstantsUtility.CAMPAIGN_CALL_CAMPAIGN_RECORD_TYPE_ID;
        }
        insert campaigns;

    }


    static testMethod void updateCaseResolutionTimeTest() {
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c FROM Case LIMIT 1];
        cases[0].Status = ConstantsUtility.CASE_STATUS_RESOLVED;
        cases[0].Mobile_Number__c = '9876543123';
        cases[0].Description = 'test';
        update cases;
        Test.stopTest();
    }
    static testMethod void ccpCampaignDetectionTest() {
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c FROM Case LIMIT 1];

        update cases;
        Test.stopTest();
    }

}