/*
Class Name  :     BatchVoIPModifyContractTermination
Date        :     13 august 2019
Author      :     Ibirds Software Services
Description :     Batch Class to call VoIPModifyContractTermination webservice
*/

global class BatchVoIPModifyContractTermination implements Database.Batchable<sobject>,Database.AllowsCallouts {   
   global Set<String> voipIds;
   global BatchVoIPModifyContractTermination(Set<String> voipIds){
       this.voipIds = voipIds;
   }
   // Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
      String query = 'select id from VoIP__c where id IN : voipIds';
      system.debug('@@@@ query ' + query);
      return Database.getQueryLocator(query);     
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<VoIP__c> scope) {
       Set<String> voIds = new Set<String>(new Map<String,SObject>(scope).keySet());
       system.debug('voipIds.size -- ' + voIds.size());
       if(voIds.size() > 0){
            VoIP_ModifyContractTermination.voipmodifyContract(voIds);            
        }
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}