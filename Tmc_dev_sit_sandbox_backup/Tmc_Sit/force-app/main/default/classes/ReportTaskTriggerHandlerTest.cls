/**
 * @File Name          : ReportTaskTriggerHandlerTest.cls
 * @Description        : Trigger handler test class 
 * @Author             : 
 * @Group              :
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 
**/
@isTest

public class ReportTaskTriggerHandlerTest{

    @testSetup
     //Customer Account
    static void testSetup(){
        Id caseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        Implementation_Strategy__c ImplementationStrategyRecord2 = TestDataFactory.createImplementation('CaseMIRenewalTriggerServiceImpl','MI_Renewal');
        Implementation_Strategy__c ImplementationStrategyRecord3 = TestDataFactory.createImplementation('CaseDoNoCallRequestsTriggerServiceImpl','Do_No_Call_Requests');
        Implementation_Strategy__c ImplementationStrategyRecord4 = TestDataFactory.createImplementation('CaseDICTriggerServiceImpl','Dealer_Internal_Complaint');
        Implementation_Strategy__c ImplementationStrategyRecord5 = TestDataFactory.createImplementation('CaseDIFTriggerServiceImpl','Dealer_Internal_Feedback');
        Implementation_Strategy__c ImplementationStrategyRecord6 = TestDataFactory.createImplementation('CaseDIRTriggerServiceImpl','Dealer_Internal_Request');
        Implementation_Strategy__c ImplementationStrategyRecord7 = TestDataFactory.createImplementation('CaseDIQTriggerServiceImpl','Dealer_Internal_Query');
        impList.add(ImplementationStrategyRecord1);
        impList.add(ImplementationStrategyRecord2);
        impList.add(ImplementationStrategyRecord3);
        impList.add(ImplementationStrategyRecord4);
        impList.add(ImplementationStrategyRecord5);
        impList.add(ImplementationStrategyRecord6);
        impList.add(ImplementationStrategyRecord7);
        Database.insert(impList,false); 
        Account accObj = new Account();
        //accObj.IsPersonAccount = true;
        accObj.FirstName = 'Customer';
        accObj.LastName = 'Test';
        accObj.PersonMobilePhone = '9890123456';
        insert accObj;
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].LastName='Test User';
        insert customerRec[0];
        // To create Case records
        List<Case> css = TestDataFactory.createCase(1,caseRecordTypeId);
        css[0].Status='New';css[0].Customer__C=customerRec[0].Id;
        INSERT css;
        List<ReportTask__c> taskList = new List<ReportTask__c>();
        
        ReportTask__c taskObj = new ReportTask__c();
        taskObj.Status__c = 'Open';
        taskObj.Priority__c = 'Normal';
        //taskObj.RecordTypeId = taskRecordTypeId;
        taskObj.OwnerId = UserInfo.getUserId(); 
        taskObj.Contact_ID__c = accObj.Id; 
        taskObj.WhatId__c = css[0].id;
        taskList.add(taskObj);
        
        INSERT taskList;
        UPDATE taskList;
        
    }
    
    @isTest
    static void reportTaskCloneTest(){
        List<ReportTask__c> taskList = [SELECT Id,Name  FROM ReportTask__c];
    }
}