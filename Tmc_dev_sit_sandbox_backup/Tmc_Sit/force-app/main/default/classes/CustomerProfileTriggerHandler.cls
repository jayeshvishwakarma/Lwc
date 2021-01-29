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
    public static void profileUpdatesbyDSE()
    {
        List<Profile> p = [Select Id from profile where Name =: 'Dealer Sales Executive'];
        List<User> u = [select Id from user where id=:userinfo.getuserid() and ProfileId =: p[0].Id Limit 1];
        
        if(u.size() > 0)
        {
            List<Account> acc = [Select Id,No_of_Times_Customer_Profiles_Updated__c,Customer_Profile_Updates_This_Month__c,Customer_Profile_Updates_Today__c
                            from Account where User__c =: u[0].Id limit 1];
            if(acc.size() > 0)
            {
                Integer num;
                Integer tdNum;
                Integer mNum;
                List<DSE_Report_RUn__c> dseRun =DSE_Report_RUn__c.getAll().values();  
                DateTime dt4 = system.now();
                DateTime dt3 = dseRun[0].Daily_End_Time__c;
                DateTime dt5 = DateTime.newinstance(dt3.Year(), dt3.month(), dt3.day(),23,59,59);
                //convert above GMT datetime to local datetime
                dt3 = dt5.Date();
                dt3 = dt3.addHours(dt5.hour());
                dt3 = dt3.addMinutes(dt5.minute());
                dt3 = dt3.addSeconds(dt5.second());
                DateTime dt6 = dseRun[0].Month_End_Time__c;
                DateTime dt7 = DateTime.newinstance(dt6.Year(), dt6.month(), dt6.day(),23,59,59);
                //convert above GMT datetime to local datetime
                dt6 = dt7.Date();
                dt6 = dt6.addHours(dt7.hour());
                dt6 = dt6.addMinutes(dt7.minute());
                dt6 = dt6.addSeconds(dt7.second());
                
                system.debug('246 %%$ '+dt4 + '' + dt3 + '' + dt6);
                if(acc[0].No_of_Times_Customer_Profiles_Updated__c == null) 
                       num =0;
                else
                    num = Integer.valueOf(acc[0].No_of_Times_Customer_Profiles_Updated__c);
                           
                num +=1;       
                acc[0].No_of_Times_Customer_Profiles_Updated__c = String.valueOf(num);
                
                //Calculate Daily Count
                if(acc[0].Customer_Profile_Updates_Today__c == null) 
                    tdnum =0;
                else
                    tdnum = Integer.valueOf(acc[0].Customer_Profile_Updates_Today__c);
                    
                if(dt4>dt3)
                {
                    List<DSE_Adoption__c> dse = [SELECT Id,CreatedDate,Count_of_Customer_Profile_Update_Daily__c,DSEAccount__c
                                            FROM DSE_Adoption__c 
                                            Where DSEAccount__c =: acc[0].Id and IsMonthly__c = false
                                            ORDER BY CreatedDate DESC Limit 1];
                    dse[0].Count_of_Customer_Profile_Update_Daily__c = tdnum;
                    tdnum = 1;
                    dseRun[0].Daily_End_Time__c = (dseRun[0].Daily_End_Time__c).addHours(24);
                    update dse[0];
                    update dseRun[0];
                }
                else
                {
                    tdnum +=1;       
                }
                acc[0].Customer_Profile_Updates_Today__c = tdnum;
                
                //Calculate MOnthly Count
                if(acc[0].Customer_Profile_Updates_This_Month__c == null) 
                    mNum =0;
                else
                    mNum = Integer.valueOf(acc[0].Customer_Profile_Updates_This_Month__c);
                    
                if(dt4>dt6)
                {
                    List<DSE_Adoption__c> dse = [SELECT Id,CreatedDate,Count_of_Customer_Profile_Updates_Month__c,DSEAccount__c
                                            FROM DSE_Adoption__c 
                                            Where DSEAccount__c =: acc[0].Id and IsMonthly__c = true
                                            ORDER BY CreatedDate DESC Limit 1];
                    dse[0].Count_of_Customer_Profile_Updates_Month__c = mNum;
                    mNum = 1;
                    dseRun[0].Month_End_Time__c = (dseRun[0].Month_End_Time__c).addMonths(1);
                    update dse[0];
                    update dseRun[0];
                }
                else
                {
                    mNum +=1;       
                }
                acc[0].Customer_Profile_Updates_This_Month__c = mNum;
                
                update acc[0];
            }
        }
    }

}