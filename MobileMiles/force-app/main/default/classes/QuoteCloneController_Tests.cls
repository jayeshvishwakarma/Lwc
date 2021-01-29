@isTest
private class QuoteCloneController_Tests {
    @isTest(SeeAllData=true) // required for using the standard pricebook, unfortunately
    private static void testClone() {
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Test Stage', CloseDate = Date.today(), AccountId = a.Id);
        insert o;

        Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true limit 1];

        Product2 p = new Product2(Name = 'Test Product', isActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = p.Id, UnitPrice = 1, isActive = true);
        insert pbe;

        Quote q = new Quote(Name = 'Test Quote', OpportunityId = o.Id, PriceBook2Id = pb.Id);
        insert q;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        insert qli;

        QuoteCloneController con = new QuoteCloneController(new ApexPages.StandardController(qli));
        System.assertNotEquals(null, con.doClone());
    }
}