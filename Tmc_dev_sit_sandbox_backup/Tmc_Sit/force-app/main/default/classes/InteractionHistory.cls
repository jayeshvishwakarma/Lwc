/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   Interaction History - This class is used in interactionHistory LWC. This class will fetch the Picklist values for 
               Task Type, Task Response, Task Campaign Type and Case Type values. Interaction History will show the Activities(Task) that agent has performed
               with the Customer.
History
Date            Author                Comments
--------------------------------------------------------------------------------------
12-03-2020      Nitin Ghai            Initial Release
16-03-2020      Nitin Ghai			  dealerGroupName added variable to fetch PowerPartner user dealer group Name
24-04-2020      Nitin Ghai            Modified fetchDealerAccounts method for show Parent Group only
------------------------------------------------------------------------------------*/
public class InteractionHistory {
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It will fetch Task Type, Task Response, Task Campaign Type and Case Type Picklist values.
                 If the Logged in user is Partner User then pass the Dealer Parent Group Name
    Inputs: 
    Returns: Wrapper
    History:
    ================
    1.1A     12-03-2020      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static picklistValues fetchPickValues(){
        
        picklistValues pckVar = new picklistValues();
        try{
            List<User> us = [Select Id,Contact.Account.Parent_Group__c FROM User 
                       WHERE ID=:UserInfo.getUserId() AND UserType='PowerPartner' AND Contact.Account.Parent_Group__c!=NULL LIMIT 1];
            if(us.size()>0){
                pckVar.dealerGroupName=us[0].Contact.Account.Parent_Group__c;
            }
            Schema.DescribeFieldResult fieldResultTaskType = Task.Type.getDescribe();
            Schema.DescribeFieldResult fieldResultTaskDisp =Task.Disposition__c.getDescribe();
            Schema.DescribeFieldResult fieldResultTaskServiceType =Task.Service_Type__c.getDescribe();
            Schema.DescribeFieldResult fieldResultCaseType =Case.Type.getDescribe();
            
            List<Schema.PicklistEntry> pleTaskType = fieldResultTaskType.getPicklistValues();
            for( Schema.PicklistEntry pickVal : pleTaskType){
                if (pickVal.isActive()) {
                    pckVar.taskType.put(pickVal.getLabel(),pickVal.getValue());
                }
            } 
            
            List<Schema.PicklistEntry> pleTaskDisp = fieldResultTaskDisp.getPicklistValues();
            for( Schema.PicklistEntry pickVal : pleTaskDisp)
            {
                if (pickVal.isActive()) {
                    pckVar.taskDisposition.put(pickVal.getLabel(),pickVal.getValue());
                }
            }
            
            List<Schema.PicklistEntry> pleTaskserviceType = fieldResultTaskServiceType.getPicklistValues();
            for( Schema.PicklistEntry pickVal : pleTaskserviceType)
            {
                if (pickVal.isActive()) {
                    pckVar.serviceInsuranceValues.put(pickVal.getLabel(),pickVal.getValue());
                }
            }
            List<Schema.PicklistEntry> pleCaseType = fieldResultCaseType.getPicklistValues();
            for( Schema.PicklistEntry pickVal : pleCaseType)
            {
                if (pickVal.isActive()) {
                    pckVar.serviceInsuranceValues.put(pickVal.getLabel(),pickVal.getValue());
                }
            }
        }catch(exception e){
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='InteractionHistory - LWC';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('InteractionHistory - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Account object : fetchPickValues - Method', '', ehst);
        }
        return pckVar;
    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It will search the Parent Group which user will pass as input and it will return the result if any matching Parent Group exist in Salesforce
    Inputs: String Dealer Group Name
    Returns: List<Account>
    History:
    ================
    1.1A     24-04-2020      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static List<Account> fetchDealerAccounts(String dealerGroupName){
        List<Account> parntGroup = new List<Account>();
        Id delerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        if(String.isNotBlank(dealerGroupName)){
            for(Aggregateresult ag : [Select Parent_Group__c FROM Account WHERE RecordTypeId=:delerRecordTypeId AND Parent_Group__c LIKE :dealerGroupName+'%' Group by Parent_Group__c])
            {
                parntGroup.add(new Account(Parent_Group__c=String.valueof(ag.get('Parent_Group__c'))));
            }
        }
        return parntGroup;
    }
    
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: Wrapper created to contain Task Type, Task Response, Task Campaign Type, Case Type Picklist values & Partner User Dealer Parent Group
    ================
    1.1A     12-03-2020        Nitin Ghai    Initial Version
    */
    public class picklistValues{
        @AuraEnabled public Map<String,String> taskType {get;set;}
        @AuraEnabled public Map<String,String> taskDisposition {get;set;}
        @AuraEnabled public String dealerGroupName {get;set;}
        @AuraEnabled public Map<String,String> serviceInsuranceValues {get;set;}
        public picklistValues(){
            taskType = new Map<String,String>();
            taskDisposition = new Map<String,String>();
            serviceInsuranceValues = new Map<String,String>();
            String dealerGroupName='';
        }
    }
	/**
    Author: Rohit Gupta
    Company: Techmatrix
    Description: Method to get customerId(accountid) from Case
    ================
    1.1A     02-11-2020        Rohit Gupta    Initial Version
    */
	@AuraEnabled
    public static String fetchCustomerId(String recid){
        String customerId = '';
        if(String.isNotBlank(recid)){
            Case cs = [SELECT Customer__c FROM CASE WHERE Id =: recid];
            if(cs.Customer__c != null){
                customerId = cs.Customer__c;
                return customerId;
            }
        }
         return customerId;
    }
}