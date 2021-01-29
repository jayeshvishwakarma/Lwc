/*********************************************************************************
* Test Class: {TestHierarchyTerritoryNumber}
* Created by  {DateCreated 12/03/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of HierarchyTerritoryNumber.trigger}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/03/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestHierarchyTerritoryNumber {

    static testMethod void myUnitTest() {
        Region__c reg = TestClassUtility.createRegion('testReg', '23232', true);
        Territory__c terrObj = TestClassUtility.createTerritory('testName','2324', 'Residential', reg.id, true);
        User TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'JKelly', 'test22111133@test.com', 'Kelly', 'test122222@test.com', 'TM', true);
        User RMUser = TestClassUtility.createTestUser('System Administrator Integration', 'JKelly', 'test22111144@test.com', 'Kelly', 'test122333@test.com', 'RM', true);
        User DMUser = TestClassUtility.createTestUser('System Administrator Integration', 'JKelly', 'test22111155@test.com', 'Kelly', 'test122444@test.com', 'DM', true);
        User RVPUser = TestClassUtility.createTestUser('System Administrator Integration', 'JKelly', 'test22111166@test.com', 'Kelly', 'test12255@test.com', 'RVP', true);

       /* Hierarchy_Matrix__c hmObj = TestClassUtility.createHierarchyMatrix(terrObj.id, TMUser.id, null, null, null, null, true);
        Hierarchy_Matrix__c hmObj2 = TestClassUtility.createHierarchyMatrix(terrObj.id, null, DMUser.id, null, null, null, true);
        Hierarchy_Matrix__c hmObj3 = TestClassUtility.createHierarchyMatrix(terrObj.id, null, null, RMUser.id, null, null, true);
        Hierarchy_Matrix__c hmObj4 = TestClassUtility.createHierarchyMatrix(terrObj.id, null, null, null, null, RVPUser.id, true); */
        System.assertEquals(terrObj.Name, 'testName');
    }
}