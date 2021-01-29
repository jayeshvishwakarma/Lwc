/**
* @File Name          : CaseEscalationServiceTest.cls
* @Description        : Test Class of the apex class 'CaseEscalationService'
* @Author             : Deepak Kumar
*
1.2A   21/8/2020  Gitika    Added methods for Case CCP and Resolution Escalation
*/
@IsTest
private class CaseEscalationServiceTest {
    
    @testSetup static void createTestData() {
        
        // Creating Case_Escalations_Matrix__mdt records for Escalations
        Case_Escalations_Matrix__mdt escalations_matrix = new Case_Escalations_Matrix__mdt();
        escalations_matrix.MasterLabel = 'Transfer Escalation Level 1';
        escalations_matrix.DeveloperName = 'Transfer_Escalation_Level_1';
        escalations_matrix.Escalation_Type__c = ConstantsUtility.ESCALATION_TYPE_TRANSFER;
        escalations_matrix.Case_Type__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        escalations_matrix.Escalation_Level__c = 'Level 1';
        escalations_matrix.Time_to_Next_Escalation__c = 1;
        escalations_matrix.Notifiers__c = 'L5';
        
        
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Account> dealerList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        dealerList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        list<For_Code__c> ForCodeList= TestDataFactory.createTestForCode(1);
        insert ForCodeList;
        list<Product2> Product2List= TestDataFactory.createProducts('Variants',1);
        insert Product2List;
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.FCR_Conducted__c = 'Yes';
            c.For_Code__c=ForCodeList[0].id;
            c.Variant__c=Product2List[0].id;
        }
        insert casesList;
        list<MC_Communication__c> mcList = TestDataFactory.createMCCommData(2,NULL);
        mcList[0].case__c=casesList[0].id;
        mcList[0].Status__c = 'Queued';
        mcList[0].Communication_Type__c='SMS';
        mcList[0].type__c=ConstantsUtility.CCP;
        mcList[1].case__c=casesList[0].id;
        mcList[1].Status__c = 'Queued';
        mcList[1].Communication_Type__c='SMS';
        mcList[1].type__c=ConstantsUtility.DEALER_RESOLUTION_ESCALATION;
        insert mcList;
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
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
        insert caseActions;
        
        
    }
    // this test method will cover updateTransferEscalationsBeforeUpdate and updateTransferEscalationsAfterUpdate both
    static testMethod void updateTransferEscalationsBeforeUpdateTest() {
        Test.startTest();
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>([SELECT Id FROM Case_Actions__c]);
        caseActions[0].Transfer_Escalation_Date_Time__c = Datetime.now();
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
        CaseEscalationService.getUserLevelUsers(ids,caseActions[0]);
        Test.stopTest();
    }
    static testMethod void updateCallTest() {
        Test.startTest();
        list<case> caseList = [select id,On_Hold_End_date__c,CCP_Escalated__c,CCP_Next_Escalation_Date_Time__c,CCP_Escalated_Level__c,Next_CCP_Escalation_Level__c,Case_Resolution_Escalated__c,Next_Escalation_Date__c from case];
        caseList[0].CCP_Escalated__c=true;
        caseList[0].Case_Resolution_Escalated__c=true;
        caseList[0].Next_Escalation_Date__c=system.today();
        update caseList[0];
        caseList[1].CCP_Escalated__c=true;
        caseList[1].CCP_Escalated_Level__c='Level 1';
        caseList[1].CCP_Next_Escalation_Date_Time__c=system.today();
        caseList[1].On_Hold_Start_date__c=system.today()-1;
        caseList[1].On_Hold_End_date__c=system.today();
        update caseList[1];
        Test.stopTest();
    }
    static testMethod void updateCallEscalationLastLevelTest() {
        Test.startTest();
        list<case> caseList = [select id,On_Hold_End_date__c,Latest_Escalation_Level__c,Next_Escalation_Level__c,CCP_Escalated__c,CCP_Escalated_Level__c,Next_CCP_Escalation_Level__c,Case_Resolution_Escalated__c,Next_Escalation_Date__c from case];
        caseList[0].CCP_Escalated__c=true;
        caseList[0].Case_Resolution_Escalated__c=true;
        caseList[0].CCP_Escalated_Level__c='Level 4';
        caseList[0].Next_Escalation_Level__c='Level 6';
        caseList[0].Latest_Escalation_Level__c='Level 6';
        caseList[0].On_Hold_End_date__c=system.today();
        caseList[0].Next_CCP_Escalation_Level__c='Level 4';
        update caseList[0];
        Test.stopTest();
    }
    static testMethod void postChatterAndMCRecordsEscalationTest() {
        Test.startTest();
        list<Category__c> CategoryList=[select id from Category__c];
        List<Recipient_Master__c> RecipientMasterList = TestDataFactory.createRecipientMaster(1,'Sales');
        insert RecipientMasterList;
        List<Recipient_List__c> RecipientList = TestDataFactory.createRecipientList(1,CategoryList[0].id,RecipientMasterList[0].id);
        RecipientList[0].region__c ='C2';
        insert RecipientList;
        list<case> caseList = [select id,CCP_Escalated__c,Region_Code__c ,CCP_Escalated_Level__c,Case_Resolution_Escalated__c,Next_Escalation_Date__c from case];
        caseList[0].Next_Escalation_Date__c=system.now();
        update caseList[0];
        caseList[0].Next_Escalation_Date__c=system.now().adddays(1);
        update caseList[0];
        list<MC_Communication__c> MCCommunicationList = new list<MC_Communication__c>();
            for(MC_Communication__c mcList:[select Status__c,id from MC_Communication__c]){
                mcList.Status__c='Picked';
                MCCommunicationList.add(mcList);
            }
        update MCCommunicationList;
        Id businessHourId = label.Business_Hour_Id;
        CaseEscalationService.getNextEscalatedDateTime(businessHourId,system.now(),20);
        Test.stopTest();
    }
    
}