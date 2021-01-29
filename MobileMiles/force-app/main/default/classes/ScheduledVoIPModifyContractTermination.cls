/*
Class Name  :     ScheduledVoIPModifyContractTermination
Date        :     13 august 2019
Author      :     Ibirds Software Services
Description :     Scheduler class of BatchVoIPModifyContractTermination Batch Class 
*/

global class ScheduledVoIPModifyContractTermination implements Schedulable{
   //To be called by VoIPTrigger to schedule batch class (13 august 2019 by shikha)
   global Set<String> voipIds;
   global ScheduledVoIPModifyContractTermination(Set<String> voipIds){
       this.voipIds = voipIds;
   }
   global void execute(SchedulableContext SC){
        BatchVoIPModifyContractTermination voipBatch = new BatchVoIPModifyContractTermination(voipIds);
        Database.executeBatch(voipBatch); 
                
        System.abortJob(SC.getTriggerId());  
   }   
}