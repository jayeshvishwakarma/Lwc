/*------------------------------------------------------------------------------------
Author:        Prabhat Sharma
Description:   Account Trigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
10/9/2019       Prabhat Sharma     Initial Release
------------------------------------------------------------------------------------*/
trigger AccountTrigger on Account (before insert,before update,after insert,after update) {
    new AccountTriggerHandler().run();
}