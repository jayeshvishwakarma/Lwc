/*
 * Name: CampaignDatasetRequestTrigger
 * Author: 
 * Description: CampaignDatasetRequestTrigger is created to update its status.

Date        Author      Comments
------------------------------------------
14/10/2020              Initial Release
*/
trigger CampaignDatasetRequestTrigger on Adhoc_Campaign_Request__c (before insert, before update, after insert, after update) {
   new CampaignDatasetRequestTriggerHandler().run(); 
}