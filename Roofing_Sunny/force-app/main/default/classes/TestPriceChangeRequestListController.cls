/*********************************************************************************
* Test Class: {TestPriceChangeRequestListController}
* Created by  {DateCreated 12/03/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of PriceChangeRequestListController.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/03/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestPriceChangeRequestListController {

    static testMethod void methodA() {
        User PCUser = TestClassUtility.createTestUser('System Administrator Integration', 'PCMUSR', 'testPc@user.com', 'PC USER', 'testPc@user.com', 'PC', true);
        Region__c rnc = TestClassUtility.createRegion('testRegionName','testRegionCode', true);
        Territory__c tc = TestClassUtility.createTerritory('testTerritory', '111222','testTerritoryType', rnc.Id, true);
        User demoTM = TestClassUtility.createTestUser('Read Only', 'ts', 'test1@testabc.com', 'testUser1', 'test1@testxyz.com', 'TM', true);
        User demoDM = TestClassUtility.createTestUser('Read Only', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        User demoRM = TestClassUtility.createTestUser('Read Only', 'ts', 'test3@testabc.com', 'testUser3', 'test3@testxyz.com', 'RM', true);
        User demoRVP = TestClassUtility.createTestUser('Read Only', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'RVP', true);

     //   Hierarchy_Matrix__c hm1 = TestClassUtility.createHierarchyMatrix(tc.Id, demoTM.id, demoDM.id, demoRM.id, PCUser.id, demoRVP.id, true);

        System.runAs(PCUser){
            PriceChangeRequestListController pcrListCon = new PriceChangeRequestListController();
            pcrListCon.getStatusSelect();
            pcrListCon.getSortDirection();
            pcrListCon.setSortDirection('DESC');
           // pcrListCon.getPCR();
            pcrListCon.getPageNumber();
            pcrListCon.getTotalPages();
            
            //pcrListCon.fetchTerritories();
            pcrListCon.newPCR();
            pcrListCon.deleteRecord();
        }
    }
    static testMethod void methodB() {
        User DMUser = TestClassUtility.createTestUser('System Administrator Integration', 'DMUSR', 'testDm@user.com', 'DM USER', 'testDm@user.com', 'DM', true);
        System.runAs(DMUser){
            PriceChangeRequestListController pcrListCon = new PriceChangeRequestListController();
            pcrListCon.getStatusSelect();
            //pcrListCon.fetchTerritories();
            pcrListCon.newPCR();
            pcrListCon.deleteRecord();
        }
    }
    static testMethod void methodC() {
        User RMUser = TestClassUtility.createTestUser('System Administrator Integration', 'RMUSR', 'testRm@user.com', 'RM USER', 'testRm@user.com', 'RM', true);
        System.runAs(RMUser){
            PriceChangeRequestListController pcrListCon = new PriceChangeRequestListController();
            pcrListCon.getStatusSelect();
            //pcrListCon.fetchTerritories();
            pcrListCon.newPCR();
            pcrListCon.deleteRecord();
        }
    }
    static testMethod void methodD() {
        User RVPUser = TestClassUtility.createTestUser('System Administrator Integration', 'RVPUSR', 'testRvp@user.com', 'RVP USER', 'testRvp@user.com', 'RVP', true);
        System.runAs(RVPUser){
            PriceChangeRequestListController pcrListCon = new PriceChangeRequestListController();
            pcrListCon.getStatusSelect();
            //pcrListCon.fetchTerritories();
            pcrListCon.newPCR();
            pcrListCon.deleteRecord();
        }
    } 
    static testMethod void methodE() {
        User TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm@user.com', 'TM USER', 'testTm@user.com', 'TM', true);
        System.runAs(TMUser){
            PriceChangeRequestListController pcrListCon = new PriceChangeRequestListController();
            pcrListCon.getStatusSelect();
            //pcrListCon.fetchTerritories();
            pcrListCon.newPCR();
            pcrListCon.deleteRecord();
            pcrListCon.ViewData();
           // pcrListCon.getPCR();
            pcrListCon.FirstAP();
            pcrListCon.PreviousAP();
            pcrListCon.NextAP();
            pcrListCon.LastAP();
            pcrListCon.getPageNumber();
        }
    }    
}