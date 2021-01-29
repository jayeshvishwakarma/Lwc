public class CreateInvoiceAndLinesController {
    private Bestelling_MM__c bestellingRecord;
    
    public CreateInvoiceAndLinesController(ApexPages.StandardController stdController){
        this.bestellingRecord = (Bestelling_MM__c)stdController.getRecord();
        bestellingRecord = [ SELECT Factuur_aanmaken_en_verzenden__c
                            FROM Bestelling_MM__c
                            WHERE id = :bestellingRecord.Id
                           ];        
    }
    
    public PageReference createInvoiceAndInvoiceLines(){
        //Savepoint sp = Database.setSavepoint();
        try{            
            bestellingRecord.Factuur_aanmaken_en_verzenden__c = true;
            update bestellingRecord;                     
            return new PageReference('/' + bestellingRecord.Id);           
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Records Creation Errors' + e.getMessage()));
        }            
        return null;         
    }
    
    /*@TestVisible
    private void createLines(List<Bestellingproduct__c> lstBestellingProdcuts, c2g__codaInvoice__c objInvoice){
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
                    insert lstInvoiceLines;
            }catch(Exception ex){}
        }        
    }*/
}