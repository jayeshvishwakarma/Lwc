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
}