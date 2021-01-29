/**
 * @File Name          : PerformanceBatch.cls
 * @Description        : This batch basically runs the ProcessData of Performance script to track the execution time for incoming cases
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Ravi Gupta
 * @Last Modified On   : 12/08/2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      	     Modification
 *==============================================================================
 * 1.0    9/08/2019, 11:00:01 AM         Ravi Gupta      Initial Version
**/
global class PerformanceBatch implements Database.Batchable<sObject>, Database.stateful,Database.AllowsCallouts{
    // Global string that store required query 
    global string query;
    // Global string that store required recordId for usecases 
    global set<id> recId;
    
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        system.debug('query'+query +'recId'+recId);
               return Database.getQueryLocator(query); 
    }
    global void execute (Database.BatchableContext bc ,List<Performance__mdt> recordsList){
        system.debug('recordsList'+recordsList);
        type t;
        try{
            for(Performance__mdt perfObj:recordsList){
                //PerformanceScript.createPerformanceLogger(perfObj.Parameter__c);
                 t = Type.forName(perfObj.Class__c);
                HandlerInterface v = (HandlerInterface)t.newInstance();
                v.ProcessData();
            }  
        }catch(Exception e){
            system.debug(e.getLineNumber()+'>>'+e.getMessage());
        }
        
    }
    global void finish(Database.BatchableContext bc){
        System.debug('----Finish');
    }
}