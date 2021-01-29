/**
     * @File Name          : ApproveRejectComponentController.cls
     * @Description        : This class approve or reject the record during approval process based on the assigned user
     * @Author             : Deepak Kumar
     * @Last Modified By   : Deepak Kumar
     * @Last Modified On   : 14/07/2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        14/07/2020                Deepak Kumar              Initial Version
**/

public with sharing class ApproveRejectComponentController {

    @AuraEnabled
    public static Boolean isCurrentAndAssignUserIsSame(String recordId) {
        try {
            List<ProcessInstanceWorkitem> processInstanceWorkitems = new List<ProcessInstanceWorkitem>();
            processInstanceWorkitems = [SELECT actorId,actor.name,ProcessInstance.Status from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status = 'Pending' LIMIT 1];
            if (processInstanceWorkitems.size() > 0 && processInstanceWorkitems[0].ActorId == UserInfo.getUserId()) {
                return true;
            }
            return false;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean updateApprovalAction(String recordId, String approverAction, String approverComments) {
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(approverComments);
            //Approve or Reject Record
            req.setAction(approverAction);
            //Getting Work Item Id
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :recordId];
            req.setWorkitemId(pItem.Id);
            // Submit the request for approval
            Approval.ProcessResult result = Approval.process(req);
            return true;
        } catch (Exception exp) {
            System.debug(exp.getMessage());
            throw new AuraHandledException(exp.getMessage());
        }
    }
}