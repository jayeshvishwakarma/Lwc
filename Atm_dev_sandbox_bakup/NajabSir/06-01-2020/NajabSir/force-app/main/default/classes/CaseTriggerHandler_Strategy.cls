/**
* @File Name          : CaseTriggerHandler_Strategy.cls
* @Description        : Trigger handler class for Case 
* @Author             : Anas
* @Group              :
* @Last Modified By   : Anas
* @Last Modified On   : 24/08/2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    24/08/2020                  Anas Yar Khan            Initial Version

**/

public without sharing class CaseTriggerHandler_Strategy extends TriggerHandler {


    private map < string, list < case >> channelCaseMap;
    private Map < String, Map < Id,case >> channelCaseOldValuesMap;
    private Map < String, Map < Id, case >> channelCaseNewValuesMap;

   // public static Id RenewalRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
   // public static Id vehicleserviceRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
   // public static Id dncRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
    public static Id mosComplaint = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MOS_Complaints').getRecordTypeId();

    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public CaseTriggerHandler_Strategy() {

        channelCaseMap = new Map < String, List < Case >> ();
        channelCaseNewValuesMap = new Map < String, Map < Id, Case >> ();
        channelCaseOldValuesMap = new Map < String, Map < Id, Case >> ();

        for (Case cs: (List < Case > ) Trigger.new) {
            if (!channelCaseMap.containsKey(cs.RecordtypeId))
                channelCaseMap.put(cs.RecordtypeId, new List < case > ());
            channelCaseMap.get(cs.RecordtypeId).add(cs);

            if (!channelCaseNewValuesMap.containsKey(cs.RecordtypeId))
                channelCaseNewValuesMap.put(cs.RecordtypeId, new Map < Id, Case > ());
            channelCaseNewValuesMap.get(cs.RecordtypeId).put(cs.Id, cs);

        }

        for (Case cs: trigger.isUpdate ? (List < Case > ) Trigger.old : new List<Case> ()) {
            if (!channelCaseOldValuesMap.containsKey(cs.RecordtypeId))
                channelCaseOldValuesMap.put(cs.RecordtypeId, new Map < Id, Case > ());
            channelCaseOldValuesMap.get(cs.RecordtypeId).put(cs.Id, cs);

        }

    }

    //Methods executions before Insert of Enquiry
    public override void beforeInsert() {
        for (String key: channelCaseMap.keyset()) {
            CaseTriggerContext caseBI = new CaseTriggerContext(key);
            caseBI.beforeInsert(channelCaseMap.get(key));
        }
    }


    //Methods executions before update of Enquiry
    public override void beforeUpdate() {
        for (String key: channelCaseMap.keyset()) {
            CaseTriggerContext caseBI = new CaseTriggerContext(key);
            caseBI.beforeUpdate(channelCaseMap.get(key),channelCaseNewValuesMap.get(key), channelCaseOldValuesMap.get(key));
        }

    }


    //Method executions after insert of Enquiry
    public override void afterInsert() {
        for (String key: channelCaseMap.keyset()) {
            CaseTriggerContext caseBI = new CaseTriggerContext(key);
            caseBI.afterInsert(channelCaseMap.get(key), channelCaseNewValuesMap.get(key), channelCaseOldValuesMap.get(key));
        }
    }


    //Methods executions after update of Enquiry
    public override void afterUpdate() {
        for (String key: channelCaseMap.keyset()) {
            CaseTriggerContext caseBI = new CaseTriggerContext(key);
            caseBI.afterUpdate(channelCaseMap.get(key), channelCaseNewValuesMap.get(key), channelCaseOldValuesMap.get(key));
        }

    }

}