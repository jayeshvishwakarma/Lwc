public without sharing class updateDSEAdoptionReportColumnsSchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        updateDSEAdoptionReportColumnsBatch b = new  updateDSEAdoptionReportColumnsBatch(); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
    }
}