/**
* @File Name          : DataIndentifyBatch.cls
* @Description        : Generic batch class to identify records in the org that would be staged for deletion.
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



global with sharing class DataIndentifyBatch implements Database.Batchable<sObject>{

   global final String query; //string used to store query.
   global final Integer sequence;//String used to store the sequence number.
   global final String fieldName; //string used to store the field that needs to be updated as “true”
   global final string conditionalValue; //String used to store the conditional value
    
    //generic constructor to execute the query and also have the sequence number for the next delete record. 
    //Requires Delete_Job_Sequence__mdt metadata to be present else exception would be thrown.
    global DataIndentifyBatch (string query, Integer sequence, string fieldName, string conditionalValue) {
        this.query = query;
        this.sequence = sequence;
        this.fieldName = fieldName;
        this.conditionalValue = conditionalValue;
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('@#@###  ==>   '+query);
        if(string.isNotBlank(query)){
            return Database.getQueryLocator(query);
        }else{
            return null;
        }
   }

    global void execute(Database.BatchableContext BC, List<sObject> objectDataList){
        
        List<Custom_Error__c> customErrorList = new List<Custom_Error__c>(); // List for creating custom error records if any error 
        
        for(sObject obj : objectDataList){
            System.debug('@#@#####   ==>  '+conditionalValue);
            if(string.isNotBlank(conditionalValue ) && obj.getsobjects(conditionalValue)!= NULL && obj.getsobjects(conditionalValue).size() > 0){
                System.debug('If COndition   ==>   '+obj);
                obj.put(fieldName, 'true');
            }else if(string.isBlank(conditionalValue )){
                System.debug('else If COndition   ==>   '+obj);
                obj.put(fieldName, 'true');
            }
        }
        
        Database.SaveResult[] toUpdateList;
        if(!objectDataList.isEmpty()){
            toUpdateList = Database.update(objectDataList, false);
        }
        
        //
        for(Database.SaveResult sr : toUpdateList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted object with ID: ' + sr.getId());
                // do nothing
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    customErrorList.add(new Custom_Error__c(Component_Name__c = 'DataIndentifyBatch',
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
            new ManageIndentifyJobs(sequence);
        }
    }

}