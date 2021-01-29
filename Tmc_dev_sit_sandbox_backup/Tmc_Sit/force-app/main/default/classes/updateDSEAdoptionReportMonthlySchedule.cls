public without sharing class updateDSEAdoptionReportMonthlySchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        Boolean isMTD = false;
        Boolean monthly = true;
        updateDSEAdoptionReportColumnsBatch b = new  updateDSEAdoptionReportColumnsBatch(isMTD,monthly); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
    }
}