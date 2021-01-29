@isTest
public class PurgeCustomerVisibilityRecords_test {
     @testSetup
    static void CreateMethod(){
       Integer iCount=20;
       
        
     List<Account> lstCustomer=TestDataFactory.createPersonAccount(iCount);
        insert lstCustomer;
       
        List<Group> lstGroup=TestDataFactory.createPublicGroup(iCount);
        insert lstGroup;
 insert new Bypass_Setting__c(SetupOwnerId=UserInfo.getUserId(), bypass_Triggers__c='CustomerVisibilityTrigger');
      
        list<Customer_visibility__c> lstCV=TestDataFactory.createCustomerVisibilityRecordsForGroup(iCount,lstCustomer);
        for(Customer_visibility__c cVar: lstCV)
          cVar.Access_Processing_Status__c='Invalidated';
        insert lstCV;
        
   }
   
   @istest
   static void processBatch(){
     
  test.startTest();
  
     Database.executeBatch(new PurgeCustomerVisibilityRecords_batch(),400);  
  
  
  test.stopTest();
   }
}