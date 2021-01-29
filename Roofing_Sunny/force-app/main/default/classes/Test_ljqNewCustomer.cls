/*********************************************************************************
* Test Class: {Test_ljqNewCustomer}
* Created by {DateCreated 12/25/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ljqNewCustomer.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/25/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class Test_ljqNewCustomer {
    
    static testMethod void myUnitTest() {        
        Region__c rnc = TestClassUtility.createRegion('test region name','test region code', true);
        Territory__c tc = TestClassUtility.createTerritory('jackson', '2656', 'land', rnc.Id, true);
        //Large_Job_Quote__c lj = TestClassUtility.createLargeJobQuote(tc.Id,null,null,null,null,null,null,null,null,null,null,null,null, true);
        Account acc = new Account(Name='TestAcc',SAP_ACCOUNT__c='123456');
        insert acc;
        Contact con = TestClassUtility.createcontact('test',acc.Id,'AL','test@test.com','9899898899',true);
       
        //LJQ_Customer__c lc= TestClassUtility.createLJQCustomer (true,/*lj.id,*/acc.id,acc.id,acc.id,true);
      
        //ApexPages.currentPage().getParameters().put('ljqid',lj.id);
        //ApexPages.currentPage().getParameters().put('objid',lj.id);
        ApexPages.currentPage().getParameters().put('isNewRecord','TRUE');
        
        ljqNewCustomer ncu = new ljqNewCustomer();
        ncu.isNewContact = false;
        //ncu.ljq  = lj;
        //ncu.cust = lc;
        ncu.custContStd= con;
        ncu.selectedContactId = con.Id;
        //ncu.createNewRecord();
        //ncu.deleteRecord();
        ncu.goBack();
       // ncu.prepareOrderFor();
       // ncu.prepareShipTo();
       // ncu.prepareContact();       
       // ncu.doSave();
        ncu.nextStep();
        ncu.checkCustomerEmail();
        ncu.checkAllAccounts();
        ncu.prepareSoldTo();                
    }
    
    static testMethod void myUnitTest1() { 
        Region__c rnc = TestClassUtility.createRegion('test region name','test region code', true);
        Territory__c tc = TestClassUtility.createTerritory('jackson', '2656', 'land', rnc.Id, true);
        //Large_Job_Quote__c lj = TestClassUtility.createLargeJobQuote(tc.Id,null,null,null,null,null,null,null,null,null,null,null,null, true);
        Account acc = new Account(Name='TestAcc',SAP_ACCOUNT__c='123456');
        insert acc;
        Contact con = TestClassUtility.createcontact('test',acc.Id,'AL','test@test.com','9899898899',true);
        //LJQ_Customer__c lc= TestClassUtility.createLJQCustomer (true,/*lj.id,*/acc.id,acc.id,acc.id,true);
      
        //ApexPages.currentPage().getParameters().put('ljqid',lj.id);
        //ApexPages.currentPage().getParameters().put('objid',lj.id);
        ApexPages.currentPage().getParameters().put('isNewRecord','FALSE');
        ApexPages.currentPage().getParameters().put('show','Section1');
        ApexPages.currentPage().getParameters().put('retURL','/apex/ljqNewCustomer');
        
        ljqNewCustomer ncu = new ljqNewCustomer();
        ncu.selectedRecordId = '';        
       // ncu.isNewContact = true;
      //  ncu.cust = lc;
        ncu.custContStd= con;
        ncu.selectedContactId = '';
        //ncu.createNewRecord();
       // ncu.deleteRecord();
       // ncu.doSave();
        ncu.searchCon();
    }
}