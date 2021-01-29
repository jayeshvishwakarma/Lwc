/*
        Name            :    PVOaanmakenTest
        Author          :    Shikha
        Date            :    05/22/2019
        Description     :    Used to test PVOaanmaken controller
*/
@istest
public class PVOaanmakenTest{
    @isTest
    public static void unitTest() {
         //create account
        account acc = (account) account.sObjectType.newSObject(null, true);
        acc.Name = 'Redbook';
        acc.Straat__c = 'Bolderweg';
        acc.Huisnummer__c = '2';
        acc.ShippingPostalCode = '1332AT';
        acc.ShippingCity = 'Almere';
        acc.ShippingCountry = 'NLD';
        acc.Phone = '036 8080 112';
        acc.E_mailadres_bedrijf__c = 'erik.hamelink@redbookict.nl';
        acc.Rechtsvorm__c = 'Stichting';
        acc.Voornaam_CP__c = 'Erik';
        acc.Achternaam_CP__c = 'Hamelink';
        acc.KvK_nummer__c = '60591706';
        insert acc;
        
        //to get the Standard PriceBook Id
        Id pricebookId = Test.getStandardPricebookId();

        //Create product
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        
        //Create pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        
        //create opportunity
        Opportunity opp = (Opportunity) opportunity.sObjectType.newSObject(null, true);
        opp.AccountId = acc.Id;
        opp.Name = 'TestOpp';
        opp.StageName = 'Won';
        opp.CloseDate = System.today().addDays(2);
        opp.PVO_aanmaken__c = true;
        insert opp;
        
        //create opportunity line item
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = opp.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;
        
        Test.startTest();
            PVOaanmaken pvo = new PVOaanmaken(new ApexPages.StandardController(opp));
            pvo.updatePVOAanmaken();
        Test.stopTest();
    }
    
}