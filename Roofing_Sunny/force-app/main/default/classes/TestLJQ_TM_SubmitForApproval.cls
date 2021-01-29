/*********************************************************************************
* Test Class: {TestLJQ_TM_SubmitForApproval}
* Created by  {DateCreated 12/02/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of LJQ_TM_SubmitForApproval.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Madan 12/02/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class TestLJQ_TM_SubmitForApproval {
    static testMethod void myUnitTest() {
        
        Region__c region = TestClassUtility.createRegion('testname', 'tst', true);
        
        Territory__c territory = TestClassUtility.createTerritory('testname', '100', 'Commercial', region.id, true);
        
        //Large_Job_Quote__c ljqObj = TestClassUtility.createLargeJobQuote(territory.id, null, 'testProjectName', 'New', 'testCity', 'testState', 'Job Site', 'Contract', 'testTotalSquareRolls', 'Saved', System.today(), System.today().addDays(-4), System.today(), true);
        
        LJQ_TM_SubmitForApproval submitForApprovalObj = new LJQ_TM_SubmitForApproval();
        
        //Large_Job_Quote__c ljq = submitForApprovalObj.ljq;
        
        submitForApprovalObj.approverId = 'test';
        
        //submitForApprovalObj.ljq = ljqObj;
        
        String approvalLink = submitForApprovalObj.approvalLink;
        
        approvalLink = submitForApprovalObj.rejectionLink;
        
        //submitForApprovalObj.objId = ljqObj.id;
    }
}