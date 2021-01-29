/*
 * Name: DatasetTrigger
 * Author: 
 * Description: Dataset trigger is created to update its status.

Date        Author      Comments
------------------------------------------
13/10/2020              Initial Release
*/
trigger DatasetTrigger on Dataset__c (before update) {
    for(Dataset__c datasetObj : Trigger.New){
        
        //Access the "old" record by its ID in Trigger.oldMap
        Dataset__c oldDataset = Trigger.oldMap.get(datasetObj.Id);
        
        if(oldDataset.Data_Submitted_to_DPS__c != datasetObj.Data_Submitted_to_DPS__c && datasetObj.Status__c == 'Pending Data Submission to DPS' && datasetObj.Data_Submitted_to_DPS__c == true){
            datasetObj.Status__c = 'Data Submitted to DPS';
        }
    }
}