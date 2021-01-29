/*
        Name            :    OpportunityTriggerTest
        Author          :    Shikha
        Date            :    05/20/2019
        Description     :    Used to test OpportunityTrigger & OpportunityTriggerHelper
*/
@istest
public class OpportunityTriggerTest{

    @isTest
    public Static void UnitTest(){
        
        
        Trigger_Settings__c settings = new Trigger_Settings__c();
           settings.Name='Default';
           settings.Account_Trigger__c=true;
           settings.AvailableSpeed_Trigger__c=true;
           settings.Bestelling_MM_Trigger__c=true;
           settings.Bestellingproduct_Trigger__c=true;
           settings.Opportunity_Trigger__c=true;
           settings.Porteringen_mobiel_Trigger__c=true;
           settings.Quote_Trigger__c=true;
           settings.VolP_Trigger__c=true;
          insert settings;
        
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
             Pricebook2Id =  pricebookId,
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
        opp.pricebook2id = pricebookId;
        insert opp;
        
        //insert quoteLineItem 
        list<Quote> quoteList = [select id, name from Quote where opportunityid =: opp.id];
        QuoteLineItem qli = new QuoteLineItem();
        qli.quoteId = quoteList[0].id;
        qli.PriceBookEntryId = pbEntry.id; 
        qli.Quantity = 5; 
        qli.Unitprice = pbEntry.UnitPrice; 
        insert qli;
   
        if(quoteList.size() > 0){
            Opp.SyncedQuoteId = quoteList[0].id;
            opp.PVO_aanmaken__c = true;
            update Opp;
        }
        
        list<quote> quoteList1 = [select id, name, IsSyncing, (select id from quotelineitems) from Quote where opportunityid =: opp.id];
        system.assertEquals(QuoteList1.size() > 0, true);
        list<quotelineitem> quoteLIList = [select id from quotelineitem where quoteid =: quoteList1[0].id];
        system.assertEquals(quoteLIList.size() > 0, true);
    
        //To test Rectordtype update
        ID GoedgeOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KPN ÉÉN Excellence Goedgekeurd').getRecordTypeId();
        ID GoedgeQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN ÉÉN Excellence Goedgekeurd').getRecordTypeId();
        opp.Recordtypeid = GoedgeOppID;
        update opp;
        
        list<opportunity> oppTestList = [select id, name, Recordtypeid, (select id, name, Recordtypeid from Quotes) from Opportunity where id =: opp.id];
        for(opportunity opps : oppTestList){
            for(quote qu : opps.quotes){
                system.assertEquals(qu.Recordtypeid, GoedgeQuoteID);
            }
        }
        
        delete opp;
    }
    
}