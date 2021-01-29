/**
    * @Author:- Anuj Kumar
    * @Company-: Techmatrix Consulting
    * @Description-: Batch class to Manage Accessories Reporting
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       14 APR 2020    Anuj Kumar     Intial Version
    **/
public class ManageAccessoriesReportingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    //Start Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT id, Name, Acc_Current_Month__c, Acc_Value_Current_Month__c,
                 Acc_Previous_Current_Month__c, Acc_Previous_Month__c from Opportunity where Is_Acc_Updated__c = True]);
    }
   
    //Execute method 
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        ManageAccessoriesReportingBatchHelper helper = new ManageAccessoriesReportingBatchHelper();
        helper.prepare();
        
        Map<String, Opportunity> oppIdWithObjMap = new Map<String, Opportunity>();
        
        for(Opportunity opp : scope){
            Integer oppCurrentMonth = opp.Acc_Current_Month__c != Null ? opp.Acc_Current_Month__c.month() : 0;
            if(oppCurrentMonth != 0){
                oppIdWithObjMap.put(opp.Id, opp);
            }
        }
        
        if(!oppIdWithObjMap.isEmpty()){
            helper.processOpportunity(oppIdWithObjMap);
        }
        
        helper.modifyLineItemDetails();
        
    }
    
    //Finish Method
    public void finish(Database.BatchableContext BC){
    
    }
}