public without sharing class MapProfileToGroupBatchScheduler implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        MapProfileToGroupBatch b = new  MapProfileToGroupBatch(); 
        string jobId= database.executebatch(b);
    }
}