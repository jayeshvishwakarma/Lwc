/*
Class Name  :     ScheduledModifyContractTermination
Date        :     26th June 2019
Author      :     Ibirds Software Services
Description :     Scheduler class of BatchModifyContractTermination Batch Class 
*/

global class ScheduledModifyContractTermination implements Schedulable{
   
   global Set<String> pmIds;
   global ScheduledModifyContractTermination(Set<String> pmIds){
       this.pmIds = pmIds;
   }
   global void execute(SchedulableContext SC){
        BatchModifyContractTermination mobielBatch = new BatchModifyContractTermination(pmIds);
        Database.executeBatch(mobielBatch); 
                
        System.abortJob(SC.getTriggerId());  
   }   
}