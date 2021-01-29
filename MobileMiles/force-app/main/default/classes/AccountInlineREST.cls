@RestResource(urlMapping='/RestInvoiceService/*')
global without sharing class AccountInlineREST{
    
    @HttpGet
    //global static List<c2g__codaInvoice__c> getSalesInvoices() {
     global static String getAccountChildList() {
        String accountId = RestContext.request.params.get('id');
        String objName = RestContext.request.params.get('obj');
        String returnData = '';
        if(objName == 'SalesInvoice'){
            List<c2g__codaInvoice__c> salesInvoiceList = [Select Name, c2g__PaymentStatus__c, c2g__InvoiceTotal__c, 
                                c2g__OutstandingValue__c, KPN_factuurnummer__c, c2g__InvoiceDate__c, 
                                DueDateEP__c, Betaalstatus__c, Openstaand_bedrag__c, X1e_herinnering__c,    mkbofficeshop_SIN__c, X2e_herinnering__c 
                                From c2g__codaInvoice__c Where c2g__Account__c =: accountId ORDER BY c2g__InvoiceDate__c DESC];
            returnData = JSON.serialize(salesInvoiceList);
        }else if(objName == 'SalesCreditNote'){
            List<c2g__codaCreditNote__c> creditNoteList = [Select Name, c2g__PaymentStatus__c, 
                                c2g__CreditNoteTotal__c, c2g__CreditNoteDate__c 
                                From c2g__codaCreditNote__c Where c2g__Account__c =: accountId ORDER BY c2g__CreditNoteDate__c DESC];
            returnData = JSON.serialize(creditNoteList);
        }else if(objName == 'PayableInvoice'){
            List<c2g__codaPurchaseInvoice__c> payableInvoiceList = [Select Name, c2g__PaymentStatus__c, 
                                c2g__InvoiceTotal__c, c2g__InvoiceDate__c ,mkbofficeshop_PIN__c
                                From c2g__codaPurchaseInvoice__c Where c2g__Account__c =: accountId ORDER BY c2g__InvoiceDate__c DESC];
            returnData = JSON.serialize(payableInvoiceList);
        }else if(objName == 'PayableCreditNote'){
            List<c2g__codaPurchaseCreditNote__c> payableCreditNoteList = [Select Name, c2g__PaymentStatus__c, 
                                c2g__CreditNoteTotal__c, c2g__InvoiceDate__c 
                                From c2g__codaPurchaseCreditNote__c Where c2g__Account__c =: accountId ORDER BY c2g__InvoiceDate__c DESC];
            returnData = JSON.serialize(payableCreditNoteList);
        }
        return returnData;
    
  }
}