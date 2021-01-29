/**
    * @Autho:- Nishant Prajapati
    * @Company-: Techmatrix Consulting
    * @Description-: APEX Trigger on Opportunity Line Item
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       22 July 2019    Nishant     Intial Version
    **/
trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update) {
    //To bypass the Opportunity Trigger
    new OpportunityLineItemTriggerHandler().run();
}