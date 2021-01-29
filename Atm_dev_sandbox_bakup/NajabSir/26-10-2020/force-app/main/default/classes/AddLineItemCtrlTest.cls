/**
* @File Name          : AddLineItemCtrlTest.cls
* @Description        :
* @Author             : Anuj Kumar
* @Group              :
* @Last Modified By   : Anuj Kumar
* @Last Modified On   : 20/08/2019 12:30 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    20/08/2019 12:30 PM          Anuj Kumar            Initial Version
**/

@isTest(seeAllData = false)
private class AddLineItemCtrlTest{
    static List<Product2> productList;
   
   
    @testsetup
    static void testrecordcreate(){
       
        //Product List
        productList = new list<Product2>();
        productList = TestDataFactory.createProducts('Variants', 1);
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
       
        //Component Record type Product
        List<Product2> componentRecords = TestDataFactory.createProducts('Component', 5);
        insert componentRecords;
       
        // Other Charges Product
        List<Product2> otherChargesProduct = TestDataFactory.createProducts('Component', 1);
        otherChargesProduct[0].Name = 'Other Charges';
        insert otherChargesProduct;
       
        // Offer Products
        List<Product2> offerProduct = TestDataFactory.createProducts('Offer', 1);
        offerProduct[0].Start_Date__c = system.today().addDays(-5);
        offerProduct[0].Fuel_Type__c = 'PET';
        offerProduct[0].For_Code__c = '3L';
        offerProduct[0].Model__c = 'BA';
        offerProduct[0].Scheme_Regiom__c = 'C1';
        offerProduct[0].State__c  = 'DL';
       
        insert offerProduct;
       
       
        // Accessory Discount Product
        List<Product2> accessoryDiscountProduct = TestDataFactory.createProducts('Accessories', 1);
        accessoryDiscountProduct[0].Name = 'Accessory Discount';
        insert accessoryDiscountProduct;
       
        // Create Corporate
        List<Corporate__c> corList = TestDataFactory.createCorporate(1);
        insert corList;
       
        // Scheme Master Data For Exchange Bonus
        List<Scheme_Master__c> smList1 = TestDataFactory.createSchemeMaster(1, 'Exchange Bonus');
        insert smList1;
       
        // Scheme Master Data For Scheme
        List<Scheme_Master__c> smList2 = TestDataFactory.createSchemeMaster(2, 'Scheme');
        insert smList2;
       
        //Color List
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        colorList[0].Color_Type__c = 'NM';
        insert colorList;
       
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
       
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
       
        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
       
        //MCP Master Creation
        List<MCP_Master__c> mcpMasterList = TestDataFactory.createMCPMaster(1);
        insert mcpMasterList;
       
        //User Creation
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
       
        oppList[0].Sales_Type__c = 'IND';
        oppList[0].First_Name__c = 'Test Enquiry';
        oppList[0].Exchange_Model__c = 'BA';
        oppList[0].Employer_Name__c = corList[0].Id;
        oppList[0].Dealership_Channel__c = 'Nexa';
       
        insert oppList;
       
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId = oppList[0].Id;
        oli.quantity = 1;
        oli.unitprice = 1;
        oli.priceBookEntryId = pricebookEntryList[0].Id;
       
        insert oli;
       
       
        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        insert quoteList;
       
        OtherAmountValidation__c amountValidation = TestDataFactory.createQuoteAmountValidation(10000);
        insert amountValidation;
        
    }
   
   
   
   
    static testMethod Void codeCoverageMethodForScenario1(){
        Test.startTest();
        //Query Product
        List<Product2> tempProduct = [SELECT id FROM Product2 WHERE Recordtype.Name!='Component'];
        // CLASS METHOD
        AddLineItemCtrl.retriveModelVarient('Ciaz', 'Ciaz');
        AddLineItemCtrl.retriveModelVarient('Ciaz', '');
        AddLineItemCtrl.retriveModelVarient('', '');
       
        //Query Colors
        List<Color_Variant_Master__c> colorList = [SELECT id,Color_Type__c FROM Color_Variant_Master__c];
        System.assertEquals(1, colorList.size());
       
        // CLASS METHOD
        AddLineItemCtrl.retriveColorVarient('');
        AddLineItemCtrl.retriveColorVarient(tempProduct[0].Id);
       
       
        List<Account> accList = [SELECT Id FROM Account WHERE recordtype.name=:'Dealer'];
       
        List<Opportunity> oppList = [SELECT Id, StageName, Sales_Type__c FROM Opportunity];
        Opportunity opp = oppList[0];
        opp.Dealership__c = accList[0].Id;
       
        System.assertEquals(1, oppList.size());
       
        List<For_Code__c> forCodeList = [SELECT Id FROM For_Code__c ];
       
        List<Price_Master__c> priceMasterList = TestDataFactory.createPriceMaster(1, tempProduct[0].Id, forCodeList[0].Id);
        insert priceMasterList;
        System.assertEquals(1, priceMasterList.size());
       
        List<PriceBookEntry> pbe = [SELECT Id FROM PriceBookEntry];
        System.assertEquals(1, pbe.size());
       
        List<Scheme_Master__c> smList = [SELECT Id, discount_amount__c FROM Scheme_Master__c];
       
        String json = '{"enquiryRecordType":"Vehicle Sales","accessoriesValidAmount":100000,"otherValidAmount":100000,"headerValue":["Customer Name : ADNAN ARNAV DANE","DMS Enquiry Number : ENQ 00012","Variant Name : BALENO ALTURA M"],"addComponent":[{"label":"Extended Warranty","value":"1000","isChecked":true,"isExchangedWarrenty":true,"showLabel":false,"isDisabled":true,"year":"1 year","showCheckBox":false},{"label":"Loyalty","value":3000,"isChecked":true,"showLabel":true,"isDisabled":true,"showCheckBox":true},{"label":"Insurance","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Municipal Charges","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Number Plate Charges","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Road Tax","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"MCP","value":1200,"isChecked":true,"isMCP":true,"showLabel":false,"isDisabled":true,"packageValue":"Economy","validityValue":"4 Yrs - 40000 KMs","showCheckBox":false,"amount":0}],"addAccessories":[{"Name":"Fog Lights","quantity":"1","Id":"01t0k000005R2QzAAK","Minimum_Quantity__c":1,"Maximum_Quantity__c":15,"price":8000,"unitPrice":8000,"priceBookEntryId":"01u0k000003KoxJAAS"}],"opportunityInfo":{"Name":"ADNAN   DANE (Car)","Pricebook2Id":"01s7F00000BI0N7QAL","Email__c":"hdalal.mirum@gmail.com","Mobile__c":"919821258774","StageName":"New"},"otherAccessoriesDiscount":{"opporrtunityId":null,"Quantity":1,"UnitPrice":"2000","priceBookEntryId":null},"selectedVariant":{"Id":"01t0k0000051AVRAA2","Name":"BALENO ALTURA M","Extended_Warranty_1_year__c":1000,"Extended_Warranty_2_year__c":1500,"Extended_Warranty_3_year__c":2000,"Loyalty_Amount__c":3000,"Fuel_Type__c":"Petrol","Family":"BALENO"},"selectedColorVariant":{"Id":"a070k000008D4O7AAK","Name":"SUPERIOR WHITE","Color_Code__c":"26U","Variant__c":"01t0k0000051AVRAA2","Color_Type__c":"NM","Variant__r":{"ProductCode":"ER4CD4","Id":"01t0k0000051AVRAA2"}},"otherCharge":{"opporrtunityId":null,"Quantity":1,"UnitPrice":0,"priceBookEntryId":null},"registrationAmountVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"5000","Quantity":1,"opporrtunityId":"'+oppList[0].Id+'","registerId":"00k0k000005IDD7AAO"},"exShowRoomVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"537850.00","Quantity":1,"opporrtunityId":"'+oppList[0].Id+'","exShowId":"00k0k000005IDD5AAO"},"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","employerName":"INDO TECH TRANSFORMERS\u00a0LTD","corporateDiscountValue":false,"exchangeBonusValue":false,"exchangeValue":false,"ruralOffersValue":true,"otherDiscountValue":true,"OfferData":0,"exchangeData":0,"exchangeBonusData":0,"corporateDiscountData":0,"ruralDiscountData":3500,"otherDiscountData":3500,"financeAmountData":"350000","cashPaymentData":192850,"schemeCode":"SS000000AK0319190472","offersText":null}}';
       
        // CLASS METHOD
        AddLineItemCtrl.retriveExShowroomPrice(tempProduct[0].Id, forCodeList[0].Id, 'NM', opp.Sales_Type__c);
        
        PriceBook2 pb2 = new PriceBook2(Id = test.getStandardPriceBookId(), IsActive = true);
        update pb2;
        
        // CLASS METHOD
        AddLineItemCtrl.fetchVariantProducts(tempProduct[0].Id);
       
        // CLASS METHOD
        AddLineItemCtrl.retriveOpportunityAmount(opp.Id);
        AddLineItemCtrl.retriveEnqModelList(opp.Id);
       
        AddLineItemCtrl.retriveConsumerOffer('3L', 'PET', 'BA', 'C1', 'DL', 'ER4CD4');
       
        //insert Accessories products
        List<Product2> accessoriesProducts= TestDataFactory.createProducts('Accessories', 1);
        insert accessoriesProducts;
         
       
        //PricebookEntry
        List<PricebookEntry> accessoriesPricebookEntryList = TestDataFactory.createPricebookEntry(1, accessoriesProducts[0].Id);
        insert accessoriesPricebookEntryList;
       
        // MCP Master Data List
        List<MCP_Master__c> mcpMasterList = [Select id, Amount__c, From_Date__c, Fuel_Type__c, Package_Description__c, Package_Validity__c, To_Date__c from MCP_Master__c];
       
        AddLineItemCtrl.getAccessories('Accessories Sales','Ciaz', 'Ciaz', 'Name');
        AddLineItemCtrl.getAccessories('Accessories Sales','Ciaz', 'Ciaz', 'Code');
        AddLineItemCtrl.getAccessoryPrice(accessoriesProducts[0].Id);
        AddLineItemCtrl.queryLineItemDetail(oppList[0].id, 'Opportunity');
        AddLineItemCtrl.getOtherAmount();
       
        AddLineItemCtrlHelper.fetchMCPAmount('Economy', '2Yrs or 20000 KMs', 'Petrol');
       
        AddLineItemCtrlHelper.generateQuotation(json);
       
        AddLineItemCtrl.retriveOffersSchemes(json);
       
        // FOR accessories product and price else case
        delete accessoriesProducts;
        AddLineItemCtrl.getAccessories('Accessories Sales','Ciaz', 'Ciaz', 'Name');
        AddLineItemCtrl.getAccessoryPrice(accessoriesPricebookEntryList[0].Id);
       
        Test.stopTest();
    }
   
   
    static testMethod void testCreate2(){
        List<Product2> prodList = [SELECT Id FROM Product2 WHERE Recordtype.Name=:'Component'];
       
        set<String> tempSet = new set<String>();
        for(Product2 pr : prodList){
            tempSet.add(pr.id);
        }
       
        AddLineItemCtrl.createChildSObjectInstance('Opportunity');
       
        List<Opportunity> oppList = [SELECT Id,Line_Item_Summary__c FROM Opportunity];
       
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
       
        system.debug('== oppList From testCreate2 '+oppList);
       
        List<PriceBookEntry> pbe = [SELECT Id FROM PriceBookEntry];
       
        system.debug('pbe---->'+pbe);
       
        List<Scheme_Master__c> smList = [SELECT Id, discount_amount__c FROM Scheme_Master__c];
       
        String json = '{"addSchemes":{"objROfferId":"00k0k000005IDDHAA4","offersText":null,"schemeCode":"SS000000AK0319190472","cashPaymentData":92850,"financeAmountData":"450000","otherDiscountData":null,"ruralDiscountData":3500,"corporateDiscountData":null,"exchangeBonusData":0,"exchangeData":null,"OfferData":null,"otherDiscountValue":true,"ruralOffersValue":true,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true},"registrationAmountVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"5000","Quantity":1,"opporrtunityId":"'+oppList[0].Id+'","registerId":"00k0k000005IDD7AAO"},"exShowRoomVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"537850.00","Quantity":1,"opporrtunityId":"'+oppList[0].Id+'","exShowId":"00k0k000005IDD5AAO"},"selectedColorVariant":{"Variant__r":{"Id":"01t0k0000051AVRAA2","ProductCode":"ER4CD4"},"Color_Type__c":"NM","Variant__c":"01t0k0000051AVRAA2","Color_Code__c":"26U","Name":"SUPERIOR WHITE","Id":"a070k000008D4O7AAK"},"selectedVariant":{"Loyalty_Amount__c":500,"Extended_Warranty_3_year__c":2000,"Extended_Warranty_2_year__c":1500,"Extended_Warranty_1_year__c":1000,"Name":"BALENO ALTURA M","Id":"01t0k0000051AVRAA2"},"addAccessories":[{"priceBookEntryId":"01u0k000003KoxEAAS","unitPrice":2000,"price":4000,"Maximum_Quantity__c":5,"Minimum_Quantity__c":1,"Id":"01t0k000005R2QpAAK","quantity":"2","Name":"Car Stereo 4","accId":"00k0k000005IDD6AAO"}],"addComponent":[{"isDisabled":true,"showLabel":false,"isExchangedWarrenty":true,"isChecked":true,"value":"1000","label":"Extended Warranty","comId":"00k0k000005IDDGAA4"},{"isDisabled":true,"showLabel":true,"isChecked":true,"value":500,"label":"Loyalty","comId":"00k0k000005IDD8AAO"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"2500","label":"Insurance","comId":"00k0k000005IDD9AAO"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"","label":"Municipal Charges"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"","label":"Number Plate Charges"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"","label":"Road Tax"},{"validityValue":"2 Yrs - 20000 KMs","packageValue":"Economy","isDisabled":false,"showLabel":true,"isMCP":true,"isChecked":true,"value":"2000","label":"MCP","comId":"00k0k000005IDDAAA4"}],"headerValue":["Customer Name : ADNAN F DANE","DMS Enquiry Number : ENQ 00012","Variant Name : BALENO ALTURA M"]}';
        AddLineItemCtrl.queryLineItemDetail(oppList[0].id, 'Opportunity');  
       
        AddLineItemCtrl.createLineItemRecords(json, oppList[0].id);
       
        AddLineItemCtrl.retriveOffersSchemes(json);
       
    }
   
    static testMethod void testCreate3(){
        List<Product2> prodList = [SELECT Id FROM Product2 WHERE Recordtype.Name=:'Component'];
       
        set<String> tempSet = new set<String>();
        for(Product2 pr : prodList){
            tempSet.add(pr.id);
        }
       
        AddLineItemCtrl.createChildSObjectInstance('Quote');  
       
        List<Opportunity> oppList = [SELECT Id,Line_Item_Summary__c FROM Opportunity];
       
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
       
        system.debug('== oppList From testCreate2 '+oppList);
       
        List<Scheme_Master__c> smList = [SELECT Id, discount_amount__c FROM Scheme_Master__c];
       
        List<PriceBookEntry> pbe = [SELECT Id FROM PriceBookEntry];
       
        String json = '{"addSchemes":{"objROfferId":"00k0k000005IDDHAA4","offersText":null,"schemeCode":"SS000000AK0319190472","cashPaymentData":92850,"financeAmountData":"450000","otherDiscountData":null,"ruralDiscountData":3500,"corporateDiscountData":null,"exchangeBonusData":0,"exchangeData":null,"OfferData":null,"otherDiscountValue":true,"ruralOffersValue":true,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true},"registrationAmountVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"5000","Quantity":1,"opporrtunityId":"'+oppList[0].Id+'","registerId":"00k0k000005IDD7AAO"},"exShowRoomVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"537850.00","Quantity":1,"opporrtunityId":"'+oppList[0].Id+'","exShowId":"00k0k000005IDD5AAO"},"selectedColorVariant":{"Variant__r":{"Id":"01t0k0000051AVRAA2","ProductCode":"ER4CD4"},"Color_Type__c":"NM","Variant__c":"01t0k0000051AVRAA2","Color_Code__c":"26U","Name":"SUPERIOR WHITE","Id":"a070k000008D4O7AAK"},"selectedVariant":{"Loyalty_Amount__c":500,"Extended_Warranty_3_year__c":2000,"Extended_Warranty_2_year__c":1500,"Extended_Warranty_1_year__c":1000,"Name":"BALENO ALTURA M","Id":"01t0k0000051AVRAA2"},"addAccessories":[{"priceBookEntryId":"01u0k000003KoxEAAS","unitPrice":2000,"price":4000,"Maximum_Quantity__c":5,"Minimum_Quantity__c":1,"Id":"01t0k000005R2QpAAK","quantity":"2","Name":"Car Stereo 4","accId":"00k0k000005IDD6AAO"}],"addComponent":[{"isDisabled":true,"showLabel":false,"isExchangedWarrenty":true,"isChecked":true,"value":"1000","label":"Extended Warranty","comId":"00k0k000005IDDGAA4"},{"isDisabled":true,"showLabel":true,"isChecked":true,"value":500,"label":"Loyalty","comId":"00k0k000005IDD8AAO"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"2500","label":"Insurance","comId":"00k0k000005IDD9AAO"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"","label":"Municipal Charges"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"","label":"Number Plate Charges"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"","label":"Road Tax"},{"validityValue":"2 Yrs - 20000 KMs","packageValue":"Economy","isDisabled":false,"showLabel":true,"isMCP":true,"isChecked":true,"value":"2000","label":"MCP","comId":"00k0k000005IDDAAA4"}],"headerValue":["Customer Name : ADNAN F DANE","DMS Enquiry Number : ENQ 00012","Variant Name : BALENO ALTURA M"]}';
        AddLineItemCtrl.queryLineItemDetail(oppList[0].id, 'Opportunity');  
       
        AddLineItemCtrl.createLineItemRecords(json, '');
       
        AddLineItemCtrl.retriveOffersSchemes(json);
       
    }
       
    static testMethod void testCreate4(){
        List<Product2> prodList = [SELECT Id FROM Product2 WHERE Recordtype.Name=:'Component'];
       
        set<String> tempSet = new set<String>();
        for(Product2 pr : prodList){
            tempSet.add(pr.id);
        }
       
        AddLineItemCtrl.createChildSObjectInstance('Quote');  
       
        List<Quote> oppList = [SELECT Id,Line_Item_Summary__c FROM Quote];
       
        List<Scheme_Master__c> smList = [SELECT Id, discount_amount__c FROM Scheme_Master__c];
       
        List<PriceBookEntry> pbe = [SELECT Id FROM PriceBookEntry];
       
        system.debug('pbe---->'+pbe);
       
        //String json = '{"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","offersText":null,"schemeCode":null,"cashPaymentData":445500,"financeAmountData":"450000","otherDiscountData":1500,"ruralDiscountData":1100,"corporateDiscountData":1200,"exchangeBonusData":15000,"exchangeData":50000,"OfferData":1500,"otherDiscountValue":true,"ruralOffersValue":false,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true,"employerName":null},"registrationAmountVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"5000","Quantity":1},"exShowRoomVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":890500,"Quantity":1,"opporrtunityId":"'+oppList[0].Id+'"},"otherCharge":{"Description":"Test Data","priceBookEntryId":null,"UnitPrice":1200,"Quantity":1,"opporrtunityId":null},"selectedColorVariant":{"Id":"a070k000008D59IAAS","Name":"SILKY SILVER","Color_Code__c":"Z2S","Variant__c":"01t0k0000051AfjAAE","Color_Type__c":"M","Variant__r":{"ProductCode":"R3RCCS1","Id":"01t0k0000051AfjAAE"}},"selectedVariant":{"Name":"MARUTI ERTIGA GREEN LXI","Family":"ERTIGA","Loyalty_Amount__c":1300,"Fuel_Type__c":"CNG","Extended_Warranty_1_year__c":2000,"Extended_Warranty_2_year__c":2500,"Extended_Warranty_3_year__c":3000,"Id":"01t0k0000051AfjAAE"},"otherAccessoriesDiscount":{"priceBookEntryId":null,"UnitPrice":0,"Quantity":1,"opporrtunityId":null},"opportunityInfo":{"Model_Code__c":"R3","Amount":900800,"StageName":"New","Mobile__c":"9212768885","Email__c":"","Pricebook2Id":"01s7F00000BI0N7QAL","Name":"VIPIN DOGRA (Car)"},"addAccessories":[{"Id":"01t0k000005R2QpAAK","Name":"Car Stereo 4","quantity":"1","Minimum_Quantity__c":1,"Maximum_Quantity__c":5,"price":3500,"unitPrice":3500,"priceBookEntryId":"01u0k000003KoxEAAS"}],"addComponent":[{"label":"Extended Warranty","value":2000,"isChecked":true,"isExchangedWarrenty":true,"showLabel":false,"isDisabled":true,"year":"1 year","showCheckBox":false},{"label":"Loyalty","value":1300,"isChecked":true,"showLabel":true,"isDisabled":true,"showCheckBox":true},{"label":"Insurance","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Municipal Charges","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"FASTag charges","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Road Tax","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"MCP","value":0,"isChecked":true,"isMCP":true,"showLabel":false,"isDisabled":true,"packageValue":"Economy","validityValue":"4 Yrs - 40000 KMs","showCheckBox":false,"amount":0}],"headerValue":["Customer Name : VIPIN RAJU DOGRA","","Variant Name : MARUTI ERTIGA GREEN LXI"],"otherValidAmount":100000,"accessoriesValidAmount":100000,"enquiryRecordType":"Vehicle Sales"}';
        String json = '{"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","offersText":null,"schemeCode":null,"cashPaymentData":445500,"financeAmountData":"450000","otherDiscountData":1500,"ruralDiscountData":1100,"corporateDiscountData":1200,"exchangeBonusData":15000,"exchangeData":50000,"OfferData":1500,"otherDiscountValue":true,"ruralOffersValue":false,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true,"employerName":null},"registrationAmountVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"5000","Quantity":1},"exShowRoomVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":890500,"Quantity":1,"opporrtunityId":"'+oppList[0].Id+'"},"otherCharge":{"Description":"Test Data","priceBookEntryId":null,"UnitPrice":1200,"Quantity":1,"opporrtunityId":null},"selectedColorVariant":{"Id":"a070k000008D59IAAS","Name":"SILKY SILVER","Color_Code__c":"Z2S","Variant__c":"01t0k0000051AfjAAE","Color_Type__c":"M","Variant__r":{"ProductCode":"R3RCCS1","Id":"01t0k0000051AfjAAE"}},"selectedVariant":{"Name":"MARUTI ERTIGA GREEN LXI","Family":"ERTIGA","Loyalty_Amount__c":1300,"Fuel_Type__c":"CNG","Extended_Warranty_1_year__c":2000,"Extended_Warranty_2_year__c":2500,"Extended_Warranty_3_year__c":3000,"Id":"01t0k0000051AfjAAE"},"otherAccessoriesDiscount":{"priceBookEntryId":null,"UnitPrice":0,"Quantity":1,"opporrtunityId":null},"opportunityInfo":{"Model_Code__c":"R3","Amount":900800,"StageName":"New","Mobile__c":"9212768885","Email__c":"","Pricebook2Id":"01s7F00000BI0N7QAL","Name":"VIPIN DOGRA (Car)"},"addAccessories":[{"Id":"01t0k000005R2QpAAK","Name":"Car Stereo 4","quantity":"1","Minimum_Quantity__c":1,"Maximum_Quantity__c":5,"price":3500,"unitPrice":3500,"priceBookEntryId":"01u0k000003KoxEAAS"}],"addComponent":[{"label":"Extended Warranty","value":2000,"isChecked":true,"isExchangedWarrenty":true,"showLabel":false,"isDisabled":true,"year":"1 year","showCheckBox":false},{"label":"Loyalty","value":1300,"isChecked":true,"showLabel":true,"isDisabled":true,"showCheckBox":true},{"label":"Insurance","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Municipal Charges","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"FASTag charges","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Road Tax","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"MCP","value":0,"isChecked":true,"isMCP":true,"showLabel":false,"isDisabled":true,"packageValue":"Economy","validityValue":"4 Yrs - 40000 KMs","showCheckBox":false,"amount":0}],"headerValue":["Customer Name : VIPIN RAJU DOGRA","","Variant Name : MARUTI ERTIGA GREEN LXI"],"otherValidAmount":100000,"accessoriesValidAmount":100000,"enquiryRecordType":"Accessories Sales"}';
        AddLineItemCtrl.queryLineItemDetail(oppList[0].id, 'Quote');  
       
        //AddLineItemCtrl.createLineItemRecords(json, oppList[0].id);
        AddLineItemCtrl.createLineItemRecords(json, '');
       
        AddLineItemCtrl.retriveOffersSchemes(json);
        PriceCalcSrvc.isPricebookEntryAccessPermission();
    }
   
    static testMethod void testCreate5(){
        List<Product2> prodList = [SELECT Id, Name FROM Product2];
       
        set<String> tempSet = new set<String>();
        for(Product2 pr : prodList){
            tempSet.add(pr.id);
        }
       
        AddLineItemCtrl.createChildSObjectInstance('Opportunity');
       
        List<Opportunity> oppList = [SELECT Id,Line_Item_Summary__c FROM Opportunity];
       
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
       
        system.debug('== oppList From testCreate2 '+oppList);
       
        List<PriceBookEntry> pbe = [SELECT Id FROM PriceBookEntry];
       
        system.debug('pbe---->'+pbe);
       
        List<Scheme_Master__c> smList = [SELECT Id, discount_amount__c FROM Scheme_Master__c];
       
        String json = '{"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","offersText":null,"schemeCode":null,"cashPaymentData":445500,"financeAmountData":"450000","otherDiscountData":1500,"ruralDiscountData":1100,"corporateDiscountData":1200,"exchangeBonusData":15000,"exchangeData":50000,"OfferData":1500,"otherDiscountValue":true,"ruralOffersValue":false,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true,"employerName":null},"registrationAmountVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":"5000","Quantity":1},"exShowRoomVariant":{"priceBookEntryId":"'+pbe[0].Id+'","UnitPrice":890500,"Quantity":1,"opporrtunityId":"'+oppList[0].Id+'"},"otherCharge":{"Description":"Test Data","priceBookEntryId":null,"UnitPrice":1200,"Quantity":1,"opporrtunityId":null},"selectedColorVariant":{"Id":"a070k000008D59IAAS","Name":"SILKY SILVER","Color_Code__c":"Z2S","Variant__c":"01t0k0000051AfjAAE","Color_Type__c":"M","Variant__r":{"ProductCode":"R3RCCS1","Id":"01t0k0000051AfjAAE"}},"selectedVariant":{"Name":"MARUTI ERTIGA GREEN LXI","Family":"ERTIGA","Loyalty_Amount__c":1300,"Fuel_Type__c":"CNG","Extended_Warranty_1_year__c":2000,"Extended_Warranty_2_year__c":2500,"Extended_Warranty_3_year__c":3000,"Id":"01t0k0000051AfjAAE"},"otherAccessoriesDiscount":{"priceBookEntryId":null,"UnitPrice":0,"Quantity":1,"opporrtunityId":null},"opportunityInfo":{"Model_Code__c":"R3","Amount":900800,"StageName":"New","Mobile__c":"9212768885","Email__c":"","Pricebook2Id":"01s7F00000BI0N7QAL","Name":"VIPIN DOGRA (Car)"},"addAccessories":[{"Id":"01t0k000005R2QpAAK","Name":"Car Stereo 4","quantity":"1","Minimum_Quantity__c":1,"Maximum_Quantity__c":5,"price":3500,"unitPrice":3500,"priceBookEntryId":"01u0k000003KoxEAAS"}],"addComponent":[{"label":"Extended Warranty","value":2000,"isChecked":true,"isExchangedWarrenty":true,"showLabel":false,"isDisabled":true,"year":"1 year","showCheckBox":false},{"label":"Loyalty","value":1300,"isChecked":true,"showLabel":true,"isDisabled":true,"showCheckBox":true},{"label":"Insurance","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Municipal Charges","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"FASTag charges","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Road Tax","value":1200,"isChecked":true,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"MCP","value":0,"isChecked":true,"isMCP":true,"showLabel":false,"isDisabled":true,"packageValue":"Economy","validityValue":"4 Yrs - 40000 KMs","showCheckBox":false,"amount":0}],"headerValue":["Customer Name : VIPIN RAJU DOGRA","","Variant Name : MARUTI ERTIGA GREEN LXI"],"otherValidAmount":100000,"accessoriesValidAmount":100000,"enquiryRecordType":"Accessories Sales"}';
        AddLineItemCtrl.queryLineItemDetail(oppList[0].id, 'Opportunity');  
       
        AddLineItemCtrl.createLineItemRecords(json, oppList[0].id);
       
        AddLineItemCtrl.retriveOffersSchemes(json);
       
        PriceCalcSrvc.generatePriceBookEntryData(prodList[0].Id, test.getStandardPriceBookId());
        
        
        AddLineItemCtrl.fetchVariantProducts(prodList[0].Id);
    }
    
    static testMethod void testCreate6(){
        
        String json = '{"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","offersText":null,"schemeCode":"CSD","cashPaymentData":77656.69999999995,"financeAmountData":"450000","otherDiscountData":88,"ruralDiscountData":1108,"corporateDiscountData":1502.00,"exchangeBonusData":2200.00,"exchangeData":506,"OfferData":660,"otherDiscountValue":true,"ruralOffersValue":false,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true,"employerName":"ICICI"},"consumerOffer":[{"UnitPrice":120,"Quantity":1,"priceBookEntryId":"01u0k000003UUl3AAG"},{"UnitPrice":150,"Quantity":1,"priceBookEntryId":"01u0k000003UUl8AAG"},{"UnitPrice":200,"Quantity":1,"priceBookEntryId":"01u0k000003UUlDAAW"},{"UnitPrice":190,"Quantity":1,"priceBookEntryId":"01u0k000003UUlIAAW"}],"registrationAmountVariant":{"priceBookEntryId":"01u0k000003UMwVAAW","UnitPrice":"4500","Quantity":1,"opporrtunityId":"0060k000009JkeQAAS"},"exShowRoomVariant":{"priceBookEntryId":"01u0k000003UMwVAAW","UnitPrice":523156.7,"Quantity":1,"opporrtunityId":"0060k000009JkeQAAS"},"otherCharge":{"Description":"Test Charges","priceBookEntryId":null,"UnitPrice":1400,"Quantity":1,"opporrtunityId":null},"selectedColorVariant":{"Id":"a070k000008D4WRAA0","Name":"SUPERIOR WHITE","Color_Code__c":"26U","Variant__c":"01t0k0000051AbHAAU","Color_Type__c":"NM","Variant__r":{"ProductCode":"ER4CS2","Id":"01t0k0000051AbHAAU"}},"selectedVariant":{"Name":"BALENO LXI BS","Family":"BALENO","Model__c":"BA","Loyalty_Amount__c":1500.00,"Fuel_Type__c":"PET","Extended_Warranty_1_year__c":1100.00,"Extended_Warranty_2_year__c":1200.00,"Extended_Warranty_3_year__c":1300.00,"Id":"01t0k0000051AbHAAU"},"otherAccessoriesDiscount":{"priceBookEntryId":null,"UnitPrice":"1000","Quantity":1,"opporrtunityId":null},"opportunityInfo":{"billingState":"DL","regionCode":"C1","forCode":"3L","Old_Variant__c":"01t0k0000051AbHAAU","Variant_Modified_Count__c":1,"Model_Code__c":"BA","Amount":518794.7,"StageName":"New","Mobile__c":"9212768885","Email__c":"sid@gmail.com","Pricebook2Id":"01s7F00000BI0N7QAL","Name":"DILGEET SAI SINGH (Car)"},"addAccessories":[{"priceBookEntryId":"01u0k000003UbQRAA0","unitPrice":4000.0,"price":4000.0,"Maximum_Quantity__c":10,"Minimum_Quantity__c":1,"quantity":"1","Name":"Mud Flap (For Line Item)","Id":"01t0k000005XDB2AAO"}],"addComponent":[{"showCheckBox":false,"year":"3 year","isDisabled":true,"showLabel":false,"isExchangedWarrenty":true,"isChecked":true,"value":1300.00,"label":"Extended Warranty"},{"showCheckBox":true,"isDisabled":true,"showLabel":true,"isChecked":true,"value":1500.00,"label":"Loyalty"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1100,"label":"Insurance"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1200,"label":"Municipal Charges"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1300,"label":"FASTag charges"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1500,"label":"Road Tax"},{"amount":0,"showCheckBox":false,"validityValue":"4 Yrs - 40000 KMs","packageValue":"Economy","isDisabled":true,"showLabel":false,"isMCP":true,"isChecked":true,"value":0,"label":"MCP"}],"headerValue":["Customer Name : DILGEET SAI SINGH","","Variant Name : BALENO LXI BS"],"otherValidAmount":100000,"accessoriesValidAmount":100000,"enquiryRecordType":"Vehicle Sales","componentType":"prebooking"}';
        AddLineItemCtrlHelper.generateQuotation(json);
        
        String jsonData = '{"enquiryRecordType":"Vehicle Sales","accessoriesValidAmount":100000,"otherValidAmount":100000,"headerValue":["Customer Name : ADNAN ARNAV DANE","DMS Enquiry Number : ENQ 00012","Variant Name : BALENO ALTURA M"],"addComponent":[{"label":"Extended Warranty","value":"1000","isChecked":true,"isExchangedWarrenty":true,"showLabel":false,"isDisabled":true,"year":"1 year","showCheckBox":false},{"label":"Loyalty","value":3000,"isChecked":true,"showLabel":true,"isDisabled":true,"showCheckBox":true},{"label":"Insurance","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Municipal Charges","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Number Plate Charges","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"Road Tax","value":"","isChecked":false,"showLabel":true,"isDisabled":false,"showCheckBox":true},{"label":"MCP","value":1200,"isChecked":true,"isMCP":true,"showLabel":false,"isDisabled":true,"packageValue":"Economy","validityValue":"4 Yrs - 40000 KMs","showCheckBox":false,"amount":0}],"addAccessories":[{"Name":"Fog Lights","quantity":"1","Id":"01t0k000005R2QzAAK","Minimum_Quantity__c":1,"Maximum_Quantity__c":15,"price":8000,"unitPrice":8000,"priceBookEntryId":"01u0k000003KoxJAAS"}],"opportunityInfo":{"Name":"ADNAN   DANE (Car)","Pricebook2Id":"01s7F00000BI0N7QAL","Email__c":"hdalal.mirum@gmail.com","Mobile__c":"919821258774","StageName":"New"},"otherAccessoriesDiscount":{"opporrtunityId":null,"Quantity":1,"UnitPrice":"2000","priceBookEntryId":null},"selectedVariant":{"Id":"01t0k0000051AVRAA2","Name":"BALENO ALTURA M","Extended_Warranty_1_year__c":1000,"Extended_Warranty_2_year__c":1500,"Extended_Warranty_3_year__c":2000,"Loyalty_Amount__c":3000,"Fuel_Type__c":"Petrol","Family":"BALENO"},"selectedColorVariant":{"Id":"a070k000008D4O7AAK","Name":"SUPERIOR WHITE","Color_Code__c":"26U","Variant__c":"01t0k0000051AVRAA2","Color_Type__c":"NM","Variant__r":{"ProductCode":"ER4CD4","Id":"01t0k0000051AVRAA2"}},"otherCharge":{"opporrtunityId":null,"Quantity":1,"UnitPrice":0,"priceBookEntryId":null},"registrationAmountVariant":{"priceBookEntryId":"01u0k000003UrV0AAK","UnitPrice":"5000","Quantity":1,"opporrtunityId":"0Q00k000000GXAwCAO","registerId":"00k0k000005IDD7AAO"},"exShowRoomVariant":{"priceBookEntryId":"01u0k000003UrV0AAK","UnitPrice":"537850.00","Quantity":1,"opporrtunityId":"0Q00k000000GXAwCAO","exShowId":"00k0k000005IDD5AAO"},"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","employerName":"INDO TECH TRANSFORMERS LTD","corporateDiscountValue":false,"exchangeBonusValue":false,"exchangeValue":false,"ruralOffersValue":true,"otherDiscountValue":true,"OfferData":0,"exchangeData":0,"exchangeBonusData":0,"corporateDiscountData":0,"ruralDiscountData":3500,"otherDiscountData":3500,"financeAmountData":"350000","cashPaymentData":192850,"schemeCode":"SS000000AK0319190472","offersText":null}}';
        
        OfferSchemeCalcSrvc.retiveOfferAndSchemes(jsonData);
        
    }
    
}