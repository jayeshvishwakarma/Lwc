/*
    Name         :    ConvertQuoteLineItemCtrlTest
    Autohr       :
    Date         :    03/26/2016
    Description  :    
*/
@isTest
public class ConvertQuoteLineItemCtrlTest{
    @isTest
    private static void unitTest1(){
        string actId = createAccount();
        string oppId = createOpportunirty(actId);
        string quoteId = createQuote(oppId);
        createQuoteLineItems(quoteId);
          
        // Test Start 
        apexPages.currentPage().getParameters().put('id',quoteId);
        ConvertQuoteLineItemCtrl ctrlObj = new ConvertQuoteLineItemCtrl();
        ctrlObj.createCustomObjectRecord();
        ctrlObj.createCustomObjectRecord();
    }
    
    // Create Account
    private static string createAccount() {
        account actObj = new account();
        actObj.name = 'Test Act';
        insert actObj;
        return actObj.id;
    }
    
     // Create Opportunity
    private static string createOpportunirty(string actId) {
        Id pricebookId = Test.getStandardPricebookId();
        
        opportunity oppObj = new opportunity();
        oppObj.name = 'Test Opp';
        oppObj.StageName = 'Gewonnen van';
        oppObj.accountId = actId;
        oppObj.CloseDate = date.today().addDays(10);
        oppObj.pricebook2Id = pricebookId;
        insert oppObj;
        return oppObj.id;
    }
    
    
    
    // Create Quote
    private static string createQuote(string oppId) {
        Quote quoteObj = new Quote();
        quoteObj.name = 'Trst Quotes';
        quoteObj.OpportunityId = oppId;
        quoteObj.pricebook2Id = Test.getStandardPricebookId();
        insert quoteObj;
        return quoteObj.id;
    }
    
    private static string createProduct2() {
        //product2 prdObj = [SELECT id from product2];
        //system.debug('------prdObj:'+prdObj.id);
        //return prdObj.id;
        return null;
    }
    
    // Create QuoteLineItems
    private static string createQuoteLineItems(string quoteId) {
        list<QuoteLineItem> qliList = new list<QuoteLineItem>();
        
        
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware', ProductCode='HW');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
      
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        /*// Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice;*/
        

        
        QuoteLineItem qliObj = new QuoteLineItem();
        qliObj.quoteId = quoteId;
        qliObj.Quantity = 100;
        qliObj.UnitPrice = 100;
        qliObj.Huidige_provider__c = 'KPN';
        qliObj.X06_nummer__c = '061246789';
        qliObj.PricebookEntryId = standardPrice.Id;
        qliList.add(qliObj);
        insert qliObj;
        return null;
    }
}