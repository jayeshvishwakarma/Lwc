/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   It will work for after insert,after update & before update events only

History
Date            Author             Comments
--------------------------------------------------------------------------------------
13-02-2020      Nitin Ghai        Initial Release
28-02-2020      Nitin Ghai		  Added Before Update event in the Trigger
------------------------------------------------------------------------------------*/
trigger WorkOrderTrigger on WorkOrder (after insert,after update, before update) {
    new WorkOrderTriggerHandler().run();
}