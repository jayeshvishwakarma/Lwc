trigger twod_RecordSharingTrigger on Product_Creation__c (before insert,before update) {
    
        /* Author: Sunny Singh (Capgemini)
    * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
    * Date: 11 December 2020
    */

   if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
   
   if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().twod_RecordSharingTrigger_Trigger_enabl__c)  return;


    twod_TriggerControl__c mc = twod_TriggerControl__c.getInstance( userinfo.getProfileId());
    if(mc.twod_RecordSharingTrigger__c){
        
        Map<Id,Product_Creation__c> NewMap=trigger.newMap;
        Map<Id,Product_Creation__c> OldMap=trigger.oldMap;
        List<Product_Creation__c> updateList;     
        twod_RecordSharingHelper instance=new twod_RecordSharingHelper();
        if(trigger.isbefore && trigger.isinsert)
        {             
            updateList=instance.updateRequestedBy(trigger.new);
        }
        if(trigger.isbefore && trigger.isupdate)
        {
            updateList=instance.updateApprovedBy(NewMap,OldMap);
        }
        
        //insert(updateList);    
    }
}