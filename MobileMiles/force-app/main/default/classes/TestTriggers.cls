public with sharing class TestTriggers {

    static testMethod void PutInQuoteSectionTest(){
        
        Account a = new Account();
        a.name = 'Test account';
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.AccountId = a.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.valueOf('2011-04-30');
        
        insert opp;
        
        Pricebook2 pb = [SELECT Id, Name from Pricebook2 WHERE isStandard=true];
        
        LSM_Product_Family__c lsmpf = new LSM_Product_Family__c(Name='Nieuw Mobile Data 1', Active__c = true);
        insert lsmpf;
         
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Family = 'Nieuw Mobile Data';
        insert p;
        
        
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = p.Id;
        pe.Pricebook2Id = pb.Id;
        pe.UseStandardPrice = false;
        pe.UnitPrice = 0;
        pe.IsActive = true;
        insert pe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 1;
        insert oli;
        
        
        opp = [Select Products__c From Opportunity WHERE Id =: opp.Id];
        
        System.assertEquals(opp.Products__c, '"Test Product", 1.00, 1.00');
         

        oli.Status_bestelling_MobileMiles_product__c ='Gefactureerd';
        update oli;
        
    }
}