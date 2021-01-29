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
    static testmethod void vaidateRestrictUser2DelTask(){
        List<Account> accts = TestDataFactory.createPersonAccount(1);
        insert accts;
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate=System.today().addMonths(1);
        oppList[0].Line_Of_Business__c ='Nexa';
        oppList[0].StageName ='New';
        insert oppList; 
        
        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'test'; 
        T.OwnerId = userinfo.getUserId();
        T.WhatId = oppList[0].id;
        insert T;
        delete T;
        
    }
    
    static testmethod void vaidateCaptureClosedGeneralTaskDetail(){
        List<Account> accts= TestDataFactory.createPersonAccount(1);
        Insert accts;
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate=System.today().addMonths(1);
        oppList[0].Line_Of_Business__c ='Nexa';
        oppList[0].StageName ='New';
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
    
}