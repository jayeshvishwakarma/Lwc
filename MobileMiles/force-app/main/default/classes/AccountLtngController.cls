global class AccountLtngController
{
    @AuraEnabled
    webservice static String updateDirectOrderKpnEENMobiel(Id accountId)
    {
        Account acc = new Account(Id = accountId);
        acc.Direct_order_KPN_EEN_Mobiel__c = true;
        try{
        	update acc;
            return 'Success';
        }catch(Exception ex){
            return 'Error';
        }
    }
    
    @AuraEnabled
    webservice static String updateKPNSmallQuote(Id accountId)
    {
        Account acc = new Account(Id = accountId);
        acc.Nieuwe_KleinZakelijk_offerte_aanmaken__c = true;
        try{
        	update acc;
        	acc.Nieuwe_KleinZakelijk_offerte_aanmaken__c = false;
            update acc;
            return 'Success';
        }catch(Exception ex){
            return 'Error';
        }
        
    }
    
    @AuraEnabled
    webservice static String updateKPNOneOffer(Id accountId)
    {
        Account acc = new Account(Id = accountId);
        acc.Nieuwe_offerte_aanmaken__c = true;
        try{
        	update acc;
        	acc.Nieuwe_offerte_aanmaken__c = false;
            update acc;
            return 'Success';
        }catch(Exception ex){
            return 'Error';
        }
        
    }
    
    @AuraEnabled
    webservice static String updateTMobileQuotation(Id accountId)
    {
        Account acc = new Account(Id = accountId);
        acc.T_Mobile_offerte_aanmaken__c = true;
        try{
        	update acc;
        	acc.T_Mobile_offerte_aanmaken__c = false;
            update acc;
            return 'Success';
        }catch(Exception ex){
            return 'Error';
        }
        
    }
}