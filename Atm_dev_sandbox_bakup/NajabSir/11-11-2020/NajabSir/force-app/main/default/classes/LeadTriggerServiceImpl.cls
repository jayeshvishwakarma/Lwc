/**
* @File Name          : LeadTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for aCRM Record Type.
* @Author             : Shaikh Mufiz
* @Group              :
* @Last Modified By   : Shaikh Mufiz
* @Last Modified On   : 19/11/2020, 3:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    19/11/2020, 3:14:54 PM     Shaikh Mufiz            Initial Version

**/
public without sharing class LeadTriggerServiceImpl implements LeadTriggerService{
    LeadTriggerStrategyHelper leadHelperInstance;
    public void beforeInsert(List<Lead> leadlist){
        leadHelperInstance = LeadTriggerStrategyHelper.getInstance(leadlist, null, null);
        
        leadHelperInstance.updateColorOnLeads(true);
        leadHelperInstance.updateDefaultValues(); 
    }
    public void beforeUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        leadHelperInstance = LeadTriggerStrategyHelper.getInstance(leadlist, newLeadMap, oldLeadMap);
        leadHelperInstance.updateLeadStatus(); 
        leadHelperInstance.updateColorOnLeads(false);  
        
    }
    public void afterInsert(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        
    }
    public void afterUpdate(List<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        //leadHelperInstance = LeadTriggerStrategyHelper.getInstance(leadlist, newLeadMap, oldLeadMap);
        //List<Lead> vehicleAndAccessories = new List<Lead>();
        /*Set<Id> leadIds = new Set<Id>();
        for(Lead myLead: leadlist){
            Lead oldLead = oldLeadMap.get(myLead.Id);
            if(!myLead.isConverted && oldLead.Enq_Mode__c != myLead.Enq_Mode__c && myLead.Enq_Mode__c == 'MKTC'){
                //For New vehicle
                if(myLead.Interested_in_New_Car__c == 'Yes'){
                    //vehicleAndAccessories.add(myLead);
                    leadIds.add(myLead.Id);
                }
                //For accessories of maruti car
                else if(myLead.Interested_in_TV__c == 'No' && myLead.Upsell_Cross_Sell_Tele_Caller__c.contains('MSGA')){
                    //vehicleAndAccessories.add(myLead);
                    leadIds.add(myLead.Id);
                }
            }
        }*/
        /*if(vehicleAndAccessories.size() > 0){
            leadHelperInstance.autoLeadConvert(vehicleAndAccessories);
        }*/   
        /*if(leadIds.size() > 0){
            leadHelperInstance.convertLeadUsingSchedular(leadIds);
        }*/
    }
}