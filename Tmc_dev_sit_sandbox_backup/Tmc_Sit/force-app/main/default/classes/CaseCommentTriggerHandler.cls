/** ---------------------------------------------------------
    Author:        Deepak Kumar
    Description:   CaseCommentTrigger Handler
    History
    Date            Author             Comments
    ----------------------------------------------------------
    24/06/2020       Deepak Kumar      Initial Release
    -----------------------------------------------------------
*/

public without sharing class CaseCommentTriggerHandler extends TriggerHandler {
    private List<CaseComment> newCaseComments;
    private Map<Id, CaseComment> oldCaseCommentsMap;

    public CaseCommentTriggerHandler() {
        this.newCaseComments = (List<CaseComment>) Trigger.new;
        this.oldCaseCommentsMap = (Map<Id, CaseComment>) Trigger.oldMap;
    }

    public override void beforeInsert() {
    }
    public override void beforeUpdate() {
    }
    public override void afterInsert() {
        updateVOConCase();
    }
    public override void afterUpdate() {
    }
    /** ---------------------------------------------------------
    Author:        Deepak Kumar
    Description:   Method to copy the related case comment to the case's additional information
    History
    Date            Author             Comments
    ----------------------------------------------------------
    24/06/2020       Deepak Kumar      Initial Release
    -----------------------------------------------------------
    */
    public void updateVOConCase() {
        try {
            Set<Id> caseIds = new Set<Id>();
            for (CaseComment caseComment : newCaseComments) {
                caseIds.add(caseComment.ParentId);
            }
            Set<Id> caseRecordTypesIds = new Set<Id>();
            caseRecordTypesIds.add(ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID);
            caseRecordTypesIds.add(ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID);
            caseRecordTypesIds.add(ConstantsUtility.REPEAT_COMPLAINT_CASE_RECORD_TYPE_ID);
            //Rajesh- added for dealer inbound calls
            caseRecordTypesIds.add(ConstantsUtility.DEALER_COMPLAINT_CASE_RECORD_TYPE_ID);
            caseRecordTypesIds.add(ConstantsUtility.DEALER_FEEDBACK_CASE_RECORD_TYPE_ID);
            caseRecordTypesIds.add(ConstantsUtility.DEALER_QUERY_CASE_RECORD_TYPE_ID);
            caseRecordTypesIds.add(ConstantsUtility.DEALER_REQUEST_CASE_RECORD_TYPE_ID);

            Map<Id, Case> casesToUpdateMap = new Map<Id, Case>([SELECT Additional_Information__c FROM Case WHERE Id IN:caseIds AND RecordTypeId IN:caseRecordTypesIds]);
            if (!casesToUpdateMap.isEmpty() && casesToUpdateMap != null) {
                for (CaseComment caseComment : newCaseComments) {
                    Case caseObj = casesToUpdateMap.get(caseComment.ParentId);
                    caseObj.Additional_Information__c = caseObj.Additional_Information__c == null ? caseComment.CommentBody : caseObj.Additional_Information__c + '\n' + caseComment.CommentBody;
                    casesToUpdateMap.put(caseComment.ParentId, caseObj);
                }

                if (casesToUpdateMap.values().size() > 0) {
                    TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                    update casesToUpdateMap.values();
                    TriggerHandler.clearBypass('CaseTriggerHandler_Strategy');
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseCommentTriggerHandler', exp.getMessage(), 'updateVOConCase', '', null);
            throw new unexpectedException('An exception has occurred. Please contact your salesforce administrator: '+exp.getMessage());
        }
    }
}