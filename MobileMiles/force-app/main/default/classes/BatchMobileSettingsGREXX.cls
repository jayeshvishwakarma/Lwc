/*
Class Name  :     BatchMobileSettingsGREXX 
Date        :     26th June 2019
Author      :     Ibirds Software Services
Description :     Batch Class to call Mobile settings webservice
*/

global class BatchMobileSettingsGREXX implements Database.Batchable<sobject>,Database.AllowsCallouts {   
   global Set<String> pmIds;
   global BatchMobileSettingsGREXX(Set<String> pmIds){
       this.pmIds = pmIds;
   }
   // Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
      String query = 'select id from Porteringen_mobiel__c where id IN : pmIds';
      system.debug('@@@@ query ' + query);
      return Database.getQueryLocator(query);     
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<Porteringen_mobiel__c> scope) {
       Set<String> portMobielIds = new Set<String>(new Map<String,SObject>(scope).keySet());
       system.debug('portMobielIds.size -- ' + portMobielIds.size());
       if(portMobielIds.size() > 0){
            MobileSettings.getMobileDetails(portMobielIds);            
        }
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}