/**
* @File Name          : ManageAccessoriesReportingBatch.cls
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

global class ManageAccReportBatchSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      //Calling the ManageAccessoriesReportingBatch script
      Database.executeBatch(new ManageAccessoriesReportingBatch());
      
   }
}