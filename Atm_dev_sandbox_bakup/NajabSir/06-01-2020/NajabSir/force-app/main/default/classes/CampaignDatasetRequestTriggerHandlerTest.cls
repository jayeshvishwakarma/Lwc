/**
* @File Name          : CreateCustomerCtrlTest.cls
* @Description        :
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   : Najab Maghribi
* @Last Modified On   : 29/10/2020 4:00 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    29/10/2020 4:00 PM         Najab Maghribi            Initial Version
**/
@isTest
public class CampaignDatasetRequestTriggerHandlerTest {
    @testsetup
    static void createTestRecords(){
        String profileId  = TestDataFactory.queryProfileInfo('ATM - Corporate Call Centre Agent');
        User userRec = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          Title = 'ATM - Corporate Call Centre Agent',
                          LocaleSidKey = 'en_US', ProfileId = profileId,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg.com' + String.valueOf(Math.random()));
        
        if(userRec != null){
        	insert userRec;    
        }
        
        User userRec2 = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          Title = 'ATM - Corporate Call Centre Agent',
                          LocaleSidKey = 'en_US', ProfileId = profileId,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg.com' + String.valueOf(Math.random()));
        
        if(userRec2 != null){
        	insert userRec2;    
        }
        
        Id offlineCampaignRecordType =  Schema.SObjectType.Adhoc_Campaign_Request__c.getRecordTypeInfosByDeveloperName().get('Offline_Campaigns').getRecordTypeId();
        Adhoc_Campaign_Request__c adhocCampaignRequestRec = new Adhoc_Campaign_Request__c();
        adhocCampaignRequestRec.Brand__c = 'Swift';
        adhocCampaignRequestRec.Must_Have__c = 'Mass Media';
        adhocCampaignRequestRec.Status__c = 'Approved';
        adhocCampaignRequestRec.Campaign_Stage__c = 'Executed';
        adhocCampaignRequestRec.Approval_Status__c = 'Approved';
        adhocCampaignRequestRec.RecordTypeId = offlineCampaignRecordType;
        if(userRec != null){
        	adhocCampaignRequestRec.CRM_2_Spoc_L1__c = userRec.id;
            adhocCampaignRequestRec.CRM_1_Spoc_L1__c = userRec.id;
            adhocCampaignRequestRec.Research_SPOC__c = userRec.id;    
        }
        List<Adhoc_Campaign_Request__c> adhocCampaignRequestList = new List<Adhoc_Campaign_Request__c>();
        adhocCampaignRequestList.add(adhocCampaignRequestRec);
        INSERT adhocCampaignRequestList;
        
        adhocCampaignRequestList[0].Brand__c = 'Alto';
        adhocCampaignRequestList[0].Campaign_Stage__c = 'Initiated';
        adhocCampaignRequestList[0].Must_Have_Medium__c = 'Research;Digital';
        adhocCampaignRequestList[0].Approval_Status__c = 'Rejected';
        if(userRec2 != null){
        	adhocCampaignRequestList[0].CRM_2_Spoc_L1__c = userRec2.id;
            adhocCampaignRequestList[0].CRM_1_Spoc_L1__c = userRec2.id;
            adhocCampaignRequestList[0].Research_SPOC__c = userRec2.id;    
        }
        UPDATE adhocCampaignRequestList;
    }
    @isTest
    private static void unitTest(){
        List<Adhoc_Campaign_Request__c> adhocCampaignRequestList = [SELECT ID, Name , recordtypeId FROM Adhoc_Campaign_Request__c LIMIT 1];
        
    }
}