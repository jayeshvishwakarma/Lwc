/**
Name                    :                TestBestellingProductController
Author                  :
Date                    :                21 June,2016   
Description             :                This class is used to provide code coverage and control flow of class 'BestellingProductController'
**/
@isTest
public class TestBestellingProductController{
    
    @isTest
    private static void testFlow(){
        //Inserting a record of Account
        Account acc = new Account(Name = 'Testing Account Record');
        insert acc;
        //Inserting records of Product2
        List<Product2> productList = new List<Product2>();
        Product2 prod1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        productList.add(prod1);
        Product2 prod2 = new Product2(Name = 'Laptop X202', Family = 'Hardware');
        productList.add(prod2);
        Product2 prod3 = new Product2(Name = 'Laptop X201', Family = 'Hardware');
        productList.add(prod3);
        insert productList;
        
        //Insert custom PriceBook2 Records
        Pricebook2 customPB1 = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB1;
        
        Pricebook2 customPB2 = new Pricebook2(Name='MobileMiles', isActive=true);
        insert customPB2;
        
        //Insert  price book entries with a custom price.
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id =  Test.getStandardPricebookId(), Product2Id = prod1.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice1;
        
        PricebookEntry customPrice3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice3;
        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id =  Test.getStandardPricebookId(), Product2Id = prod3.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice2;
        
        //inserting a record of Bestelling
        Bestelling_MM__c bestell = new Bestelling_MM__c();
        bestell.RecordTypeId = Schema.SObjectType.Bestelling_MM__c.getRecordTypeInfosByName().get('Meervoudig').getRecordTypeId();
        bestell.Bedrijf__c = acc.Id;
        bestell.Status__c = 'Bestelling geannuleerd';
        insert bestell; 
        Bestellingproduct__c bestellPro = new Bestellingproduct__c(Bestelling__c=bestell.id);
        insert bestellPro;
        ApexPages.StandardController sc = new ApexPages.StandardController(bestellPro);
        ApexPages.currentPage().getParameters().put('retURL',bestell.Id);
        BestellingProductController classObj = new BestellingProductController(sc); 
        classObj.bestellingPro.Hoeveelheid__c = 1212;
        classObj.bestellingPro.Verkoopprijs__c = 123.12;
        classObj.bestellingPro.Extra_HW_korting__c = 12.12;
        classObj.bestellingPro.Product__c = prod1.Id;
        classObj.bestellingPro.Aanvulling_productomschrijving__c = 'test';
        classObj.bestellingPro.Price__c  = [select Pricebook2Id from  PricebookEntry  where Id=:customPrice1.Id].Pricebook2Id ;
        classObj.save();
        
        //system.assert([select id from Bestellingproduct__c where id=:classObj.bestellingPro.Id].Id!=null);
        
        Bestellingproduct__c bestellPro1  =  [select id,Hoeveelheid__c,Extra_HW_korting__c  from Bestellingproduct__c  where id=:classObj.bestellingPro.Id];
        ApexPages.StandardController sc1 = new ApexPages.StandardController(bestellPro1);
        BestellingProductController classObj1 = new BestellingProductController(sc1);
        classObj1.bestellingPro.Verkoopprijs__c  = 111.00;
        classObj.bestellingPro.Price__c = [select Pricebook2Id from  PricebookEntry  where Id=:customPrice1.Id].Pricebook2Id;
        classObj1.saveAndNext();
        classObj1.cancel();
    }
    @isTest
    private static void testFlow2(){
        //Inserting a record of Account
        Account acc = new Account(Name = 'Testing Account Record');
        insert acc;
        //Inserting records of Product2
        List<Product2> productList = new List<Product2>();
        Product2 prod1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        productList.add(prod1);
        Product2 prod2 = new Product2(Name = 'Laptop X202', Family = 'Hardware');
        productList.add(prod2);
        Product2 prod3 = new Product2(Name = 'Laptop X201', Family = 'Hardware');
        productList.add(prod3);
        insert productList;
        
        //Insert custom PriceBook2 Records
        Pricebook2 customPB1 = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB1;
        
        Pricebook2 customPB2 = new Pricebook2(Name='MobileMiles', isActive=true);
        insert customPB2;
        
        //Insert  price book entries with a custom price.
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id =  Test.getStandardPricebookId(), Product2Id = prod1.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice1;
        
        PricebookEntry customPrice3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice3;
        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id =  Test.getStandardPricebookId(), Product2Id = prod3.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice2;
        
        //inserting a record of Bestelling
        Bestelling_MM__c bestell = new Bestelling_MM__c();
        bestell.RecordTypeId = Schema.SObjectType.Bestelling_MM__c.getRecordTypeInfosByName().get('Meervoudig').getRecordTypeId();
        bestell.Bedrijf__c = acc.Id;
        bestell.Status__c = 'Bestelling geannuleerd';
        insert bestell; 
        Bestellingproduct__c bestellPro = new Bestellingproduct__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(bestellPro);
        ApexPages.currentPage().getParameters().put('retURL',bestell.Id);
        BestellingProductController classObj = new BestellingProductController(sc); 
        classObj.bestellingPro.Hoeveelheid__c = 1212;
        classObj.bestellingPro.Verkoopprijs__c = 123.12;
        classObj.bestellingPro.Extra_HW_korting__c = 12.12;
        classObj.bestellingPro.Product__c = prod1.Id;
        classObj.bestellingPro.Aanvulling_productomschrijving__c = 'test';
        classObj.bestellingPro.Price__c  = [select Pricebook2Id from  PricebookEntry  where Id=:customPrice1.Id].Pricebook2Id ;
        classObj.save();
        
        //system.assert([select id from Bestellingproduct__c where id=:classObj.bestellingPro.Id].Id!=null);
        
        Bestellingproduct__c bestellPro1  = new Bestellingproduct__c();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(bestellPro1);
        BestellingProductController classObj1 = new BestellingProductController(sc1);
        classObj1.bestellingPro.Verkoopprijs__c  = 111.00;
        classObj.bestellingPro.Price__c = [select Pricebook2Id from  PricebookEntry  where Id=:customPrice1.Id].Pricebook2Id;
        classObj1.saveAndNext();
        classObj1.cancel();
    }
}