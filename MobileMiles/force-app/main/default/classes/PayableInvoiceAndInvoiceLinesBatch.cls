global class PayableInvoiceAndInvoiceLinesBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext cntxt){
      return Database.getQueryLocator('SELECT TrackTrace_URL_dropshipment__c, Verzendadres__c, Ordernummer__c, Postcode_plaats__c, Bedrijf__c, Name, ' +
                      'Betaalwijze__c, Aanhef__c, Achternaam__c,Bedrijfsnaam__c, E_mailadres__c, Extra_e_mailadres_1__c, ' + 
                      'Extra_e_mailadres_2__c, Factuurdatum__c , Aanmaakdatum__c, mkbofficeshop_nl__c,' + 
                      '(SELECT Hoeveelheid__c, Product__c, Net_UnitPrice__c,IMEI_nummer__c, Net_UnitPrice_tbv_PIN__c, Aanvulling_productomschrijving__c, Tax_Code__c, Name, TaxCode_trigger__c ' + 
                        'FROM Bestellingproducten__r) ' + 

                      'FROM Bestelling_MM__c ' + 
                      'WHERE PIN_aanmaken_en_verzenden__c = true');        
    }
    
    global void execute(Database.BatchableContext cntxt, List<Bestelling_MM__c> scope){
        try{
            //Map<Id, c2g__codaPurchaseInvoice__c> invoiceMap = new Map<Id, c2g__codaPurchaseInvoice__c>();
            
            Map<Id, c2g__codaCreditNote__c> creditNoteMap = new Map<Id, c2g__codaCreditNote__c>();
            for(Bestelling_MM__c bestellingRecord : scope){
                
                /*c2g__codaPurchaseInvoice__c objInvoice = new c2g__codaPurchaseInvoice__c();
                objInvoice.Bestelling__c = bestellingRecord.Id;
                //objInvoice.Verzendadres__c = bestellingRecord.Verzendadres__c;
                //objInvoice.Postcode_plaats__c = bestellingRecord.Postcode_plaats__c;
                objInvoice.c2g__AccountInvoiceNumber__c = bestellingRecord.Name;
                objInvoice.c2g__Account__c = bestellingRecord.Bedrijf__c;
                objInvoice.Ordernummer__c = bestellingRecord.Ordernummer__c;
                objInvoice.Betaalwijze__c = bestellingRecord.Betaalwijze__c;
                objInvoice.Aanhef__c = bestellingRecord.Aanhef__c;
                
                // objInvoice.Bedrijfsnaam_ontvanger__c = bestellingRecord.Bedrijfsnaam__c;
                objInvoice.E_mailadres__c = bestellingRecord.E_mailadres__c;
                objInvoice.Extra_e_mailadres_1__c = bestellingRecord.Extra_e_mailadres_1__c;
                objInvoice.Extra_e_mailadres_2__c = bestellingRecord.Extra_e_mailadres_2__c;
                objInvoice.Achternaam__c = bestellingRecord.Achternaam__c;
                objInvoice.mkbofficeshop_PIN__c = bestellingRecord.mkbofficeshop_nl__c;
                objInvoice.c2g__InvoiceDate__c = bestellingRecord.Aanmaakdatum__c;
                if(Test.isRunningTest()){
                    objInvoice.c2g__InvoiceDate__c = system.today().addDays(-10);
                }
                system.debug(Label.Default_Invoice_Company);
                objInvoice.c2g__OwnerCompany__c  = Label.Default_Invoice_Company;  
                //objInvoice.E_mail_Verzendbevestiging_en_factuur__c = True;        
                invoiceMap.put(bestellingRecord.Id, objInvoice);*/
                
                //done by ranu on 1st april 2020 as per jasper rebuild logic
                c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
                creditNote.Bestelling__c = bestellingRecord.Id;
                creditNote.c2g__Account__c = bestellingRecord.Bedrijf__c;
                creditNote.Ordernummer__c = bestellingRecord.Ordernummer__c;
                creditNote.Betaalwijze__c = bestellingRecord.Betaalwijze__c;
                creditNote.Salutation__c = bestellingRecord.Aanhef__c;
                creditNote.E_mail__c = bestellingRecord.E_mailadres__c;
                creditNote.Extra_e_mailadres_1__c = bestellingRecord.Extra_e_mailadres_1__c;
                creditNote.Extra_e_mailadres_2__c = bestellingRecord.Extra_e_mailadres_2__c;
                creditNote.Lastname__c = bestellingRecord.Achternaam__c;
                creditNote.mkbofficeshop_SCR__c = bestellingRecord.mkbofficeshop_nl__c;
                creditNote.c2g__InvoiceDate__c = bestellingRecord.Aanmaakdatum__c;
                if(Test.isRunningTest()){
                    creditNote.c2g__InvoiceDate__c = system.today().addDays(-10);
                }
                creditNoteMap.put(bestellingRecord.Id, creditNote);
            }
            
            if(creditNoteMap.size() > 0){
                //Database.insert(invoiceMap.values(), false);
                insert creditNoteMap.values();
            }
            
            PayableInvoiceAndInvoiceLinesBatchHelper.updateInvoiceLineItems(scope, creditNoteMap);
        }catch(Exception ex){
            system.debug('error ' + ex.getMessage());
        }
              
    }
    
    global void finish(Database.BatchableContext cntxt){
      
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