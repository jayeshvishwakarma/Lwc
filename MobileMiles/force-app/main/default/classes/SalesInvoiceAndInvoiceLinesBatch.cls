global class SalesInvoiceAndInvoiceLinesBatch implements Database.Batchable<sObject> {
        
        global Database.QueryLocator start(Database.BatchableContext cntxt){
            return Database.getQueryLocator('SELECT Id, Facturen__c , TrackTrace_URL_dropshipment__c, mkbofficeshop_nl__c, Ordernummer__c, Verzendadres__c, Postcode_plaats__c, Bedrijf__c, Name, ' +
                                            'Betaalwijze__c, Aanhef__c, Achternaam__c,Bedrijfsnaam__c, E_mailadres__c, Extra_e_mailadres_1__c, ' + 
                                            'Extra_e_mailadres_2__c, Factuurdatum__c ,  ' + 
                                            '(SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,IMEI_nummer__c, Aanvulling_productomschrijving__c, Tax_Code__c, Name,TaxCode_trigger__c ' + 
                                                'FROM Bestellingproducten__r) ' + 

                                            'FROM Bestelling_MM__c ' + 
                                            'WHERE Factuur_aanmaken_en_verzenden__c = true And (Facturen__c = 0 or Facturen__c = null) limit 48');        
        }
        
        global void execute(Database.BatchableContext cntxt, List<Bestelling_MM__c> scope){
            //try{
                Map<Id, c2g__codaInvoice__c> invoiceMap = new Map<Id, c2g__codaInvoice__c>();
                for(Bestelling_MM__c bestellingRecord : scope){
                    c2g__codaInvoice__c objInvoice = new c2g__codaInvoice__c();
                    objInvoice.Bestelling__c = bestellingRecord.Id;
                    objInvoice.Track_Trace__c = bestellingRecord.TrackTrace_URL_dropshipment__c;
                    objInvoice.Verzendadres__c = bestellingRecord.Verzendadres__c;
                    objInvoice.Postcode_Plaats__c = bestellingRecord.Postcode_plaats__c;
                    objInvoice.c2g__Account__c = bestellingRecord.Bedrijf__c;
                    objInvoice.Ordernummer__c = bestellingRecord.Ordernummer__c;
                    objInvoice.Betaalwijze__c = bestellingRecord.Betaalwijze__c;
                    objInvoice.Aanhef_ontvanger__c = bestellingRecord.Aanhef__c;
                    objInvoice.Achternaam_ontvanger__c = bestellingRecord.Achternaam__c;
                    objInvoice.Bedrijfsnaam_ontvanger__c = bestellingRecord.Bedrijfsnaam__c;
                    objInvoice.E_mailadres__c = bestellingRecord.E_mailadres__c;
                    objInvoice.Extra_e_mailadres_1__c = bestellingRecord.Extra_e_mailadres_1__c;
                    objInvoice.Extra_e_mailadres_2__c = bestellingRecord.Extra_e_mailadres_2__c;
                    objInvoice.c2g__InvoiceDate__c = bestellingRecord.Factuurdatum__c;
                    objInvoice.mkbofficeshop_SIN__c = bestellingRecord.mkbofficeshop_nl__c;
                    objInvoice.c2g__DeriveDueDate__c = TRUE; // done by ranu on 2nd april as per jasper "Fwd: Derive Due Date" email
                    if(Test.isRunningTest()){
                        objInvoice.c2g__InvoiceDate__c = system.today().addDays(-10);
                    }
                    objInvoice.c2g__OwnerCompany__c  = Label.Default_Invoice_Company;  
                    objInvoice.E_mail_Verzendbevestiging_en_factuur__c = True;              
                    invoiceMap.put(bestellingRecord.Id, objInvoice);
                }
                
                if(invoiceMap.size() > 0){
                    //Database.insert(invoiceMap.values(), false);
                    insert invoiceMap.values();
                }
                SalesInvoiceAndInvoiceLinesBatchHelper.updateInvoiceLineItems(scope,invoiceMap);
                
            /*}catch(Exception ex){
                system.debug('error ' + ex.getMessage());
            }*/
                    
        }
        
        global void finish(Database.BatchableContext cntxt){
            if(!Test.isRunningTest()){
                Integer count = Database.countQuery('SELECT count() FROM Bestelling_MM__c WHERE Factuur_aanmaken_en_verzenden__c = true And (Facturen__c = 0 or Facturen__c = null) limit 48');
                if(count > 0){
                    Database.executeBatch(new SalesInvoiceAndInvoiceLinesBatch(), 48);
                }
            }
        }
           
        
        /*global List<c2g__codaInvoiceLineItem__c> createLines(List<Bestellingproduct__c> lstBestellingProdcuts, c2g__codaInvoice__c objInvoice){
            
            if (lstBestellingProdcuts.size() > 0 ){
                List<c2g__codaInvoiceLineItem__c> lstInvoiceLines = new List<c2g__codaInvoiceLineItem__c>();
                
                for(Bestellingproduct__c objBestellingProduct: lstBestellingProdcuts){
                    c2g__codaInvoiceLineItem__c objInvoiceLine =  new c2g__codaInvoiceLineItem__c();
                    if(objInvoice != null)
                        objInvoiceLine.c2g__Invoice__c = objInvoice.Id;
                    objInvoiceLine.c2g__Quantity__c = objBestellingProduct.Hoeveelheid__c;
                    objInvoiceLine.c2g__Product__c = objBestellingProduct.Product__c;
                    objInvoiceLine.c2g__UnitPrice__c = objBestellingProduct.Net_UnitPrice__c;
                    objInvoiceLine.c2g__DeriveUnitPriceFromProduct__c = false;
                    objInvoiceLine.c2g__UseProductInformation__c = false;
                    objInvoiceLine.IMEI_nummer__c = objBestellingProduct.IMEI_nummer__c;
                    objInvoiceLine.Aanvulling_productomschrijving__c = objBestellingProduct.Aanvulling_productomschrijving__c;
                    
                    lstInvoiceLines.add(objInvoiceLine);
                }
                try{
                    if(lstInvoiceLines.size() > 0)
                        return lstInvoiceLines;
                }catch(Exception ex){
                        return null;
                }
            }
            return null;
        }*/
      }