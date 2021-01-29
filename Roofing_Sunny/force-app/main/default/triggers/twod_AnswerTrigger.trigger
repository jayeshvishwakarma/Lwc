trigger twod_AnswerTrigger on Answer__c (before insert) {
    
    /* Author: Sunny Singh (Capgemini)
     * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
     * Date: 10 December 2020
     */
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().twod_AnswerTrigger_Trigger_enabled__c)  return;
    
    twod_TriggerControl__c mc = twod_TriggerControl__c.getInstance( userinfo.getProfileId());
    if(mc.twod_AnswerTrigger__c){
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                for(Answer__c ans:Trigger.New){
                    
                    String objectApiName = Id.valueOf(ans.Related_Record_Id__c).getSObjectType().getDescribe().getName();
                    
                    if(objectApiName  == 'Inspection__c'){
                        ans.Inspection__c = ans.Related_Record_Id__c;
                    }
                    else if(objectApiName  == 'Sampling_QC__c'){
                        ans.Sampling_QC__c= ans.Related_Record_Id__c;  
                    }    
                    
                }
            }    
        }
    }
}