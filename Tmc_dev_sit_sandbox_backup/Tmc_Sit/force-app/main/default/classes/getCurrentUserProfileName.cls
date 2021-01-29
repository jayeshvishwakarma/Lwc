/**
 * @File Name          : getCurrentUserProfileName.cls
 * @Description        : To fetch metadata records storing call campaign to script mapping
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Sunit Kumar Chand
 * @Last Modified On   : 25/06/2020, 9:59:19 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/18/2020   Rajesh Ramachandran          Initial Version
 * 1.1   17/06/2020   Nitin Ghai                   Added user query to get logged in user profileName
 * 1.1A  25/06/2020   Sunit Kumar Chand            Added lob in where condition
**/
public without sharing class getCurrentUserProfileName {

    @AuraEnabled(cacheable=true)
    public static DataWrapper getMetadataRecords(string campaignType, string campaignId, string lob){
        System.debug('campaignType:- '+campaignType);
        DataWrapper wrapper= new DataWrapper();
        
        wrapper.profileName=[Select Id, Profile.Name from User where Id=:UserInfo.getUserId() LIMIT 1].Profile.Name;
        
        List<Ad_Hoc_Campaign_CTI__mdt> mdt = New List<Ad_Hoc_Campaign_CTI__mdt>();
        if (campaignType == 'General'){
            mdt = [select Campaign_Type__c,Script_Name__c, Survey_Id__c, Child_Flow_Name__c, Campaign_Id__c,Survey_Urls__c From Ad_Hoc_Campaign_CTI__mdt
            Where Campaign_Id__c=: campaignId and lob__c=: lob ORDER BY Script_Name__c ASC];

        }
        else {
            mdt = [select Campaign_Type__c,Script_Name__c, Survey_Id__c, Child_Flow_Name__c, Campaign_Id__c,Survey_Urls__c From Ad_Hoc_Campaign_CTI__mdt
            Where Campaign_Type__c=: campaignType and lob__c=: lob ORDER BY Script_Name__c ASC];
        }

        if(mdt.size() > 0)
            wrapper.lstmdtRecord= mdt;
        
        return wrapper;
    }
    
    
    public class DataWrapper{
        @AuraEnabled
        public List<Ad_Hoc_Campaign_CTI__mdt> lstmdtRecord{get;set;}
        @AuraEnabled
        public string  profileName{get;set;}
    }
}