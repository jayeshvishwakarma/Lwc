@isTest(seeAllData = false)
public class SVOCSearchUtilityTest {
    @testsetup
    static void testrecordcreate(){
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        for(opportunity opp : opplist){
            opp.First_Name__c = 'pro';
            opp.Last_Name__c = 'test';
            opp.Email__c = 'A@blah.com';
            opp.Mobile__c = '6788868660';
            opp.SVOC_ID__c = 'TMC1233';
        }
        insert opplist;
        
    }
    
    @istest
    static void testcreate(){
        List<Opportunity> opty = new list<Opportunity>([SELECT Id,First_Name__c,Last_Name__c,Email__c,Mobile__c,SVOC_ID__c 
                                                        FROM Opportunity]);
        System.assertEquals(1, opty.size());
        Map<String,String> svocMap = new map<String,String>();
        
        for(Opportunity opp : opty){
            svocMap.put(opp.SVOC_ID__c,null);    
        }
        SVOCSearchUtility.searchCustomersBySVOCIds(svocMap);
        SVOCSearchUtility.createPersonAccounts(opty);
        
    }
}