/**
* @File Name          : LeadPathTriggerServiceImpl
* @Description        : Strategy, Implementation class for aCRM Record Type.
* @Author             : Shaikh Mufiz
* @Last Modified By   : 
* @Last Modified On   : 19/11/2020, 3:14:54 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date       Author                 Modification
*==============================================================================
* 1.0    19/11/2020     Shaikh Mufiz            Initial Version

**/
public without sharing class LeadPathTriggerServiceImpl implements LeadTriggerService{
    LeadTriggerStrategyHelper leadHelperInstance;
    public void beforeInsert(List<Lead> leadlist){}
    
    public void beforeUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        leadHelperInstance = LeadTriggerStrategyHelper.getInstance(leadlist, newLeadMap, oldLeadMap);
		leadHelperInstance.convertLead(); 
    }
    
    public void afterInsert(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){}
    
    public void afterUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){}
}