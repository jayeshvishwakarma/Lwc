/**
* @File Name          : manageDeleteJobs.cls
* @Description        : Class used to manage the delete job sequence
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


public with sharing class manageDeleteJobs {
    private final Integer DEFAULTBATCH = 200;

    public manageDeleteJobs(Integer sequenceNo) {
        
        //Fetch the current sequence 
        list<Delete_Job_Sequence__mdt> currentSequence  = [select id, Batch_Size__c, Query__c 
                                                        from Delete_Job_Sequence__mdt 
                                                        where Sequence_Number__c = :sequenceNo];
        
        if(currentSequence.size() == 1){
            
            //Fetch the batch size.
            for(Delete_Job_Sequence__mdt job : currentSequence){
                if(job.Batch_Size__c == null){
                    job.Batch_Size__c = DEFAULTBATCH;
                }

            //initiate batch
            dataDeleteBatch instance = new dataDeleteBatch(job.Query__c, sequenceNo+1);
            database.executebatch(instance, Integer.Valueof(job.Batch_Size__c));

            }
        }
    
    }
}