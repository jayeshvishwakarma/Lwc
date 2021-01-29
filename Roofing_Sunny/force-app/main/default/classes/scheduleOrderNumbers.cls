/***************************************************************************************************
Author : Mukesh Bhardwaj.
Company : Threshold Consulting
Description : Schedule Class to Call  batchOrderNumbers.
Date On : 3rd May 2013.
Initial Version
****************************************************************************************************/
global class scheduleOrderNumbers implements Schedulable
{
    //call batchOrderNumbers class
    global void execute(SchedulableContext sc)
    {
        batchOrderNumbers b = new batchOrderNumbers(); 
        database.executebatch(b);  
    }
}