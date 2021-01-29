global class SchedulerUsageHelper implements Schedulable{
   
   global Set<String> portMobs; 
   global SchedulerUsageHelper(Set<String> portMobs){
       this.portMobs = portMobs;
   }   
   global void execute(SchedulableContext SC){        
        
        BatchMobileUsage mobUsage = new BatchMobileUsage(this.portMobs);
        Database.executeBatch(mobUsage);  
        
        System.abortJob(SC.getTriggerId());             
   }   
}