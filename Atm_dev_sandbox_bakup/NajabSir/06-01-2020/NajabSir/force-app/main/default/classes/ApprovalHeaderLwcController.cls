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
    public static ProcessInstanceWorkitem fetchApprovalData(String recordId){
        ProcessInstanceWorkitem piworkItem = new ProcessInstanceWorkitem();
        if(String.isNotBlank(recordId)){
            List<ProcessInstanceWorkitem> piworkItemList = [SELECT id,processInstance.targetObjectId,processInstance.SubmittedBy.Name,processInstance.Status,processInstance.createdDate,Actor.Name,createdDate,processInstanceId,originalActor.Name,createdBy.name FROM ProcessInstanceWorkitem WHERE id =: recordId];
            piworkItem = !piworkItemList.isEmpty() ? piworkItemList[0] : new ProcessInstanceWorkitem();
        }
        return piworkItem;
    }
    //for handling the approval process
    @AuraEnabled
    public static string saveData(String recordId,String actionName,String comments,string processInstanceId){
        try{
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(recordId);
            if(actionName == ConstantsUtility.APPROVE)
                req.setAction(actionName);
            if(actionName == ConstantsUtility.REJECT)
                req.setAction(actionName);
            req.setComments(comments);
            requests.add(req);
            if(requests.size()>0){
                Approval.ProcessResult[] processResults = Approval.process(requests);  
                ProcessInstanceStep ProInsObj = [SELECT id from ProcessInstanceStep where ProcessInstanceId =: processInstanceId order by createdDate desc limit 1];
                return 'success' +'@@'+ProInsObj.Id;
            }
        }
        catch(exception e){
            system.debug('exception-----'+e.getMessage());
            return 'Error : '+e.getMessage();
        }
        return '';
    }
}