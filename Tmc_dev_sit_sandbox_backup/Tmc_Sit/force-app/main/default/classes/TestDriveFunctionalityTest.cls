@isTest
public class TestDriveFunctionalityTest {
    
    @testSetup
    static void CreateMethod(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
		
        List<Account> personAccount = TestDataFactory.createPersonAccount(1);
        Insert personAccount; 
        
        list<product2> products = TestDataFactory.createProducts('Variants', 1);
        products[0].Model__c = 'BA';
        products[0].Enquiry__c = 'Yes';
        products[0].Fuel_Type__c = 'Petrol';
        
        Insert products;
        
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        Insert accList;
        
        List<Asset> assetList = new List<Asset>(); 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(products)){
            ast.accountId  = accList[0].Id;
            assetList.add(ast);
        }
        Insert assetList;
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        //Accounts Creation
        accList[0].For_Code__c = forCodeList[0].Id;
        update accList;
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = usr[0].Id;
        
        insert oppList;
        
        List<test_drive__c> tdList = TestDataFactory.createTestDriveRecords(1);
        tdList[0].Enquiry__c = oppList[0].id;
        insert tdList;
    }
    
    @isTest
    static void getVariants(){
        test.startTest();
        BasicReturn result=TestDriveFunctionality.findVariants('BA', 'EXC', 'Petrol');

        System.assertEquals('Success', result.message);
        test.stopTest();
    }
    
    @isTest
    static void getVIN()
    {
        
        List<Account> personAccount = new list<Account>([SELECT id from Account where isPersonAccount =true]);
        list<product2> products = new list<Product2>([SELECT id from product2]);
        List<Account> accList = new list<Account>([SELECT id from Account where isPersonAccount =False]);
        List<Asset> assetList = new List<Asset>([SELECT id from Asset]);
        
        test.startTest();
        List<Asset> result=TestDriveFunctionality.findVIN('BA',personAccount[0].Id,'Petrol');
        List<Asset> result1=TestDriveFunctionality.findVIN('BA',personAccount[0].Id,'');
        TestDriveFunctionality.findVariantsForStockCheck('BA');
        System.assertEquals(0, result.size());
        test.stopTest();
    }
    @isTest
    static void createTestDrive()
    {
        list<product2> products = new list<Product2>([select Id,Name,(select Id,Name from Assets) from Product2]);
        List<Account> accList = new list<Account>([SELECT id from Account where isPersonAccount =False]);
        List<Asset> assetList = new List<Asset>([SELECT id from Asset]);
        List<Opportunity> oppList = new list<opportunity>([SELECT id from opportunity]); 
        
        List<test_drive__c> tdList = new List<test_drive__c>([SELECT id from test_drive__c]);
               
        test.startTest();
       // try{
            for(Product2 pr:products)
            {
                List<Asset> assetsList=pr.Assets;
                for(Asset asset:assetsList)
                {
                    BasicReturn data=TestDriveFunctionality.createTestDriveSF('{"assetId":"'+asset.Id+'","enquiryId":"'+oppList[0].Id+'","bookingId":"MRT1","location":"Event","bookingDate":"2019-07-15","startTime":"01:30","endTime":"02:00","isCommercial":true,"startMeterReading":14,"endMeterReading":15,"loadedTestDrive":true}');
                    BasicReturn data1=TestDriveFunctionality.createTestDriveSF('{"assetId":"'+asset.Id+'","enquiryId":null,"bookingId":"MRT1","status":"COMPLETED","location":"Event","bookingDate":"2019-07-15","startTime":"01:30","endTime":"02:00","satisfied":"No","feedback":"Test","kmDriven":"10","isCommercial":true,"startMeterReading":"14","endMeterReading":"15","loadedTestDrive":"true"}');
                    System.debug(data);
                    Test_Drive__c td=TestDriveFunctionality.getTestDrive(tdList[0].id);
                    TestDriveFunctionality.updateTestDrive('{"id":"'+tdList[0].id+'","status":"'+td.Status__c+'","location":"'+td.Location__c+'","selectedDate":"2019-07-15","startTime":"01:30","endTime":"02:00","oldStartDate":"2019-07-15T07:05:00.00Z","duration":10}');
                    TestDriveFunctionality.updateTestDrive('{"id":"'+tdList[0].id+'","status":"COMPLETED","location":"'+td.Location__c+'","selectedDate":"2019-07-15","startTime":"01:30","endTime":"02:00","oldStartDate":"2019-07-15T07.05:00.00Z","satisfied":"No","feedback":"Test","kmDriven":"10","duration":10}');
                    //System.assertEquals('Test Drive created Successfully', data.message);    
                }
            }
            test.stopTest();
    /*    }
        catch(Exception e)
        {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
        */
    }
}