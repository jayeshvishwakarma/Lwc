/*********************************************************************************
* Test Class: {TestScheduleBatchProcessOrderIntake}
* Created by  {DateCreated 12/05/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ScheduleBatchProcessOrderIntake.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/05/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestScheduleBatchProcessOrderIntake {

    static testMethod void myUnitTest() {
        Test.startTest();
        ScheduleBatchProcessOrderIntake sbpoi = new ScheduleBatchProcessOrderIntake();
        sbpoi.execute(null);
        System.assert(true);
        Test.stopTest();
    }
}