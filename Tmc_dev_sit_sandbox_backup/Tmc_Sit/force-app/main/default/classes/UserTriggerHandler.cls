/**
* @Autho:- Nishant Prajapati
* @Company-: Techmatrix Consulting
* @Description-: Handler class for User Trigger.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       01 Oct 2019    Nishant     Intial Version
* 1.1       01 Dec 2019    Subhojit    Added logic to add external user to related public group
**/
public without sharing class UserTriggerHandler extends TriggerHandler{

    private list<User> newUserList; // Used to store the list of new User
    private Map<Id, User> oldUserMap; // Used to store Map of old User
    public static map<id,Brands_Role_Mapping__mdt> brandRoleMap; //Map used to store the brand role mappings.

    static{
        list<string> roleDeveloperName = new list<string>(); //variable to hold the role DeveloperName
        map<string,Brands_Role_Mapping__mdt> tempRoldMap = new map<string,Brands_Role_Mapping__mdt>(); //Map tp hold the Id to Brands Map
        brandRoleMap = new  map<id,Brands_Role_Mapping__mdt>();

        //Iterate and fetch the custom metadata
        for(Brands_Role_Mapping__mdt role :[select id, DeveloperName, Department__c from Brands_Role_Mapping__mdt]){ //No limit as the query is on Metadat and doesnt have more than 10 records.
        roleDeveloperName.add(role.DeveloperName);
        tempRoldMap.put(role.DeveloperName, role);
        }

        for(UserRole role : [select id,DeveloperName from UserRole where DeveloperName in :roleDeveloperName]){
            brandRoleMap.put(role.id, tempRoldMap.get(role.DeveloperName));
        }

    }


    public UserTriggerHandler() {
        this.newUserList= (list<User>) Trigger.new;
        this.oldUserMap= (Map<Id, User>) Trigger.oldMap;
    }

    public override void beforeInsert() {

        check4ProfileUpdate();
        ChecKMobileNumber();
		checkForExistingUserName();
    }

    public override void beforeUpdate() {
        check4ProfileUpdate();
        ChecKMobileNumber();
        checkForDMSActive();
		captureDateTimeUserBecomingActiveAgain();
    }

    public override void afterInsert() {
        /*AU-IM016110824 Changed the sequence for Error:Group member operation already in progress */
        if(!Test.isRunningTest())
            addUserToDealerMasterPublicGroup();

        callScheduleApexJob();
        //setPasswordForPartnerUsers();
        assignSalesSPOC();
        addUserToChatterGroup();
        //Added By Anas Yar Khan on 14 Sept 2020
        updatePhoneAndDesignationOnContact(); 
        //Added 3rd Dec 2020
        serviceUserInsertToGroup();
    }

    public override void afterUpdate() {
        callScheduleApexJob();
        //setPasswordForPartnerUsers();
       assignSalesSPOC();
        removeInActiveSalesSpoc();
	if(UtilityHelper.isTriggerRun == true)
        checkDealerUpdatedThePassword();
        //Added By Anas Yar Khan on 14 Sept 2020
        updatePhoneAndDesignationOnContact();
        //Added 3rd Dec 2020
        serviceUserInsertToGroup();
	
    }

    /**
Author: Nishant Prajapati
Company: Techmatrix
Description: record is being inserted or user profile field is being updated, update the profile change flag and capture the old profile.
Inputs:
Returns: void
History:
====================================================
1.0     01 Oct 2019  Nishant  Initial Version

**/
    public void check4ProfileUpdate(){

        Map<Id, string> userProfileMap= new Map<Id, string>();
        Map<Id, Profile> ProfileMap= new Map<Id, Profile>();

        // Commented as part of the issue fix where users are not getting added to the public group. On 20/Feb/2020 By Anuj.

        //check if any scheduled job already exist before updating user profile update flag
        //Integer jobInfo= [SELECT count() FROM AsyncApexJob WHERE  ApexClass.Name= 'MapProfileToGroupBatchScheduler' AND JobType= 'ScheduledApex' AND Status IN: System.Label.Batch_APEX_Status.split(',')];

        // if(jobInfo == 0){
        if(trigger.isUpdate){
            for(User ur : newUserList){
                if(ur.profileId <> oldUserMap.get(ur.Id).profileId){
                    userProfileMap.put(ur.id, oldUserMap.get(ur.Id).profileId);
                }
            }

            if(userProfileMap.size() > 0){
                ProfileMap= new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Id IN: userProfileMap.values()]);
            }
        }

        for(User ur : newUserList){
            Boolean isUpdatedProfile= trigger.isUpdate && ur.profileId <> oldUserMap.get(ur.Id).profileId;
            if(trigger.isInsert || isUpdatedProfile){
                ur.Profile_Updated__c= true;
                if(isUpdatedProfile && userProfileMap.containskey(ur.Id) && String.isBlank(ur.Previous_Profile_Name__c)){
                    ur.Previous_Profile_Name__c= ProfileMap.get(userProfileMap.get(ur.Id)).Name;
                }

            }
        }
        //  }
    }

    public  void callScheduleApexJob(){
        boolean callScehdular= false;
        boolean callScehdular1= false;
        boolean isInsert;
        boolean isInactiveBatch=UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','inactiveBatch');
        boolean isActiveCheck=false;
        boolean eval=false;
        set<string> uIds = new set<string>();
        set<string> uIds1 = new set<string>();
        //Rahul R Updates for MOS
        set<string> profileName = new set<string>();
                                                    
        for(inActiveUsers__mdt inActiveLabel :[select DeveloperName from inActiveUsers__mdt  LIMIT 500]){
                profileName.add(inActiveLabel.DeveloperName);
            }    

        Map<Id,Profile> profiles = new Map<Id,Profile>([Select Id from Profile where Name =:profileName]);
        //system.debug('isinsert check - ' + UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','isInsert'));
        for(User ur : newUserList){
            if (ur.IsActive==true)
                isActiveCheck=true;
            
            if(profiles.keySet().contains(ur.ProfileId))
            {
                eval=true;
                if(Trigger.IsInsert)
                    uIds.add(ur.Id);
                if(Trigger.IsUpdate)
                    uIds1.add(ur.Id);
            }
        }
        /*if(Trigger.IsUpdate && eval == true){
            if(isActiveCheck==false){
                if(!System.isFuture() && !System.isBatch()){
                    isInsert=UtilityHelper.updateAndRetreiveEvalFlag(false,'update','Isinsert');
                }
            }else{
                if(!System.isFuture() && !System.isBatch()){
                    UtilityHelper.updateEvalSetting(false,'Isinsert');
                }
            }
        }
        if(Trigger.IsInsert && eval == true){
            Boolean isInsert1 = UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','isInsert');
            if(isInsert1 == false)
            {
                if(!System.isFuture() && !System.isBatch()){
                    UtilityHelper.updateEvalSetting(true,'Isinsert');
                }
            }
        }
        system.debug('isinsert check - ' + UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','isInsert'));
        */
        for(User ur : newUserList){
            system.debug('120- isInactiveBatch'+isInactiveBatch + ur.IsActive + ur.DMS_Active__c + ur.ProfileId + profiles.keySet());
            if(profiles.keySet().contains(ur.ProfileId) && (ur.IsActive == true || ur.DMS_Active__c == false) && isInactiveBatch==false){
                callScehdular1= true;
                break;
            }
        }
        for(User ur : newUserList){
            if(ur.Profile_Updated__c){
                callScehdular= true;
                break;
            }
        }
        if(callScehdular){
            Schedule_Apex_Job_Time__c mc = Schedule_Apex_Job_Time__c.getOrgDefaults();

            /*
*  Comment : Logic added to add the bulk user records to public groups.
*  Added By : Anuj
*  Date : 20/feb/2020
*/

            /*
*  Comment : logic added to run schedule for 20 mins from start of user creation
*  Added By : Rahul Sharma - MSIL
*  Date : 21/mar/2020
*/
            //check if any scheduled job already exist before updating user profile update flag
            Integer jobInfo= [SELECT count() FROM AsyncApexJob WHERE  ApexClass.Name= 'MapProfileToGroupBatchScheduler' AND JobType= 'ScheduledApex' AND Status IN: System.Label.Batch_APEX_Status.split(',')];
            if(jobInfo == 0){
                DateTime currentInstance = System.Now().addMinutes(20);

                //Construct the Cron String
                String crn = '00 '+ currentInstance.minute()+' '+ currentInstance.hour()+' '+currentInstance.day()+' '+currentInstance.Month()+' ? '+currentInstance.year();

                MapProfileToGroupBatchScheduler sch = new MapProfileToGroupBatchScheduler();
                //schedule job for 20 mins from now
                 if(!Test.isRunningTest())
                {
                    system.schedule('MapProfileToGroupBatchScheduler'+string.valueof(currentInstance)+':'+string.valueof(currentInstance.millisecond()),crn,sch);
                // ScheduleApexJob.findBatchApex(ConstantsUtility.ASYNC_APEX_BATCH, 'MapProfileToGroupBatchScheduler',Integer.valueof(mc.Time_in_minutes__c));
                TriggerHandler.bypass('UserTriggerHandler');
                TriggerHandler.clearBypass('UserTriggerHandler');
                }
            }
        }
        if(callScehdular1 && Trigger.IsInsert){
            /*Schedule_Apex_Job_Time__c mc = Schedule_Apex_Job_Time__c.getOrgDefaults();
ScheduleApexJob.findBatchApex(ConstantsUtility.ASYNC_APEX_BATCH1, 'inActiveTVEvaluatorSchedule',Integer.valueof(mc.Time_in_minutes__c));
TriggerHandler.bypass('UserTriggerHandler');
TriggerHandler.clearBypass('UserTriggerHandler');*/
            DateTime currentInstance = System.Now().addMinutes(5);
            //Construct the Cron String
            String crn = '00 '+ currentInstance.minute()+' '+ currentInstance.hour()+' '+currentInstance.day()+' '+currentInstance.Month()+' ? '+currentInstance.year();
            inActiveTVEvaluatorSchedule sch = new inActiveTVEvaluatorSchedule(uIds);
            //schedule job for 5 mins from now
            if(!Test.isRunningTest())
                system.schedule('inActiveTVEvaluatorSchedule'+string.valueof(currentInstance)+':'+string.valueof(currentInstance.millisecond()),crn,sch);
        }
        if(callScehdular1 && Trigger.IsUpdate){
            /*Schedule_Apex_Job_Time__c mc = Schedule_Apex_Job_Time__c.getOrgDefaults();
ScheduleApexJob.findBatchApex(ConstantsUtility.ASYNC_APEX_BATCH1, 'inActiveTVEvaluatorSchedule',Integer.valueof(mc.Time_in_minutes__c));
TriggerHandler.bypass('UserTriggerHandler');
TriggerHandler.clearBypass('UserTriggerHandler');*/
            DateTime currentInstance = System.Now().addMinutes(7);
            //Construct the Cron String
            String crn = '00 '+ currentInstance.minute()+' '+ currentInstance.hour()+' '+currentInstance.day()+' '+currentInstance.Month()+' ? '+currentInstance.year();
            inActiveTVEvaluatorUpdateSchedule sch = new inActiveTVEvaluatorUpdateSchedule(uIds1);
            //schedule job for 5 mins from now
            if(!Test.isRunningTest())
                system.schedule('inActiveTVEvaluatorUpdateSchedule'+string.valueof(currentInstance)+':'+string.valueof(currentInstance.millisecond()),crn,sch);
        }
    }


    /**
Author: Nishant Prajapati
Company: Techmatrix
Description: Method to append 91 in user's mobile phone
Returns: void
History:
====================================================
1.0     01 Oct 2019  Nishant  Initial Version

**/
    public void ChecKMobileNumber(){
        for(user u: this.newUserList){

            if(u.Phone != null && u.MobilePhone == null){
                u.MobilePhone = u.Phone;
            }

            if((trigger.isInsert && (u.MobilePhone != null && u.MobilePhone.length()==10)) || (trigger.isUpdate && (u.MobilePhone != null && u.MobilePhone != this.oldUserMap.get(u.Id).MobilePhone &&
                                                                                                                    u.MobilePhone.length()==10)))
                u.MobilePhone = ConstantsUtility.COUNTRY_CODE+ u.MobilePhone;
        
            //Rahul Adding logic for Brands prepopulation of Department
            if(brandRoleMap.containsKey(u.UserRoleId)){
                u.Department = brandRoleMap.get(u.UserRoleId).Department__c;
            }
        
        
        
        }
    }


    /**
        Author: Nishant Prajapati
        Company: Techmatrix
        Description: Method to set partner user's password
        Returns: void
        History:
        Modification: Anas Yar Khan - 06th Of October 2020 - Added password paradigm for CTI Users 
        ====================================================
        1.0     03 Dec  Nishant  Initial Version

    **/
    public void setPasswordForPartnerUsers(){
        try{
            //Set to store the User Ids for which password needs to be reset
            set<Id> userIds = new set<Id>();
            set<Id> setCTIUsersId = new set<Id>();
            //number to track number of users being created or updated in this trigger transaction
            Integer i = 0;
            for(user u: this.newUserList){
                if(u.ContactId!=null && u.IsActive && (trigger.isInsert || (trigger.IsUpdate && !oldUserMap.get(u.Id).IsActive && u.IsActive))){
                    i++;
                    
                    if (i < 50){
                        //Add the users to the userIds list if the list size is less than 50
                        userIds.add(u.Id);
                    }else{
                        //ENque the job for the users and then reset the users.
                        userIds.add(u.Id);
                        //System.enqueueJob(new PasswordService(userIds));
                        scheduleSetPassword(userIds,false);//Boolean passed by Anas Yar Khan
                        i = 0;
                        userIds.clear();
                    }
                }
                //Added by Anas Yar Khan
                //Date: 06th Of Oct 2020
                //For setting password for CTI users
                else if((trigger.isInsert || 
                         (trigger.isUpdate && (this.oldUserMap.get(u.Id).Location_Prefix__c!=u.Location_Prefix__c || this.oldUserMap.get(u.Id).CTI_User_Id__c!=u.CTI_User_Id__c))) 
                        && u.Location_Prefix__c != NULL && u.CTI_User_Id__c != NULL ) {
                            i++;
                            if (i < 50){
                                //Add the users to the userIds list if the list size is less than 50
                                setCTIUsersId.add(u.Id);
                            }else{
                                //ENque the job for the users and then reset the users.
                                setCTIUsersId.add(u.Id);
                                //System.enqueueJob(new PasswordService(userIds));
                                scheduleSetPassword(userIds,true);
                                i = 0;
                                setCTIUsersId.clear();
                            }
                            
                        }
            }
            
            
            //schedule the job if any pending users are present.
            if(userIds.size() > 0){
                //System.enqueueJob(new PasswordService(userIds));
                scheduleSetPassword(userIds,false);   //Boolean passed by Anas Yar Khan
                i = 0;
                
            }
            
            //Added By Anas Yar Khan
            //schedule the job if any pending users are present.
            //Date: 06th Of Oct 2020
            //For setting password for CTI users
            if(setCTIUsersId.size() > 0){
                //System.enqueueJob(new PasswordService(userIds));
                scheduleSetPassword(setCTIUsersId,true);
                i = 0;
            }
        }catch(Exception e){ 
            ExceptionHandler.LogError_Future('UserTriggerHandler SetPassword', e.getStackTraceString()+e.getMessage(),'User', '', null);
        }
    }


    /**
Author: Subhojit Chakraborty
Company: Salesforce
Description: Method to add external users to oublic group
Returns: void
History:
====================================================
1.0     01 Ded 2019  Nishant  Initial Version

**/
    public void addUserToDealerMasterPublicGroup(){
        CustomerRecordVisibilityUtility.addUserToParentPublicGroup(newUserList);
    }

    
    /**
        Author: Rahul Raghunathan
        Company: Salesforce
        Description: Method to schedule the password service for every half an hour
        Returns: void
        History:
        Modification: Anas Yar Khan - 06th Of October 2020 - Added password paradigm for CTI Users 
        ====================================================
        1.0     28 Jan 2020  Rahul  Initial Version

    **/
    public void scheduleSetPassword(set<id> userIds,Boolean isCTIUsers){
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        
        DateTime currentInstance = System.Now().addMinutes(30);
        
        //Construct the Cron String
        String sch = '00 '+ currentInstance.minute()+' '+ currentInstance.hour()+' '+currentInstance.day()+' '+currentInstance.Month()+' ? '+currentInstance.year();
        
        //schedule job for 30 mins from now
        system.schedule('PasswordService'+string.valueof(currentInstance)+':'+string.valueof(currentInstance.millisecond()),sch,new PasswordService(userIds,isCTIUsers));
    }
    
    /**
Author: Rahul Sharma
Company: MSIL
Description: method to check if user active in DMS or not , specially for evaluator
Returns: void

**/
    public void checkForDMSActive(){
        boolean isInactiveBatch=UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','inactiveBatch');
        for(User ur : newUserList){

            if(isInactiveBatch==false){
                ur.DMS_Active__c = ur.IsActive;
            }

        }
    }


    /**
Author: Prashant Gahlaut
Company: Techmatrix Consulting
Description: Method to assign SM as SalesSPOC in DealerAccount
Returns: void
**/
    public void assignSalesSPOC(){
        //list to update the account
        list<Account> accList = new list<Account>();
        //set to store dealer Account Id
        set<string> dealerAccountIdSet = new set<string>();
        //store SM users Id
        map<string , list<string>> smsaleSpocMap = new map<string,list<string>>();
        //store GM users Id
        map<string , list<string>> gmsaleSpocMap = new map<string,list<string>>();
        //store other partner user Id
        map<string, list<string>> otherUserMap = new map<string,list<string>>();

        //Designation List
        list<String> smDesignation = (system.Label.SM_Designations).split(',');
        list<String> gmDesignation = (system.label.GM_Designations).split(',');
        //loop through list
        for(User usr : newUserList){
            if(((trigger.isInsert && usr.IsActive == true)||(trigger.isUpdate && (usr.IsActive == true && usr.Designation__c != oldUserMap.get(usr.Id).Designation__c || usr.IsActive != oldUserMap.get(usr.Id).IsActive)))
               && usr.IsPortalEnabled == true && usr.ContactId != null && usr.Designation__c != null && usr.Dealer_Account__c != null){
                   //store dealer account Id
                   dealerAccountIdSet.add(usr.Dealer_Account__c);
               }
        }
        // Size check
        if(dealerAccountIdSet.size()>0){
            //fetch all the present users related to dealer account Id
            for(User usr : [SELECT Id,designation__c,Dealer_Account__c,contactId,isActive from user
                            where IsPortalEnabled = true
                            and isActive = true
                            and Dealer_Account__c in : dealerAccountIdSet
                            and (contact.Account.Sales_SPOC_1__c = null
                            or contact.Account.Sales_SPOC_2__c = null
                            or contact.Account.Sales_SPOC_3__c = null
                            or contact.Account.Sales_SPOC_4__c = null
                            or contact.Account.Sales_SPOC_5__c = null)
                            ]){
                                //if SM
                                //if(usr.Designation__c == 'NSM'){
                                if(smDesignation.contains(usr.Designation__c)){
                                    if(smsaleSpocMap.containsKey(usr.Dealer_Account__c)){
                                        list<string> tempList = smsaleSpocMap.get(usr.Dealer_Account__c);
                                        tempList.add(usr.Id);
                                        smsaleSpocMap.put(usr.Dealer_Account__c ,tempList);
                                    }
                                    else
                                        smsaleSpocMap.put(usr.Dealer_Account__c , new list<string>{usr.Id});
                                }
                                //if GM
                                //if(usr.Designation__c == 'GM'){
                                if(gmDesignation.contains(usr.Designation__c)){
                                    if(gmsaleSpocMap.containsKey(usr.Dealer_Account__c)){
                                        list<string> tempList = gmsaleSpocMap.get(usr.Dealer_Account__c);
                                        tempList.add(usr.Id);
                                        gmsaleSpocMap.put(usr.Dealer_Account__c ,tempList);
                                    }
                                    else
                                        gmsaleSpocMap.put(usr.Dealer_Account__c , new list<string>{usr.Id});
                                }
                                //if not NSM and GM
                                //if(usr.Designation__c != 'NSM' && usr.Designation__c != 'GM')
                                if(!smDesignation.contains(usr.Designation__c) && !smDesignation.contains(usr.Designation__c))
                                    otherUserMap.put(usr.Dealer_Account__c , new list<string>());
                            }
            //if other users come then add this users to GM map with different dealer Account Id only
            if(otherUserMap.size()>0){
                for(string accIdKey : otherUserMap.keyset()){
                    if(!gmsaleSpocMap.containsKey(accIdKey))
                        gmsaleSpocMap.put(accIdKey,otherUserMap.get(accIdKey));
                }
            }
        }

        //if SM map
        if(smsaleSpocMap.size()>0 && gmsaleSpocMap.size()==0)
            accList = accountToUpdate(smsaleSpocMap);

        //if GM map
        if(gmsaleSpocMap.size()>0 && smsaleSpocMap.size()==0)
            accList = accountToUpdate(gmsaleSpocMap);

        //if SM and GM Map
        if(gmsaleSpocMap.size()>0 && smsaleSpocMap.size()>0){
            for(string accIdKey : gmsaleSpocMap.keyset()){
                if(!smsaleSpocMap.containskey(accIdKey))
                    smsaleSpocMap.put(accIdKey,gmsaleSpocMap.get(accIdKey));
            }
            accList = accountToUpdate(smsaleSpocMap);
        }

        //list size check
        if(accList.size()>0 && !System.isFuture() && !System.isBatch()){
            String accToUpdateJasonlist = JSON.serialize(accList);
            salesSPOCUpdateUsingFuture(accToUpdateJasonlist);
        }
    }

    //method to return the Account list that needs to be updated with respective salesSPOC users
    public list<Account> accountToUpdate(map<string,list<string>> userMap){
        list<Account> acclist = new list<Account>();
        //loop through Keyset
        for(string keys : userMap.keySet()){
            //Initialize Account object with all sales SPOC fields null
            Account acc = new Account(Id = keys,Sales_SPOC_1__c = null,Sales_SPOC_2__c = null,Sales_SPOC_3__c = null,Sales_SPOC_4__c = null,Sales_SPOC_5__c = null);
            //if list size is greater than 0 for respective accId
            if(userMap.get(keys).size()>0){
                for(integer i=1;i<=userMap.get(keys).size();i++){
                    if(i<=5)
                        acc.put('Sales_SPOC_'+i+'__c',userMap.get(keys)[i-1]);
                }
            }
            acclist.add(acc);
        }
        return acclist;
    }

    //Future method to update the Sales SPOC fields
    @future
    public static void salesSPOCUpdateUsingFuture(String accJsonList){
        List<Account> futureAccountList = (List<Account>)JSON.deserialize(accJsonList, List<Account>.class);
        if(futureAccountList != null && futureAccountList.size()>0)
            update futureAccountList;
    }

     /**
Author: Rahul Sharma
Company: MSIL
Description: Method to remove SM as SalesSPOC in DealerAccount if inactive
Returns: void
**/
    public void removeInActiveSalesSpoc()
    {
        //set to store dealer Account Id
        set<string> dealerAccountIdSet = new set<string>();
        Set<String> userId = new Set<String>();
        map<String,string> accWithSalesSpoc1 = new map<String,string>();
        map<String,string> accWithSalesSpoc2 = new map<String,string>();
        map<String,string> accWithSalesSpoc3 = new map<String,string>();
        map<String,string> accWithSalesSpoc4 = new map<String,string>();
        map<String,string> accWithSalesSpoc5 = new map<String,string>();
        map<String,List<string>> accWithAvailableNSMSalesSpoc = new map<String,List<string>>();
        map<String,List<string>> accWithAvailableGMSalesSpoc = new map<String,List<string>>();
        map<String,Integer> accWithNSMCount = new map<String,Integer>();
        Integer countNSM = 0;
        set<Id> salesSpoc = new set<Id>();
        List<Account> lstUpdate = new List<Account>();
        //Designation List
        list<String> smDesignation = (system.Label.SM_Designations).split(',');
        list<String> gmDesignation = (system.label.GM_Designations).split(',');

        for(User usr : newUserList){
            if(usr.IsActive == false && usr.Designation__c != null && usr.IsPortalEnabled == true && (smDesignation.contains(usr.Designation__c) || gmDesignation.contains(usr.Designation__c))  && usr.ContactId != null && usr.Dealer_Account__c != null){
                   //store dealer account Id
                   userId.add(usr.Id);
                   dealerAccountIdSet.add(usr.Dealer_Account__c);
               }
        }
        if(!userId.IsEmpty())
        {
            List<Account> accSalesSpoc = [Select Id,Sales_SPOC_1__c,Sales_SPOC_1__r.Designation__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c,Sales_SPOC_2__r.Designation__c,Sales_SPOC_3__r.Designation__c,Sales_SPOC_4__r.Designation__c,Sales_SPOC_5__r.Designation__c from Account where (Sales_SPOC_1__c in: userId or Sales_SPOC_2__c in: userId or Sales_SPOC_3__c in: userId or Sales_SPOC_4__c in: userId or Sales_SPOC_5__c in: userId) and id in: dealerAccountIdSet];

            List<Account> salesSpocLst = [Select Id,Sales_SPOC_1__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c from Account where id in: dealerAccountIdSet];

            for(Account acc : salesSpocLst)
            {
                if(acc.Sales_SPOC_1__c != null)
                    salesSpoc.add(acc.Sales_SPOC_1__c);
                if(acc.Sales_SPOC_2__c != null)
                    salesSpoc.add(acc.Sales_SPOC_2__c);
                if(acc.Sales_SPOC_3__c != null)
                    salesSpoc.add(acc.Sales_SPOC_3__c);
                if(acc.Sales_SPOC_4__c != null)
                    salesSpoc.add(acc.Sales_SPOC_4__c);
                if(acc.Sales_SPOC_5__c != null)
                    salesSpoc.add(acc.Sales_SPOC_5__c);
            }

            List<User> nsmSalesSpoc = [Select Id,Designation__c,Dealer_Account__c from user where Designation__c in: smDesignation and Dealer_Account__c in : dealerAccountIdSet and IsActive =: true and id not in : salesSpoc];

            List<User> gmSalesSpoc = [Select Id,Designation__c,Dealer_Account__c from user where Designation__c in: gmDesignation and Dealer_Account__c in : dealerAccountIdSet and IsActive =: true and id not in : salesSpoc];

            if(!nsmSalesSpoc.IsEmpty())
            {
                for(User usr : nsmSalesSpoc)
                {
                    if(accWithAvailableNSMSalesSpoc.containsKey(usr.Dealer_Account__c)){
                        list<string> tempList = accWithAvailableNSMSalesSpoc.get(usr.Dealer_Account__c);
                        tempList.add(usr.Id);
                        accWithAvailableNSMSalesSpoc.put(usr.Dealer_Account__c ,tempList);
                    }
                    else
                        accWithAvailableNSMSalesSpoc.put(usr.Dealer_Account__c , new list<string>{usr.Id});
                }
            }

            if(!gmSalesSpoc.IsEmpty())
            {
                for(User usr : gmSalesSpoc)
                {
                    if(accWithAvailableGMSalesSpoc.containsKey(usr.Dealer_Account__c)){
                        list<string> tempList = accWithAvailableGMSalesSpoc.get(usr.Dealer_Account__c);
                        tempList.add(usr.Id);
                        accWithAvailableGMSalesSpoc.put(usr.Dealer_Account__c ,tempList);
                    }
                    else
                        accWithAvailableGMSalesSpoc.put(usr.Dealer_Account__c , new list<string>{usr.Id});
                }
            }

            if(!accSalesSpoc.IsEmpty())
            {
                for(Account acc : accSalesSpoc)
                {
                    system.debug(' 530 && '+userId.contains(acc.Sales_SPOC_1__c)+userId.contains(acc.Sales_SPOC_2__c)+userId.contains(acc.Sales_SPOC_3__c)+userId.contains(acc.Sales_SPOC_4__c)+userId.contains(acc.Sales_SPOC_5__c));
                    String Id = (String.ValueOf(acc.Id)).substring(0, 15);
                    if(userId.contains(acc.Sales_SPOC_1__c))
                        accWithSalesSpoc1.put(Id,acc.Sales_SPOC_1__c);
                    if(userId.contains(acc.Sales_SPOC_2__c))
                        accWithSalesSpoc2.put(Id,acc.Sales_SPOC_2__c);
                    if(userId.contains(acc.Sales_SPOC_3__c))
                        accWithSalesSpoc3.put(Id,acc.Sales_SPOC_3__c);
                    if(userId.contains(acc.Sales_SPOC_4__c))
                        accWithSalesSpoc4.put(Id,acc.Sales_SPOC_4__c);
                    if(userId.contains(acc.Sales_SPOC_5__c))
                        accWithSalesSpoc5.put(Id,acc.Sales_SPOC_5__c);

                    if(acc.Sales_SPOC_1__r.Designation__c != null && smDesignation.contains(acc.Sales_SPOC_1__r.Designation__c))
                        countNSM +=1;
                    if(acc.Sales_SPOC_2__r.Designation__c != null && smDesignation.contains(acc.Sales_SPOC_2__r.Designation__c))
                         countNSM +=1;
                    if(acc.Sales_SPOC_3__r.Designation__c != null && smDesignation.contains(acc.Sales_SPOC_3__r.Designation__c))
                         countNSM +=1;
                    if(acc.Sales_SPOC_4__r.Designation__c != null && smDesignation.contains(acc.Sales_SPOC_4__r.Designation__c))
                         countNSM +=1;
                    if(acc.Sales_SPOC_5__r.Designation__c != null && smDesignation.contains(acc.Sales_SPOC_5__r.Designation__c))
                         countNSM +=1;

                    accWithNSMCount.put(Id,countNSM);
                }
            }
        }

        for(String str : dealerAccountIdSet)
        {
            Account acc = new Account();
            acc.Id = str;
            Integer count;
            if(accWithNSMCount.containsKey(str))
                count = accWithNSMCount.get(str);

            if(count > 1)
            {
                if(accWithSalesSpoc1.containsKey(str))
                {
                    if(accWithAvailableNSMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableNSMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_1__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableNSMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_1__c = null;
                    }
                }
                if(accWithSalesSpoc2.containsKey(str))
                {
                    if(accWithAvailableNSMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableNSMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_2__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableNSMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_2__c = null;
                    }
                }
                if(accWithSalesSpoc3.containsKey(str))
                {
                    if(accWithAvailableNSMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableNSMSalesSpoc.get(str);
                        system.debug(' 737 lstUpdate '+salesSpocLst );
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_3__c = salesSpocLst[0];
                            salesSpocLst.remove(0);
                            accWithAvailableNSMSalesSpoc.put(str ,salesSpocLst);
                        }
                    }
                    else
                    {
                    system.debug(' 737 lstUpdate ');
                        acc.Sales_SPOC_3__c = null;
                    }
                }
                if(accWithSalesSpoc4.containsKey(str))
                {
                    if(accWithAvailableNSMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableNSMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_4__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableNSMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_4__c = null;
                    }
                }
                if(accWithSalesSpoc5.containsKey(str))
                {
                    if(accWithAvailableNSMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableNSMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_5__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableNSMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_5__c = null;
                    }
                }
            }
            else
            {
                if(accWithSalesSpoc1.containsKey(str))
                {
                    if(accWithAvailableGMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableGMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_1__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableGMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_1__c = null;
                    }
                }
                if(accWithSalesSpoc2.containsKey(str))
                {
                    if(accWithAvailableGMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableGMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_2__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableGMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_2__c = null;
                    }
                }
                if(accWithSalesSpoc3.containsKey(str))
                {
                    if(accWithAvailableGMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableGMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_3__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableGMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_3__c = null;
                    }
                }
                if(accWithSalesSpoc4.containsKey(str))
                {
                    if(accWithAvailableGMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableGMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_4__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableGMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_4__c = null;
                    }
                }
                if(accWithSalesSpoc5.containsKey(str))
                {
                    if(accWithAvailableGMSalesSpoc.containsKey(str))
                    {
                        list<string> salesSpocLst = accWithAvailableGMSalesSpoc.get(str);
                        if(salesSpocLst.size() > 0)
                        {
                            acc.Sales_SPOC_5__c = salesSpocLst[0];

                        }
                        salesSpocLst.remove(0);
                        accWithAvailableGMSalesSpoc.put(str ,salesSpocLst);
                    }
                    else
                    {
                        acc.Sales_SPOC_5__c = null;
                    }
                }

            }

            lstUpdate.add(acc);
        }
        system.debug(' 737 lstUpdate '+lstUpdate);
        if(!lstUpdate.IsEmpty() && !System.isFuture() && !System.isBatch())
        {
                String accToUpdateJasonlist = JSON.serialize(lstUpdate);
            salesSPOCUpdateUsingFuture(accToUpdateJasonlist);
        }
    }
  /**
Author: Rohit Gupta
Company: Techmatrix
Description: Method to add partnerusers to respective chatter Group
Returns: void
**/

    public void addUserToChatterGroup(){
        Set<String> contactIdSet = new Set<String>();
        Set<String> ceoContactIdSet = new Set<String>();
        Set<String> salesUsersIdSet = new Set<String>();
        for(Profile pf: [Select Id From Profile Where Name = 'Dealer Hostess' or Name = 'Dealer Sales Executive'
                         OR Name = 'Dealer Team Leads/Managers' OR Name = 'Dealer GM' OR Name = 'Dealer CEO/Owner'
                         OR Name = 'Dealer Accessories User' OR Name = 'Dealer Finance Manager']){
                             salesUsersIdSet.add(pf.Id);
                         }
        Id ceoProfileId = [SELECT Id from Profile where name = 'Dealer CEO/Owner' limit 1].Id;
        //Id dealerEvaluatorProfileId = [SELECT Id from Profile where name = 'Dealer TV Evaluator' limit 1].Id;

        for(User user :newUserList){
            if(user.contactId != null && salesUsersIdSet.contains(user.ProfileId)){
                contactIdSet.add(user.ContactId);
                if(user.ProfileId == ceoProfileId){
                    ceoContactIdSet.add(user.ContactId);
                }
            }
        }
        //calling future method to insert chatter group and members
        if(contactIdSet.size() > 0){
            addUserToChatterGroupFuture(contactIdSet, ceoContactIdSet, ceoProfileId);
        }

    }
    @future
    public static void addUserToChatterGroupFuture(Set<String> contactIdSet, Set<String> ceoContactIdSet, Id ceoProfileId){
        try{
            Set<String> cGroupSet = new Set<String>();

            List<Contact> contactList = new List<Contact>();
            List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
            List<CollaborationGroupMember> cGroupMemberList = new List<CollaborationGroupMember>();

            Map<String, String> cGroupMap = new Map<String, String>();
            Map<String, String> cGroupMapForCEO = new Map<String, String>();
            Map<String, String> map1 = new Map<String, String>();
            Map<String, String> map2 = new Map<String, String>();

            List<User> newUserList = [Select id, profileId, contactid from User where contactid in: contactIdSet];

            if(contactIdSet.size() > 0){
                contactList = [SELECT Id, Account.Parent_Group__c, Account.Dealer_code__c, Account.FOR_Code__r.For_Code__c,
                               Account.Region_code__c
                               FROM Contact WHERE Id IN :contactIdSet];
                for(Contact contact : contactList){
                    if(contact.Account.Dealer_code__c != null && contact.Account.FOR_Code__r.For_Code__c != null && contact.Account.Parent_Group__c != null){
                        cGroupMap.put(contact.Id, contact.Account.Dealer_code__c +'_'+contact.Account.FOR_Code__r.For_Code__c + '_'+contact.Account.Parent_Group__c+'_'+'sales');
                        cGroupSet.add(contact.Account.Dealer_code__c +'_'+contact.Account.FOR_Code__r.For_Code__c + '_'+contact.Account.Parent_Group__c+'_'+'sales');
                    }
                }
                //New for CEOs to be added to 'All C1 Dealers Nexa/Arena' Group
                if(ceoContactIdSet.size() > 0){
                    for(Contact contact: [SELECT Account.Region_Code__c, Account.Channel__c FROM Contact WHERE Id IN: ceoContactIdSet]){
                        if(contact.Account.Channel__c != null && contact.Account.Region_code__c != null){
                            String val;
                            if(contact.Account.Channel__c == 'NRM'){
                                val = 'All '+ contact.Account.Region_code__c + ' Dealers Arena';
                            }else if(contact.Account.Channel__c == 'EXC'){
                                val = 'All '+ contact.Account.Region_code__c + ' Dealers Nexa';
                            }
                            cGroupSet.add(val);
                            cGroupMapForCEO.put(contact.Id, val);
                        }
                    }
                }

                //
                for(CollaborationGroup cGroup : [SELECT Id, Name FROM CollaborationGroup  WHERE Name IN :cGroupSet] ){
                    map1.put(cGroup.Name, cGroup.Id);
                }

                Network nk = [select id from Network where Name like 'Dealer%' limit 1];

                for(String str : cGroupSet){
                    if(!map1.containsKey(str)){
                        CollaborationGroup cGroup = new CollaborationGroup();
                        cGroup.NetworkId = nk.Id;
                        cGroup.Name = str;
                        cGroup.CollaborationType = 'Unlisted';
                        cGroupList.add(cGroup);
                    }
                }
                if(cGroupList.size() > 0){
                    insert cGroupList;
                }
                for(CollaborationGroup cGroup : [SELECT Id, Name FROM CollaborationGroup  WHERE Name IN :cGroupSet] ){
                    map2.put(cGroup.Name, cGroup.Id);
                }
                for(User user: newUserList){
                    if(cGroupMap.containsKey(user.ContactId) && map2.containsKey(cGroupMap.get(user.ContactId))){
                        CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                        cGroupMember.MemberId = user.Id;
                        cGroupMember.CollaborationGroupId = map2.get(cGroupMap.get(user.ContactId));
                        cGroupMemberList.add(cGroupMember);
                    }
                    if(user.ProfileId == ceoProfileId){
                        if(cGroupMapForCEO.containsKey(user.ContactId) && map2.containsKey(cGroupMapForCEO.get(user.ContactId))){
                            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                            cGroupMember.MemberId = user.Id;
                            cGroupMember.CollaborationGroupId = map2.get(cGroupMapForCEO.get(user.ContactId));
                            cGroupMemberList.add(cGroupMember);
                        }
                    }
                }
                if(cGroupMemberList.size() > 0){
                    insert cGroupMemberList;
                }
            }
        }catch(Exception e){
            ExceptionHandler.LogError('UserTriggerHandler addUserToChatterGroupFuture', e.getStackTraceString()+e.getMessage(),'User', '', null);
        }
    }

	/**
    Author: Rahul Sharma
    Company: MSIL
    Description: Method to capture date/time at user becoming active again
    Returns: void
    History:
    ====================================================
    1.0     06 Aug 2020  Rahul Sharma  Initial Version

    **/
    public void captureDateTimeUserBecomingActiveAgain(){
        for(user u: this.newUserList){
            if( trigger.IsUpdate && !oldUserMap.get(u.Id).IsActive && u.IsActive){
                u.InActive_To_Active_Date__c = system.now();
            }
        }
    }

     /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Method to capture date/time at user becoming active again
    Returns: void
    History:
    ====================================================
    1.0     06 Aug 2020  Rahul Sharma  Initial Version

    **/
    public void checkDealerUpdatedThePassword(){
        set<Id> uIds = new set<Id>();
        for(user u: this.newUserList){
            If(trigger.IsUpdate)
             uIds.add(u.Id);
        }
        List<User> usrLst = new List<User>();
        if(uIds.size()>0)
		{
			List<User> usrLst1 = [Select id,Partner_User_Default_Pwd_Generation_Time__c,LastPasswordChangeDate from user where id in: uIds and (LastPasswordChangeDate != null) and Partner_User_Default_Pwd_Generation_Time__c != null];
			for(User u : usrLst1 )
			{
				User usr = new User(Id = u.Id);
				if(u.Partner_User_Default_Pwd_Generation_Time__c < u.LastPasswordChangeDate)
					  usr.Password_Reset_by_Dealer__c = true;
				usrLst.add(usr);
			}

			If(!usrLst.IsEmpty())
			{
				TriggerHandler.bypass('UserTriggerHandler');
				update usrLst;
				TriggerHandler.clearBypass('UserTriggerHandler');
			}
		}
    }
	
		
		   /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Method to check if inactive user with same username exists, if so update the inactive user's username and nickname
    Returns: void
    
    **/
     public void checkForExistingUserName(){
        boolean isInactiveBatch=UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','inactiveBatch'); 
        set<string> userNames = new set<string>();
        List<User> lstUserUpdate = new List<User>();
        for(User ur : newUserList){
            userNames.add(ur.Username);
        }
        List<User> lstUser = [Select Id,Username,CommunityNickname,Dealer_Employee_Code__c from User where IsActive = false and contactId != null and Username in: userNames];
        if(lstUser.size() > 0)
        {
            for(User usr : lstUser)
            {
                if(usr.Dealer_Employee_Code__c != null)
                {
                    User u = new User(id=usr.Id);
                    u.Username = usr.Username +'.'+usr.Dealer_Employee_Code__c;
                    u.CommunityNickname = usr.CommunityNickname +'.'+usr.Dealer_Employee_Code__c;
                    lstUserUpdate.add(u);
                }
            }
            if(lstUserUpdate.size() > 0)
            {
                TriggerHandler.bypass('UserTriggerHandler');
                update lstUserUpdate;
                TriggerHandler.clearBypass('UserTriggerHandler');
            }
        }
    }

    /**
Author: Anas Yar Khan
Company: Techmatrix Consulting
Description: This method is used to update Phone and Designation from User to related contact in case partner user is inserted
Returns: void
**/    
    public void updatePhoneAndDesignationOnContact() {
        try {
            //Map to store contact Id as a key and corresponding partner user as a value
            Map<Id,User> mapContactIdToUser = new Map<Id,User>();          
            //Fetching users that are inserted or updated and isPartnerUser
            for(User usr : [SELECT Id,ContactId,Phone,Designation__c 
                            FROM User 
                            WHERE Id IN :newUserList 
                            AND IsPortalEnabled = true]) {
                                if(trigger.isInsert && usr.ContactId != NULL) {
                                    mapContactIdToUser.put(usr.ContactId,usr);    
                                }
                                else if(trigger.isUpdate && usr.ContactId != NULL && (usr.Phone != oldUserMap.get(usr.Id).Phone || usr.Designation__c != oldUserMap.get(usr.Id).Designation__c)) {
                                    mapContactIdToUser.put(usr.ContactId,usr);    
                                }
                            }
            
            //Calling updateContact to update the Contact Records
            if(mapContactIdToUser.keySet().size() > 0) {
                updateContact(mapContactIdToUser);    
            }    
        }
        catch(Exception e) {
            ExceptionHandler.LogError('UserTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'Update Contact if the partner user is updated or inserted', '', null);
        }
    }
    
    /**
Author: Anas Yar Khan
Company: Techmatrix Consulting
Description: This method is used to update Phone and Designation on Contact
Returns: void
**/  
    
    public void updateContact(Map<Id,User> mapContactIdToUser) {
        try {
        DateTime currentInstance = System.Now().addMinutes(10);
        //Construct the Cron String
        String sch = '00 '+ currentInstance.minute()+' '+ currentInstance.hour()+' '+currentInstance.day()+' '+currentInstance.Month()+' ? '+currentInstance.year();
        //schedule job for 30 mins from now
        system.schedule('ContactUpdate'+string.valueof(currentInstance)+':'+string.valueof(currentInstance.millisecond()),sch,new ContactUpdate(mapContactIdToUser));
        }
        catch(Exception e) {
            ExceptionHandler.LogError('UserTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'Update Phone and Designation of Contact schedule', '', null);    
        }
    }
     /**
Author: Satish Kumar
Company: MSIL
Description: This method is used to update Phone and Designation on Contact
Returns: void
**/  
 public void  serviceUserInsertToGroup(){
         Map<String, String> newprofileRoleMap= new Map<String, String>();
         Map<Id, String> oldprofileRoleMap= new Map<Id, String>();       
         Set<String> groupSet= new Set<String>();
          Set<ID> setGroupId= new Set<Id>();
         Set<ID> setUserOrGroupId= new Set<Id>();

         for(user urnew:newUserList){
            newprofileRoleMap.put(urnew.id,urnew.User_Role_Text__c);
            System.debug('772 newprofileRoleMap'+newprofileRoleMap);
         }

         
         //retreive the groups corresponding to id
         Map<string, string> newgroupMap= new Map<string, string>();
         for(Group newgr : [SELECT Id, Name, DeveloperName from Group WHERE DeveloperName IN: newprofileRoleMap.values()]){
             newgroupMap.put(newgr.DeveloperName, newgr.Id);
             System.debug('780 newprofileRoleMap'+newgroupMap);
         } 

           List<GroupMember> aftergrpMemberCreate= new List<GroupMember>();
            List<GroupMember> aftergrpMemberDelete= new List<GroupMember>();
                  for(User urnew : newUserList){
                     //List<User> usrold=oldUsermap.values();
                      if(trigger.isUpdate && (newprofileRoleMap.get(urnew.id)!=oldUsermap.get(urnew.id).User_Role_Text_InternalServ__c)){
                               System.debug('789'+oldUsermap.get(urnew.id));
                                  oldprofileRoleMap.put(urnew.id,oldUsermap.get(urnew.id).User_Role_Text_InternalServ__c);
                                   System.debug('788 newprofileRoleMap'+oldprofileRoleMap); 
                                                                                                           
                               }
                           if(trigger.isinsert || trigger.isUpdate){
                              aftergrpMemberCreate.addAll(addGroupMemberToGroup(urnew,newgroupMap));
                            }
                  }

                     if(oldprofileRoleMap!=null ){
                        aftergrpMemberDelete=deleteGroupMemberFromGroup(oldprofileRoleMap);
                         if(aftergrpMemberDelete.size() > 0){
                                      delete aftergrpMemberDelete;                 
                                                     }
                     }
                                 
                        if(aftergrpMemberCreate.size() > 0){
                                     insert aftergrpMemberCreate;
                         }

        }
         
    public List<GroupMember> addGroupMemberToGroup(User user, Map<string, string> newgroupMap ){
           List<GroupMember> grpMemberCreate= new List<GroupMember>();
                             if(newgroupMap.containsKey(user.User_Role_Text_InternalServ__c)){
                                 GroupMember gm = new GroupMember();
                                 gm.GroupId = newgroupMap.get(user.User_Role_Text_InternalServ__c);
                                 gm.UserOrGroupId = user.Id;
                                 grpMemberCreate.add(gm);
                             }
                             
                         System.debug('819 newprofileRoleMap'+grpMemberCreate);
                        //System.debug('820 group member'+gm); 
                 return  grpMemberCreate;  
       
    }

    public list<GroupMember> deleteGroupMemberFromGroup( Map<Id, string> oldUsermap){
             List<GroupMember> grpMemberDelete= [Select Id from GroupMember where UserOrGroupId  IN: oldUsermap.keySet() AND Group.DeveloperName  IN: oldUsermap.values() ];
                      System.debug('844 deleted'+grpMemberDelete); 
                      return grpMemberDelete;
     }

}