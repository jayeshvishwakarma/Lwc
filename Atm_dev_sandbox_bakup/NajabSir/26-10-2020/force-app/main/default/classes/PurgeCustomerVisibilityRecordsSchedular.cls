global class PurgeCustomerVisibilityRecordsSchedular implements Schedulable {


   
   global void execute(SchedulableContext ctx) {
   
     Database.executeBatch(new PurgeCustomerVisibilityRecords_batch(),200); 
      
   }   
}