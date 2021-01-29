/**
* @File Name          : CustomerProfileTriggerHandler.cls
* @Description        : Trigger handler class for Customer Profile
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 19/08/2019, 12:12:16 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0   13/08/2019, 03:14:54 PM      Prabhat Sharma         Initial Version
* 1.1   14/09/2019                   Sumit Gupta            Implemented Deepu's review comments/suggestions
**/

//CODE REVIEWED BY: Prabhat Sharma

public without sharing class CustomerProfileTriggerHandler extends TriggerHandler{
    
    private List<Customer_Profile__c> newList; // To store the list of new Opportunities
    private Map<Id, Customer_Profile__c> oldListMap;

    //filtered list with at-least one of the applicable field value changed
    private List<Customer_Profile__c> applicableList;

    //applicable fields
    private Set<String> applicableFields;

    //Constructor to assign trigger.new to local variable
    public CustomerProfileTriggerHandler(){
        newList = (List<Customer_Profile__c>)trigger.new;
        oldListMap = (Map<Id, Customer_Profile__c>)trigger.oldMap;
        applicableFields = getApplicableFields();
        applicableList = getApplicableRecords();
    }
     public override void beforeUpdate(){
        //Update the relevant fields on Account on update
         setAccountId(this.newList);
       
    }
    
    //Methods executions after update of Customer Profile records
    public override void afterUpdate(){
        //Update the relevant fields on Account on update
        
        updateFieldsonAccount();
        //profileUpdatesbyDSE();
    }
     //Methods executions before insert of Customer Profile records
    public override void beforeInsert(){
        //Update the relevant fields on Account on update
        setAccountId(this.newList);
    }
    
    
     /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to update fields on Account whenever any change happens in related customer profile record
        Returns: void
        History:
        ====================================================
        1.0     13 Aug 2019  Prabhat Sharma  Initial Version 
    **/
    public void updateFieldsonAccount(){
        //This will store all the Accounts to be updated
        List<Account> accountToUpdate = new List<Account>();

        //Loop through trigger.new
        for(Customer_Profile__c newObj : applicableList){
            Account accountObj = new Account();
            
            //Loop through all valid fields and add them into Account object
            for(String validField : applicableFields){
                if(newObj.get(validField)!=null && newObj.get(validField)!=ConstantsUtility.PICKLIST_DEFAULT_VALUE){
                    accountObj = mapFieldValues(newObj,accountObj,validField,validField);
                } 
            }
            
            accountObj = mapFieldValues(newObj,accountObj,ConstantsUtility.ID_CONST,ConstantsUtility.CUSTOMER_FIELDCONST);
            accountObj = mapFieldValues(newObj,accountObj,ConstantsUtility.GENDER_CONST,ConstantsUtility.GENDER_FIELDCONST);
            accountObj = mapFieldValues(newObj,accountObj,ConstantsUtility.AADHAR_CONST,ConstantsUtility.AADHAR_FIELDCONST);
            accountObj = mapFieldValues(newObj,accountObj,ConstantsUtility.PAN_CONST,ConstantsUtility.PAN_FIELDCONST);
            accountObj = mapFieldValues(newObj,accountObj,ConstantsUtility.BIRTHDATE_CONST,ConstantsUtility.BIRTHDATE_FIELDCONST);
            accountObj.Id=newObj.customer__c;
            system.debug(accountObj+'......'+newObj.customer__c);
            //Add all the accounts to be updated in a list
            accountToUpdate.add(accountObj);
        }

        //Update Account records
        if(accountToUpdate.size()>0)
            update accountToUpdate;
        
    }
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to map field values from Customer profile object to Account object (Person Account)
        Returns: Account object instance
        History:
        ====================================================
        1.0     13 Aug 2019  Prabhat Sharma  Initial Version 
    **/
    public Account mapFieldValues(Customer_Profile__c obj, Account accObj, String field, String customField){
        if(obj.get(customField)!=null && obj.get(customField)!=ConstantsUtility.PICKLIST_DEFAULT_VALUE){
            accObj.put(field,obj.get(customField));
        }
        return accObj;
    }

    private Set<String> getApplicableFields(){
        //This will have all the fields of Account
        Map<String, Schema.SObjectField> accountSchemaMap = Schema.SObjectType.Account.fields.getMap(); 
        //This will have all the fields of Customer Profile
        Map<String, Schema.SObjectField> customerProfileSchemaMap = Schema.SObjectType.Customer_Profile__c.fields.getMap();
        //This will store all the valid fields that needs to be updated
        set<String> applicableFields = new set<String>();
        
        //Loop through customer profile schema map and filter out all the valida fields that also exists on Account object
        for(String field : customerProfileSchemaMap.keySet()){
            if(accountSchemaMap.containsKey(field)){
                Schema.DescribeFieldResult fd = accountSchemaMap.get(field).getDescribe();
                if(fd.isCustom() && !fd.isCalculated()){
                    applicableFields.add(field);
                }
            }
        } 
        return applicableFields;
    }

    /**
        Author: Sumit Gupta
        Company: Salesforce
        Description: to return filtered list with at-least one of the applicable field value changed
        Returns: Applicable custom profile records
    **/
    private List<Customer_Profile__c> getApplicableRecords(){
        List<Customer_Profile__c> applicableList = new List<Customer_Profile__c>();
        for(Customer_Profile__c newRec : newList){
           if(oldListMap!=null){ 
            Customer_Profile__c oldRec = oldListMap.get(newRec.Id);
            if(isApplicableRecord(newRec, oldRec)){
                applicableList.add(newRec);
            }
           } 
        }
        return applicableList;
    }

    /**
        Author: Sumit Gupta
        Company: Salesforce
        Description: Applicable fields update check
        Returns: true/false
    **/
    private Boolean isApplicableRecord(Customer_Profile__c newRec, Customer_Profile__c oldRec){
        for(String field : applicableFields){
            if(newRec.get(field) != oldRec.get(field)){
                return true;
            }
        }
        return false;
    }
      /**
        Author: Subhojit Chakraborty
        Company: Salesforce
        Description: set Account Id in case of opportunity initiated customer profile
        Returns: void
    **/
    public void setAccountId(List<Customer_Profile__c> lstNewCustomerProfile){
    system.debug('in');
            Set<Id> setOppId=new set<Id>();List<Opportunity> lstOpps=new List<Opportunity>();
            for(Customer_Profile__c ocpVar:lstNewCustomerProfile){
                if(ocpVar.customer__c==null && ocpVar.Enquiry__c!=null)
                 setOppId.add(ocpVar.Enquiry__c);
            }
        if(setOppId.size()>0){
            Map<Id,Opportunity> mapOpp=new map<Id,Opportunity>([select Id,customer__c from Opportunity where Id in :setOppId]);
            for(Customer_Profile__c ocpVar:lstNewCustomerProfile){
                if(mapOpp!=null && mapOpp.containskey(ocpVar.Enquiry__c))
                 ocpVar.customer__c=mapOpp.get(ocpVar.Enquiry__c).customer__c;
                 system.debug(ocpVar.customer__c);
            }
        }
      
    }
    
    /**
        Author: Rahul Sharma
        Company: MSIL
        Description: Update Counter on DSE's Account for profile updates done by him/her
     **/
    public void profileUpdatesbyDSE(){
                Profile p = [Select Id from profile where Name =: 'Dealer Sales Executive'];
                User u = [select Id from user where id=:userinfo.getuserid() and ProfileId =: p.Id Limit 1];
                if(u != null)
                {
                    Account acc = [Select Id,No_of_Times_Customer_Profiles_Updated__c from Account where User__c =: u.Id limit 1];
                    if(acc != null)
                    {
                        Integer num;
                        if(acc.No_of_Times_Customer_Profiles_Updated__c == null) 
                               num =0;
                        else
                            num = Integer.valueOf(acc.No_of_Times_Customer_Profiles_Updated__c);
                                   
                        num +=1;       
                        acc.No_of_Times_Customer_Profiles_Updated__c = String.valueOf(num);
                        update acc;
                    }
                }
    }

}