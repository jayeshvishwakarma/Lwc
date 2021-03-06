@isTest
public class TestovereenkomstController{
    static testMethod void unitTest(){
        
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
                            //Router__c = 'ZyXel SBG3300-N000',
                            Levering_door_KPN__c = true
        );
        insert verbinding1;
        
        PriceBookEntry pbe1 = new PriceBookEntry(product2id=verbinding1.id, unitprice=10, isactive=true, pricebook2id=Test.getStandardPricebookId());
        insert pbe1;
        
        QuoteLineItem qutlineitemtest = new QuoteLineItem ();
        qutlineitemtest = new QuoteLineItem(QuoteId = quote.id , Quantity = 3.00,UnitPrice = 12 , PricebookEntryId = pbe1.id);
        insert qutlineitemtest;

        EZSign__Signature__c ezSignObj = new EZSign__Signature__c(EZSign__Signature_Key__c = 'testKey');
        ezSignObj.EZSign__Parent_Id__c = quote.Id;
        insert ezSignObj ;
        
        ApexPages.StandardController std = new ApexPages.StandardController(ezSignObj);
        ApexPages.currentPage().getParameters().put('key',ezSignObj.EZSign__Signature_Key__c);
        overeenkomstController controllerObj = new overeenkomstController(std);
        
        
    }
}