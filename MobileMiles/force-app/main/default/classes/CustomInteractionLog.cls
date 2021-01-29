public class CustomInteractionLog {


    public Boolean isSuccess{get;set;}

    public String accId { 
        get {
            if(accId == null) {
                accId = ApexPages.currentPage().getParameters().get('id');
            }
            return accId;
        }
        set; 
    }

    public void updateWhoWhatId() {
        Integer AccountCount = [Select COUNT() from Account where id =:accId];
        
        if (AccountCount==0) {
            statusMessage = 'This log is not associated with a Account or Contact! Please save the Account.';
            return;
        }

        Account myAccount = [Select id, (Select id from Contacts) from Account where id = :accId];
        
        if(myAccount.contacts!=null&&myAccount.contacts.size()>0){
            task.whoId = myAccount.contacts[0].id;
        }

        task.whatId = myAccount.id;

        System.debug('task' + task);
    }

    private void initializeTask() {
        updateWhoWhatId();
        task.subject = Subject;
    }
    
    private String Subject { 
        get {
            Subject = 'Call at ' + DateTime.now();
            return Subject;
        }
        set; 
    }

    public CustomInteractionLog(ApexPages.StandardController controller) {
        initializeTask();
    }       

    public String ANI { get; set;}
    public String CallObject { get; set;} 
    public Integer CallDurationInSeconds { get; set;} 
    public String CallType { get; set;}  
    public String CallDisposition { get; set;}        
    
    public String statusMessage { get; set; }

    public Task task { 
        get {
            if(task == null) {
                task = new Task();
            }
            return task;
        }
        set; 
    }
    
    public void setCallAttachedData() {
        task.CallObject = CallObject;
        //task.ANI__c = ANI;
    }     

    public void setCallEndData() {
        task.CallDurationInSeconds = CallDurationInSeconds;
        task.CallType =CallType; 
        task.CallDisposition = CallDisposition;    
        save();
    }
    
    public void save() {
        
        try {
            task.Status = 'Voltooid';

            List<Task> taskList=[Select CallDurationInSeconds,CallType,CallDisposition,Subject,CreatedDate from Task where whatId=:task.whatId order by createddate desc limit 1];
            
            Task tasklog = new Task();
            if(!taskList.isEmpty()){
                tasklog = taskList[0];
            }


            if(!taskList.isEmpty() && ((System.now().getTime()-tasklog.createddate.getTime())/1000)/60 < 1) { 
                task.CallDurationInSeconds=tasklog.CallDurationInSeconds;
                task.CallType=tasklog.CallType;
                task.CallDisposition=tasklog.CallDisposition;
                task.subject=tasklog.subject;
                task.ActivityDate = Date.today();
                upsert task;

                if(task.id != tasklog.Id){
                    delete tasklog;
                }
                statusMessage = 'Last save at ' + DateTime.now();
            }
            else{
                upsert task;
                initializeTask();
                statusMessage = 'Last save at ' + DateTime.now();
            }
        } catch(Exception e) {
            statusMessage = 'Log did not get Saved';
            System.debug('Exception Occured :' + e.getMessage());
        }

        isSuccess = true;
    }
    
     public void saveAndNew() {
        save();
        task = null;
        initializeTask();
        //task.ANI__c= ANI;
        task.CallObject = CallObject;
    }        
}