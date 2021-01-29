@isTest
public class PerformanceBatchTest {

     public static testMethod void testMethod1(){
        
          
        PerformanceBatch perVar = new PerformanceBatch();
        set<id> recId = new Set<id>();
        for (Performance__mdt  uc : [SELECT Id FROM Performance__mdt WHERE Active__c=true]){
            recId.add(uc.Id);
        }
        system.debug('???'+recId);
        perVar.query='SELECT Id,Active__c,MasterLabel,Class__c FROM Performance__mdt WHERE Id IN:recId';
        perVar.recId = recId;
        Database.executeBatch(perVar);
    }
}