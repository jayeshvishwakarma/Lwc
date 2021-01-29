/**
* @File Name          : LeadTrigger.cls
* @Description        : Lead Trigger
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
trigger LeadTrigger on Lead (after insert, before update, after update) {
    
    //Added By Shaik Mufiz on 23.10.2020
    /*******     START HERE     *******/
    if(Trigger.isAfter && Trigger.isUpdate){
        
        List<Lead> accessoriesSales = new List<Lead>();
        List<Lead> vehicleSales = new List<Lead>();
        for(Lead myLead: Trigger.new){
            if(!myLead.isConverted && myLead.Is_Completed__c){
                if(myLead.Interested_in_New_Car__c == 'Yes'){
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
    /*******     END HERE     *******/
    else{
        new LeadTriggerHandler().run();
    }
}