public with sharing class UserDetails {
    
    @AuraEnabled(cacheable = true)
    public static List<Task> getAllTasks(){
        List<Task> lstTasks = [SELECT Subject, OwnerId, Owner.Name, CreatedDate,Status 
                               FROM Task
                              ];
        if(lstTasks.size() > 0){
            return lstTasks;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void setTaskCompleted(String status, String taskId){
		List<Task> lstTask = [Select id, status from Task where id =: taskId];
        lstTask[0].Status = status;
        Database.update(lstTask);
        System.debug(lstTask);
    }
    
    @AuraEnabled
    public static List<Task> getTasksById(String userId){
        List<Task> lstTasks = [SELECT Subject, OwnerId, Owner.Name, ActivityDate, Status,Description
                               FROM Task 
                               Where ownerId =:userId
                              ];
        if(lstTasks.size() > 0){
            return lstTasks;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void deleteTask(String taskId){
        Database.delete(taskId);
    }
    
    @AuraEnabled
    public static Task addTask(String subject, String userId, Date recDate, String status, String priority){
        Task objTask = new Task();
        List<Task> taskList = new List<Task>();
        objTask.OwnerId = userId;
        objtask.ActivityDate = (Date)recDate;
        objTask.Priority = priority;
        objTask.Status = status;
        objTask.Subject = subject;
        taskList.add(objTask);
        if(taskList.size() > 0){
         	insert taskList;
            System.debug('Inside IF : '+taskList);
            return [SELECT Id, ActivityDate, Subject FROM Task WHERE Id =:taskList[0].id] ;
        }else{
        System.debug('Outside If'+taskList);
        return null;
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<Wrapper> getAllUserWithTask(){
        
        List<Wrapper> lstWrapper = new List<Wrapper>();
        
        Set<Id> setIds = new Set<Id>();
        
        List<User> lstUsers = [SELECT Id, FullPhotoUrl, Email, name 
                               FROM User];
        
        for(User u : lstUsers){
            setIds.add(u.id);
        }
        
        List<Task> lstTasks = [SELECT Subject, OwnerId, Owner.Name, ActivityDate, Status, Description
                               FROM Task 
                               Where ownerId IN:setIds];
        
        if(!lstUsers.isEmpty()){
            for(User user : lstUsers){
                Integer count = 0;
                Integer completed = 0;
                Integer progressBarCount = 0;
                for(Task t : lstTasks){
                    if(user.id == t.OwnerId){
                        count++;
                        if(t.Status == 'Completed') completed++;
                    }
                }
                if(count > 0)progressBarCount = (100/count)*completed;
                lstWrapper.add(new Wrapper(user, count, progressBarCount));
            }
        }
        System.debug(lstWrapper);
        return lstWrapper;
    }
    
    
    public class Wrapper{
        @AuraEnabled
        public User objUser{get;set;}
        @AuraEnabled
        public Integer count {get;set;}
        @AuraEnabled
        public Integer progressBar{get;set;}
        
        public Wrapper(User recUsers, Integer recCount, Integer recProgressBar ){
            this.objUser = recUsers;
            this.count = recCount;
            this.progressBar = recProgressBar;
            
        }
    }
}