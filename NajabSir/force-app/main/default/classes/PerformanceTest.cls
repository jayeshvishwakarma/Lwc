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
       SysPerfPerformanceAccessoriesEnquiry.ProcessData();
        
    }
    
 @isTest
    public static void test4(){
       SysPerfInfluencers.ProcessData();
        
    }
    

        
 @isTest
    public static void test5(){
       SysPerfChangeOwner.ProcessData();
        
    }
    
    @isTest
    public static void test6(){
       SysPerfVehicleEnquiryDeliveryChecklist.ProcessData();
        
    }
    
    
      @isTest
    public static void test9(){
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
        
        list<Survey__c> surveyList = TestDataFactory.createSurvey(1);
        insert surveyList;
          Custom_Validation_Exception_Setting__c st= TestDataFactory.createCustomValidation(true);
       SysPerfEnquiryBookingForm.ProcessData(); 
    }
    
    @isTest
    public static void test14(){
     list<Product2> productList = TestDataFactory.createProduct2(1);
        insert productList;

        SysPerfCreateQuote.ProcessData();
    }
    
     @isTest
    public static void test15(){
     list<Product2> productList = TestDataFactory.createProduct2(1);
        insert productList;

        SysPerfUpdateQuote.ProcessData();
    }
    
     @isTest
    public static void test24(){
     
        SysPerfLoadEmployees.ProcessData();
    }
    
    
     @isTest(SeeAllData='true')
    public static void test16(){
        SysPerfTestDriveSubmitFeedback.ProcessData();
    }
    
     @isTest
    public static void test17(){
      //MuleSoft_API_Details__mdt mdt = [ SELECT MasterLabel FROM MuleSoft_API_Details__mdt WHERE MasterLabel = 'Test Drive Slots' ];
       
        UtilityClass.wrapperDateTime wrap1 = new UtilityClass.wrapperDateTime();
        Test.setMock(HttpCalloutMock.class, new WebSermockTest());
        
        SysPerfTestDriveCreate.ProcessData();
    }
    
    @isTest
    public static void test18(){
        
        list<Product2> productList = TestDataFactory.createProduct2(1);
        insert productList;
       // SysPerfUpdateVehicleEnquiry.ProcessData();
    }
    
     @isTest
    public static void test19(){
        
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