trigger BulkHoldCasesTrigger on Bulk_Hold_Cases__c (before insert,after insert,after update,before update) {
    new BulkHoldCasesTriggerHandler().run();
}