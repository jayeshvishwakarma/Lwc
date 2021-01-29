@isTest
public class ChangeMSGAEnquiryOwnerTest {
@testSetup
    static void CreateRecords(){
	 // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS.Strategy_Key__c = 'Accessories_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';

        Insert IS;

        List<Account> accList1 = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert accList1;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Accessories Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'Open';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = UserInfo.getUserId();


        insert oppList;

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        list<User> userList = TestDataFactory.createUserData('Portal', 'Dealer Accessories User', conList);
        //userList[0].Name = 'acc M';
        userList[0].Designation__c = 'ACM';
        //userList[0].IsPortalEnabled = true;
        insert userList;
    }


    @isTest
    static void test1(){
        test.startTest();
        List<user> userList = new list<User>([SELECT id , name , Designation__c from user where LastName = 'Testing']);
        system.debug('Rohit '+userList[0].Name);
        system.debug('Rohit1 '+userList[0].Designation__c);
        System.runAs(userList[0]){

            List<Account> accList1 = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert accList1;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Accessories Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'Open';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = UserInfo.getUserId();


        insert oppList;
            List<Account> accList2 = new list<Account>([SELECT id from Account]);
            List<opportunity> oppList1 = new list<opportunity>([SELECT id from opportunity where First_Name__c =  'John']);
            System.debug('OOp '+ oppList1);
            ChangeMSGAEnquiryOwner.fetchDetails();


            ChangeMSGAEnquiryOwner.getUserList(accList2[0].Id,'Test');
            String id = '["'+oppList1[0].Id+'\"]';
            ChangeMSGAEnquiryOwner.updateEnqOwner(id,userList[0].Id);
        }
        test.stopTest();
    }

    @isTest
    static void test2(){
        test.startTest();
        List<user> userList = new list<User>([SELECT id , name , Designation__c from user where LastName = 'Testing']);
        system.debug('Rohit '+userList[0].Name);
        system.debug('Rohit1 '+userList[0].Designation__c);
        System.runAs(userList[0]){

            List<Account> accList1 = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert accList1;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Accessories Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'Open';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = UserInfo.getUserId();


        insert oppList;
            List<Account> accList2 = new list<Account>([SELECT id from Account]);
            List<opportunity> oppList1 = new list<opportunity>([SELECT id from opportunity where First_Name__c =  'John']);
            System.debug('OOp '+ oppList1);
            ChangeMSGAEnquiryOwner.fetchDetails();


            ChangeMSGAEnquiryOwner.getUserList(accList2[0].Id,'Test');
            //String id = '["'+oppList1[0].Id+'\"]';
            ChangeMSGAEnquiryOwner.updateEnqOwner(oppList1[0].Id,userList[0].Id);
        }
        test.stopTest();
    }

}