/**
 * @description       :
 * @author            : Rajesh Ramachandran
 * @group             :
 * @last modified on  : 10-19-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   10-19-2020   Rajesh Ramachandran   Initial Version
**/
@isTest
public class OptyAssignDCCSPOCTest {

    static list<User> spocUser = new list<User>();

    @testSetup
    static void createTestData(){

		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;

        Custom_Validation_Exception_Setting__c cv = new Custom_Validation_Exception_Setting__c();
        cv.Name = 'All';
        cv.Referral_Logic_Run__c = true;
        cv.Bypass_Validation_Rules__c= true;
        cv.AvoidStageChanges__c = ':Pre-Booking:Retail:Delivery/Closed Won:Closed Lost:';
        cv.Bypass_Opportunity_Process_Builders__c = true;
        Insert cv;

        CDC_TimeSet__c cdc = new CDC_TimeSet__c();
        cdc.Name = 'First';
        cdc.TimeSetUp__c = system.today();

        Insert cdc;

        GlobalSwitchOn__c gs = new GlobalSwitchOn__c();
        gs.Name = 'Email';
        gs.Create_Dummy_Account__c = true;

        Insert gs;

        // Custom Setting
        List<Implementation_Strategy__c> isCSList = new List<Implementation_Strategy__c>();
        isCSList.add(TestDataFactory.createIS('1','Record Type','OpportunityVehicleTriggerServiceImpl','Vehicle_Sales','OpportunityTriggers'));
        isCSList.add(TestDataFactory.createIS('2','Record Type','OpportunityMSDSTriggerServiceImpl','MSDS','OpportunityTriggers'));
        isCSList.add(TestDataFactory.createIS('3','Record Type','OpportunityAccessoriesTriggerServiceImpl','Accessories_Sales','OpportunityTriggers'));
        isCSList.add(TestDataFactory.createIS('4','Record Type','OpportunityLoyaltyTriggerServiceImpl','Loyalty_Enrollment','OpportunityTriggers'));
	    isCSList.add(TestDataFactory.createIS('5','Record Type','OpportunityPartsTriggerServiceImpl','Parts','OpportunityTriggers'));

        Insert isCSList;

        //Create Spoc user

    }

    @isTest static void testDCCAssignEnquirytoSalesSPOC(){

        String recortype2 = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

        List<User> userDetail = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id in:spocUser];
        Account acc = new Account();
        acc.name ='Test Nexa';
        acc.Sales_SPOC_1__c = spocUser[0].Id;
        acc.Sales_SPOC_2__c = spocUser[0].Id;
        acc.Sales_SPOC_3__c = spocUser[0].id;
        acc.Sales_SPOC_4__c = spocUser[0].id;
        acc.Sales_SPOC_5__c = spocUser[0].id;
        acc.Accessories_SPOC_1__c = spocUser[0].id;
        acc.Accessories_SPOC_2__c = spocUser[0].id;
        acc.Territory_Sales_Manager__c = spocUser[0].id;
        acc.Finance_Manager__c = spocUser[0].id;
        acc.TSM_ISL__c = spocUser[0].id;
        acc.TSM_Rural__c = spocUser[0].id;
        acc.TSM_MGA__c = spocUser[0].id;
        acc.Id = userDetail[0].Contact.AccountId;
        update acc;

        List<Contact> conList1 = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList1;


        List<User> lsuser = TestDataFactory.createUserData('Portal', 'Call Center Executive Service', conList1);
        insert lsuser;

        List<User> userDetail1 = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id = :lsuser[0].Id];

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        Test.startTest();
        system.runAs(lsuser[0]){

            List<Opportunity> oppList2 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            List<Opportunity> oppList3 = TestDataFactory.createTestOpportunity(1, 'MSDS');
            List<Opportunity> oppList4 = TestDataFactory.createTestOpportunity(1, 'Accessories Sales');
            oppList2.addAll(oppList3);
            oppList2.addAll(oppList4);

            for(Opportunity opp : opplist2){
                opp.StageName = 'New';
               // opp.Customer__c= personAccountList[0].Id;
               // opp.ownerId = userDetail[0].id;
                opp.Dealership__c = accList[0].Id;
               // opp.Accessories_DSE1__c = lsuser[0].Id;
               // opp.RecordTypeId = recortype2;
                opp.Vehicle_Registration__c = '12345';
            }
            insert opplist2;
        }
        Test.stopTest();
    }

}