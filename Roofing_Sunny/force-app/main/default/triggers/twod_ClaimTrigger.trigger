/*Trigger on  twod__Claim__c
@Trigger Name  : CT_ClaimTrigger
@CreatedOn     : 27/09/2016
@Created by    : Mounika 
@Modified by   : Mounika
@Description   : Trigger on twod__Claim__c object.      
*/

trigger twod_ClaimTrigger on twod__Claim__c (after update, before update, after Insert, before Insert)              
{
    
        /* Author: Sunny Singh (Capgemini)
    * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
    * Date: 11 December 2020
    */

   if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
   
   if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().twod_ClaimTrigger_Trigger_enabled__c)  return;

    twod_TriggerControl__c mc = twod_TriggerControl__c.getInstance( userinfo.getProfileId());
    if(mc.twod_ClaimTrigger__c){        
        twod_ClaimTriggerHandler  objHandler = new twod_ClaimTriggerHandler ();       
        if(trigger.isafter && trigger.isupdate ){        
            objHandler.OnAfterUpdate(trigger.oldMap, trigger.newMap);
        }
        if(trigger.isafter && trigger.isInsert){
            objHandler.OnAfterInser(trigger.newMap);
        }        
        if(trigger.isbefore && trigger.isInsert){
            objHandler.onBeforeInsert(trigger.new);
        }
    }
}