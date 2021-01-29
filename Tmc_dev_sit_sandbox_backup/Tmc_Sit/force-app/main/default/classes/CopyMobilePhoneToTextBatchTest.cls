@isTest (seeAllData=false)
private class CopyMobilePhoneToTextBatchTest {
    
    static testmethod void test() {
        
        // Create test accounts to be updated
        // by the batch job.
        Id dealerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        
        
        for (Integer i=0;i<200;i++) {
            Integer myNo = Math.round((Math.random() * (900000) + 100000));
            
            Account m = new Account(FirstName = 'Account ', LastName='Test',PersonMobilePhone='9678'+String.valueOf(myNo), RecordTypeId=dealerRecordType);
            accList.add(m);
        }
        TriggerHandler.bypass('AccountTriggerHandler');
        insert accList;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        String query = 'Select id,Phone_txt__c, PersonMobilePhone from Account where RecordType.DeveloperName = \'Customer\' and Phone_txt__c = null and PersonMobilePhone != null AND SVOC_ID__c != null order by id ASC LIMIT 500000';
        
        Test.startTest();
        CopyMobilePhoneToTextBatch copyBatch = new CopyMobilePhoneToTextBatch(query);
        Database.executeBatch(copyBatch);
        Test.stopTest();
        
    }
}