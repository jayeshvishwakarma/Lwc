/**
Author: Gitika
Company: Techmatrix
Description: Batch class to Uncheck DNE Customer after 6 months 
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        02/07/2020                Gitika            Initial Version
**/
global class UpdateDNECustomersBatch implements Database.Batchable<sObject>, Database.stateful,Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        return Database.getQueryLocator([Select Id,DNE_Case_Id__c,DNE_Till_Date__c from Account where DNE_Till_Date__c=Today]); 
    }
    global void execute (Database.BatchableContext bc ,List<Account> recordsList){
       // system.debug('recordsList'+recordsList);
        try{
            for(Account acc:recordsList){
                acc.DNE_Case_Id__c = null; 
                acc.DNE_Till_Date__c= null;
            }
            update recordsList;
        }catch(Exception e){
            system.debug(e.getLineNumber()+'>>'+e.getMessage());
        }
        
    }
    global void finish(Database.BatchableContext bc){
        System.debug('----Finish');
    }
}