/*
Class Name  :     BatchModifyMobileSettingsGREXX 
Date        :     26th June 2019
Author      :     Ibirds Software Services
Description :     Batch Class to call Mobile settings webservice
*/

global class BatchModifyMobileSettingsGREXX implements Database.Batchable<sobject>,Database.AllowsCallouts {   
   global Set<String> pmIds;
   global BatchModifyMobileSettingsGREXX(Set<String> pmIds){
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
       Set<Id> portMobielIds = new Set<Id>(new Map<Id,SObject>(scope).keySet());
       system.debug('portMobielIds.size -- ' + portMobielIds.size());
       if(portMobielIds.size() > 0){  
            ModifyMobileSettings.getPorteringMobile(portMobielIds);        
        }
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}