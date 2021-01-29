@isTest(seeAllData = false)
public class BookingBCRFormPDFControllerTest {
    @testSetup
    static void recordCreation(){
        
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
        
        list<PricebookEntry> priceBooklist = TestDataFactory.createPricebookEntry(1,productList[0].Id);
        insert priceBooklist;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        opplist[0].Model_Code__c = 'BA';
        opplist[0].Receipt_Details__c = 'test';
        insert opplist;
       
        list<OpportunityLineitem> oppLineItemlist = TestDataFactory.createOpportunityLineItem(1,opplist[0].Id,priceBooklist[0].Id);
        for(OpportunityLineitem opp : oppLineItemlist){
            opp.Type__c = 'Variants';
            opp.Product2Id = productList[0].id;
        }
        insert oppLineItemlist;
    }
    
    @istest
    static void testRegisterTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Registration';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm2 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Registration');
        test.stopTest();
    }
    @istest
    static void testExtendedWarrantyTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Extended Warranty';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm2 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Extended Warranty');
        test.stopTest();
    }
    @istest
    static void testMCPTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'MCP';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm2 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'MCP');
        test.stopTest();
    }
    @istest
    static void testAccessoriesTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Accessories';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Accessories');
        test.stopTest();
    }
    @istest
    static void testLoyaltyTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Loyalty';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Loyalty');
        test.stopTest();
    }
    @istest
    static void testMunicipalChargesTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Municipal Charges';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Municipal Charges');
        test.stopTest();
    }
    
    @istest
    static void testOfferTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Offer';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Offer');
        test.stopTest();
    }
    
    @istest
    static void testSchemesTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        BookingBCRFormPDFController bcrForm = new BookingBCRFormPDFController();
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Type__c = 'Schemes';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].type__c, 'Schemes');
        test.stopTest();
    }
    
    @istest
    static void testExchangeBonusTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        for(product2 prod: productList){
            prod.Name = 'Exchange Bonus';
        }
        update productList;
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Product2.Name = 'Exchange Bonus';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].Product2.Name, 'Exchange Bonus');
        test.stopTest();
    }
    
    @istest
    static void testOtherDiscountsTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        for(product2 prod: productList){
            prod.Name = 'Other Discounts';
        }
        update productList;
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Product2.Name = 'Other Discounts';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].Product2.Name, 'Other Discounts');
        test.stopTest();
    }
    @istest
    static void testRoadTaxsTypeField(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<OpportunityLineitem> oppLineItemlist = new list<OpportunityLineitem>([Select type__c,TotalPrice,Product2.Name,ProductCode,Quantity,
                                                                                   UnitPrice from OpportunityLineItem 
                                                                                   where OpportunityId =:opplist[0].id]);
       list<product2> productList = new list<product2>([SELECT Name from product2]);
      
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        
        for(product2 prod: productList){
            prod.Name = 'Road Tax';
        }
        update productList;
        for(OpportunityLineitem opl : oppLineItemlist){
            opl.Product2.Name = 'Road Tax';
        }
        update oppLineItemlist;
        BookingBCRFormPDFController bcrForm6 = new BookingBCRFormPDFController();
        System.assertEquals(oppLineItemlist[0].Product2.Name, 'Road Tax');
        test.stopTest();
    }
    
    
    
    
   @isTest
    static void saveAndSend(){
         test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        BookingBCRFormPDFController.downloadBCRDocument(opplist[0].id,ConstantsUtility.BTN_LABEL_CONST,'BookingBCRFormPDF','Booking Confirmation Report','Send_BCR_Time__c','');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
         
         test.stopTest();
    }
    
    @isTest
    static void CheckExisting(){
        test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<Contentversion> contlist =  TestDataFactory.createContentversion(1);
        insert contlist;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=opplist[0].id;  
        contentlink.ShareType= 'I';               
        contentlink.ContentDocumentId=[select Id,ContentDocumentId from ContentVersion WHERE Id =:contlist[0].Id].ContentDocumentId;
        insert contentlink;
        
        BookingBCRFormPDFController.downloadBCRDocument(opplist[0].id,ConstantsUtility.BTN_LABEL_CONST,'Delivery','Delivery Checklist','Delivery_Checklist_Time__c','');
        test.stopTest();
     }
    
     @isTest
    static void updateSendBCRTimeonOppTest(){
     test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        BookingBCRFormPDFController.updateSendBCRTimeonOpp(opplist[0].id); 
         test.stopTest();
    }
}