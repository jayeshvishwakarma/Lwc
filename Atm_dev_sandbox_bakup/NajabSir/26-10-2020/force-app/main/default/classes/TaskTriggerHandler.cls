/**
* @Autho:- Nishant Prajapati
* @Company-: Techmatrix Consulting
* @Description-: APEX Trigger Handler class of TaskTrigger
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       23 Sept 2019    Nishant     Intial Version
**/
public class TaskTriggerHandler extends TriggerHandler {
    
    private list<Task> taskItems;
    private Map<Id, Task> oldTaskMap;
    public TaskTriggerHandler() {
        this.taskItems = (list<Task>) Trigger.new;
        this.oldTaskMap = (Map<Id, Task>) Trigger.oldMap;
    }
    
    public override void beforeDelete() {
        restrictUser2DelTask(this.taskItems);
    }
    
    public override void afterInsert() {
        captureClosedGeneralTaskDetailOnEnquiry(this.taskItems);
        SendBrochure(this.taskItems);
        // Added By Deepak on 4th Aug.
        updateCCPDetailsOnCase(this.taskItems);
        //Added by Anas Yar Khan 21th Oct 
        updateCustomActivity(this.taskItems,null);
    }
    
    public override void afterUpdate() {
        captureClosedGeneralTaskDetailOnEnquiry(this.taskItems);
        updateCCPDetailsOnCase(this.taskItems);
        //Added by Anas Yar Khan 21th Oct
        updateCustomActivity(this.taskItems,this.oldTaskMap);
    }
    public override void beforeInsert() {
        validateLoanAppliedEnquiry(this.taskItems);
        //Added by Deepak on 17th Aug
        UpdateTaskCTIDisposition(this.taskItems);
    }
    
    
    /**
@Author:                  Anas Yar Khan
@Created Date :           20/10/2020
@Discription:             Update Call Type on Custom Activity
@Date Of Modification :   20/10/2020
*/
    public static void updateCustomActivity(List<Task> triggerNew,Map<Id,Task> oldTaskMap) {
    	List<Custom_Activity__c> listCustomActivityToUpdate = new List<Custom_Activity__c>();
        for(Task tsk : triggerNew) {
            if(tsk.WhatId != NULL 
               && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Custom_Activity__c') {
                   if(trigger.isInsert && tsk.CallType != NULL) {
                   		listCustomActivityToUpdate.add(getCustomActivity(tsk));    
                   }   
                   else if(trigger.isUpdate && tsk.CallType != NULL && tsk.CallType != oldTaskMap.get(tsk.Id).CallType) {
                  		listCustomActivityToUpdate.add(getCustomActivity(tsk));				     
                   }
               }
        } 
        
        if(listCustomActivityToUpdate.size() > 0) {
            update listCustomActivityToUpdate;
        }
    }
    
    public static Custom_Activity__c getCustomActivity(Task tsk) {
    	Custom_Activity__c ca = new Custom_Activity__c();
        ca.Id = tsk.WhatId;
        ca.Call_Type__c = tsk.CallType;  
        return ca;
    }
    
    
    
    
    /**
@Author:                  Nishant Prajapati
@Created Date :           23/09/2019
@Discription:             Restrict users to delete task from UI, other than System Admin and Integration Users.
@Date Of Modification :   23/09/2019
*/
    public static void restrictUser2DelTask(List<Task> tasks) {
        
        List<User> currentUser = [Select Id, Profile.Name from User where Id = :UserInfo.getUserId()];
        if (currentUser.size() > 0) {
            Boolean isAdminOrIntegrationUser = (currentUser[0].Profile.Name == ConstantsUtility.PROFILE_SYSTEM_ADMIN || currentUser[0].Profile.Name == ConstantsUtility.PROFILE_INTEGRATION_USER) ? true : false;
            if (isAdminOrIntegrationUser == false) {
                for (Task item : tasks) {
                    item.addError('You can only cancel or update this Task, Deletion is not allowed');
                }
            }
        }
        
    }
    
    
    /**
@Author:                  Anuj Kumar
@Created Date :           25/10/2019
@Discription:             Hold Details of closed, General Follow Up RecordType Task at Enquiry level and used this to show in Closed FollowUp.
@Date Of Modification :   25/10/2019
*/
    public static void captureClosedGeneralTaskDetailOnEnquiry(List<Task> tasks) {
        
        List<Task> closedGeneralTask = new List<Task>();
        
        Map<String, User> userIdWithObjMap = new Map<String, User>();
        Map<String, Opportunity> opportunityIdWithObjMap = new Map<String, Opportunity>();
        Map<String, List<ClosedFollowUps_JSON_STRUCTURE>> enquiryWithClosedGeneralTaskInfoMap = new Map<String, List<ClosedFollowUps_JSON_STRUCTURE>>();
        
        
        for (Task tsk : tasks) {
            string taskRecordTypeName = tsk.recordTypeId != Null ? Schema.sobjectType.Task.getRecordTypeInfosById().get(tsk.recordTypeId).getName() : Null;
            
            if (tsk.recordTypeId != Null && taskRecordTypeName != Null &&
                tsk.Status == ConstantsUtility.STATUS_COMPLETED &&
                taskRecordTypeName == ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE &&
                String.valueOf(tsk.whatId).startsWith(ConstantsUtility.OPPORTUNITY_KEY_PREFIX)) {
                    
                    closedGeneralTask.add(tsk);
                    userIdWithObjMap.put(tsk.OwnerId, new User());
                    opportunityIdWithObjMap.put(tsk.whatId, new Opportunity());
                }
        }
        
        if (opportunityIdWithObjMap != Null && opportunityIdWithObjMap.size() > 0) {
            
            opportunityIdWithObjMap = new Map<String, Opportunity>([
                Select Id, Name, Closed_General_FollowUp_Details__c,
                DMS_Enquiry_Name__c, StageName
                From Opportunity
                Where Id IN:opportunityIdWithObjMap.keySet()
            ]);
        }
        
        if (userIdWithObjMap != Null && userIdWithObjMap.size() > 0) {
            
            userIdWithObjMap = new Map<String, User>([Select Id, Name from User Where Id IN:userIdWithObjMap.keySet()]);
            
        }
        
        for (Task tsk : closedGeneralTask) {
            
            Opportunity opp = opportunityIdWithObjMap.containsKey(tsk.whatId) ? opportunityIdWithObjMap.get(tsk.whatId) : new Opportunity();
            
            User usr = userIdWithObjMap.containsKey(tsk.OwnerId) ? userIdWithObjMap.get(tsk.OwnerId) : new User();
            
            List<ClosedFollowUps_JSON_STRUCTURE> existingFollowUpDetails = new List<ClosedFollowUps_JSON_STRUCTURE>();
            ClosedFollowUps_JSON_STRUCTURE general = generateFollowUpData(tsk, opp, usr);
            
            if (!enquiryWithClosedGeneralTaskInfoMap.containsKey(tsk.whatId)) {
                enquiryWithClosedGeneralTaskInfoMap.put(tsk.whatId, existingFollowUpDetails);
            }
            enquiryWithClosedGeneralTaskInfoMap.get(tsk.whatId).add(general);
            
        }
        
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        if (enquiryWithClosedGeneralTaskInfoMap != Null && enquiryWithClosedGeneralTaskInfoMap.size() > 0) {
            
            for (String enquiryId : enquiryWithClosedGeneralTaskInfoMap.keySet()) {
                
                Opportunity opp = opportunityIdWithObjMap.containsKey(enquiryId) ? opportunityIdWithObjMap.get(enquiryId) : new Opportunity();
                opp.Id = enquiryId;
                
                String data = JSON.serialize(enquiryWithClosedGeneralTaskInfoMap.get(enquiryId)).contains('&quot;') ?
                    JSON.serialize(enquiryWithClosedGeneralTaskInfoMap.get(enquiryId)).replace('&quot;', '"') :
                JSON.serialize(enquiryWithClosedGeneralTaskInfoMap.get(enquiryId));
                
                opp.Closed_General_FollowUp_Details__c = (opp.Closed_General_FollowUp_Details__c != Null &&
                                                          opp.Closed_General_FollowUp_Details__c != '') ?
                    opp.Closed_General_FollowUp_Details__c + data :
                data;
                
                if (opp.Closed_General_FollowUp_Details__c.contains('][')) {
                    opp.Closed_General_FollowUp_Details__c = opp.Closed_General_FollowUp_Details__c.replace('][', ',');
                }
                
                opportunityList.add(opp);
            }
            
        }
        
        system.debug('== opportunityList ' + opportunityList);
        try {
            DataBase.update(opportunityList, false);
        } catch (Exception ex) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'Task Trigger'; ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('Task Trigger', ex.getMessage(), 'Task Trigger', '', ehst);
        }
        
        
    }
    
    
    Public Static ClosedFollowUps_JSON_STRUCTURE generateFollowUpData(Task tsk, Opportunity opp, User usr) {
        
        ClosedFollowUps_JSON_STRUCTURE general = new ClosedFollowUps_JSON_STRUCTURE();
        general.Remarks = tsk.Description != Null ? tsk.Description : '';
        general.EnquiryNumber = opp.DMS_Enquiry_Name__c != Null ? opp.DMS_Enquiry_Name__c : '';
        general.ReminderDatetime = tsk.ReminderDateTime != Null ? String.valueOf(tsk.ReminderDateTime) : '';
        general.DueDate = tsk.ActivityDate != Null ? string.valueOf(tsk.ActivityDate) : '';
        general.EnquiryStage = opp.StageName != Null ? opp.StageName : '';
        general.Type = ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE;
        general.FollowupStatus = ConstantsUtility.STATUS_COMPLETED;
        general.AssignedTo = usr.Name != Null ? usr.Name : '';
        
        
        return general;
        
    }
    
    
    /**
@Author:                  Nishant Prajapati
@Created Date :           08/11/2019
@Discription:             Bank Appointment cannot be created if Loan Applied on Enquiry is not selected.
*/
    public static void validateLoanAppliedEnquiry(List<Task> tasks) {
        Id bankAppointmentRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(ConstantsUtility.BANK_APPOINTMENT).getRecordTypeId();
        List<Task> tasklList = new List<Task>();
        Set<Id> enquiryIdSet = new Set<Id>();
        
        for (Task tsk : tasks) {
            if (tsk.whatId != Null && String.valueOf((tsk.whatId).getSobjectType()) == ConstantsUtility.OPPORTUNITY) {
                enquiryIdSet.add(tsk.whatId);
                tasklList.add(tsk);
            }
        }
        
        if (enquiryIdSet.size() > 0) {
            
            Map<Id, Opportunity> enquiryMap = new Map<Id, Opportunity>(
                [Select id, Loan_Applied__c,Mobile__c, Customer__c, Customer__r.PersonContactId from Opportunity Where Id IN :enquiryIdSet]);
            
            for (Task tsk : tasklList) {
                Opportunity opp = enquiryMap.containsKey(tsk.whatId) ? enquiryMap.get(tsk.whatId) : new Opportunity();
                
                if (tsk.recordtypeId == bankAppointmentRecordTypeId && opp.Customer__c != Null && opp.Customer__r.PersonContactId != Null) {
                    tsk.whoId = opp.Customer__r.PersonContactId;
                }
                
                if (tsk.recordtypeId == bankAppointmentRecordTypeId && opp.Loan_Applied__c == false) {
                    tsk.addError(System.Label.Bank_Appointment_Task_Error_Message);
                }
            }
        }
    }
    
    /**
@Author:                  Prabhat Sharma
@Created Date :           08/11/2019
@Discription:             Brouchure Request task to create MC Communication records
*/
    public static void SendBrochure(List<Task> tasks) {
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(ConstantsUtility.SEND_BROCHURE).getRecordTypeId();
        Set<Id> enquiryIdSet = new Set<Id>();
        map<Id, String> taskModelmap = new map<Id, String>();
        map<String, Task> taskPhonemap = new map<String, Task>();
        for (Task tsk : tasks) {
            if (tsk.WhatId != null && tsk.RecordTypeId == recordTypeId && String.ValueOf((tsk.WhatId).getSobjectType()) == ConstantsUtility.OPPORTUNITY) {
                enquiryIdSet.add(tsk.whatId);
                taskModelmap.put(tsk.whatId, tsk.Model__c);
                taskPhonemap.put(tsk.whatId, tsk);
            }
        }
        
        if (enquiryIdSet.size() > 0) {
            OpportunityTriggerHelper.esclationLevels = taskModelmap;
            OpportunityTriggerHelper.sendBrochurePhone = taskPhonemap;
            GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.SEND_BROCHURE_METADATA, enquiryIdSet, ConstantsUtility.OPPORTUNITY, '');
        }
    }
    
   
    
    
    
    
    
    
    /**
@Author : Deepak Kumar
@CreatedDate : 4th Aug. 2020
@Description : This method is used to update the related case CCP fields based on the multiple criteria
*/
    public static void updateCCPDetailsOnCase(List<Task> taskItems) {
        try {
            Map<Id, Case> caseMapToUpdate = new Map<Id, Case>();
            Set<Id> caseIdsForDialerDisposition = new Set<Id>();
            for (Task task : taskItems) {
                if (Trigger.isUpdate &&  task.RecordTypeId == ConstantsUtility.TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID && task.whatId !=null
                    && String.valueOf(task.whatId).startsWith(ConstantsUtility.CASE_PREFIX) && task.CallType == ConstantsUtility.CALL_TYPE_OUTBOUND) {
                        // Method to update the Case CCP Status
                        caseMapToUpdate = updateCcpStatus(task, caseMapToUpdate);
                    }
                if(Trigger.isInsert && task.whatId !=null && String.valueOf(task.whatId).startsWith(ConstantsUtility.CASE_PREFIX) ){
                    caseIdsForDialerDisposition.add(task.WhatId);
                }
            }
            //if (caseIdsForDialerDisposition.size() > 0) {
                System.debug('caseIdsForDialerDisposition '+caseIdsForDialerDisposition);
                DialerDispositionWrapper dispositionWrapper = updateDialerDisposition(caseIdsForDialerDisposition, caseMapToUpdate);
                System.debug('dispositionWrapper '+dispositionWrapper);
                
                caseMapToUpdate = dispositionWrapper.caseMapToUpdate;
                if (!caseMapToUpdate.isEmpty()) {
                    Set<Id> caseIdsToCompleteFirstMileStone = new Set<Id>();
                    for (Case caseObj : caseMapToUpdate.values()) {
                        if (caseObj.CCP_Status__c == ConstantsUtility.CCP_STATUS_CONTACTED_COMPLETED) {
                            caseIdsToCompleteFirstMileStone.add(caseObj.Id);
                        }
                    }
                    TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                    update caseMapToUpdate.values();
                    TriggerHandler.clearBypass('CaseTriggerHandler_Strategy');
                    
                    if (caseIdsToCompleteFirstMileStone.size() > 0) {
                        List<String> milestoneNames = new List<String>();
                        milestoneNames.add(ConstantsUtility.CASE_MILESTONE_FIRST_RESPONSE);
                        MilestoneUtils.completeMilestone(caseIdsToCompleteFirstMileStone, milestoneNames, DateTime.now());
                    }
                    
                    // Sending the chatter  notification to L3 or L4
                    if (!dispositionWrapper.escalationUsersMap.isEmpty() && !dispositionWrapper.recordIdVsMessageMap.isEmpty()) {
                        ChatterNotificationUtil.sendChatterNotification(dispositionWrapper.escalationUsersMap, dispositionWrapper.recordIdVsMessageMap);
                    }
                    if(dispositionWrapper.caseActionsForApproval.size() > 0){
                        insert dispositionWrapper.caseActionsForApproval;
                    }
                }
           // }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('TaskTriggerHandler', exp.getMessage(), 'updateCCPDetailsOnCase', '', null);
            
        }
    }
    private static DialerDispositionWrapper updateDialerDisposition(Set<Id> caseIdsForDialerDisposition, Map<Id, Case> caseMapToUpdate) {
        DialerDispositionWrapper dispositionWrapper = new DialerDispositionWrapper();
        List<Case> casesForCampaignUpdate = new List<Case>();
        // Variable to send the chatter notification
        Map<Id, Set<String>> escalationUsersMap = new Map<Id, Set<String>>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        
        List<Case> cases = getCasesWithTasks(caseIdsForDialerDisposition);
        Map<String, Case_Escalations_Matrix__mdt> caseTypeVsCaseEscalationsMatrixMap = new Map<String, Case_Escalations_Matrix__mdt>();
        caseTypeVsCaseEscalationsMatrixMap = CaseTriggerStrategyHelper.getCaseTypeVsCaseEscalationsMatrixMap(caseTypeVsCaseEscalationsMatrixMap);
        List<Approval_Notification_Setting__c> approvalNotificationSettings = [SELECT Approved_Template__c FROM Approval_Notification_Setting__c WHERE Approval_Type__c = :ConstantsUtility.CCP_NUMBER_IF_UNSUCCESSFUL_CONNECTS_NOTIFICATION_NAME LIMIT 1];
        // Iterate over case records
        System.debug('approvalNotificationSettings '+approvalNotificationSettings);
        for (Case caseObj : cases) {
            Integer noOfTasksWithDialerDisposition = 0;
            noOfTasksWithDialerDisposition = caseObj.Tasks.size() > 0 ? getTaskCount(caseObj.Tasks) : 0;
            if (!caseMapToUpdate.containsKey(caseObj.Id)) {
                caseMapToUpdate.put(caseObj.Id, new Case(Id = caseObj.Id));
            }
            Case caseObjTemp = caseMapToUpdate.get(caseObj.Id); // Get the case Object from the Map
            Boolean isNoOfUnsucessFulConnectsChanged = false;
            System.debug(noOfTasksWithDialerDisposition);
            System.debug(caseObjTemp.No_of_Unsuccessful_Connects__c);
            if(noOfTasksWithDialerDisposition != caseObj.No_of_Unsuccessful_Connects__c && noOfTasksWithDialerDisposition !=0){
                // ONLY of Disposition made
                isNoOfUnsucessFulConnectsChanged = true;
                
            }
            System.debug(isNoOfUnsucessFulConnectsChanged);
            caseObjTemp.No_of_Unsuccessful_Connects__c = noOfTasksWithDialerDisposition;
            
            caseObjTemp.CCP_Status__c = caseObjTemp.CCP_Status__c == null ? caseObj.CCP_Status__c : caseObjTemp.CCP_Status__c;
            
            // If the CCP Outbound Call To is CALL TO CUSTOMER AND No_of_Unsuccessful_Connects__c is more then 3
            if (caseObj.CCP_Outbound_Call_To__c == ConstantsUtility.CCP_OUTBOUND_CALL_TO_CUSTOMER && caseObjTemp.No_of_Unsuccessful_Connects__c >= 3 && caseObjTemp.CCP_Status__c != ConstantsUtility.CCP_STATUS_CONTACTED_COMPLETED) {
                caseObjTemp.CCP_Next_Escalation_Date_Time__c = null;  // Removing the  Next Escalation date time
                caseObjTemp.CCP_Status__c = ConstantsUtility.CCP_STATUS_CONTACTED_BY_RO_NOT_CCA_INCOMPLETE ;
            }
            // Updating the CCP_Outbound_Call_Date_Time and CCP_Outbound_Call_To__c of Non Completed cases
            if (caseObjTemp.CCP_Status__c != null && (caseObjTemp.CCP_Status__c == ConstantsUtility.CCP_STATUS_CONTACTED_BY_RO_NOT_CCA_INCOMPLETE)
                || (caseObjTemp.CCP_Status__c == ConstantsUtility.CCP_STATUS_NOT_CONTACTED_INCOMPLETE)) {
                    String caseType = caseObj.Business_Area__c.contains(ConstantsUtility.SALES_CASE_BUSINESS_AREA) ? ConstantsUtility.SALES_CASE_BUSINESS_AREA : ConstantsUtility.CASE_TYPE_SERVICE;
                    //caseType = caseObj.CCP_Attempt_No__c != null ? caseType + '_' + (Integer.valueOf(caseObj.CCP_Attempt_No__c)) : caseType + '_' + (2);
                    
                    if(isNoOfUnsucessFulConnectsChanged && caseObjTemp.No_of_Unsuccessful_Connects__c!=null && Math.mod(Integer.valueOf(caseObjTemp.No_of_Unsuccessful_Connects__c),3) == 0){
                        caseType = caseObj.CCP_Attempt_No__c != null ? caseType + '_' + (Integer.valueOf(caseObj.CCP_Attempt_No__c) + 1) : caseType + '_' + (2);
                        
                    }else if(!isNoOfUnsucessFulConnectsChanged){
                        caseType = caseObj.CCP_Attempt_No__c != null ? caseType + '_' + (Integer.valueOf(caseObj.CCP_Attempt_No__c) + 1) : caseType + '_' + (2);
                        
                    }else{
                        caseType = caseObj.CCP_Attempt_No__c != null ? caseType + '_' + (Integer.valueOf(caseObj.CCP_Attempt_No__c)) : caseType + '_' + (2);
                    }
                    System.debug('caseType :::'+caseType);
                    caseObjTemp = CaseTriggerStrategyHelper.updateCCPInfo(caseTypeVsCaseEscalationsMatrixMap, caseObjTemp, caseType);
                    
                    
                    if (caseObj.CCP_Outbound_Call_To__c != caseObjTemp.CCP_Outbound_Call_To__c) {
                        // Updating the field value for get the Campaign Id
                        caseObjTemp.Channel__c = caseObj.Channel__c;
                        caseObjTemp.Case_Type__c = caseObj.Case_Type__c;
                        caseObjTemp.Business_Area__c = caseObj.Business_Area__c;
                        caseObjTemp.Primary_Category__c = caseObj.Primary_Category__c;
                        caseObjTemp.Mobile_Number__c = caseObj.Mobile_Number__c;
                        caseObjTemp.Stakeholders_JSON__c = caseObj.Stakeholders_JSON__c;
                        caseObjTemp.Selected_Hierarchy_Type__c = caseObj.Selected_Hierarchy_Type__c;
                        casesForCampaignUpdate.add(caseObjTemp);
                    }
                }
            //=====================  After the last level all the thing needs to terminated ==========================
            // Sending chatter notification to L3/L4 and Marking the Case Trigger_CCP_Not_Responded_Flow__c as true
            //caseObjTemp.CCP_Status__c = caseObjTemp.CCP_Status__c == null ? caseObj.CCP_Status__c : caseObjTemp.CCP_Status__c;
            if (caseObjTemp.CCP_Status__c == ConstantsUtility.CCP_STATUS_CONTACTED_BY_RO_NOT_CCA_INCOMPLETE && caseObjTemp.No_of_Unsuccessful_Connects__c >= Integer.valueOf(System.Label.CCP_Max_Unsuccessful_connects)) {
                String message = '';
                if (approvalNotificationSettings != null && approvalNotificationSettings[0].Approved_Template__c != null) {
                    message = approvalNotificationSettings[0].Approved_Template__c;
                    message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT,caseObj.CaseNumber) : message;
                }
                Set<String> userStrings = new Set<String>();
                if (caseObj.L3_Stakeholder__c != null) {
                    userStrings.add(caseObj.L3_Stakeholder__c);
                } else if (caseObj.L4_Stakeholder__c != null) {
                    userStrings.add(caseObj.L4_Stakeholder__c);
                }
                if (userStrings.size() > 0) {
                    escalationUsersMap.put(caseObj.Id, userStrings);
                    recordIdVsMessageMap.put(caseObj.Id, message);
                }
                caseObjTemp.Trigger_CCP_Not_Responded_Flow__c = true;
                Case_Actions__c caseActions = new Case_Actions__c();
                caseActions.Name = ConstantsUtility.CASE_ACTIONS_CCP_NOT_RESPONDED_FLOW;
                caseActions.RecordTypeId = ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID ;
                caseActions.Case_Number__c = caseObj.Id;
                dispositionWrapper.caseActionsForApproval.add(caseActions);
                
            }
            caseMapToUpdate.put(caseObjTemp.Id, caseObjTemp);
        }
        // Getting the updated value for campaign and related phone numbers
        if (casesForCampaignUpdate.size() > 0) {
            caseMapToUpdate = CaseTriggerStrategyHelper.ccpCampaignDetectionHelper(casesForCampaignUpdate, caseMapToUpdate);
            System.debug('caseMapToUpdate '+caseMapToUpdate);
        }
        dispositionWrapper.caseMapToUpdate = caseMapToUpdate;
        dispositionWrapper.escalationUsersMap = escalationUsersMap;
        dispositionWrapper.recordIdVsMessageMap = recordIdVsMessageMap;
        return dispositionWrapper;
    }
    public class DialerDispositionWrapper {
        public Map<Id, Case> caseMapToUpdate;
        public Map<Id, Set<String>> escalationUsersMap;
        public Map<Id, String> recordIdVsMessageMap;
        public List<Case_Actions__c> caseActionsForApproval = new List<Case_Actions__c>();
        
    }
    private static Map<Id, Case> updateCcpStatus(Task task, Map<Id, Case> caseMapToUpdate) {
        Case caseObj = new Case();
        if (caseMapToUpdate.containsKey(task.WhatId)) {
            caseObj = caseMapToUpdate.get(task.WhatId);
        }
        // Condition 1
        if (task.Wrap_Up_Code__c == ConstantsUtility.WRAP_UP_CODE_NEXT_CALL) {
            caseObj.Id = task.WhatId;
            caseObj.CCP_Status__c = ConstantsUtility.CCP_STATUS_CONTACTED_COMPLETED;
            caseObj.CCP_Complete_Time__c = Datetime.now();
            caseObj.CCP_Outbound_Call_Date_Time__c = null;
            caseObj.CCP_Next_Escalation_Date_Time__c = null;
            caseMapToUpdate.put(caseObj.Id, caseObj);
            // caseIdsToCompleteFirstMileStone.add(task.WhatId); // Adding caseIds to complete the milestone for Contacted Cases
            // Condition 2
        } else if (task.Wrap_Up_Code__c == ConstantsUtility.WRAP_UP_CODE_NEXT_CALL_COMPLAINT && !caseMapToUpdate.containsKey(task.WhatId)) { // If task is al
            caseObj.Id = task.WhatId;
            caseObj.CCP_Status__c = ConstantsUtility.CCP_STATUS_NOT_CONTACTED_INCOMPLETE;
            // Need to update the CCP_Outbound_Call_Date_Time__c to next call
            caseMapToUpdate.put(caseObj.Id, caseObj);
        }
        
        return caseMapToUpdate;
    }
    private static List<Case> getCasesWithTasks(Set<Id> caseIdsForDialerDisposition) {
        Id taskRecordTypeId = ConstantsUtility.TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID;
        String outboundCallType = ConstantsUtility.CALL_TYPE_OUTBOUND;
        // Query The cases along with related tasks so we can count the Dialer Dispositions
        return [
            SELECT Id,CCP_Outbound_Call_To__c,CCP_Attempt_No__c,No_of_Unsuccessful_Connects__c,CCP_Status__c,Mobile_Number__c,L3_Stakeholder__c,L4_Stakeholder__c,
            CCP_Next_Escalation_Date_Time__c,CCP_Escalated__c,Channel__c,Primary_Category__c,CampaignId__c,Stakeholders_JSON__c,Selected_Hierarchy_Type__c,
            Mobile_Number_1__c,Mobile_Number_2__c,Mobile_Number_3__c,Mobile_Number_4__c,CaseNumber,Assigned_Date__c,
            RecordTypeId,Dealer_Name__c,Case_Type__c,Business_Area__c,CCP_Outbound_Call_Date_Time__c, (SELECT Disposition_Code__c, Disposition_Detail__c FROM Tasks)
            FROM Case
            WHERE Id IN:caseIdsForDialerDisposition
        ];
    }
    private static Integer getTaskCount(List<Task> tasks) {
        Integer count = 0;
        for (Task taskObj : tasks) {
            if (taskObj.Disposition_Code__c != null && taskObj.Disposition_Detail__c != null) {
                count++;
            }
        }
        return count;
    }
    
    /**
@Author : Deepak Kumar
@CreatedDate : 17th Aug. 2020
@Description :This will update the Record Type of task based on the Call Type and also populate the Campaign Id from Case
*/
    public static void UpdateTaskCTIDisposition(List<Task> tasks) {
        Set<Id> caseIds = new Set<Id>();
        for (Task task : tasks) {
            // Updating the Task record Type if call type id not blank
            if (task.CallType != null) {
                task.RecordTypeId = ConstantsUtility.TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID;
            }
            if (task.WhatId !=null && String.valueOf(task.WhatId).startsWith(ConstantsUtility.CASE_PREFIX)) {
                caseIds.add(task.WhatId);
            }
        }
        if (caseIds.size() > 0) {
            Map<Id, Case> caseMap = new Map<Id, Case>();
            for (Case caseObj : getCasesWithTasks(caseIds)) {
                System.debug('caseObj '+caseObj);
                if (caseObj.CampaignId__c != null) {
                    caseMap.put(caseObj.Id, new Case(Id = caseObj.Id, CampaignId__c = caseObj.CampaignId__c));
                }
            }
            if (!caseMap.isEmpty()) {
                for (Task task : tasks) {
                    // Updating the Task campaign id in task if campaign is on thr tak object
                    if (task.WhatId != null && caseMap.containsKey(task.WhatId)) {
                        task.CampaignId__c = caseMap.get(task.WhatId).CampaignId__c;
                    }
                }
            }
        }
    }
    
}