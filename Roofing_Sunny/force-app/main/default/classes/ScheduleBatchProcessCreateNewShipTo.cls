/*******************************************************************************
Name            : ScheduleBatchProcessCreateNewShipTo.cls
Created Date    : 27th March 2015
Description     : Scheduler class for Batch process which is responsible to create new shipto accounts for a sold to account with out shiptos
*******************************************************************************/
global class ScheduleBatchProcessCreateNewShipTo implements Schedulable 
{    
    // execute method to Schedule batch class   
    global void execute(SchedulableContext SC) 
    {               
        CreateNewShipTo bulkupdate=  new CreateNewShipTo();
        //Execute batch
         database.executeBatch(bulkupdate);
    }
}