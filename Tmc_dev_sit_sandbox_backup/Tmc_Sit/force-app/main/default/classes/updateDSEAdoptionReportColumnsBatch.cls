/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to update fields on account object for DSE's to show in a report 
    **/
public without sharing class updateDSEAdoptionReportColumnsBatch implements Database.Batchable<sObject>, Database.Stateful{
   
   public final Boolean isMTD;
   public final Boolean monthly;
    
   public updateDSEAdoptionReportColumnsBatch(Boolean bool,Boolean bool1){
             isMTD = bool;
             monthly = bool1;
  }

   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       Id AccRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('User Account').getRecordTypeId();
       return Database.getQueryLocator([Select Id,User__c,User__r.ProfileId,User__r.Profile.Name from Account where RecordTypeId =: AccRecTypeId2 AND IsPartner = false and IsPersonAccount = false]);
  
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
            system.debug('38 %% '+ monthly + isMTD);
            if(monthly == false && isMTD == false)
                AccountDSEReportFillUp.updateDSEFields(accLst1);
            if(monthly == false && isMTD == true)
                AccountDSEReportFillUp.updateDSEFieldsForDailyCount(accLst1);
            if(monthly == true && isMTD == false)
               AccountDSEReportFillUp.updateDSEFieldsForMonthlyCount(accLst1);    
            
        }
   }
   //Finish Method
   public void finish(Database.BatchableContext BC){
            List<DSE_Report_RUn__c> dseRun =DSE_Report_RUn__c.getAll().values();  
            if(monthly == false && isMTD == true)
            {
            DateTime dt = DateTime.now();
            dseRun[0].Daily_Run_Time__c = dt.addHours(-3);
            update dseRun[0];
            }
            if(monthly == true && isMTD == false)
            {
            DateTime dt = DateTime.now();
            dseRun[0].Monthly_Run_TIme__c= dt.addMonths(1);
            update dseRun[0];
            }
            
        
    }
}