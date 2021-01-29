global class SalesInvoiceAndInvoiceLinesBatchHelper {
    
    global static List<c2g__codaInvoiceLineItem__c> createLines(List<Bestellingproduct__c> lstBestellingProdcuts, c2g__codaInvoice__c objInvoice){
        
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
                
                objInvoiceLine.Webshopproduct__c = objBestellingProduct.Name;
                objInvoiceLine.c2g__TaxCode1__c = objBestellingProduct.TaxCode_trigger__c;
                
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
    }
    global static void updateInvoiceLineItems(List<Bestelling_MM__c> scope, Map<Id, c2g__codaInvoice__c> invoiceMap){
        List<Bestelling_MM__c> lstBestelling  = new List<Bestelling_MM__c>();
        List<c2g__codaInvoiceLineItem__c> lstAllInvoiceLines = new List<c2g__codaInvoiceLineItem__c>();
        for(Bestelling_MM__c bestellingRecord : scope){
                    
            c2g__codaInvoice__c objInvoice = invoiceMap.get(bestellingRecord.Id);
            
            //insert objInvoice;
            if(bestellingRecord.Bestellingproducten__r.size() > 0){
                if(objInvoice != null){
                    List<c2g__codaInvoiceLineItem__c> lstInvoiceLines = SalesInvoiceAndInvoiceLinesBatchHelper.createLines(bestellingRecord.Bestellingproducten__r, objInvoice);
                    if(lstInvoiceLines != null)
                        lstAllInvoiceLines.addAll(lstInvoiceLines);
                }   
            }
            
            Bestelling_MM__c bmUpdate = new Bestelling_MM__c(Id = bestellingRecord.Id, Factuur_aanmaken_en_verzenden__c = false, Status__c = 'Verwerkt');         
            lstBestelling.add(bmUpdate);               
        }
        
        //insert childs
        if(lstAllInvoiceLines.size() > 0)
            //Database.insert(lstAllInvoiceLines, false);  
            insert lstAllInvoiceLines;
        
        // Update Bestelling Status unchecked
        if(lstBestelling.size() > 0){
            List<c2g__codaInvoice__c> lstupdateNewInvoices = new List<c2g__codaInvoice__c>();
            for(c2g__codaInvoice__c objNewInvoice : invoiceMap.values()){
                c2g__codaInvoice__c objupdateInvoice = new c2g__codaInvoice__c(Id=objNewInvoice.Id, E_mail_Verzendbevestiging_en_factuur__c=true);
                lstupdateNewInvoices.add(objupdateInvoice);
            }
            //Database.update(lstupdateNewInvoices, false);
            update lstupdateNewInvoices;
            
            update lstBestelling;
        }
    }

}