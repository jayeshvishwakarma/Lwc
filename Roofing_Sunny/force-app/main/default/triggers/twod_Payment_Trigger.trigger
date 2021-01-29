trigger twod_Payment_Trigger on Payment__c (before insert,before update,before delete,after insert, after update) {
    
        /* Author: Sunny Singh (Capgemini)
    * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
    * Date: 11 December 2020
    */

   if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
   
   if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().twod_Payment_Trigger_Trigger_enabled__c)  return;

    twod_TriggerControl__c mc = twod_TriggerControl__c.getInstance( userinfo.getProfileId());
    system.debug('mc--');
    system.debug(mc);
    if(mc.twod_Payment_Trigger__c){
        
        if(trigger.isDelete)
        {
            twod_PaymentTriggerHelper.HandleDelete(Trigger.old);
            
        }
    
    if(Trigger.isBefore) {
        
        if(trigger.isInsert){
            twod_PaymentTriggerHelper.HandleBeforeInsert(Trigger.new);
        }  
        if(trigger.isUpdate)
        { 
            //Integration user profile id
            Id integrationProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'Integration User' LIMIT 1].Id;
            
            Id loggedInProfileId = userinfo.getProfileId();
            if(loggedInProfileId == integrationProfileId){
                /*for(Payment__c p: trigger.new){
                    if(!string.IsEmpty(p.Check_Date__c)){
                        p.Check_Date__c = string.valueof(date.valueof(p.Check_Date__c).format());
                    }
                 } */
                return;
            }
            /*
            for(Payment__c p: trigger.new){
                if(p.Approval_Status__c =='Approved' || p.Approval_Status__c =='Rejected' || p.Approval_Status__c =='Queued For Approval' || p.Released_To_SAP__c == true ){
                    
                    return;
                }
            }*/
            
            //System Admin Profile ID
            /*
            Id adminProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            if(loggedInProfileId == adminProfileId ){
                
            }*/
            
            twod_PaymentTriggerHelper.HandleBeforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
        
    }
    
}