@isTest
public with sharing class ProcessCustomerVisibilityAccess_test {
    @testSetup
    static void CreateMethod(){
        Integer iCount=20;
        
        
        List<Account> lstCustomer=TestDataFactory.createPersonAccount(iCount);
        insert lstCustomer;
        
        List<Group> lstGroup=TestDataFactory.createPublicGroup(iCount);
        insert lstGroup;
        insert new Bypass_Setting__c(SetupOwnerId=UserInfo.getUserId(), bypass_Triggers__c='CustomerVisibilityTrigger');
        
        list<Customer_visibility__c> lstCV=TestDataFactory.createCustomerVisibilityRecordsForGroup(iCount,lstCustomer);
        insert lstCV;
        
    }
    
    @istest
    static void processBatch(){
        
        test.startTest();
        
        Database.executeBatch(new ProcessCustomerVisibilityAccess_batch(true),400);  
        
        
        test.stopTest();
    }
    @istest
    static void processBatch1(){
        
        test.startTest();
        
        Database.executeBatch(new ProcessCustomerVisibilityAccess_batch(),400);  
        
        
        test.stopTest();
    }
}