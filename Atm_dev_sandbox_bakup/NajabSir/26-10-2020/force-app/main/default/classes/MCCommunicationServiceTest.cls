/**
* @File Name          : MCCommunicationServiceTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationService'
* @Author             : Gitika
**/
@IsTest
public class MCCommunicationServiceTest {
    @testSetup static void createTestData() {
        
        list<account> dealerList = TestDataFactory.createDealerAccount(1);
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        Implementation_Strategy__c ImplementationStrategyRecordMSILQuery = TestDataFactory.createImplementation('CaseMSILQueryInternalTriggerServiceImpl','MSIL_Query_Internal');
        Implementation_Strategy__c ImplementationStrategyRecordFeedback = TestDataFactory.createImplementation('CaseQueryFeedbackTriggerServiceImpl','Query_Feedback');
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        ImplementationStrategyRecordList.add(ImplementationStrategyRecordMSILQuery);
        ImplementationStrategyRecordList.add(ImplementationStrategyRecordFeedback);
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Id MSIL_Query_InternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        List<case> casesListfeedback = TestDataFactory.createCase(1, ComplaintRecordType);
        List<case> casesListQuery = TestDataFactory.createCase(1, ComplaintRecordType);
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
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+userinfo.getUserId().left(15)+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        for (case c : casesListfeedback) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c=ConstantsUtility.DEALER_FEEDBACK_CASE_TYPE;
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        casesList.addall(casesListfeedback);
        for (case c : casesListQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Dealer Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        casesList.addall(casesListQuery);
        for (case c : casesListMSILQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='MSIL Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            // c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":null,"msilQuery":[{"stakeHolder":"MGR-Brand","refName":"Isha Agnihotri","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"},{"stakeHolder":"MGR-CCC","refName":"Kapil Khanna","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msgp":null,"msds":null,"loyaltyProgram":null,"finance":null,"accessories":null}';
            c.Selected_Hierarchy_Type__c='msilQuery';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        casesList.addall(casesListMSILQuery);
        insert casesList; 
    }
    static testMethod void method1() {
        Test.startTest();
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Id Query_FeedbackRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query_Feedback').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, Query_FeedbackRecordType);
        List<case> casesListComplaint = TestDataFactory.createCase(1, ComplaintRecordType);
        account acc =[select id from account];
        Category__c cat =[select id from Category__c];
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Dealer Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=acc.id;
            c.Primary_Category_ID__c=Cat.id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        for (case c : casesListComplaint) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=acc.id;
            c.Primary_Category_ID__c=Cat.id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        casesList.addall(casesListComplaint);
        insert casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        list<Case_Actions__c> caseActions1 = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesListComplaint[0].Id);
        list<Case_Actions__c> caseActions2 = TestDataFactory.createCaseActions(1, 'On Hold', ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesListComplaint[0].Id);
        caseActions.addall(caseActions1);
        caseActions.addall(caseActions2);
        insert caseActions;
        Test.stopTest();
    }
    static testMethod void method2() {
        Test.startTest();   
        Id MSIL_Query_InternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        Category__c cat =[select id from Category__c];
        List<case> casesListMSILQuery = TestDataFactory.createCase(1, MSIL_Query_InternalRecordType);
        for (case c : casesListMSILQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='MSIL Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            // c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=Cat.id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":null,"msilQuery":[{"stakeHolder":"MGR-Brand","refName":"Isha Agnihotri","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"},{"stakeHolder":"MGR-CCC","refName":"Kapil Khanna","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msgp":null,"msds":null,"loyaltyProgram":null,"finance":null,"accessories":null}';
            c.Selected_Hierarchy_Type__c='msilQuery';
            c.Assigned_Date__c=system.now();
            // c.Region_Code__c ='C2';
        }
        insert casesListMSILQuery;
        MCCommunicationService.getStakeHolderMappingForMSILQuery(casesListMSILQuery[0].Stakeholders_JSON__c,casesListMSILQuery[0].Selected_Hierarchy_Type__c);
        casesListMSILQuery[0].status='Closed';
        update casesListMSILQuery[0];
        Test.stopTest();
    }
}