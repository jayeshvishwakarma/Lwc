/**
* @File Name          : dataDeleteBatch.cls
* @Description        : Generic batch class to delete records in the org. The input to the constructor is the query to select the records.
* @Author             : 
* @Group              : 
* @Last Modified By   : Rahul Raghunathan
* @Last Modified On   : 10/8/2019, 9:29:33 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    08/10/2019, 9:14:54 PM                                Initial Version
**/



global with sharing class dataDeleteBatch implements Database.Batchable<sObject>{

   global final String Query; //string used to store query.
   global final Integer sequence;//String used to store the sequence number.

    
    //Generic constructor to execute the query and fetch the scope
    global dataDeleteBatch(string q) {
        this.Query = q;
    }

    //generic constructor to execute the query and also have the sequence number for the next delete record. 
    //Requires Delete_Job_Sequence__mdt metadata to be present else exception would be thrown.
    global dataDeleteBatch(string q, Integer s) {
        this.Query = q;
        this.sequence = s;
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Database.DeleteResult[] DR_Dels = database.delete(scope,false);
        //TO DO parse through the error and create Error Classes
    }

    global void finish(Database.BatchableContext BC){
        //If the next sequence is mentioned in the construtor then call the manage delete class elze just end.
        if(this.sequence != null){
            new manageDeleteJobs(sequence);
        }
    }

}