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
public class DealerResolution {
    @AuraEnabled
    public static caseActionWrapper fetchcaseAction(String recordId){
        caseActionWrapper wrapper = new caseActionWrapper();
        try{
            wrapper.caseRecordId = recordId;
            list<case_actions__c> caseacc = [Select id,OwnerId,Case_Number__c from case_actions__c where (Case_Number__c=:recordId OR Id=:recordId )
                                             and recordtypeid = :ConstantsUtility.Case_Closure_CASE_ACTION_RECORD_TYPE_ID order by createddate desc limit 1];
            
            if(caseacc.size()>0){
                wrapper.caseaction=caseacc[0];
                wrapper.caseRecordId = caseacc[0].Case_Number__c;
            }
           
            wrapper.closureRecordTypeId=ConstantsUtility.Case_Closure_CASE_ACTION_RECORD_TYPE_ID;
            wrapper.message='SUCCESS';
            return wrapper;
        }
        catch(Exception e){
            wrapper.message= e.getMessage();
            return wrapper;
        }
    }
    @AuraEnabled
    public static string getCaseActionFields(String sObjectName,String fieldSetName){
        List<fieldWrapper> fieldWrapperList = new List<fieldWrapper>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult describeSObjectResult = objToken.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = describeSObjectResult.fieldSets.getMap();
            //system.debug('>>>>>>> fieldSetMap >>> ' + fieldSetMap);
            if(fieldSetMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember fieldSetMember : fieldSetMap.get(fieldSetName).getFields()) {
                    fieldWrapper  fldWrap = new fieldWrapper();
                    fldWrap.label = fieldSetMember.getLabel();
                    fldWrap.isRequired = (fieldSetMember.getDBRequired() || fieldSetMember.getRequired());
                    fldWrap.name = fieldSetMember.getFieldPath();
                    fieldWrapperList.add(fldWrap);
                }
            
        }catch(Exception exp){
            System.debug('Exception Message : ' +exp.getMessage() +' At Line Number ::'+exp.getLineNumber());
            
        }
        return JSON.serialize(fieldWrapperList);
    }
    public class fieldWrapper{
        public  String name;
        public  String label;
        public  Boolean isRequired = false;
    }
    public class caseActionWrapper{
        @AuraEnabled public Case_Actions__c caseaction = new Case_Actions__c();
        @AuraEnabled public String caseRecordId;
        @AuraEnabled public String closureRecordTypeId;
        @AuraEnabled public String message;
    }
}