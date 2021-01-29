public class TaskEditController {
   public Task objTask {get;set;}
   
   public TaskEditController(){
   String taskId=ApexPages.currentPage().getParameters().get('recId');
       //System.debug(taskID);
       objTask=[SELECT Subject,Status,Priority
                     FROM Task
                     WHERE ID=:taskId];
   }
   public pageReference saveTask(){
       update objtask;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Your Task Has Been Edited'));
       PageReference BackToPage=Page.taskmanager;
       
       return BackToPage;
   }
}