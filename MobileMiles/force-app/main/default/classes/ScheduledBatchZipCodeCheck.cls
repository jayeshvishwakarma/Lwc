/*
Class Name  :     ScheduledBatchZipCodeCheck 
Date        :     27th May, 2019
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/
global class ScheduledBatchZipCodeCheck implements Schedulable{
   
   global Set<String> accountIds;
   global ScheduledBatchZipCodeCheck(Set<String> accountIds){
       this.accountIds = accountIds;
   }
   global void execute(SchedulableContext SC){
       BatchZipCodeCheck zipCodeBatch = new BatchZipCodeCheck(accountIds);
        Database.executeBatch(zipCodeBatch); 
                
        System.abortJob(SC.getTriggerId());  
   }   
}