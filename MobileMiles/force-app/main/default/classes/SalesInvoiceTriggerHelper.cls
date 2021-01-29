/*
    Name        : SalesInvoiceTriggerHelper
    Date        : 22th feb, 2018
    Author      :
    Description : This is helper class used into RHX_c2g_codaInvoice Trigger
                   @ Update to c2g__codaInvoice__c.Paynl_Transaction_Id field from pay.nl gatway

*/
public class SalesInvoiceTriggerHelper{
    
    @future (callout=true)
    Public static void UpdatePayNLTransactionId(Set<Id> salesinvoiceIds){
        List<c2g__codaInvoice__c> saleInvoiceList = new List<c2g__codaInvoice__c>();
        
        // This method must be call before executing "PnlPaymentHandler.doTransactionRequest" method for get the ip address
        PnlPaymentHandler.userIPAddress = PnlPaymentHandler.getLoginUserIPAddress();
        PnlPaymentHandler.isTrigger = true;
        PnlPaymentHandler.isSalesTrigger = true;
        for(c2g__codaInvoice__c sinvoice : [Select id,c2g__InvoiceTotal__c, name, c2g__BillingAddress__c  
                                                                            from c2g__codaInvoice__c where id in : salesinvoiceIds]){
                Decimal amount = sinvoice.c2g__InvoiceTotal__c != null ? sinvoice.c2g__InvoiceTotal__c*100 : 0;
                string consumerAddress = string.isNotBlank(sinvoice.c2g__BillingAddress__c ) ? sinvoice.c2g__BillingAddress__c  : '';
                
                
                PnlPaymentHandler.TransactionModal transactionModalObj = PnlPaymentHandler.doTransactionRequest(amount,sinvoice.Name,
                                                                                                                        '','','','');
                
                if(transactionModalObj!=null && transactionModalObj.request!=null 
                                             && transactionModalObj.request.result=='1'
                                             && transactionModalObj.transaction_x!=null
                                             && transactionModalObj.transaction_x.transactionId!=null
                                             && transactionModalObj.transaction_x.paymentURL!=null){
                    saleInvoiceList.add(new c2g__codaInvoice__c(id=sinvoice.id,Paynl_Transaction_Id__c = transactionModalObj.transaction_x.transactionId,
                                                                                Payment_URL__c = transactionModalObj.transaction_x.paymentURL));
                }                                                                                                       
        }
        
        // updating to Bestelling_MM.Paynl_Transaction_Id records from pay.nl gatway
        If(saleInvoiceList.size()>0){
            update saleInvoiceList;
        }
        // Reset to static values
        PnlPaymentHandler.userIPAddress = '';
        PnlPaymentHandler.isTrigger = false;
        PnlPaymentHandler.isSalesTrigger = false;
    }

}