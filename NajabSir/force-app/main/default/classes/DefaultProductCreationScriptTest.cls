@isTest
public class DefaultProductCreationScriptTest {
    @testSetup
    static void createRecoord(){
      StandardPriceBookId__c lsPB = new StandardPriceBookId__c();
        lsPB.PriceBookId__c = Test.getStandardPricebookId();
        insert lsPB;  
    }
    @isTest
    Static void Test(){
        test.startTest();
        DefaultProductCreationScript.createDefaultProductsRecord();
        list<product2> prolist = new list<product2>([SELECT id from product2]);
        System.assertEquals(19, prolist.size());
        list<PricebookEntry> priceList = new list<PricebookEntry>([SELECT id from PricebookEntry]);
        System.assertEquals(19, priceList.size());
        test.stopTest();
    }
}