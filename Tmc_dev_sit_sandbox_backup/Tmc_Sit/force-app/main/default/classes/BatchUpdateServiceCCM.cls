/**
 * @description       : Batch to update users with Call Center/Workshop Manager profile to the Dealership belong into Service CCM
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 10-20-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   10-14-2020   Nitin   Initial Version
**/
public with sharing class BatchUpdateServiceCCM implements Database.Batchable<sObject>,Schedulable {
    
    //query for users with Profile Name as Call Center/Workshop Manager and Active users
    String query = 'select id,Name,AccountId from User where profile.name = \'Call Center/Workshop Manager\' AND isPortalEnabled=true AND isActive=true';    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext BC, List<User> scope){
        List<Account> updateDealerAcc = new List<Account>();
        Map<Id,String> dealerAccServiceCCMMap = new Map<Id,String>();
        for (User usr : scope){
            dealerAccServiceCCMMap.put(usr.AccountId,usr.Id);
        }
        if(dealerAccServiceCCMMap.size()>0){
            for(Id dealerId : dealerAccServiceCCMMap.KeySet()){
                Account acc = new Account();
                acc.Id=dealerId;
                acc.Service_CCM__c=dealerAccServiceCCMMap.get(acc.Id);
                updateDealerAcc.add(acc);
            }
        }
        if(updateDealerAcc.size()>0 && Test.isRunningTest() == false){
            update updateDealerAcc;
        }
    }
    
    public void finish(Database.BatchableContext BC){
    } 
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new BatchUpdateServiceCCM());
    }
    
}