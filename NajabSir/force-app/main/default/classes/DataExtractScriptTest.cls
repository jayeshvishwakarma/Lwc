@istest
public class DataExtractScriptTest {
    @testSetup
    static void CreateRecord(){
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = userinfo.getUserId();
        oppList[0].Booking_Number__c = '123';
        oppList[0].Booking_Date__c = System.today().addDays(-8);
        insert oppList;
        
        list<MC_Communication__c> Mclist = testdataFactory.createMCCommData(1,oppList[0].id);
        Mclist[0].Type__c = 'BCR';
        insert Mclist;
    }
    
    @istest
    static void testing(){
        list<MC_Communication__c> Mclist = new list<MC_Communication__c>([SELECT id,type__c,CreatedDate from MC_Communication__c]);
        System.debug('Mclist'+Mclist.size());
        List<Opportunity> oppList = new list<opportunity>([SELECT id from opportunity]);
        System.debug('oppList'+oppList.size());
        Datetime start =System.today().addDays(-1);
        Datetime endd = System.today().addDays(1);
        DataExtractScript.extractData(start,endd);
    }
}