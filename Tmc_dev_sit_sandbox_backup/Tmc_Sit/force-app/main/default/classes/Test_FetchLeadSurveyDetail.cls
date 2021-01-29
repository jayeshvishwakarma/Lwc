/*
 * Name  : Test_FetchLeadSurveyDetail.cls
 * Author: 
 * Description: Test_FetchLeadSurveyDetail test class is created to test FetchLeadSurveyDetail apex class.

Date		Author		Comments
------------------------------------------
13/10/2020				Initial Release
*/
@isTest
private class Test_FetchLeadSurveyDetail {
    @testSetup static void setup(){
        // insert custom settings
        Implementation_Strategy__c implSetting = new Implementation_Strategy__c();
        implSetting.Name = '3';
        implSetting.Identifier_Type__c = 'Record Type';
         implSetting.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        implSetting.Strategy_Key__c = 'Vehicle_Sales';
        implSetting.Use_Case__c = 'OpportunityTriggers';
        insert implSetting;
        //create custom setting record
        List<Implementation_Strategy__c> cusSettingList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c cusSetting = new Implementation_Strategy__c();
        cusSetting.Identifier_Type__c = 'Record Type';
        cusSetting.Name = '1';
        cusSetting.Strategy_Implementation__c = 'LeadTriggerServiceImpl';
        cusSetting.Strategy_Key__c = 'aCRM';
        cusSetting.Use_Case__c = 'LeadTriggers';
        cusSettingList.add(cusSetting);
        
        Implementation_Strategy__c customSetting = new Implementation_Strategy__c();
        customSetting.Identifier_Type__c = 'Record Type';
        customSetting.Name = '2';
        customSetting.Strategy_Implementation__c = 'LeadPathTriggerServiceImpl';
        customSetting.Strategy_Key__c = 'Lead_path';
        customSetting.Use_Case__c = 'LeadTriggers';
        cusSettingList.add(customSetting);
        
        insert cusSettingList;

        Campaign campaignObj =  UtilLead.createCampaignRec();
        Lead leadObj = UtilLead.createLeadRec(campaignObj.Id, 'aCRM');
        Lead leadNewObj = UtilLead.createLeadRec(campaignObj.Id, 'New Lead');
        Survey_Question_CTI__c ques = UtilLead.createQuestion(null, campaignObj.Id);
        Survey_Question_CTI__c ques2 = UtilLead.createQuestion(ques.Id, campaignObj.Id);
        Survey_Answer_CTI__c answer = UtilLead.createAnswer(ques.Id);
        Survey_Response_CTI__c responseObj = UtilLead.createResponse(leadObj.Id, ques.Id);
    }
    
    @isTest static void test_getDetails_WithNoResponse(){
        delete [SELECT Id FROM Survey_Response_CTI__c];
        Lead leadObj = [SELECT Id, Title__c, FirstName, lastName, Salutation, LeadSource, AdEventName__c, Email, Test_Drive_Given__c, 
                        Customer_Type__c, Upsell_Cross_Sell_Tele_Caller__c, Campaign_Type__c, Sales_Model__c, Enq_Model__c, Variant__c, 
                        Color__c, Gender__c, MobilePhone, Sales_Email__c, Enquiry_Dealership__c, Enquiry_Dealer_City__c FROM Lead LIMIT 1];
        
        System.assert(leadObj.Id != null, 'Lead record not exist!');
        FetchLeadSurveyDetail.getDetails(leadObj.Id, 'English');
    }
    
    @isTest static void test_getDetails(){
        Test.startTest();
        List<Lead> leadList = [SELECT Id, Title__c, FirstName, lastName, Salutation, LeadSource, AdEventName__c, Email, Test_Drive_Given__c, 
                        Customer_Type__c, Upsell_Cross_Sell_Tele_Caller__c, Campaign_Type__c, Sales_Model__c, Enq_Model__c, Variant__c, 
                        Color__c, Gender__c, MobilePhone, Sales_Email__c, Enquiry_Dealership__c, Enquiry_Dealer_City__c FROM Lead];
        System.assert(leadList[0].Id != null, 'Lead record not exist!');
        
        Survey_Response_CTI__c response = [SELECT Id, Response__c, Survey_Question__c, Unique_ID__c, Lead__c, ResponseText__c 
                                           FROM Survey_Response_CTI__c LIMIT 1];
        System.assert(response.Id != null, 'Survey response not exist!');
        
        FetchLeadSurveyDetail.getDetails(leadList[0].Id, 'English');
        
        String responseData = '['+JSON.serialize(response)+']';
        System.assert(String.isNotBlank(responseData), 'Response data is empty!');
        FetchLeadSurveyDetail.submitSurveyResponse(responseData, true, leadList[0].Id);
        Test.stopTest();
    }
    
    @isTest static void test_retriveLookupResult(){
        String query = ' AND RecordType.Name = \'Variants\' AND Model__c =\'Maruti Alto 800 \'';
        FetchLeadSurveyDetail.retriveLookupResult('Product2', 'Name', 'Maruti', query);
    }
}