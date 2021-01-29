/**
 * @File Name          : EventTriggerHandlerTest.cls
 * @Description        : Test Class of the apex class 'EventTriggerHandler'
 * @Author             : Deepak Kumar
**/

@IsTest
private class EventTriggerHandlerTest {

    @testSetup static void createTestData() {

        List<User> lstInternalUser  = TestDataFactory.createUserData('Internal', 'Maruti Sales User',null);
        insert lstInternalUser;
        List<Account> personAccounts = TestDataFactory.createPersonAccount(1);
        insert personAccounts;
        List<Event> events = TestDataFactory.createEvents(1,personAccounts[0].Id);
        events[0].OwnerId = lstInternalUser[0].Id;
        insert events;
    }
    static testMethod void allEventsTest() {
        Test.startTest();
        List<Event> events  = [SELECT Id FROM Event];
        events[0].Delegation_Request_Status__c = ConstantsUtility.EVENT_DELEGATION_REQUEST_STATUS_ACCEPTED;
        update events;
        Test.stopTest();
    }
}