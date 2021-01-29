/*********************************************************************************
* Test Class: {TestLJQ_RM_RejectionEMail}
* Created by  {DateCreated 12/05/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of LJQ_RM_RejectionEMail.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/05/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestLJQ_RM_RejectionEMail {

    static testMethod void myUnitTest() {
        Region__c rnc = TestClassUtility.createRegion('testRegionName','testRegionCode', true);
        Territory__c tc = TestClassUtility.createTerritory('testTerritory', '111222','testTerritoryType', rnc.Id, true);
        Date sDate = date.newInstance(2014, 9, 27);
        Date eDate = date.newInstance(2014, 9, 28);
        User demoRM = TestClassUtility.createTestUser('Read Only', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'RM', true);
        //Large_Job_Quote__c lj = TestClassUtility.createLargeJobQuote(tc.Id,demoRM.Id, 'testProject', 'testProjectType', 'testCity', 'testState', 'Job Site', 'Contract', 'testTSquareRolls','Activated',sDate, sDate, eDate, true);
        LJQ_RM_RejectionEMail lrrEmail = new LJQ_RM_RejectionEMail();
        //lrrEmail.objId = lj.id;
        lrrEmail.ljq = null;
        System.debug(lrrEmail.ljq);
        System.assertEquals(rnc.Name, 'testRegionName');
    }
}