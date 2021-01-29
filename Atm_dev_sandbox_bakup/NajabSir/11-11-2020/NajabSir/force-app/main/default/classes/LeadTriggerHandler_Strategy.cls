/**
* @Author -: Shaikh Mufiz
* @Company -: Techmatrix Consulting
* @Description -: Handler class for Trigger.
* =============================================================
* Version   Date          Author			Modification
* =============================================================
* 1.0       19/11/2020    Shaikh Mufiz     	Intial Version
**/
public without sharing class LeadTriggerHandler_Strategy extends TriggerHandler{
	private map < string, list < Lead >> leadMap;
    private Map < String, Map < Id, Lead >> leadOldValuesMap;
    private Map < String, Map < Id, Lead >> leadNewValuesMap;
    private Schema.DescribeSObjectResult leadDescribe = Schema.SObjectType.Lead;
    //private static Id aCRM_Id = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('aCRM').getRecordTypeId();

    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public LeadTriggerHandler_Strategy() {

        leadMap = new Map < String, List < Lead >> ();
        leadNewValuesMap = new Map < String, Map < Id, Lead >> ();
        leadOldValuesMap = new Map < String, Map < Id, Lead >> ();
		List<Implementation_Strategy__c> strategiesCS = Implementation_Strategy__c.getAll().values();
        Set<Id> recordsTypeIds = new Set<Id>();
        for(Implementation_Strategy__c OTRecord : strategiesCS){
            if(OTRecord.Use_Case__c == 'LeadTriggers'){
                if(String.isNotBlank(OTRecord.Strategy_Key__c)){
                    Id recordTypeId = leadDescribe.getRecordTypeInfosByDeveloperName().get(OTRecord.Strategy_Key__c).getRecordTypeId();
                    if(String.isNotBlank(recordTypeId)){
                        recordsTypeIds.add(recordTypeId);
                    }
                }
            }
        }
        for (Lead leadObj: (List < Lead > ) Trigger.new) {
            if(recordsTypeIds.contains(leadObj.RecordtypeId)){
                if (!leadMap.containsKey(leadObj.RecordtypeId))
                    leadMap.put(leadObj.RecordtypeId, new List < Lead > ());
                leadMap.get(leadObj.RecordtypeId).add(leadObj);
                
                if (!leadNewValuesMap.containsKey(leadObj.RecordtypeId))
                    leadNewValuesMap.put(leadObj.RecordtypeId, new Map < Id, Lead > ());
                leadNewValuesMap.get(leadObj.RecordtypeId).put(leadObj.Id, leadObj);
            }
        }

        for (Lead leadObj: trigger.isUpdate ? (List < Lead > ) Trigger.old : new List<Lead> ()) {
            if(recordsTypeIds.contains(leadObj.RecordtypeId)){
                if (!leadOldValuesMap.containsKey(leadObj.RecordtypeId))
                    leadOldValuesMap.put(leadObj.RecordtypeId, new Map < Id, Lead > ());
                leadOldValuesMap.get(leadObj.RecordtypeId).put(leadObj.Id, leadObj);
            }
        }
    }
    
    //Methods executions before Insert of Enquiry
    public override void beforeInsert() {
        for (String key: leadMap.keyset()) {
            LeadTriggerContext contextObj = new LeadTriggerContext(key);
            contextObj.beforeInsert(leadMap.get(key));
        }
    }

    //Methods executions before update of Enquiry
    public override void beforeUpdate() {
        for (String key: leadMap.keyset()) {
            LeadTriggerContext contextObj = new LeadTriggerContext(key);
            contextObj.beforeUpdate(leadMap.get(key),leadNewValuesMap.get(key), leadOldValuesMap.get(key));
        }

    }

    //Method executions after insert of Enquiry
    public override void afterInsert() {
        for (String key: leadMap.keyset()) {
            LeadTriggerContext contextObj = new LeadTriggerContext(key);
            contextObj.afterInsert(leadMap.get(key), leadNewValuesMap.get(key), leadOldValuesMap.get(key));
        }
    }

    //Methods executions after update of Enquiry
    public override void afterUpdate() {
        for (String key: leadMap.keyset()) {
            LeadTriggerContext contextObj = new LeadTriggerContext(key);
            contextObj.afterUpdate(leadMap.get(key), leadNewValuesMap.get(key), leadOldValuesMap.get(key));
        }
    }
}