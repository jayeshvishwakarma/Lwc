/*********************************************************************************
* Test Class: {TestPCRApprovalEmailTemplateProcess}
* Created by  {DateCreated 12/04/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of PCRApprovalEmailTemplateProcess.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/04/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestPCRApprovalEmailTemplateProcess {

    static testMethod void methodA() {
        PCRApprovalEmailTemplateProcess pcrAppEmail =  new PCRApprovalEmailTemplateProcess();
        Region__c reg = TestClassUtility.createRegion('TestClass1','TC1',true);
        Territory__c ter = TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial',reg.Id, true);
       // Price_Change_Request__c pcrObj = TestClassUtility.createPriceChangeRequest(ter.Id, true);
        System.debug(pcrAppEmail.approvalLink);
        //pcrAppEmail.PCRApprovalEmailTemplateProcess();
    }
    static testMethod void methodB() {
        try{
        PCRApprovalEmailTemplateProcess pcrAppEmail =  new PCRApprovalEmailTemplateProcess();
        Region__c reg = TestClassUtility.createRegion('TestClass1','TC1',true);
        Territory__c ter = TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial',reg.Id, true);
     //   Price_Change_Request__c pcrObj = TestClassUtility.createPriceChangeRequest(ter.Id, true);
        pcrAppEmail.approver = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm@user.com', 'TM USER', 'testTm@user.com', 'TM', true);
        //pcrAppEmail.objId = pcrObj.Id;
       // pcrAppEmail.pcr = pcrObj;
        //System.debug(pcrAppEmail.objId);
        //System.debug(pcrAppEmail.pcrLink);
        pcrAppEmail.submittedUser = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm2@user.com', 'TM USER', 'testTm2@user.com', 'TM', true);
        //pcrAppEmail.PCRApprovalEmailTemplateProcess();
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
}