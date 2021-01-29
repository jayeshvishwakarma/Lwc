/*------------------------------------------------------------------------------------
Author:        Saloni Gupta
Description:   Preliminary Checklist Trigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
19/5/2020       Saloni Gupta     Initial Release
------------------------------------------------------------------------------------*/
trigger PreliminaryChecklistTrigger on Preliminary_Checklist__c (after insert) {
    new PreliminaryChecklistTriggerHandler().run();
}