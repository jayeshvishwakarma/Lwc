/*
 * Name: Test_DatasetTrigger
 * Author: 
 * Description: Test_DatasetTrigger test class is created to test trigger.

Date		Author		Comments
------------------------------------------
13/10/2020				Initial Release
*/
@isTest
private class Test_DatasetTrigger {
    @isTest static void updateStatus(){
        //Create a campaign
        Campaign campObj = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        insert campObj;
        
        //Create a new record in dataset
        Adhoc_Campaign_Request__c datasetObj = new Adhoc_Campaign_Request__c();
        //datasetObj.Name = 'Test trigger';
        datasetObj.Requester_Name__c = UserInfo.getUserId();
        datasetObj.Campaign_ID__c = campObj.Id;
        datasetObj.Omni_Channel_Comm__c = 'No';
        datasetObj.Data_Filter_Requirements__c = 'test';
        datasetObj.Campaign_Objective__c = 'test';
        datasetObj.Expected_Business_Outcome__c = 'test';
        datasetObj.Expected_Delivery_Date__c = System.today();
        datasetObj.Expected_Delivery_Timeline__c = System.today();
        datasetObj.Data_Count_for_Model__c = 10;
        datasetObj.Model_Details__c = 'test';
        datasetObj.Expected_Campaign_Delivery_Baseline__c = 'test';
        datasetObj.Brand__c = 'Alto';
        insert datasetObj;
        
        //Update dataset field
        datasetObj.Data_Submitted_to_DPS__c = true;
        datasetObj.Status__c = 'Pending Data Submission to DPS';
        update datasetObj;
    }
}