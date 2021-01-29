/*------------------------------------------------------------------------------------
Author:        Mahith Madwesh
Description:   Get Latest Job Card Details Controller

History
Date            Author                Comments
--------------------------------------------------------------------------------------
27-12-2019      Mahith Madwesh            Initial Release
07-04-2020      Nitin Ghai                Added RecordTypeId Parameter,Updated fetchData Method and 
                                          added fetchAssetData and WrapperClass
03-06-2020      Mahith Madwesh            Get the asset name if it is in localStorage 
08-06-2020      Mahith Madwesh            Removed unused variables and wrapper class 
25-09-2020      Nitin Ghai                Updated fetchData to fetch Workshop List 
------------------------------------------------------------------------------------*/
public without sharing class GetLatestJobCardDetails {
    @AuraEnabled
    public static WrapperClass fetchData(String recordId) {
        WrapperClass assetDealerRec = new WrapperClass();
        try{
            String dealerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
            String recordTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            if(String.isNotBlank(recordId)){
                User us = [Select Id,Account.Parent_Workshop_Code__c from User where Id=:userInfo.getUserId()];
                assetDealerRec.assetRec = [SELECT Name,Registration_Number__c FROM Asset WHERE AccountId = :recordId AND RecordTypeId=:recordTypeId];
                
                if(us!=NULL){
                    assetDealerRec.dealerRec=[Select Id,Dealer_code__c,For_code__c,Outlet_code__c,For_code__r.For_code__c FROM Account 
                                              WHERE Account.Parent_Workshop_Code__c=:us.Account.Parent_Workshop_Code__c AND recordtypeid =:dealerRecTypeId];
                }
            }
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return assetDealerRec;
    }
    
    /**
	 Author: Mahith Madwesh
	 Company: Salesforce
	 Description: Get the asset Name if it is present in localStorage
	 Inputs:
	 Returns:
	 History:
	 ================
	 1.0     03 JUN 2020      Mahith     Initial Version
	 */
    @AuraEnabled(cacheable=true)
    public static asset getAssetName(string assetCacheId){
        return [SELECT Name,Registration_Number__c FROM asset WHERE Id=:assetCacheId].get(0);
    }
    
    //*****Wrapper for Dealer Internal(Nitin Ghai)******/
    public class WrapperClass{
        @AuraEnabled
        public List<Account> dealerRec {get;set;}
        @AuraEnabled
        public List<Asset> assetRec {get;set;}
        public WrapperClass(){
            dealerRec=new List<Account>();
            assetRec= new List<Asset>();
        }
    }
}