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
            
            List<Account> accountList = [Select id, Name, First_Name__c, Last_Name__c, Email__c, Mobile__c, Birthday__c, Enquiry_Type__c,
                    Last_Call_Center_For_Code__c, Last_Call_Center_For_Code__r.Name, Last_Call_Center_Dealership__c, 
                    Last_Call_Center_Dealership__r.Name from Account 
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
                }
                system.debug('== acc '+acc);
                
                upsert acc;
                //system.debug('2== acc '+acc);
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
    public static List<Account> getAccountDetail(String name, String forCodeId){
        List<Account> accountList = new List<Account>();
        
        String accountRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.DEALER_RECORDTYPE).getRecordTypeId();
        
        if(String.isNotBlank(name)){
            string nameData = '%'+name.trim()+'%';
            
            accountList = [Select id, Name,recordTypeId from Account where recordTypeId =: accountRecordTypeId 
                AND For_Code__c =: forCodeId AND Name Like: nameData];
        }
        
        return accountList;
    }
    
}