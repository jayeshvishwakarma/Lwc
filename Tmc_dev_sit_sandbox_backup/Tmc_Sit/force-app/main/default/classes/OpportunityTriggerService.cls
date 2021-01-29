public interface OpportunityTriggerService {
    void beforeInsert(List<Opportunity> opplist);
    void beforeUpdate(List<Opportunity> oppList,Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldoppMap);
    void afterInsert(list<Opportunity> oppList, Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldoppMap);
    void afterUpdate(list<Opportunity> oppList, Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldoppMap);
}