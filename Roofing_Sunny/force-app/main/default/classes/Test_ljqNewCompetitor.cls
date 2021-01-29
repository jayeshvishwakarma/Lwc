/*********************************************************************************
* Test Class: {Test_ljqNewCompetitor}
* Created by {DateCreated 12/25/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ljqNewCompetitor.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/25/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class Test_ljqNewCompetitor {

    static testMethod void myUnitTest() {
        
        Region__c rnc = TestClassUtility.createRegion('test region name','test region code', true);
        Territory__c tc = TestClassUtility.createTerritory('jackson', '2656', 'land', rnc.Id, true);
        Date sDate = date.newInstance(2014, 9, 27);
        Date eDate = date.newInstance(2014, 9, 28);
        User demoDM = TestClassUtility.createTestUser('Read Only', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        //Large_Job_Quote__c lj = TestClassUtility.createLargeJobQuote(tc.Id,demoDM.Id, 'testProject', 'testProjectType', 'testCity', 'testState', 'Job Site', 'Contract', 'testTSquareRolls','Activated',sDate, sDate, eDate, true);
        
        //ApexPages.currentPage().getParameters().put('ljqid',lj.id);
        //ApexPages.currentPage().getParameters().put('objid',lj.id);
        ljqNewCompetitor nc = new ljqNewCompetitor();
      
        nc.createNewRecord();
        nc.deleteRecord();
        nc.goBack();
      //  nc.save();
      //  nc.submit();
       // nc.doSave();
        nc.nextStep();
       /*List<SelectOption> selectOpt = nc.competitorList;
       ApexPages.currentPage().getParameters().put('isNewRecord','Yes');
       ApexPages.currentPage().getParameters().put('show','All');
       ApexPages.currentPage().getParameters().put('retURL','/test/test');
       nc = new ljqNewCompetitor();
      //LJQ_Competitor__c ljqComp = new LJQ_Competitor__c();
       ljqComp.Company_Name__c = 'test';
       ljqComp.Large_Job_Quote__c = lj.Id;
       insert ljqComp;
       nc.selectedRecordId = ljqComp.Id;
       Pagereference pr = nc.createNewRecord();
       
       nc.compt.Company_Name__c = 'test';
       nc.compt.Product__c = 'test';
       nc.compt.Price__c = 5.5;
       nc.compt.Customer__c = ljqComp.Id;
       nc.comptCont.Name = 'test';
       nc.comptcont.Company__c = 'test';
       nc.conversationDate = System.today();
       nc.doSave();
       nc.isNewContact = true;
       nc.doSave();*/
       nc.refreshCompetitorList();
       nc.selectedCompetitor = '';
    }
}