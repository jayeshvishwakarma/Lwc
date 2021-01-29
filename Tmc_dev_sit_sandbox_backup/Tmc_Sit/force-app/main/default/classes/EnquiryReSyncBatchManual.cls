/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to resync enquiries.
    **/
public without sharing class EnquiryReSyncBatchManual implements Database.Batchable<sObject>, Database.Stateful{
   
   //Start Method
   Integer k=0;
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       return Database.getQueryLocator([select id,Name, OwnerId,DMS_Enquiry_Name__c,StageName
                                             from opportunity 
                                             where 
                                             Variant__c != null
                                             And DMS_Enquiry_Name__c = null 
                                             And DMS_Sync_Error_Details__c != null 
                                             And StageName =: 'New'
                                             ]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<Opportunity> scope){
         
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        if(scope.size() > 0)
        {
            for(Opportunity opp : scope)
               oppsToUpdate.add(opp);
        }
        
        if(oppsToUpdate.size() > 0)
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