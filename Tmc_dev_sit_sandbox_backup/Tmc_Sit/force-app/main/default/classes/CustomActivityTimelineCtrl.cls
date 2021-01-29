/**
* @Author-: Sunit Kumar Chand
* @Company-: Techmatrix Consulting
* @Description-: This class is used for Custom Activity Timeline functionallty.
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 17/01/2020, 12:06:33 PM
* @Modification Log   : Intial Version
* =============================================================
*  Version   Date            Author      Modification
* =============================================================
*  1.0       17 Jan 2020    Sunit     Intial Version
* 
**/
public class CustomActivityTimelineCtrl {
    
    @AuraEnabled
    public static List<Task> fetchTasks(String recordId){
        System.debug(recordId);
        List<Task> taskList = new List<Task>();
        if(String.isNotBlank(recordId)) {
            taskList = [
               // SELECT Id, Type, Subject, CreatedBy.Name, CreatedDate, Description 
                //FROM Task WHERE Contact_ID__c =: recordId OR Case__c =: recordId
                
                SELECT Id, Type, Subject, Status, CreatedBy.Name, CreatedDate, ActivityDate, Description,Owner.Name 
                FROM Task WHERE ActivityDate != null AND (Contact_ID__c =: recordId OR whatId =: recordId) 
            ];
        }
        return taskList;
    }
}