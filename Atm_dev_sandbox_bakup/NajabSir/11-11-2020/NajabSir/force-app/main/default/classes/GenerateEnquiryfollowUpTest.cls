/**
 * @File Name          : GenerateEnquiryfollowUpTest.cls
 * @Description        : 
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 30/7/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    29/7/2019 04:30 PM          Anuj Kumar            Initial Version
**/

@isTest
private class GenerateEnquiryfollowUpTest{
    
    @testSetup
    static void CreateRecords(){
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
        
        oppList[0].First_Name__c = 'Test Enquiry';
        insert oppList;
        System.assertEquals(1, oppList.size());  
        
        Id preBookRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pre Booking Follow-up').getRecordTypeId();
            
        List<Task> task = TestDataFactory.createTask(1, oppList[0], preBookRecordTypeId);
        insert task;
    }
    
    static testMethod Void codeCoverageMethodForScenario1(){
        
        List<Opportunity> oppList = new list<opportunity>([SELECT id,ownerId,StageName from opportunity]);
        Test.startTest();
            
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pre Booking Follow-up').getRecordTypeId();
            
            List<Task> taskList = TestDataFactory.createTask(1, oppList[0], taskRecordTypeId);
            insert taskList;
            system.debug('== taskLis Data '+taskList);
        
            
            list<user>usr = new list<user>([SELECT id from user]);
            system.runAs(usr[0]){
                GenerateEnquiryfollowUp.checkUserPermissions(oppList[0].Id);
            }
            
            GenerateEnquiryfollowUp.retriveOpenTaskInfo(oppList[0].Id, 'New', null);
            
            GenerateEnquiryfollowUp.retriveEnquiryInfo(oppList[0].Id);
            
            GenerateEnquiryfollowUp.retriveReasonList('Request to lost');
            
            GenerateEnquiryfollowUp.retriveSubReasonList('Family decision');
            
            GenerateEnquiryfollowUp.retriveGeneralFollowUpDetail(oppList[0].Id, taskList[0].Id);
            
            Task tk = new Task();
            tk.ReminderDateTime = system.now(); 
            tk.type = 'Call';
            tk.Enquiry_Stage__c = 'Request to lost';
            
            string taskData = Json.serialize(tk);
            
            GenerateEnquiryfollowUp.createPreOrPostOpenFollowUp(oppList[0].Id, taskData, 'Pre Booking Follow-up');
            
            Task up_tk = new Task();
            up_tk.Enquiry_Scoring__c = 'Request to lost'; 
            up_tk.Reason__c = 'Finance problem';
            up_tk.SubReason__c = 'Loan not approved';
            up_tk.Enquiry_Stage__c = 'Exploration';
            
            string up_taskData = Json.serialize(up_tk);
            
            GenerateEnquiryfollowUp.updatePreOpenFollowUp(oppList[0].Id, oppList[0].stageName, taskList[0].Id, 'Test Remark', up_taskData, taskData, 'Pre Booking Follow-up');
            
            
            GenerateEnquiryfollowUp.updateGeneralFollowUpInfo(oppList[0].Id, oppList[0].stageName, taskList[0].Id, up_taskData, taskData, 'Pre Booking Follow-up');
                        
        Test.stopTest();
    
    }
    
    static testMethod Void codeCoverageMethodForScenario2(){
        
        List<Opportunity> oppList = new list<opportunity>([SELECT id,ownerId,StageName from opportunity]);
        
        Test.startTest();
            
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Post Booking Follow-up').getRecordTypeId();
            
            List<Task> taskList = TestDataFactory.createTask(1, oppList[0], taskRecordTypeId);
            insert taskList;
            
            GenerateEnquiryfollowUp.retriveOpenTaskInfo(oppList[0].Id, 'New', null);
            
            GenerateEnquiryfollowUp.retriveEnquiryDetail(oppList[0].Id);
            
            GenerateEnquiryfollowUp.retriveReasonList('Request to lost');
            
            GenerateEnquiryfollowUp.retriveSubReasonList('Family decision');
            
            Task tk = new Task();
            tk.ReminderDateTime = system.now(); 
            tk.type = 'Call';
            tk.Enquiry_Stage__c = 'Request to lost';
            
            string taskData = Json.serialize(tk);
            
            GenerateEnquiryfollowUp.createPreOrPostOpenFollowUp(oppList[0].Id, taskData, 'Post Booking Follow-up');
            
            Task up_tk = new Task();
            up_tk.type = 'Call';
            up_tk.Enquiry_Stage__c = 'Exploration';
            up_tk.Description = 'Test Desc';
            
            string up_taskData = Json.serialize(up_tk);
            
            GenerateEnquiryfollowUp.updatePostOpenFollowUp(oppList[0].Id, oppList[0].stageName, taskList[0].Id, up_taskData, taskData, 'Post Booking Follow-up');
            
            GenerateEnquiryfollowUp.retriveOpenTaskInfo(oppList[0].Id, 'New', taskList[0].Id);
        Test.stopTest();
    
    }
    
    static testMethod Void codeCoverageMethodForScenario3(){
        List<Opportunity> oppList = new list<opportunity>([SELECT id,ownerId,StageName from opportunity]);
        Test.startTest();
            
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Post Booking Follow-up').getRecordTypeId();
            
            List<Task> taskList = TestDataFactory.createTask(1, oppList[0], taskRecordTypeId);
            insert taskList;
            
            GenerateEnquiryfollowUp.retriveOpenTaskInfo(oppList[0].Id, 'New', null);
            
            GenerateEnquiryfollowUp.retriveReasonList('Hot');
            
            GenerateEnquiryfollowUp.retriveSubReasonList('Family decision');
            
            Task tk = new Task();
            tk.ReminderDateTime = system.now() + math.random(); 
            tk.type = 'Call';
            tk.Enquiry_Stage__c = 'Hot';
            
            string taskData = Json.serialize(tk);
            
            GenerateEnquiryfollowUp.createPreOrPostOpenFollowUp(oppList[0].Id, taskData, 'Post Booking Follow-up');
            
            Task up_tk = new Task();
            up_tk.type = 'CallTT';
            up_tk.Enquiry_Stage__c = 'Exploration';
            up_tk.Description = 'Test Desc';
            
            string up_taskData = Json.serialize(up_tk);
            
            GenerateEnquiryfollowUp.updatePreOpenFollowUp(oppList[0].Id, oppList[0].stageName, taskList[0].Id, 'Test Remark', up_taskData, taskData, 'Pre Booking Follow-up');
            
            GenerateEnquiryfollowUp.updatePostOpenFollowUp(oppList[0].Id, oppList[0].stageName, taskList[0].Id, up_taskData, taskData, 'Post Booking Follow-up');
            
            GenerateEnquiryfollowUp.retriveOpenTaskInfo(oppList[0].Id, 'New', taskList[0].Id);
        Test.stopTest();
    
    }
    
}