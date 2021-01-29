/**
* @File Name          : LeadTriggerContext.cls
* @Description        : Context class to choose a strategy on the basis of Record Type.
* @Author             : Shaikh Mufiz
* @Last Modified By   : Shaikh Mufiz
* @Last Modified On   : 19/11/2020, 12:42:54 AM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    19/11/2020, 12:42:54 AM     Shaikh Mufiz            Initial Version

**/
public class LeadTriggerContext {
    public class NameException extends Exception{}
    
    public static final Map<String,LeadTriggerService> strategies;
    static{
        List<Implementation_Strategy__c> strategiesCS = Implementation_Strategy__c.getAll().values();
        
        // Populate a map of strategy names to concrete implementations
        // using Type.forName for each strategy string
        strategies = new Map<String,LeadTriggerService>();
        for(Implementation_Strategy__c OTRecord : strategiesCS){
            if(OTRecord.Use_Case__c == 'LeadTriggers'){
                try{
                    strategies.put(OTRecord.Strategy_Key__c, (LeadTriggerService)Type.forName(OTRecord.Strategy_Implementation__c).newInstance());
                }catch(Exception e){continue;} //skip bad name silently
            }
        }
    }
    private LeadTriggerService strategy;
    
    public LeadTriggerContext(String name){
        String strRecordDevName = Schema.SObjectType.Lead.getRecordTypeInfosById().get(name).getDeveloperName();
        
        if(!strategies.containsKey(strRecordDevName)) throw new NameException(strRecordDevName);
        strategy = strategies.get(strRecordDevName);
    }
    
    public void beforeInsert(List<Lead> leadList){
        strategy.beforeInsert(leadList);
    }
    
    public void beforeUpdate(List<Lead> leadList, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        strategy.beforeUpdate(leadList,newLeadMap, oldLeadMap);
    }
    
    public void afterInsert(List<Lead> leadList,Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        strategy.afterInsert(leadList, newLeadMap, oldLeadMap);
    }
    
    public void afterUpdate(List<Lead> leadList,Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        strategy.afterUpdate(leadList, newLeadMap, oldLeadMap);
    }
}