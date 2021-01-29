/*
    Author: Mukesh Bhardwaj(Threshold Consulting)
    Company: Certainteed
    Description: Update the Case BusinessHours from with default BusinessHours.
    Changes: May 3 , 2013: Initial Draft

    Author: David Berman (Capgemini)
    Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
    Date: 9 December 2020
*/
trigger biuCase on Case (before insert, before update) 
{
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().biuCase_Trigger_enabled__c)  return;


    Id profileId= UserInfo.getProfileId();
    //String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    // Query for the default business hours
    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];       
    
      for(Case c : trigger.new) {
          if(bh != null){
              c.BusinessHoursId = bh.Id;
          }          
        if(trigger.isInsert){             
              //THis method is calling to convert the document links coming from Hybris to html links                
              caseTriggerHandler_rpg.formatDocumentData(c,null);
          } 
          else{
              //THis method is calling to convert the document links coming from Hybris to html links              
              if(c.Documents__c != trigger.OldMap.get(c.id).Documents__c){
                 caseTriggerHandler_rpg.formatDocumentData(c,trigger.OldMap.get(c.id));
              }              
          }
          
      }
      
}