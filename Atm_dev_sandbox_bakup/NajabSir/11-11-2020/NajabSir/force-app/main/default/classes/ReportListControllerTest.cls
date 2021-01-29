/**
* @File Name          : ReportListControllerTest.cls
* @Description        : used for quick link
* @Author             :
* @Group              :
* @Last Modified By   : Prashant Gahlaut
* @Last Modified On   : 17/11/2020, 11:29:29 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    17/11/2020, 11:29:29 AM    Prashant Gahlaut          Initial Version
**/
@isTest
public class ReportListControllerTest {
    @isTest
    static void testmethods(){
        Test.startTest();
        ReportListController.fetchData();
        ReportListController.fetchLookUpValues('test','Account');
        ReportListController.fetchProductLookUpValues('test','Product2','AK');
        test.stopTest();
    }
}