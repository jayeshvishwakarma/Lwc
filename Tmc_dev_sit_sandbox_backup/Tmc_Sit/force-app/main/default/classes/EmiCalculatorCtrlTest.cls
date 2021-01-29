@isTest
public class EmiCalculatorCtrlTest {
    static list<User> spocUser = new list<User>();
    @testSetup 
    static void CreateRecord(){
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
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
        
        //Create Business Account 
        list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
        objList[0].user__c = spocUser[0].id;
        objList[0].Territory_Sales_Manager__c = userDetail[0].id;
        objList[0].TSM_ISL__c = userDetail[0].id;
        insert objList;
        
        //Create Product
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
       
        //Create Vehicle Enquiry
        String recortype = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        String recortype2 = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Accessories Sales').getRecordTypeId();
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        
        for(Opportunity opp : opplist){
            opp.Dealership__c = acc.Id;
            opp.Accessories_DSE1__c = spocUser[0].id;
            opp.Type_of_Escalation__c = 'DSE Allocation Time';
            opp.Time_for_Next_Escalation__c = DateTime.newInstance(2019, 11, 15, 11, 25, 33);
            opp.RecordTypeId = recortype;
        }
        insert opplist;
    }
    
    @isTest
    static void retrieveEnquiryDetailsTest(){
        list<opportunity> oppList = new list<opportunity>([SELECT id from  opportunity]);
        EmiCalculatorCtrl.retrieveEnquiryDetails(oppList[0].id);
        EmiCalculatorCtrl.queryFinancierRecords('Test','Test');
        EmiCalculatorCtrl.RetrieveUser();
    }
}