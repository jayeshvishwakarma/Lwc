/*
Class Name  :     ScheduledMobileSettingsGREXX 
Date        :     26th June 2019
Author      :     Ibirds Software Services
Description :     Scheduler class of BatchMobileSettingsGREXX Batch Class 
*/

global class ScheduledMobileSettingsGREXX implements Schedulable{
   
   global Set<String> pmIds;
   global ScheduledMobileSettingsGREXX(Set<String> pmIds){
       this.pmIds = pmIds;
   }
   global void execute(SchedulableContext SC){
        BatchMobileSettingsGREXX mobielBatch = new BatchMobileSettingsGREXX(pmIds);
        Database.executeBatch(mobielBatch); 
                
        System.abortJob(SC.getTriggerId());  
   }   
}