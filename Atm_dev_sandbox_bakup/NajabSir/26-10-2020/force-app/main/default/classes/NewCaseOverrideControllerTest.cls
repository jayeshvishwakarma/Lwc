/**
 * @File Name          : NewCaseOverrideControllerTest.cls
 * @Description        : Test Class of the apex class 'NewCaseOverrideController'
 * @Author             : Deepak Kumar
**/

@IsTest
private class NewCaseOverrideControllerTest {
    static testMethod void getCurrentUserProfileNameTest() {
        Test.startTest();
        NewCaseOverrideController.getCurrentUserProfileName();
        Test.stopTest();
    }
}