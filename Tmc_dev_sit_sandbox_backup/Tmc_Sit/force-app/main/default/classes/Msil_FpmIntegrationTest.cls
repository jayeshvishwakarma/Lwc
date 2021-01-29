/**
 * @File Name          : Msil_FpmIntegrationTest.cls
 * @Author             : Rahul Sharma
 * @Group              : MSIL
**/

@isTest
private class Msil_FpmIntegrationTest{
    static list<User> dseUser = new list<User>();
    
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
		
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;
            
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accountList[0].For_Code__c = forCodeList[0].Id;
        accountList[0].Dealer_Code__c = '154';
        insert accountList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accountList[0].Id);
        conList[0].LastName = 'Test Sc2';
        insert conList;
        System.assertEquals(1, conList.size());
        User usr = TestDataFactory.generateUserData('Dealer Hostess', conList[0].Id, 'Dealer Sales Executive');
        
        List<Contact> dseConList = TestDataFactory.createTestContact(1, accountList[0].Id);
        insert dseConList;
        
        dseUser = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', dseConList);
        dseUser[0].Designation__c = 'SAE';
        insert dseUser;
        
        
        //User u = [Select Id from User where Profile.Name = 'Dealer Sales Executive' and IsActive = True Limit 1];
        //system.debug('user id is : '+ u.id);
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        userAccountList[0].User__c = dseUser[0].Id;
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Product2> productList = new list<Product2>();
        productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].Email__c= 'test@test.com';
        oppList[0].Dealership__c= accountList[0].Id;
        oppList[0].ownerId = dseUser[0].Id;
        oppList[0].Model_Code__c= 'BA';
        oppList[0].DMS_Enquiry_Name__c= 'ENQ84943671';
        oppList[0].DMS_Sync_Error_Details__c = 'BA';
        oppList[0].Variant__c= productList[0].Id;
        
        insert oppList;
        
        FMP_Integration__c fmp = new FMP_Integration__c();
        fmp.name='fmp';
        fmp.Weekdays__c='Monday,Tuesday,Wednesday,Thursday,Friday';
        fmp.Start_Time__c = '08:00:00';
        fmp.End_Time__c= '20:00:00';
        insert fmp;
            
    }
    
    @isTest
    static void fmpResponse(){
        Opportunity opp = [Select Id from opportunity limit 1];
        system.debug('opp'+opp);
        Test.startTest();
        if(opp != null)
        {
            Test.setMock(HttpCalloutMock.class, new Msil_FpmIntegrationMock());
            Msil_FpmIntegration.getLoanStatusFromFMP(opp.Id);
        }
        Msil_FpmIntegration.fmpResponseWrapper wrap1 = new Msil_FpmIntegration.fmpResponseWrapper(null,null,null);
        Msil_FpmIntegration.loanStatusWrapper wrap2 = new Msil_FpmIntegration.loanStatusWrapper(null,null,null);
        test.stopTest();
    }
    
    @isTest
    static void fmpErrorEnqNotPresnt(){
        Opportunity opp = [Select Id from opportunity limit 1];
        opp.DMS_Enquiry_Name__c = null;
        update opp;
        system.debug('opp'+opp);
        Test.startTest();
        if(opp != null)
            Msil_FpmIntegration.getLoanStatusFromFMP(opp.Id);
        test.stopTest();
    }   
    
    @isTest
    static void fmpErrorNonTiming(){
        Opportunity opp = [Select Id from opportunity limit 1];
        List<FMP_Integration__c> fmpValues = FMP_Integration__c.getAll().values();
        fmpValues[0].Start_Time__c = '21:00:00';
        update fmpValues[0];
        system.debug('opp'+opp);
        Test.startTest();
        if(opp != null)
            Msil_FpmIntegration.getLoanStatusFromFMP(opp.Id);
        test.stopTest();
    }   
    
    @isTest
    static void fmpErrorDayCheck(){
        Opportunity opp = [Select Id from opportunity limit 1];
        List<FMP_Integration__c> fmpValues = FMP_Integration__c.getAll().values();
        fmpValues[0].Weekdays__c = 'abc';
        update fmpValues[0];
        system.debug('opp'+opp);
        Test.startTest();
        if(opp != null)
            Msil_FpmIntegration.getLoanStatusFromFMP(opp.Id);
        test.stopTest();
    }    

    @isTest
    static void fmpErrorNoOppId(){
        Test.startTest();
        Msil_FpmIntegration.getLoanStatusFromFMP(null);
        test.stopTest();
    }    

}