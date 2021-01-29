/**
* @File Name          : AgentWorkTriggerHandler.cls
* @Description        : Trigger handler class for Agent Work
* @Author             : Anas Yar Khan
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    27/08/2020                Anas Yar Khan              Initial Version
**/
public without sharing class AgentWorkTriggerHandler extends TriggerHandler {
	private List<AgentWork> triggerNew;           //Holds the Trigger.New of Agent Work
    public AgentWorkTriggerHandler() {
        this.triggerNew = (List<AgentWork>)Trigger.New;
    }
    
    public override void afterInsert() { 
    	updateMOSCase();
    }
    
    public override void afterUpdate() { 
    	updateMOSCase();
    }
    /*
    Author : Anas Yar Khan
    Event : After Insert , After Update
    Description : Method to update the MOS Case,Open Task and Case Actions when Owner of Case is assigned via Omni Channel
    */
    public void updateMOSCase() {
        try {
            Set<Id> setCaseId = new Set<Id>();            //Set to store the WorkItemId
            Map<Id,Case> mapIdToCase;                     //Map to store MOS Case
            List<Task> listTaskToUpdate = new List<Task>();     //List to store Task that need to be updated
            List<Case_Actions__c> listCaseActionToUpdate = new List<Case_Actions__c>();    //List to store Case Actions that need to be updated
            List<Custom_Activity__c> listCustomActivityToUpdate = new List<Custom_Activity__c>();
            
            
            //Iterating over Trigger.new to get the Work Item Id
            for(AgentWork agtWrk : triggerNew) {
                if(agtWrk.WorkItemId != NULL && agtWrk.WorkItemId.getSObjectType().getDescribe().getName() == ConstantsUtility.CaseObjectName) {
                    setCaseId.add(agtWrk.WorkItemId);	    
                }
            }
            
            //To fill Map(Id as Key and MOS Case as Value)
            //This logic only works if the Case Is MOS Case
            if(setCaseId.size() > 0) {
                mapIdToCase = new Map<Id,Case>([SELECT Id,Omni_Channel_Assignment_Date_Time__c,OwnerId 
                                                FROM Case 
                                                WHERE Id IN :setCaseId 
                                                AND RecordTypeId = :ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID]);    
            }
            
            //Iterating over MOS Case Id to update MOS Case, Task and Case Action record
            if(mapIdToCase != NULL && mapIdToCase.keySet().size() > 0) {
                //Updating the Case by DateTime.now
                for(Id caseId : mapIdToCase.keySet()) {
                    Case caseObj = 	mapIdToCase.get(caseId);
                    caseObj.Omni_Channel_Assignment_Date_Time__c = Datetime.now();
                }
                
                //Fetching Task and update the owner of the task as Case Owner
                for(Task taskObj : [SELECT Id,OwnerId,WhatId 
                                    FROM Task 
                                    WHERE WhatId IN :mapIdToCase.keySet() 
                                    AND RecordTypeId IN (:ConstantsUtility.MOS_TASK_RecordType_Id, :ConstantsUtility.TASK_MOS_Follow_Up_RecordType_Id) 
                                    AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                                        taskObj.OwnerId = mapIdToCase.get(taskObj.WhatId).OwnerId;
                                        listTaskToUpdate.add(taskObj);
                                    }
                //Fetching Case Actions and update the owner as Case Owner
                for(Case_Actions__c caseActionObj : [SELECT Id,OwnerId,Case_Number__c 
                                                    FROM Case_Actions__c 
                                                    WHERE Case_Number__c IN :mapIdToCase.keySet()]) {
                    //Only user can be the owner of the CaseAction records                                    
                    if(String.valueOf(mapIdToCase.get(caseActionObj.Case_Number__c).OwnerId).startsWith(ConstantsUtility.UserPrefix)) {
                        caseActionObj.OwnerId = mapIdToCase.get(caseActionObj.Case_Number__c).OwnerId;
                        listCaseActionToUpdate.add(caseActionObj);
                    }
                }
                
                //Fetching custom Activity
                for(Custom_Activity__c ca : [SELECT Id,OwnerId,Case__c FROM Custom_Activity__c WHERE Case__c IN :mapIdToCase.keySet()]) {
                	ca.OwnerId = mapIdToCase.get(ca.Case__c).OwnerId;
                    listCustomActivityToUpdate.add(ca);
                }
            }
            
            
            //DML to update MOS Cases
            if(mapIdToCase != NULL && mapIdToCase.keySet().size() > 0) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update mapIdToCase.values();
                TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }
            
            //DML to update Tasks
            if(listTaskToUpdate.size() > 0) {
                TriggerHandler.bypass('TaskTriggerHandler');
                update listTaskToUpdate;
                TriggerHandler.clearbypass('TaskTriggerHandler');
            }
            
            //DML to update the Case Actions
            if(listCaseActionToUpdate.size() > 0) {
                TriggerHandler.bypass('CaseActionsTriggerHandler');
                update listCaseActionToUpdate;
                TriggerHandler.clearBypass('CaseActionsTriggerHandler');
            }
            
            //DML to update custom Activity
            if(listCustomActivityToUpdate.size() > 0) {
                update listCustomActivityToUpdate;
            }
        }
        catch(Exception e) {
            ExceptionHandler.LogError('AgentWorkTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'Update Tasks and Case Actions Owner if the Case Owner is assigned by the Omni Channel', '', null);
        }
    }
}