@istest
public class MSIL_CdcCountOverMailTest {
        DateTime schedularTime=DateTime.newInstance(2020, 04, 23, 16, 8, 16);
        public  static DateTime customDate=system.now();
        
        @testSetup
        static void CreateRecord(){
		
			// Custom Setting
            Implementation_Strategy__c IS = new Implementation_Strategy__c();
            IS.Name  = '1';
            IS.Identifier_Type__c = 'Record Type';
            IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
            IS.Strategy_Key__c = 'Vehicle_Sales';
            IS.Use_Case__c = 'OpportunityTriggers';
            
            Insert IS;
			
            Datetime dt = system.now();
            
            Date d = date.newinstance(dt.year(), dt.month(), dt.day());
            List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
            insert userAccountList;
            
            List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
            insert personAccountList;
            
            List<Opportunity> oppList = TestDataFactory.createTestOpportunity(2, 'Vehicle Sales');
            oppList[0].accountId = userAccountList[0].id;
            oppList[0].StageName = 'New';
            oppList[0].Customer__c= personAccountList[0].Id;
            oppList[0].ownerId = userinfo.getUserId();
            oppList[0].DMS_Sync_Error_Details__c  = 'abc';
            
            oppList[1].accountId = userAccountList[0].id;
            oppList[1].StageName = 'Pre-Booking';
            oppList[1].Customer__c= personAccountList[0].Id;
            oppList[1].ownerId = userinfo.getUserId();
            oppList[1].DMS_Sync_Error_Details__c  = 'abc';
            oppList[1].DMS_Enquiry_Name__c  = 'abc';
            oppList[1].Pre_booking_Submission_Date__c   = d;
            insert oppList;
            
            CDC_TimeSet__c cs = new CDC_TimeSet__c();
            cs.Name='test';
            cs.TimeSetUp__c=customDate;
            insert cs;
            
            CDC_Limit__c cdc = new CDC_Limit__c(Hourly_CDC_Consume_limit__c=100,BackupCustomDate__c=customDate,Usage_Till_Now__c=1000);
            insert cdc;
        }
        
       @istest
        static void testgetCDCData(){
            Object jsonString='{"MonthlyPlatformEvents":{"Max":7500000,"Remaining":7500000}}';
            String keyv='MonthlyPlatformEvents';
            Map<String, Object> dummyMap=new Map<String, Object>();
            dummyMap.put(keyv,jsonString);
            MSIL_CdcCountOverMailMock dummyResponse=new MSIL_CdcCountOverMailMock(200,'Success','{"MonthlyPlatformEvents":{"Max":7500000,"Remaining":7500000}}',null);
            Test.setMock(HttpCalloutMock.class, dummyResponse);
             Test.startTest();
            MSIL_CdcCountOverMail.getCDCData(null);
            Test.stopTest();
           
        }
       @istest
        static void testparseJson(){
            MSIL_CdcCountOverMailMock dummyResponse=new MSIL_CdcCountOverMailMock(200,'Success','{"MonthlyPlatformEvents":{"Max":7500000,"Remaining":7500000}}',null);
            Test.setMock(HttpCalloutMock.class, dummyResponse);
               Test.startTest();
            MSIL_CdcCountOverMail.getCDCData(customDate);
            Test.stopTest();
           
        }
        
        
       /*  @istest
        static void testparseJson2(){
           
            Test.startTest();
            MSIL_CdcCountOverMail.parseJson2(customDate);
            Test.stopTest();
        }*/
        
        @istest
        static void testinsertCDCLimitField(){
            Test.startTest();
            MSIL_CdcCountOverMail.insertCDCLimitField(100,customDate,300000);
            Test.stopTest();
        }

        
        
        @isTest 
        static void executeTest(){   
            Test.startTest();
            MSIL_CDCHourlyScheduleClass myClass = new MSIL_CDCHourlyScheduleClass();   
            String chron = '0 0 23 * * ?';        
            system.schedule('CDCAlertTest', chron, myClass);
            Test.stopTest();
        } 



}