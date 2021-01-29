public without sharing class PassWordServiceSchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
    
        String query = system.label.User_PassWord_Service_Query;
        system.debug('9 user : '+query);
        PassWordServiceBatch b = new  PassWordServiceBatch(query); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
        
       }
    
}