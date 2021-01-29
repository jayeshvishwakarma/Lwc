@istest
private class TestSendEmailController{

    @istest
    private static void testclass(){
        
        Account acc = new Account();
        acc.name = 'Test';
        acc.E_mailadres_bedrijf__c = 'abari@phiz.co';
        insert acc;
        
        Bestelling_MM__c beste = new Bestelling_MM__c();
        beste.Bedrijf__c = acc.id;
        beste.Hoeveelheid__c = 30;
        insert beste;
        
        apexpages.currentpage().getparameters().put('id',beste.id);
        SendEmailController sc = new SendEmailController();
        sc.sendmail();
    }

    
}