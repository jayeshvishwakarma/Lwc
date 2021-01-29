global class ScheduledBatchISRACheck implements Schedulable{
   
   global Set<String> accountIds;
   global ScheduledBatchISRACheck(Set<String> accountIds){
       this.accountIds = accountIds;
   }
   global void execute(SchedulableContext SC){
       BatchISRACheck israCheckBatch = new BatchISRACheck(accountIds);
        Database.executeBatch(israCheckBatch); 
                
        System.abortJob(SC.getTriggerId());  
   }   
}