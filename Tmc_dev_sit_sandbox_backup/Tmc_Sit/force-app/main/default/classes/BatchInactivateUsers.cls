/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 08-18-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   08-18-2020   Rajesh Ramachandran   Initial Version
**/
public with sharing class BatchInactivateUsers implements Database.Batchable<sObject>,Schedulable {

    //query for users where profile is driver and isactive is true
    String query = 'select id from User where profile.name = \'Driver\' and isActive = true limit 10000';    

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
     }

    public void execute(Database.BatchableContext BC, List<User> scope){
        
        for (User usr : scope){
            usr.isActive = false;
        }
        update scope;

    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('Users are inactivated successfully');
    }    

    public void execute(SchedulableContext SC) {
        database.executebatch(new BatchInactivateUsers());
       }

}