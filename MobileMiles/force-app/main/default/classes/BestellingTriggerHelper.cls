/*
    Name        : BestellingTriggerHelper
    Date        : 20 feb, 2018
    Author      :
    Description : This is helper class used into Bestelling Trigger
                   @ Update to Bestelling_MM.Paynl_Transaction_Id field from pay.nl gatway

*/
Public class BestellingTriggerHelper{
    @future (callout=true)
    Public static void UpdatePayNLTransactionId(Set<Id> bestellingIdSet){
        List<Bestelling_MM__c> updateBestellingList = new List<Bestelling_MM__c>();
        
        // This method must be call before executing "PnlPaymentHandler.doTransactionRequest" method for get the ip address
        PnlPaymentHandler.userIPAddress = PnlPaymentHandler.getLoginUserIPAddress();
        PnlPaymentHandler.isTrigger = true;
        for(Bestelling_MM__c bestObj : [Select id,Totaal_bedrag_incl_BTW__c,Name,Street__c,Postcode__c,Housenumber__c,City__c 
                                                                            from Bestelling_MM__c where id in : bestellingIdSet]){
                Decimal amount = bestObj.Totaal_bedrag_incl_BTW__c!=null ? bestObj.Totaal_bedrag_incl_BTW__c*100 : 0;
                string consumerAddress = string.isNotBlank(bestObj.Street__c) ? bestObj.Street__c : '';
                consumerAddress += string.isNotBlank(bestObj.Postcode__c) ? bestObj.Postcode__c:'';
                string consumerHouseNumber = string.isNotBlank(bestObj.Housenumber__c) ? bestObj.Housenumber__c : '';
                string consumerCity = string.isNotBlank(bestObj.City__c) ? bestObj.City__c : '';
                
                PnlPaymentHandler.TransactionModal transactionModalObj = PnlPaymentHandler.doTransactionRequest(amount,bestObj.Name,
                                                                                                                        consumerAddress,
                                                                                                                        consumerHouseNumber,
                                                                                                                        consumerCity,'');
                
                if(transactionModalObj!=null && transactionModalObj.request!=null 
                                             && transactionModalObj.request.result=='1'
                                             && transactionModalObj.transaction_x!=null
                                             && transactionModalObj.transaction_x.transactionId!=null
                                             && transactionModalObj.transaction_x.paymentURL!=null){
                    updateBestellingList.add(new Bestelling_MM__c(id=bestObj.id,Paynl_Transaction_Id__c = transactionModalObj.transaction_x.transactionId,
                                                                                Payment_URL__c = transactionModalObj.transaction_x.paymentURL));
                }                                                                                                       
        }
        
        // updating to Bestelling_MM.Paynl_Transaction_Id records from pay.nl gatway
        If(updateBestellingList.size()>0){
            update updateBestellingList;
        }
        // Reset to static values
        PnlPaymentHandler.userIPAddress = '';
        PnlPaymentHandler.isTrigger = false;
    }
}