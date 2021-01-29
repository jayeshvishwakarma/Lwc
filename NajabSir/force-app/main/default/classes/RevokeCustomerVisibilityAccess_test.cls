@isTest
public  class RevokeCustomerVisibilityAccess_test {
      @testSetup
    static void CreateMethod(){
       Integer iCount=20;
       
        
     List<Account> lstCustomer=TestDataFactory.createPersonAccount(iCount);
        insert lstCustomer;
       
        List<Group> lstGroup=TestDataFactory.createPublicGroup(iCount);
        insert lstGroup;
 
      
        list<Customer_visibility__c> lstCV=TestDataFactory.createCustomerVisibilityRecordsForGroup(iCount,lstCustomer);
       
        insert lstCV;
        
   }
   
   @istest
   static void processBatch(){
     
  test.startTest();
  
     Database.executeBatch(new RevokeCustomerVisibilityAccess_batch(true),400);  
  
  
  test.stopTest();
   }
}