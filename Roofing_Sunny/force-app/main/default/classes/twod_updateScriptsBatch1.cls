global class twod_updateScriptsBatch1 implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select First_Name__c, Last_Name__c from Claim_Interested_Parties__c Where Claim__r.Is_Migrated__c=true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Claim_Interested_Parties__c> scope) {
        twod_updateScripts ct=new twod_updateScripts();
        ct.updateCip(scope);
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}