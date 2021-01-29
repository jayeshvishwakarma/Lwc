/**
* @File Name          : DataDeleteBatch.cls
* @Description        : Generic batch class to delete records in the org. The input to the constructor is the query to select the records.
* @Author             : 
* @Group              : 
* @Last Modified By   : Brijesh Singh
* @Last Modified On   : 27/07/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    08/10/2019, 9:14:54 PM                                Initial Version
**/



global with sharing class dataDeleteBatch implements Database.Batchable<sObject>{

   global final String query; //string used to store query.
   global final Integer sequence; //String used to store the sequence number.
   global final string conditionalValue; //String used to store the conditional value
    
    //generic constructor to execute the query and also have the sequence number for the next delete record. 
    //Requires Delete_Job_Sequence__mdt metadata to be present else exception would be thrown.
    global dataDeleteBatch(string query, Integer sequence, string conditionalValue) {
        this.query = query;
        this.sequence = sequence;
        this.conditionalValue = conditionalValue;
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        if(string.isNotBlank(query)){
            return Database.getQueryLocator(query);
        }else{
            return null;
        }
   }

    global void execute(Database.BatchableContext BC, List<sObject> objectDataList){
        List<sObject> dataDeleteList = new List<sObject>(); // List for store the records which need to be deleted
        List<Custom_Error__c> customErrorList = new List<Custom_Error__c>(); // List for creating custom error records
        
        //If there is some condition so If part will execute otherwise else part
        if(string.isNotBlank(conditionalValue )){
            System.debug('If condition enter '+conditionalValue );
            List<string> childNameList = new List<string>();
            childNameList = conditionalValue.split(',');
            for(sObject sobj : objectDataList){
                if(!childNameList.isEmpty() && childNameList.size() == 2 && sobj.getsobjects(childNameList[0])!= NULL && sobj.getsobjects(childNameList[0]).size() > 0 && sobj.getsobjects(childNameList[1])!= NULL && sobj.getsobjects(childNameList[1]).size() > 0){
                    system.debug('@@@@@ Inside inner if condition');
                    //Nothing to do with data because they having child record as well
                }else{
                    dataDeleteList.add(sobj);
                }
                
                
                /*
                if(sobj.getsobjects(conditionalValue)!= NULL && sobj.getsobjects(conditionalValue).size() > 0){
                    system.debug('@@@@@ Inside inner if condition');
                    //Nothing to do with data because they having child record as well
                }else{
                    dataDeleteList.add(sobj);
                }*/
            }
        }else{
            System.debug('else condition enter '+conditionalValue );
            dataDeleteList.addAll(objectDataList);
        }
        
        System.debug('@@@@ Delete Account Data List '+dataDeleteList);
        Database.DeleteResult[] DR_Dels = Database.delete(dataDeleteList, false); // delete record
        
        
        for(Database.DeleteResult dr : DR_Dels) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + dr.getId());
                // do nothing
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    customErrorList.add(new Custom_Error__c(Component_Name__c = 'dataDeleteBatch',
                                                            Error_Message__c = err.getMessage(),
                                                            User__c = UserInfo.getUserId(),
                                                            Error_source__c = 'Batch Class'));
                }
            }
        }
        
        //Create custom error if any
        if(!customErrorList.isEmpty()){
            INSERT customErrorList;
        }

        //TO DO parse through the error and create Error Classes
    }

    global void finish(Database.BatchableContext BC){
        //If the next sequence is mentioned in the construtor then call the manage delete class elze just end.
        if(this.sequence != null){
            new manageDeleteJobs(sequence);
        }
    }

}