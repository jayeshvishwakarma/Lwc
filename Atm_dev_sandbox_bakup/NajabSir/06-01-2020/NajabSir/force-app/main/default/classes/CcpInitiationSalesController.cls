/**
    * Author : Deepak Kumar
    * Company : Techmatrix
    * Description : Apex controller for the CcpInitiationSales lwc component
    * History
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       06 Aug 2020    Deepak          Intial Version
**/
public without sharing class CcpInitiationSalesController {
    /**
      Author: Deepak Kumar
      Company: Techmatrix
      Description: Method to get the on load info foe the CCP initiation and CCP approval initiation flow
      Returns: string
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
     * 1.0          06 Aug 2020              Deepak                     Initial Version
    **/
    @AuraEnabled
    public static CcpOnloadInfo getCcpOnloadInfo(String recordId,String documentType) {
        try {
            CcpOnloadInfo ccpOnloadInfo = new CcpOnloadInfo();
            ccpOnloadInfo.contentVersions = getContentVersions(recordId,documentType);
            ccpOnloadInfo.caseObj = getCaseInfo(recordId);
            List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
            caseActions = getCaseActionInfo(recordId);
            ccpOnloadInfo.isCaseActionApprovedOrInProgress = false;
            if(caseActions.size() > 0){
                if(caseActions[0].Approval_Status__c !=null && caseActions[0].Approval_Status__c == ConstantsUtility.In_Progress || caseActions[0].Approval_Status__c == ConstantsUtility.Approved){
                    ccpOnloadInfo.isCaseActionApprovedOrInProgress = true;
                }
            }
            ccpOnloadInfo.currentUserIsL3L4OrSystemAdmin = checkUser(ccpOnloadInfo.caseObj);
            return ccpOnloadInfo;
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + 'AT ::' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getMessage());
        }
    }
    public class CcpOnloadInfo {
        @AuraEnabled public Case caseObj;
        @AuraEnabled public Boolean isCaseActionApprovedOrInProgress;
        @AuraEnabled public Case_Actions__c caseActionObj;
        @AuraEnabled public List<ContentVersion> contentVersions;
        @AuraEnabled public Boolean currentUserIsL3L4OrSystemAdmin;
    }
    /**
           Author: Deepak Kumar
           Company: Techmatrix
           Description: Method to get the related CCP Uploaded files from the case.
           Returns: string
           History:
           * Ver         Date                     Author                    Modification
           *==============================================================================
           * 1.0        06 Aug 2020              Deepak                     Initial Version
        **/
    private static List<ContentVersion> getContentVersions(String recordId,String documentType) {
        try {
            Set<Id> ids = new Set<Id>();
            for (ContentDocumentLink contentDocumentLink : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId = :recordId]) {
                ids.add(contentDocumentLink.ContentDocumentId);
            }
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            documentType = '%' + documentType ;
            contentVersions = [SELECT Id,ContentDocumentId,FileUniqueName__c,ContentUrl,title FROM ContentVersion Where ContentDocumentId IN :ids AND FileUniqueName__c LIKE :documentType];
            return contentVersions;
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + 'AT ::' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getMessage());
        }
    }
    /**
          Author: Deepak Kumar
          Company: Techmatrix
          Description: Method to get case info using record Id
          Returns: Case Object
          History:
          * Ver         Date                     Author                    Modification
          *==============================================================================
          * 1.0        06 Aug 2020              Deepak                     Initial Version
       **/
    private static Case getCaseInfo(String recordId) {
        return [SELECT Id,CCP_Status__c,L3_Stakeholder__c,L4_Stakeholder__c,CCP_Mode__c,Trigger_CCP_Not_Responded_Flow__c,CaseNumber FROM Case WHERE Id = :recordId LIMIT 1];
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: Method to check the current user is L3,L4 or System admin
       Returns: string
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0        06 Aug 2020              Deepak                     Initial Version
    **/
    private static Boolean checkUser(Case caseObj) {
        if ((caseObj.L3_Stakeholder__c !=null && Id.valueOf(caseObj.L3_Stakeholder__c) == UserInfo.getUserId())
                || (caseObj.L3_Stakeholder__c !=null &&  Id.valueOf(caseObj.L4_Stakeholder__c) == UserInfo.getUserId())) {
            return true;
        } else if ([select Name from profile where id = :UserInfo.getProfileId()].Name == 'System Administrator') {
            return true;
        }
        return false;
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: Method to to update name of the File uploded in the custom field of content version
       Returns: string
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0        06 Aug 2020              Deepak                     Initial Version
    **/
    @AuraEnabled
    public static List<ContentVersion> updateFileUniqueName(String contentVersionId, String caseNumber, String recordId, String documentType) {
        try {
            ContentVersion contentVersion = [SELECT Id,ContentDocumentId,FileUniqueName__c,ContentUrl,title FROM ContentVersion Where ContentDocumentId = :contentVersionId];
            contentVersion.FileUniqueName__c = caseNumber + '-' + documentType;
            update contentVersion;
            return getContentVersions(recordId,documentType);
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + 'AT ::' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getMessage());
        }
    }
    /**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: Method to update the Case Record and Create the case action to initiate the approval for CCP Not Responded flow
    Returns: string
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
   * 1.0          06 Aug 2020              Deepak                     Initial Version
  **/
    @AuraEnabled
    public static String updateCaseWithCCP(Case caseObj, Boolean isCreateCaseAction) {
        try {
            TriggerHandler.bypass('CaseActionsTriggerHandler');
            update caseObj;
            TriggerHandler.clearBypass('CaseActionsTriggerHandler');
            if (isCreateCaseAction) {
                List<Case_Actions__c> caseActionsList = getCaseActionInfo(caseObj.Id);
                Case_Actions__c caseActions =  new Case_Actions__c();
                if(caseActionsList.size() > 0){
                    caseActions = caseActionsList[0];
                }
                if(caseActions !=null && (caseActions.Approval_Status__c == ConstantsUtility.In_Progress || caseActions.Approval_Status__c == ConstantsUtility.Approved)){
                    return 'A CCP Not Responded approval has already been initiated and is In Progress or Approved';
                }else if(caseActions !=null  && caseActions.Approval_Status__c == ConstantsUtility.Rejected){
                    set<Id> recordIds = new Set<Id>();
                    recordIds.add(caseActions.Id);
                    ApprovalRequestService.initiateApprovalRequests(recordIds,null);
                    return caseActions.Id;
                }else if(caseActions == null || caseActions.Approval_Status__c == null){
                    caseActions = new Case_Actions__c();
                    caseActions.Name = 'CCP Not Responded Flow';
                    caseActions.RecordTypeId = ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID;
                    caseActions.Case_Number__c = caseObj.Id;
                    insert caseActions;
                    return caseActions.Id;
                }
            }
            return caseObj.Id;
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + 'AT ::' + exp.getStackTraceString());
            throw new AuraHandledException(exp.getMessage());
        }
    }
    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: Method to get the CCP Case Action Related to Case
        Returns: string
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        06 Aug 2020              Deepak                     Initial Version
     **/
    private static  List<Case_Actions__c> getCaseActionInfo(String recordId) {
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
        caseActions = [SELECT Id,Approval_Status__c FROM Case_Actions__c WHERE Case_Number__c = :recordId  AND RecordTypeId =:ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID LIMIT 1];
        if (caseActions.size() > 0) {
            return caseActions;
        }
        return caseActions;
    }
}