/**
    * @Autho:- Nishant Prajapati
    * @Company-: Techmatrix Consulting
    * @Description-: Test case for OpportunityLineItemTriggerHandler class.
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       26 July 2019    Nishant     Intial Version
    **/
@isTest
public class OpportunityLineItemTriggerHandlerTest {
    static testMethod void validateUpdateFlagMethod(){
        //insert opportunity
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = userinfo.getUserId();
        
        insert oppList;
        
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
        
        //insert pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productList[0].Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        //insert opportunity line item
        system.debug('oppList>>>'+oppList.size());
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppList[0].Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 5 * pbEntry.UnitPrice
        );
        
        insert oli;
    }
}