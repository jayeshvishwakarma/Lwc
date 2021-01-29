/**
* @File Name          : enqMatchingBatch.cls
* @Description        : Class to compare external id and id of enquiry with DMS data
* @Author             : Rahul Sharma
**/
public without sharing class enqMatchingBatch implements Database.Batchable<sObject>{
   
   //Start Method
   Integer k=0;
   string query;
   //Public static set<string> conIds;
   public enqMatchingBatch(String Q)
   {
       query = Q;
   }
   public Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('query '+query);
      return Database.getQueryLocator(query);
   }
   
    //Execute method 
    public void execute(Database.BatchableContext BC, List<Enq_Matching__c> scope){
        List<Enq_Matching__c> lstEnqMatch = new List<Enq_Matching__c>();
        set<String> externalIds= new set<string>();
        set<String> enqNames = new set<string>();
        map<String,string> sfIdMap = new map<String,string>();
        map<String,string> sfNameMap = new map<String,string>();
        if(scope.size() > 0)
        {
            for(Enq_Matching__c match: scope)
            {
                if(!externalIds.contains(match.DMS_External_id__c))
                {
                    externalIds.add(match.DMS_External_id__c);
                }
            }
        
            if(externalIds.size() > 0)
            {
                List<Opportunity> lstOpp = [Select Id, External_Id__c,First_Name__c from Opportunity where External_Id__c in: externalIds];
                for(String key : externalIds)
                {
                    for(Opportunity opp : lstOpp)
                    {
                        if(key == opp.External_Id__c)
                        {
                            sfIdMap.put(key,opp.Id);
                            sfNameMap.put(key,opp.First_Name__c);
                        }
                    }
                }
            }
            for(Enq_Matching__c match: scope)
            {    
                Enq_Matching__c mat = new Enq_Matching__c(Id = match.Id);
                if(sfIdMap.containskey(match.DMS_External_id__c))
                    mat.SF_Enquiry_Id__c = sfIdMap.get(match.DMS_External_id__c);
                if(sfNameMap.containskey(match.DMS_External_id__c))
                    mat.SF_ENQ_Name__c = sfNameMap.get(match.DMS_External_id__c);
                mat.Picked_By_Batch__c = true;
                lstEnqMatch.add(mat);
            }
        }
        if(!lstEnqMatch.IsEmpty())
            update lstEnqMatch;
        
    }

    //Finish Method
    public void finish(Database.BatchableContext BC){
       
    }
   
}