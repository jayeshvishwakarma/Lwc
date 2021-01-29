/**
            Name        :        SalesInvoiceTrigger 
            Author      :        Ranu Bari
            Date        :        13th May, 2020
            Description :        Trigger on sales invoice for some data update and logics.

**/
trigger SalesInvoiceTrigger on c2g__codaInvoice__c (after update) {
    
    /**Start to create invoice line item and replace "Insert SINLI" PB functionality through trigger.**/

    Set<Id> invoices = new Set<Id>();
    if(Trigger.isAfter && Trigger.isUpdate){
        for(c2g__codaInvoice__c invoice : Trigger.new){         
               if(invoice.Insert_Cloud_N_Diensten__c == TRUE && 
               invoice.Insert_Cloud_N_Diensten__c != Trigger.oldMap.get(invoice.id).Insert_Cloud_N_Diensten__c){
               
                invoices.add(invoice.id);
            }
        }
        if(invoices.size() > 0){
            BatchCreateSalesLIs createSLIs = new BatchCreateSalesLIs(invoices);
            Database.executeBatch(createSLIs); 
        }
    }
    /**End to create invoice line item and replace "Insert SINLI" PB functionality through trigger.**/
}