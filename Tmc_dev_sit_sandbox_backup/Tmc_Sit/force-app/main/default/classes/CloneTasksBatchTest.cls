/**
    * @Autho:- Sakib Beig
    * @Company-: Techmatrix Consulting
    * @Description-: Test class of CloneTasksBatch
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 
    **/
@isTest
public class CloneTasksBatchTest {
    static testmethod void test(){
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
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        //Customer Account
        Account accObj = new Account();
        //accObj.IsPersonAccount = true;
        accObj.FirstName = 'Customer';
        accObj.LastName = 'Test';
        accObj.PersonMobilePhone = '9890123456';
        insert accObj;
        
        List<Task> taskList = new List<Task>();
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('General_Task').getRecordTypeId();
        
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].LastName='Test User';
        insert customerRec;
        
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        Profile cceProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center Executive Service']; 
        Profile ccmProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center/Workshop Manager']; 
        
        List<Contact> conList = TestDataFactory.createTestContact(2,accList[0].Id);
        insert conList;
        User ccmUser = new User(Alias = 'standtt', Email='standarduserccmtest@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              title = 'MS', 
                              LocaleSidKey='en_US', ProfileId = ccmProfile.Id,ContactId = conList[0].Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduserccmtest@testorg.com'+DateTime.now().millisecond());
        insert ccmUser;
        
        User cceUser = new User(Alias = 'standtt', Email='standarduserccetest@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              title = 'MS', 
                              LocaleSidKey='en_US', ProfileId = cceProfile.Id,ContactId = conList[1].Id,managerid = ccmUser.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduserccetest@testorg.com'+DateTime.now().millisecond());
        
        insert cceUser; 
        
        List<Case> caseRecordsList = TestDataFactory.createCase(1,caseRecordTypeId);
        caseRecordsList[0].Status='New';caseRecordsList[0].Customer__C=customerRec[0].Id;
        insert caseRecordsList;
        
        //for (Integer i=0;i<200;i++){
        Task taskObj = new Task();
        taskObj.Type = 'Call';
        taskObj.Description = 'test';
        taskObj.Subject = 'Testing';
        taskObj.recordTypeId = taskRecordTypeId;
        taskObj.Status = ConstantsUtility.STATUS_COMPLETED;
        taskObj.WhatId = caseRecordsList[0].id;
        taskObj.ownerid = cceUser.Id;
        
        /*taskObj.Status = 'Open';
        taskObj.Priority = 'Normal';
        taskObj.RecordTypeId = taskRecordTypeId;
        taskObj.OwnerId = cceUser.Id; 
        taskObj.Contact_ID__c = accObj.Id; 
        taskObj.WhatId = caseRecordsList[0].id;*/
        taskList.add(taskObj);
        //}
        insert taskList;

        Test.startTest();
        CloneTasksBatch cloneBatch = new CloneTasksBatch();
        Database.executeBatch(cloneBatch,200);
        Test.stopTest();        
    }
}