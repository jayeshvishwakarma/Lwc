/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Event Visit Plan Trigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
27-09-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
trigger EventVisitPlanTrigger on Event_Visit_Plan__c (after insert, after update) {
    new EventVisitPlanTriggerHandler().run();
}