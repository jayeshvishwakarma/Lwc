/**
* @File Name          : LeadTVTriggerServiceImpl
* @Description        : Strategy, Implementation class for Inbound True Value Prospect Record Type.
* @Author             : Shaikh Mufiz
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    08/12/2020, 1:05:15 PM     Shaikh Mufiz            Initial Version

**/
public without sharing class LeadTVTriggerServiceImpl implements LeadTriggerService{
    
    LeadTriggerStrategyHelper leadHelperInstance;
    public void beforeInsert(List<Lead> leadlist){}
    public void beforeUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){}
    public void afterInsert(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){}
    
    public void afterUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        leadHelperInstance = LeadTriggerStrategyHelper.getInstance(leadlist, newLeadMap, oldLeadMap);
        leadHelperInstance.updateEnquiryNumber();
    }
}