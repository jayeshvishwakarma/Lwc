/*
    Name        : OldTaskDeletionBatch
    Date        : 21 May, 2020
    Author      : Mufiz
    Description : This batch class is using for deleting older than 10 days records of task.
*/
global with sharing class OldTaskDeletionBatch implements Database.Batchable<SObject>{
	private final String taskOwnerId;
	global OldTaskDeletionBatch(String taskOwnerId){
		this.taskOwnerId = taskOwnerId;
	}
    global Database.QueryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator([SELECT Id FROM Task WHERE ownerid =: taskOwnerId and what.type = 'Quote' and createddate < LAST_N_DAYS:10]);
    }
	global void execute(Database.BatchableContext ctx, List<Task> records){
        if(records.size() > 0) delete records;
    }
	global void finish(Database.BatchableContext ctx){}
}