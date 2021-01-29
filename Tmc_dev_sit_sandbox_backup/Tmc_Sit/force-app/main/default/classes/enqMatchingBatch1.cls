/**
* @File Name          : enqMatchingBatch.cls
* @Description        : Class to compare external id and id of enquiry with DMS data
* @Author             : Rahul Sharma
**/
public without sharing class enqMatchingBatch1 implements Database.Batchable<sObject>{
   
   //Start Method
   Integer k=0;
   string query;
   public enqMatchingBatch1(String Q)
   {
       query = Q;
   }
   public Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('query '+query);
      return Database.getQueryLocator(query);
   }
   
    //Execute method 
    public void execute(Database.BatchableContext BC, List<opportunity> scope){
        List<opportunity> oppUpdate = new List<opportunity>();
        set<String> sfIds= new set<string>();
        set<String> dmsSfId = new set<string>();
        map<String,string> sfIdMap = new map<String,string>();
        map<String,string> sfNameMap = new map<String,string>();
        if(scope.size() > 0)
        {
            for(opportunity opp: scope)
            {
                if(!sfIds.contains(opp.id))
				{
					if((opp.Name!=null && !(opp.Name).contains('Test')) || (opp.DMS_Enquiry_Name__c != null && !(opp.DMS_Enquiry_Name__c).contains('SF')) || opp.Name == null || opp.DMS_Enquiry_Name__c == null)
                    sfIds.add(opp.id);
                }
            }
        
            if(sfIds.size() > 0)
            {
                List<Enq_Matching__c> lstEnqMatch = [Select Id, DMS_External_id__c,DMS_SF_Id__c from Enq_Matching__c where DMS_SF_Id__c in: sfIds];
                if(sfIds.size() != lstEnqMatch.size())
                {
                    for(Enq_Matching__c enq :lstEnqMatch)
                    {
                        if(!dmsSfId.contains(enq.DMS_SF_Id__c))
                        {
                            dmsSfId.add(enq.DMS_SF_Id__c);
                        }
                    }
                    for(String str : sfIds)
                    {
                        if(!dmsSfId.contains(str))
                        {
                            Opportunity opp2 = new opportunity(id=str,Enq_Exists_in_DMS__c= true);
                            
                            oppUpdate.add(opp2);
                        }
                    }
                    if(!oppUpdate.IsEmpty())
                    {
                        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
                        database.update(oppUpdate, false);
                        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
                    }
                }
            }
        }
    }

    //Finish Method
    public void finish(Database.BatchableContext BC){
       
    }
   
}