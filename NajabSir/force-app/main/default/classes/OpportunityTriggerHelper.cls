/**
* @File Name          : OpportunityTriggerHelper.cls
* @Description        : Helper class for Opportunity trigger handler
* @Author             : 
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 12/12/2019, 10:28:31 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM                                Initial Version
**/
public with sharing class OpportunityTriggerHelper {
    
    //Static Variable to store all the Opportunities having owner as SPOCs
    public static List<Opportunity> spocOptyList = new list<Opportunity>();
    //Get all the User Id for which Escalation needs to be done
    public static map<Id,set<String>> esclationUsers = new map<Id,set<String>>(); 
	//Store all Enquiry ID and the level to which escalation should happen
	public static map<Id,String> esclationLevels = new map<Id,String>();  
    //Store all Enquiry ID and the level to which escalation should happen
	public static map<String,Task> sendBrochurePhone = new map<String,Task>();  
	

    public OpportunityTriggerHelper(){}
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create instances of Opportunity team member object
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     17 Sept 2019  Prabhat Sharma  Initial Version
    **/
    public  OpportunityTeamMember createOppTeamMemberInstance(Opportunity opp, Account dealer, String field){
        set<String> fieldsOnOpp = new set<String>();
        fieldsOnOpp.add(ConstantsUtility.ACCESSORIES_DSE);
        
        //Create new instances and return
        OpportunityTeamMember oppteamMember = new OpportunityTeamMember();
        oppteamMember.OpportunityId = opp.Id;  
        oppteamMember.UserId = !fieldsOnOpp.contains(field) ? (Id)dealer.get(field) : (Id)opp.get(field);
        
        return oppteamMember;
        
    }

    /**
        Author: Prabhat Sharma
        Description: Method to key value json structure for Last Modified time stamp
        Returns: String
        History:
        Last Modified By: Prabhat Sharma 09 Oct 2019
        ====================================================
        1.0  09 Oct 2019  Prabhat Sharma  Initial Version 
    **/
    public OpportunityShare createOppShareRecords(String parentId, String recordId){
        OpportunityShare newOppShare = new OpportunityShare();
        newOppShare.OpportunityId = parentId;
        newOppShare.UserOrGroupId = recordId;
        newOppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
        newOppShare.OpportunityAccessLevel = ConstantsUtility.OPPSHARE_CONST;
        
        return newOppShare;
    }

    /**
        Author: Prabhat Sharma
        Description: Method to key value json structure for Last Modified time stamp
        Returns: String
        History:
        Last Modified By: Prabhat Sharma 09 Oct 2019
        ====================================================
        1.0  09 Oct 2019  Prabhat Sharma  Initial Version 
    **/
    public String createKeyValueStructure(String label, String value){
        //JSON Key
        String result = ConstantsUtility.DOUBLE_QUOTES+label+ConstantsUtility.DOUBLE_QUOTES+ConstantsUtility.COLON;
        //JSON Value
        result+=ConstantsUtility.DOUBLE_QUOTES+value+ConstantsUtility.DOUBLE_QUOTES;
        //Adding comma at the end
        result+=ConstantsUtility.COMMA;
        
        return result;
    }

     /**
        Author: Prabhat Sharma
        Description: Method to key value json structure for Last Modified time stamp
        Returns: String
        History:
        Last Modified By: Prabhat Sharma 09 Oct 2019
        ====================================================
        1.0  09 Oct 2019  Prabhat Sharma  Initial Version 
        2.0  07 Nov 2019  Anuj            Include general follow up.
    **/
    public Task createTaskRecordInstance(Opportunity opp, String recordTypeId, String subject, String type){
        Task followUp = new Task();
        followUp.ActivityDate = system.today();
        followUp.OwnerId = opp.OwnerId;
        followUp.IsReminderSet = true;
        followUp.Priority = ConstantsUtility.PREBOOKING_FOLLOWUP_PRIORITY;
        followUp.RecordTypeId = recordTypeId;
        followUp.ReminderDateTime = Datetime.now().addMinutes(ConstantsUtility.PREBOOKING_REMINDER_TIME);
        followUp.Status = ConstantsUtility.STATUS_OPEN;
        followUp.Subject = subject;
        followUp.Type = type;
        followUp.IsVisibleInSelfService = true;
        followUp.WhatId = opp.Id;
        
        return followUp;
    }


    /**
        Author: Prabhat Sharma
        Description: Creates new instance of accounts to update
        Returns: Account
        History:
        Last Modified By: Prabhat Sharma 22 Aug 2019
        ====================================================
        1.0  23 Aug 2019  Prabhat Sharma  Initial Version 
    **/
    public Account updateAccountSVOCDetails(Opportunity newOpty, Boolean isUpdateStatus, Boolean isUpdateSVOCId){
        //Instantiate customer account with IDs mapped
        Account acct = new Account();
        //If status needs to be updated
        if(isUpdateStatus)
            acct.Status__c = String.isBlank(newOpty.Customer__r.SVOC_ID__c) ? ConstantsUtility.DUPLICATE_CUSTOMER : newOpty.Customer__r.Status__c;
        //If SVOC ID needs to be updated
        if(isUpdateSVOCId)
            acct.SVOC_ID__c = newOpty.SVOC_ID__c;
        //Map the ID of Accounts from Customer Lookup from Enquiries
        acct.Id = newOpty.Customer__c;

        return acct;
    }
    
}