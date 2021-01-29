trigger BrochureRequestTrigger on Brochure_Request__c (before insert, after insert, before update, after update) {

if(trigger.isInsert){
    if(trigger.isBefore){
     BrochureRequestTriggerHandler.SendBrochure(trigger.new);
    }
}
}