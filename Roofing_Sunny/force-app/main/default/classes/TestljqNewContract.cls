/*********************************************************************************
* Test Class: {TestljqNewContract}
* Created by {DateCreated 12/05/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ljqNewContract.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/05/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestljqNewContract {

    static testMethod void myUnitTest() {
        Region__c rnc = TestClassUtility.createRegion('testRegionName','testRegionCode', true);
        Territory__c tc = TestClassUtility.createTerritory('testTerritory', '111222','testTerritoryType', rnc.Id, true);
        States__c st = TestClassUtility.createStates('Alabama','AL', true);
        Date sDate = date.newInstance(2014, 9, 27);
        Date eDate = date.newInstance(2014, 9, 28);
        Area_Price__c pa = TestClassUtility.createPriceArea('101',tc.Id, true);
        User demoTM = TestClassUtility.createTestUser('Read Only', 'ts', 'test1@testabc.com', 'testUser1', 'test1@testxyz.com', 'TM', true);
        User demoDM = TestClassUtility.createTestUser('Read Only', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        User demoRM = TestClassUtility.createTestUser('Read Only', 'ts', 'test3@testabc.com', 'testUser3', 'test3@testxyz.com', 'RM', true);
        User demoPC = TestClassUtility.createTestUser('Read Only', 'ts', 'test4@testabc.com', 'testUser4', 'test4@testxyz.com', 'PC', true);
        User demoRVP = TestClassUtility.createTestUser('Read Only', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'RVP', true);

        /*Hierarchy_Matrix__c hm1 = TestClassUtility.createHierarchyMatrix(tc.Id, demoTM.id, demoDM.id, demoRM.id, demoPC.id, demoRVP.id, true);
        Hierarchy_Matrix__c hm2 = TestClassUtility.createHierarchyMatrix(tc.Id, demoTM.id, demoDM.id, demoRM.id, demoPC.id, demoRVP.id, true);*/
        
        //Large_Job_Quote__c lj = TestClassUtility.createLargeJobQuote(tc.Id,demoTM.id, 'testProject', 'testProjectType', '', '', 'Distributors Warehouse', 'Contract and Invoice Verification', 'testTSquareRolls','Activated',sDate, sDate, eDate, true);
        //LJQ_Contract__c ljqCont = TestClassUtility.createLJQContract(/*lj.Id,*/ true); 
        //Apexpages.currentPage().getParameters().put('ljqid',lj.Id);
       // ljqNewContract ljqNewCont = new ljqNewContract();
        //ljqNewCont.goBack();
       // ljqNewCont.doSave();
       // Apexpages.currentPage().getParameters().put('objId',ljqCont.Id);
       // ljqNewContract ljqNewCont1 = new ljqNewContract();
        System.assertEquals(rnc.Name,'testRegionName'); 
    }
}