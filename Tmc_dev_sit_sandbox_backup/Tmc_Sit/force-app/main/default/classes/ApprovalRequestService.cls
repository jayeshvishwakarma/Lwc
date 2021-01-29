/**
* @File Name          : ApprovalRequestService.cls
* @Description        : Apex Class to handler all approval request
* @Author             : Prabhat Sharma
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 6/05/2020, 11:29:29 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM         Prabhat Sharma         Initial Version 
**/


public without sharing class ApprovalRequestService{

    
      /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to trigger approval request
        Inputs: Id of the objects and approval process API name
        Returns: void
        History:
        ================
        1.0     05 June 2020      Prabhat     Initial Version
    */
    
    public static void initiateApprovalRequests(set<Id> requestIds, String approvalProcessName){
        try {
            
            List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest> ();
            
            for (Id recordId : requestIds) {
                // Create an approval request 
                Approval.ProcessSubmitRequest reqObj = new Approval.ProcessSubmitRequest();
                reqObj.setComments('Submitting request for approval');
                reqObj.setObjectId(recordId);
                // Submit on behalf of a specific submitter
                reqObj.setSubmitterId(UserInfo.getUserId());
                /****Change Added by Nitin on 27th September 2020*****/
                if(String.isNotBlank(approvalProcessName)){
                    reqObj.setProcessDefinitionNameOrId(approvalProcessName);
                }
                /****************************************************/
                approvalRequests.add(reqObj);
            }
    
    
            Approval.ProcessResult[] processResults = Approval.process(approvalRequests, true);
        }catch (System.DmlException e) {
            //Create custom error records
        }
    }
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to get record type Id as key and developer name as value in a map
        Inputs: map of Id and record type
        Returns: void
        History:
        ================
        1.0     08 June 2020      Prabhat     Initial Version
    */
    public static map<Id,RecordType> fetchRecordTypeName(String sObjectType){
        
        Map<Id,RecordType> sObjectRecordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType=:sObjectType]); 
        
        return sObjectRecordTypeMap;
        
    }
}