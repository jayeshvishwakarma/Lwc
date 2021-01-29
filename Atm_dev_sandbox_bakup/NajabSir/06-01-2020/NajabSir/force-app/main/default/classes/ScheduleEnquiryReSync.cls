/**
* @File Name          : ScheduleEnquiryReSync.cls
* @Description        : Apex Class to schedule ecnquiry resync
* @Author             : Rahul Sharma
* @Group              : MSIL
**/

public without sharing class ScheduleEnquiryReSync implements Schedulable
{
public void execute(SchedulableContext sc) {
        EnquiryReSyncBatch b = new  EnquiryReSyncBatch(); 
        Integer size = integer.valueof(Label.Enquiry_Sync_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
    }
}