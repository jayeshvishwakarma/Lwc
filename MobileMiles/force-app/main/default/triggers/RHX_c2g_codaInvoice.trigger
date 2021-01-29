trigger RHX_c2g_codaInvoice on c2g__codaInvoice__c
    (after delete, after insert, after undelete, after update, before delete) {
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
     if(rollClass != null) {
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        if (trigger.isAfter) {
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'c2g__codaInvoice__c'}, null);
        }
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        //For payment transacion url
        Set<Id> salesinvoiceIds = new Set<Id>();
        for(c2g__codaInvoice__c sinvoice : Trigger.new){
         // Auto generate Pay.nl transaction id and update to c2g__codaInvoice__c.Paynl_Transaction_Id__c field 
            if(sinvoice.Paynl_Payment__c && (trigger.isInsert || (trigger.isUpdate && sinvoice.Paynl_Payment__c!=trigger.oldMap.get(sinvoice.id).Paynl_Payment__c))){
                salesinvoiceIds.add(sinvoice.Id); 
            }
        }
        
        // Updating to c2g__codaInvoice__c.Paynl_Transaction_Id__c field from Pay.NL transaction id
        if(salesinvoiceIds.size()>0){
            SalesInvoiceTriggerHelper.UpdatePayNLTransactionId(salesinvoiceIds);    
        }
    }
    
}