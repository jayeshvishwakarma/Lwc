/**
* @File Name : PartLineItemCtrlTest.cls
* @Description :
* @Author : Anuj Kumar
* @Group :
* @Last Modified By : Anuj Kumar
* @Last Modified On : 04/09/2020
* @Modification Log :
*==============================================================================
* Ver Date Author Modification
*==============================================================================
* 1.0 04/09/2020 12:30 PM Anuj Kumar Initial Version
**/

@isTest(seeAllData = false)
private class PartLineItemCtrlTest{
    static List<Product2> productList;
    @testsetup
    static void testrecordcreate() {
        
        // Custom Setting
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

        //Product List
        productList = new list<Product2>();
        productList = TestDataFactory.createProducts('Parts', 1);

        Insert productList;

        //Pricebook Entry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        insert pricebookEntryList;


        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Parts');
        oppList[0].StageName = 'New';
        insert oppList;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId = oppList[0].Id;
        oli.quantity = 1;
        oli.unitprice = 1;
        oli.priceBookEntryId = pricebookEntryList[0].Id;
        oli.DMS_Acc_Cust_Serv__c = 'Y';

        insert oli;


        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        insert quoteList;

    }
    
    static testMethod Void checkPartLineItemDetails() {
        Test.startTest();
            List<Opportunity> oppList = [Select id, Name, Variant__c, Pricebook2Id, Email__c, Mobile__c from Opportunity limit 1];
            
            PartLineItemCtrl.getPartLineItemDetails(oppList[0].id);
            
            String recordData = '[{"Id":"01t7F000007m2ZXQAY","Name":"BCK CUSHON-GREGE","quantity":"1","ProductCode":"990J0M999L2-130","Status__c":"Open","price":960,"unitPrice":960,"priceBookEntryId":"01u7F0000090DWFQA2"}]';
            
            PartLineItemCtrl.ceratePartLineItemDetails(recordData, oppList[0].id, JSON.serialize(oppList[0]), 'Opportunity', false, 100);
            
        Test.stopTest();
    }
    
    
    static testMethod Void checkPartCreateLineItemDetails() {
        Test.startTest();
            list<Product2> productList = TestDataFactory.createProducts('Offer', 1);
            productList[0].Name = 'Offer';
            Insert productList;
            
            List<Opportunity> oppList = [Select id, Name, Variant__c, Pricebook2Id, Email__c, Mobile__c from Opportunity limit 1];
            
            PartLineItemCtrl.getPartLineItemDetails(oppList[0].id);
            
            String recordData = '[{"Id":"01t7F000007m2ZXQAY","Name":"BCK CUSHON-GREGE","quantity":"1","ProductCode":"990J0M999L2-130","Status__c":"Open","price":960,"unitPrice":960,"priceBookEntryId":"01u7F0000090DWFQA2"}]';
            
            PartLineItemCtrl.ceratePartLineItemDetails(recordData, oppList[0].id, JSON.serialize(oppList[0]), 'Quote', false, 100);
            
        Test.stopTest();
    }
    
}