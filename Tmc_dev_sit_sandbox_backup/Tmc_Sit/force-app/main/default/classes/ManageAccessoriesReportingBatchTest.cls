/**
  * @Author:- Anuj Kumar
  * @Company-: Techmatrix Consulting
  * @Description-: Test class of ManageAccessoriesReportingBatch
  * =============================================================
  * Version   Date            Author      Modification
  * =============================================================
  * 1.0       14 APR 2020    Anuj Kumar     Intial Version
  **/
@isTest(seeAllData = false)
public class ManageAccessoriesReportingBatchTest {
    
    @testSetup 
    static void setup() {
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
		
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;
        
        string PRODUCT_NAME = 'Accessories Reporting';
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].First_Name__c = 'Test';
        oppList[0].Name = 'Enquiry';
        oppList[0].StageName = 'New';
        oppList[0].Acc_Current_Month__c = Date.newInstance(2020, 05, 21);
        oppList[0].Acc_Value_Current_Month__c= 5;
        oppList[0].Acc_Previous_Current_Month__c = Date.newInstance(2020, 03, 14);       
        oppList[0].Acc_Previous_Month__c = 4;        
        oppList[0].CloseDate = Date.newInstance(2020, 04, 20);
        oppList[0].Is_Acc_Updated__c = True;
        
        insert oppList;
        
        //Product List
        List<Product2> productList;
        productList = new list<Product2>();
        productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Name='Maruti';
       
        insert productList;
        
        Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true);        
        update standardPricebook; 
                
        //PricebookEntry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        
        insert pricebookEntryList;

        
        //OpportunityLineItem  
        List<OpportunityLineItem> oli = TestDataFactory.createOpportunityLineItem(1,oppList[0].Id,pricebookEntryList[0].Id);              
        oli[0].Quantity = 5.00;
        oli[0].Type__c = PRODUCT_NAME;
        oli[0].ServiceDate = Date.newInstance(2020, 04, 20);
        
        insert oli; 
               
    } 
    
    static testmethod void test() {        
        Test.startTest();
        Database.executeBatch(new ManageAccessoriesReportingBatch());
        Test.stopTest();
        
    }
    
    static testmethod void test1() {  
        
         string PRODUCT_NAME = 'Accessories Reporting';
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].First_Name__c = 'Test';
        oppList[0].Name = 'Enquiry';
        oppList[0].StageName = 'New';
        oppList[0].Acc_Current_Month__c = Date.newInstance(2020, 05, 21);
        oppList[0].Acc_Value_Current_Month__c= 5;
        oppList[0].Acc_Previous_Current_Month__c = Date.newInstance(2020, 03, 14);       
        oppList[0].Acc_Previous_Month__c = 4;        
        oppList[0].CloseDate = Date.newInstance(2020, 04, 20);
        oppList[0].Is_Acc_Updated__c = True;
        
        insert oppList;
        
         //Product List
        List<Product2> productList;
        productList = new list<Product2>();
        productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Name=PRODUCT_NAME;
       
        insert productList;
        
        Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true);        
        update standardPricebook;
        
        //PricebookEntry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        
        insert pricebookEntryList;
        
        List<OpportunityLineItem> oli = TestDataFactory.createOpportunityLineItem(1,oppList[0].Id,pricebookEntryList[0].Id);              
        oli[0].Quantity = 5.00;
        oli[0].Type__c = PRODUCT_NAME;
        oli[0].ServiceDate = Date.newInstance(2020, 05, 21);
        
        insert oli; 
        
        Test.startTest();
        Database.executeBatch(new ManageAccessoriesReportingBatch());
        Test.stopTest();
        
    }
       
}