/**
            Name        :        BatchCreateSalesLIs
            Author      :        Ranu Bari
            Date        :        13th May, 2020
            Description :        batch class to create sales invoice line item, called from SalesInvoiceTrigger.

**/
global class BatchCreateSalesLIs implements Database.Batchable<sobject> {   
   global Set<ID> invoices;
   global BatchCreateSalesLIs(Set<Id> invoices){
       this.invoices = invoices;
   }
   // Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
      String query = 'select id, c2g__Account__r.Totaal_per_maand_Cloud_N_Diensten__c  from c2g__codaInvoice__c where id IN : invoices';
      return Database.getQueryLocator(query);     
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<c2g__codaInvoice__c> scope) {       
       if(scope.size()>0){
            BatchCreateSalesLIsHelper.createSalesInvoiceLIs(scope);            
        }
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}