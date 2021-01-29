trigger UpdateKPNKorting on Quote (after update) {
    List<Trigger_Settings__c> lstTriggerSettings = [SELECT Quote_Trigger__c From Trigger_Settings__c];
   
   if(lstTriggerSettings.size()>0 && lstTriggerSettings[0].Quote_Trigger__c){
    List<QuoteLineItem> qLIList = [SELECT Id, Quote.Looptijd__c, Abonnement__c, KPN_Korting__c, KPN_Korting_Update__c FROM QuoteLineItem WHERE QuoteId IN :trigger.new];
    
    for(QuoteLineItem qLI : qLIList){
        qLI.KPN_Korting_update__c = qLI.KPN_Korting__c;
    }
    
    update qLIList;
    /*
    
    IF(AND( ISPICKVAL(Quote.Looptijd__c,"2 jaar") , BEGINS(Abonnement__c,"Zorgeloos"),CONTAINS(Abonnement__c,"Actie lifetime")), 8.26, 
IF(AND( ISPICKVAL(Quote.Looptijd__c,"2 jaar") , OR(Abonnement__c="Budget 300, Actie lifetime",Abonnement__c="Basis, Actie lifetime",Abonnement__c="Vooral Internet Instap, Actie lifetime")), 2.07, 
IF(AND( ISPICKVAL(Quote.Looptijd__c,"2 jaar") , Abonnement__c="Vooral Internet Standaard, Actie lifetime"), 4.13, 
IF(AND( ISPICKVAL(Quote.Looptijd__c,"1 jaar") , BEGINS(Abonnement__c,"Zorgeloos"),CONTAINS(Abonnement__c,"Actie lifetime")), 4.13, 
NULL))))
    */
}
}