@istest
public  class CustomerVisibilityUtility_test {
     
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
        Customer_visibility__c cvVar=lstCV[0].clone();
        cvVar.Id=null;
        cvVar.End_Datetime__c=null;
        insert cvVar;
        list<Customer_visibility__c> lstCVForUser=TestDataFactory.createCustomerVisibilityRecordsForUser(iCount,lstCustomer);
        insert lstCVForUser;
        
   }
   
   @istest
   static void processCVTest(){
       list<Customer_visibility__c> lstCV=[SELECT Id, OwnerId, IsDeleted, Name,  Dealer_Public_Group_Name__c, SVOC_ID__c, Customer_Account__c, Start_Datetime__c, 
       End_Datetime__c,End_Date_Reason__c, Transaction_Type__c, Transaction_Date__c, Security_Master_Unique_Key__c, Integration_Failure_Reason__c,
       Access_Processing_Status__c, Access_processing_Failure_Reason__c, Sync_Status__c, Sync_Datetime__c, Related_User__c, Do_Not_Sync__c,MSIL_User_ID__c 
       FROM Customer_Visibility__c];
       
        CustomerRecordVisibilityUtility.grantAccessToCustomerAccount(lstCV,true,false,false);
       Map<Id,Account> mapAcc=new Map<Id,Account>([select Id from Account]);
       CustomerRecordVisibilityUtility.checkIfCustomerRecordAccessExsists(mapAcc.keySet());
       try{
          CustomerRecordVisibilityUtility.revokeAccessToCustomerAccount(lstCV,true,false,system.now());
        

       }
       catch(Exception ex){}
       Test.startTest();
         Notification__e notificationEvent=new Notification__e(Notification_Type__c=system.label.Customer_visibility_Grant_Access_Batch);
         
          Database.SaveResult sr = EventBus.publish(notificationEvent);
          Test.stopTest();
       for(Integer i=0;i<Integer.valueOf(System.label.Customer_visibility_Grant_Access_Batch_Retention_Duration)+1;i++){
           CustomerRecordVisibilityUtility.processBatchInitiateNotification(new List<Notification__e>{new Notification__e(Notification_Type__c=system.label.Customer_visibility_Grant_Access_Batch)});
       }
         

   }
   @istest
   static void addUserToParentPublicGroupTest(){
        List<User> lstUser=[select Id,ContactId from User where contactId!=null];
        CustomerRecordVisibilityUtility.addUserToParentPublicGroup(lstUser);

   }

}