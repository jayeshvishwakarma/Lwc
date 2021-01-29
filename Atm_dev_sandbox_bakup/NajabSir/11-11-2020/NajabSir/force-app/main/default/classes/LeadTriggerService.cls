public interface LeadTriggerService {
	void beforeInsert(List<Lead> leadlist);
    void beforeUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap);
    void afterInsert(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap);
    void afterUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap);
}