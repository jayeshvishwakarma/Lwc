global class PerformanceBatchScheduler implements Schedulable{
    /*
Name        :        PerformanceBatchScheduler
Author      :        Ravi Gupta
*/
    /*This class call the batch and  Process all metadat record and count execution time depending upon use case  */
    global void execute(SchedulableContext sc) {
        PerformanceBatch perVar = new PerformanceBatch();
        set<id> recId = new Set<id>();
        /*for (Performance__mdt  uc : [SELECT Id,Class__c  FROM Performance__mdt WHERE Active__c=true]){
            system.debug('uc'+ uc.Class__c);
            recId.add(uc.Id); 
        }*/
        system.debug('???'+recId);
        perVar.query='SELECT Id,Active__c,MasterLabel,Class__c FROM Performance__mdt WHERE Active__c=true';
        system.debug('perVar--->'+perVar);
        ID batchprocessid = Database.executeBatch(perVar,1);
        
    }
}