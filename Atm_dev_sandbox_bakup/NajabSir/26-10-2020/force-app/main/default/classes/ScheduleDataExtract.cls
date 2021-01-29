/**
* @File Name          : ScheduleDataExtract.cls
* @Description        : Apex Class to schedule data extract
* @Author             : 
* @Group              : 
* @Last Modified By   : Anuj Kumar
* @Last Modified On   : 09/01/2019, 3:12:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    09/01/2019, 3:12:16 PM                               Anuj Kumar
**/

global class ScheduleDataExtract implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      //Calling the data extract script
      DataExtractScript.extractData(null,null);
      
   }
}