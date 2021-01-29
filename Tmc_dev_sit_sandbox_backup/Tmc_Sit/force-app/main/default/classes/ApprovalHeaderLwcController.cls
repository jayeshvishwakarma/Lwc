/**
* @File Name          : ApprovalHeaderLwcController.cls
* @Description        : class for handle Approval Process 
* @Author             : 
* @Group              : 
* @Last Modified By   : Prashant Gahlaut
* @Last Modified On   : 2/11/2020, 11:00 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    2/11/2020, 11:00 AM         Prashant Gahlaut        Initial Version
**/
public without sharing class ApprovalHeaderLwcController {
    //for fetching ProcessInstanceWorkitem data 
    @AuraEnabled
    public static ProcessInstanceWorkitem fetchApprovalData(String recordId) {
        ProcessInstanceWorkitem piworkItem = new ProcessInstanceWorkitem();
        if (String.isNotBlank(recordId)) {
            List<ProcessInstanceWorkitem> piworkItemList = [SELECT id,processInstance.targetObjectId,processInstance.SubmittedBy.Name,processInstance.Status,processInstance.createdDate,Actor.Name,createdDate,processInstanceId,originalActor.Name,createdBy.name FROM ProcessInstanceWorkitem WHERE id = :recordId];
            piworkItem = !piworkItemList.isEmpty() ? piworkItemList[0] : new ProcessInstanceWorkitem();
        }
        return piworkItem;
    }
    //for handling the approval process
    @AuraEnabled
    public static string saveData(String recordId, String actionName, String comments, string processInstanceId) {
        try {
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(recordId);
            if (actionName == ConstantsUtility.APPROVE)
                req.setAction(actionName);
            if (actionName == ConstantsUtility.REJECT)
                req.setAction(actionName);
            req.setComments(comments);
            requests.add(req);
            if (requests.size() > 0) {
                Approval.ProcessResult[] processResults = Approval.process(requests);
                ProcessInstanceStep ProInsObj = [SELECT id from ProcessInstanceStep where ProcessInstanceId = :processInstanceId order by createdDate desc limit 1];
                updateComments(recordId,comments);
                return 'success' + '@@' + ProInsObj.Id;
            }
        } catch (exception e) {
            system.debug('exception-----' + e.getMessage());
            return 'Error : ' + e.getMessage();
        }
        return '';
    }


    /**
     Author: Deepak Kumar
     Company: Techmatrix Consulting
     Description: This method will be used to copy approval step comments to the custom fields on case action
     */
    public static String updateComments(String recordId, String comments) {
        try {
            if (recordId != null) {
                List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
                caseActions = [SELECT Id,Name FROM Case_Actions__c WHERE Id = :recordId LIMIT 1];

                if (!caseActions.isEmpty()) {
                    Case_Actions__c caseAction = caseActions[0];
                    String currentUserId = UserInfo.getUserId();

                    if (currentUserId == caseAction.L2A_Stakeholder__c || currentUserId == caseAction.L2B_Stakeholder__c) {
                        caseAction.CCM_Remarks__c = comments;
                    }
                    if (currentUserId == caseAction.L3A_Stakeholder__c) {
                        caseAction.TSM_Remarks__c = comments;
                    }
                    if (currentUserId == caseAction.L4_Stakeholder__c) {
                        caseAction.Regional_Head_Remarks__c = comments;
                    }
                    if (currentUserId == caseAction.L5_Stakeholder__c) {
                        caseAction.Zonal_Head_Remarks__c = comments;
                    }
                    if (currentUserId == caseAction.L6A_Stakeholder__c) {
                        caseAction.SNP_Head_Remarks__c = comments;
                    }
                    if (currentUserId == caseAction.Transferred_Dealer_Approver__c) {
                        caseAction.Transferred_Regional_Head_Comments__c = comments;
                    }
                    if (caseAction.Name == ConstantsUtility.On_Hold) {
                        caseAction.Hold_Rejection_Comments__c = comments;
                    }
                    // For Legal User
                    if (String.valueOf(caseAction.OwnerId).startsWith(ConstantsUtility.OOG) && String.valueOf(caseAction.Owner.Name).containsIgnoreCase(ConstantsUtility.LEGAL)) {
                        Set<Id> queueIds = new Set<Id>();
                        queueIds.add(caseAction.OwnerId);
                        Map<Id, Set<String>> queueIdVsMembersMap = CaseActionsTriggerHandler.getQueueMembersMap(queueIds);
                        if (!queueIdVsMembersMap.isEmpty() && queueIdVsMembersMap.containsKey(caseAction.OwnerId)) {
                            caseAction.Legal_Comments__c = queueIdVsMembersMap.get(caseAction.OwnerId).contains(currentUserId) ? comments : '';
                        }
                    }


                    TriggerHandler.bypass('CaseActionsTriggerHandler');
                    update caseAction;
                    TriggerHandler.clearBypass('CaseActionsTriggerHandler');

                }
            }
        } catch (exception exp) {
            ExceptionHandler.LogError('ApprovalHeaderLwcController', exp.getStackTraceString(), 'updateComments', '', null);
            System.debug('Exception Message :: ' + exp.getMessage() + 'At  ' + exp.getStackTraceString());
        }
        return null;
    }
}