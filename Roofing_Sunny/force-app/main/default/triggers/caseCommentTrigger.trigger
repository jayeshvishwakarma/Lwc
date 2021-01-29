trigger caseCommentTrigger on CaseComment (before update, before delete) 
{    
    /* Author: David Berman (Capgemini)
     * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
     * Date: 9 December 2020
     */
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().caseCommentTrigger_Trigger_enabled__c)  return;
    
    
     if(Trigger.isBefore){
         if(Trigger.isUpdate){
             for(CaseComment csCmt : Trigger.new){
                 if(csCmt.CreatedById != userInfo.getUserId()){                    
                          csCmt.addError('You do not have sufficient privileges to edit this case comment. Case comments can only be edited by the individual who created it.');                     
                 }
             }
         }
         else if(Trigger.isDelete){
             for(CaseComment csCmt : Trigger.old){
                 if(csCmt.CreatedById != userInfo.getUserId()){                   
                          csCmt.addError('You do not have sufficient privileges to edit this case comment. Case comments can only be edited by the individual who created it.');                     
                 }
             }             
         }
     }
}