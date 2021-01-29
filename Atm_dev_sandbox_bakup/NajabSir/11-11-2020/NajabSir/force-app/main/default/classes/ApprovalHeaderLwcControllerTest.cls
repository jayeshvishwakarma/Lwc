/**
* @File Name          : ApprovalHeaderLwcControllerTest.cls
* @Description        : Test class for ApprovalHeaderLwcController cls
* @Author             : 
* @Group              : 
* @Last Modified By   : Prashant Gahlaut
* @Last Modified On   : 2/11/2020, 3:00 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    3/11/2020, 3:00 PM         Prashant Gahlaut        Initial Version
**/
@isTest
public class ApprovalHeaderLwcControllerTest {
    @isTest
    static void testMethd(){
        test.startTest();
        ApprovalHeaderLwcController.fetchApprovalData('test');
        ApprovalHeaderLwcController.saveData('test','Approve','test','test');
        ApprovalHeaderLwcController.saveData('test','Reject','test','test');
        test.stopTest();
    }
}