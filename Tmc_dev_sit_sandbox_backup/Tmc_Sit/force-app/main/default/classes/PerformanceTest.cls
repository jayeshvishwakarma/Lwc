/**
* @File Name          : 
* @Description        : This class will create a performance log for Vehicle Enquiry.
* @Author             : 
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 12/20/2019, 12:25:16 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    12/10/2019,                Saifullah Saifi               Initial Version
**/

@isTest
public class PerformanceTest {
   
   @testSetup
   public static void testSetupMethod(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '3';
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
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '4';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       
       // Custom Setting
      Implementation_Strategy__c IS3 = new Implementation_Strategy__c();
      IS3.Name  = '8';
      IS3.Identifier_Type__c = 'Record Type';
      IS3.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
      IS3.Strategy_Key__c = 'Loyalty_Enrollment';
      IS3.Use_Case__c = 'OpportunityTriggers';
      
      Insert IS3;
   }




   //Added by Anas Yar Khan on 21th July for Loyalty NFR
   @isTest
    public static void SysPerfLoyaltyReferralDetailsTest(){
      SysPerfLoyaltyReferralDetails.ProcessData();
    }
    
    @isTest
    public static void SysPerfLoyaltyEnrollmentCreateTest(){
      
       SysPerfLoyaltyEnrollmentCreate.ProcessData();
    }
    
    @isTest
    public static void SysPerfLoyaltyInterestOnVehicleEnqTest(){

       SysPerfLoyaltyInterestOnVehicleEnq.ProcessData();
    } 
    
    @isTest
    public static void SysPerfLoyaltyValidationTest(){
       SysPerfLoyaltyValidation.ProcessData();
    }
    
    @isTest
    public static void SysPerfLoyaltyFollowUpTest(){
       SysPerfLoyaltyFollowUp.ProcessData();
    }
    
    
   @isTest
    public static void SysPerfGetLoyaltyBalancePointsTest(){
       SysPerfGetLoyaltyBalancePoints.ProcessData();
    } 
   
   
 @isTest
    public static void test(){
      // SysPerfAccessoriesEnquiryAssignment.ProcessData();
    }
    
  @isTest
    public static void test1(){
      // SysPerfProductAccessoriesList.ProcessData();
        UtilityClass.tempWrap lw ;
        UtilityClass.LimitWrap cd1;
        
    }
    @isTest
    public static void test2(){
        try{
           // SysPerfUpdateTaskAccessoryEnquiry.ProcessData();
        } catch(Exception e){
            
        }
    }
  @isTest
    public static void test3(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       SysPerfPerformanceAccessoriesEnquiry.ProcessData();
        
    }
    
 @isTest
    public static void test4(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       SysPerfInfluencers.ProcessData();
        
    }
    

        
 @isTest
    public static void test5(){
       // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       SysPerfChangeOwner.ProcessData();
        
    }
    
    @isTest
    public static void test6(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       SysPerfVehicleEnquiryDeliveryChecklist.ProcessData();
        
    }
    
    
      @isTest
    public static void test9(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       SysPerfUpdateTaskVehicleEnquiry.ProcessData();
        
    }
    
    
   
   @isTest
    public static void test10(){
        
       list<Survey__c> surveyList = TestDataFactory.createSurvey(1);
        insert surveyList;
       SysPerfRetrieveTehsilList.ProcessData(); 
    }
    
     @isTest
    public static void test11(){
        
       list<Survey__c> surveyList = TestDataFactory.createSurvey(1);
        insert surveyList;
       SysPerfRetrieveVillageList.ProcessData(); 
    }
    @isTest
    public static void test12(){
       
       list<Survey__c> surveyList = TestDataFactory.createSurvey(1);
        insert surveyList;
        
        Custom_Validation_Exception_Setting__c st= TestDataFactory.createCustomValidation(true);
        
     //  SysPerfModelVariantEnquiry.ProcessData(); 
    }

     @isTest
    public static void test13(){
         // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
        
        list<Survey__c> surveyList = TestDataFactory.createSurvey(1);
        insert surveyList;
          Custom_Validation_Exception_Setting__c st= TestDataFactory.createCustomValidation(true);
       SysPerfEnquiryBookingForm.ProcessData(); 
    }
    
    @isTest
    public static void test14(){
     // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
     list<Product2> productList = TestDataFactory.createProduct2(1);
        insert productList;

        SysPerfCreateQuote.ProcessData();
    }
    
     @isTest
    public static void test15(){
     list<Product2> productList = TestDataFactory.createProduct2(1);
        insert productList;

        //SysPerfUpdateQuote.ProcessData();
    }
    
     @isTest
    public static void test24(){
     
        SysPerfLoadEmployees.ProcessData();
    }
    
    
     
    public static void test16(){
         // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
       // Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        //Insert IS1;
        SysPerfTestDriveSubmitFeedback.ProcessData();
    }
    
     @isTest
    public static void test17(){
        
        test.startTest();
        List<Implementation_Strategy__c> implementList = [select id , name,Identifier_Type__c ,
                                                                Strategy_Implementation__c ,
                                                                Strategy_Key__c ,
                                                                Use_Case__c 
                                                                 from Implementation_Strategy__c ];
      //MuleSoft_API_Details__mdt mdt = [ SELECT MasterLabel FROM MuleSoft_API_Details__mdt WHERE MasterLabel = 'Test Drive Slots' ];
       
        UtilityClass.wrapperDateTime wrap1 = new UtilityClass.wrapperDateTime();
        Test.setMock(HttpCalloutMock.class, new WebSermockTest());
        
        SysPerfTestDriveCreate.ProcessData();
        test.stopTest();
    }
    
    @isTest
    public static void test18(){
        
        list<Product2> productList = TestDataFactory.createProduct2(1);
        insert productList;
       // SysPerfUpdateVehicleEnquiry.ProcessData();
    }
    
     @isTest
    public static void test19(){
         // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
       SysPerfUpdateVehicleEnquiry.ProcessData();
    }
        @isTest
    public static void test20(){
         Test.setMock(HttpCalloutMock.class, new WebSermockTest());
       // SysPerfCancelTimeSlot.ProcessData();
    }
    
    @isTest
    public static void test21(){
        SysPerfVehicleEnquiryQuotePriceDisplay.ProcessData();
    }
    
    @isTest
    public static void test22(){
        //SysPerfUpdateStatus.ProcessData();
    }
    @isTest
    public static void test23(){
        // load offer record type from product 
        Id productRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Offer').getRecordTypeId();
        List<Product2> proList=TestDataFactory.createProducts('Offer',1);
        List<PricebookEntry> pricebookList=TestDataFactory.createPriceBookEntryList(1,proList[0].Id);
        //SysPerfCreateProdOffer.ProcessData();
        
    }
    
    @isTest
    public static void test25(){
       SysPerfVehicleEnquiryQuoteAccessories.ProcessData();
        
    }
    @isTest
    public static void test26(){
         // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
        // load offer record type from product 
        //Id productRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Accessories').getRecordTypeId();
       // System.debug('---->'+productRecordType);
        List<Product2> proList=TestDataFactory.createProducts('Accessories',1);
        List<PricebookEntry> pricebookList=TestDataFactory.createPriceBookEntryList(1,proList[0].Id);
      SysPerfDisplayOffers.ProcessData();
    }

 /*   @isTest(SeeAllData='true')
    public static void test29(){
        Report reportList = [SELECT Id,DeveloperName FROM Report where
                                    DeveloperName ='Performance_Logger_1_vGv'];
        SysPerfSetFilterReport.ProcessData();
        
    } */

    public static testMethod void test30(){
        test.startTest();
         // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        // Custom Setting
        Implementation_Strategy__c IS1 = new Implementation_Strategy__c();
        IS1.Name  = '2';
        IS1.Identifier_Type__c = 'Record Type';
        IS1.Strategy_Implementation__c = 'OpportunityAccessoriesTriggerServiceImpl';
        IS1.Strategy_Key__c = 'Accessories_Sales';
        IS1.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS1;
        List<Performance__mdt> listPerformanceMdt = Performance.getPerformanceTest();
        Performance.PerformanceWrap objPerformanceWrap = new Performance.PerformanceWrap();
        objPerformanceWrap.ClassName = listPerformanceMdt[0].Id;
        objPerformanceWrap.MasterLabel = listPerformanceMdt[0].MasterLabel;
        objPerformanceWrap.prfrm = listPerformanceMdt[0];
        Performance.ExecuteTestScript( JSON.serialize( new List<Performance.PerformanceWrap>{objPerformanceWrap} ) );
        
        // for exception
       
        objPerformanceWrap.RecordID = null;
        Performance.ExecuteTestScript( JSON.serialize( new List<Performance.PerformanceWrap>{objPerformanceWrap} ) );
        test.stopTest();
        
        //utility class
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        List<Account> accts = new List<Account>();
        Account a = new Account(FirstName='TEST',LastName='ACCOUNT');
        a.RecordTypeId=customerRecTypeId;
        accts.add(a);
        insert accts; 
        
        Id customerRecTypeDealId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        List<Account> acctDeas = new List<Account>();
        Account Deal = new Account(Name='ACCOUNT');
        deal.RecordTypeId=customerRecTypeDealId;
        acctDeas.add(deal);
        insert acctDeas;
        
        UtilityClass.fetchEnquiryId(accts[0].Id, acctDeas[0].Id, 1);
        UtilityClass.fetchContentDistribution();
        UtilityClass.updateQuote(null,null);
    }
}