@istest
public class RefreshEnquiryPriceTest {
    static List<Product2> productList;
    
    @testsetup
    static void testrecordcreate(){
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
        //Product List
        productList = new list<Product2>();
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
        List<PricebookEntry> pbe = TestDataFactory.createPricebookEntry(1, productList[0].Id);
        insert pbe;
        
        //Component Record type Product
        List<Product2> componentRecords = TestDataFactory.createProducts('Component', 5);
        insert componentRecords;
        
        //Color List
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        colorList[0].Color_Type__c = 'NM';
        insert colorList;
        
        
        List<Product2> offerProduct = TestDataFactory.createProducts('Offer', 1);
        offerProduct[0].Start_Date__c = system.today().addDays(-5);
        offerProduct[0].End_Date__c = system.today().addDays(5);
        offerProduct[0].Fuel_Type__c = 'PET';
        offerProduct[0].For_Code__c = '3L';
        offerProduct[0].Model__c = 'BA';
        offerProduct[0].Scheme_Regiom__c = 'C1';
        offerProduct[0].State__c  = 'DL';
       
        insert offerProduct;
        
        //Pricebook Entry
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPricebookEntry(1, offerProduct[0].Id);
        insert pricebookEntryList;
        
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
        
        //User Creation 
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', conList);
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
         
        insert oppList;
        
        String json = '{"addSchemes":{"objOtherId":"01u0k000003KpOJAA0","offersText":null,"schemeCode":"CSD","cashPaymentData":77656.69999999995,"financeAmountData":"450000","otherDiscountData":88,"ruralDiscountData":1108,"corporateDiscountData":1502,"exchangeBonusData":2200,"exchangeData":506,"OfferData":660,"otherDiscountValue":true,"ruralOffersValue":false,"exchangeValue":true,"exchangeBonusValue":true,"corporateDiscountValue":true,"employerName":"ICICI"},"consumerOffer":[{"UnitPrice":120,"Quantity":1,"priceBookEntryId":"01u0k000003UUl3AAG"},{"UnitPrice":150,"Quantity":1,"priceBookEntryId":"01u0k000003UUl8AAG"},{"UnitPrice":200,"Quantity":1,"priceBookEntryId":"01u0k000003UUlDAAW"},{"UnitPrice":190,"Quantity":1,"priceBookEntryId":"01u0k000003UUlIAAW"}],"registrationAmountVariant":{"priceBookEntryId":"01u0k000003UMwVAAW","UnitPrice":"4500","Quantity":1,"opporrtunityId":"0060k000009JkeQAAS"},"exShowRoomVariant":{"priceBookEntryId":"01u0k000003UMwVAAW","UnitPrice":523156.7,"Quantity":1,"opporrtunityId":"0060k000009JkeQAAS"},"otherCharge":{"Description":"Test Charges","priceBookEntryId":null,"UnitPrice":1400,"Quantity":1,"opporrtunityId":null},"selectedColorVariant":{"Id":"a070k000008D4WRAA0","Name":"SUPERIOR WHITE","Color_Code__c":"26U","Variant__c":"01t0k0000051AbHAAU","Color_Type__c":"NM","Variant__r":{"ProductCode":"ER4CS2","Id":"01t0k0000051AbHAAU"}},"selectedVariant":{"Name":"BALENO LXI BS","Family":"BALENO","Model__c":"BA","Loyalty_Amount__c":1500,"Fuel_Type__c":"PET","Extended_Warranty_1_year__c":1100,"Extended_Warranty_2_year__c":1200,"Extended_Warranty_3_year__c":1300,"Id":"'+componentRecords[0].Id+'"},"otherAccessoriesDiscount":{"priceBookEntryId":null,"UnitPrice":"1000","Quantity":1,"opporrtunityId":null},"opportunityInfo":{"billingState":"DL","regionCode":"C1","forCode":"3L","Old_Variant__c":"01t0k0000051AbHAAU","Variant_Modified_Count__c":1,"Model_Code__c":"BA","Amount":518794.7,"StageName":"New","Mobile__c":"9212768885","Email__c":"sid@gmail.com","Pricebook2Id":"01s7F00000BI0N7QAL","Name":"DILGEET SAI SINGH (Car)"},"addAccessories":[{"priceBookEntryId":"01u0k000003UbQRAA0","unitPrice":4000,"price":4000,"Maximum_Quantity__c":10,"Minimum_Quantity__c":1,"quantity":"1","Name":"Mud Flap (For Line Item)","Id":"01t0k000005XDB2AAO"}],"addComponent":[{"showCheckBox":false,"year":"3 year","isDisabled":true,"showLabel":false,"isExchangedWarrenty":true,"isChecked":true,"value":1300,"label":"Extended Warranty"},{"showCheckBox":true,"isDisabled":true,"showLabel":true,"isChecked":true,"value":1500,"label":"Loyalty"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1100,"label":"Insurance"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1200,"label":"Municipal Charges"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1300,"label":"FASTag charges"},{"showCheckBox":true,"isDisabled":false,"showLabel":true,"isChecked":true,"value":1500,"label":"Road Tax"},{"amount":0,"showCheckBox":false,"validityValue":"4 Yrs - 40000 KMs","packageValue":"Economy","isDisabled":true,"showLabel":false,"isMCP":true,"isChecked":true,"value":0,"label":"MCP"}],"headerValue":["Customer Name : DILGEET SAI SINGH","","Variant Name : BALENO LXI BS"],"otherValidAmount":100000,"accessoriesValidAmount":100000,"enquiryRecordType":"Vehicle Sales","componentType":"prebooking"}';
        oppList[0].Line_Item_Summary__c= json;
        update oppList[0];
        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        
        insert quoteList;
        
        OtherAmountValidation__c amountValidation = TestDataFactory.createQuoteAmountValidation(10000);
        insert amountValidation;
        
        
        
    }
    
    
    
    static testmethod void validateRefreshMethod(){
        
        List<Opportunity> oppList = [SELECT Id,Line_Item_Summary__c FROM Opportunity];
        system.assertEquals(1, oppList.size());
        List<PriceBookEntry> pbe = [SELECT Id FROM PriceBookEntry];
        system.assertEquals(2, pbe.size());
        
        List<Product2> productList = new List<Product2>([Select Id, Name, Discount_Price__c from Product2]);
        
        RefreshEnquiryPrice.updateEnquiryPrice(oppList[0].Line_Item_Summary__c );
        
    }
    
}