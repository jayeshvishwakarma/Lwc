global class RevokeCustomerVisibilityAccessSchedular implements Schedulable {


   
   global void execute(SchedulableContext ctx) {
   
     Database.executeBatch(new RevokeCustomerVisibilityAccess_batch(),Integer.valueOf(System.label.RevokeCustomerVisibilityAccess_batch_Chunk_Size)); 
      
   }   
}