/**
* @File Name          : ManageAccReportBatchScheduleTest.cls
* @Description        : Apex Class to schedule data extract
* @Author             : 
* @Group              : 
* @Last Modified By   : Anuj Kumar
* @Last Modified On   : 15/04/2020, 3:12:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    15/04/2020, 3:12:16 PM                               Anuj Kumar
**/
@isTest
private class ManageAccReportBatchScheduleTest{

    static testMethod void testschedule() {
    
        Test.StartTest();
            ManageAccReportBatchSchedule sh1 = new ManageAccReportBatchSchedule();
        
            String sch = '0 0 23 * * ?'; 
            system.schedule('Update Accessories', sch, sh1); 
        Test.stopTest(); 
    
    }
}