@isTest
private class Test_LeadHandler {
    @testSetup static void setup(){
        Campaign campaignObj =  UtilLead.createCampaignRec();
        Lead leadObj = UtilLead.createLeadRec(campaignObj.Id);
    }
    @isTest static void test_autoLeadConvert(){
        Lead leadObj = [SELECT Id, Title__c, FirstName, lastName, Salutation, LeadSource, AdEventName__c, Email, Test_Drive_Given__c, 
                        Customer_Type__c, Upsell_Cross_Sell_Tele_Caller__c, Campaign_Type__c, Sales_Model__c, Enq_Model__c, Variant__c, 
                        Color__c, Gender__c, MobilePhone, Sales_Email__c, Enquiry_Dealership__c, Enquiry_Dealer_City__c FROM Lead LIMIT 1];
        System.assert(leadObj != null, 'Lead records not exist!');
        
        leadObj.Is_Completed__c = true;
        leadObj.Interested_in_New_Car__c = 'Yes';
        update leadObj;
        
        leadObj.Interested_in_TV__c = 'No';
        leadObj.Interested_in_New_Car__c = 'No';
        update leadObj;
    }
}