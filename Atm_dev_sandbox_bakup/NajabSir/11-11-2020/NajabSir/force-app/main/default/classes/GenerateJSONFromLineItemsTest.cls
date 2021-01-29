/**
 * @File Name          : GenerateJSONFromLineItemsTest.cls
 * @Description        : This is a test class for GenerateJSONFromLineItems.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 10/10/2019 10:15 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    10/10/2019 10:15 AM          Anuj Kumar            Initial Version
**/

@isTest(seeAllData = false)
private class GenerateJSONFromLineItemsTest{
    
    @testsetup
    static void generateTempData(){
        
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
        
        List<product2> productList = new List<product2>();
        
        //Component Record type Product
        string componentProductRecordTypeName = 'Component';
        
        List<Product2> extRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        extRecords[0].Name = ConstantsUtility.EX_WARRANTY_CONST;
        productList.addAll(extRecords);
        
        List<Product2> insRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        insRecords[0].Name = ConstantsUtility.INSURANCE_CONT;
        productList.addAll(insRecords);
        
        List<Product2> loyRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        loyRecords[0].Name = ConstantsUtility.LOYALTY_CONST;
        productList.addAll(loyRecords);
        
        List<Product2> munRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        munRecords[0].Name = ConstantsUtility.MUNICIPAL_CH_CONST;
        productList.addAll(munRecords);
        
        List<Product2> numRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        numRecords[0].Name = ConstantsUtility.NUM_PLATE_CONST;
        productList.addAll(numRecords);
        
        List<Product2> roadRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        roadRecords[0].Name = ConstantsUtility.ROAD_TAX_CONST;
        productList.addAll(roadRecords);
        
        List<Product2> mcpRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        mcpRecords[0].Name = ConstantsUtility.MCP_CONST;
        productList.addAll(mcpRecords);
        
        List<Product2> otherRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        otherRecords[0].Name = ConstantsUtility.OTHER_CHARGES_CONST;
        productList.addAll(otherRecords);
        
        List<Product2> regRecords = TestDataFactory.createProducts(componentProductRecordTypeName, 1);
        regRecords[0].Name = ConstantsUtility.REGISTRATION_AMOUNT_CONST;
        productList.addAll(regRecords);
        
        //Accessories Record type Product
       
        List<Product2> regAccRecords = TestDataFactory.createProducts('Accessories', 1);
        regAccRecords[0].Name = ConstantsUtility.REGISTRATION_AMOUNT_CONST;
        productList.addAll(regAccRecords);
        
        //Offer Record type Product
        
        List<Product2> corpRecords = TestDataFactory.createProducts('Offer', 1);
        corpRecords[0].Name = ConstantsUtility.CORPORATE_DISCOUNT_CONST;
        productList.addAll(corpRecords);
        
        List<Product2> exRecords = TestDataFactory.createProducts('Offer', 1);
        exRecords[0].Name = ConstantsUtility.EXCH_BONUS_CONST;
        productList.addAll(exRecords);
        
        List<Product2> exvRecords = TestDataFactory.createProducts('Offer', 1);
        exvRecords[0].Name = ConstantsUtility.EXCH_VALUE_CONST;
        productList.addAll(exvRecords);
        
        List<Product2> oRecords = TestDataFactory.createProducts('Offer', 1);
        oRecords[0].Name = ConstantsUtility.OTHER_DISCOUNT_CONST;
        productList.addAll(oRecords);
        
        List<Product2> rRecords = TestDataFactory.createProducts('Offer', 1);
        rRecords[0].Name = ConstantsUtility.RURAL_OFFER_CONST;
        productList.addAll(rRecords);
        
        //Variant Record type Product
       
        List<Product2> variantRecords = TestDataFactory.createProducts(ConstantsUtility.VARIANT_CONST, 1);
        variantRecords[0].Name = 'Baleno';
        productList.addAll(variantRecords);
        
        
        
        insert productList;
        
        //Pricebook Entry
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        
        for(integer i = 0; i < productList.size(); i++){
            List<PricebookEntry> singleProductPrice = TestDataFactory.createPricebookEntry(1, productList[i].Id);
            pricebookEntryList.addAll(singleProductPrice);
        }
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
        insert oppList;
        System.assertEquals(1, oppList.size());
        
        List<OpportunityLineItem> olilist = new List<OpportunityLineItem>();
        
        for(Integer i = 0; i< pricebookEntryList.size(); i++){
            List<OpportunityLineItem> singleOppLineRec = TestDataFactory.createOpportunityLineItem(1, oppList[0].Id, pricebookEntryList[i].id);
            olilist.addAll(singleOppLineRec);
        }
        
        insert olilist;
    }
    
    static testMethod Void codeCoverageMethodForScenario1(){
        Test.startTest();
        
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity]);
        
        GenerateJSONFromLineItems.generateJSONForEnquiry(oppList[0].Id);
        
        Test.stopTest();
    }
    
}