/*********************************************************************************
* Test Class: {Test_ljqProductEscalator}
* Updated by {DateCreated 12/24/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ljqProductEscalator.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/24/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class Test_ljqProductEscalator {

    static testMethod void myUnitTest1() {
        Region__c rnc = TestClassUtility.createRegion('test region name','test region code', true);
        Territory__c tc = TestClassUtility.createTerritory('jackson', '2656', 'land', rnc.Id, true);
        //Large_Job_Quote__c lq = TestClassUtility.createLargeJobQuote(tc.Id,null,null,null,null,null,null,null,null,null,null,null,null, true);
        User us=  TestClassUtility.createTestUser('Contract Manager','Danthony','rbommareddy@thresholdcs.com','Anthony','rbommareddy@thresholdcs.com','Pricing Manager',true);
        Plants__c wh =  TestClassUtility.createWarehouse('TEST',us.id, true);
         //Market_Class__c mc= TestClassUtility.createMarketClass('test', true);
        //Product_Type__c pt= TestClassUtility.createProductType('test','test','test',mc.id, true );
       // LJQ_Product__c lp = TestClassUtility.createLJQProduct(/*lq.Id,*/12,wh.id,pt.id,true); 
        Date sDate = date.newInstance(2014, 9, 28);
        Date eDate = date.newInstance(2014, 9, 28);
        //LJQ_Product_Escalator__c lpe = TestClassUtility.createLJQProductEscalator(lp.Id,10.1,10.2,sDate,eDate, true);
        
        //ApexPages.currentPage().getParameters().put('prodId',lp.Id);
       // Apexpages.currentPage().getParameters().put('retURL',lp.Id);
        ljqProductEscalator ljPE = new ljqProductEscalator();
        //ljqProductEscalator.ProductEscalator PE = new ljqProductEscalator.ProductEscalator(lpe);
        ljPE.fetchEscalators();
        ljPE.addOneMoreEscalator();
        ljPE.doSave();
        ljPE.goBack();
        
    }
    
}