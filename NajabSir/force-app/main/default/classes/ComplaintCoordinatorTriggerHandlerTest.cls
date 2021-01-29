/**
 * @File Name          : ComplaintCoordinatorTriggerHandlerTest.cls
 * @Description        : Test Class of the apex class 'ComplaintCoordinatorTriggerHandler'
 * @Author             : Deepak Kumar
**/

@IsTest
private class ComplaintCoordinatorTriggerHandlerTest {

    @testSetup static void createTestData() {
        List<Complaint_Coordinator__c> complaintCoordinators = TestDataFactory.createComplaintCoordinator(ConstantsUtility.ARENA_CASE_CHANNEL,'Complaint Coordinator','ALTO 800',1);
        insert complaintCoordinators;
    }
    static testMethod void updateExternalIdTest() {
        Test.startTest();
        Complaint_Coordinator__c coordinator = [SELECT Id,External_Id__c,Channel__c,Model__c,Type__c FROM Complaint_Coordinator__c LIMIT 1];
        update coordinator;
       // System.assertEquals(coordinator.External_Id__c,'', 'External Id should be same');
        Test.stopTest();
    }
}