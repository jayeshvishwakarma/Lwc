public without sharing class updateDSEAdoptionReportColumnsSchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        Boolean isMTD = false;
        Boolean monthly = false;
        updateDSEAdoptionReportColumnsBatch b = new  updateDSEAdoptionReportColumnsBatch(isMTD,monthly); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
    }
}