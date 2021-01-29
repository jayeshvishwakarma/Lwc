@isTest
public class GlasvezelPdfTest {
	
     @testSetup
    private static void setup(){
         Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.KvK_nummer__c = '200';
        objAccount.Straat__c = 'Washington';
        objAccount.Huisnummer__c = '100';
        objAccount.Huisnummer_toevoeging__c = '55';
        objAccount.ShippingCity = 'DC';
        insert objAccount;
        Glasvezel_Request__c objGlasvezelRequest=new Glasvezel_Request__c();
        objGlasvezelRequest.Bedrijfsnaam__c = 'Test';
        objGlasvezelRequest.KvK_nummer__c = '200';
        objGlasvezelRequest.Straat__c = 'Washington';
        objGlasvezelRequest.Huisnummer__c = '100';
        objGlasvezelRequest.Huisnummer_toevoeging__c = '55';
        objGlasvezelRequest.ShippingCity__c = 'DC';
        objGlasvezelRequest.Phone__c='90909090909';
        objGlasvezelRequest.Voornaam_CP__c = 'Testname';
        objGlasvezelRequest.Achternaam_CP__c = 'TestAchternaam';
        objGlasvezelRequest.Postcode__c = '123456';
        objGlasvezelRequest.E_mailadres_bedrijf__c = 'kaushik.rajrishi@gmail.com';
        objGlasvezelRequest.Bankrekeningnummer__c = '10';        
        objGlasvezelRequest.Cources__c = 'SNEL';
        objGlasvezelRequest.Fox_Sports__c = true;
        objGlasvezelRequest.Ziggo_Sports__c = true;            
        objGlasvezelRequest.Aantal__c = 2;
        objGlasvezelRequest.Account__c=objAccount.id;
        insert objGlasvezelRequest;
    
    }
    @isTest
    private static void sendPdfControllerTest(){
        test.startTest();
        List<Glasvezel_Request__c> lstGlasvezelRequests = [SELECT Bedrijfsnaam__c,FttHbeschikbaar__c, KvK_nummer__c, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, 
                                                           Postcode__c, ShippingCity__c, Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone__c,
                                                           Bankrekeningnummer__c,Bedrijfsnummer__c,Cources__c,Fox_Sports__c,Ziggo_Sports__c,Aantal__c,Account__c,Account__r.Qr_Code__c
                                                           FROM Glasvezel_Request__c                                                          
                                                          ];
        
        ApexPages.CurrentPage().getParameters().put('id',lstGlasvezelRequests[0].id); 
        GlasvezelRequestPdfController objPdfController = new GlasvezelRequestPdfController();
        objPdfController.getAccount();
        test.stopTest();
    }
}