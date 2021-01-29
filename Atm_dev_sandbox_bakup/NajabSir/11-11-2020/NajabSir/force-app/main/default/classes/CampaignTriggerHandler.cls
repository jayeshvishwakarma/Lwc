/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Campaign Trigger Handler

History
Date            Author             Comments
--------------------------------------------------------------------------------------
27-09-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
public with sharing class CampaignTriggerHandler extends TriggerHandler {
    
    private List<Campaign> newCampaigns;
    private Map<Id, Campaign> oldCampaignsMap;
      
    public CampaignTriggerHandler() {
        this.newCampaigns = (List<Campaign>) Trigger.new;
        this.oldCampaignsMap = (Map<Id, Campaign>) Trigger.oldMap;
    }
	
    public override void beforeInsert() {
        //Pre-Populate Dealer field
        populateDealerLookUp();
    }
    
    public override void beforeUpdate() {
        //Pre-Populate Dealer field
        populateDealerLookUp();
    }
    
    
    public override void afterInsert() {
        Set<Id> recordIds = new Set<Id>();
        for(Campaign newPlan : newCampaigns){
            recordIds.add(newPlan.Id);
        }
        if(!recordIds.isEmpty()){
            AccountTeamShareService.createShareRecords(recordIds);
        }
    }
      
    public override void afterUpdate() {
        Set<Id> recordIds = new Set<Id>();
        for(Campaign newPlan : newCampaigns){
            Campaign oldPlan = oldCampaignsMap.get(newPlan.Id);
            //if owner is changed
            if(newPlan.OwnerId != oldPlan.OwnerId){
                recordIds.add(newPlan.Id);
            }
        }
        if(!recordIds.isEmpty()){
            AccountTeamShareService.createShareRecords(recordIds);
        }
    }
    
    
    public void populateDealerLookUp(){
        
        map<Id,Id> ownerDealerAccountMap = new map<Id,Id>();
        
        for(Campaign camp : newCampaigns){
            if(trigger.isInsert || (trigger.IsUpdate && oldCampaignsMap.get(camp.Id).OwnerId != camp.OwnerId)){
                ownerDealerAccountMap.put(camp.OwnerId, null);
            }
            
            //Added by Prabhat as part of DE206 - 03rd Feb 2020
            //Validation to restrict user to rescedule event not more than 3 times
            if(trigger.IsUpdate && oldCampaignsMap.get(camp.Id).StartDate  != camp.StartDate){
                camp.Reschedule_Count__c = camp.Reschedule_Count__c!=null ? camp.Reschedule_Count__c+1 : 1;
                if(camp.Reschedule_Count__c!=null && camp.Reschedule_Count__c>Integer.valueOf(label.Max_Reschedule_Allowed)){
                    camp.addError(label.Reschedule_Event_Error_Message);
                }
            }
        }
        
        
        if(ownerDealerAccountMap.keySet().size()>0){
            for(User usr : [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id in:ownerDealerAccountMap.keySet()]){
                if(usr.ContactId != null){
                    ownerDealerAccountMap.put(usr.Id, usr.Contact.AccountId);
                }
            }
            
            //Loop Through trigger new to populate 
            for(Campaign camp : newCampaigns){
                if(ownerDealerAccountMap.containsKey(camp.OwnerId) && ownerDealerAccountMap.get(camp.OwnerId)!=null){
                    camp.Dealership__c = ownerDealerAccountMap.get(camp.OwnerId);
                }
            }
        }
    }
    
}