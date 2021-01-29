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


    //Added to store brochure Request Records
    public static map<String,Brochure_Request__c> sendBrochureRequestPhone = new map<String,Brochure_Request__c>(); 

    public OpportunityTriggerHelper(){}

        /**
           Author: Avaneesh Singh
           Company Techmatrix
           Description : Method to replace the Sales , Service , TV , Accesseries SPOC to accountContactRelation object field data
           inputs : Set of account id
           return : Set of user id
           History :
           ===================================================
           1.2 9 April 2020

        **/

            public Map<Id,Set<String>> fetchRelatedAccConRelationUser(set<Id> accountIdSet){
                Map<Id,Set<String>> accountGroupUserMap = new Map<Id,Set<String>>();
                  List<AccountContactRelation> accountContactList = [select id , accountid,ContactId from AccountContactRelation
                                                                           where accountid In : accountIdSet AND Roles =:ConstantsUtility.Sales_SPOC];
                    if(accountContactList.size() > 0){

                            Set<Id> contactIdSet = new Set<Id>();
                                for(AccountContactRelation accCon : accountContactList){
                                    if(accCon.contactid != null){
                                      contactIdSet.add(accCon.contactid);
                                    }
                                }

                            for(user user : [select id , contactid,accountid from user where contactid In :contactIdSet
												and isActive = true]){
                                if(!accountGroupUserMap.containsKey(user.accountid)){
                                  accountGroupUserMap.put(user.accountid , new Set<String>());
                                }
                                accountGroupUserMap.get(user.accountid).add(user.id);
                            }
                     }
               return accountGroupUserMap ;
            }




        /**
            Author: Avaneesh Singh
            Company: Techmatrix
            Description: Method to group the accountid with role and set of user
            Inputs: None
            Returns: void
            History:
            ====================================================
            R1.2     9 April 2020 Avaneesh Singh  (US861: Stake holder Management)
        **/
        public Map<String,Set<Id>> accountContactRoleGroup(Set<Id> accountIdSet){
            Map<String,Set<Id>> accWithRoleUserSetMap = new Map<String,Set<Id>>();
            List<AccountContactRelation> accountContactList = [select id , accountid,ContactId,Roles from AccountContactRelation
                                                                   where accountid In :accountIdSet];

                if(accountContactList.size() > 0){
                    Set<Id> contactIdSet = new Set<Id>();
                        for(AccountContactRelation accCon : accountContactList){
                            if(accCon.contactid != null){
                              contactIdSet.add(accCon.contactid);
                            }
                        }


                    Map<id,Set<Id>> accountWithUserMap = new Map<Id,Set<Id>>();
                    for(user user : [select id , contactid,accountid from user where contactid In :contactIdSet AND IsActive = true]){
                       if(!accountWithUserMap.containsKey(user.accountid)){
                         accountWithUserMap.put(user.accountid , new Set<Id>());
                       }
                       accountWithUserMap.get(user.accountid).add(user.id);
                    }

                   for(AccountContactRelation acr : accountContactList){
                       if(acr.Roles != null){
                          if(!accWithRoleUserSetMap.containskey(acr.accountid+'#'+acr.Roles) && accountWithUserMap.containsKey(acr.accountid)){
                           accWithRoleUserSetMap.put(acr.accountid+'#'+acr.Roles,accountWithUserMap.get(acr.accountid));
                          }
                       }
                   }
                }
           return accWithRoleUserSetMap ;
        }

        /**
            Author: Avaneesh Singh
            Company: Techmatrix
            Description: Method to create instances of Opportunity team member based on Account
            Inputs: None
            Returns: void
            History:
            ====================================================
            R1.2     9 April 2020 Avaneesh Singh  (US861: Stake holder Management)
        **/
        public  List<OpportunityTeamMember> createOppTeamMemberAccountCon(Opportunity opp, id accountid,String AccountContactRoleStr, Map<String,Set<Id>> accountRoleKeyUserIdMap){
            List<OpportunityTeamMember> OpportunityTeamMemberList = new List<OpportunityTeamMember>();

            if(accountRoleKeyUserIdMap.containsKey(accountid+'#'+AccountContactRoleStr)){
               for(Id userId : accountRoleKeyUserIdMap.get(accountid+'#'+AccountContactRoleStr)){
                   OpportunityTeamMember oppteamMember = new OpportunityTeamMember();
                   oppteamMember.OpportunityId = opp.Id;
                   oppteamMember.UserId = userId;
                   OpportunityTeamMemberList.add(oppteamMember);
               }
           }
             return OpportunityTeamMemberList ;
       }
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
    public Task createTaskRecordInstance(Opportunity opp, String recordTypeId, String subject, String type, Integer reminderTime){
        Task followUp = new Task();
        followUp.ActivityDate = system.today();
        followUp.OwnerId = opp.OwnerId;
        followUp.IsReminderSet = true;
        followUp.Priority = ConstantsUtility.PREBOOKING_FOLLOWUP_PRIORITY;
        followUp.RecordTypeId = recordTypeId;
        followUp.ReminderDateTime = Datetime.now().addMinutes(reminderTime);
        followUp.Status = ConstantsUtility.STATUS_OPEN;
        followUp.Subject = subject;
        followUp.Type = type;
        followUp.IsVisibleInSelfService = true;
        followUp.WhatId = opp.Id;

        // Added as Part on Trigger Refactor - By Anuj
        followUp.First_FollowUp__c = True;

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
     /**
        Author: Gitika Khandelwal
        Description: Method to create Instance of Task Object
        Returns: Task
        History:
        ====================================================
        1.0  9 April 2020  Gitika Khandelwal  Initial Version
    **/

    public Task createLoyaltyEnrolmentFollowUps(Opportunity opp, String recordTypeId,
                                                String type, string priority,date activitydate ,String channel){

        Task followUp = new Task();
        followUp.ActivityDate = activitydate;
        followUp.OwnerId = opp.OwnerId;
        followup.CreatedById=opp.OwnerId;
        followUp.IsReminderSet = true;
        followUp.Priority = priority;
        followUp.RecordTypeId = recordTypeId;
        followUp.Status = ConstantsUtility.STATUS_OPEN;
        followUp.Type = type;
        followUp.IsVisibleInSelfService = true;
        followUp.WhatId = opp.Id;
        // Added as Part on Trigger Refactor - By Anuj
        followUp.First_FollowUp__c = True;

                                                 //   if(string.isNotBlank(channel))
                                                 //    followUp.LOB__c = channel;

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
    @AuraEnabled
    public static String validateLoyalty(String recordId){
        String validateMessage = '';
        User currentUser = [SELECT Id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        if(currentUser.Profile.Name!=ConstantsUtility.DEALER_QCM && currentUser.Profile.Name!=ConstantsUtility.DEALER_HOSTESS && currentUser.Profile.Name!=ConstantsUtility.PROFILE_SYSTEM_ADMIN){
            validateMessage = 'Only Hostess & Loyalty Executives can create Loyalty Enrollments.';
        }
        else{
            List<Opportunity> existingEnrollments = new list<Opportunity>([SELECT Id FROM Opportunity WHERE Asset__c=:recordId and RecordtypeId =:OpportunityTriggerStrategyHelper.loyaltySalesId]);
            if(existingEnrollments.size()>0){
                validateMessage = 'Loyalty Enrollment already exists for this customer.';
            }
        }

        return validateMessage;

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
    @AuraEnabled
    public static Opportunity fetchCustomerDetails(String recordId){
        Opportunity opty = new Opportunity();
        opty.Asset__c = recordId;
        opty.CloseDate = Date.today()+30;
        opty.StageName='New';
        opty.RecordTypeId = OpportunityTriggerStrategyHelper.loyaltySalesId;
        List<Asset> assetDetails = new list<Asset>([SELECT Id,Account.Id,Account.FirstName,Account.LastName,Account.PersonMobilePhone,Account.PersonEmail,VIN__c FROM Asset WHERE Id=:recordId]);
        if(assetDetails.size()>0){
            opty.First_Name__c = assetDetails[0].Account.FirstName;
            opty.Last_Name__c = assetDetails[0].Account.LastName;
            opty.Mobile__c = assetDetails[0].Account.PersonMobilePhone;
            opty.Email__c = assetDetails[0].Account.PersonEmail;
            opty.Customer__c = assetDetails[0].Account.Id;
            opty.VIN__c = assetDetails[0].VIN__c;

        }

        List<User> userInfo = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()];

        if(userInfo[0].Channel__c!=null){
            opty.Dealership_Channel__c = userInfo[0].Channel__c;

            if(userInfo[0].Channel__c == ConstantsUtility.NEXA_LINEOFBUSINESS)
                opty.Loyalty_Program_Type__c = ConstantsUtility.MARUTI_PROGRAM_TYPE;
            else if(userInfo[0].Channel__c == ConstantsUtility.ARENA_LINEOFBUSINESS)
                opty.Loyalty_Program_Type__c = ConstantsUtility.MARUTI_PROGRAM_TYPE;
            else if(userInfo[0].Channel__c == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS)
                opty.Loyalty_Program_Type__c = ConstantsUtility.COMMERCIAL_PROGRAM_TYPE;
        }


        return opty;
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
    @AuraEnabled
    public static String saveEnrollmentDetails(String jsonWrap){
        String message = 'Success';
        Savepoint sp = Database.setSavepoint();
        try{
            Opportunity opty = (Opportunity)System.JSON.deserialize(jsonWrap, Opportunity.class);

            insert opty;
            message+='#'+opty.Id;

        }catch(DMLException ex){
            Database.rollback(sp);
            message = 'Error ';
            for(Integer i=0;i<ex.getNumDml();i++) { message += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'Loyalty Enrollment'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('Loyalty Enrollmen', ex.getMessage(), 'Loyalty Enrollmen', '', ehst);
        }


        return message;
    }

}