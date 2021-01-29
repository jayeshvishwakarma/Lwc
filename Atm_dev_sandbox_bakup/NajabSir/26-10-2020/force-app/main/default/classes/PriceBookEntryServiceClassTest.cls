@isTest
public class PriceBookEntryServiceClassTest {
    @testSetup
    static void recordCreate(){
        
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
        
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        Insert accList;
        
        List<Asset> assetList = new List<Asset>(); 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productList)){
            ast.accountId  = accList[0].Id;
            
            assetList.add(ast);
        }
        
        Insert assetList;
        
        Pricebook2 pr = new Pricebook2(Name = 'Standard Price Book');
        insert pr;
    }
    
    @isTest
    static void test(){
        list<product2> productList = new list<product2>([SELECT id from product2]);
        list<Pricebook2> prlist = new list<Pricebook2>([SELECT name from Pricebook2]);
        BasicReturn br= PriceBookEntryServiceClass.createPriceBookEntry(productList, 'Standard Price Book');
        System.assertEquals('Success', br.status);
    }
    
    @isTest
    static void test2(){
        list<product2> productList = new list<product2>([SELECT id from product2]);
        BasicReturn br=PriceBookEntryServiceClass.createPriceBookEntry(productList, 'Standard');
        System.assertEquals('Failed', br.status);
    }

}