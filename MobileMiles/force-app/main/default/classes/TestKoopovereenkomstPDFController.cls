@isTest
public class TestKoopovereenkomstPDFController{
    @isTest
    private static void test(){
        
        Account account = new Account(name='test account');
        insert account;
        
        Opportunity opp = new Opportunity(name='Opp1', accountid=account.id, StageName='WON', CloseDate=Date.today());
        insert opp;
        
        Quote quote = new Quote(name='quote1 opp1', opportunityId=opp.id,Looptijd__c = '1 jaar',heeft_verbinding__c = true);
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        
        ID verbindingRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Verbinding').getRecordTypeId();
        
        Product2 verbinding1 = new Product2(name='verbinding1', aantal_kanalen__c=8, recordtypeid=verbindingRT, isactive=true,
                            Family = 'Verbindingen', Voice_Internet__c = 'Voice + Internet',
                            SLA_Level__c = 'Standaard',
                            verbinding__c = 'verbindingpicklist1',
                            EVC__c = 'Geen EVC',
                            Router__c = 'Draytek Vigor 2760',
                            Levering_door_KPN__c = true
        );
        insert verbinding1;
        
        PriceBookEntry pbe1 = new PriceBookEntry(product2id=verbinding1.id, unitprice=10, isactive=true, pricebook2id=Test.getStandardPricebookId());
        insert pbe1;
        
        QuoteLineItem qutlineitemtest = new QuoteLineItem ();
        qutlineitemtest = new QuoteLineItem(QuoteId = quote.id , Quantity = 3.00,UnitPrice = 12 , PricebookEntryId = pbe1.id);
        insert qutlineitemtest;

        KoopovereenkomstPDFController contactController = new KoopovereenkomstPDFController ( new Apexpages.Standardcontroller( quote ) );
        contactController.getFieldsForController();
        
    }
}