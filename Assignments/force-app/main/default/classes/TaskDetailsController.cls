public class TaskDetailsController {
public Task objTask {get;set;}
   
   public TaskDetailsController(){
   String taskId=ApexPages.currentPage().getParameters().get('recId');
       System.debug(taskID);
       objTask=[SELECT Subject,Status,Priority,ActivityDate,WhoId,OwnerId,CreatedDate
                FROM Task
                WHERE ID=:taskId];
   }
   public pageReference BackToTaskManager(){
       PageReference backtoPage=Page.taskmanager;
       return backtoPage;
   }
}