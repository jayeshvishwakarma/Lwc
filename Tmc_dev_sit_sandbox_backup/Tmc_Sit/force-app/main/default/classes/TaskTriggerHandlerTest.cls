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

    }

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
        T.Subject = 'Send eBrochure';
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

    static testMethod void validateTaskTrigger(){
        Id salesPSFFollowupRecordTypeId= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Sales_PSF_Follow_Up').getRecordTypeId();
        //Insert Enquiry
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate=System.today().addMonths(1);
        oppList[0].Line_Of_Business__c ='Nexa';
        oppList[0].StageName ='New';
        insert oppList;

        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'test';
        T.recordTypeId = salesPSFFollowupRecordTypeId;
        T.Status = ConstantsUtility.STATUS_COMPLETED;
        T.WhatId = oppList[0].id;
        T.Enquiry__c= oppList[0].id;
        T.Disposition__c= 'Wrong Number';
        insert T;
        update T;


    }

    static testMethod void validateLoanAppliedOnEnquiryMethod(){
        Id bankAppointmentRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(ConstantsUtility.BANK_APPOINTMENT).getRecordTypeId();
        //Insert Enquiry
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate=System.today().addMonths(1);
        oppList[0].Line_Of_Business__c ='Nexa';
        oppList[0].StageName ='New';
        oppList[0].Loan_Applied__c= true;
        insert oppList;

        Custom_Activity__c custActObj = new Custom_Activity__c();
		custActObj.Name = 'Test';
        insert custActObj;
        
        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'test';
        T.recordTypeId = bankAppointmentRecordTypeId;
        T.Status = ConstantsUtility.STATUS_COMPLETED;
        T.WhatId = oppList[0].id;
        T.Enquiry__c= oppList[0].id;
        T.Disposition__c= 'Wrong Number';
        insert T;
        T.WhatId = custActObj.Id;
        update T;
    }
	
	static testMethod void validateUpdateCCPDetailsOnCase(){
        Id vehicleserviceRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        Id queryComplaintRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Query_Complaints_Call_Dispositions').getRecordTypeId();
        Id caseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].LastName='Test User';
        insert customerRec[0];
        List<Case> css = TestDataFactory.createCase(1,vehicleserviceRecTypeId);
        css[0].Status='New';css[0].Customer__C=customerRec[0].Id;
        
        INSERT css[0];
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].CloseDate=System.today().addMonths(1);
        oppList[0].Line_Of_Business__c ='Nexa';
        oppList[0].StageName ='New';
        oppList[0].Loan_Applied__c= true;
        insert oppList;
        Task T = new Task();
        T.Type = 'Email';
        T.Description = 'test';
        T.recordTypeId = queryComplaintRecordType;
        T.Status = ConstantsUtility.STATUS_COMPLETED;
        T.Wrap_Up_Code__c = 'Next Call';
        T.WhatId = css[0].id;
        T.CallType = 'Outbound';
        T.Enquiry__c = oppList[0].id;
        T.Disposition__c= 'Wrong Number';
        insert T;
        UPDATE T;
        
    }
    static testMethod void validateCloneTaskToReportTaskTest(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('General_Task').getRecordTypeId();
        
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        Profile cceProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center Executive Service']; 
        Profile ccmProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center/Workshop Manager']; 
        
        List<Contact> conList = TestDataFactory.createTestContact(2,accList[0].Id);
        insert conList;
        User ccmUser = new User(Alias = 'standtt', Email='standarduserccm@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              title = 'MS', 
                              LocaleSidKey='en_US', ProfileId = ccmProfile.Id,ContactId = conList[0].Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduserccm@testorg.com'+DateTime.now().millisecond());
        insert ccmUser;
        
        User cceUser = new User(Alias = 'standtt', Email='standardusercce@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              title = 'MS', 
                              LocaleSidKey='en_US', ProfileId = cceProfile.Id,ContactId = conList[1].Id,managerid = ccmUser.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standardusercce@testorg.com'+DateTime.now().millisecond());
        
        insert cceUser;
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].LastName='Test User';
        insert customerRec;
        List<Case> caseRecordsList = TestDataFactory.createCase(1,caseRecordTypeId);
        caseRecordsList[0].Status='New';caseRecordsList[0].Customer__C=customerRec[0].Id;
        insert caseRecordsList;
        
        Task T = new Task();
        T.Type = 'Call';
        T.Description = 'test';
        T.Subject = 'Testing';
        T.recordTypeId = taskRecordTypeId;
        T.Status = ConstantsUtility.STATUS_COMPLETED;
        T.WhatId = caseRecordsList[0].id;
        t.ownerid = cceUser.Id;
        insert T;
        UPDATE T;
        
    }
    
}