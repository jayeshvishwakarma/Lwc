@isTest
public class CreatePayableInvoiceAndLinesTest {
    @isTest(SeeAllData = true)
    private static void testInvoiceAndInvoiceLines(){
        /*Account accObj = new  Account();
        accObj.Name = 'Test Account';
        insert accObj;
        
        Bestelling_MM__c bestellingObj = new Bestelling_MM__c();
        bestellingObj.Achternaam__c = 'Achternaam Testing Text';
        bestellingObj.PIN_aanmaken_en_verzenden__c = true;
        bestellingObj.Factuurdatum__c = system.today().addDays(-10);
        bestellingObj.Bedrijf__c = accObj.Id;
        insert bestellingObj;
        
        List<Bestellingproduct__c> lstBestellingProdcuts = new List<Bestellingproduct__c>();
        Bestellingproduct__c bestellingProduObj = new Bestellingproduct__c();
        bestellingProduObj.Hoeveelheid__c = 5.2;
        bestellingProduObj.IMEI_nummer__c = 'IMEI-nummer testing text';
        bestellingProduObj.Aanvulling_productomschrijving__c = 'Aanvulling productomschrijving testing text';
        bestellingProduObj.Bestelling__c = bestellingObj.Id;
        lstBestellingProdcuts.add(bestellingProduObj);
        insert lstBestellingProdcuts;*/
        
        //New Start
        Bestellingproduct__c product = [SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,
                                        IMEI_nummer__c, Aanvulling_productomschrijving__c,Bestelling__c  
                                        FROM Bestellingproduct__c 
                                        WHERE Bestelling__c != null limit 1];
        
        Bestelling_MM__c bestellingObj = [SELECT TrackTrace_URL_dropshipment__c, Verzendadres__c, Ordernummer__c, Postcode_plaats__c, 
                                          Bedrijf__c, Name, Betaalwijze__c, Aanhef__c, Achternaam__c,Bedrijfsnaam__c, E_mailadres__c, 
                                          Extra_e_mailadres_1__c, Extra_e_mailadres_2__c, Factuurdatum__c , Aanmaakdatum__c, 
                                          mkbofficeshop_nl__c, (SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,IMEI_nummer__c, 
                                          Net_UnitPrice_tbv_PIN__c, Aanvulling_productomschrijving__c, Tax_Code__c, Name,
                                          TaxCode_trigger__c FROM Bestellingproducten__r)
                                          FROM Bestelling_MM__c 
                                          LIMIT 1];
        if(bestellingObj != null){
             
            bestellingObj.PIN_aanmaken_en_verzenden__c = true;
            bestellingObj.Factuur_aanmaken_en_verzenden__c = true;
            bestellingObj.Factuurdatum__c = system.today();
            update bestellingObj;
        }
        
                                                           
        Test.startTest();
        PayableInvoiceAndInvoiceLinesSchedule scheduleInvoiceAndInvoiceLines = new PayableInvoiceAndInvoiceLinesSchedule();
        System.schedule('InvoiceAndInvoiceLinesBatch', '0 0 22 1/1 * ? *', scheduleInvoiceAndInvoiceLines);
        
        Database.executeBatch(new PayableInvoiceAndInvoiceLinesBatch());
        
        
        
       
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
        PayableInvoiceAndInvoiceLinesBatchHelper.createLines(lstBestellingProdcuts, null);
        String query = 'SELECT TrackTrace_URL_dropshipment__c, Verzendadres__c, Ordernummer__c, Postcode_plaats__c, Bedrijf__c, Name, ' +
                      'Betaalwijze__c, Aanhef__c, Achternaam__c,Bedrijfsnaam__c, E_mailadres__c, Extra_e_mailadres_1__c, ' + 
                      'Extra_e_mailadres_2__c, Factuurdatum__c , Aanmaakdatum__c, mkbofficeshop_nl__c,' + 
                      '(SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,IMEI_nummer__c, Net_UnitPrice_tbv_PIN__c, Aanvulling_productomschrijving__c, Tax_Code__c, Name,TaxCode_trigger__c ' + 
                        'FROM Bestellingproducten__r) ' + 

                      'FROM Bestelling_MM__c Limit 1';
        List<Bestelling_MM__c> bestllingList = database.query(query);
        List<c2g__codaCreditNote__c> purchaseInvoiceList = [Select Id from c2g__codaCreditNote__c Limit 1];
        Map<Id, c2g__codaCreditNote__c> invoiceMap = new Map<Id, c2g__codaCreditNote__c>();
        invoiceMap.put(bestllingList[0].Id, purchaseInvoiceList[0]);
        try{
            PayableInvoiceAndInvoiceLinesBatchHelper.updateInvoiceLineItems(bestllingList, invoiceMap);    
        }catch(Exception ex){}
          
    }
}