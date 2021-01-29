/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Campaign Trigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
27-09-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
trigger CampaignTrigger on Campaign (before insert, before update, after insert, after update) {
    new CampaignTriggerHandler().run();
}