/**
 * @File Name          : CaseOwnerAssignmentBatchTest.cls
 * @Description        : Test Class of the apex class 'CaseOwnerAssignmentBatch'
 * @Author             : Deepak Kumar
**/

@IsTest
private class CaseOwnerAssignmentBatchTest {
    @testSetup static void createTestData() {

        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(2, 'Dealer');
        for (Account dealer : businessAccountList) {
            dealer.Region_Code__c = 'C1';
            dealer.Channel__c = 'NRM';
            dealer.Dealer_Type__c = ConstantsUtility.DEALER_TYPE_3S;
            dealer.DMS_Primaries__c = '[ { "level":"SalesL2A", "SFID":"0051s000000yBC0", "MSPIN":"12345" }, { "level":"SalesL2B", "SFID":"0051s000000yBC0", "MSPIN":"12345" }, { "level":"ServiceL1A", "SFID":"0051s000000yBC0", "MSPIN":"12345" }, { "level":"ServiceL1B", "SFID":"0051s000000yBC0", "MSPIN":"12345" }, { "level":"ServiceL2A", "SFID":"0051s000000yBC0", "MSPIN":"12345" }, { "level":"ServiceL2B", "SFID":"0051s000000yBC0", "MSPIN":"12345" }, { "level":"PrimaryMOSTechnician", "SFID":"0051s000000yBC0", "MSPIN":"12345" }]';

        }
        businessAccountList[1].Dealer_Type__c = ConstantsUtility.DEALER_TYPE_S;
        insert businessAccountList;


        List<Complaint_Coordinator__c> complaintCoordinatorsTemp = TestDataFactory.createComplaintCoordinator('NRM', 'SNP AC Coordinator', null, 2);
        complaintCoordinatorsTemp[1].Type__c = 'Div Head';
        complaintCoordinatorsTemp[0].Region__c = 'C1';
        complaintCoordinatorsTemp[1].Region__c = 'C1';
        complaintCoordinatorsTemp[0].User__c = UserInfo.getUserId();
        complaintCoordinatorsTemp[1].User__c = UserInfo.getUserId();
        insert complaintCoordinatorsTemp;


        List<Category__c> categories = TestDataFactory.createCategories(1, 'Primary');
        categories[0].Case_Type__c = ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        insert categories;
        List<Recipient_Master__c> RecipientMasterList = TestDataFactory.createRecipientMaster(1, 'Sales');
        RecipientMasterList[0].Name = 'Arena';
        RecipientMasterList[0].External_ID__c = 'Arena_Sales';
        RecipientMasterList[0].Region__c = 'C1';
        insert RecipientMasterList;
        List<Recipient_List__c> RecipientList = TestDataFactory.createRecipientList(1, categories[0].id, RecipientMasterList[0].id);
        RecipientList[0].region__c ='C1';
        insert RecipientList;
    }
    static testMethod void ForDealerTest() {
        Test.startTest();
        CaseOwnerAssignmentBatch batch = new CaseOwnerAssignmentBatch(ConstantsUtility.ACCOUNT_OBJ);
        Database.executeBatch(batch);
        Test.stopTest();
    }
    static testMethod void ForMSILTest() {
        Test.startTest();
        CaseOwnerAssignmentBatch batch = new CaseOwnerAssignmentBatch('Msil');
        Database.executeBatch(batch);
        Test.stopTest();
    }
}