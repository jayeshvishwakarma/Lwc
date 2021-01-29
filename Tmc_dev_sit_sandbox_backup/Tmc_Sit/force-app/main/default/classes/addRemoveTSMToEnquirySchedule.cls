public without sharing class addRemoveTSMToEnquirySchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        string query = Label.Add_Remove_TSM_Query;
        addRemoveTSMToEnquiry b = new addRemoveTSMToEnquiry(query); 
        Integer size = integer.valueof(Label.Add_Remove_TSM_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
    }
    
}