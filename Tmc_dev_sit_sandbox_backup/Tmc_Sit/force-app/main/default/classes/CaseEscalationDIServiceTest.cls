/**
* @File Name          : CaseEscalationServiceTest.cls
* @Description        : Test Class of the apex class 'CaseEscalationService'
* @Author             : Deepak Kumar
*
1.2A   21/8/2020  Gitika    Added methods for Case CCP and Resolution Escalation
*/
@IsTest
private class CaseEscalationDIServiceTest {

    @testSetup static void createTestData() {

        // Creating Case_Escalations_Matrix_MDT__c records for Escalations
        Case_Escalations_Matrix_MDT__c escalations_matrix = new Case_Escalations_Matrix_MDT__c();
        escalations_matrix.Name = 'Transfer Escalation Level 1';
        escalations_matrix.Escalation_Type__c = ConstantsUtility.ESCALATION_TYPE_TRANSFER;
        escalations_matrix.Case_Type__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        escalations_matrix.Escalation_Level__c = 'Level 1';
        escalations_matrix.Time_to_Next_Escalation__c = 1;
        escalations_matrix.Notifiers__c = 'L5';
        escalations_matrix.highest_level_escalation__c='Level 4';

        // insert escalations_matrix;
        list<account> dealerList = TestDataFactory.createDealerAccount(1);
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
       /* Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        List<Implementation_Strategy__c> impList1= new List<Implementation_Strategy__c>();
        impList1.add(ImplementationStrategyRecord);
        insert impList1;*/
        List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        Implementation_Strategy__c ImplementationStrategyRecord2 = TestDataFactory.createImplementation('CaseMIRenewalTriggerServiceImpl','MI_Renewal');
        Implementation_Strategy__c ImplementationStrategyRecord3 = TestDataFactory.createImplementation('CaseDoNoCallRequestsTriggerServiceImpl','Do_No_Call_Requests');
        Implementation_Strategy__c ImplementationStrategyRecord4 = TestDataFactory.createImplementation('CaseDICTriggerServiceImpl','Dealer_Internal_Complaint');
        Implementation_Strategy__c ImplementationStrategyRecord5 = TestDataFactory.createImplementation('CaseDIFTriggerServiceImpl','Dealer_Internal_Feedback');
        Implementation_Strategy__c ImplementationStrategyRecord6 = TestDataFactory.createImplementation('CaseDIRTriggerServiceImpl','Dealer_Internal_Request');
        Implementation_Strategy__c ImplementationStrategyRecord7 = TestDataFactory.createImplementation('CaseDIQTriggerServiceImpl','Dealer_Internal_Query');
        //Implementation_Strategy__c ImplementationStrategyRecord8 = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        impList.add(ImplementationStrategyRecord1);
        impList.add(ImplementationStrategyRecord2);
        impList.add(ImplementationStrategyRecord3);
        impList.add(ImplementationStrategyRecord4);
        impList.add(ImplementationStrategyRecord5);
        impList.add(ImplementationStrategyRecord6);
        impList.add(ImplementationStrategyRecord7);
       // impList.add(ImplementationStrategyRecord8);
        Database.insert(impList,false);
       // Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, 'Dealer_Internal_Complaint');
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Dealer Internal Complaint';
            c.Business_Area__c='Sales';
            c.Case_Stage__c = 'Pre Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
            //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        List<case> casesListDealerInternal = TestDataFactory.createCase(4, 'Dealer_Internal_Complaint');
        for (case c : casesListDealerInternal) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Dealer Internal Complaint';
            c.Business_Area__c='Sales';
            c.Case_Stage__c = 'Pre Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
            //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
           // c.BusinessHoursId=label.Business_Hour_Id;
            casesList.add(c);
        }
        List<case> casesListDealerInternalQuery = TestDataFactory.createCase(2, 'Dealer_Internal_Query');
        for (case c : casesListDealerInternalQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Dealer Internal Query';
            c.Business_Area__c='Sales';
            c.Case_Stage__c = 'Pre Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
            //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
          //  c.BusinessHoursId=label.Business_Hour_Id;
            casesList.add(c);
        }
        List<case> casesListDealerInternalRequest = TestDataFactory.createCase(2, 'Dealer_Internal_Request');
        for (case c : casesListDealerInternalRequest) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Dealer Internal Request';
            c.Business_Area__c='MIBPL (Insurance)';
            c.Channel__c='MI';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
            //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
         //   c.BusinessHoursId=label.Business_Hour_Id;
            casesList.add(c);
        }

        //casesList[2].BusinessHoursId='01m7F000000fzV2';
        insert casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Dealer Internal Transfer', ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER, casesList[0].Id);
        caseActions[0].Transfer_Escalation_Date_Time__c = Datetime.now().addHours(-1);
        caseActions[0].L1_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L2A_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L3A_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L4_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L5_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L6A_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L7A_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L8A_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L9_Stakeholder__c = UserInfo.getUserId();
        caseActions[0].L10_Stakeholder__c = UserInfo.getUserId();
        //caseActions[0].Transfer_Escalation_Notifiers__c='L1A';
        caseActions[1].Transfer_Escalation_Date_Time__c = Datetime.now().addHours(-1);
        caseActions[1].L1_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L2A_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L3A_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L4_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L5_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L6A_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L7A_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L8A_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L9_Stakeholder__c = UserInfo.getUserId();
        caseActions[1].L10_Stakeholder__c = UserInfo.getUserId();
        insert caseActions;
        //added by Prashant Gahlaut
       // Implementation_Strategy__c stratagyComplaint = TestDataFactory.implmentationSetting('CaseDICTriggerServiceImpl','Dealer_Internal_Complaint','Test');
       // insert stratagyComplaint;

    }
    // this test method will cover updateTransferEscalationsBeforeUpdate and updateTransferEscalationsAfterUpdate both
    static testMethod void updateTransferEscalationsBeforeUpdateTest() {
        Test.startTest();
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>([SELECT Id FROM Case_Actions__c]);
        caseActions[0].Transfer_Escalation_Date_Time__c = Datetime.now();
        caseActions[1].Transfer_Escalation_Date_Time__c = Datetime.now();
        caseActions[1].Transfer_Escalation_Day__c=1;
        update caseActions;
        Test.stopTest();
    }
    static testMethod void getUserLevelUsersTest() {
        Test.startTest();
        List<Case_Actions__c> caseActions = [SELECT Id,L1_Stakeholder__c,L2A_Stakeholder__c,L3A_Stakeholder__c,L4_Stakeholder__c,L5_Stakeholder__c,L6A_Stakeholder__c,L7A_Stakeholder__c,L8A_Stakeholder__c,L9_Stakeholder__c,L10_Stakeholder__c FROM Case_Actions__c];
        List<Id> ids = new List<Id>();
        for (Integer i = 0; i < 1; i++) {
            ids.add(UserInfo.getUserId());
        }
        //CaseEscalationService.getUserLevelUsers(ids,caseActions[0]);
        caseActions[0].L1_Stakeholder__c='0057F000006zces';
        update caseActions[0];
        //CaseEscalationService.getUserLevelUsers(ids,caseActions[0]);
        caseActions[0].L2A_Stakeholder__c='0057F000006zces';
        update caseActions[0];
        //CaseEscalationService.getUserLevelUsers(ids,caseActions[0]);
        Test.stopTest();
    }
    static testMethod void updateCallTest() {
        Test.startTest();
        list<case> caseList = [select id,CCP_Escalated__c,Channel__c,CCP_Escalated_Level__c,Case_Resolution_Escalated__c,Next_Escalation_Date__c from case];
        System.debug('S test');
        System.debug(caseList[0].Channel__c);
        caseList[0].CCP_Escalated__c=true;
        caseList[0].Case_Resolution_Escalated__c=true;
        caseList[0].Next_Escalation_Date__c=system.today();
        caseList[1].CCP_Escalated__c=true;
        caseList[1].CCP_Escalated_Level__c='Level 1';
        caseList[2].CCP_Escalated__c=true;
        caseList[2].Case_Resolution_Escalated__c=true;
        caseList[2].Next_Escalation_Date__c=system.today();
        caseList[3].CCP_Escalated__c=true;
        caseList[3].CCP_Escalated_Level__c='Level 1';
        caseList[4].CCP_Escalated__c=true;
        caseList[4].CCP_Escalated_Level__c='Level 3';
        caseList[4].CCP_Next_Escalated_Level__c='Level 4';
        caseList[6].CCP_Escalated__c=true;
        caseList[6].Case_Resolution_Escalated__c=true;
        caseList[6].Next_Escalation_Date__c=system.today();
        //caseList[4].Next_Escalation_Date__c='2020-10';
        update caseList;
        Test.stopTest();
    }

    /*static testMethod void updateCallTestForCCP() {
        Test.startTest();
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dealer_Internal_Complaint').getRecordTypeId();
        list<case> caseList = [select id,CCP_Escalated__c,CCP_Escalated_Level__c,Case_Resolution_Escalated__c,Next_Escalation_Date__c from case];
        caseList[0].CCP_Escalated__c=true;
        caseList[0].Case_Resolution_Escalated__c=true;
        caseList[0].recordTypeId=caseRecTypeId;
        caseList[0].Next_Escalation_Date__c=system.today();
        update caseList[0];
        Test.stopTest();
    }*/
    static testMethod void postChatterAndMCRecordsEscalationTest() {
        Test.startTest();
        list<Category__c> CategoryList=[select id from Category__c];
        List<Recipient_Master__c> RecipientMasterList = TestDataFactory.createRecipientMaster(1,'Sales');
        insert RecipientMasterList;
        /*List<Recipient_List__c> RecipientList = TestDataFactory.createRecipientList(1,CategoryList[0].id,RecipientMasterList[0].id);
        RecipientList[0].region__c ='C2';
        insert RecipientList;
        list<case> caseList = [select id,CCP_Escalated__c,Region_Code__c ,CCP_Escalated_Level__c,Case_Resolution_Escalated__c,Next_Escalation_Date__c from case];
        caseList[0].Next_Escalation_Date__c=system.now();
        update caseList[0];
        caseList[0].Next_Escalation_Date__c=system.now().adddays(1);
        update caseList[0];*/

        Test.stopTest();
    }

}