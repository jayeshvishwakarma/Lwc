/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to automatic sync enquiries every hour where DMS enq no not present 
    **/
public without sharing class EnquiryReSyncBatch implements Database.Batchable<sObject>, Database.Stateful{
   
   //Start Method
   Integer k=0;
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       return Database.getQueryLocator([select id,Name, OwnerId,DMS_Enquiry_Name__c,StageName,DMS_Sync_Error_Details__c
                                             from opportunity 
                                             where Variant__c != null
                                             And DMS_Sync_Error_Details__c != null 
                                             And ((DMS_Enquiry_Name__c = null 
                                             And StageName =: ConstantsUtility.STAGE_NEW )
                                             OR (StageName =: ConstantsUtility.STAGE_PREBOOKING
                                             AND Pre_Booking_Number__c = null
                                             AND Pre_booking_Submission_Date__c != null))]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<SF_Retry_Custom_Setting__c> retrySettings=SF_Retry_Custom_Setting__c.getAll().values();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        list<String> dmsErrors = new list<String>();
        list<String> dmsErrorsSet = (Label.MSIL_DMSError).split(',');
        list<String> dmsErrorsSet2 = (Label.MSIL_DMSError_2).split(',');
        list<String> dmsErrorsSet3 = (Label.MSIL_DMSError_3).split(',');
        for(String str : dmsErrorsSet)
            dmsErrors.add(str);
        for(String str : dmsErrorsSet2)
            dmsErrors.add(str);
        for(String str : dmsErrorsSet3)
            dmsErrors.add(str);
        system.debug('dmsErrors --  '+dmsErrors);
        String error;
        if(scope.size() > 0 && retrySettings[0].Retry__c == true)
        {
            for(Opportunity opp : scope)
            {
                    error = String.valueOf(opportunity.DMS_Sync_Error_Details__c);
                if(error.contains(':') == true)
                    error = error.substringBefore(':');
                 
                if(error != null && (!dmsErrors.contains(error))) 
                    oppsToUpdate.add(opp);
            }
        }
        
        if(oppsToUpdate.size() > 0 && retrySettings[0].Retry__c == true)
        {
            Database.SaveResult[] srList = database.update(oppsToUpdate, false);
            for (Database.SaveResult sr : srList) 
            {
             if (sr.isSuccess()) {
                 k++;
            }
            }
        }
   }
   //Finish Method
   public void finish(Database.BatchableContext BC){
    
    }
}