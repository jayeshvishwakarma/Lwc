/**
    * @Author:- Anuj Kumar
    * @Company-: Techmatrix Consulting
    * @Description-: Schedule class for Batch class to Mark Enquiry as Escalated
    * =============================================================
    * Version   Date             Author         Modification
    * =============================================================
    * 1.0       17 JULY 2020     Anuj Kumar     Intial Version
    **/

public class EnquiryEscalationBatchScheduler implements schedulable{
    // Default run for every 1 hour
    public static string cronExp = '0 0 * ? * *';
    
    public static void scheduleBatch(){
        startSchedule(cronExp);
    }
    
    public static void scheduleBatch(String cronEx){
        string cronExpe = cronEx != null ? cronEx : cronExp; 
        startSchedule(cronExpe);
        
    }
    
    public static void startSchedule(string cronExp){
        EnquiryEscalationBatchScheduler sc = new EnquiryEscalationBatchScheduler();
        string JobId = system.schedule('PartsEnquiryEscalationBatch1', cronExp, sc);
    }
    
    public void execute(SchedulableContext sc) {
        database.executebatch(new EnquiryEscalationBatch());
    }
    
}