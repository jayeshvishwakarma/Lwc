/**
* @File Name          : MCCommunicationServiceTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationService'
* @Author             : Gitika
**/
@IsTest
public class CaseActionCreationTest {
 @testSetup static void createTestData() {
   
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
    
    list<account> dealerList = TestDataFactory.createDealerAccount(1);
    insert dealerList;
    list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
    insert CategoryList;
   Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
    List<case> casesList = TestDataFactory.createCase(1, 'Dealer_Internal_Complaint');
    List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
    Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
    ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
    insert ImplementationStrategyRecordList;
    //Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
     
     
    for (case c : casesList) {
        c.status = 'New';
        c.Type = 'Renewal';
        c.FCR_Conducted__c = 'No';
        c.Case_Type__c='Dealer Internal Complaint';
        c.Business_Area__c='Sales';
        c.Channel__c='Arena';
        c.Dealer_Name__c=dealerList[0].id;
        c.Primary_Category_ID__c=CategoryList[0].id;
        c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
        c.Selected_Hierarchy_Type__c='sales';
        c.Assigned_Date__c=system.now();
        c.Region_Code__c ='C2';
        
    }
     system.debug('casesList---->'+casesList);
    insert casesList;
    }
    static testMethod void method1() {
          Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,ConstantsUtility.SEND_BACK_TO_QUERY_MANAGEMENT_TEAM,'test');
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,ConstantsUtility.RESPONDED_VIA_SF,'test');
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,ConstantsUtility.RESPONDED_VIA_OUTLOOK,'test');
        CaseActionCreation.updateMsilQueryResponse(casesList[0].id,'No Response Required','test');
         Test.stopTest();
    }
    static testMethod void method2() {
        Test.startTest();
        list<case> casesList =[Select Id,Status,Tertiary_Category_ID__c,Secondary_Category_ID__c,Primary_Category_ID__c from Case ];
        
        CaseActionCreation.updateCaseStatusResolved(casesList[0].id);
        CaseActionTriggerHelper.getCategoryId(casesList[0]);
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Dealer_Internal_Case_Closure', ConstantsUtility.DEALERCLOSE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
         
        insert caseActions;
        CaseActionCreation.callApprovalFlow(caseActions[0].id,'Dealer_Internal_Case_Closure');
        FileUtility__c FileUtilityRecord = TestDataFactory.createFileUtilitySetting('Dealer_Internal_Case_Closure','Dealer_Internal_Closure');
        insert FileUtilityRecord;
        CaseActionCreation.fetchcaseAction(caseActions[0].id,'Dealer_Internal_Case_Closure');
       // CaseActionCreation.getQueueId();
        Test.stopTest();
    }
     static testMethod void method3() {
        Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
        
        CaseActionCreation.updateCaseStatusResolved(casesList[0].id);
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Dealer_Internal_Case_Closure', ConstantsUtility.DEALERCLOSE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
         
        insert caseActions;
        CaseActionCreation.callApprovalFlow(caseActions[0].id,'test');
        CaseActionCreation.checkApprovalRequired(caseActions[0].id,'test','test');
        CaseActionCreation.fetchcaseAction(caseActions[0].id,'Dealer_Internal_Case_Closure');
        Test.stopTest();
    }
}