/*------------------------------------------------------------------------------------
Author:        Saloni Gupta
Description:   RFC Trigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
09/4/2020       Saloni Gupta     Initial Release
14/4/2020       Avaneesh Singh   Sharing the record of RFC Requirement
------------------------------------------------------------------------------------*/
trigger RFCTrigger on RFC__c (before Insert,before Update, after insert,after update) {
    new RFCTriggerHandler().run();

}