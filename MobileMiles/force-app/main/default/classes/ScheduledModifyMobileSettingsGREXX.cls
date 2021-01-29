/*
Class Name  :     ScheduledModifyMobileSettingsGREXX 
Date        :     26th June 2019
Author      :     Ibirds Software Services
Description :     Scheduler class of BatchMobileSettingsGREXX Batch Class 
*/

global class ScheduledModifyMobileSettingsGREXX implements Schedulable{
   
   global Set<String> pmIds;
   global ScheduledModifyMobileSettingsGREXX (Set<String> pmIds){
       this.pmIds = pmIds;
   }
   global void execute(SchedulableContext SC){
        BatchModifyMobileSettingsGREXX mobielBatch = new BatchModifyMobileSettingsGREXX(pmIds);
        Database.executeBatch(mobielBatch); 
                
        System.abortJob(SC.getTriggerId());  
   }   
}