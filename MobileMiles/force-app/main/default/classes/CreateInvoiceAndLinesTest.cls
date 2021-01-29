@isTest
public class CreateInvoiceAndLinesTest {
    
    @isTest(SeeAllData = true)
    private static void testInvoiceAndInvoiceLines(){
        Bestellingproduct__c product = [SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,
                                        IMEI_nummer__c, Aanvulling_productomschrijving__c,Bestelling__c  
                                        FROM Bestellingproduct__c 
                                        WHERE Bestelling__c != null limit 1];
        
        Bestelling_MM__c bestellingObj = [SELECT Id 
                                          FROM Bestelling_MM__c 
                                          WHERE Id =: product.Bestelling__c 
                                          LIMIT 1];
        if(bestellingObj != null){
            bestellingObj.Factuur_aanmaken_en_verzenden__c = true;
            
            bestellingObj.Factuurdatum__c = system.today();
            update bestellingObj;
        }
        
        //Testing Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(bestellingObj);
        CreateInvoiceAndLinesController testAccPlan = new CreateInvoiceAndLinesController(sc);
        testAccPlan.createInvoiceAndInvoiceLines();        
        
        //Testing Batch Helper
        /*c2g__codaInvoice__c objInvoice = new c2g__codaInvoice__c();
        objInvoice.Bestelling__c = bestellingObj.Id;
        objInvoice.Track_Trace__c = bestellingObj.TrackTrace_URL_dropshipment__c;
        objInvoice.Verzendadres__c = bestellingObj.Verzendadres__c;
        objInvoice.Postcode_Plaats__c = bestellingObj.Postcode_plaats__c;
        objInvoice.c2g__Account__c = bestellingObj.Bedrijf__c;
        objInvoice.Ordernummer__c = bestellingObj.Name;
        objInvoice.Betaalwijze__c = bestellingObj.Betaalwijze__c;
        objInvoice.Aanhef_ontvanger__c = bestellingObj.Aanhef__c;
        objInvoice.Achternaam_ontvanger__c = bestellingObj.Achternaam__c;
        objInvoice.Bedrijfsnaam_ontvanger__c = bestellingObj.Bedrijfsnaam__c;
        objInvoice.E_mailadres__c = bestellingObj.E_mailadres__c;
        objInvoice.Extra_e_mailadres_1__c = bestellingObj.Extra_e_mailadres_1__c;
        objInvoice.Extra_e_mailadres_2__c = bestellingObj.Extra_e_mailadres_2__c;
        objInvoice.c2g__InvoiceDate__c = bestellingObj.Factuurdatum__c;
        objInvoice.c2g__OwnerCompany__c  = Label.Default_Invoice_Company; 
        insert objInvoice;*/
        
        //Testing Batch Class
        //SalesInvoiceAndInvoiceLinesBatch objBatch = new SalesInvoiceAndInvoiceLinesBatch();
        InvoiceAndInvoiceLinesSchedule scheduleInvoiceAndInvoiceLines = new InvoiceAndInvoiceLinesSchedule();
        Test.startTest();
            //Database.executeBatch(objBatch);
            System.schedule('InvoiceAndInvoiceLinesBatch', '0 0 22 1/1 * ? *', scheduleInvoiceAndInvoiceLines);
            Database.executeBatch(new SalesInvoiceAndInvoiceLinesBatch());
            //SalesInvoiceAndInvoiceLinesBatchHelper.createLines(lstBestellingProdcuts, null);
            
        Test.stopTest(); 
        
        
    }
    @isTest(SeeAllData = true)
    private static void TestUpdateInvoiceLineItems(){
        List<Bestellingproduct__c> lstBestellingProdcuts = [ SELECT id, Name, Hoeveelheid__c, Product__c, Net_UnitPrice__c,IMEI_nummer__c, 
                                                             Net_UnitPrice_tbv_PIN__c, Aanvulling_productomschrijving__c, 
                                                             Tax_Code__c, 
                                                             TaxCode_trigger__c
                                                             FROM Bestellingproduct__c];                                                                 
                                                             //WHERE Bestelling__c = :bestellingObj.Id];
        SalesInvoiceAndInvoiceLinesBatchHelper.createLines(lstBestellingProdcuts, null);
        String query = 'SELECT TrackTrace_URL_dropshipment__c, Verzendadres__c, Ordernummer__c, Postcode_plaats__c, Bedrijf__c, Name, ' +
                      'Betaalwijze__c, Aanhef__c, Achternaam__c,Bedrijfsnaam__c, E_mailadres__c, Extra_e_mailadres_1__c, ' + 
                      'Extra_e_mailadres_2__c, Factuurdatum__c , Aanmaakdatum__c, mkbofficeshop_nl__c,' + 
                      '(SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,IMEI_nummer__c, Net_UnitPrice_tbv_PIN__c, Aanvulling_productomschrijving__c, Tax_Code__c, Name,TaxCode_trigger__c ' + 
                        'FROM Bestellingproducten__r) ' + 

                      'FROM Bestelling_MM__c Limit 1';
        List<Bestelling_MM__c> bestllingList = database.query(query);
        List<c2g__codaInvoice__c> salesInvoiceList = [Select Id from c2g__codaInvoice__c Limit 1];
        Map<Id, c2g__codaInvoice__c> invoiceMap = new Map<Id, c2g__codaInvoice__c>();
        invoiceMap.put(bestllingList[0].Id, salesInvoiceList[0]);
        try{
            SalesInvoiceAndInvoiceLinesBatchHelper.updateInvoiceLineItems(bestllingList, invoiceMap);
        }catch(Exception ex){
        
        }
           
    }
}