/**
* @File Name          : ServiceCalculator.cls
* @Description        : This class is used to show Service Cost applicable for Searched Asset. This class is getting used in serviceCalculator LWC. It takes Input
                        as Registration Number, Service Type & Kilometre.
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : Nitin Ghai
* @Last Modified On   : 21/06/2020, 11:02:00 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    1/1/2020, 11:52:23 PM        Nitin Ghai                 Initial Version
* 1.1   12/2/2020, 03:37:30 PM        Nitin Ghai		         changes in fetchCityandAssestInfo method Removed City refrence and 
                                                                 added For Code from Dealer Account
* 1.2   24/4/2020  06:02:00 PM        Nitin Ghai                 Removed API call from Apex class and added to LWC cmp
* 1.3   21/06/2020 11:02:00 AM        Nitin Ghai                 Updated Method and Wrapper to fetch Workshop Rec
* 1.4   25/08/2020 14:00:00 PM        Nitin Ghai                 Added VIN__c in query
* 1.5   22/10/2020                    Nitin Ghai                 Added method fetchDealerWorkshopList for Internal users
**/
public without sharing class ServiceCalculator {
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method will return us the Wrapper of Customer Related Asset and Workshop List.
    Inputs: Record Id(Account)
    Returns: Wrapper
    History:
    ================
    1.1A    1/1/2020      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static ServiceCalculatorWrapper fetchCityandAssestInfo(String recordId){
        Id assetVehicleRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        ServiceCalculatorWrapper serviceWarpper = new ServiceCalculatorWrapper();
        try{
            if(String.isNotBlank(recordId)){
              	//Added by Prashant Gahlaut on 27/10/2020
              	//functions to call service calculator on Asset obj
                if(recordId.contains('02i')){
                    recordId = [Select AccountId  FROM Asset where Id=:recordId AND AccountId != null AND RecordTypeId=:assetVehicleRecTypeId ].AccountId;
                }
                //This will have information related to Registration number of Customer's vehicle
                serviceWarpper.registrationNumberList = [Select Registration_Number__c,Name,VIN__c FROM Asset where AccountId=:recordId AND RecordTypeId=:assetVehicleRecTypeId];
                serviceWarpper.userData= [Select Id,isPortalEnabled,profile.Name from User where Id=:UserInfo.getUserId()];
                if(serviceWarpper.userData!=NULL && serviceWarpper.userData.isPortalEnabled){
                    //This will have info related to Workshop
                    serviceWarpper.workShopList=CreateAppointment.fetchWorkShopList();
                }else{
                    //Query for Internal Users
                    serviceWarpper.forCodeList=[Select Id,Name from For_Code__c where For_Code__c!=NULL];
                }
                
            }
        }
        catch(exception e){
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='serviceCalculator - LWC';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('ServiceCalculator - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Account object : fetchCityandAssestInfo - Method', recordId, ehst);
        }
        return serviceWarpper;
    }
    
    @AuraEnabled
    public static List<Account> fetchDealerWorkshopList(String forCodeId){
        system.debug('forCodeId---->'+forCodeId);
        List<Account> dealerRec = new List<Account>();
        if(String.isNotBlank(forCodeId)){
            dealerRec=[Select id,Name,BillingPostalCode,Channel__c,Dealer_Type__c,Dealer_Category__c,For_Code__r.Name,Dealer_Address_F__c,For_Code__r.For_Code__c,Parent_Group__c,Dealer_Map_Code__c,Dealer_Location__c
                       from Account where RecordTypeId=:ConstantsUtility.DEALER_ACCOUNT_RECORDTYPE_ID 
                       AND For_Code__c=:forCodeId
                       AND Parent_Workshop_Code__c!=NULL];
                }
        return dealerRec;
    }
    
    
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: Wrapper created to contain the Registration Number of Customer Asset's and Workshop List.
    ================
    1.1A     1/1/2020        Nitin Ghai    Initial Version
    */
    public class ServiceCalculatorWrapper{
        @AuraEnabled
        public List<Asset> registrationNumberList {get;set;}
        @AuraEnabled
        public List<Account> workShopList {get;set;}
        @AuraEnabled 
        public List<For_Code__c> forCodeList {get;set;}
        @AuraEnabled 
        public User userData {get;set;}
        public ServiceCalculatorWrapper(){
            // Variable to contain Registration Number
            registrationNumberList=new List<Asset>();
            // Variable to contain List of Workshop
            workShopList = new List<Account>();
            // Variable to store For Code
            forCodeList = new List<For_Code__c>();
            userData=new User(); //logged in User data
        }
    }
}