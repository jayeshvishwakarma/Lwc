/**
* @File Name          : OpportunityTriggerContext.cls
* @Description        : Context class to choose a strategy on the basis of Record Type.
* @Author             : Nitish Bansal
* @Group              :
* @Last Modified By   : Nitish/Anuj
* @Last Modified On   : 11/06/2020, 1:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    11/06/2020, 1:14:54 PM     Nitish Bansal            Initial Version

**/
public Class OpportunityTriggerContext{
    public class NameException extends Exception{}

    public static final Map<String,OpportunityTriggerService> strategies;
    static{
        List<Implementation_Strategy__c> strategiesCS = Implementation_Strategy__c.getAll().values();
        
        // Populate a map of strategy names to concrete implementations
        // using Type.forName for each strategy string
        strategies = new Map<String,OpportunityTriggerService>();
        for(Implementation_Strategy__c OTRecord : strategiesCS){
            if(OTRecord.Use_Case__c=='OpportunityTriggers'){
                try{
                    strategies.put(OTRecord.Strategy_Key__c, (OpportunityTriggerService)Type.forName(OTRecord.Strategy_Implementation__c).newInstance());
                }catch(Exception e){continue;} //skip bad name silently
            }
        }
    }
    private OpportunityTriggerService strategy;

    public OpportunityTriggerContext(String name){
        String strRecordDevName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(name).getDeveloperName();
        
        if(!strategies.containsKey(strRecordDevName)) throw new NameException(strRecordDevName);
        strategy = strategies.get(strRecordDevName);
    }

    public void beforeInsert(List<opportunity> oppList){
        strategy.beforeInsert(oppList);
    }
    
    public void beforeUpdate(List<opportunity> oppList, Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){
        strategy.beforeUpdate(oppList,newOppMap, oldOppMap);
    }
    
    public void afterInsert(List<opportunity> oppList,Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){
        strategy.afterInsert(oppList, newOppMap, oldOppMap);
    }
    
    public void afterUpdate(List<opportunity> oppList,Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){
        strategy.afterUpdate(oppList, newOppMap, oldOppMap);
    }
 }