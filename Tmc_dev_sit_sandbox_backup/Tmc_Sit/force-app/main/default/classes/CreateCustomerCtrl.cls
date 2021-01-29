/**
 * @File Name          : CreateCustomerCtrl.cls
 * @Description        : This class allow us to show or create the customer records
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    20/10/2019 11:17 AM          Anuj Kumar            Initial Version
**/
public without sharing class CreateCustomerCtrl{
    
    @AuraEnabled
    public static Account getCutomerDetail(String recId){
        system.debug('== recId '+recId);
        String accountRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        system.debug('== accountRecordTypeId '+accountRecordTypeId);
        
        Account acc = new Account();
        
        if(String.isNotBlank(recId)){
            
            List<Account> accountList = [Select id, FirstName, LastName, personEmail, PersonMobilePhone, PersonBirthdate, Enquiry_Type__c,
                    Last_Call_Center_For_Code__c, Parent_CC_Outlet__c, 
                    Parent_CC_Outlet__r.Name from Account 
                    where recordTypeId =: accountRecordTypeId AND Id =: recId];
                    
            system.debug('== accountList '+accountList);
            
            if(!accountList.isEmpty()){
                acc = accountList[0];
            }
            
        }
        return acc;
    }
    
    
    @AuraEnabled
    public static String createCutomer(String recData){
        system.debug('== recData '+recData);
        String accountRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account();
        if(String.isNotBlank(recData)){
            try{
                acc = (Account)JSON.deserialize(recData, Account.class);
                acc.Status__c = ConstantsUtility.PROSPECT_CUSTOMER;            
                acc.OwnerId = system.label.Integration_User;
                acc.SFMC_Sync__c = True;
                acc.recordTypeId = accountRecordTypeId;
                
                if(acc.Id == null){
                    acc.FirstName = acc.First_Name__c;
                    acc.LastName = acc.Last_Name__c;
                    acc.PersonEmail = acc.Email__c;
                    acc.PersonMobilePhone = acc.Mobile__c;
                    acc.PersonBirthdate = acc.Birthday__c;
                }
                system.debug('== acc '+acc);
                
                upsert acc;
                
                return acc.Id;
            } catch (Exception e) {
                
                ExceptionHandler.LogError('CreateCustomerCtrl createCutomer', e.getMessage(), 'createCutomer', '', null);
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return '';
    }
    
    @AuraEnabled
    public static List<For_Code__c> getForCodeDetail(String name){
        List<For_Code__c> forCodeList = new List<For_Code__c>();
        
        if(String.isNotBlank(name)){
            string nameData = '%'+name.trim()+'%';
            
            forCodeList = [Select id, Name from For_Code__c where Name Like: nameData];    
        }
        
        return forCodeList;
    }
    
    @AuraEnabled
    public static DealershipWrapper getAccountDetail(String forCodeId, String dealerchannel, String transtype){
            
        system.debug('== dealerchannel '+dealerchannel);
        system.debug('== transtype '+transtype);
        
        DealershipWrapper dealerWrap = new DealershipWrapper();
        
        Set<String> dealershipChannelSet = new Set<String>();
        
        Boolean checkDealerCategory = false;
        String category = '';
        String dealerType = 'TV';
        
        if(transtype == 'Account.VehicleSales'){
            dealershipChannelSet.add(dealerchannel);
        }else if(transtype == 'Account.CommercialVehicleSales'){
            dealershipChannelSet.add('Com');
        }else if(transtype == 'Account.EnquiryMSDSSales'){
            dealershipChannelSet.add('MDS');
        }else if(transtype == 'Account.AccessoriesSales' || transType == 'Account.SuzukiConnectSales'){
            checkDealerCategory = true;
            category = 'DDT';
            
            dealershipChannelSet.add(dealerchannel);
        }else if(transtype == 'Account.Parts'){
            checkDealerCategory = true;
            category = 'DDT';
            dealershipChannelSet.add('NRM');
        }
        
        
        
        List<Account> accountList = new List<Account>();
        
        String accountRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.DEALER_RECORDTYPE).getRecordTypeId();
        
        if(String.isNotBlank(forCodeId)){
          //  string nameData = '%'+name.trim()+'%';
            
             String query = 'Select id, Name,recordTypeId, BillingPostalCode, Dealer_Type__c, Channel__c, Dealer_Category__c from Account where RecordTypeId = : accountRecordTypeId AND For_Code__c =: forCodeId ';
             
             if(transtype == 'Account.True_Value_Prospect'){
                 query += ' AND Dealer_Type__c =: dealerType';
             }else{
                 query += ' AND Channel__c IN : dealershipChannelSet ';
             }
             
             if(checkDealerCategory && transtype == 'Account.Parts'){
                 query += ' AND Dealer_Category__c =: category';
             }else if(checkDealerCategory && transtype != 'Account.Parts'){
                 query += ' AND Dealer_Category__c !=: category';
             }
             
             
           //  query += ' AND Name Like: nameData ';
             
             accountList = (List<Account>) dataBase.query(query);
             
             Map<String, Pincode> pinCodeMap = new Map<String, Pincode>();
             
             Map<String, List<DealershipInfo>> picodeWithAccountMap = new Map<String, List<DealershipInfo>>();
             
             for(Account acc : accountList){
                 if(String.isNotBlank(acc.BillingPostalCode)){
                     Pincode pin = new Pincode();
                     pin.label = acc.BillingPostalCode;
                     pin.value = acc.BillingPostalCode;
                     pinCodeMap.put(acc.BillingPostalCode, pin);
                     
                     DealershipInfo ds = new DealershipInfo();
                     ds.Id = acc.Id;
                     ds.Name = acc.Name;
                     ds.DealerType = acc.Dealer_Type__c;
                     ds.Channel = getChannelName(acc);
                     ds.variant = '';
                     
                     if(!picodeWithAccountMap.containsKey(acc.BillingPostalCode))
                         picodeWithAccountMap.put(acc.BillingPostalCode, new List<DealershipInfo> ());
                     picodeWithAccountMap.get(acc.BillingPostalCode).add(ds);    
                 }
             }
             
             if(!pinCodeMap.isEmpty() && !picodeWithAccountMap.isEmpty()){
                 
                 dealerWrap.pinCodeList = pinCodeMap.values();
                 dealerWrap.picodeWithAccountMap = picodeWithAccountMap;
             }
        }
        system.debug('== dealerWrap '+dealerWrap);
        return dealerWrap;
    }
    
    public static string getChannelName(Account acc){
        String channel = '';
        
        if(acc.Channel__c == 'Com'){
            channel = 'Commercial';
        }else if(acc.Channel__c == 'MDS'){
            channel = 'MSDS';
        }else if(acc.Channel__c == 'NRM' && acc.Dealer_Category__c == 'DDT'){
            channel = 'Parts';
        }else if(acc.Channel__c == 'NRM' && acc.Dealer_Category__c != 'DDT'){
            channel = 'Arena';
        }else if(acc.Channel__c == 'EXC'){
            channel = 'Nexa';
        }else{
            channel = 'Maruti';
        }
        
        return channel;
    }
    
    public class DealershipWrapper{
        
        @AuraEnabled public List<Pincode> pinCodeList;
        @AuraEnabled public Map<String, List<DealershipInfo>> picodeWithAccountMap;
    }
    
    Public class Pincode{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }
    
    public class DealershipInfo{
        
        @AuraEnabled public string Id;
        @AuraEnabled public string Name;
        @AuraEnabled public string DealerType;
        @AuraEnabled public string Channel;
        @AuraEnabled public string variant;
        
    }
    
}