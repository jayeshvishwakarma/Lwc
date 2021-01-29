/*
* @Name-: UpdateLeadScheduler
* @Author-: Shaikh Mufiz
* @Company-: Techmatrix Consulting
* @Description-: Scheduler class to populate External Id field of Opportunity by Enquiry Number of Lead.
* =============================================================
* Version   Date          Author      		Modification
* =============================================================
* 1.0       06/11/2020    Shaikh Mufiz     	Intial Version
**/
global class UpdateLeadScheduler implements Schedulable {
    Set<Id> convertedLeadIds = new Set<Id>();
    
    public UpdateLeadScheduler(Set<Id> leadIds){
        convertedLeadIds.addAll(leadIds);
    }
    global void execute(SchedulableContext sc) {
        UpdateLeadSchedulerBatch batchable = new UpdateLeadSchedulerBatch(convertedLeadIds);
        Database.executeBatch(batchable);
    }
}