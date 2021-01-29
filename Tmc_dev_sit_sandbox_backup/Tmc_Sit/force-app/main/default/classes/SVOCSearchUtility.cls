/**
 * @File Name          : SVOCSearchUtility.cls
 * @Description        : Class to search customer records based on SVOC IDs and create new customers if no records found
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Prabhat Sharma
 * @Last Modified On   : 08/22/2019, 08:58:33 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
* 1.0    08/21/2019, 11:33:33 AM      Prabhat Sharma              Initial Version
**/

//CODE REVIEWED BY: Prabhat Sharma

public with sharing class SVOCSearchUtility {

    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to search customer records based on SVOC ID from Enquiries
        Inputs: map of SVOC ID and null
        Returns: map of SVOC ID and Account Id (Customer)
        History:
        ================
        1.0     20 Aug 2019      Prabhat Sharma    Initial Version
        1.1     17 APr 2020      Deepak Kumar      Update the return type and parameter from string,string to string,Account
        1.2     20 May 2020      Anuj Kumar        Include commercial fields in Account query.
    **/
    public static map<string,Account> searchCustomersBySVOCIds(map<string,Account> svocDetailsMap){

            //Loop through all customer records based on the SVOC Id updated on Enquiry
            //Return SVOC ID as key and customer account record id as value
            for(Account acc : [SELECT Id,SVOC_ID__c,Tier__c,Loyalty_Card_Number__c, COMM_Tier__c, COMM_Loyalty_Card_Number__c
                               from Account WHERE recordtype.name =: ConstantsUtility.CUSTOMER_RECORDTYPE
                               AND SVOC_ID__c in : svocDetailsMap.keySet()]){
                                       if(String.isNotBlank(acc.SVOC_ID__c)){
                                           svocDetailsMap.put(acc.SVOC_ID__c,acc);
                                       }
                                   
            }
            return svocDetailsMap;
        }
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create person accounts (customers) if no customer found for that SVOC Id
        Inputs: List of Opportunities
        Returns: map of SVOC ID and Account Id (Customer)
        History:
        ================
        1.0     22 Aug 2019      Prabhat Sharma    Initial Version
    **/
    
    public static map<string,string> createPersonAccounts(list<Opportunity> svocDetailslist){
        
        //Variable to store accounts to be created
        list<Account> accountsToInsert = new list<Account>();
        //Map to store SVOC ID as key and new created Account ID as values
        map<string,string> svocDetailsMap = new map<String,string>();
        //Get customer record type ID from Account
        String customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.CUSTOMER_RECORDTYPE).getRecordTypeId();
        
        //Loop through trigger.new to create new customers and map the SVOC ID
        for(opportunity opp : svocDetailslist){
            Account acc = new account();
            //First Name from First Name field from Enquiry
            acc.FirstName = opp.First_Name__c!=null ? opp.First_Name__c.toUpperCase() : null;
            //Last Name from Last Name field from Enquiry
            acc.LastName =  opp.Last_Name__c!=null ? opp.Last_Name__c.toUpperCase() : opp.Name;
            //Email from Enquiry custom email field
            acc.PersonEmail = opp.Email__c!=null ? opp.Email__c : null;
            //Mobile phone from Enquiry custom mobile field
            acc.PersonMobilePhone = opp.Mobile__c!=null ? opp.Mobile__c : null;
            //SVOC ID from Enquiry custom SVOC ID field
            acc.SVOC_ID__c = opp.SVOC_ID__c!=null ? opp.SVOC_ID__c : null;
            
            //Default status to prospect
            acc.Status__c = ConstantsUtility.PROSPECT_CUSTOMER;
            
            //Customer Record Type Mapping
            acc.RecordtypeId = customerRecordTypeId;
            //Add new accounts to be created
            accountsToInsert.add(acc);
        }
        
        
        if(accountsToInsert.size()>0){
            Database.insert(accountsToInsert,false);
            
            //Loop through all newly created accounts 
            for(Account acct : accountsToInsert){
                svocDetailsMap.put(acct.SVOC_ID__c,acct.Id);
            }
        }
        return svocDetailsMap;
        
        
    }
}