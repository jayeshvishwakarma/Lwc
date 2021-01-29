/**
* @Autho:- Anas Yar Khan
* @Company-: Techmatrix Consulting
* @Description-: APEX Trigger Handler class of CustomActivityTrigger
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       08 Oct 2020    Anas        Intial Version
**/
public class CustomActivityTriggerHandler extends TriggerHandler{
	private list<Custom_Activity__c> taskItems;
    private Map<Id,Custom_Activity__c> oldTaskMap;
    public CustomActivityTriggerHandler() {
        this.taskItems = (list<Custom_Activity__c>) Trigger.new;
        this.oldTaskMap = (Map<Id, Custom_Activity__c>) Trigger.oldMap;
    }
    
    public override void afterInsert() {
        CaseTriggerHelper.getByPassMOSCommunication();           //Call to CaseTriggerHelper function to get whether MC records needs to be created or not
        updateFollowUpInformationOnCase(this.taskItems);
    }
    
    public override void afterUpdate() {
        updateTaskCompletedFieldOnCase(this.taskItems, this.oldTaskMap);
    }
    
    public override void beforeInsert() {
        updateFollowUpInformation(this.taskItems);
    }
    
    public override void beforeUpdate() {
        updateFollowUpInformation(this.taskItems);
    }
    
    public static void updateFollowUpInformationOnCase(List<Custom_Activity__c> taskItems) {
        try{
            List<Case> listCaseToUpdate = new List<Case>();  //List to store the cases which need to be updated
            List<Custom_Activity__c> listSendSMSTask = new List<Custom_Activity__c>();    //List to store task which have send sms as Yes
            Set<Id> setCaseId = new Set<Id>();                //Id to store set
            Map<Id,Case> mapIdToCase;                         //Map to store Case
            List<MC_Communication__c> listMCCommunicationToInsert = new List<MC_Communication__c>();    //List to store mc communication to insert
            for (Custom_Activity__c taskObj : taskItems) {
                if (taskObj.RecordTypeId != NULL
                    && taskObj.RecordTypeId == ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId
                    && taskObj.Case__c != NULL
                    && taskObj.Case__c.getSObjectType().getDescribe().getName() == ConstantsUtility.CaseObjectName) {
                        Case newCaseObj = new Case();
                        newCaseObj.Id = taskObj.Case__c;
                        newCaseObj.Next_Follow_Up_Time__c = taskObj.Next_Follow_Up_Time__c;
                        newCaseObj.Next_FollowUp_Remarks__c = taskObj.Next_Follow_Up_remarks__c;
                        newCaseObj.Repeat_Call_Notification__c = taskObj.Repeat_Call_Notification__c;
                        
                        listCaseToUpdate.add(newCaseObj);
                        
                        if(taskObj.Send_SMS__c == ConstantsUtility.SendSMSYes) {
                            listSendSMSTask.add(taskObj);
                            setCaseId.add(taskObj.Case__c);    
                        }
                        
                    }
            }
            
            if(setCaseId.size() > 0) {
                mapIdToCase = new Map<Id,Case>([SELECT Id,Job_Type__c,MOS_Case_Stage__c,MOS_Case_Source__c FROM Case WHERE Id IN :setCaseId]);    
            }
            //Getting MC Communication records
            if(mapIdToCase != NULL && mapIdToCase.keySet().size() > 0 && listSendSMSTask.size() > 0 && !CaseTriggerHelper.byPassMOSCommunication) {
                for(Custom_Activity__c taskObj : listSendSMSTask) {
                    if(mapIdToCase.containsKey(taskObj.Case__c)) {
                        Case caseObj = mapIdToCase.get(taskObj.Case__c);
                        if(caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown && taskObj.Mobile__c != NULL) {
                            if(caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                                if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Follow_Up_MCall_before_Allocation,taskObj.Mobile__c));
                                }
                                else {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Follow_Up_before_Allocation,taskObj.Mobile__c));
                                }
                            }
                            else if(caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                                if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Follow_Up_MCall_after_Allocation,taskObj.Mobile__c));   
                                }
                                else {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Follow_Up_after_Allocation,taskObj.Mobile__c));      
                                }
                            }
                        }   
                        else if(caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && taskObj.Mobile__c != NULL) {
                            if(caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                                if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Accidental_Follow_Up_MCall_before_Allocation,taskObj.Mobile__c));
                                }
                                else {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Accidental_Follow_Up_before_Allocation,taskObj.Mobile__c));
                                }
                            }
                            else if(caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                                if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Accidental_Follow_Up_MCall_after_Allocation,taskObj.Mobile__c));   
                                }
                                else {
                                    listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,ConstantsUtility.Accidental_Follow_Up_after_Allocation,taskObj.Mobile__c));      
                                }
                            }    
                        }
                    }
                }
            }
            
            if (listCaseToUpdate.size() > 0) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update listCaseToUpdate;
                TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }
            
            if(listMCCommunicationToInsert.size() > 0) {
                TriggerHandler.bypass('MCCommunicationTriggerHandler');
                insert listMCCommunicationToInsert;
                TriggerHandler.clearbypass('MCCommunicationTriggerHandler');
            }    
        }
        catch(Exception e) {
            ExceptionHandler.LogError('CustomActivityTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'update Follow Up Information after insert', '', null);     
        }
    }
    
    public static void updateTaskCompletedFieldOnCase(List<Custom_Activity__c> taskItems, Map<Id, Custom_Activity__c> oldTaskMap) {
        try {
            List<Case> listCaseToUpdate = new List<Case>();  //List to store the cases which needs to be updated
            Set<Id> setCustomActivityId = new Set<Id>();
            
            for (Custom_Activity__c taskObj : taskItems) {
                if (taskObj.RecordTypeId != NULL && taskObj.Case__c != NULL 
                    && taskObj.Case__c.getSObjectType().getDescribe().getName() == ConstantsUtility.CaseObjectName
                    && taskObj.Status__c == ConstantsUtility.MOS_Task_Status_Completed 
                    && taskObj.Status__c != oldTaskMap.get(taskObj.Id).Status__c) {
                        if(taskObj.RecordTypeId == ConstantsUtility.CustomActivityMOSTaskRecordTypeId) {
                         	Case newCaseObj = new Case();
                            newCaseObj.Id = taskObj.Case__c;
                            newCaseObj.Task_Completed__c = ConstantsUtility.MOS_Task_Completed;
                            listCaseToUpdate.add(newCaseObj);  
                            setCustomActivityId.add(taskObj.Id);
                        } 
                        else if(taskObj.RecordTypeId == ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId) {
                        	setCustomActivityId.add(taskObj.Id);    
                        }
                    }
            }
            
            if (listCaseToUpdate.size() > 0) {
                //TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update listCaseToUpdate;
                //TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }    
            
            if(setCustomActivityId.size() > 0) {
                List<Task> listTaskToUpdate = new List<Task>();
                for(Task taskObj : [SELECT Id,Status FROM Task WHERE Custom_Activity__c IN :setCustomActivityId AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                 	taskObj.Status =  ConstantsUtility.MOS_Task_Status_Completed;
                    listTaskToUpdate.add(taskObj);
                }
                
                if(listTaskToUpdate.size() > 0) {
                    TriggerHandler.bypass('TaskTriggerHandler');
                    update listTaskToUpdate;
                    TriggerHandler.clearbypass('TaskTriggerHandler');    
                }
            }
        }
        catch(exception e) {
            ExceptionHandler.LogError('CustomActivityTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'Update Task Completed Field On Case after update', '', null);    
        }
        
    }
    
    public static void updateFollowUpInformation(List<Custom_Activity__c> taskItems) {
        try {
            //Set to store MOS Case Id
            Set<Id> setCaseId = new Set<Id>();
            //List to store follow up task
            List<Custom_Activity__c> listFollowUpTask = new List<Custom_Activity__c>();
            //Iterating over Trigger.New to get MOS Case Id
            for (Custom_Activity__c taskObj : taskItems) {
                if (taskObj.RecordTypeId != NULL
                    && taskObj.RecordTypeId == ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId
                    && taskObj.Case__c != NULL
                    && taskObj.Case__c.getSObjectType().getDescribe().getName() == ConstantsUtility.CaseObjectName) {
                        setCaseId.add(taskObj.Case__c);
                        listFollowUpTask.add(taskObj);
                    }
            }
            Map<Id, Case> mapIdToReachedTime = new Map<Id, Case>();        //Map to store Case having job type Accidental and Stage Reached
            Map<Id, Case> mapIdToCase = new Map<Id, Case>();               //Map to store all Cases
            //Fetching case corresponding to Ids present in SetCaseId
            if (setCaseId.size() > 0) {
                for (Case caseObj : [SELECT Id,Reached_Time__c,OwnerId,Job_Type__c, MOS_Case_Stage__c 
                                     FROM Case 
                                     WHERE Id IN :setCaseId]) {
                                         mapIdToCase.put(caseObj.Id, caseObj);        // Stores all Cases
                                         if (caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental 
                                             && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Reached) {
                                             mapIdToReachedTime.put(caseObj.Id, caseObj);       //Stores cases which satisfy above condition
                                         }
                                     }
            }
            
            //iterating over follow up task
            if(listFollowUpTask.size() > 0) {
                for (Custom_Activity__c taskObj : listFollowUpTask) {
                    //if Repeat_Call_Notification__c is true then next follow up will be one minute from now
                    if (taskObj.Repeat_Call_Notification__c) {
                        taskObj.Next_Follow_Up_Time__c = System.now().addMinutes(ConstantsUtility.oneMinute);
                    } else if (mapIdToReachedTime.keySet().size() > 0 && mapIdToReachedTime.containsKey(taskObj.Case__c) && mapIdToReachedTime.get(taskObj.Case__c).Reached_Time__c != NULL && (taskObj.Call_Origin__c == ConstantsUtility.TaskCallOriginTechnician || taskObj.Call_Origin__c == ConstantsUtility.TaskCallOriginTowingAgency)) {
                        taskObj.Next_Follow_Up_Time__c = mapIdToReachedTime.get(taskObj.Case__c).Reached_Time__c.addMinutes(ConstantsUtility.SixtyMinutes);
                    }
                    //Subject will be CallOrigin + Subject
                    /*
                    if (trigger.isInsert && String.isNotBlank(taskObj.Call_origin__c)) {
                        taskObj.Subject__c = taskObj.Call_origin__c + ' ' + taskObj.Subject__c;
                        String name = taskObj.Name;
                        if(name.length() > 80) {
                        	taskObj.Name = name.substring(0,76) + '...';  
                        }
                        else if(name.length() <= 80) {
                            taskObj.Name = name;
                        }
                    }
					*/
                    //Update task owner as owner of case
                    if(trigger.isInsert && mapIdToCase.keySet().size() > 0 && mapIdToCase.containsKey(taskObj.Case__c)) {
                        taskObj.OwnerId = mapIdToCase.get(taskObj.Case__c).OwnerId;     
                    }
                }    
            }    
        }
        catch(Exception e) {
            ExceptionHandler.LogError('CustomActivityTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'update Follow Up Information before insert and before update', '', null);    
        }
    }
}