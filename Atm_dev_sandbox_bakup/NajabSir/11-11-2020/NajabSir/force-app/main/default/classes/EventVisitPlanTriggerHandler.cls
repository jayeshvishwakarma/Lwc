/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Event Visit Plan Trigger Handler

History
Date            Author             Comments
--------------------------------------------------------------------------------------
27-09-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
public with sharing class EventVisitPlanTriggerHandler extends TriggerHandler {
    
    private List<Event_Visit_Plan__c> newEventVisitPlans;
    private Map<Id, Event_Visit_Plan__c> oldEventVisitPlansMap;
      
    public EventVisitPlanTriggerHandler() {
        this.newEventVisitPlans = (List<Event_Visit_Plan__c>) Trigger.new;
        this.oldEventVisitPlansMap = (Map<Id, Event_Visit_Plan__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        Set<Id> recordIds = new Set<Id>();
        for(Event_Visit_Plan__c newPlan : newEventVisitPlans){
            recordIds.add(newPlan.Id);
        }
        if(!recordIds.isEmpty()){
            AccountTeamShareService.createShareRecords(recordIds);
        }
    }
      
    public override void afterUpdate() {
        Set<Id> recordIds = new Set<Id>();
        for(Event_Visit_Plan__c newPlan : newEventVisitPlans){
            Event_Visit_Plan__c oldPlan = oldEventVisitPlansMap.get(newPlan.Id);
            //if owner is changed
            if(newPlan.OwnerId != oldPlan.OwnerId){
                recordIds.add(newPlan.Id);
            }
        }
        if(!recordIds.isEmpty()){
            AccountTeamShareService.createShareRecords(recordIds);
        }
    }
}