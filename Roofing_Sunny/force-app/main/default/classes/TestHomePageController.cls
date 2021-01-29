/*********************************************************************************
* Test Class: {TestHomePageController}
* Created by  {DateCreated 12/03/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of HomePageController.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/03/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestHomePageController {

    static testMethod void myUnitTest() {
            HomePageController hpCon = new HomePageController();
            hpCon.redirectToHome();
    }
}