public class TaskManagerController {
    public List<Task> lstTasks {get;set;}
    public String selectedOption{get;set;}
    public INTEGER searchByOption {get;set;}
    public Boolean tableView {get;set;}
    public String recTaskId {get;set;}
    public String strOfIds{get;set;}
    public Map<Integer,String> mapOfOptions{get;set;}
    private static String strquery='Select id, Owner.Name,Subject,Priority,Who.Name,What.Name,Status,Description,ActivityDate FROM Task';
    
    public TaskManagerController(){
        searchByOption=0;
        lstTasks=Database.query(strquery);
        TableView=True;
        mapOfOptions = new Map<Integer,String>();
        mapOfOptions.put(1, 'TODAY');
        mapOfOptions.put(2, 'THIS_WEEK');
        mapOfOptions.put(3, 'THIS_MONTH');
    }
    
    public void searchTaskRecords(){
        System.debug(SearchByOption);
        if(SearchByOption==0)
        {
            lstTasks=Database.query(strquery);
            TableView=True;
            return;
        }
        lstTasks=Database.query(strquery+' WHERE ActivityDate = '+mapOfOptions.get(searchByOption));
        
        if(lstTasks.size()>0)
        {
            tableView=True;
        }else
        {
            tableView=false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'NO Record Found'));
        }
        
    }
    
    
    public void markCompleted(){
        
        List<Id> strOfIds2=strOfIds.split(' ');
        System.debug('Mark Wala Button Chala');
        
        lstTasks=[SELECT Subject,Status,Priority,CreatedDate,OwnerId,ActivityDate
                  From Task  where Id IN: strOfIds2
                 ];
        
        for(Task objTask : lstTasks)
        {
            objTask.Status='Complete';
        }
        Database.update(lstTasks);
        
        lstTasks=[SELECT Subject,Status,Priority,CreatedDate,OwnerId,ActivityDate
                  From Task
                 ]; 
        
        tableView=True;
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Your Task status has been Completed'));
        system.debug('Mark completed '+recTaskId);
        
    }
    
}