/**
* @File Name          : CaseActionTriggerHandlerTest.cls
* @Description        : Test Class of the apex class 'CaseActionTriggerHandler'
* @Author             : Gitika
**/
@IsTest
public class CaseActionTriggerHandlerTest {
    @testSetup static void createTestData() {
        
        list<account> dealerList = TestDataFactory.createDealerAccount(1);
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        Implementation_Strategy__c ImplementationStrategyRecordMSILQuery = TestDataFactory.createImplementation('CaseMSILQueryInternalTriggerServiceImpl','MSIL_Query_Internal');
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        ImplementationStrategyRecordList.add(ImplementationStrategyRecordMSILQuery);
        
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Id MSIL_Query_InternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        List<case> casesListMSILQuery = TestDataFactory.createCase(1, MSIL_Query_InternalRecordType);
        
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L2B","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        
        for (case c : casesListMSILQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='MSIL Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            // c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":null,"msilQuery":[{"stakeHolder":"MGR-Brand","refName":"Isha Agnihotri","recordId":"0057F0000072DPEQA2","phone":"","email":"gitika.k@techmatrixconsulting.com"},{"stakeHolder":"MGR-CCC","refName":"Kapil Khanna","recordId":"0057F000006zcetQAA","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msgp":null,"msds":null,"loyaltyProgram":null,"finance":null,"accessories":null}';
            c.Selected_Hierarchy_Type__c='msilQuery';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        casesList.addall(casesListMSILQuery);
        insert casesList; 
    }
    static testMethod void method1() {
        Test.startTest();
        list<case> casesList=[Select id from case];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        list<Case_Actions__c> caseActionsOnHold = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        for(Case_Actions__c cs : caseActionsOnHold){
            cs.Hold_Till_Date__c=system.today().adddays(20);
            cs.Hold_Start_Date__c=system.today();
        }
        caseActions.addall(caseActionsOnHold);
        insert caseActions;
        Test.stopTest();
    }
    
}