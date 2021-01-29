/*
* @Name-: LeadConvertScheduler
* @Author-: Shaikh Mufiz
* @Company-: Techmatrix Consulting
* @Description-: 
* =============================================================
* Version   Date          Author      		Modification
* =============================================================
* 1.0       17/12/2020    Shaikh Mufiz     	Intial Version
**/
global class LeadConvertScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<LeadStatus> leadStatus = [SELECT Id, MasterLabel, ApiName  FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        if(leadStatus.size() > 0){
            LeadConvertSchedulerBatch leadConvertSchedulerBatchable = new LeadConvertSchedulerBatch(leadStatus[0].ApiName);
            Database.executeBatch(leadConvertSchedulerBatchable, 200);
        }
    }
}