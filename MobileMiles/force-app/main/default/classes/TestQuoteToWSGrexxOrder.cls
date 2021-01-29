@istest
public class TestQuoteToWSGrexxOrder {
    @testsetup
    public static void setupData() {
        account acc = (account) account.sObjectType.newSObject(null, true);
        acc.Name = 'Redbook';
        acc.Straat__c = 'Bolderweg';
        acc.Huisnummer__c = '2';
        acc.ShippingPostalCode = '1332AT';
        acc.ShippingCity = 'Almere';
        acc.ShippingCountry = 'NLD';
        acc.Phone = '036 8080 112';
        acc.E_mailadres_bedrijf__c = 'erik.hamelink@redbookict.nl';
        acc.Rechtsvorm__c = 'Stichting';
        acc.Voornaam_CP__c = 'Erik';
        acc.Achternaam_CP__c = 'Hamelink';
        acc.KvK_nummer__c = '60591706';
        insert acc;
        Opportunity opp = (Opportunity) opportunity.sObjectType.newSObject(null, true);
        opp.AccountId = acc.Id;
        opp.Name = 'TestOpp';
        opp.StageName = 'Won';
        opp.CloseDate = System.today().addDays(2);
        insert opp;
        Quote qte = (Quote) Quote.sObjectType.newSObject(null, true);
        qte.opportunityId = opp.Id;
        qte.name = 'TestQuote';

        insert qte;

        Porteringen_mobiel__c pMob = (Porteringen_mobiel__c) Porteringen_mobiel__c.sObjectType.newSObject(null, true);
        pMob.Offerte__c = qte.Id;
        pMob.Profieltype__c = 'KPN ÉÉN Zakelijk Mobiel Bundel SO';
        pMob.Type_huidig_abonnement__c = 'Zakelijk';
        pMob.Name = '12345678';
        pMob.Nieuw_SIM_kaart_nummer__c = '12345678';
        pMob.Wensdatum__c = System.today().addDays(2);
        pMob.Huidig_SIM_kaart_nummer_bij_consument__c = '12345678';
        pMob.Type_aanvraag__c = 'Nieuw nummer';
        pMob.Afwijkende_contract_einddatum__c  = system.today();
        pMob.Selecteer__c = true;
        pMob.GREXX_status_update__c = null;
        
        insert pmob;
    }

    public static testmethod void sendOrderToGrexxFail() {
    Test.setMock(HttpCalloutMock.class, new WSGrexxOrderControlHttpMock());
        Quote qte = [select id from Quote limit 1];
        qte.Grexxref__c = 'something';
        update qte;
        Test.startTest();
        QuoteToWSGrexxOrder theController = new QuoteToWSGrexxOrder(new ApexPages.StandardController(qte));
        theController.CreateOrder();
        PageReference pageref1 = theController.CreateOrderForce();
        test.stopTest();
    }

    public static testmethod void sendOrderToGrexx() {
    Test.setMock(HttpCalloutMock.class, new WSGrexxOrderControlHttpMock());
        Quote qte = [select id from Quote limit 1];
        qte.orderwishdate__c = System.today().addDays(2);
        qte.Grexxref__c = null;
        update qte;
        
        Test.startTest();
        QuoteToWSGrexxOrder theController = new QuoteToWSGrexxOrder(new ApexPages.StandardController(qte));
        PageReference pageref = theController.CreateOrder();
        PageReference pageref1 = theController.CreateOrderForce();
        test.stopTest();
    }
}