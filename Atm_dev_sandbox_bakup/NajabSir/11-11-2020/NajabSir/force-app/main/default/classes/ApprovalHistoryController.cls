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
public without sharing class ApprovalHistoryController {

    public static final String APPROVE_ACTION = 'Approve';
    public static final String REJECT_ACTION = 'Reject';
    public static final String RECALL_ACTION = 'Removed';

    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchUsers(String searchTerm) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, FirstName, LastName)
            LIMIT :ApprovalHistoryUtil.MAX_RESULTS 
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User currUser : users) {
            results.add(
                new LookupSearchResult(
                    currUser.Id,
                    'User',
                    userIcon,
                    currUser.FirstName + ' ' + currUser.LastName,
                    ''
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled
    public static String processStep(String recordId, String comments, String nextApproverId, String action){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];

        return ApprovalHistoryUtil.processStep(workItems,comments, nextApproverId,  action);
    }

    @AuraEnabled
    public static void reassignStep(String recordId, String newActorId ){
        List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = : recordId];
        ApprovalHistoryUtil.reassignStep(workItemList, newActorId);
    }


    @AuraEnabled
    public static String submitForApproval(String recordId, String comments, String nextApproverId){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(comments);
        if(!String.isBlank(nextApproverId)){
            req.setNextApproverIds(new Id[] {nextApproverId});
        }
        req.setObjectId(recordId);
        
        // Submit on behalf of a specific submitter
        req.setSubmitterId(ApprovalHistoryUtil.currentUserId); 
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req);
        ApprovalHeaderLwcController.updateComments(recordId,comments); // Calling method to copy comments Added By Deepak 23rd Nov.
        return JSON.serialize(result);
        
    }


    @AuraEnabled (cacheable=true)
    public static ApprovalHistory getApprovalHistory(String recordId){  
                       
        List<ProcessInstance> processInstances = [SELECT Id,SubmittedById, ProcessDefinition.Name , (SELECT ID, ProcessNodeId,
                                                            StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                            ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                            OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by IsPending DESC, CreatedDate DESC )   
                                                    FROM ProcessInstance where TargetObjectId =:recordId order by CreatedDate DESC];
        ApprovalHistory approvalHistory = ApprovalHistoryUtil.populateApprovalHistorySteps(processInstances, recordId);
        // Case where Queue User can approve the case

        if(!approvalHistory.isCurrentUserApprover && approvalHistory.approvalSteps.size() > 0
                && approvalHistory.approvalSteps[0].stepStatus == 'Pending' && String.valueOf(processInstances[0].StepsAndWorkitems[0].ActorId).startsWith(ConstantsUtility.OOG)){
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            String query = 'Select Id,Name,OwnerId From '+sObjName+' Where Id =:recordId';
            List<SObject> objList =  Database.query(query);
            if(objList.size() > 0){
                //Check for Legal flow - Queue users should be allowed to approve reject
                String recordtypeName = String.valueOf(objList[0].get('Name'));
                if(String.isNotBlank(recordtypeName) && recordtypeName=='Legal'){
                    Id queueId = Id.valueOf(String.valueOf(objList[0].get('OwnerId')));
                    Set<Id> queueIds = new Set<Id>();
                    queueIds.add(queueId);
                    Map<Id, Set<String>> idToMembersIds = CaseActionsTriggerHandler.getQueueMembersMap(queueIds);
                    approvalHistory.isCurrentUserApprover = !idToMembersIds.isEmpty() && idToMembersIds.get(queueId).contains(String.valueOf(UserInfo.getUserId()));
                }else{
                    approvalHistory.isCurrentUserApprover = Id.valueOf(String.valueOf(objList[0].get('OwnerId'))) ==  UserInfo.getUserId();
                }
            }
        }

        return approvalHistory;
                                                                            
    }  

    public class ApprovalHistoryStep{
        @AuraEnabled  
        public String stepName {get;set;}  
        @AuraEnabled  
        public String stepUrl {get;set;}
        @AuraEnabled  
        public DateTime createdDate {get;set;}   
        @AuraEnabled  
        public String stepStatus {get;set;}  
        @AuraEnabled  
        public String assignedTo {get;set;}   
        @AuraEnabled  
        public String assignedToUrl {get;set;}
        @AuraEnabled
        public String comments {get;set;}
        
        public ApprovalHistoryStep(
            String stepName,
            String stepId,
            DateTime createdDate, 
            String stepStatus,
            String assignedTo,
            String assignedToId,
            String comments )  
        { 
            this.stepName = stepName;
            this.stepUrl = '/' + stepId;
            this.createdDate = createdDate;
            this.assignedTo = assignedTo;  
            this.assignedToUrl = '/'+assignedToId;
            this.comments = comments;

            if(stepStatus == ApprovalHistoryUtil.STATUS_STARTED){
                this.stepStatus = ApprovalHistoryUtil.STATUS_SUBMITTED;
            }else if(stepStatus == ApprovalHistoryUtil.STATUS_REMOVED){
                this.stepStatus = ApprovalHistoryUtil.STATUS_RECALLED;
            }else{
                this.stepStatus = stepStatus;
            }
            
        } 
    }

    public class ApprovalHistory{
        @AuraEnabled
        public List<ApprovalHistoryStep> approvalSteps;
        @AuraEnabled
        public String approvalStepsSize;
        @AuraEnabled 
        public boolean isCurrentUserApprover; 
        @AuraEnabled 
        public boolean showRecall;  //Modify All Data" permission or "Modify All" on the object level
                                    // system admin and submitter(if it says so on the approval process)
                                        //SELECT Name FROM Profile WHERE PermissionsModifyAllData = true
                                    //query permission sets with modify all or modify all for object and see if curr user has them

        @AuraEnabled 
        public boolean showSubmitForApproval; 
        public ApprovalHistory(List<ApprovalHistoryStep> approvalSteps, boolean isCurrentUserApprover, boolean isSubmitForApproval, boolean showRecall){
            this.approvalSteps = approvalSteps;
            this.isCurrentUserApprover = isCurrentUserApprover; 
            //this.approvalStepsSize = moreThan6Steps ? '6+' : string.valueOf(approvalSteps.size());
            this.showSubmitForApproval = isSubmitForApproval;
            this.showRecall = showRecall;
        }
    }


}