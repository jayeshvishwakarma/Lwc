/**
            Name        :        BatchMobileUsage 
            Date        :        19th May 2020
            Author      :        Ranu Bari
            Description :        To call web service for account
**/

global class BatchMobileUsage implements Database.Batchable<sobject>,Database.AllowsCallouts {   
   global Set<String> portMobs;
   global BatchMobileUsage (Set<String> portMobs){
       this.portMobs = portMobs;
   }
   // Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
      String query = 'SELECT Id, account__r.IRMA_MKB_Office__c, iRMA_id__c from Porteringen_mobiel__c where id IN : portMobs';
      system.debug('@@@@ query ' + query);
      return Database.getQueryLocator(query);     
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<Porteringen_mobiel__c> scope) {
       //MobileUsage.getPorteringDetails(scope);     
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}