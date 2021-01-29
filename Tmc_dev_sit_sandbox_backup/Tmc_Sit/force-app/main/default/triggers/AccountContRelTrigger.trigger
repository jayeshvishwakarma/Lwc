/*------------------------------------------------------------------------------------
Author:        Avaneesh Singh
Description:   Account Contact Relation trigger 

History
Date            Author             Comments
--------------------------------------------------------------------------------------
15/4/2020       Avaneesh Singh   Sharing the record of RFC Requirement
------------------------------------------------------------------------------------*/

trigger AccountContRelTrigger on AccountContactRelation (before insert , after insert,after delete,after update) {
   new AccountContRelTriggerHandler().run();
}