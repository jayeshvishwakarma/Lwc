/**
* @File Name          : MCCommunicationServiceTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationService'
* @Author             : Gitika
**/
@IsTest
public class CaseActionCreationTest {
 @testSetup static void createTestData() {
   
    list<account> dealerList = TestDataFactory.createDealerAccount(1);
    insert dealerList;
    list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
    insert CategoryList;
    List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
    Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
    
    ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
    insert ImplementationStrategyRecordList;
    Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
    List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
    for (case c : casesList) {
        c.status = 'New';
        c.Type = 'Renewal';
        c.FCR_Conducted__c = 'No';
        c.Case_Type__c='Complaint';
        c.Business_Area__c='Sales';
        c.Channel__c='Arena';
        c.Dealer_Name__c=dealerList[0].id;
        c.Primary_Category_ID__c=CategoryList[0].id;
        c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
        c.Selected_Hierarchy_Type__c='sales';
        c.Assigned_Date__c=system.now();
        c.Region_Code__c ='C2';
        c.FCR_Conducted__c = 'Yes';
    }
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
        list<case> casesList =[Select Id,Status from Case ];
        
        CaseActionCreation.updateCaseStatusResolved(casesList[0].id);
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
         
        insert caseActions;
        CaseActionCreation.callApprovalFlow(caseActions[0].id,'Case_Closure');
        FileUtility__c FileUtilityRecord = TestDataFactory.createFileUtilitySetting('Case_Closure','Case_Closure');
        insert FileUtilityRecord;
        CaseActionCreation.fetchcaseAction(caseActions[0].id,'Case_Closure');
        CaseActionCreation.getQueueId();
        Test.stopTest();
    }
     static testMethod void method3() {
        Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
         
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
         
        insert caseActions;
         
        Test.stopTest();
    }
}