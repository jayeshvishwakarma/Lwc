@isTest
public  class CreateDealerPublicGroup_test {
   @testSetup
    static void CreateMethod(){
       Integer iCount=20;
       
        List<Account> lstDealer=TestDataFactory.createDealerAccount(iCount);
        insert lstDealer;
        List<Account> lstCustomer=TestDataFactory.createPersonAccount(iCount);
        insert lstCustomer;
        List<Contact> lstDealerContact=TestDataFactory.createDealerContact(2,lstDealer);
        insert lstDealerContact;
        List<Group> lstGroup=TestDataFactory.createPublicGroup(iCount);
        insert lstGroup;
 
        List<User> lstInternalUser=TestDataFactory.createUserData('Internal', 'Maruti Sales User',null);
        Integer iCountTemp=0;
        for(User oUser:lstInternalUser){
          oUser.DMS_Username__c='usr'+iCountTemp;
          iCountTemp++;
        }
        insert lstInternalUser;
        List<User> lstIExternalUser=TestDataFactory.createUserData('Portal', 'Dealer Sales Executive',new List<Contact>{lstDealerContact[0]});
        insert lstIExternalUser;
        list<Customer_visibility__c> lstCV=TestDataFactory.createCustomerVisibilityRecordsForGroup(iCount,lstCustomer);
        insert lstCV;
        list<Customer_visibility__c> lstCVForUser=TestDataFactory.createCustomerVisibilityRecordsForUser(iCount,lstCustomer);
        insert lstCVForUser;
        
   }
   @istest
   static void processBatch(){
     
  test.startTest();
  
     Database.executeBatch(new CreateDealerPublicGroup_batch(true),400);  
  
  
  test.stopTest();
   }
}