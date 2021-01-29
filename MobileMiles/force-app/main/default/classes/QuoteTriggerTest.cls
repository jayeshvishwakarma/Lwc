/**
    Name           :   QuoteTriggerTest
    Author         :   iBirds Services
    Date           :   27 May, 2019
    Description    :   This is a test class of AccountTriggerHelper Class.
**/
@isTest
public class QuoteTriggerTest{
      //created on 27 May 2019 by shikha
      @isTest
      static void testUnit1(){ 
          
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

        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Test Stage', CloseDate = Date.today(), AccountId = a.Id);
        insert o;

        Id pb = Test.getStandardPricebookId();

        Product2 p = new Product2(Name = 'Test Product', isActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb, Product2Id = p.Id, UnitPrice = 1, isActive = true);
        insert pbe;
        
        ID Tele2GoedQuotID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Tele2 Goedgekeurd').getRecordTypeId();
        Quote q = new Quote(Name = 'Test Quote', OpportunityId = o.Id, PriceBook2Id = pb, Recordtypeid = Tele2GoedQuotID);
        insert q;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        insert qli;

        Porteringen_mobiel__c PorteringenmobielRecord = new Porteringen_mobiel__c(Name='Nieuw', Offerte__c = q.Id, Type_aanvraag__c = 'Portering', IRMA_Id__c = '1234');
        insert PorteringenmobielRecord;
        
        //Porteringen_mobiel__c PorteringenmobielRecord1 = new Porteringen_mobiel__c(Name='Nieuw1', Offerte__c = q.Id, Type_aanvraag__c = 'Nieuw nummer', IRMA_Id__c = '1235', Voorgaande_order__c = PorteringenmobielRecord.id);
        //insert PorteringenmobielRecord1;
        
        ID kpnGoedQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN KleinZakelijk Goedgekeurd').getRecordTypeId();
        q.Recordtypeid = kpnGoedQuoteID;
        q.Porteergegevens_ophalen__c = true;
        update q;
        
        ID kpnGoedPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('KPN KleinZakelijk Goedgekeurd').getRecordTypeId();
        list<Quote> quoteTestList = [select id, name, Recordtypeid, (select id, name, Recordtypeid from Porteringen_mobiel__r) from Quote where id =: q.id];
        for(Quote qu : quoteTestList){
            for(Porteringen_mobiel__c pm : qu.Porteringen_mobiel__r){
                system.assertEquals(pm.Recordtypeid, kpnGoedPortMobID);
            }
        }

        delete q;
      }
}