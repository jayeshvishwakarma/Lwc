/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to update fields on account object for DSE's to show in a report 
    **/
public without sharing class updateDSEAdoptionReportColumnsBatch implements Database.Batchable<sObject>, Database.Stateful{
   
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       Id AccRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('User Account').getRecordTypeId();
       return Database.getQueryLocator([Select Id,User__c from Account where RecordTypeId =: AccRecTypeId2 AND IsPartner = false and IsPersonAccount = false]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<Account> scope){
         
        List<Account> accLst1 = new List<Account>();
        if(scope.size() > 0)
        {
            for(Account acc : scope)
            {
                accLst1.add(acc);
            }   
        }
        
        if(accLst1.size() > 0)
        {
            AccountDSEReportFillUp.updateDSEFields(accLst1);
        }
   }
   //Finish Method
   public void finish(Database.BatchableContext BC){
    
    }
}