/**
* @File Name          : ScheduleDataDeletionBatch.cls
* @Description        : This class has to  execute method you would have the call the manageIdentifyJobs and manageDeleteJobs with sequence as 1.
* @Author             : 
* @Group              : 
* @Last Modified By   : Brijesh Singh
* @Last Modified On   : 27th Jul 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    08/10/2019, 9:14:54 PM                                Initial Version
**/


global class ScheduleDataDeletionBatch implements Schedulable {
    global void execute(SchedulableContext sc){
        
        //Calling class for delete records
        new manageDeleteJobs(1);
        
        //Calling class for update the record for identification (Set value as 'True')
        new ManageIndentifyJobs(1);
    }

}