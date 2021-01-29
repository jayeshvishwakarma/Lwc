public without sharing class CountNumberOfPostsBatchScheduler implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        CountNumberOfPostsBatch b = new  CountNumberOfPostsBatch(); 
        string jobId= database.executebatch(b);
    }
}