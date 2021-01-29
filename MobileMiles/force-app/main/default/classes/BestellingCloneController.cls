/*
      Name           : BestellingCloneController
      Author         :
      Date           : 13th Jun 2016
      Description    : This controller is used in clonning existing Bestelling and its child products
*/
public class BestellingCloneController{

    public Bestelling_MM__c Bestelling{get;set;}
    public list<Bestellingproduct__c> BestellingProductList{get;set;}
    public String recordId{get;set;}
    public Integer delIndex{get;set;}
    public String productId{get;set;}
    public Map<String,String> productIdNameMap{get;set;}
   
    public BestellingCloneController(ApexPages.StandardController controller){      
        Bestelling = new Bestelling_MM__c();
        productIdNameMap = new Map<String,String>();
        BestellingProductList = new list<Bestellingproduct__c>();
        try{
            Set<String> productIdSet = new Set<String>();
            recordId = ApexPages.currentPage().getParameters().get('id');
            Bestelling = [select id, name, Bedrijf__c, MobileMiles__c, RecordTypeid, RecordType.name, Factuurdatum__c, Status__c, 
                Factuur_verzonden__c, Factuurnummer__c, Kenmerk__c, Betalingsvoorwaarden__c, Periode__c, Aangepaste_leverdatum__c,
                Handmatig_uitbetaald__c, Betaallink__c, Bedrijfsnaam__c, E_mailadres__c, Aanhef__c, Extra_e_mailadres_1__c, 
                Extra_e_mailadres_2__c, Voornaam__c, Achternaam__c, TrackTrace__c, Verzendadres__c, TrackTrace_dropshipment__c,
                Postcode_plaats__c, verwachte_leverdatum__c, Opmerkingen__c,(select id,Productnaam__c, IMEI_nummer__c,Hoeveelheid__c, Verkoopprijs__c, 
                Extra_HW_korting__c, Totale_prijs__c, Bestelling__c,Product__c,Aanvulling_productomschrijving__c,Price__c from 
                Bestellingproducten__r) from Bestelling_MM__c where id =:recordId];
            if(Bestelling != null){            
                for(Bestellingproduct__c prod: Bestelling.Bestellingproducten__r){
                    BestellingProductList.add(prod.clone(false));
                    productIdSet.add(prod.Product__c);
                }            
            }
            if(productIdSet.size()>0){
                for(Product2 pro : [select id,Name from Product2 where Id IN :productIdSet])
                    productIdNameMap.put(pro.Id,pro.Name);
            }
                
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Record Found for Clone.'));   
        }
    }
    //Deletes a row and contents
    public void DeleteRow(){
        if(delIndex != null)
            BestellingProductList.remove(delIndex);
    }
    //Clones existing Bestelling and products
    public PageReference save(){
        Bestelling_MM__c BestellingInsert = Bestelling.clone(false);
        try{
            insert BestellingInsert;
            if(BestellingProductList.size() > 0){
                for(Bestellingproduct__c prod: BestellingProductList){
                    prod.Bestelling__c = BestellingInsert.id;
                }
                insert BestellingProductList;
            }           
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage())); 
        }        
        return new PageReference('/' + BestellingInsert.id);
    }  
}