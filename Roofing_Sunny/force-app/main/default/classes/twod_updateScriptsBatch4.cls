global class twod_updateScriptsBatch4 implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'Select Id,Payment_Type__c,Sales_Org__c,Currency__c,Exchange_Rate__c,Total_Amount_Converted__c,Total_Amount__c,Claim__r.Currency__c, Claim__r.Sales_org__c, Claim__r.Country_BL__c, (Select Id,Product_Filter__c,Sales_Org__c,Amount__c, Amount_Converted__c from Payment_Lines__r) from Payment__c where Claim__r.twod__Claim_Status__c NOT IN (\'Closed\') and Sales_Org__c = null and Claim__r.Sales_Org__c != null';
        
        twod_batchQuery__mdt md = [select Id,Field_Set__c,Criteria__c,Active__c,Object__c from twod_batchQuery__mdt where Active__c = true AND Object__c = 'Payment__c'];

        String query = 'Select '+ md.Field_Set__c +' from ' + md.Object__c +' where ' +md.Criteria__c;
        System.debug('***Final Query***:' +query);

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Payment__c> scope) {
        twod_updateScripts ct=new twod_updateScripts();
        ct.updPayment(scope);
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}