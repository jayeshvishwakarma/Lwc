public class CustomActivityController {

    @AuraEnabled
    public static String getCustomActivity(String taskId) {
        String customActivityId = '';
        List<Task> listTask = [SELECT Custom_Activity__c FROM Task WHERE Id = :taskId];
        if(listTask != NULL && listTask.size() > 0) {
         	customActivityId = listTask[0].Custom_Activity__c;
        }
        return customActivityId;
    }
}