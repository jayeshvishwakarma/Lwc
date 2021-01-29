@istest
public class TestPorteringToWSGrexxOrder {
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
        pMob.Huidig_SIM_kaart_nummer_bij_consument__c = '123455';
        pMob.Type_aanvraag__c = 'Nieuw nummer';
        pMob.Afwijkende_contract_einddatum__c  = system.today();
        pMob.Selecteer__c = true;
        pMob.GREXX_status_update__c = null;
        
        insert pmob;
    }

    public static testmethod void sendOrderToGrexxFail() {
    Test.setMock(HttpCalloutMock.class, new WSGrexxOrderControlHttpMock());
        Porteringen_mobiel__c  pmob = [select id from Porteringen_mobiel__c  limit 1];
        pmob.Grexxref__c = 'something';
        update pmob;
        Test.startTest();
        PorteringToWSGrexxOrder theController = new PorteringToWSGrexxOrder(new ApexPages.StandardController(pmob));
        theController.CreateOrder();
        PageReference pageref1 = theController.CreateOrderForce();
        test.stopTest();
    }

    public static testmethod void sendOrderToGrexx() {
    Test.setMock(HttpCalloutMock.class, new WSGrexxOrderControlHttpMock());
        Porteringen_mobiel__c  pMob = [select id from Porteringen_mobiel__c  limit 1];
        pmob.orderwishdate__c = System.today().addDays(2);
        pmob.Grexxref__c = null;
        update pmob;
        
        Test.startTest();
        PorteringToWSGrexxOrder theController = new PorteringToWSGrexxOrder(new ApexPages.StandardController(pmob));
        PageReference pageref = theController.CreateOrder();
        PageReference pageref1 = theController.CreateOrderForce();
        
       
        test.stopTest();
    }
    public static testmethod void sendOrderToGrexx1() {
        //from LWC (SimSwap) component
        Test.setMock(HttpCalloutMock.class, new WSGrexxOrderControlHttpMock());
        Test.startTest();
        List<Porteringen_mobiel__c> portMob = [Select name, orderwishdate__c, account__r.iRMA_id__c, account__r.name, account__r.Straat__c, account__r.Huisnummer__c, 
                                               account__r.Huisnummer_toevoeging__c, account__r.Postcode__c, account__r.shippingcity, 
                                               account__r.Telefoonnummer_nummeriek__c, account__r.E_mailadres_bedrijf__c, account__r.Rechtsvormtext__c, 
                                               account__r.Naam_volledig_cp__c, account__r.Voornaam_CP__c, account__r.IRMA_MKB_Office__c,  account__r.Achternaam_CP__c, Grexxref__c, Nieuw_SIM_kaart_nummer__c 
                                               from Porteringen_mobiel__c LIMIT 1];
        
        
        list<Porteringen_mobiel__c> mobPorteringen = [Select productcode__c, Nieuw_SIM_kaart_nummer__c, phonenumber_nummeriek__c, donortelco_ID__c,
                                                      phonenumbertype__c, subscriptiontype__c, Gids_vermelding__c, Wensdatum__c, Blokkeren_betaalde_servicenummers__c,
                                                      Blokkeren_bellen_in_het_buitenland__c, Blokkeren_bellen_naar_buitenland__c, Blokkeren_data_in_het_buitenland__c,
                                                      Blokkeren_nummer_herkenning__c, Klant_nummer__c, Huidig_SIM_kaart_nummer_bij_consument__c, IRMA_Id__c,
                                                      OrderStatusCode__c, Contract_einddatum__c, Label__c, account__r.IRMA_MKB_Office__c,
                                                      (Select Id, productcode__c From Mobiele_modules__r)
                                                      From Porteringen_mobiel__c LIMIT 1];
        PorteringToWSGrexxOrder.callGrexxService(portMob[0], mobPorteringen);
        Test.stopTest();
    }
}