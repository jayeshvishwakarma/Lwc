/**
     * @File Name          : L8ServiceApprovalController.cls
     * @Description        : This class is responsible to function for L8ServiceApproval component
     * @Author             : Deepak Kumar
     * @Last Modified By   : Deepak Kumar
     * @Last Modified On   : 07/09/2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0       07/09/2020                Deepak Kumar              Initial Version
**/


public without sharing class L8ServiceApprovalController {
    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: This methodd is responsible to get the initial data from case action
       Inputs:  String recordId
       Returns: String
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0       07/09/2020             Deepak Kumar              Initial Version
   **/
    @AuraEnabled
    public static InitialInfo getCaseActionL8Approver(String recordId) {
        try {
            InitialInfo initialInfo = new InitialInfo();
            String l8Json;
            Case_Actions__c caseActions = getCaseActions(recordId);
            if (caseActions != null) {
                l8Json = caseActions.Service_Revalidation_JSON__c;
                l8Json = l8Json !=null && l8Json.length() < 50 ? null : l8Json;
            }
            if (l8Json == null && caseActions != null) {
                // Populate Service_Revalidation_JSON__c on case Action
                l8Json = populateServiceRevalidationJSON(caseActions);
            }
            initialInfo.l8Json =l8Json;
            initialInfo.workshopReasons = JSON.serialize(getWorkshopReasons());
            return initialInfo;
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getMessage());
        }
    }
    public static List<PickListObj> getWorkshopReasons(){
        List<PickListObj> workshopReasons = new List<L8ServiceApprovalController.PickListObj>();
        Schema.DescribeFieldResult fieldResult = Case_Actions__c.Workshop_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            PickListObj obj = new PickListObj();
            obj.label = f.getLabel();
            obj.value = f.getValue();
            workshopReasons.add(obj);
            //options.add(new Sele.ctOption(f.getLabel(), f.getValue()));
        }
        return workshopReasons;
    }
    public class InitialInfo {
        @AuraEnabled public String l8Json;
        @AuraEnabled public String workshopReasons;
    }
    public class PickListObj {
         public String label;
         public String value;
    }
    private static Case_Actions__c getCaseActions(String recordId) {
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
        caseActions = [
                SELECT Id,Service_Revalidation_JSON__c,
                        L8A_Stakeholder__c,L8A_Stakeholder__r.Name,
                        L8B_Stakeholder__c,L8B_Stakeholder__r.Name,
                        L8C_Stakeholder__c,L8C_Stakeholder__r.Name,
                        L8D_Stakeholder__c,L8D_Stakeholder__r.Name,
                        L8E_Stakeholder__c,L8E_Stakeholder__r.Name,
                        Case_Number_Text__c,Case_Number__r.Channel__c,Case_Number__c
                FROM Case_Actions__c
                WHERE Id = :recordId
        ];
        if (caseActions.size() > 0) {
            return caseActions[0];
        }
        return null;
    }
    private static String populateServiceRevalidationJSON(Case_Actions__c caseActions) {
        String l8Json = '';
        List<ApproverWrapper> approverWrappers = new List<ApproverWrapper>();
        ApproverWrapper approverWrapper = new ApproverWrapper();
        if (caseActions.L8A_Stakeholder__c != null) {
            approverWrapper.approverId = caseActions.L8A_Stakeholder__c;
            approverWrapper.approver = caseActions.L8A_Stakeholder__r.Name;
            approverWrappers.add(approverWrapper);
        }
        if (caseActions.L8B_Stakeholder__c != null) {
            approverWrapper = new ApproverWrapper();
            approverWrapper.approverId = caseActions.L8B_Stakeholder__c;
            approverWrapper.approver = caseActions.L8B_Stakeholder__r.Name;
            approverWrappers.add(approverWrapper);
        }
        if (caseActions.L8C_Stakeholder__c != null) {
            approverWrapper = new ApproverWrapper();
            approverWrapper.approverId = caseActions.L8C_Stakeholder__c;
            approverWrapper.approver = caseActions.L8C_Stakeholder__r.Name;
            approverWrappers.add(approverWrapper);
        }
        if (caseActions.L8D_Stakeholder__c != null) {
            approverWrapper = new ApproverWrapper();
            approverWrapper.approverId = caseActions.L8D_Stakeholder__c;
            approverWrapper.approver = caseActions.L8D_Stakeholder__r.Name;
            approverWrappers.add(approverWrapper);
        }
        if (caseActions.L8E_Stakeholder__c != null) {
            approverWrapper = new ApproverWrapper();
            approverWrapper.approverId = caseActions.L8E_Stakeholder__c;
            approverWrapper.approver = caseActions.L8E_Stakeholder__r.Name;
            approverWrappers.add(approverWrapper);
        }
        if (approverWrappers.size() > 0) {
            caseActions.Service_Revalidation_JSON__c = JSON.serialize(approverWrappers);
            l8Json = caseActions.Service_Revalidation_JSON__c;
            TriggerHandler.bypass('CaseActionsTriggerHandler');
            update caseActions;
            TriggerHandler.clearBypass('CaseActionsTriggerHandler');
        }
        return l8Json;
    }
    public class ApproverWrapper {
        public String approver = '';
        public String approverId;
        public String decision = 'Pending';
        public String workshopReason = '';
        public String remarks = '';
    }
    /**
      Author: Deepak Kumar
      Company: Techmatrix
      Description: This methodd is responsible update the case action record and related approval
      Inputs:  String recordId, String jsonData, Integer approveCount, Integer rejectCount, Integer totalItems
      Returns: String
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
      * 1.0       07/09/2020             Deepak Kumar              Initial Version
      **/
    @AuraEnabled
    public static String updateCaseAction(String recordId, String approverData) {
        try {
            Case_Actions__c caseActions = getCaseActions(recordId);
            if (caseActions != null) {
                Integer approveCount = 0;
                Integer rejectCount = 0;
                Integer totalItems = 0; // always should be 5
                List<ApproverWrapper> approverWrappers = (List<ApproverWrapper>) System.JSON.deserialize(approverData, List<ApproverWrapper>.class);

                if (approverWrappers != null && approverWrappers.size() > 0) {
                    Set<String> approverUserIds = new Set<String>();
                    totalItems = approverWrappers.size();
                    String l8A_WorkshopReason;
                    String l8B_WorkshopReason;
                    for (ApproverWrapper wrapper : approverWrappers) {
                        if (wrapper.decision == 'Approve') {
                            approveCount++;
                        }
                        if (wrapper.decision == 'Reject') {
                            rejectCount++;
                            if (wrapper.approverId == caseActions.L8A_Stakeholder__c) {
                                l8A_WorkshopReason = wrapper.workshopReason;
                            } else if (wrapper.approverId == caseActions.L8B_Stakeholder__c) {
                                l8B_WorkshopReason = wrapper.workshopReason;
                            }
                        }
                        // For Chatter Notifications
                        approverUserIds.add(wrapper.approverId);
                    }
                    if (approveCount == totalItems) {
                        updateApproval('Approve', recordId);
                       // caseActions.Approval_Status__c = ConstantsUtility.Pending_Ringi_Approval;
                    } else if (rejectCount == totalItems) {
                        updateApproval('Reject', recordId);
                      //  caseActions.Approval_Status__c = ConstantsUtility.STATUS_REJECTED;
                        // Updating the related case
                        Case relatedCaseToUpdate;
                        if (caseActions.Case_Number__r.Channel__c != null && (caseActions.Case_Number__r.Channel__c == ConstantsUtility.ARENA_CASE_CHANNEL || caseActions.Case_Number__r.Channel__c == ConstantsUtility.COMMERCIAL_CASE_CHANNEL)) {
                            relatedCaseToUpdate = new case (id = caseActions.Case_Number__c, Workshop_Reason__c = l8A_WorkshopReason);
                        } else if (caseActions.Case_Number__r.Channel__c != null && caseActions.Case_Number__r.Channel__c == ConstantsUtility.NEXA_CASE_CHANNEL) {
                            relatedCaseToUpdate = new case (id = caseActions.Case_Number__c, Workshop_Reason__c = l8B_WorkshopReason);
                        }
                        if (relatedCaseToUpdate != null && relatedCaseToUpdate.Id != null) {
                            TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                            update relatedCaseToUpdate;
                            TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
                        }
                    }
                    caseActions.Service_Revalidation_JSON__c = approverData;
                    TriggerHandler.bypass('CaseActionsTriggerHandler');
                    update caseActions;
                    TriggerHandler.clearBypass('CaseActionsTriggerHandler');

                    if ((approveCount + rejectCount) == totalItems && approverUserIds.size() > 0 && rejectCount > 0 && approveCount > 0) {
                        // Some user shave rejected and some have approved and all response received
                        Map<String, Approval_Notification_Setting__c> approvalTypeVsNotificationSettingsMap = new Map<String, Approval_Notification_Setting__c>();
                        for (Approval_Notification_Setting__c notificationSetting : [SELECT Name,Approval_Type__c,Approved_Template__c FROM Approval_Notification_Setting__c WHERE isActive__c = true AND Approval_Type__c = :ConstantsUtility.UNJUSTIFIED_APPROVAL_L8_DECISION_NOT_UNIFIED]) {
                            approvalTypeVsNotificationSettingsMap.put(notificationSetting.Approval_Type__c, notificationSetting);
                        }
                        if (!approvalTypeVsNotificationSettingsMap.isEmpty()) {
                            String message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.UNJUSTIFIED_APPROVAL_L8_DECISION_NOT_UNIFIED).Approved_Template__c;
                            message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, caseActions.Case_Number_Text__c) : message;
                            /** NEED to Send Notification to all L8 users */
                            Map<Id, Set<String>> escalationUsersMap = new Map<Id, Set<String>>();
                            escalationUsersMap.put(recordId, approverUserIds);
                            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
                            recordIdVsMessageMap.put(recordId, message);
                            //System.debug(escalationUsersMap);
                            // System.debug(recordIdVsMessageMap);
                            ChatterNotificationUtil.sendChatterNotification(escalationUsersMap, recordIdVsMessageMap);
                        }
                    }
                }
                return 'success';
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getStackTraceString()+'  '+exp.getMessage());
        }
        return null;
    }
    private static String updateApproval(String action, String recordId) {

        // System.debug('recordId ' + recordId);
        Set<Id> processInstanceIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status = 'Pending' and TargetObjectId = :recordId])).keySet();
        Map<Id,ProcessInstanceWorkitem> idProcessInstanceWorkitemMap = new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId,ActorId,Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :processInstanceIds]);

        for (Id pInstanceWorkitemsId : idProcessInstanceWorkitemMap.keySet()) {
            // System.debug(pInstanceWorkitemsId);
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(action);
            req2.setAction(action);
            // req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(pInstanceWorkitemsId);
            // Submit the request for approval
            Approval.ProcessResult result2 = Approval.process(req2);
//            if (action == 'Reject' && UserInfo.getUserId() == idProcessInstanceWorkitemMap.get(pInstanceWorkitemsId).ActorId) {
//                Approval.ProcessResult result2 = Approval.process(req2);
//                break;
//            }else if (action == 'Approve'){
//                // Approve all
//                 Approval.ProcessResult result2 = Approval.process(req2);
//            }
        }
        return 'success';
    }
}