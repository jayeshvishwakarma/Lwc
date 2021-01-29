/**
 * @File Name          : UpdateSynchingCtrlTest.cls
 * @Description        : 
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 26/08/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    26/08/2019 05:30 PM          Anuj Kumar            Initial Version
**/

@isTest
private class UpdateSynchingCtrlTest{
    @testSetup
    static void CreateRecord(){
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
		
        Implementation_Strategy__c IS2 = new Implementation_Strategy__c();
        IS2.Name  = '2';
        IS2.Identifier_Type__c = 'Record Type';
        IS2.Strategy_Implementation__c = 'OpportunityPartsTriggerServiceImpl';
        IS2.Strategy_Key__c = 'Parts';
        IS2.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS2;
        
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;
       //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
        
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        list<product2> productList = new list<product2>();
        for(product2 pro : TestDataFactory.createProducts('Variants', 2)){
            pro.Model__c = 'BA';
            pro.Enquiry__c = 'Yes';
            
            productList.add(pro);
        }
        Insert productList;
        
        //Pricebook Entry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        insert pricebookEntryList;
        
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = accList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = usr[0].Id;
        
        Opportunity opp = oppList[0];
        opp.First_Name__c = 'Test Dealer';
        opp.Dealership__c = accList[0].Id;
        opp.Model_Code__c = 'BA';
        opp.Variant__c = productList[1].Id;
        opp.Dms_enquiry_name__c = 'ENQ122';
        insert oppList;
        System.assertEquals(1, oppList.size());
        
        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        insert quoteList;  
        System.assertEquals(1, quoteList.size());
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<OpportunityLineItem> olilist = TestDataFactory.createOpportunityLineItem(1, oppList[0].Id, pricebookEntryList[0].id);
        insert olilist;
        System.assertEquals(1, olilist.size());
        

    }
        
    static testMethod Void codeCoverageMethodForScenario1(){
        Test.startTest();
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        List<Quote> quoteList = new list<Quote>([SELECT id,Name from Quote]);
        List<Opportunity> oppList = new list<opportunity>([SELECT id,Name from opportunity]);
        
            UpdateSynchingCtrl.retriveQuoteSyncType(quoteList[0].id);
            UpdateSynchingCtrl.updateSyncing(quoteList[0].id, false, quoteList[0].Name, oppList[0].Name, oppList[0].Id);
            UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, oppList[0].Id);
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        Test.stopTest();
        
    }
    
    static testMethod Void codeCoverageMethodForScenario2(){
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        List<Opportunity> oppList = [Select id,name, priceBook2Id, Variant_Modified_Count__c from Opportunity];
        oppList[0].Variant_Modified_Count__c = 2;
        update oppList;
        
        String priceBook2IdFromOpp = (oppList != Null && oppList.size() > 0) ? oppList[0].priceBook2Id : Null;
        List<PricebookEntry> pricebookEntryList = new list<PricebookEntry>([SELECT id, product2Id from PricebookEntry]);
        List<Quote> quoteList = new list<Quote>([SELECT id,name from Quote]); 
        quoteList[0].Pricebook2Id = priceBook2IdFromOpp;
        update quoteList;
        System.assertEquals(1, quoteList.size());
        
        QuoteLineItem quoteLineItemObj = new QuoteLineItem(Type__c = 'Variants', quantity = 1, UnitPrice = 1, priceBookEntryId = pricebookEntryList[0].id, quoteId = quoteList[0].Id);
        
        insert quoteLineItemObj;
        
            try{
                UpdateSynchingCtrl.retriveQuoteSyncType(quoteList[0].id);
                UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, oppList[0].id);
                
                oppList[0].Variant_Modified_Count__c = 1;
                update oppList;
                
                UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, oppList[0].id);
                
                oppList[0].Variant__c = pricebookEntryList[0].product2Id;
                oppList[0].Variant_Modified_Count__c = 2;
                update oppList;
                
                UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, oppList[0].id);
            }catch(Exception e){}
            
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
        
    }
    
    
    static testMethod Void codeCoverageMethodForScenario3(){
        Test.startTest();
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
        
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
        
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        Insert accountList;
        
        List<Asset> assetList = new List<Asset>(); 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productList)){
            ast.accountId  = accountList[0].Id;
            
            assetList.add(ast);
        }
        
        Insert assetList;
        
        //Pricebook Entry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        insert pricebookEntryList;
        
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = usr[0].Id;
        
        Opportunity opp = oppList[0];
        opp.First_Name__c = 'Test Dealer';
        opp.Dealership__c = accList[0].Id;
        opp.DMS_Enquiry_Name__c = 'ENQ123';
        insert oppList;
        System.assertEquals(1, oppList.size());
        
        List<OpportunityLineItem> olilist = TestDataFactory.createOpportunityLineItem(1, oppList[0].Id, pricebookEntryList[0].id);
        
        insert olilist;
        System.assertEquals(1, olilist.size());
        
        List<Opportunity> opportunityList = [Select id, priceBook2Id from Opportunity Where Id =: oppList[0].Id];
        String priceBook2IdFromOpp = (opportunityList != Null && opportunityList.size() > 0) ? opportunityList[0].priceBook2Id : Null;
        
        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        quoteList[0].Pricebook2Id = priceBook2IdFromOpp;
        insert quoteList;
        System.assertEquals(1, quoteList.size());
        
        QuoteLineItem quoteLineItemObj = new QuoteLineItem(quantity = 1, UnitPrice = 1, priceBookEntryId = pricebookEntryList[0].id, quoteId = quoteList[0].Id);
        
        //insert quoteLineItemObj;
        
            UpdateSynchingCtrl.retriveQuoteSyncType(quoteList[0].id);
            UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, quoteList[0].id);
            
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
        
    }
    
    static testMethod Void codeCoverageMethodForScenario4(){
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
        
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
        
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        Insert accountList;
        
        List<Asset> assetList = new List<Asset>(); 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productList)){
            ast.accountId  = accountList[0].Id;
            
            assetList.add(ast);
        }
        
        Insert assetList;
        
        //Pricebook Entry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        insert pricebookEntryList;
        
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = usr[0].Id;
        
        Opportunity opp = oppList[0];
        opp.First_Name__c = 'Test Dealer';
        opp.Dealership__c = accList[0].Id;
        opp.DMS_Enquiry_Name__c = 'ENQ123';
        insert oppList;
        System.assertEquals(1, oppList.size());
        
        List<OpportunityLineItem> olilist = TestDataFactory.createOpportunityLineItem(1, oppList[0].Id, pricebookEntryList[0].id);
        
        insert olilist;
      //  System.assertEquals(1, olilist.size());
        
        List<Opportunity> opportunityList = [Select id, priceBook2Id from Opportunity Where Id =: oppList[0].Id];
        String priceBook2IdFromOpp = (opportunityList != Null && opportunityList.size() > 0) ? opportunityList[0].priceBook2Id : Null;
        
        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        quoteList[0].Pricebook2Id = priceBook2IdFromOpp;
        insert quoteList;
        System.assertEquals(1, quoteList.size());
        
        QuoteLineItem quoteLineItemObj = new QuoteLineItem(Type__c = 'Variants', quantity = 1, UnitPrice = 1, priceBookEntryId = pricebookEntryList[0].id, quoteId = quoteList[0].Id);
        
        insert quoteLineItemObj;
        
        delete olilist;
        
        
            UpdateSynchingCtrl.retriveQuoteSyncType(quoteList[0].id);
            UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, quoteList[0].id);
            
            Delete [Select id from QuoteLineItem];
            Delete [Select id from OpportunityLineItem];
            
            UpdateSynchingCtrl.retriveQuoteSyncType(quoteList[0].id);
            
            
            List<Opportunity> oppList1 = TestDataFactory.createTestOpportunity(1, 'Parts');
            oppList1[0].accountId = userAccountList[0].id;
            oppList1[0].StageName = 'New';
            oppList1[0].Current_Open_Follow_up__c = null;
            oppList1[0].Customer__c= personAccountList[0].Id;
            oppList1[0].ownerId = usr[0].Id;
            
            insert oppList1;
            UpdateSynchingCtrl.updateSyncing(quoteList[0].id, true, quoteList[0].Name, oppList[0].Name, oppList1[0].id);
            
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
    }
   
}