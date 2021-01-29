/**
    * @Author:- Anuj Kumar
    * @Company-: Techmatrix Consulting
    * @Description-: Test Class for Schedule class and Batch class to Mark Enquiry as Escalated
    * =============================================================
    * Version   Date             Author         Modification
    * =============================================================
    * 1.0       17 JULY 2020     Anuj Kumar     Intial Version
    **/

@isTest
private class EnquiryEscalationBatchSchedulerTest{
    
    @testsetup
    static void testrecordcreate() {
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityPartsTriggerServiceImpl';
        IS.Strategy_Key__c = ConstantsUtility.PARTS;
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
		
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;

        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
        //User Creation
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;


        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, ConstantsUtility.PARTS);
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c = personAccountList[0].Id;
        oppList[0].Time_for_Next_Escalation__c = system.today().addDays(-1);
        
        insert oppList;
    }
    
    static testMethod void testschedule1() {
        Test.StartTest();
            EnquiryEscalationBatchScheduler sh1 = new EnquiryEscalationBatchScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Escalataion Batch', sch, sh1); 
        Test.stopTest();
    }
    
    static testMethod void testschedule2() {
        Test.StartTest();
            EnquiryEscalationBatchScheduler.scheduleBatch();
        Test.stopTest();
    }
    
    static testMethod void testschedule3() {
        Test.StartTest();
            EnquiryEscalationBatchScheduler.scheduleBatch('0 0 23 * * ?');
        Test.stopTest();
    }
}