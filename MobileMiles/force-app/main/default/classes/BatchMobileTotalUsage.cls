/**
            Name        :        BatchMobileTotalUsage 
            Date        :        19th May 2020
            Author      :        Ranu Bari
            Description :        To call web service for account
**/

global class BatchMobileTotalUsage implements Database.Batchable<sobject>,Database.AllowsCallouts {   
   global Set<String> accIds;
   global BatchMobileTotalUsage(Set<String> accIds){
       this.accIds = accIds;
   }
   // Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
      String query = 'SELECT Id, IRMA_MKB_Office__c, iRMA_id__c from Account where id IN : accIds';
      //system.debug('@@@@ query ' + query);
      return Database.getQueryLocator(query);     
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<Account> scope) {
       //Set<Id> ids = (new Map<Id,Account>(scope)).keySet();
       //MobileTotalUsage.fetchMobileUsageFromBatch(ids);     
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}