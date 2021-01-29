/*******************************************************************************
Name            : ScheduleBatchProcessOrderIntake.cls
Created Date    : 25th Aug, 2014
Description     : Scheduler class for Batch process which is responsible to 
        create Order_Intake__c and Order_Intake_Line__c records for reporting
*******************************************************************************/
global class ScheduleBatchProcessOrderIntake implements Schedulable {
    // execute method to Schedule batch class
    global void execute(SchedulableContext SC) {
    	    
        BatchProcessOrderIntake jobToDo = new BatchProcessOrderIntake();
        //Execute batch with batch size 1
        Database.executeBatch(jobToDo, 1); 
  }
}