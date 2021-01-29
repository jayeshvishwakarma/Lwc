global class twod_updateScriptsBatch2 implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Released_To_SAP__c,Paid_Y_N__c,Approval_Status__c,Approved__c from Payment__c where Paid_Y_N__c=\'Yes\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Payment__c> scope) {
        twod_updateScripts ct=new twod_updateScripts();
        ct.updatePayment(scope);
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}