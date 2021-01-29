global class PayableInvoiceAndInvoiceLinesBatchHelper {
    
   global static List<c2g__codaCreditNoteLineItem__c> createLines(List<Bestellingproduct__c> lstBestellingProdcuts, c2g__codaCreditNote__c creditNote){
        
        if (lstBestellingProdcuts.size() > 0 ){
            List<c2g__codaCreditNoteLineItem__c> creditNoteLIs = new List<c2g__codaCreditNoteLineItem__c>();
            
            for(Bestellingproduct__c objBestellingProduct: lstBestellingProdcuts){
                c2g__codaCreditNoteLineItem__c creditNLI =  new c2g__codaCreditNoteLineItem__c();
                if(creditNote != null)
                    /*objInvoiceLine.c2g__PurchaseInvoice__c = creditNote.Id;
                    //objInvoiceLine.Hoeveelheid_tbv_creditfactuur__c = objBestellingProduct.Hoeveelheid__c;
                    objInvoiceLine.c2g__Quantity__c  = objBestellingProduct.Hoeveelheid__c;
                    objInvoiceLine.c2g__Product__c = objBestellingProduct.Product__c;
                    objInvoiceLine.c2g__UnitPrice__c = objBestellingProduct.Net_UnitPrice_tbv_PIN__c;
                    objInvoiceLine.c2g__DeriveUnitPriceFromProduct__c = false;
                    objInvoiceLine.c2g__InputVATCode__c = objBestellingProduct.TaxCode_trigger__c;
                    objInvoiceLine.Webshopproduct__c = objBestellingProduct.Name;
                    //objInvoiceLine.c2g__UseProductInformation__c = false;
                    //objInvoiceLine.IMEI_nummer__c = objBestellingProduct.IMEI_nummer__c;
                    //objInvoiceLine.Aanvulling_productomschrijving__c = objBestellingProduct.Aanvulling_productomschrijving__c;
                    //objInvoiceLine.c2g__TaxCode1__c = objBestellingProduct.TaxCode_trigger__c;*/
                    
                    creditNLI.c2g__CreditNote__c = creditNote.Id;
                    creditNLI.c2g__Quantity__c  = objBestellingProduct.Hoeveelheid__c;
                    creditNLI.c2g__Product__c = objBestellingProduct.Product__c;
                    creditNLI.c2g__UnitPrice__c = objBestellingProduct.Net_UnitPrice_tbv_PIN__c;
                    creditNLI.c2g__DeriveUnitPriceFromProduct__c = false;
                    creditNLI.c2g__TaxCode1__c = objBestellingProduct.TaxCode_trigger__c;
                    creditNLI.Webshopproduct__c = objBestellingProduct.Name;
                    creditNoteLIs.add(creditNLI);
            }
            try{
                if(creditNoteLIs.size() > 0)
                    return creditNoteLIs;
            }catch(Exception ex){
                    return null;
            }
        }
        return null;
    }
    
    global static void updateInvoiceLineItems(List<Bestelling_MM__c> scope, Map<Id, c2g__codaCreditNote__c> creditNoteMap){
        List<Bestelling_MM__c> lstBestelling  = new List<Bestelling_MM__c>();
        List<c2g__codaCreditNoteLineItem__c> CNLineItems = new List<c2g__codaCreditNoteLineItem__c>();
        for(Bestelling_MM__c bestellingRecord : scope){
                c2g__codaCreditNote__c creditNote = creditNoteMap.get(bestellingRecord.Id);
                
                //insert objInvoice;
                if(bestellingRecord.Bestellingproducten__r.size() > 0){
                    if(creditNote != null){
                        
                        List<c2g__codaCreditNoteLineItem__c> noteLineItems = createLines(bestellingRecord.Bestellingproducten__r, creditNote);
                        
                        if(noteLineItems != null)
                            CNLineItems.addAll(noteLineItems);
                    }  
                }
                
                Bestelling_MM__c bmUpdate = new Bestelling_MM__c(Id = bestellingRecord.Id, PIN_aanmaken_en_verzenden__c = false, Status__c = 'Verwerkt');         
                lstBestelling.add(bmUpdate);               
            }
            
            //insert childs
            if(CNLineItems.size() > 0)
              //Database.insert(lstAllInvoiceLines, false);  
              insert CNLineItems;
            
            // Update Bestelling Status unchecked
            if(lstBestelling.size() > 0){
                List<c2g__codaCreditNote__c> lstupdateNewcreditNotes = new List<c2g__codaCreditNote__c>();
                for(c2g__codaCreditNote__c objNewCreditNote : creditNoteMap.values()){
                    c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c(Id=objNewCreditNote.Id, Verzend_creditfactuur__c =true);
                    lstupdateNewcreditNotes.add(creditNote);
                }
                //Database.update(lstupdateNewInvoices, false);
                update lstupdateNewcreditNotes;
                
                update lstBestelling;
                //Database.update (lstBestelling, false);
            }
    }
}