/*
    Name        : OldTaskDeletionBatchScheduler
    Date        : 21 May, 2020
    Author      : Mufiz
    Description : This scheduler class is using for run OldTaskDeletionBatch every day.
*/
global class OldTaskDeletionBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
          OldTaskDeletionBatch batchObj = new OldTaskDeletionBatch(System.Label.Task_Owner_Id); 
          Database.executeBatch(batchObj, 200);
   }
}