/*********************************************************************************
* Test Class: {Test_LargeJobQuoteList}
* Updated by {DateCreated 12/26/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Covering Code of LargeJobQuoteList}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/26/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class Test_LargeJobQuoteList {

    static testMethod void myUnitTest() {
        Region__c rnc = TestClassUtility.createRegion('testRegionName','testRegionCode', true);
        Territory__c tc = TestClassUtility.createTerritory('testTerritory', '111222','testTerritoryType', rnc.Id, true);
        Apexpages.currentPage().getParameters().put('sortExp','LastModifiedDate');
        Apexpages.currentPage().getParameters().put('sortType','DESC');
        Apexpages.currentPage().getParameters().put('prj','test prj name');
        Apexpages.currentPage().getParameters().put('status','Saved');
        Apexpages.currentPage().getParameters().put('isBtnClicked','true');
        Apexpages.currentPage().getParameters().put('quoteNumber','10');
        Apexpages.currentPage().getParameters().put('region',rnc.Id);
        User TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'JKelly', 'test22111133@test.com', 'Kelly', 'test122222@test.com', 'TM', true);
        User demoDM = TestClassUtility.createTestUser('Read Only', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        User demoPC = TestClassUtility.createTestUser('Read Only', 'ts', 'test4@testabc.com', 'testUser4', 'test4@testxyz.com', 'PC', true);
        User demoRVP = TestClassUtility.createTestUser('Read Only', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'RVP', true);
        
        System.runAs(TMUser) {
            LargeJobQuoteList jql = new LargeJobQuoteList();
            jql.getTotalPages();
            System.debug(jql.statusOptions);
            jql.deleteRecord();
            jql.fetchJobeQuotes();
        }
        System.runAs(demoDM) {
            LargeJobQuoteList jql = new LargeJobQuoteList();
            jql.getTotalPages();
            System.debug(jql.statusOptions);
            jql.deleteRecord();
            jql.fetchJobeQuotes();
        }
        System.runAs(demoRVP) {
            LargeJobQuoteList jql = new LargeJobQuoteList();
            jql.getTotalPages();
            System.debug(jql.statusOptions);
            jql.deleteRecord();
            jql.fetchJobeQuotes();
        }
        System.runAs(demoPC) {
            LargeJobQuoteList jql = new LargeJobQuoteList();
            jql.getTotalPages();
            System.debug(jql.statusOptions);
            jql.deleteRecord();
            jql.fetchJobeQuotes();
        }
        LargeJobQuoteList jql = new LargeJobQuoteList();
            jql.getTotalPages();
            System.debug(jql.statusOptions);
            jql.deleteRecord();
            jql.fetchJobeQuotes();
    }
}