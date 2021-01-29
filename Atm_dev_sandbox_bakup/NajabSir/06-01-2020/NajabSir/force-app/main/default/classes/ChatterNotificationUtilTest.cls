/**
 * @File Name          : ChatterNotificationUtilTest.cls
 * @Description        : Test Class of the apex class 'ChatterNotificationUtil'
 * @Author             : Deepak Kumar
**/

@IsTest
private class ChatterNotificationUtilTest {
    @testSetup static void createTestData() {
        List<Account> personAccounts = TestDataFactory.createPersonAccount(1);
        insert personAccounts;
    }
    static testMethod void sendChatterNotificationTest() {
        Test.startTest();
        //    Map<Id, Set<String>> escalationUsers,Map<Id, String> recordIdVsMessageMap
        List<Account> personAccounts = [SELECT Id FROM Account LIMIT 1];
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Set<String> usersSet = new Set<String>();
        usersSet.add(String.valueOf(UserInfo.getUserId()));
        escalationUsers.put(personAccounts[0].Id, usersSet);
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        recordIdVsMessageMap.put(personAccounts[0].Id, 'Test Message');
        ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
        Test.stopTest();
    }
}