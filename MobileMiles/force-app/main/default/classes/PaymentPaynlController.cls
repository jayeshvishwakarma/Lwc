public with sharing class PaymentPaynlController{

    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static void ParametersFromPage(String params, string orderId) {
        Bestelling_MM__c Bestelling = [SELECT id, Transaction_Id__c, Payment_Status__c FROM Bestelling_MM__c WHERE Transaction_Id__c =:orderId ];      
        if(params == '100'){
            Bestelling.Payment_Status__c ='Successed';
        }  
        else{
            Bestelling.Payment_Status__c ='Failed';    
        } 
        system.debug(Bestelling);
        update  Bestelling;    
    }
}