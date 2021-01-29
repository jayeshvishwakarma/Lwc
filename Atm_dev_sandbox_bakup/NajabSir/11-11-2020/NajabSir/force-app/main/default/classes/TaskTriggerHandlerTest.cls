/**
* @Autho:- Nishant Prajapati
* @Company-: Techmatrix Consulting
* @Description-: Test class of TaskTriggerHandler
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       24 Sept 2019    Nishant     Intial Version
**/
@istest
public class TaskTriggerHandlerTest {
    
    @testSetup static void createTestData() {
        
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        
        Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('OpportunityVehicleTriggerServiceImpl', 'Vehicle_Sales');
        ImplementationStrategyRecord1.Use_Case__c = 'OpportunityTriggers';
        insert ImplementationStrategyRecord1;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        LIst<Campaign> campaigns = TestDataFactory.createCampaign(1);
        insert campaigns;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert businessAccountList;
        
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Business_Area__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
            c.Outlet_Type__c = 'Arena Sales Outlets';
            c.Case_Type__c = ConstantsUtility.COMPLAINT_CASE_TYPE;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.FCR_Conducted__c = 'Yes';
            c.CCP_Status__c = ConstantsUtility.CCP_STATUS_NOT_CONTACTED_INCOMPLETE;
            c.CampaignId__c = campaigns[0].Id;
            c.CCP_Outbound_Call_To__c = ConstantsUtility.CCP_OUTBOUND_CALL_TO_CUSTOMER;
        }
        insert casesList;
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].StageName = ConstantsUtility.STAGE_NEW;
        insert oppList;
        Id recordTypeId = ConstantsUtility.TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID;
        LIst<Task> taskList = TestDataFactory.createTask(1, oppList[0], recordTypeId);
        User otherUser = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1];
        for (Task task : taskList) {
            task.WhatId = casesList[0].id;
            task.OwnerId = otherUser.Id;
            task.CallType = ConstantsUtility.CALL_TYPE_OUTBOUND;
            task.Disposition_Code__c = '0';
            task.Disposition_Detail__c = 'Customer phone did not answer';
            task.CallType = ConstantsUtility.CALL_TYPE_OUTBOUND;
        }
        insert taskList;
        
    }
    static testmethod void vaidateRestrictUser2DelTask() {
        List<Account> accts = TestDataFactory.createPersonAccount(1);
        insert accts;
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate = System.today().addMonths(1);
        oppList[0].Line_Of_Business__c = 'Nexa';
        oppList[0].StageName = 'New';
        insert oppList;
        
        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'test';
        T.OwnerId = userinfo.getUserId();
        T.WhatId = oppList[0].id;
        insert T;
        delete T;
        
    }
    static testmethod void vaidateCaptureClosedGeneralTaskDetail() {
        List<Account> accts = TestDataFactory.createPersonAccount(1);
        Insert accts;
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate = System.today().addMonths(1);
        oppList[0].Line_Of_Business__c = 'Nexa';
        oppList[0].StageName = 'New';
        insert oppList;
        
        string tskgeneralRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE).getRecordTypeId();
        
        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'test';
        T.recordTypeId = tskgeneralRecordTypeId;
        T.Status = ConstantsUtility.STATUS_COMPLETED;
        T.OwnerId = userinfo.getUserId();
        T.WhatId = oppList[0].id;
        insert T;
        update T;
        
    }
    
    // Added By Deepak
    static testmethod void updateCCPDetailsOnCaseUpdateTest() {
        Test.startTest();
        Task taskObj = [SELECT Id,Wrap_Up_Code__c FROM Task WHERE RecordTypeId = :ConstantsUtility.TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID LIMIT 1];
        taskObj.Wrap_Up_Code__c = ConstantsUtility.WRAP_UP_CODE_NEXT_CALL;
        update taskObj;
        Test.stopTest();
    }
    
    //Added by Anas Yar Khan
    static testmethod void updateCustomActivityTest() {
        Test.startTest();
        List<Custom_Activity__c> listCustomActivity = TestDataFactory.createCustomActivity(1,'MOS Task');
        insert listCustomActivity;
        List<Task> listTask = TestDataFactory.createTaskMOS(1,'MOS Task');
        listTask[0].WhatId = listCustomActivity[0].Id;
        insert listTask;
        update listTask;
        Test.stopTest();
    }
    
    
}