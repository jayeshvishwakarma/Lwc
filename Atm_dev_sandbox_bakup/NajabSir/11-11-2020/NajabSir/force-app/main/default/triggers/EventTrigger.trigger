/** ------------------------------------------------------------------------------------
    Author:         Deepak Kumar
    Description:   Event Trigger
    History
    Date            Author             Comments
    --------------------------------------------------------------------------------------
    23-06-2020      Deepak Kumar       Initial Release
  ------------------------------------------------------------------------------------*/

trigger EventTrigger on Event (before insert, before update, after insert, after update) {
    new EventTriggerHandler().run();
}