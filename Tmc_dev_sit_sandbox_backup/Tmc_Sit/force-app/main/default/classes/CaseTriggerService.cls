public interface CaseTriggerService {
	void beforeInsert(List<Case> caseList);
    void beforeUpdate(List<Case> caseList, Map<Id, Case> newOppMap, Map<Id, Case> oldoppMap);
    void afterInsert(list<Case> caseList, Map<Id, Case> newOppMap, Map<Id, Case> oldoppMap);
    void afterUpdate(list<Case> caseList, Map<Id, Case> newOppMap, Map<Id, Case> oldoppMap);
}