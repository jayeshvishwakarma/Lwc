@isTest
public class CsvUploadPortMobielControllerTest {
    
    static testmethod void testfileupload(){
        Test.startTest();
        
        Contact con= new contact();
        con.Email = 'ram@gmail.com';
        con.LastName= 'ds';
        con.MobilePhone= '9898561236';
        insert con;
        
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
        
        
        
        Product2 proObj = new Product2();
        proObj.Name  = 'ABCD';
        proObj.ProductCode = 'ftfeg';
        insert proObj;
        
        Id proMooRecordId = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('KPN ÉÉN').getRecordTypeId();
        //String csvFileBody = 'Product Mobiel;Product KPN ??N;Naam huidige provider;klant- nummer;Label;06/097-;Type aanvraag;Datum eind contract;Wensdatum;Recordtype-ID;Type huidig abonnement\r\n;Mobiel 10 GB;Onbeperkt min/SMS;'+proObj.Id+';KPN Service Provider Mobiel (KPN Telecom mobile);24354657;Pietje Puk;23456789;Portering;1/6/2020;1/6/2020;'+proMooRecordId+';Zakelijk';
      
        //Blob csvBlobData = Blob.valueOf(csvFileBody);
         // system.debug(' Blob.valueOf(csvFileBody) ' + Blob.valueOf(csvFileBody));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qte);
        CsvUploadPortMobielController importData = new CsvUploadPortMobielController(sc);
        String csvFileBody = 'Product Mobiel;Product KPN ??N;Naam huidige provider;klant- nummer;Label;06/097-;Type aanvraag;Datum eind contract;Wensdatum;Recordtype-ID;Type huidig abonnement\r\n"Mobiel 10 GB, Onbeperkt min/SMS";01t2o000007ZUBs;KPN Service Provider Mobiel (KPN Telecom mobile);24354657;Pietje Puk;23456789;Portering;1/6/2020;1/6/2020;012570000003J9m;Zakelijk\r\n';
      
        Blob csvBlobData = Blob.valueOf(csvFileBody);
        importData.csvFileBody = csvBlobData;
        importData.importCSVFile();
        Test.stopTest();
    }
}