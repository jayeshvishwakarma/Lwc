/*********************************************************************************
* Test Class: {Test_LJQEmailTemplate}
* Created by {DateCreated 12/25/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of LJQEmailTemplate.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/25/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class Test_LJQEmailTemplate {

    static testMethod void myUnitTest() {
        
        Region__c rnc = TestClassUtility.createRegion('testRegionName','testRegionCode', true);
        Territory__c tc = TestClassUtility.createTerritory('testTerritory', '111222','testTerritoryType', rnc.Id, true);
        Date sDate = date.newInstance(2014, 9, 27);
        Date eDate = date.newInstance(2014, 9, 28);
        User demoDM = TestClassUtility.createTestUser('Read Only', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        User us=  TestClassUtility.createTestUser('Contract Manager','Danthony','rbommareddy@thresholdcs.com','Anthony','rbommareddy@thresholdcs.com','Pricing Manager',true);
        Plants__c wh =  TestClassUtility.createWarehouse('TEST',us.id, true);
       // Market_Class__c mc= TestClassUtility.createMarketClass('test', true);
       // Product_Type__c pt= TestClassUtility.createProductType('test','test','test',mc.id, true );
        //Large_Job_Quote__c lj = TestClassUtility.createLargeJobQuote(tc.Id,demoDM.Id, 'testProject', 'testProjectType', 'testCity', 'testState', 'Job Site', 'Contract', 'testTSquareRolls','Activated',sDate, sDate, eDate, true);
        //Large_Job_Quote__c lj2 = TestClassUtility.createLargeJobQuote(tc.Id,demoDM.Id, 'testProject2', 'testProjectType2', 'testCity2', 'testState2', 'Job Site', 'Invoice Verification', 'testTSquareRolls2','Activated',sDate, sDate, eDate, true);
        //Large_Job_Quote__c lj3 = TestClassUtility.createLargeJobQuote(tc.Id,demoDM.Id, 'testProject3', 'testProjectType3', 'testCity3', 'testState3', 'Job Site', 'Contract and Invoice Verification', 'testTSquareRolls3','Activated',sDate, sDate, eDate, true);
       // LJQ_Product__c lp = TestClassUtility.createLJQProduct(/*lj.Id,*/12,wh.id,pt.id,true);
       // LJQ_Product_Escalator__c lpe = TestClassUtility.createLJQProductEscalator(lp.Id,10.1,10.2,sDate,eDate, false);
        //List<LJQ_Product_Escalator__c> lpList = new List<LJQ_Product_Escalator__c>();
       // lpList.add(lpe);
       //insert lpList;
        Account acc = new Account(Name='TestAcc',SAP_ACCOUNT__c='123456');
        insert acc;
        Contact con = TestClassUtility.createcontact('test',acc.Id,'AL','test@test.com','9899898899',true);
      
        //LJQ_Contact__c ljqCon = new LJQ_Contact__c();
      //  ljqCon.Company__c = 'test';
       // ljqCon.Contact__c = con.Id;
       // ljqCon.Conversation_Date__c = sDate.addDays(2);
        //ljqCon.Large_Job_Quote__c = lj.Id;
       // insert ljqCon;
        
       // LJQ_Customer__c lc= TestClassUtility.createLJQCustomer (true,/*lj.id,*/acc.id,acc.id,acc.id,false);
        //lc.Include__c = true;
      //  lc.Contact__c = ljqCon.Id;
       // insert lc;
        
      //Market_Class__c mclass = TestClassUtility.createMarketClass('test'  ,true); 
        
       // Product_Type__c prdType = TestClassUtility.createProductType('test','IDC', '202120' ,mclass.Id, true);
        
        /*Color__c color = new Color__c();
        color.Color_Code__c   = 'red';
        color.oldCode__c      = 'red';
        color.Product_Type__c = prdType.Id;
        insert color;*/
        
      //  LJQ_Color__c  ljqcolor = TestClassUtility.createLJQColor(lp.Id, /*color.Id,*/ true);
        
       /* LJQEmailTemplate et = new LJQEmailTemplate();
        //et.contactConfirmation = true;
        et.contInvVerConfirmation = true;
        et.quoteConfirmation = true;
        et.ljqRecipientId = con.Id;
        //et.ljqId = lj.Id;
        et.emailType = 'Cont&InvVerConfirmation';
        et.emailType = 'QuoteConfirmation';
        //et.ljqId = lj2.Id;
        et.emailType = 'Cont&InvVerConfirmation';
        et.emailType = 'QuoteConfirmation';
        //et.ljqId = lj3.Id;
        et.emailType = 'Cont&InvVerConfirmation';
        et.emailType = 'QuoteConfirmation';
        //LJQEmailTemplate.LJQProductDetail pd = new LJQEmailTemplate.LJQProductDetail(lp,'test',lpList,'test');*/
    }
}