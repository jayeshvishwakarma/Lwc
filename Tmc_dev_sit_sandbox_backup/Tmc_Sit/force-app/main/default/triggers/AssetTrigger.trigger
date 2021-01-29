/*------------------------------------------------------------------------------------
Author:        Rahul Sharma
Description:   Asset Trigger Trigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
20/07/2020      Rahul Sharma     Initial Release
------------------------------------------------------------------------------------*/
trigger AssetTrigger on Asset (before insert,before update) {
    new AssetTriggerHandler().run();
}