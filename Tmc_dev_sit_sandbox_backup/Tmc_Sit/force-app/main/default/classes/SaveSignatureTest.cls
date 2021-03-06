@isTest(seeAllData = false)
public class SaveSignatureTest {

    @testsetup
    static void testrecordcreate(){
         // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        insert opplist;
    }
    
    @istest
    static void testcreate(){
        list<opportunity> opplistt = new list<opportunity>([SELECT id from opportunity]);
        SaveSignature.saveSignatureMethod('testsignature',opplistt[0].Id);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
    }
}