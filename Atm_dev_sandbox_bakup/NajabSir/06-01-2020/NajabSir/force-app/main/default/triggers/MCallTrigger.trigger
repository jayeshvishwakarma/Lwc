trigger MCallTrigger on MCall_Event__c (before insert,before update,after insert,after update) {
    
        new MCallTriggerHandler().run();

}