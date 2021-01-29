/**
    * @Autho:- Nishant Prajapati
    * @Company-: Techmatrix Consulting
    * @Description-: Contains method for update Enquiry Update Flag on opportunity when opportunity line item is created.
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       22 July 2019    Nishant     Intial Version
    * 1.1       31 July 2019    Nishant     W-000290, Requirement change
    **/
    
    //CODE REVIEWED BY: Prabhat Sharma

public class OpportunityLineItemTriggerHandler extends TriggerHandler{
    
    private list<OpportunityLineItem> newOppLineItemList; 
    
    public OpportunityLineItemTriggerHandler() {
        this.newOppLineItemList= (list<OpportunityLineItem>) Trigger.new;
    }
    
    public override void afterInsert(){
        updateEnquiryUpdateFlag(this.newOppLineItemList);
    }
    public override void afterUpdate(){
        updateEnquiryUpdateFlag(this.newOppLineItemList);
    }
     /**
        Author: Nishant Prajapati
        Company: Techmatrix
        Description: Its a overrriden method of trigger handler framework. It will be automatically called after insert and update.
        Inputs: List<OpportunityLineItem>
        Returns: void
        History:
        ====================================================
        1.0     24 Jul 2019  Nishant  Initial Version
        1.1     13 Aug 2019  Rajesh    Updated to remove clear bypass after update on Opportunity
  **/
    public static void updateEnquiryUpdateFlag(List<OpportunityLineItem> oppLineItems){
        
        map<Id,Opportunity> oppToUpdate= new map<Id,Opportunity>();
        
        for(OpportunityLineItem oppLineItem : oppLineItems){
            Opportunity opp= new Opportunity(Id= oppLineItem.OpportunityId);
            opp.Opportunity_Line_Modified_Time__c= DateTime.now();
            
            if (oppLineItem.Type__c == ConstantsUtility.VARIANT_CONST){ //Hardcoded value replaced by constant
                opp.Variant__c = oppLineItem.Product2Id;
                opp.Color__c = oppLineItem.Color__c;
            }
            oppToUpdate.put(opp.Id,opp);
        }
        
        if(oppToUpdate.size() > 0){
            TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
            update oppToUpdate.values();
            TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        }

    }
}