/**
            Name        :        BatchCreateSalesLIsHelper
            Author      :        Ranu Bari
            Date        :        13th May, 2020
            Description :        batch class helper to create sales invoice line item, called from SalesInvoiceTrigger.

**/
public class BatchCreateSalesLIsHelper{

    public static void createSalesInvoiceLIs(List<c2g__codaInvoice__c> salesInvoices){
        List<c2g__codaInvoiceLineItem__c> createSalesILIs = new List<c2g__codaInvoiceLineItem__c>();
        for(c2g__codaInvoice__c salesInvoice : salesInvoices){
            createSalesILIs.add(new c2g__codaInvoiceLineItem__c(c2g__Invoice__c = salesInvoice.id,
                                                                c2g__Product__c = System.Label.Sales_Product,
                                                                c2g__UnitPrice__c = salesInvoice.c2g__Account__r.Totaal_per_maand_Cloud_N_Diensten__c));
        }    
        if(createSalesILIs.size() > 0){
            try{
                insert createSalesILIs;
            }catch(Exception e){
                system.debug(e.getMessage());
            }
        }   
    }
}