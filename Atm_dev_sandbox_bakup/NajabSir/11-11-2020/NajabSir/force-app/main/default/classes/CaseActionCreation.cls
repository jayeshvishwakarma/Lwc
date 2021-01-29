/**
Author: Gitika
Company: Techmatrix
Description: Class Used for Case Closure record Creation/Editing functionality. 
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        19/06/2020                Gitika            Initial Version
**/
public without sharing class CaseActionCreation {
/**
Author: Sunit Kumar Chand
Company: Techmatrix
Description: 
Returns:Boolean
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.2       12/11/2020                Sunit                     Initial Version
**/
    @AuraEnabled
    public static boolean suzukiConnectQueueMemberCheck(String channel) {
        boolean memberofQueue = false;
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Constant_Value__c cv = ProjectUtility.getConstantValue('Suzuki Connect');
        if (channel == ConstantsUtility.NEXA_CASE_CHANNEL) {
            groupMemberList = [Select UserOrGroupId From GroupMember where GroupId = :cv.Nexa_Suzuki_Connect_Queue_Id__c];
        } else if (channel == ConstantsUtility.ARENA_CASE_CHANNEL) {
            groupMemberList = [Select UserOrGroupId From GroupMember where GroupId = :cv.Arena_Suzuki_Connect_Queue_Id__c];
        }
        if (groupMemberList.size() > 0) {
            for (GroupMember gm : groupMemberList) {
                if (gm.UserOrGroupId == System.UserInfo.getUserId()) {
                    memberofQueue = true;
                    break;
                }
            }
        }
        return memberofQueue;
    }
/**
Author: Gitika
Company: Techmatrix
Description: Method to update case as Resolved
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string updateCaseStatusResolved(String recordId) {
        Try {
            List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
            caseActions = [Select Case_Number__c from Case_Actions__c where Id = :recordId LIMIT 1];
            if (!caseActions.isEmpty()) {
                recordId = caseActions[0].Case_Number__c;
            }
            list<case> caseobj = [Select Id,Status from Case where id = :recordId];
            if (!ConstantsUtility.EXCLUDED_STATUS.contains(caseobj[0].Status)) {
                caseobj[0].Status = ConstantsUtility.Resolved;
                caseobj[0].Resolved_date__c = system.today();
                update caseobj[0];
            }
            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /**
Author: Gitika
Company: Techmatrix
Description: Method to call approval process on Case Action on Edit call 
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string callApprovalFlow(String recordId, String processName) {
        // set to store case ids
        set<id> recordIds = new set<id>();
        //Map for record type and Approval Process names from custom metadata type
        Map<String, String> approvalMatrixMap = new map<String, String>();

        TRY {
            for (Case_Action_Approval_Matrix__mdt approvalMatrixObj : [SELECT Id,DeveloperName,Approval_Process_API_Name__c FROM Case_Action_Approval_Matrix__mdt]) {
                approvalMatrixMap.put(approvalMatrixObj.DeveloperName, approvalMatrixObj.Approval_Process_API_Name__c);
            }
            system.debug('processName' + processName);
            if (approvalMatrixMap.containskey(processName)) {
                recordIds.add(recordId);
                String approvalProcessName = approvalMatrixMap.get(processName);
                // initiate the approval process
                ApprovalRequestService.initiateApprovalRequests(recordIds, approvalProcessName);
                return 'SUCCESS';
            }
            // Insert feed
            //  CaseActionCreation.insertFeedItem(caseac[0].case_number__c,comment,ConstantsUtility.TEXT_POST,null);
            return 'Some error Occured.Please try later';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /**
Author: Gitika
Company: Techmatrix
Description: Method to update Field MSIL QUERY RESPONSE ON Case for case Type MSIL Query
Returns: string
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string updateMsilQueryResponse(String recordId, String msilQueryResponse, String Comment) {
        Try {
            list<case> caseobj = [Select Id,Status,MSIL_Remarks__c,Business_area__c,case_Type__c,Channel__c,MSIL_Query_Response__c from Case where id = :recordId];
            if (msilQueryResponse != null) {
                if (msilQueryResponse == ConstantsUtility.SEND_BACK_TO_QUERY_MANAGEMENT_TEAM) {
                    //if(msilQueryResponse != caseobj[0].MSIL_Query_Response__c){
                    caseobj[0].MSIL_Query_Response__c = msilQueryResponse;
                    // Assignment to queue basis business type , case type and channel
                    caseobj[0].OwnerId = caseTriggerHelper.getQueueName(caseobj[0].Channel__c, caseobj[0].Business_area__c, caseobj[0].case_Type__c, false);
                    // }
                    if (Comment != null) {
                        caseobj[0].MSIL_Remarks__c = Comment;
                        // insert feed 
                        CaseActionCreation.insertFeedItem(caseobj[0].id, comment, ConstantsUtility.TEXT_POST, null);
                    }
                } else if (msilQueryResponse == ConstantsUtility.RESPONDED_VIA_SF) {
                    if (msilQueryResponse != caseobj[0].MSIL_Query_Response__c) {
                        // update case as Closed
                        caseobj[0].Status = ConstantsUtility.CASE_CLOSED;
                        caseobj[0].MSIL_Query_Response__c = msilQueryResponse;
                    }
                } else if (msilQueryResponse == ConstantsUtility.RESPONDED_VIA_OUTLOOK) {
                    // update case as closed
                    caseobj[0].Status = ConstantsUtility.CASE_CLOSED;
                    caseobj[0].MSIL_Query_Response__c = msilQueryResponse;
                } else {
                    if (msilQueryResponse != caseobj[0].MSIL_Query_Response__c) {
                        caseobj[0].MSIL_Query_Response__c = msilQueryResponse;
                        if (String.isNotBlank(Comment)) {
                            // insert feed  
                            CaseActionCreation.insertFeedItem(caseobj[0].id, comment, ConstantsUtility.TEXT_POST, null);
                        }
                    }
                }
                update caseobj[0];
            }
            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /**
Author: Gitika
Company: Techmatrix
Description: Method called on load of dealer Resolution
Returns: caseActionWrapper
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static caseActionWrapper fetchcaseAction(Id recordId, String ProcessName) {
        caseActionWrapper wrapper = new caseActionWrapper();
        // map to store case ids with stakholdermapping
        map<id, map<string, string>> mapofCaseIdWithStakeHoldersmap = new map<id, map<string, string>>();
        map<string, string> mapofStakeHolderWithId = new map<string, string>();
        try {
            Map<string, FileUtility__c> FileUtilityName = FileUtility__c.getAll();
            String objectname = String.valueof(recordId.getsobjecttype());
            if (objectname == 'Case_Actions__c') {
                wrapper.openInEditMode = true;
            }
            if (FileUtilityName.containskey(ProcessName)) {
                wrapper.FileDetail = FileUtilityName.get(ProcessName);
                wrapper.FieldList = CaseActionCreation.getCaseActionFields('Case_Actions__c', FileUtilityName.get(ProcessName).Field_Set_API_Name__c);

                wrapper.RecordTypeId = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get(FileUtilityName.get(ProcessName).Name).getRecordTypeId();
                wrapper.caseRecordId = recordId;
                list<case_actions__c> caseacc = [
                        Select id,OwnerId,Case_Number__c,Approval_Status__c,current_approver__c
                        from case_actions__c
                        where (Case_Number__c = :recordId OR Id = :recordId )
                        and recordtypeid = :wrapper.RecordTypeId
                        order by createddate desc
                        limit 1
                ];

                if (caseacc.size() > 0) {
                    wrapper.caseaction = caseacc[0];
                    wrapper.caseRecordId = caseacc[0].Case_Number__c;
                }
                list<case> caseobj = [select id,Stakeholders_JSON__c,Selected_Hierarchy_Type__c,OTP_Entered__c,Status,OwnerId,Closure_Mode__c,OTP_Generated_Time__c,No_of_Outbound_Emails__c,MSIL_Remarks__c,MSIL_Query_Response__c from case where id = :wrapper.caseRecordId];
                if (caseobj.size() > 0) {
                    wrapper.caseObj = caseobj[0];
                    if (FileUtilityName.get(ProcessName).Field_Name_Of_Stakeholder__c != null) {
                        wrapper.stakeHolderids = '';
                        mapofCaseIdWithStakeHoldersmap = CaseActionTriggerHelper.mapOfcaseIdWithMapOfStakeHolders(caseobj, ConstantsUtility.mapOfStakeholderJSONWithCaseActionFields);
                        mapofStakeHolderWithId = mapofCaseIdWithStakeHoldersmap.get(caseobj[0].id);
                        if (mapofStakeHolderWithId != null) {
                            for (string str : FileUtilityName.get(ProcessName).Field_Name_Of_Stakeholder__c.split(';')) {
                                if (mapofStakeHolderWithId.containskey(str) && mapofStakeHolderWithId.get(str) != null)
                                    wrapper.stakeHolderids = wrapper.stakeHolderids + ';' + mapofStakeHolderWithId.get(str);
                            }
                        }
                    }
                }
                wrapper.message = 'SUCCESS';
                return wrapper;
            }
            wrapper.message = 'File Utility does not found';
            return wrapper;
        } catch (Exception e) {
            wrapper.message = e.getMessage();
            return wrapper;
        }
    }

    /**
Author: Gitika
Company: Techmatrix
Description: Method to fetch fieldset w.r.t object
Returns: string
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    public static string getCaseActionFields(String sObjectName, String fieldSetName) {
        List<fieldWrapper> fieldWrapperList = new List<fieldWrapper>();
        string Fieldlist = null;
        try {
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult describeSObjectResult = objToken.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = describeSObjectResult.fieldSets.getMap();
            //system.debug('>>>>>>> fieldSetMap >>> ' + fieldSetMap);
            if (fieldSetMap.containsKey(fieldSetName))
                for (Schema.FieldSetMember fieldSetMember : fieldSetMap.get(fieldSetName).getFields()) {
                    fieldWrapper fldWrap = new fieldWrapper();
                    fldWrap.label = fieldSetMember.getLabel();
                    if (fldWrap.label == 'Message' || fldWrap.label == 'Tentative Delivery Date') {
                        fldWrap.isDisabled = true;
                    }
                    fldWrap.isRequired = (fieldSetMember.getDBRequired() || fieldSetMember.getRequired());
                    fldWrap.name = fieldSetMember.getFieldPath();
                    fieldWrapperList.add(fldWrap);
                }
            Fieldlist = JSON.serialize(fieldWrapperList);
            return Fieldlist;
        } catch (Exception exp) {
            System.debug('Exception Message : ' + exp.getMessage() + ' At Line Number ::' + exp.getLineNumber());
            return Fieldlist;
        }

    }
    /**
Author: Gitika
Company: Techmatrix
Description: Generic method to insert feed
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static void insertFeedItem(String recordId, String body, String Type, String contentVersionId) {
        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        if (String.isNotBlank(body)) {
            post.Body = body;
        }
        if (String.isNotBlank(contentVersionId)) {
            post.RelatedRecordId = contentVersionId;
        }
        post.Type = Type;
        post.Visibility = 'AllUsers';
        insert post;
    }
/**
Author: Sunit Kumar Chand
Company: Techmatrix
Description: Generic method to return feeditem object
Returns: FeedItem
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.2       18/11/2020             Sunit Kumar Chand          Initial Version
**/
    @AuraEnabled
    public static FeedItem getFeedItem(String recordId, String body, String Type, String contentVersionId) {
        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        if (String.isNotBlank(body)) {
            post.Body = body;
        }
        if (String.isNotBlank(contentVersionId)) {
            post.RelatedRecordId = contentVersionId;
        }
        post.Type = Type;
        post.Visibility = 'AllUsers';
        return post;
    }
    /**
Author: Gitika
Company: Techmatrix
Description: to get SPOC Queue id
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static list<Group> getQueueId() {
        list<Group> grpList = [SELECT Id,DeveloperName FROM Group where Type = :ConstantsUtility.QUEUE];
        if (grpList.size() > 0) {
            return grpList;
        }
        return null;
    }
    public class fieldWrapper {
        public String name;
        public String label;
        public Boolean isRequired = false;
        public Boolean isDisabled = false;
    }
    public class caseActionWrapper {
        @AuraEnabled public Case_Actions__c caseAction = new Case_Actions__c();
        @AuraEnabled public Case caseObj = new Case();
        @AuraEnabled public String caseRecordId;
        @AuraEnabled public String RecordTypeId;
        @AuraEnabled public FileUtility__c FileDetail = new FileUtility__c();
        @AuraEnabled public String FieldList;
        @AuraEnabled public String message = '';
        @AuraEnabled public boolean openInEditMode = false;
        @AuraEnabled public String stakeHolderids;
    }
}