/**
* @File Name          : LeadTriggerHandler.cls
* @Description        : Lead Trigger Handler Class
* @Author             : Mahith Madwesh
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         17/01/2020               Mahith Madwesh         Initial Version
*/
public with sharing class LeadTriggerHandler extends TriggerHandler{

    List<Lead> newLeadList;
    Map<Id, Lead> newLeadMap;
    Map<Id, Lead> oldLeadMap;

    public LeadTriggerHandler() {
        this.newLeadList = (List<Lead>) Trigger.new;
        this.newLeadMap = (Map<Id, Lead>) Trigger.newMap;
        this.oldLeadMap = (Map<Id, Lead>) Trigger.oldMap;
    }

    //methods executions before update of Lead 
    public override void beforeUpdate() {
        LeadConversionService.convertLead(newLeadList, oldLeadMap);
    }
    //methods executions after update of Lead 
    public override void afterUpdate() {
        List<Lead> accessoriesSales = new List<Lead>();
        List<Lead> vehicleSales = new List<Lead>();
        for(Lead myLead: newLeadList){
            if(!myLead.isConverted && myLead.Is_Completed__c ){
                if(myLead.Interested_in_New_Car__c == 'Yes' && myLead.Lead_Score__c == 'Hot'){
                    vehicleSales.add(myLead);
                }else if(myLead.Interested_in_TV__c == 'No' && myLead.Upsell_Cross_Sell_Tele_Caller__c.contains('MSGA')){
                    accessoriesSales.add(myLead);
                }
            }
        }
        if(accessoriesSales.size() > 0)
            LeadHandler.autoLeadConvert(accessoriesSales, ConstantsUtility.ACCESSORIES_SALES_CONST);
        if(vehicleSales.size() > 0){
            System.debug('list : '+vehicleSales);
            LeadHandler.autoLeadConvert(vehicleSales, ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE);
        }
    }
}