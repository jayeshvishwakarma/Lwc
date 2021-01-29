/*
    Author: Mukesh Bhardwaj(Threshold Consulting)
    Company: Certainteed
    Description: Update the Case BusinessHours from with default BusinessHours.
    Changes: May 9 , 2013: Initial Draft
    We should add the code to call the caseTriggerHandler_rpg class for all events.
    DO NOT create more than one trigger on Case.
*/
trigger caseTrigger on Case (before update, before insert, before delete, after update, after insert, after delete) {

    /* Author: Sunny Singh (Capgemini)
     * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
     * Date: 10 December 2020
     */
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().caseTrigger_Trigger_enabled__c)  return;
    
    caseTriggerHandler_rpg  handler = new caseTriggerHandler_rpg();
    
    List<Case> caseList = new List<Case>();
    
    Id certainTeedWebChatId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CertainTeed Web Chat').getRecordTypeId();
    Id customerMasterRequestId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
    Id generalCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General Case').getRecordTypeId();
    Id reconsignmentCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Reconsignment Case').getRecordTypeId();
    Id rmaCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Case').getRecordTypeId();
    Id serviceCaseRoofingId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Case Roofing').getRecordTypeId();
    Id portalId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Portal').getRecordTypeId();
    
    for(Case record : Trigger.New){
        if(record.RecordTypeId == certainTeedWebChatId || record.RecordTypeId == customerMasterRequestId || record.RecordTypeId == generalCaseId
            || record.RecordTypeId == reconsignmentCaseId || record.RecordTypeId == rmaCaseId || record.RecordTypeId == serviceCaseRoofingId
              || ( record.RecordTypeId == portalId && ( record.Sales_Org__c == '1102' || record.Sales_Org__c == '1501') )){
            caseList.add(record);
        }
    }
    if(caseList.size() > 0){
        //Before Update
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            //Before update Action 1: Update TM and Warehouse User
            handler.updateTM(caseList, Trigger.oldMap);
        }
        //Before Insert
        if(Trigger.isBefore && Trigger.isInsert)
        {
            //Before update, action1: Update the business hours
            handler.updateBusinessHours(caseList);
            
            //Before insert Action 2: Update TM and Warehouse User
            handler.updateTM(caseList, null);
        }
         if(Trigger.isAfter && Trigger.isInsert){
             //Invoked method to apply assignment rules for portal cases
            handler.portalCaseAssignment(caseList);
        }
    }
}