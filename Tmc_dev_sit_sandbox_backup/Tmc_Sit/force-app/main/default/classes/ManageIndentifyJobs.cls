/**
* @File Name          : ManageIndentifyJobs.cls
* @Description        : class to initiate the identify jobs
* @Author             : 
* @Group              : 
* @Last Modified By   : Brijesh Singh
* @Last Modified On   : 27th Jul 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    08/10/2019, 9:14:54 PM                                Initial Version
**/


public with sharing class ManageIndentifyJobs{
    private final Integer DEFAULTBATCH = 200;
    public List<Custom_Error__c> customErrorList;

    public ManageIndentifyJobs(Integer sequenceNo) {
        customErrorList = new List<Custom_Error__c>();
        
        //Fetch the current sequence 
        
        String query = 'select id, Batch_Size__c, Query__c,Field_To_Be_Updated__c,Condition_For_Deletion__c FROM Delete_Job_Sequence__mdt WHERE Sequence_Number__c = :sequenceNo AND type__c = \'Identify\'';
        if(Test.isRunningTest()){
            query += ' AND developerName = \'Test_Class_Identity_Data\'';
        }else{
            query += ' AND developerName != \'Test_Class_Identity_Data\'';
        }
        list<Delete_Job_Sequence__mdt> currentSequence  = database.query(query);
        
        /*
        list<Delete_Job_Sequence__mdt> currentSequence  = [select id, Batch_Size__c, Query__c ,
                                                           Field_To_Be_Updated__c,Condition_For_Deletion__c  
                                                           FROM Delete_Job_Sequence__mdt 
                                                           WHERE Sequence_Number__c = :sequenceNo
                                                           AND type__c = 'Identify'
                                                           AND Field_To_Be_Updated__c != NULL];
        */                                                   
        //need to process only one record as per requirement so we can check zero index
        if(!currentSequence.isEmpty() && currentSequence.size() == 1 && string.isNotBlank(currentSequence[0].Query__c)){
            
            //Fetch the batch size.
            for(Delete_Job_Sequence__mdt job : currentSequence){
                if(job.Batch_Size__c == null){
                    job.Batch_Size__c = DEFAULTBATCH;
                }

            //initiate batch
            dataIndentifyBatch instance = new dataIndentifyBatch(job.Query__c, sequenceNo+1, job.Field_To_Be_Updated__c, job.Condition_For_Deletion__c);
            database.executebatch(instance, Integer.Valueof(job.Batch_Size__c));

            }
        }else if(currentSequence.size() > 1){
            //for more than one records creating error records
            customErrorList.add(new Custom_Error__c(Component_Name__c = 'ManageIndentifyJobs',
                                                            Error_Message__c = 'More than 1 record is selected from metadate for same Sequence_Number__c',
                                                            User__c = UserInfo.getUserId()));
        }
        
         //Create custom error if any
        if(!customErrorList.isEmpty()){
            INSERT customErrorList;
        }
    
    }
}