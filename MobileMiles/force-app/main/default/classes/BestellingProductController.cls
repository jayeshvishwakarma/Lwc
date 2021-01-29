/**
Name                    :                BestellingProductController
Author                  :
Date                    :                20 June,2016   
Description             :                This standard controller is used to override new and edit standard button of object 'Bestellingproduct__c'
**/
public class BestellingProductController{
    public Bestellingproduct__c bestellingPro{get;set;}
    public String productId{get;set;}
    public String productName{get;set;}
    private Map<String,Decimal> productPriceMap;
    private String editRecordId;
    private String parentRecordId;
    
    public BestellingProductController(ApexPages.StandardController controller){
        editRecordId = '';
        productPriceMap = new Map<String,Decimal>();
        //fills the map for unit price of product and price
        for(PricebookEntry price : [SELECT Id,UnitPrice,PriceBook2Id,PriceBook2.Name,Product2Id FROM PricebookEntry]){
            if(price.PriceBook2Id !=null && price.PriceBook2Id !=null)
                productPriceMap.put(price.PriceBook2Id+'/'+price.Product2Id,price.UnitPrice);  
        } 
        //code executes when edit button is clicked
        if(controller.getId() !='' && controller.getId() != null){ 
            bestellingPro = [select id,Name,IMEI_nummer__c,ToestelVerzekering__c,Totaal_per_maand_ToestelVerzekering__c,Prijs_ToestelVerzekering__c,Deselecteer_voor_verzendbevestiging__c,Hoeveelheid__c,Product__c,Product__r.Name,Bestelling__c,Verkoopprijs__c,Extra_HW_korting__c,Aanvulling_productomschrijving__c,Price__c from Bestellingproduct__c where Id =:controller.getId() ];
            productName = bestellingPro.Product__r.Name;
            editRecordId  = bestellingPro.Id;
        }
        //code executes when new button is clicked 
        else{
            productName = '';
            bestellingPro = new Bestellingproduct__c();
            List<PriceBook2> productList  = new List<PriceBook2>(); 
            productList  = [Select Id from PriceBook2 where Name = 'KPN EEN' limit 1];
            if(productList.size()>0)
                bestellingPro.Price__c = productList[0].id;
            //sets parent id to Bestelling__c 
            parentRecordId = ApexPages.currentPage().getParameters().get('CF00ND0000005eCc1_lkid') ;
            
            /*for(string key: ApexPages.currentPage().getParameters().keyset()){
                system.debug('===' + key + ' -- ' + ApexPages.currentPage().getParameters().get(key));
            }*/
            
            bestellingPro.Bestelling__c = parentRecordId; 
            editRecordId = ''; 
        }  
    }
    //this method saves Bestellingproduct__c  record and redirect page to standard detail page 
    public PageReference save(){
        try{
            if(productName == null || productName =='')
                bestellingPro.Product__c = null; 
            //fills the Verkoopprijs__c  field according to product and pricebook unit price
            if(bestellingPro.Price__c !=null && bestellingPro.Product__c != null){
                if(productPriceMap.containsKey(bestellingPro.Price__c+'/'+bestellingPro.Product__c)){
                    if(bestellingPro.id == null || bestellingPro.Verkoopprijs__c == null) 
                        bestellingPro.Verkoopprijs__c = productPriceMap.get(bestellingPro.Price__c+'/'+bestellingPro.Product__c);
                 }else{
                    bestellingPro.Verkoopprijs__c = null;
                }
            } 
            else
                bestellingPro.Verkoopprijs__c = null;   
            upsert bestellingPro; 
            productName = '';
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }  
        return new PageReference('/' + bestellingPro.id);  
    }
    //method saves the Bestellingproduct__c  record and also provide new record to be created
    public void saveAndNext(){
        try{
            if(productName == null || productName =='')
                bestellingPro.Product__c = null;
            if(bestellingPro.Price__c !=null && bestellingPro.Product__c != null){
                if(productPriceMap.containsKey(bestellingPro.Price__c+'/'+bestellingPro.Product__c)){
                    if(bestellingPro.id == null || bestellingPro.Verkoopprijs__c == null) 
                        bestellingPro.Verkoopprijs__c = productPriceMap.get(bestellingPro.Price__c+'/'+bestellingPro.Product__c);
                }else
                    bestellingPro.Verkoopprijs__c = null;    
            }
            else
                bestellingPro.Verkoopprijs__c = null;
            upsert bestellingPro;  
            productName = '';
            editRecordId = ''; 
            List<Bestellingproduct__c > parentId = new List<Bestellingproduct__c>();
            parentId  = [select Bestelling__c,id from Bestellingproduct__c where Id=:bestellingPro.Id];
            bestellingPro = new Bestellingproduct__c();
            List<PriceBook2> productList  = new List<PriceBook2>(); 
            productList  = [Select Id from PriceBook2 where Name = 'KPN EEN' limit 1];
            if(productList.size()>0)
                bestellingPro.Price__c = productList[0].id;
            if(parentId.size()>0)
                bestellingPro.Bestelling__c = parentId[0].Bestelling__c; 
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
    }
    //method cancels the record creation
    public pageReference cancel(){
        //redirects to child record detail page when record is edited
        if( editRecordId != '' &&  editRecordId != null )
            return new PageReference('/' + editRecordId);
        //redirects to parent detail page when new button is clicked to create a new record
        else
            return new PageReference('/' + ApexPages.currentPage().getParameters().get('retURL').replace('/',''));
    }
}