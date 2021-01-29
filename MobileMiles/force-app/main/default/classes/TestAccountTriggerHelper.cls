/**
    Name           :   TestAccountTriggerHelper
    Author         :   iBirds Services
    Date           :   27 May, 2019
    Description    :   This is a test class of AccountTriggerHelper Class.
**/
@isTest
public class TestAccountTriggerHelper{
      //created on 27May 2019 by shikha
      @testSetup static void dataSetup(){
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
          Account acc = new Account(Name = 'Test Co.',
                                  RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId(),
                                  Rechtsvorm__c = 'BV', KvK_nummer__c = '25364837', Producttype_ISRA_check__c = 'xDSL', IsraSpecification__c = '001',
                                  Phone = '0486-414395', Voornaam_CP__c = 'Piet', Achternaam_CP__c = 'Pietersen', E_mailadres_bedrijf__c = 'piet@testco.co',
                                  Huisnummer__c = '4', ShippingPostalCode = '5371MJ', ShippingStreet = 'De Heinen 4', ShippingCity = 'Huisseling',
                                  Aantal_mobiele_profielen__c = 3, Huisnummer_toevoeging__c = 'a', Isra_Check__c = false);
          insert acc;
       
      }
    
      @isTest
      static void testUnit(){ 
          List<Account> accountlist = [SELECT Id, ISRA_Check__c, Producttype_ISRA_check__c, Connectivity_portfolio__c, ShippingPostalCode, Huisnummer__c, Huisnummer_toevoeging__c, Cleaned_phone__c, IsraSpecification__c FROM Account];  
          
          Test.startTest();
            Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'ZipCode Check', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 50);
            insert lastBatch;
            AccountTriggerHelper.isZipCodeCheckCalled = false;
      
            accountlist[0].Connectivity_portfolio__c = 'SMB';
            accountlist[0].Check_Beschikbaarheid__c = true;
            update accountlist[0];
            
            list<Available_Supplier__c> supplierList = [select id, Account__c from Available_Supplier__c where Account__c =: accountlist[0].id];
            
            if(supplierList.size() > 0){
                list<Available_Speed__c> speedList = [select id, Available_Supplier__c from Available_Speed__c where Available_Supplier__c =: supplierList[0].id];    
                if(speedList.size() > 0){
                    system.assertEquals(speedList[0].Available_Supplier__c, supplierList[0].id);
                }
            }
            
        Test.stopTest();
    }
    
    @isTest static void testUnit1(){
        List<Account> accountlist = [SELECT Id, ISRA_Check__c, Producttype_ISRA_check__c, ShippingPostalCode, Huisnummer__c, Huisnummer_toevoeging__c, Cleaned_phone__c, IsraSpecification__c FROM Account];
        
        Test.startTest();
            accountlist[0].Isra_Check__c = true;
            Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'ISRA Check', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 50);
            insert lastBatch;
            AccountTriggerHelper.isISRACheckCalled = false;
            update accountlist[0];
        Test.stopTest();
    }
    
    @isTest
    static void testUnit2(){   
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
        
        delete a;
     }
}