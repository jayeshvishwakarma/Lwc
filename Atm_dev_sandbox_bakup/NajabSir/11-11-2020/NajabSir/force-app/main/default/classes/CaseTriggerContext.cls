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
public Class CaseTriggerContext{
    public class NameException extends Exception{}

    public static final Map<String,CaseTriggerService> strategies;
    static{
        List<Implementation_Strategy__c> strategiesCS = Implementation_Strategy__c.getAll().values();
        // Populate a map of strategy names to concrete implementations
        // using Type.forName for each strategy string
        strategies = new Map<String,CaseTriggerService>();
        System.debug('strategies-->'+strategies);
        for(Implementation_Strategy__c OTRecord : strategiesCS){
            if(OTRecord.Use_Case__c=='CaseTriggers'){
                try{
                    strategies.put(OTRecord.Strategy_Key__c, (CaseTriggerService)Type.forName(OTRecord.Strategy_Implementation__c).newInstance());
                }catch(Exception e){continue;} //skip bad name silently
            }
        }
    }
    private CaseTriggerService strategy;

    public CaseTriggerContext(String name){
        String strRecordDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(name).getDeveloperName();
        if(!strategies.containsKey(strRecordDevName)) throw new NameException(strRecordDevName);
        strategy = strategies.get(strRecordDevName);
    }

    public void beforeInsert(List<Case> caseList){
        strategy.beforeInsert(caseList);
    }
    
    public void beforeUpdate(List<Case> caseList, Map<Id, Case> newOppMap, Map<Id, Case> oldOppMap){
        strategy.beforeUpdate(caseList,newOppMap, oldOppMap);
    }
    
    public void afterInsert(List<Case> caseList,Map<Id, Case> newOppMap, Map<Id, Case> oldOppMap){
        strategy.afterInsert(caseList, newOppMap, oldOppMap);
    }
    
    public void afterUpdate(List<Case> caseList,Map<Id, Case> newOppMap, Map<Id, Case> oldOppMap){
        strategy.afterUpdate(caseList, newOppMap, oldOppMap);
    }
 }