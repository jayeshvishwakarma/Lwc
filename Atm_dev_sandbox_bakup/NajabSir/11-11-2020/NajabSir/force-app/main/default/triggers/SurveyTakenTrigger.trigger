trigger SurveyTakenTrigger on SurveyTaker__c (before insert) {
    new SurveyTakenTriggerHandler().run();
}