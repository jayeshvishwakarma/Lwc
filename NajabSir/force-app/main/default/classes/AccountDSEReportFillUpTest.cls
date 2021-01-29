/**
        * @Autho:- Rahul Sharma
        * @Company-: MSIL
        * @Description-: Test class for AccountDSEReportFillUp.
        **/
        
    @istest
    public class AccountDSEReportFillUpTest {
        
        @testSetup
        static void CreateMethod(){
            
            List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
            insert forCodeList;
        
            List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
            accountList[0].For_Code__c = forCodeList[0].Id;
            insert accountList;
        
            List<Contact> conList = TestDataFactory.createTestContact(1, accountList[0].Id);
            conList[0].LastName = 'Test Sc2';
            insert conList;
            System.assertEquals(1, conList.size());
            User usr = TestDataFactory.generateUserData('Dealer Hostess', conList[0].Id, 'Dealer Sales Executive');
            
            User u = [Select Id from User where Profile.Name = 'Dealer Sales Executive' and IsActive = True Limit 1];
            system.debug('user id is : '+ u.id);
            List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
            userAccountList[0].User__c = u.Id;
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
            oppList[0].ownerId = u.Id;
           oppList[0].Model_Code__c= 'BA';
           oppList[0].DMS_Sync_Error_Details__c = 'BA';
            oppList[0].Variant__c= productList[0].Id;
          
            insert oppList;
            
            Id preBookRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pre Booking Follow-up').getRecordTypeId();
            
            List<Task> task = TestDataFactory.createTask(1, oppList[0], preBookRecordTypeId);
            insert task;
            
            system.runAs(u)
            {
                list<Event_Visit_Plan__c> eventList = TestDataFactory.createEventsPlans(200);
                for(Event_Visit_Plan__c evp : eventList){
                evp.OwnerId = u.Id;
                evp.Assigned_Sales_Exec__c = u.Id;
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
        static void EnquiryReSyncBatchManual(){
                    Test.startTest();
                    EnquiryReSyncBatchManual b= new EnquiryReSyncBatchManual();   
                    database.executeBatch(b);
                    test.stopTest();
                }   
                       
    }