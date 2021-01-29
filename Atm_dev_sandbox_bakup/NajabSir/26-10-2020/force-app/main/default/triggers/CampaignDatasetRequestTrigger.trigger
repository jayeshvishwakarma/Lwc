/*
 * Name: CampaignDatasetRequestTrigger
 * Author: 
 * Description: CampaignDatasetRequestTrigger is created to update its status.

Date		Author		Comments
------------------------------------------
14/10/2020				Initial Release
*/
trigger CampaignDatasetRequestTrigger on Adhoc_Campaign_Request__c (before update) {
    for(Adhoc_Campaign_Request__c datasetReqObj : Trigger.New){
        
        //Access the "old" record by its ID in Trigger.oldMap
        Adhoc_Campaign_Request__c oldDatasetReq = Trigger.oldMap.get(datasetReqObj.Id);
        
        if(oldDatasetReq.Data_Submitted_to_DPS__c != datasetReqObj.Data_Submitted_to_DPS__c && datasetReqObj.Status__c == 'Pending Data Submission to DPS' && datasetReqObj.Data_Submitted_to_DPS__c == true){
            datasetReqObj.Status__c = 'Data Submitted to DPS';
        }            
        
    }
}