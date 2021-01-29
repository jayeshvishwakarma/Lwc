/**
* @Autho:- Rahul Sharma
* @Company-: MSIL
* @Description-: Test class for AccountDSEReportFillUp.
**/

@istest
public class AccountDSEReportFillUpTest {
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
		
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accountList[0].For_Code__c = forCodeList[0].Id;
        insert accountList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accountList[0].Id);
        conList[0].LastName = 'Test Sc2';
        insert conList;
        
        List<Contact> dseConList = TestDataFactory.createTestContact(1, accountList[0].Id);
        insert dseConList;
        
        dseUser = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', dseConList);
        dseUser[0].Designation__c = 'SAE';
        insert dseUser;
        
        User usr = TestDataFactory.generateUserData('Dealer Hostess', conList[0].Id, 'Dealer Sales Executive');
        
        //User u = [Select Id from User where Profile.Name = 'Dealer Sales Executive' and IsActive = True Limit 1];
        
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
        oppList[0].ownerId =  dseUser[0].Id;
        oppList[0].Model_Code__c= 'BA';
        oppList[0].DMS_Sync_Error_Details__c = 'BA';
        oppList[0].Variant__c= productList[0].Id;
        oppList[0].Dealership_Channel__c = 'Nexa';
       	DateTime today = system.now();
        oppList[0].Send_BCR_Time__c= today.addDays(-30);
        oppList[0].Brochure_Sent_Time__c= today.addDays(-30);
        oppList[0].Finance_Checklist_Time__c= today.addDays(-30);
        oppList[0].Delivery_Checklist_Time__c= today.addDays(-30);
        oppList[0].Quote_Sent_time__c= today.addDays(-30);
        oppList[0].DSE_Allocation_Time__c= today.addDays(-30);

        
        insert oppList;
        
        Id preBookRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pre Booking Follow-up').getRecordTypeId();
        
        List<Task> task = TestDataFactory.createTask(1, oppList[0], preBookRecordTypeId);
        insert task;
        
        DSE_Report_RUn__c cs = new DSE_Report_RUn__c();
        cs.Name='RUN';
        cs.Daily_End_Time__c = system.now();
        cs.Daily_End_Time_SVOC__c = system.now();
        cs.Daily_Run_Time__c = system.now();
        cs.Month_End_Time__c = system.now();
        cs.Month_End_Time_SVOC__c = system.now();
        cs.Monthly_Run_TIme__c = system.now();
        //cs.Other fiels values
    	insert cs;
        

        system.runAs( dseUser[0])
        {
            list<Event_Visit_Plan__c> eventList = TestDataFactory.createEventsPlans(200);
            for(Event_Visit_Plan__c evp : eventList){
                evp.OwnerId =  dseUser[0].Id;
                evp.Assigned_Sales_Exec__c =  dseUser[0].Id;
            }
            insert eventList;
            
            //Create MC Communication Records
            list<MC_Communication__c> mcComList  = TestdataFactory.createMCCommData(5,opplist[0].Id);
            mcComList[0].Type__c = 'Quote';
            mcComList[1].Type__c = 'Send Brochure';
            mcComList[2].Type__c = 'BCR';
            mcComList[3].Type__c = 'Delivery Checklist';
            mcComList[4].Type__c = 'Finance Checklist';
            insert mcComList;   
        }  
    }
    
    @isTest
    static void updateDSEAdoptionReportColumnsBatch(){
        Test.startTest();
        updateDSEAdoptionReportColumnsSchedule myClass = new updateDSEAdoptionReportColumnsSchedule();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }  
    @isTest
    static void updateDSEAdoptionReportMTDSchedule(){
        Test.startTest();
        updateDSEAdoptionReportMTDSchedule myClass = new updateDSEAdoptionReportMTDSchedule();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }  
    @isTest
    static void updateDSEAdoptionReportMonthlySchedule(){
        Test.startTest();
        updateDSEAdoptionReportMonthlySchedule myClass = new updateDSEAdoptionReportMonthlySchedule();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }  
    
    @isTest
    static void EnquiryReSyncBatchManual(){
        Test.startTest();
        EnquiryReSyncBatchManual b= new EnquiryReSyncBatchManual();   
        database.executeBatch(b);
        test.stopTest();
    }   
    
}