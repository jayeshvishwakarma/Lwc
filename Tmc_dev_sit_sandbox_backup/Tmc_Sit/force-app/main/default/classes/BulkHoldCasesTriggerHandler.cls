public class BulkHoldCasesTriggerHandler extends TriggerHandler{
    private list<Bulk_Hold_Cases__c> newBulkHoldCasesList; //Used to store the list of new Bulk Hold Cases
    private map<id,Bulk_Hold_Cases__c> OldBulkHoldCasesmap; //Used to store the map of old Bulk Hold Cases
    
    public BulkHoldCasesTriggerHandler() {
        this.newBulkHoldCasesList= (List<Bulk_Hold_Cases__c>) Trigger.new;
        this.OldBulkHoldCasesmap= (map<id,Bulk_Hold_Cases__c>) Trigger.oldmap;
    }
    
    public override void beforeInsert() {
        
    }
    public override void afterInsert() {
        initiateBulkHoldApprovalProcess();
    }
    public override void afterupdate() {
        updateApprovalStatusOnCase();
        sendChatterNotifications();
    }
    public override void beforeupdate(){
        changeCaseActionOwner();
    }
    

    
    /**
Author: Gitika
Company: Techmatrix
Description: Method to update current approver as owner 
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        05/06/2020                Gitika            Initial Version
**/
    public void changeCaseActionOwner() {
        for (Bulk_Hold_Cases__c BulkHoldObj : this.newBulkHoldCasesList) {
            if (BulkHoldObj.Current_Approver__c != null && this.OldBulkHoldCasesmap.get(BulkHoldObj.Id).Current_Approver__c != BulkHoldObj.Current_Approver__c) {
                BulkHoldObj.OwnerId = BulkHoldObj.Current_Approver__c;
            }
        }
    }
    
    /**
Author: Gitika
Company: Techmatrix
Description: Method to Initiate approval process on Bulk Hold Cases
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        05/06/2020                Gitika            Initial Version
**/ 
    
    public void initiateBulkHoldApprovalProcess(){
        
        //Set to store all case action record Ids
        set<Id> BulkHoldObjIds = new set<Id>();
        //Map for record type and Approval Process names from custom metadata type
        Map<String,String> approvalMatrixMap = new map<String,String>();
        try{
            for(Case_Action_Approval_Matrix__mdt approvalMatrixObj : [SELECT Id,DeveloperName,Approval_Process_API_Name__c FROM Case_Action_Approval_Matrix__mdt]){
                approvalMatrixMap.put(approvalMatrixObj.DeveloperName, approvalMatrixObj.Approval_Process_API_Name__c);
            }
            
            for(Bulk_Hold_Cases__c BulkHoldObj : newBulkHoldCasesList){
                BulkHoldObjIds.add(BulkHoldObj.Id);
            }
            // initiate the approval process
            if(approvalMatrixMap.containskey(ConstantsUtility.Recordtype_Bulk_Hold)){
                
                String approvalProcessName = approvalMatrixMap.get(ConstantsUtility.Recordtype_Bulk_Hold);
                
                ApprovalRequestService.initiateApprovalRequests(BulkHoldObjIds,approvalProcessName);   
            }
        }
        catch(exception e){
            ExceptionHandler.LogError('BulkHoldCasesTriggerHelper', e.getMessage(), 'initiateBulkHoldApprovalProcess', '', null);
        }
        
    }
    
    /**
Author: Gitika
Company: Techmatrix
Description: Method to update Bulk Hold Cases Approval status on Case
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        05/06/2020                Gitika            Initial Version
**/ 
    
    public void updateApprovalStatusOnCase(){
        try{
            // Map of Case Id with Approval Status
            map<string,string> MapOfCaseIdWithApprovalStatus = new map<string,string>();
            // List of Cases to update 
            list<case> ListcaseToUpdate = new list<case>();
            
            for(Bulk_Hold_Cases__c bulkCase : newBulkHoldCasesList){
                if(OldBulkHoldCasesmap.get(bulkCase.id).Approval_Status__c != bulkCase.Approval_Status__c
                   && (bulkCase.Approval_Status__c == ConstantsUtility.Approved || bulkCase.Approval_Status__c ==ConstantsUtility.Rejected)){
                       MapOfCaseIdWithApprovalStatus.put(bulkCase.id,bulkCase.Approval_Status__c);   
                   }   
            }
            for(case cse :[select id,Status,Bulk_Hold_Status__c,Bulk_Hold_Case__c,Bulk_Hold_Till_Date__c,Bulk_Hold_Start_Date__c,On_Hold_Start_Date__c from case where Bulk_Hold_Case__c in :MapOfCaseIdWithApprovalStatus.keyset()]){
                if(MapOfCaseIdWithApprovalStatus.get(cse.Bulk_Hold_Case__c)==ConstantsUtility.Approved){
                     case cs = new case();
                    cs.id = cse.id;
                    cs.status = ConstantsUtility.CASE_STATUS_ON_HOLD;
                    cs.Bulk_Hold_Status__c = MapOfCaseIdWithApprovalStatus.get(cse.Bulk_Hold_Case__c);
                    if(cse.On_Hold_Start_Date__c==null)
                    cs.On_Hold_Start_Date__c= cse.Bulk_Hold_Start_Date__c !=null ? cse.Bulk_Hold_Start_Date__c:null;
                    cs.On_Hold_End_Date__c= cse.Bulk_Hold_Till_Date__c !=null ? cse.Bulk_Hold_Till_Date__c:null;
                    ListcaseToUpdate.add(cs);   
                }
                else{
                    ListcaseToUpdate.add(new case (id=cse.id,Bulk_Hold_Status__c = MapOfCaseIdWithApprovalStatus.get(cse.Bulk_Hold_Case__c)));   
                }
                
            }
            if(ListcaseToUpdate.size()>0) update ListcaseToUpdate;
        } catch(exception e){
            ExceptionHandler.LogError('BulkHoldCasesTriggerHelper', e.getMessage(), 'updateApprovalStatusOnCase', '', null);
        }
    }
     /**
     Author: Deepak Kumar
     Company: Techmatrix Consulting
     Description: This method will be used to send the Custom notification on approval process to others users then current approvers.
     */
    public void sendChatterNotifications() {
        try {
            Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();

            Map<Id, Set<String>> escalationUsersInit = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMapInit = new Map<Id, String>();

            for (Bulk_Hold_Cases__c bulkHoldCase : newBulkHoldCasesList) {
                Set<String> users = new Set<String>();
                // 1
                if (bulkHoldCase.Current_Approver__c != null && OldBulkHoldCasesmap.get(bulkHoldCase.Id).Current_Approver__c != bulkHoldCase.Current_Approver__c) {
                    // Process Initiation Notification to next approver
                    users.add(bulkHoldCase.Current_Approver__c);
                    escalationUsersInit.put(bulkHoldCase.Id, users);
                    recordIdVsMessageMapInit.put(bulkHoldCase.Id, bulkHoldCase.Initiation_Notification_Message__c);
                }
                // 2
                if (bulkHoldCase.Approved_Rejection_Notifiers__c != null && OldBulkHoldCasesmap.get(bulkHoldCase.Id).Approved_Rejection_Notifiers__c != bulkHoldCase.Approved_Rejection_Notifiers__c) {
                    users.clear();
                    for (String str : bulkHoldCase.Approved_Rejection_Notifiers__c.split(ConstantsUtility.COMMA)) {
                        str = str.trim();
                        if (str != null && str != '') {
                            users.add(str);
                        }
                    }
                    if (users.size() > 0) {
                        recordIdVsMessageMap.put(bulkHoldCase.Id, bulkHoldCase.Approval_Chatter_Message__c);
                        escalationUsers.put(bulkHoldCase.Id, users);
                    }
                }
            }
            if (!recordIdVsMessageMapInit.isEmpty() && !escalationUsersInit.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(escalationUsersInit, recordIdVsMessageMapInit);
            }
            if (!recordIdVsMessageMap.isEmpty() && !escalationUsers.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
            }


        } catch (Exception exp) {
            ExceptionHandler.LogError('BulkHoldCasesTriggerHandler', exp.getMessage(), 'sendChatterNotifications', '', null);
        }

    }
    
}