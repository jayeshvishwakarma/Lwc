/**
* @File Name          : OpportunityTriggerStrategyHelper.cls
* @Description        : Trigger handler class for Opportuntiy (Enquiry)
* @Author             : Anuj Kumar
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 09-06-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    11/06/2020, 1:14:54 PM     Anuj Kumar                Initial Version

**/

public without sharing class OpportunityTriggerStrategyHelper{


    private Map<Id, Opportunity> newOppMap; //Used to store the map of new Opportunities
    private list<Opportunity> newOppList; // Used to store the list of new Opportunities
    private Map<Id, Opportunity> oldOppMap; // Used to store Map of old Opportunities

    public static Id vehicleSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE).getRecordTypeId();
    public static Id accessoriesSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_SALES_CONST).getRecordTypeId();
    public static Id loyaltySalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_LOYALTY_RECORDTYPE).getRecordTypeId();
    public static String preBookingTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.PRE_BOOKING_FOLLOWUP).getRecordTypeId();
    public static String generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE).getRecordTypeId();
    public static String LoyalityEnrolmentFollowUpTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.Loyality_Enrolment_FollowUp_RECORDTYPE).getRecordTypeId();
    public static String LoyalityEnrolmentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.Opportunity_Loyalty_Enrolment_RECORDTYPE).getRecordTypeId();
    public static String customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.CUSTOMER_RECORDTYPE).getRecordTypeId();
    public static String msdsCourseRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(ConstantsUtility.MSDS_Courses).getRecordTypeId();

    private static String MuleUserRecordId;
    private static List<User> currentUserList = new List<User>();

    private static OpportunityTriggerStrategyHelper instance = null;

    private OpportunityTriggerHelper oppHelper;
    //Enquiry Escalation Service Class
    private EnquiryEscalationService escSrvc;

    public List<GlobalSwitchOn__c> checkAccountPermission;

    private OpportunityTriggerStrategyHelper(){

        checkAccountPermission = GlobalSwitchOn__c.getall().values();

        for(User usr : [SELECT Id, Name, Profile.Name, channel__c FROM User WHERE (Id =: UserInfo.getUserId() OR Name =: ConstantsUtility.DMS_USER )]){
            if(usr.Name == ConstantsUtility.DMS_USER){
                MuleUserRecordId = usr.Id;
            }
            if(usr.Id == UserInfo.getUserId()){
                currentUserList.add(usr);
            }
        }

        //Instantiate service class
        escSrvc = new EnquiryEscalationService();

        //Instantiate Helper Class
        oppHelper = new OpportunityTriggerHelper();
    }

    public static OpportunityTriggerStrategyHelper getInstance(List<Opportunity> newOppList , Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){

        if(instance == null) instance = new OpportunityTriggerStrategyHelper();
        instance.newOppList = newOppList;
        instance.newOppMap = newOppMap;
        instance.oldOppMap = oldOppMap;
        return instance;
    }
    /**
        Author: Nitish Bansal
        Company: Salesforce
        Description: Method to update the Opportunity Recordtype if not sent by DMS
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     05 Jun 2020  Nitish Bansal  Initial Version
    **/
    public void setStandardPriceBook() {
        system.debug('setOpportunityRecordType******* OpportunityTriggerHandler_Strategy');

        String pricebook2Id = '';
        StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance();
        if (lsPB != null) {
            pricebook2Id = lsPB.PriceBookId__c;
        }
        for (Opportunity opp: this.newOppList) {
            if (pricebook2Id != '')
                opp.Pricebook2Id = pricebook2Id;
        }
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to update the Opportunity close date to 3 months from the day Enquiry was created
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     29 Jul 2019  Prabhat Sharma  Initial Version
  **/
    public void populateCloseDate(String closingMonth) {

        //Loop through all new Opportunities
        for (Opportunity opp : this.newOppList) {

            //Updating Close Date from closingMonth months from now
            //Nitish modified to pass param from respective strategyimpl class
            opp.CloseDate = system.today().addMonths(Integer.valueOf(closingMonth));

            //Pre-Populating Address Type 1 and Address Type 2 Field
            opp.Address_Type_1__c = ConstantsUtility.RESIDENCE;
            opp.Address_Type_2__c = ConstantsUtility.OFFICE;
            opp.Test_Drive_Given__c = 'N';
            opp.Mode_Of_Communication__c = 'M';
        }
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to assign Ownership of Enquiry(Opportunity) to Sales SPOC(s) when Enquiry(Opportunity) is of Vehicle Sales Record Type and Enquiry(Opportunity) owner is Integration user.
        We will fetch Sales SPOC(s) from the Dealership field on Enquiry(Opportunity).
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     16 Jul 2019  Prabhat Sharma  Initial Version
  **/
    public void assignEnquirytoSalesSPOC() {
        System.debug('coming in this function');

        //Set to add Dealership from Enquiry(Opportunity).
        Set<Id> dealerAccountIds = new Set<Id>();

        // Map to add Account Id and Sales SPOC(s) User Ids.
        Map<Id, set<String>> accountSalesSpocUserIdsMap = new Map<Id, set<String>>();

        //Dealer Channel Account Map
        Map<Id, Account> accountChannelMap = new Map<Id, Account>();
        //This to randomly assign the SPOCs for Opportunities
        Integer counter = 0;

        //get profile Ids of ATM CallCenter Users
        String atmProfileIds = Label.ATM_Profiles;
        boolean isATMCreated = atmProfileIds.contains(UserInfo.getProfileId());

        //Loop through all new Opportunities
        for (Opportunity opp : this.newOppList) {
            if ((UserInfo.getUserId() == label.Integration_User || isATMCreated) && opp.Dealership__c != null && opp.DMS_Enq_Mode__c != 'Nav Portal' && opp.DMS_Enq_Mode__c != 'NAV') //Removed vehile sales record type Id condition for Accessories Enquiries
                dealerAccountIds.add(opp.Dealership__c);
        }
        // Set to add Sales SPOC(s) User Ids.
        set<String> tempSpocIds;

        //Query Sales SPOCs on Dealer(Account)
        if (dealerAccountIds.size() > 0) {
            for (Account acc : [
                SELECT Id,Sales_SPOC_1__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c,Channel__c
                FROM Account
                WHERE Id IN:dealerAccountIds
            ]) {

                //Adding channel as value and Dealership ID as key
                accountChannelMap.put(acc.Id, acc);

                tempSpocIds = new Set<String>();
                if (acc.Sales_SPOC_1__c != null)
                    tempSpocIds.add(acc.Sales_SPOC_1__c);
                if (acc.Sales_SPOC_2__c != null)
                    tempSpocIds.add(acc.Sales_SPOC_2__c);
                if (acc.Sales_SPOC_3__c != null)
                    tempSpocIds.add(acc.Sales_SPOC_3__c);
                if (acc.Sales_SPOC_4__c != null)
                    tempSpocIds.add(acc.Sales_SPOC_4__c);
                if (acc.Sales_SPOC_5__c != null)
                    tempSpocIds.add(acc.Sales_SPOC_5__c);

                //Fill the Map with Dealer(Account) and Sales SPOC(s) User Ids.
                accountSalesSpocUserIdsMap.put(acc.Id, tempSpocIds);
            }

            map<String, String> channelMap = new map<String, String>(ConstantsUtility.channelModelMap);
            List<Opportunity> tempOpty = new list<Opportunity>();
            //Assign Enquiry(Opportunity) Owner from Integration user to Sales SPOC(s)
            for (Opportunity opty : this.newOppList) {
                //ignoring the owner update which orginally consist of owner id other than  DMS Admin. ---@Satish
                if(isATMCreated || (UserInfo.getUserId() == label.Integration_User && opty.OwnerId == label.Integration_User)){
                if (accountSalesSpocUserIdsMap.containsKey(opty.Dealership__c) && accountSalesSpocUserIdsMap.get(opty.Dealership__c).size() > 0) {

                    //assign a random dealer as an enquiry owner
                    List<String> spocUserList = new List<String>(accountSalesSpocUserIdsMap.get(opty.Dealership__c));

                    //Added check for size because Random Utility was failing to size =1
                    if (spocUserList.size() > 1) {
                        opty.OwnerId = RandomUtility.findRandomStringFromList(spocUserList);
                    } else if (spocUserList.size() == 1) {
                        opty.OwnerId = spocUserList[0];
                    }

                    tempOpty.add(opty);
                    }
                }
                //Default LOB and Dealership Channel
                if (accountChannelMap.containsKey(opty.Dealership__c) && accountChannelMap.get(opty.Dealership__c).Channel__c != null) {
                    if (channelMap.containsKey(accountChannelMap.get(opty.Dealership__c).Channel__c)) {
                        opty.line_of_business__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                        opty.Temporary_LOB_Admin_use__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                        opty.dealership_channel__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                    }
                }
            }
            //Assign the list to a static variable for trigger after event to get the Enquiry Ids and create MC records
            if (tempOpty.size() > 0) {
                OpportunityTriggerHelper.spocOptyList = tempOpty;
            }
        }
        system.debug('== assignEnquirytoSalesSPOC ');
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to add Primary TSM and other TSMs based on
        LOB to the Opportunity Team Member once an Opportunity is created or
        the Dealership is updated.
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0    17 Sept 2019   Prabhat Sharma  Initial Version
        1.1    30 June 2020   Anuj Kumar      Second Version - Call from Async class
  **/
    public void addOpportunityTeamMembers(Boolean isInsert, Boolean isUpdate) {
        try {
            //List to insert the OpportunityTeamMember records
            list<OpportunityTeamMember> oppTeamMemberList = new list<OpportunityTeamMember>();
            //List to insert the OpportunityShare records
            list<OpportunityShare> oppSharesToInsert = new list<OpportunityShare>();
            //List to delete the previous OpportunityTeamMember records for related Enquiry id
            list<OpportunityTeamMember> oppTeamMemberDeleteList;

            //Set to contains the Opportunity Dealership__c field
            set<Id> dealershipIdSet = new set<Id>();
            map<Id, set<Id>> oppTsmUsersMap = new map<Id, set<Id>>();

            //Set to delete previous OpportunityTeamMember records for related Enquiry id
            set<Id> oppIdSet = new set<Id>();

            //Accessories Record type Id
            Id acessoriesSalesRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_SALES_CONST).getRecordTypeId();

            system.debug('== newOppList '+this.newOppList);

            for (opportunity opp : this.newOppList) {
                //Check if dealership is not blank or Dealership has changed
                if ((isInsert && opp.Dealership__c != null) || (isUpdate && ((opp.Dealership__c != this.oldOppMap.get(opp.id).Dealership__c) ||
                                                                                             (opp.ISL_Rural__c != this.oldOppMap.get(opp.id).ISL_Rural__c) ||
                                                                                             (opp.Accessories_DSE1__c != this.oldOppMap.get(opp.Id).Accessories_DSE1__c) ||
                                                                                             (opp.OwnerId != this.oldOppMap.get(opp.Id).OwnerId)))) {
                                                                                                 dealershipIdSet.add(opp.Dealership__c);
                                                                                                 oppIdSet.add(opp.id);
                                                                                             }
            }

            //Check dealershipSet size
            if (dealershipIdSet.size() > 0) {

                //Map to put all the Id related Account records
                map<Id, Account> accountMap = new map<id, Account>([
                    SELECT id,Finance_Manager__c,Territory_Sales_Manager__c,
                    TSM_ISL__c,TSM_MGA__c,TSM_Rural__c,Accessories_SPOC_1__c,
                    Accessories_SPOC_2__c,Network_Manager__c
                    FROM Account
                    WHERE Id in:dealershipIdSet
                    AND Recordtype.Name = :ConstantsUtility.DEALER_RECORDTYPE
                ]);

                oppTeamMemberDeleteList = new list<OpportunityTeamMember>([
                    SELECT id
                    from OpportunityTeamMember
                    WHERE OpportunityId in:oppIdSet
                ]);

                /*
                  R1.2     9 April 2020 Avaneesh Singh  (US861: Stake holder Management)
                */
                Map<String,Set<Id>> accountRoleKeyUserIdMap = oppHelper.accountContactRoleGroup(dealershipIdSet);

                set<Id> tempSet;
                //Loop through all new Opportunities
                for (Opportunity opp :this.newOppList) {
                    tempSet = new set<Id>();


                    //Check if accountMap contains Opportunity Dealership id
                    if (accountMap.containskey(opp.Dealership__c)) {

                        //Adding Accessories DSE from Enquiry level
                        if (opp.Accessories_DSE1__c != null) {
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c), ConstantsUtility.ACCESSORIES_DSE));
                            tempSet.add(opp.Accessories_DSE1__c);
                        }

                        //Adding Accessories SPOC 1 for every opportunity
                         if(opp.Dealership__c != null){
                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.Accessories_SPOC,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.Accessories_SPOC))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.Accessories_SPOC));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.True_Value_Manager,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.True_Value_Manager))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.True_Value_Manager));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.Accounts_Manager,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.Accounts_Manager))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.Accounts_Manager));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.Allotment_Manager,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.Allotment_Manager))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.Allotment_Manager));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.MGA_Manager,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.MGA_Manager))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.MGA_Manager));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.PDI_Coordinator,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.PDI_Coordinator))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.PDI_Coordinator));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.RTO_Coordinator ,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.RTO_Coordinator ))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.RTO_Coordinator ));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.DC ,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.DC ))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.DC ));

                            oppTeamMemberList.addAll(oppHelper.createOppTeamMemberAccountCon(opp,opp.Dealership__c,ConstantsUtility.QCM,accountRoleKeyUserIdMap));
                            if(accountRoleKeyUserIdMap.containsKey(opp.Dealership__c+'#'+ConstantsUtility.QCM))
                            tempSet.addAll(accountRoleKeyUserIdMap.get(opp.Dealership__c+'#'+ConstantsUtility.QCM));
                         }

                        //Adding Accessories SPOC 1 for every opportunity
                        if (accountMap.get(opp.Dealership__c).Accessories_SPOC_1__c != null) {
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c), ConstantsUtility.ACCESSORIES_SPOC_1));
                            tempSet.add(accountMap.get(opp.Dealership__c).Accessories_SPOC_1__c);
                        }

                        //Adding Accessories SPOC 2 for every opportunity
                        if (accountMap.get(opp.Dealership__c).Accessories_SPOC_2__c != null) {
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c), ConstantsUtility.ACCESSORIES_SPOC_2));
                            tempSet.add(accountMap.get(opp.Dealership__c).Accessories_SPOC_2__c);
                        }

                        //Adding Primary TSM for every Opportunity
                        if (accountMap.get(opp.Dealership__c).Territory_Sales_Manager__c != null) {
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c),
                                ConstantsUtility.PRIMARY_TSM));
                            tempSet.add(accountMap.get(opp.Dealership__c).Territory_Sales_Manager__c);
                        }


                        //Adding Finance managers to Opportunity team for Dealers
                        if (accountMap.get(opp.Dealership__c).Finance_Manager__c != null) {
                            //Adding finance mamanger
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c),
                                ConstantsUtility.FINANCE_MANAGER));
                            tempSet.add(accountMap.get(opp.Dealership__c).Finance_Manager__c);
                        }


                        //Adding TSM in Opportunity team for ISL for Maruti Personas
                        if (opp.ISL_Rural__c == ConstantsUtility.ISL_LINEOFBUSINESS &&
                            accountMap.get(opp.Dealership__c).TSM_ISL__c != null) {
                            //Adding TSM ISL
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c),
                                ConstantsUtility.TSM_ISL));
                            //For Opportunity Share
                            tempSet.add(accountMap.get(opp.Dealership__c).TSM_ISL__c);
                        }

                        //Adding TSM in Opportunity team for RURAL for Maruti Personas
                        else if (opp.ISL_Rural__c == ConstantsUtility.RURAL_LINEOFBUSINESS &&
                            accountMap.get(opp.Dealership__c).TSM_Rural__c != null) {
                            //Adding TSM Rurual
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c),
                                ConstantsUtility.TSM_RURAL));
                            //For Opportunity Share
                            tempSet.add(accountMap.get(opp.Dealership__c).TSM_Rural__c);

                        }
                        //Adding TSM in Opportunity team for ACCESSORIES for Maruti Personas
                        //Rajesh - removed condition on accessories record type so mga tsm will see all enquiries
                        else if (accountMap.get(opp.Dealership__c).TSM_MGA__c != null) {
                            //Adding TSM MGA
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c),
                                ConstantsUtility.TSM_MGA));
                            //For Opportunity Share
                            tempSet.add(accountMap.get(opp.Dealership__c).TSM_MGA__c);
                        }
                        /* added by Gitika for sharing enquiry basis Network Manager */
                        else if(accountMap.get(opp.Dealership__c).Network_manager__c != null){
                            //Adding NETWORK MANAGER
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp, accountMap.get(opp.Dealership__c),
                                                                                        ConstantsUtility.NETWORK_MANAGER));
                            //For Opportunity Share
                            tempSet.add(accountMap.get(opp.Dealership__c).Network_manager__c);

                        }
                        oppTsmUsersMap.put(opp.id, tempSet);
                    }
                }
                //Get all Opportunity share records to be inserted
                oppSharesToInsert = createOppShareRecords(oppTsmUsersMap, oppHelper);
            }


            //Insert Opportunity Share records
            if (oppSharesToInsert.size() > 0) {
                insert oppSharesToInsert;
            }
            //Delete previous Opportunity team member records
            if (Schema.sObjectType.OpportunityTeamMember.isDeletable() && oppTeamMemberDeleteList != null)
                delete oppTeamMemberDeleteList;
            //Insert Opportunity team member records
            if (oppTeamMemberList.size() > 0) {
                insert oppTeamMemberList;
            }

        } catch (System.DmlException e) {
            ExceptionHandler.LogError('OpportunityTriggerHandler addOpportunityTeamMembers', e.getMessage(), 'OpportunityTriggerHandler', '', null);
        }

    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create instances of Opportunity share records
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     17 Sept 2019  Prabhat Sharma  Initial Version
  **/
    public list<OpportunityShare> createOppShareRecords(map<Id, set<Id>> oppTsmUserMap, OpportunityTriggerHelper oppHelper) {
        list<OpportunityShare> oppShareToInsert = new list<OpportunityShare>();

        map<Id, set<Id>> oppShareMap = new map<Id, set<Id>>();
        set<Id> tempIdSet;

        //Query all Opportunity share records related to the Opportunities
        for (opportunityshare oppShare : [SELECT UserOrGroupId,OpportunityId FROM OpportunityShare WHERE OpportunityId in :oppTsmUserMap.keyset()]) {
            tempIdSet = new set<Id>();
            if (oppShareMap.containsKey(oppShare.OpportunityId) && oppShareMap.get(oppShare.OpportunityId) != null) {
                oppShareMap.get(oppShare.OpportunityId).add(oppShare.UserOrGroupId);
            } else {
                tempIdSet.add(oppShare.UserOrGroupId);
                oppShareMap.put(oppShare.OpportunityId, tempIdSet);
            }
        }

        //Loop through all Opportunities
        for (Id opptyId : oppTsmUserMap.keySet()) {
            //Loop through all available users
            for (Id tempId : oppTsmUserMap.get(opptyId)) {
                if (tempId != null && oppShareMap.containsKey(opptyId) && !oppShareMap.get(opptyId).contains(tempId)) {
                    //Create Opportunity share records
                    oppShareToInsert.add(oppHelper.createOppShareRecords(opptyId, tempId));
                }
            }
        }

        //Return all Oppshare records to be created
        return oppShareToInsert;
    }
     /**
Author: Sunit Kumar Chand
Company: Techmatrix
Description: This method will store previous Enquiry owner when ownen changed.
Inputs:
Returns: void
History:
====================================================
1.0     18 Jul 2019  Sunit Kumar Chand  Initial Version
**/
    public void updatePreviousOwneronEnquiry(){
        // This loop is used to traverse through the list of opportunity got updated
        for(Opportunity opp: this.newOppList){
            // This condition will check if owner of Opportunity is changed then it will store previous Opportunity owner in 'Previous Enquiry Owner'
            if(opp.ownerId!=this.oldOppMap.get(opp.Id).ownerId)
            {
                opp.Previous_Enquiry_Owner__c=this.oldOppMap.get(opp.Id).ownerId;
                //Capturing owner change @Rahul Sharma
                system.debug('531 $$% ');
                opp.Is_Owner_Change_Performed__c = true;
            }
            if(opp.ownerId == this.oldOppMap.get(opp.Id).ownerId && opp.Is_Owner_Change_Performed__c == true)
            {
                system.debug('536 $$% ');
                //Capturing owner change @Rahul Sharma
                opp.Is_Owner_Change_Performed__c = false;
            }
        }
    }

    /**
        Author: Sunit Kumar Chand
        Company: Techmatrix
        Description: This method will check BookingCancellationReason field and update opportunity stage to New
        if BookingCancellationReason is Post-Pone
        and previous value of BookingCancellationReason is blank.
        Inputs:
        Returns: void
        History:
        ====================================================
        1.0     26 Aug 2019  Sunit Kumar Chand  Initial Version
  **/
    public void checkBookingCancellationReason() {
        try {
            // This loop is used to traverse through the list of opportunity got updated
            for (Opportunity opp : this.newOppList) {
                // This condition will check if owner of Opportunity is changed then it will store previous Opportunity owner in 'Previous Enquiry Owner'
                if (opp.Booking_Cancellation_Reason__c != Null && String.isBlank(this.oldOppMap.get(opp.Id).Booking_Cancellation_Reason__c)) {
                    opp.StageName = ConstantsUtility.STAGE_NEW;
                    opp.Pre_booking_Submission_Date__c = null;
                }
                /*else if(String.isNotBlank(opp.Booking_Cancellation_Reason__c) && opp.Booking_Cancellation_Reason__c!=label.Booking_Cancellation_Reason && String.isBlank(this.oldOppMap.get(opp.Id).Booking_Cancellation_Reason__c)){
opp.StageName=ConstantsUtility.STAGE_CLOSELOST;
}*/
            }
        } catch (Exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'OpportunityTriggerHandler checkBookingCancellationReason'; ehst.userId = UserInfo.getUserId(); ExceptionHandler.LogError('OpportunityTriggerHandler checkBookingCancellationReason', e.getMessage(), 'OpportunityTriggerHandler', '', ehst);
        }
    }


    /**
        Author: Ritika Mehendiratta
        Company: Techmatrix
        Description: Method to update the standard account field on opportunity with the value in opportunity owner field
        Inputs: List of Opportunities
        Returns: void
        History:
        ====================================================
        1.0     19 Jul 2019    Ritika Mehendiratta  Initial Version
        1.1     29 Oct 2019    Prabhat Sharma       Added logic to populate Accessories DSE field for Accessories Enquiries
        1.2     16 Jun 2020   Nitish/Saloni         Changes in method Parameter due to trigger design setup in MSDS R1.2. Refer OpportunityTriggerHandler Class for Method originality.
    **/

    //Updated by Anuj(TechMatrix) as part of strategy implementation


    public void updateDealerAndStandardAccount() {
        system.debug('updateDealerAndStandardAccount******* OpportunityTriggerHandler_Strategy');
        //Map to store the Portal User Ids as keys and Dealer Account ID as values
        map < Id, Id > userContactAccountMap = new map < Id, Id > ();
        //Map to store the Portal User Ids as keys and User Account ID as values
        map < Id, Id > userAccountUserAccountMap = new map < Id, Id > ();

        //Map to store the Portal User Ids as keys and User Account ID as values
        map < Id, String > userDesignationMap = new map < Id, String > ();
        //Map to store the Portal User Ids as keys and User Account ID as values
        map < Id, User > accountChannelMap = new map < Id, User > ();

        //Channel model Map
        map < String, String > channelModelMap = new map < String, String > (ConstantsUtility.channelModelMap);

        //Loop through trigger.new
        for (Opportunity opp: this.newOppList) {
            //Populating Mobile no. for SFMC
            if (opp.Mobile__c != null && (trigger.isInsert || (trigger.isUpdate && this.oldOppMap.get(opp.Id).Mobile__c != opp.Mobile__c))) {
                //populate SFMC Mobile field
                opp.Mobile_SFMC__c = ConstantsUtility.COUNTRY_CODE + String.valueof(opp.Mobile__c);
            }

            if (opp.OwnerID != label.Integration_User && (trigger.isInsert || (trigger.isUpdate && this.oldOppMap.get(opp.Id).OwnerID != opp.OwnerId)))
                userContactAccountMap.put(opp.ownerId, null);

        }


        //If the map has something...
        if (userContactAccountMap.keySet().size() > 0) {

            //Looping through all portal users to get their account IDs
            for (User portalUser: [Select id, ContactId, Contact.AccountId, Contact.Account.Channel__c, Designation__c ,
                            Contact.Account.Dealer_Category__c
                            from user where id in: usercontactAccountMap.keySet()]) {
                if (portalUser.ContactId != null) {
                    userContactAccountMap.put(portalUser.Id, portalUser.Contact.AccountId);
                    //Dealership channe field on Enquiry
                    //Change Map As R1.2 Parts development
                    accountChannelMap.put(portalUser.Contact.AccountId, portalUser);
                    //Added to check the designation for Accessories Enquiries
                    userDesignationMap.put(portalUser.Id, portalUser.Designation__c);
                }
            }

            //Loop through all the accounts
            for (Account userAcc: [select id, user__c from Account where recordtype.developername =: ConstantsUtility.USER_ACCT_RECORDTYPE and user__c in: userContactAccountMap.keySet()]) {
                userAccountUserAccountMap.put(userAcc.user__c, userAcc.id);
            }

            //Populating Account Id on Enquiry
            for (Opportunity oppty: this.newOppList) {

                //Update the Dealership
                if (userContactAccountMap.containsKey(oppty.OwnerId) && userContactAccountMap.get(oppty.OwnerId) != null) {
                    oppty.Dealership__c = userContactAccountMap.get(oppty.OwnerId);

                    //Change Map As R1.2 Parts development
                    User userData = accountChannelMap.get(oppty.Dealership__c);
                    String dealerChannel = '';
                    String dealerCategory = '';
                    if(userData != null){
                        dealerChannel = userData.Contact.Account.Channel__c;
                        dealerCategory = userData.Contact.Account.Dealer_Category__c;
                    }

                    if (accountChannelMap.get(oppty.Dealership__c) != null && channelModelMap.containsKey(dealerChannel)) {
                        if(dealerChannel == ConstantsUtility.PARTS_DEALER_CHANNEL && dealerCategory == ConstantsUtility.PARTS_DEALER_CATEGORY){
                            oppty.Dealership_Channel__c = ConstantsUtility.PARTS;
                        }else{
                            oppty.Dealership_Channel__c = channelModelMap.get(dealerChannel);
                        }
                    }
                }

                //Update the standard Account field on Enquiry
                //This will enable the visiblity for the Account team of that account
                if (userAccountUserAccountMap.containsKey(oppty.OwnerId) && userAccountUserAccountMap.get(oppty.OwnerId) != null)
                    oppty.AccountId = userAccountUserAccountMap.get(oppty.OwnerId);

                //Check if the enquiry is an Accessories Enquiry and the Owner is an Accessories DSE,
                //Update the Accessories DSE field on Enquiry
                if (oppty.RecordtypeId == accessoriesSalesId && userDesignationMap.containsKey(oppty.OwnerId) &&
                    userDesignationMap.get(oppty.OwnerId) == ConstantsUtility.ACCESSORIES_DSE_DESIGNATION) {
                    oppty.Accessories_DSE1__c = oppty.OwnerId;
                }
            }
        }
    }

    /**
        Author: Nitish Bansal
        Company: Techmatrix
        Description: Method to populate Exchange vehicle evaluator(previously part of updateDealerAndStandardAccount())
        Inputs: List of Opportunities
        Returns: void
        History:
        ====================================================
        1.0     05 Jun 2020  Nitish Bansal     Initial Version
        1.1     16 Jun 2020  Nitish/Saloni      Changes in method Parameter due to trigger design setup in MSDS R1.2. Refer OpportunityTriggerHandler Class for Method originality.
        1.2     30 Jul 2020  Rahul Sharma    Change in logic to assign user on enquiry for chose evaluator
    **/
    public void populateExchangeVehicleEvaluator() {
         //Map to store the Contact Ids as keys and User ID as values
        map < Id, String > contactUserIdsMap = new map < Id, String > ();
        map < Id, String > conEnqMap = new map < Id, String > ();
        set <Id> evalConIds= new set <Id>();
        //Loop through trigger.new
        for (Opportunity oppty: this.newOppList) {
            if(oppty.Exchange_Vehicle_Evaluator_Contact__c != null)
            {
                system.debug('oppEvalMap'+oppty.Exchange_Vehicle_Evaluator_Contact__c);
                evalConIds.add(oppty.Exchange_Vehicle_Evaluator_Contact__c);
            }

        }
        for (Contact con: [Select Id,Related_TV_Eval_User__c From Contact where id in: evalConIds]) {
            conEnqMap.put(con.Id,con.Related_TV_Eval_User__c);
        }
        if (conEnqMap.values() != Null && conEnqMap.values().size() > 0) {
                for (Opportunity oppty: this.newOppList) {
                    //Update the Exchange Vehicle Evaluator field on Enquiry
                    if (oppty.Exchange_Vehicle_Evaluator_Contact__c != Null && conEnqMap != null && conEnqMap.containsKey(oppty.Exchange_Vehicle_Evaluator_Contact__c)) {
                        oppty.Exchange_Vehicle_Evaluator__c = conEnqMap.get(oppty.Exchange_Vehicle_Evaluator_Contact__c);
                    }
                }
            }
        }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to update Escaltion fields on Enquiry based on which Escaltion will happen.
        Returns: void
        History:
        ====================================================
        1.0     22 Jul 2019  Prabhat Sharma  Initial Version
  **/
    public void updateEscalationFields() {
        system.debug('== updateEscalationFields 1');
        //To avoid recursive call of trigger as DML is required to update the Escalated flag to false
        //if(AvoidRecursion.isBeforeRun()){
        //Calling Escalation Service Class to Update the fields
        escSrvc.escalationFieldUpdates(this.newOppList, this.oldOppMap);
        system.debug('== updateEscalationFields 2');
        // }
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to post chatter message after enquiry Escalation
        Returns: void
        History:
        ====================================================
        1.0     22 Jul 2019  Prabhat Sharma  Initial Version
  **/
    public void postChatterMessage(Boolean isInsert, Boolean isUpdate) {
        //Call Escaltion Service Class
        new EnquiryEscalationService().postEscalationChatterMessage(this.newOppList, this.newOppMap, this.oldOppMap, isInsert);
    }


    /**
        Author: Rajesh Ramachandran
        Description: Method to set Enquiry_Stage_Time__c(changed to last modified time stamp) with current Stage and timestamp
        Returns: void
        History:
        Last Modified By: Prabhat Sharma 22 Aug 2019
        ====================================================
        1.0    09 Aug 2019  Rajesh Ramachandran  Initial Version
  **/
    public void setStageTime(String opportunityRecordTypeName) {
        system.debug('== setStageTime ');
        //Variable to store Dealership Ids
        set<Id> dealershipIds = new set<Id>();
        set<Id> colorIds = new set<Id>();
  //1.1CR Changes
  set<Id> campaignIds = new set<Id>();
        set<Id> OwnerIds = new set<Id>();
        //Loop through trigger new and get the dealerships Ids
        for (Opportunity opp : this.newOppList) {
            OwnerIds.add(opp.OwnerId);
            if (opp.Dealership__c != null)
                dealershipIds.add(opp.Dealership__c);
            if (opp.color__c != null)
                colorIds.add(opp.Color__c);
      //1.1CR
            if(opp.CampaignId != Null)
                campaignIds.add(opp.CampaignId);

            if(opportunityRecordTypeName == ConstantsUtility.PARTS && opp.FollowUp_Last_Modified_Details__c == Null && trigger.isInsert){
                opp.FollowUp_Last_Modified_Details__c = ConstantsUtility.PARTS_DEFAULT_FOLLOW_UP_DETAIL;
            }
        }

        if(dealershipIds.size()>0 || campaignIds.size() > 0){
            //Query Owner details
            Map<Id,User> OwnerMap = new Map<Id,User>([SELECT Id,MSPIN__c FROM User where id in :OwnerIds]);
            //Query the dealership details
            Map<Id, Account> dealershipMap = new Map<Id, Account>([
                SELECT Id,Dealer_Map_Code__c,Dealer_Location__c,Parent_Group__c,For_Code__c,For_Code__r.For_Code__c,Dealer_Code__c,
                Dealer_Comp_FA__c
                FROM Account
                WHERE Id in:dealershipIds
            ]);
            //Query the Campaign details
            Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, Location__c, Location__r.Event_Code__c
                                                                   FROM Campaign WHERE Id in: campaignIds]);
            //Query Variant Master Records
            Map<Id, Color_Variant_Master__c> colorVariantMap = new Map<Id, Color_Variant_Master__c>([SELECT Id,Name,Color_Code__c FROM Color_Variant_Master__c WHERE Id in:colorIds]);

            Set<String> oppStageSet = new Set<String>();
            List<OpportunityStage> stageList = new list<OpportunityStage>([SELECT Id, ApiName FROM OpportunityStage WHERE IsClosed = true]);

            //Loop through closed Opportuntiy stages
            for (OpportunityStage opp : stageList) {
                oppStageSet.add(opp.ApiName);
            }

            //Loop through trigger new
            for (Opportunity opty : this.newOppList) {

                //Enquiry Stage
                String data = ConstantsUtility.OPEN_CURLY_BRACES;

                String enquiryStage = '';
                enquiryStage = (oppStageSet.contains(opty.stagename) && trigger.isUpdate) ? this.oldOppMap.get(opty.id).StageName : opty.StageName;

                //Enquiry Stage
                data += oppHelper.createKeyValueStructure(ConstantsUtility.STAGE_LABEL, enquiryStage);

                //Dealer Map Code
                if (opty.Dealership__c != null && dealershipMap.containsKey(opty.Dealership__c)) {
                    //Dealer Map Code
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.DEALERMAPCODE_LABEL, dealershipMap.get(opty.Dealership__c).Dealer_Map_Code__c);
                    //Dealer For Code
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.FORCODE_LABEL, dealershipMap.get(opty.Dealership__c).For_Code__r.For_Code__c);
                    //Pre-Booking Number
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.PRE_BOOKING_LABEL, opty.Pre_Booking_Number__c);
                    //Adding the Dealer Code
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.DEALER_CODE, dealershipMap.get(opty.Dealership__c).Dealer_Code__c);
                    //Parent Group
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.DEALERPARENTGROUP_LABEL, dealershipMap.get(opty.Dealership__c).Parent_Group__c);
                    //Dealer Location
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.DEALERLOCATIONCODE_LABEL, dealershipMap.get(opty.Dealership__c).Dealer_Location__c);
                    //Dealer COMP FA
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.DEALER_COMP_FA, dealershipMap.get(opty.Dealership__c).Dealer_Comp_FA__c);
                }

                if(opty.CampaignId != Null){
                    //Event_Code
                    data+=oppHelper.createKeyValueStructure('Event_Code', (campaignMap.get(opty.CampaignId).Location__c != Null ? campaignMap.get(opty.CampaignId).Location__r.Event_Code__c : null));
                }
                //Adding the Color Code
                String colorCode = '';
                if (opty.Color__c != null && colorVariantMap.containsKey(opty.Color__c)) {
                    colorCode = colorVariantMap.get(opty.Color__c).Color_Code__c;
                }
                data += oppHelper.createKeyValueStructure(ConstantsUtility.COLOR_LABEL, colorCode);

                //Adding DMS Enquiry Number
                data += oppHelper.createKeyValueStructure(ConstantsUtility.DMS_ENQUIRY_NUM, opty.DMS_Enquiry_Name__c);
                //Adding Booking Number
                data += oppHelper.createKeyValueStructure(ConstantsUtility.BOOKING_NUMBER, opty.Booking_Number__c);

                 //Adding Enquiry Record Type

                data += oppHelper.createKeyValueStructure(ConstantsUtility.RECORD_TYPE_CONST, opportunityRecordTypeName);

                if(opportunityRecordTypeName ==  ConstantsUtility.OPPORTUNITY_LOYALTY_RECORDTYPE){
                    data += oppHelper.createKeyValueStructure(ConstantsUtility.MSPIN_CONST,OwnerMap.get(opty.OWNERID).MSPIN__c!=NULL ?OwnerMap.get(opty.OWNERID).MSPIN__c:NULL);
                }

                // Added By: Anuj (Requested by Rajesh related to DMS)
                system.debug('@@## opty.StageName '+opty.StageName);
                if(opty.Last_Follow_Up_Update_Time__c != Null && this.oldOppMap != Null &&
                       this.oldOppMap.get(opty.id).Last_Follow_Up_Update_Time__c != opty.Last_Follow_Up_Update_Time__c){
                       data+=oppHelper.createKeyValueStructure(ConstantsUtility.IS_FOLLOW_UP_UPDATE, String.valueOf(True));
                }else if(opty.Last_Follow_Up_Update_Time__c != Null && this.oldOppMap != Null &&
                       this.oldOppMap.get(opty.id).Last_Follow_Up_Update_Time__c == opty.Last_Follow_Up_Update_Time__c &&
                       opty.isRequestToLost__c && this.oldOppMap.get(opty.id).isRequestToLost__c != opty.isRequestToLost__c &&
                       opty.Pending_Approval__c && this.oldOppMap.get(opty.id).Pending_Approval__c != opty.Pending_Approval__c){
                       data+=oppHelper.createKeyValueStructure(ConstantsUtility.IS_FOLLOW_UP_UPDATE, String.valueOf(True));
                }else if(this.oldOppMap != Null && !opty.Pending_Approval__c && this.oldOppMap.get(opty.id).Pending_Approval__c != opty.Pending_Approval__c &&
                        this.oldOppMap.get(opty.id).StageName != opty.StageName && opty.StageName == 'Closed Lost'){
                       data+=oppHelper.createKeyValueStructure(ConstantsUtility.IS_FOLLOW_UP_UPDATE, String.valueOf(True));
                       system.debug('@@## Contains '+opty.FollowUp_Last_Modified_Details__c.contains('##'));
                       if(string.isNotBlank(opty.FollowUp_Last_Modified_Details__c) && opty.FollowUp_Last_Modified_Details__c.contains('##')){
                           String FollowUpDetails = opty.FollowUp_Last_Modified_Details__c;
                           system.debug('@@## FollowUpDetails  '+FollowUpDetails );
                           system.debug('@@## Split Condition '+(FollowUpDetails.split('##').size() >= 6 && FollowUpDetails.contains('##F##')));
                           if(FollowUpDetails.split('##').size() >= 6 && FollowUpDetails.contains('##F##')){
                              opty.FollowUp_Last_Modified_Details__c = FollowUpDetails.replace('##F##','##L##');
                              system.debug('@@## opty.FollowUp_Last_Modified_Details__c '+opty.FollowUp_Last_Modified_Details__c);
                           }
                       }
                    } else {
                        data += oppHelper.createKeyValueStructure(ConstantsUtility.IS_FOLLOW_UP_UPDATE, String.valueOf(False));
                    }


                //Time Stamp
                data += oppHelper.createKeyValueStructure(ConstantsUtility.TIMESTAMP_LABEL, String.valueOf(Datetime.now()));
                data = data.removeEnd(ConstantsUtility.COMMA);

                //Closed Curly Braces
                data += ConstantsUtility.CLOSE_CURLY_BRACES;
                //Update the data in Last Modified Details field
                opty.Last_Modified_Details__c = data;

                system.debug('== opty.Last_Modified_Details__c '+opty.Last_Modified_Details__c);
                
                //Rahul Adding logic to get the external Id
                //Should be populated only if Enquiry Number is generate.
                //Should be a combination of dealer map code, Dealer location Code, Dealer Parent group and Enquriy
                if (string.isNotBlank(opty.DMS_Enquiry_Name__c)) {
                    opty.External_Id__c = dealershipMap.get(opty.Dealership__c).Parent_Group__c +
                        '_' + dealershipMap.get(opty.Dealership__c).Dealer_Map_Code__c +
                        '_' + dealershipMap.get(opty.Dealership__c).Dealer_Location__c +
                        '_' + opty.DMS_Enquiry_Name__c;
                }

                //if the stage of Enquiry changed to Retail then update Send_BCR_Time__c equals to null
                if (opty.stageName == ConstantsUtility.RETAIL_NAME && (trigger.isInsert || (trigger.isUpdate && this.oldOppMap.get(opty.Id).Stagename != opty.stageName))) {
                    opty.Send_BCR_Time__c = null;
                }

                //Rajesh - temporary fix to solve line of business not defaulted by Mulesoft user
                try {
                    if (trigger.isInsert) {

                        //Temporary fix to remove dots from the Name fields
                        if (String.isNotBlank(opty.First_Name__c)) {
                            opty.First_Name__c = opty.First_Name__c.contains('.') ? opty.First_Name__c.remove('.').trim() : opty.First_Name__c.trim();
                        }
                        if (String.isNotBlank(opty.Middle_Name__c)) {
                            opty.Middle_Name__c = opty.Middle_Name__c.contains('.') ? opty.Middle_Name__c.remove('.').trim() : opty.Middle_Name__c.trim();
                        }
                        if (String.isNotBlank(opty.Last_Name__c)) {
                            opty.Last_Name__c = opty.Last_Name__c.contains('.') ? opty.Last_Name__c.remove('.').trim() : opty.Last_Name__c.trim();
                        }
                    }
                } catch (Exception e) {
                    ExceptionHandler.LogError('OpportunityTriggerHandler default lob', e.getMessage(), 'OpportunityTriggerHandler', '', null);
                }

            }
        }
    }


    /**
        Author: Prabhat Sharma
        Description: Method to notify SPOC about DSE Allocation
        Returns: void
        History:
        Last Modified By: Prabhat Sharma 14 Oct 2019
        ====================================================
        1.0   14 Oct 2019  Rajesh Ramachandran  Initial Version
  **/
    public void notifySpocForDSEAllocation() {
        try {
            set<Id> oppIdSet = new set<Id>();
            List<Opportunity> optyList = new list<Opportunity>(OpportunityTriggerHelper.spocOptyList);
            if (optyList.size() > 0) {
                for (Opportunity opp : optyList) {
                    oppIdSet.add(opp.Id);
                }

                //If SPOC has been assigned
                if (oppIdSet.size() > 0) {
                    //System.enqueueJob(new AsyncCreateRecordQueueable(true, ConstantsUtility.SPOC_TO_ALLOT_DSE, oppIdSet, ConstantsUtility.OPPORTUNITY, ''));
                    GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.SPOC_TO_ALLOT_DSE, oppIdSet, ConstantsUtility.OPPORTUNITY, '');
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('OpportunityTriggerHandler notifySpocForDSEAllocation', e.getMessage(), 'OpportunityTriggerHandler', '', null);
        }
    }


    /**
        Author: Prabhat Sharma
        Description: Method to create PreBooking Follow Up task on creation of an enquiry
        Returns: void
        History:
        Last Modified By: Prabhat Sharma 23 Aug 2019
        ====================================================
        1.0    23 Aug 2019  Rajesh Ramachandran  Initial Version
  **/
    public void createEnquiryFollowUp(String taskRecordTypeId, String typeOfFollowUp, String followUpType, Integer reminderTime, Boolean isLoyalty){
        try {
            set<Id> customerIds = new set<Id>();
            for (Opportunity opp : this.newOppList) {
                if (opp.Customer__c != null)
                    customerIds.add(opp.Customer__c);
            }
            //Map to store enquiry Id as key and Prebooking Task Id as value
            map<String, Task> enquiryIdFollowUpIdMap = new map<String, Task>();

            //Query PersonContact to poulate on Name ID field on task record.
            Map<Id, Account> mapAccount = new Map<Id, Account>([select id,personcontactid,PersonEmail,Name from Account where id in :customerIds]);

            list<User> Current_User = currentUserList;

            for (Opportunity opp : this.newOppList) {

                system.debug('== opp.Owner_Designation__c '+opp.Owner_Designation__c);

                if (!AvoidRecursion.processedEnquiryIds.contains(opp.Id)) {
                    //If Dealership is not blank
                    //Create Task record instance
                    Task followUp = new Task();
                    //Populate relevant fields on Task
                    if(isLoyalty == false){
                        followUp = oppHelper.createTaskRecordInstance(opp, taskRecordTypeId, typeOfFollowUp, followUpType,reminderTime);
                    }else if(isLoyalty == true && ConstantsUtility.DESIGNATION.contains(opp.Owner_Designation__c)){
                        followup = oppHelper.createLoyaltyEnrolmentFollowUps(opp, taskRecordTypeId,
                                                                         followUpType, ConstantsUtility.Loyality_Task_PRIORITY,
                                                                         ConstantsUtility.Loyality_Task_ACTIVITYDATE, Current_User[0].channel__c);

                        string Name = mapAccount.containskey(opp.Customer__c) ? mapAccount.get(opp.Customer__c).Name :opp.Name;
                        followup.Subject = ConstantsUtility.Pitch_Loyality_to + Name;
                        followup.Customer_Email_ID__c= mapAccount.containskey(opp.Customer__c) ? mapAccount.get(opp.Customer__c).PersonEmail : '';
                    }
                    //Populate Name field on task Record
                    if (mapAccount.get(opp.Customer__c) != null)
                        followUp.Enquiry_Customer__c = mapAccount.get(opp.Customer__c).PersonContactId;

                    enquiryIdFollowUpIdMap.put(opp.Id, followUp);

                    //Recusrion Fix - Prabhat 17th Jan
                    AvoidRecursion.processedEnquiryIds.add(opp.Id);
                }
            }

            if (enquiryIdFollowUpIdMap.values().size() > 0) {
                //Create Pre-Booking Follow ups
                insert enquiryIdFollowUpIdMap.values();
            }
            //}
        } catch (Exception e) {
            ExceptionHandler.LogError('OpportunityTriggerHandler createPreBookingFollowUp', e.getMessage(), 'OpportunityTriggerHandler', '', null);
        }
    }

    /**
        Author: Saloni Gupta
        Description: Method to create MSDS Follow Up task on creation of an enquiry
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    16-July-2020  Saloni Gupta  Initial Version
  **/
    public void createMSDSEnquiryFollowUp(String taskRecordTypeId){
        try {

            //Map to store enquiry Id as key and Prebooking Task Id as value
            map<String, Task> enquiryIdFollowUpIdMap = new map<String, Task>();

            for (Opportunity opp : this.newOppList) {

                if (!AvoidRecursion.processedEnquiryIds.contains(opp.Id)) {
                    //Create Task record instance
                    Task followUp = new Task();
                    //Populate relevant fields on Task
                    followUp = oppHelper.createTaskRecordInstance(opp, taskRecordTypeId, ConstantsUtility.MSDS_FOLLOW_UP_TASK_REC_TYPE, ConstantsUtility.MSDS_FOLLOWUP_TYPE, ConstantsUtility.MSDS_REMINDER_TIME);
                    followUp.MSDS_Enquiry_Stage__c = ConstantsUtility.MSDS_FOLLOWUP_STAGE;
                    followUp.MSDS_Enquiry_Status__c = ConstantsUtility.MSDS_FOLLOWUP_STATUS;

                    enquiryIdFollowUpIdMap.put(opp.Id, followUp);

                    //Recusrion Fix - Prabhat 17th Jan
                    AvoidRecursion.processedEnquiryIds.add(opp.Id);
                }
            }

            if (enquiryIdFollowUpIdMap.values().size() > 0) {
                //Create Pre-Booking Follow ups
                insert enquiryIdFollowUpIdMap.values();
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('OpportunityTriggerHandler createMSDSBookingFollowUp', e.getMessage(), 'OpportunityTriggerHandler', '', null);
        }
    }


    /**
        Author: Prabhat Sharma
        Description: Method to search customer based on svoc ids and update on enquiries
        Returns: void
        History:
        Last Modified By: Prabhat Sharma 22 Aug 2019
        ====================================================
        1.0  21 Aug 2019  Prabhat Sharma  Initial Version
        1.1 17 Apr 2020   Deepak Kumar   Added method to update Interested in Loyalty
  **/
    public void updateFieldsUsingSVOCID() {
        if (AvoidRecursion.isSVOCAfterRun()) {
            try {
                //Map to have SVOC ID as key and Account  as value
                map<string, Account> svocIdAccountMap = new map<string, Account>();

                //List to update all customers SVOC ID field
                map<Id, Account> accountToUpdate = new map<Id, Account>();

                //List to update all customers SVOC ID field
                //  list<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
                // instead of List now we are using map to avoid Duplicate id Issue
                Map<Id,Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();

                //List have Opportunities for which new Accounts will be created
                list<Opportunity> newAccountsForOpps = new List<Opportunity>();

                list<Task> taskListToBeInserted = new list<Task>();

                set<id> customerIds = new set<id>();
                Account account = new Account();

                //Loop through trigger.new
                for (Opportunity opp : this.newOppList) {
                    if (String.isNotBlank(opp.SVOC_ID__c) && opp.SVOC_ID__c != this.oldOppMap.get(opp.Id).SVOC_ID__c) {
                        svocIdAccountMap.put(opp.SVOC_ID__c, null);
                    }
                    // added by Gitika
                    if (opp.RecordTypeId == LoyalityEnrolmentRecordTypeId && ConstantsUtility.DESIGNATION.contains(opp.Owner_Designation__c)
                        && trigger.isUpdate && opp.ownerId != this.oldOppMap.get(opp.id).OwnerId) {
                            customerIds.add(opp.Customer__c);
                        }
                }


                //If there is a change in SVOC ID field, proceed further
                if (svocIdAccountMap.size() > 0) {

                    //Map to store the search results for all accounts
                    map<string, Account> searchResultMap = SVOCSearchUtility.searchCustomersBySVOCIds(svocIdAccountMap);

                    //Query and loop through all the filtered enquiries
                    for (Opportunity opty : [
                        SELECT Id,Name,Customer__c,SVOC_ID__c,Customer__r.Status__c,Customer__r.SVOC_ID__c,
                        First_Name__c,Last_Name__c,Email__c,Mobile__c,Customer__r.Tier__c,Reason_not_Interested_in_Loyalty__c,
                        Customer__r.Loyalty_Card_Number__c,Interested_In_Loyalty__c, Dealership_Channel__c
                        FROM Opportunity
                        WHERE SVOC_ID__c in :svocIdAccountMap.keyset()
                    ]) {


                        //If customer NOT FOUND and previous value was a BLANK value
                        if (searchResultMap.containsKey(opty.SVOC_ID__c) && searchResultMap.get(opty.SVOC_ID__c)==null &&
                            String.isBlank(this.oldOppMap.get(opty.Id).SVOC_ID__c)) {
                                //Update customer SVOC ID field and no change in status
                                Account tempAcc = oppHelper.updateAccountSVOCDetails(opty, false, true);
                                accountToUpdate.put(tempAcc.Id, tempAcc);
                            }

                        //If customer NOT FOUND and previous value was a NON BLANK value
                        else if (searchResultMap.containsKey(opty.SVOC_ID__c) && String.isBlank(searchResultMap.get(opty.SVOC_ID__c).Id) &&
                                 String.isNotBlank(this.oldOppMap.get(opty.Id).SVOC_ID__c)) {
                                     //Add enquiries for which new Accounts to be created
                                     newAccountsForOpps.add(opty);
                                     // If previous customer is a propsect, mark it as duplicate
                                     Account tempAcc = oppHelper.updateAccountSVOCDetails(opty, false, false);
                                     accountToUpdate.put(tempAcc.Id, tempAcc);

                                 }
                        //If customer is FOUND and previous value was BLANK or a NON BLANK value
                        else if (searchResultMap.containsKey(opty.SVOC_ID__c) && String.isNotBlank(searchResultMap.get(opty.SVOC_ID__c).Id) &&
                                 opty.Customer__c != searchResultMap.get(opty.SVOC_ID__c).Id) {
                                     // If previous customer is a propsect, mark it as duplicate
                                     Account tempAcc = oppHelper.updateAccountSVOCDetails(opty, true, false);
                                     accountToUpdate.put(tempAcc.Id, tempAcc);
                                     // Update customer field on Enquiry with newly found Customer record
                                     opty.Customer__c = searchResultMap.get(opty.SVOC_ID__c).Id;
                                     opportunitiesToUpdateMap.put(opty.Id,opty);
                                 }
                        /** Added By Deepak Kumar
                        // to check for Account's Teir and Loyalty Card Number based on SVOC ID and update the Interested In Loyalty. */
                        if (searchResultMap.containsKey(opty.SVOC_ID__c) && searchResultMap.get(opty.SVOC_ID__c)!=null && String.isNotBlank(searchResultMap.get(opty.SVOC_ID__c).Id)) {

                            if(opportunitiesToUpdateMap.containsKey(opty.Id)){
                                opty = opportunitiesToUpdateMap.get(opty.Id);
                            }
                            // Method is defined below
                            opty = polulateInterestedInLoyalty(opty, searchResultMap.get(opty.SVOC_ID__c));
                            opportunitiesToUpdateMap.put(opty.Id,opty);

                        }

                    }


                    //If new Accounts needs to be created
                    if (newAccountsForOpps.size() > 0) {
                        //Get the IDs of newly created customer accounts
                        map<string, string> newSearchResultMap = SVOCSearchUtility.createPersonAccounts(newAccountsForOpps);

                        //Loop through all the enquiries and map the customer with newly created records
                        for (Opportunity newopty : [SELECT Id,SVOC_ID__c,Customer__c FROM Opportunity WHERE Id in :newAccountsForOpps]) {
                            if (newSearchResultMap.containsKey(newopty.SVOC_ID__c) && String.isNotBlank(newSearchResultMap.get(newopty.SVOC_ID__c))) {
                                newopty.Customer__c = newSearchResultMap.get(newopty.SVOC_ID__c);
                                opportunitiesToUpdateMap.put(newopty.Id,newopty);

                            }
                        }
                    }

                    //Update customer with SVOC Ids
                    if (accountToUpdate.size() > 0) {
                        update accountToUpdate.values();
                    }

                    //Update Enquiries with new customer lookups
                    if (opportunitiesToUpdateMap.values().size() > 0) {
                        update opportunitiesToUpdateMap.values();
                    }
                }
                // Added by Gitika for Loyalty Enrollments.
                //Query customer details to poulate on task record.
                Map<Id, Account> mapOfCustomerWithCustomerDetails = new Map<Id, Account>([select id,personcontactid,PersonEmail,Name from Account where id in :customerIds]);

                //Query current user to get Channel
                list<User> Current_User = currentUserList;

                // checks if Enquriy is loyalty enrollment and Enquiry owner designation is QCM ,NTD
                for (opportunity opp : this.newOppList) {
                    if (opp.RecordTypeId == LoyalityEnrolmentRecordTypeId && ConstantsUtility.DESIGNATION.contains(opp.Owner_Designation__c)
                        && trigger.isUpdate && opp.ownerId != this.oldOppMap.get(opp.id).OwnerId) {
                            Task followup = new Task();

                            followup = oppHelper.createLoyaltyEnrolmentFollowUps(opp, LoyalityEnrolmentFollowUpTaskRecordTypeId,
                                                                                 ConstantsUtility.Loyality_Task_TYPE, ConstantsUtility.Loyality_Task_PRIORITY,
                                                                                 ConstantsUtility.Loyality_Task_ACTIVITYDATE, Current_User[0].channel__c);

                            string Name = mapOfCustomerWithCustomerDetails.containskey(opp.Customer__c) ? mapOfCustomerWithCustomerDetails.get(opp.Customer__c).Name :opp.Name;
                            followup.Subject = ConstantsUtility.Pitch_Loyality_to + Name;
                            followup.Customer_Email_ID__c= mapOfCustomerWithCustomerDetails.containskey(opp.Customer__c) ? mapOfCustomerWithCustomerDetails.get(opp.Customer__c).PersonEmail : '';
                            followup.Enquiry_Customer__c= mapOfCustomerWithCustomerDetails.containskey(opp.Customer__c) ? mapOfCustomerWithCustomerDetails.get(opp.Customer__c).personcontactId :'';
                            taskListToBeInserted.add(followup);
                        }
                }

                if (taskListToBeInserted.size() > 0) insert taskListToBeInserted;

            } catch (Exception e) {
                ExceptionHandler.LogError('OpportunityTriggerHandler updateFieldsUsingSVOCID', e.getMessage(), 'OpportunityTriggerHandler', '', null);
            }
        }
    }


    /**
        Author: Nishant Prajapati
        Description: Change Enquiry Stage to Booking when Reatil Cancellation Date gets populated
        Returns: void
        History:
        Last Modified By: Nishant 26 Aug 2019
        ====================================================
        1.0  26 Aug 2019  Nishant  Initial Version
  **/
    public void changeEnquiryStage() {
        for (Opportunity opp : this.newOppList) {

            if (opp.Retail_Cancellation_Date__c <> null && this.oldOppMap.get(opp.Id).Retail_Cancellation_Date__c == null) {
                opp.stageName = ConstantsUtility.STAGE_BOOKING;
            }

            if(this.oldOppMap.get(opp.Id).Acc_Value_Current_Month__c != opp.Acc_Value_Current_Month__c){
                opp.Acc_Previous_Month__c = this.oldOppMap.get(opp.Id).Acc_Value_Current_Month__c;
                opp.Acc_Previous_Current_Month__c = this.oldOppMap.get(opp.Id).Acc_Current_Month__c ;

                opp.Is_Acc_Updated__c = true;
            }
        }
    }


    /**
        Author: Rahul Raghunathan
        Description: Updates the Name of the Enquiry to Customer Name - Record Type
        Returns: void
        History:
        Last Modified By: Rahul 17 Sep 2019
        ====================================================
        1.0  Rahul 17 Sep 2019  Initial Version
        1.1  Prabhat 10 Oct 2019  Second Version
        1.2  Addition of Refree Details Pre population --> Gitika Khandelwal 13 April 2020  Thrid Version
  **/
    public void updateEnquiryName(String enqType) {

        Map<String, Account> loyaltyCardNoMap = new Map<String, Account>();
        Map<String, Account> loyaltyCardMobileNoMap = new Map<String, Account>();
        Map<String, String> OppidWithLoyaltyDMSid = new Map<String, String>();
        list<Task> ListTaskToUpdate = new list<Task>();

        for (Opportunity opp : this.newOppList) {

            String optyName = '';
            if (opp.First_Name__c != null)
                optyName = opp.First_Name__c + ConstantsUtility.BLANK_SPACE;
            if (opp.Middle_Name__c != null)
                optyName += opp.Middle_Name__c + ConstantsUtility.BLANK_SPACE;
            if (opp.Last_Name__c != null)
                optyName += opp.Last_Name__c + ConstantsUtility.BLANK_SPACE;
            if(opp.BillTo_Name__c == null)
                opp.BillTo_Name__c = optyName;
            if(opp.BillTo_First_Name__c == null && opp.First_Name__c != null)
                opp.BillTo_First_Name__c = opp.First_Name__c;
            if(opp.BillTo_Middle_Name__c == null && opp.Middle_Name__c != null)
                opp.BillTo_Middle_Name__c = opp.Middle_Name__c;
            if(opp.BillTo_Last_Name__c == null && opp.Last_Name__c != null)
                opp.BillTo_Last_Name__c = opp.Last_Name__c;
            opp.Name = optyName;

            opp.Name += ConstantsUtility.OPEN_BRACKET + enqType + ConstantsUtility.CLOSE_BRACKET;

            if(opp.Dealership_Channel__c == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS){
                opp.Name = opp.Name.replace(ConstantsUtility.NEWCAR_ENQ, ConstantsUtility.NEW_Vehicle_ENQ);
            }
            // Added in R1.2 Phase 2 development for fast view dashboard By: Mahith
            if(trigger.IsUpdate && this.oldOppMap.get( opp.Id ).Invoice_Number__c != this.newOppMap.get( opp.Id ).Invoice_Number__c){
                opp.Delivery_Checklist_Sent__c = null;
                opp.Delivery_Checklist_Time__c   = null;
            }

            //whenever Gate_Pass_Date__c is null and StageName equals to Retail
            if (opp.Gate_Pass_Date__c != null && opp.StageName == ConstantsUtility.RETAIL_NAME && (trigger.isInsert || (trigger.IsUpdate && this.oldOppMap.get(opp.Id).Gate_Pass_Date__c == null))) {
                opp.StageName = ConstantsUtility.DEL_CLOSED_WON_NAME;
                opp.CloseDate = System.today();
            }            

            //whenever stage is changing from new to PreBooking or Booking
            if (trigger.isUpdate && opp.StageName == ConstantsUtility.STAGE_NEW && (this.oldOppMap.get(opp.id).StageName == ConstantsUtility.STAGE_PREBOOKING || this.oldOppMap.get(opp.id).StageName == ConstantsUtility.STAGE_BOOKING)) {
                opp.Pre_Booking_Number__c = null;
                opp.Booking_Number__c = null;
                opp.Pre_booking_Submission_Date__c = null;
            }
             //Whenever Enquiry Color is populated first time
            if(opp.Color__c!=null && (trigger.IsInsert || (trigger.isUpdate && this.oldOppMap.get(opp.id).Color__c!=null && this.oldOppMap.get(opp.id).Color_Captured_Time__c==null))) // Added by Navin on 20/04/2020 due to Stop to update Color Captured time field change in sfdc.
                opp.Color_Captured_Time__c = DateTime.now();


            // Added by Gitika Khandelwal 13th April 2020 for Validation of Refree Details
            // Added By Anuj: Commercial Impact on Loyaylty on 21 May 2020

            if(opp.Referred_By_Mobile_Number__c != Null &&  // removed opp.Referred_By_Loyalty_Card_Number__c != Null &&
                opp.LeadSource != ConstantsUtility.ENQUIRY_SOURCE_WEBSITE && (trigger.isInsert ||
                (trigger.isUpdate && opp.Referred_By_Mobile_Number__c != this.oldOppMap.get(opp.id).Referred_By_Mobile_Number__c))) {
                    loyaltyCardMobileNoMap.put(opp.Referred_By_Mobile_Number__c, null);
            }

            /** Update the Stage Name based on the Loyalty DMS Enrollment ID */
            if(opp.Loyalty_DMS_Enrollment_ID__c !=null && opp.Loyalty_DMS_Enrollment_ID__c!=this.oldOppMap.get(opp.Id).Loyalty_DMS_Enrollment_ID__c){
                opp.StageName = ConstantsUtility.OPP_STAGE_PENDING_ENROLLMENT_CONST;
                OppidWithLoyaltyDMSid.put(opp.id,opp.Loyalty_DMS_Enrollment_ID__c);
            }

        }

        //Populate the Loyalty Card Number on the Loyalty FollowUps
        if(OppidWithLoyaltyDMSid.size()>0){
            for(Task tsk :[Select id,Loyalty_card_number__c,whatid from task where whatid in :OppidWithLoyaltyDMSid.keyset()]){
                if(tsk.Status !='Completed' && tsk.Loyalty_card_number__c != OppidWithLoyaltyDMSid.get(tsk.whatid)){
                    ListTaskToUpdate.add(new Task (id = tsk.id,Loyalty_card_number__c=OppidWithLoyaltyDMSid.get(tsk.whatid)));
                }
            }
            if(ListTaskToUpdate.size()>0)
                update ListTaskToUpdate;
        }

    Custom_Validation_Exception_Setting__c customValid = Custom_Validation_Exception_Setting__c.getOrgDefaults();
        //Populate Referral Details
        if (customValid.Referral_Logic_Run__c && !loyaltyCardMobileNoMap.isEmpty() ) { // removed && !loyaltyCardNoMap.isEmpty()

            for (Account acc : [Select id,Name, Referred_By__c, Loyalty_Card_Number__c, PersonEmail, PersonMobilePhone, COMM_Loyalty_Card_Number__c
                                from Account where recordTypeId =: customerRecordTypeId
                                 AND Phone_txt__c IN:loyaltyCardMobileNoMap.keySet()]){ // Updated PersonMobilePhone to Phone_txt__c and removed And (Loyalty_Card_Number__c IN:loyaltyCardNoMap.keySet()

                 if (loyaltyCardMobileNoMap.containskey(acc.PersonMobilePhone)) {
                     loyaltyCardMobileNoMap.put(acc.PersonMobilePhone, acc);
                 }
             }


            if(loyaltyCardMobileNoMap!=null && loyaltyCardMobileNoMap.size()>0) {
                for (Opportunity opp : this.newOppList) {

                    Account acc;
                    if(opp.Mobile__c!=null && opp.Referred_By_Mobile_Number__c != null && opp.Mobile__c==opp.Referred_By_Mobile_Number__c){
                        opp.addError(ConstantsUtility.REFREE_MOBILE_AND_CURRENT_MOBILE_SAME_ERROR);
                    }
                    else if (loyaltyCardMobileNoMap.containsKey(opp.Referred_By_Mobile_Number__c) && loyaltyCardMobileNoMap.get(opp.Referred_By_Mobile_Number__c) != Null) {

                        acc = loyaltyCardMobileNoMap.get(opp.Referred_By_Mobile_Number__c);

                        opp.Referred_By__c = (acc != Null && acc.Name != Null) ? acc.Name : null;
                        opp.Referred_by_Email__c = (acc != Null && acc.PersonEmail != Null) ? acc.PersonEmail : null;

                        if(opp.Loyalty_Program_Type__c == ConstantsUtility.COMMERCIAL_PROGRAM_TYPE){
                            opp.Referred_By_Loyalty_Card_Number__c = (acc != Null && acc.COMM_Loyalty_Card_Number__c != Null) ? acc.COMM_Loyalty_Card_Number__c: opp.Referred_By_Loyalty_Card_Number__c;
                            opp.Referred_By_Loyalty_Card_Mobile_Number__c =(acc != Null && acc.COMM_Loyalty_Card_Number__c!= Null) ? (acc.PersonMobilePhone != Null ? acc.PersonMobilePhone : null):opp.Referred_By_Loyalty_Card_Mobile_Number__c;
                            opp.Reference_Type__c= (acc != Null && acc.COMM_Loyalty_Card_Number__c!= Null) ? ConstantsUtility.ENQUIRY_REFERENCE_LOYALTY :ConstantsUtility.ENQUIRY_REFERENCE_OTHERS;
                        }else{
                            opp.Referred_By_Loyalty_Card_Number__c = (acc != Null && acc.Loyalty_Card_Number__c != Null) ? acc.Loyalty_Card_Number__c : opp.Referred_By_Loyalty_Card_Number__c;
                            opp.Referred_By_Loyalty_Card_Mobile_Number__c =(acc != Null && acc.Loyalty_Card_Number__c != Null) ? (acc.PersonMobilePhone != Null ? acc.PersonMobilePhone : null) : opp.Referred_By_Loyalty_Card_Mobile_Number__c;
                            opp.Reference_Type__c= (acc != Null && acc.Loyalty_Card_Number__c != Null) ? ConstantsUtility.ENQUIRY_REFERENCE_LOYALTY : ConstantsUtility.ENQUIRY_REFERENCE_OTHERS;
                        }
                        opp.LeadSource =ConstantsUtility.ENQUIRY_SOURCE_REFERENCE;

                    }
                }
            }
        }

    }


    /**
        Author: Prabhat Sharma
        Description: Creates MC Communication records if DSE is allocated or a DSE is untagged from an Enquiry
        Returns: void
        History:
        Last Modified By: Prabhat Sharma 04 Oct 2019
        ====================================================
        1.0  04 Oct 2019  Prabhat Sharma  Initial Version
        1.1  14 Oct 2019  Prabhat Sharma  Added Logic for Untagged DSE MC Notification
        1.2  30 Jun 2019  Anuj Kumar      Call from Async class
  **/
    public void createMCrecordsOnDSEAllocationOrUntagging(Boolean isInsert, Boolean isUpdate) {
        //Set to have Opportunity Ids if Owner is a DSE
        set<Id> userIdSet = new set<Id>();
        //set to have filtered Opportunity Ids where owner is DSE
        set<Id> dseAllocationOppIdSet = new set<Id>();
        //set to have filtered Opportunity Ids where DSE is untagged
        set<Id> dseUntaggedOppIdSet = new set<Id>();


        for (Opportunity opp : this.newOppList) {
            //Check if owner has changed
            if (isInsert || (isUpdate && ((opp.OwnerId != this.oldOppMap.get(opp.id).OwnerId)))) {
                userIdSet.add(opp.OwnerId);
                if (isUpdate) {
                    userIdSet.add(this.oldOppMap.get(opp.id).OwnerId);
                }
            }
        }

        if (userIdSet.size() > 0) {
            Map<Id, User> userIdMap = new map<Id, User>([SELECT Id,Title,Profile.Name FROM User WHERE Id in:userIdSet]);

            //Loop through all new/old Opportunity
            for (Opportunity opp : this.newOppList) {
                //Check for DSE Allocation to an Enquiry
                if (userIdMap.containsKey(opp.OwnerId) && String.isNotBlank(userIdMap.get(opp.OwnerId).Profile.Name) && userIdMap.get(opp.OwnerId).Profile.Name == ConstantsUtility.DSE_PROFILE_NAME) {
                    dseAllocationOppIdSet.add(opp.Id);
                }
                //Check for DSE Untagged
                if (isUpdate && userIdMap.containsKey(this.oldOppMap.get(opp.id).OwnerId) &&
                    String.isNotBlank(userIdMap.get(this.oldOppMap.get(opp.id).OwnerId).Profile.Name) &&
                    userIdMap.get(this.oldOppMap.get(opp.id).OwnerId).Profile.Name == ConstantsUtility.DSE_PROFILE_NAME) {
                        dseUntaggedOppIdSet.add(opp.Id);
                    }
            }

            //Create Marketing communication records for DSE Allocation
            if (dseAllocationOppIdSet.size() > 0) {
                GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.DSE_ALLOCATION, dseAllocationOppIdSet, ConstantsUtility.OPPORTUNITY, '');
            }

            //Create Marketing communication records for Untagged DSEs
            if (dseUntaggedOppIdSet.size() > 0) {
                GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.DSE_UNTAGGED, dseUntaggedOppIdSet, ConstantsUtility.OPPORTUNITY, '');
            }
        }
    }

     /**
        Author: Zakir
        Description:  if the enquiry stage is "Retail" then all the related Task will be closed .
        Returns: void
        History:
        Last Modified By: Rohit  13-02-2020
        ====================================================

  **/
   public void closedFollowup() {
      String MuleUserId = MuleUserRecordId;
      String CurrentUserId = UserInfo.getUserId();
            Boolean IsPreBooking = false;
            Set<Id> opportunityIdSet = new Set<Id>();
            for (Opportunity opp : this.newOppList) {
                if(this.oldOppMap.get(opp.Id).StageName != opp.StageName && ((opp.stageName == ConstantsUtility.RETAIL_NAME && MuleUserId == CurrentUserId) || opp.stageName == ConstantsUtility.STAGE_CLOSELOST))
                {
                        opportunityIdSet.add(opp.id);
                }
            }
            if(opportunityIdSet.size() > 0 && !System.isFuture() && !System.isBatch())
            {
                closeFollowups(opportunityIdSet,IsPreBooking);
            }

    }

    /**
        Author: Rohit
        Description: Close all the Pre booking followups when enquiry stage changes to Booking
        Returns: void
        History:
        Last Modified By:

  **/
   public void closePreBookingFollowups(){
     String MuleUserId = MuleUserRecordId;
        String CurrentUserId = UserInfo.getUserId();
        Boolean IsPreBooking = true;
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Opportunity opp: this.newOppList){
            if(MuleUserId == CurrentUserId && opp.StageName == ConstantsUtility.STAGE_BOOKING && this.oldOppMap.get(opp.Id).StageName != opp.StageName){
                opportunityIdSet.add(opp.Id);
            }
        }
        if(opportunityIdSet.size() > 0 && !System.isFuture() && !System.isBatch())
        {
        closeFollowups(opportunityIdSet,IsPreBooking);
        }
    }



    /**
        Author: Rahul Raghunathan
        Description: To be called during before insert to copy over from Customer onto Opportuniyy.
        Returns: void
        History:
        Last Modified By: Rahul 08 October 2019
        ====================================================
        1.0  Rahul 08 October 2019  Initial Version
  **/
    public void updateCustomerAttributes(String addressFieldType, Integer firstFieldIndex) {

        try {
            set<id> customerIdSet = new set<id>();//vairable to store the customer IDs.

            for (Opportunity opp : this.newOppList) {
                //If the customer if not blank then add the Ids.
                if (opp.customer__c != null) {
                    customerIdSet.add(opp.Customer__c);
                }
            }


            //Fetch the customer details if the customers have been populated,
            if (customerIdSet.size() > 0) {

                //Map for key as Opportunity field and value as Account field
                map<String, String> optyAcctFieldMap = new map<String, String>();

                String query = 'SELECT Id,';

                //Loop through custom metadata type to get all the fields
                //Builds SOQL string for query
                for (Customer_Attribute_Mapping__mdt fields : [SELECT Account_Field_API__c,Opportunity_Field_API__c FROM Customer_Attribute_Mapping__mdt]) {
                    query += fields.Account_Field_API__c + ConstantsUtility.COMMA;
                    if (fields.Opportunity_Field_API__c != Null) {
                        optyAcctFieldMap.put(fields.Opportunity_Field_API__c, fields.Account_Field_API__c);
                    }
                }


                query = query.removeEnd(ConstantsUtility.COMMA);
                query += ' FROM Account WHERE Id in: customerIdSet';

                map<Id, Account> customerMap = new map<Id, Account>((List<Account>) Database.query(query));

                for (Opportunity opp : this.newOppList) {
                    Account acc = customerMap.get(opp.customer__c);

                    //Loop through all the fields and map it with Opportuntiy fields
                    for (String field : optyAcctFieldMap.keySet()) {
                        String acctField = optyAcctFieldMap.get(field);
                        if (acc != null && opp.get(field) == null) {
                            opp.put(field, acc.get(acctField));
                        }
                    }

                    //Copying address from Customer to Enquiry
                    if (opp.customer__c != null) {
                        copyAccountAddress(opp.recordTypeId, opp, acc, addressFieldType, firstFieldIndex);
                    }


                }
            }
        } catch (Exception ex) {
            ExceptionHandler.LogError('OpportunityTriggerHandler - updateCustomerAttributes', ex.getMessage(), 'Opportunity', null, null); throw new unexpectedException('An exception has occurred. Please contact your salesfore administrator');
        }
    }


    /**
        Author: Anuj Kumar
        Description: To be called during before insert case to count the variant changes on Opportunity.
        Returns: void
        History:
        Last Modified By: Anuj (11 Nov 2019)
        ====================================================
        1.0  Anuj 11 Nov 2019      Initial Version
  **/
     public opportunity copyAccountAddress(String recordTypeId, Opportunity opp, Account acc, String addressFieldType, Integer firstFieldIndex) {
        system.debug('copyAccountAddress******* OpportunityTriggerHandler_Strategy');
        Integer billingStreetLength = acc.BillingStreet != Null ? acc.BillingStreet.length() : ConstantsUtility.ZERO;

        return updateAddressFields(addressFieldType, billingStreetLength, firstFieldIndex, opp, acc);

    }


    /**
        Author: Anuj Kumar
        Description: To be called during before insert case to count the variant changes on Opportunity.
        Returns: void
        History:
        Last Modified By: Anuj (11 Nov 2019)
        ====================================================
        1.0  Anuj 11 Nov 2019      Initial Version
  **/
    public static opportunity updateAddressFields(string firstField, Integer billingStreetLength, Integer firstFieldIndex, Opportunity opp, Account acc) {

        if (billingStreetLength > firstFieldIndex) {
            opp.put(firstField, acc.BillingStreet.subString(ConstantsUtility.ZERO, firstFieldIndex));

            if (billingStreetLength >= (firstFieldIndex + ConstantsUtility.THIRTY)) {
                opp.BillTo_Address_Line_2__c = acc.BillingStreet.subString(firstFieldIndex, firstFieldIndex + ConstantsUtility.THIRTY);
            } else if ((billingStreetLength > firstFieldIndex) && (billingStreetLength < (firstFieldIndex + ConstantsUtility.THIRTY))) {
                opp.BillTo_Address_Line_2__c = acc.BillingStreet.subString(firstFieldIndex, billingStreetLength);
            }

            if (billingStreetLength >= (firstFieldIndex + ConstantsUtility.SIXTY)) {
                opp.BillTo_Address_Line_3__c = acc.BillingStreet.subString(firstFieldIndex + ConstantsUtility.THIRTY, firstFieldIndex + ConstantsUtility.SIXTY);
            } else if ((billingStreetLength > (firstFieldIndex + ConstantsUtility.THIRTY)) && (billingStreetLength < (firstFieldIndex + ConstantsUtility.SIXTY))) {
                opp.BillTo_Address_Line_3__c = acc.BillingStreet.subString(ConstantsUtility.SIXTY, billingStreetLength);
            }
        } else {
            opp.put(firstField, acc.BillingStreet);
        }

        return opp;
    }


    /**
        Author: Anuj Kumar
        Description: To be called during before insert case to count the variant changes on Opportunity.
        Returns: void
        History:
        Last Modified By: Anuj (11 Nov 2019)
        ====================================================
        1.0  Anuj 11 Nov 2019      Initial Version
  **/
    public void populateVariantChangesCount() {

        List<String> profileNameList = system.label.By_Pass_Variant_Changes != Null ?
            system.label.By_Pass_Variant_Changes.split(';') :
        new List<String>();

        List<User> userInfo = currentUserList;

        for (opportunity opp : this.newOppList) {
            if (this.oldOppMap == Null && opp.Variant__c != Null) {
                opp.Variant_Modified_Count__c = 1;
            } else if (this.oldOppMap != Null && this.newOppList != Null) {

                if (userInfo != Null && profileNameList != Null && !profileNameList.contains(userInfo[0].Profile.Name)) {

                    Integer countLimit = system.label.Restrict_variant_count_limit != Null ? Integer.valueOf(system.label.Restrict_variant_count_limit) : 0;
                    if (this.oldOppMap.get(opp.Id).Variant__c != opp.Variant__c && opp.Variant_Modified_Count__c > countLimit) {
                        opp.addError(system.label.Variant_Changes_Count_Msg);
                    } else if (opp.Variant__c != Null && this.oldOppMap.get(opp.Id).Variant__c != opp.Variant__c) {
                        opp.Variant_Modified_Count__c = opp.Variant_Modified_Count__c != null ? opp.Variant_Modified_Count__c + 1 : 1;
                    }
                }
            }
        }

    }
    /**
        Author: Subhojit Chakraborty
        Description: To be called during before insert case to insert dummy account if account is not populated
        Returns: void

        ====================================================
        1.0  Subhojit     10 Dec 2019      Initial Version
        1.1  Anuj Kumar   30 Jun 2020      Second Version - Call from Async class
  **/
    public void createDummyAccountOnOpportunity() {
        try {
            Map<Opportunity, Account> mapOppNewDummyAccount = new Map<Opportunity, Account>();
            String sCustomerrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.CUSTOMER_RECORDTYPE).getRecordTypeId();
            for (Opportunity oppVar : this.newOppList) {
                if (oppVar.Customer__c == null) {
                    Account accVar = new Account();
                    accVar.RecordtypeId = sCustomerrecTypeId;
                    accVar.FirstName = oppVar.First_Name__c;
                    accVar.LastName = oppVar.Last_Name__c;
                    if (accVar.LastName == null)
                        accVar.LastName = '.';
                    accVar.PersonEmail = oppVar.Email__c;
                    accVar.PersonMobilePhone = oppVar.Mobile__c;
                    accVar.Status__c = ConstantsUtility.PROSPECT_CUSTOMER;
                    accVar.PersonBirthDate = oppVar.Birthdate__c;
                    accvar.OwnerId = system.label.Integration_User;
                    accvar.SFMC_Sync__c = True;
                    accvar.Enquiry_Exists__pc = True;
                    mapOppNewDummyAccount.put(oppVar, accVar);
                }
            }
            if (mapOppNewDummyAccount.size() > 0) {
                insert mapOppNewDummyAccount.values();

                for (Opportunity oppVar : mapOppNewDummyAccount.keySet()){
                    oppVar.Customer__c = mapOppNewDummyAccount.get(oppVar).Id;
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('OpportunityTriggerHandler createDummyAccountOnOpportunity', e.getMessage(), 'OpportunityTriggerHandler', '', null);
        }
    }

    /**
        Author: Anuj Kumar
        Description: Populated default value on enquiry field on the basis on recordType
        Returns: void

        ====================================================
        1.0  Anuj Kumar   30 Jun 2020      First Version
    **/
    public void updateFollowupDetailsOnEnquiry(String type, Integer reminderTime){

        for (Opportunity oppVar : this.newOppList){
            oppVar.Current_Follow_Up_Time__c =  Datetime.now().addMinutes(reminderTime);
            oppVar.Current_Follow_Up_Type__c = type;
        }
    }

    /**
        Author: Rahul Raghunathan
        Description: Method to prevent the update from stage to New when in prebooking by Mulesoft User.
        Returns: void

        ====================================================
        1.0  Rahul Raghunathan  06 Jan 2020      Initial Version
  **/

    public void preventWrongStageChange() {

        //Check if the new stage is new and previous stage is present in custom setting AvoidStageChanges,
        //then revert the change. Avoidstagechanges will hold stage name in a pattern of :<stagename>:
        Custom_Validation_Exception_Setting__c currSetting = Custom_Validation_Exception_Setting__c.getInstance(userInfo.getUserId());
        String preventStages = 'none';
        if (currSetting != null) {
            preventStages = currSetting.AvoidStageChanges__c;
        }

        if (preventStages != null) {
            for (Opportunity opp : this.newOppList) {
                if ((opp.stageName == 'New') && preventStages != null && this.oldOppMap.get(opp.id) != null && this.oldOppMap.get(opp.id).StageName != 'New'
                    && (preventStages.contains(':' + this.oldOppMap.get(opp.id).StageName + ':'))) {
                        opp.stageName = this.oldOppMap.get(opp.id).StageName;
                    }
            }
        }

    }

    /**
        Author: Rahul Sharma
        Company: MSIL
        Description: Method to set default gender and customer type
        Inputs: None
        Returns: void
  **/
    public void updateGenderAndCustomerType() {
        String MuleUserId = MuleUserRecordId;
        String CurrentUserId = UserInfo.getUserId();

        //Loop through Opportunities
        for (Opportunity opp : this.newOppList) {
            if (opp.Gender__c == null)
                opp.Gender__c = 'M';
            if (opp.Customer_Type__c == null)
                opp.Customer_Type__c = 'I';

            //functionality to update 'If other Employees' field if user is Mule and 'Employer Name' is 'Others'
            if (MuleUserId == CurrentUserId && opp.Employer_Name__c != null && opp.Employer_Name__c == Label.Other_Employer_Id && opp.If_Other_Employers__c == null) {
                opp.If_Other_Employers__c = ConstantsUtility.OTHER_VALUE;
            }

            if (trigger.isUpdate && opp.Line_Of_Business__c == null && opp.Temporary_LOB_Admin_use__c != null) {
                opp.Line_Of_Business__c = opp.Temporary_LOB_Admin_use__c;
            }
       //Adding code to capture DMS created time when DMS number present on enq @Rahul Sharma
            if((trigger.isInsert && opp.DMS_Enquiry_Name__c != null && opp.DMS_Created_Date__c == null) || (trigger.isUpdate && opp.DMS_Enquiry_Name__c != null && opp.DMS_Created_Date__c == null && opp.DMS_Enquiry_Name__c != this.oldOppMap.get(opp.id).DMS_Enquiry_Name__c) )
            {
               DateTime dt = DateTime.now();
               opp.DMS_Created_Date__c = date.newinstance(dt.year(), dt.month(), dt.day());
            }

            //functionality to update enquiry created date when enquiry created in sf @Rahul Sharma/MSIL
            if(trigger.isInsert && opp.enq_created_date__c == null && MuleUserId != CurrentUserId)
            {
                opp.enq_created_date__c = DateTime.Now();
            }
            //functionality to update request to lost date @Rahul Sharma/MSIL
            if(trigger.isUpdate && opp.Is_Request_To_Lost__c == true && opp.Request_to_lost_date__c == null && opp.StageName != 'Closed Lost')
            {
                opp.Request_to_lost_date__c = DateTime.Now();
            }

            //functionality to update first home visit date @Rahul Sharma/MSIL
            if(trigger.isUpdate && opp.Home_Visit_Date__c  == null && opp.Previous_Follow_Up_Type__c != null && this.oldOppMap.get(opp.id).Previous_Follow_Up_Type__c  != opp.Previous_Follow_Up_Type__c)
            {
                String followupType = (opp.Previous_Follow_Up_Type__c).substring(0,1);
                if(followupType == 'V')
                    opp.Home_Visit_Date__c = DateTime.Now();
            }
        }
    }
     /**
    Author: Rohit Gupta
    Company: Techmatrix
    Description:
    Inputs: None
    Returns: void
    **/
     /*
    public void changeEnquiryStagePreBookingToNew(){
        system.debug('jfhjf');
        String MuleUserId = [select id from user where name =: ConstantsUtility.DMS_USER].ID;
        String CurrentUserId = UserInfo.getUserId();
        for(Opportunity opportunity: this.newOppList){
        system.debug('jfhjf');
            if(MuleUserId == CurrentUserId && opportunity.StageName == ConstantsUtility.STAGE_PREBOOKING && opportunity.StageName != ConstantsUtility.STAGE_NEW && opportunity.DMS_Enquiry_Name__c != null &&
               opportunity.DMS_Sync_Error__c != null && String.IsBlank(opportunity.Pre_Booking_Number__c) && String.IsBlank(opportunity.Pre_Booking_Status__c)){

                  opportunity.StageName = ConstantsUtility.STAGE_NEW;
                  opportunity.Pre_booking_Submission_Date__c = null;
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput= new ConnectApi.MarkupBeginSegmentInput();
                    markupBeginSegmentInput.markupType=ConnectApi.MarkupType.PARAGRAPH;
                    ConnectApi.MarkupEndSegmentInput markupEndSegment;
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput.id = opportunity.OwnerId;
                    messageBodyInput.messageSegments.add(markupBeginSegmentInput);
                    //messageBodyInput.messageSegments.add(mentionSegmentInput);
                    textSegmentInput.text = ' System is busy, please click on pre booking again\n\t';
                    messageBodyInput.messageSegments.add(textSegmentInput);
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
                    markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                    markupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
                    messageBodyInput.messageSegments.add(markupEndSegment);
                    System.debug('@@## '+messageBodyInput);
                    feedItemInput.body = messageBodyInput;
                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                    feedItemInput.subjectId = opportunity.Id;
                    feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkid(), feedItemInput);
                    system.debug(' 1487 rahul debug '+ feedElement );
             }
        }
    }*/

     /**
    Author: Satish Kumar
    Company: Maruti
    Description:
    Inputs: None
    Returns: void
    **/

    public void changeBookingAndRetailDate(){
        for(Opportunity opp : this.newOppList){
            if(((this.oldOppMap.get(opp.id).Booking_Date__c) != (this.newOppMap.get(opp.id).Booking_Date__c))
               ||((this.oldOppMap.get(opp.id).Booking_Cancellation_Date__c) != (this.newOppMap.get(opp.id).Booking_Cancellation_Date__c ))
               ||((this.oldOppMap.get(opp.id).Retail_Cancellation_Date__c) != (this.newOppMap.get(opp.id).Retail_Cancellation_Date__c ))
               ||((this.oldOppMap.get(opp.id).Retail_Completed_Date__c) != (this.newOppMap.get(opp.id).Retail_Completed_Date__c ) ))
            {
                if((this.oldOppMap.get(opp.id).Booking_Date__c) > (this.newOppMap.get(opp.id).Booking_Date__c)
                  ){
                      opp.Booking_Date__c=this.oldOppMap.get(opp.id).Booking_Date__c;
                  }
                if((this.oldOppMap.get(opp.id).Retail_Completed_Date__c) > (this.newOppMap.get(opp.id).Retail_Completed_Date__c )){
                    opp.Retail_Completed_Date__c=this.oldOppMap.get(opp.id).Retail_Completed_Date__c;
                }
            }
        }
    }


    /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Send chatter notification to enq owner , when employer status is pending for approval in DMS
    **/

    public void notifyEnqOwnerAboutEmployerStatus(){
        Map<Id, Id> ownerManagerMap = new Map<Id, Id>();
        //for(Opportunity opp : [Select Id,OwnerId,Owner.ManagerId From Opportunity where id in: trigger.newmap.keyset()])
        for(Opportunity opp : [Select Id,OwnerId,Owner.ManagerId From Opportunity where id in: this.newOppMap.keySet()])
        {
            ownerManagerMap.put(opp.OwnerId,opp.Owner.ManagerId);
        }
        String MuleUserId = MuleUserRecordId;
        String CurrentUserId = UserInfo.getUserId();
        String error;
        for(Opportunity opportunity: this.newOppList){

            if(opportunity.DMS_Sync_Error_Details__c == null){
                error = 'abc';
            }else{
                error  =  opportunity.DMS_Sync_Error_Details__c;
            }

        if(MuleUserId == CurrentUserId && ownerManagerMap.containsKey(opportunity.OwnerId) ==  true && ownerManagerMap.get(opportunity.OwnerId) != null && ((opportunity.StageName == ConstantsUtility.STAGE_PREBOOKING && opportunity.Pre_Booking_Number__c == null) || (opportunity.StageName == ConstantsUtility.STAGE_NEW  && opportunity.DMS_Enquiry_Name__c == null)) && (error.contains('EMPLOYEE APPROVAL STATUS IS PENDING FOR USERID:')||error.contains('DEALER DETAIL NOT AVAILABLE FOR USERID:'))){

                opportunity.StageName = ConstantsUtility.STAGE_NEW;
                opportunity.Pre_booking_Submission_Date__c = null;
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentInput.markupType=ConnectApi.MarkupType.PARAGRAPH;
                ConnectApi.MarkupEndSegmentInput markupEndSegment;
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                system.debug('manager id'+ownerManagerMap.get(opportunity.OwnerId));
                mentionSegmentInput.id = ownerManagerMap.get(opportunity.OwnerId);
                messageBodyInput.messageSegments.add(markupBeginSegmentInput);
                textSegmentInput.text = 'Enquiry DSE Status is pending for approval in DMS, please get it approved then create enquiries in salesforce. And Then retry already created enquiries or assign it to some other DSE.';
                messageBodyInput.messageSegments.add(textSegmentInput);
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
                messageBodyInput.messageSegments.add(markupEndSegment);
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = opportunity.Id;
                feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkid(), feedItemInput);
            }
        }
    }

  /**
    Author: Satish Kumar
    Company: MSIL
    Description: Capture lastmodified date in cdc custom setting
    **/

public  void insertAndUpdateTimeOnCDC(){
        List<CDC_TimeSet__c> mcs=CDC_TimeSet__c.getAll().values();
        Boolean isUpdate = false;
        DateTime lastModifiedTime;
         DateTime myDateTime;
        if(mcs.size()>0){
             myDateTime=mcs[0].TimeSetUp__c;
        }

        for(Opportunity opp : this.newOppList)
        {
                if(myDateTime ==null){
                    isUpdate = true;
                    lastModifiedTime = opp.LastModifiedDate;
                }
                else
                {
                    DateTime newDateTime = myDateTime.addHours(24);
                    if(opp.LastModifiedDate>newDateTime)
                    {
                        isUpdate = true;
                        lastModifiedTime = opp.LastModifiedDate;
                    }
               }

        }
        if(isUpdate == true && lastModifiedTime != null && mcs.size()>0 )
        {
             mcs[0].TimeSetUp__c=lastModifiedTime ;
             update mcs[0];
        }
    }

/**
    Author: Rahul Sharma
    Company: MSIL
    Description: Retry Enquiry If DMS no not present for 3 times and wont trigger if its a data error return from DMS
    **/
    public  void retriggerEnquiry(){
        system.debug('1767 $$ ');
        String MuleUserId = MuleUserRecordId;
        String CurrentUserId = UserInfo.getUserId();
        list<String> dmsErrors = new list<String>();
        list<String> dmsErrorsSet = (Label.MSIL_DMSError).split(',');
        list<String> dmsErrorsSet2 = (Label.MSIL_DMSError_2).split(',');
        list<String> dmsErrorsSet3 = (Label.MSIL_DMSError_3).split(',');
        for(String str : dmsErrorsSet)
            dmsErrors.add(str);
        for(String str : dmsErrorsSet2)
            dmsErrors.add(str);
        for(String str : dmsErrorsSet3)
            dmsErrors.add(str);
        system.debug('dmsErrors --  '+dmsErrors);
        Set<String> oppIds= new set<String>();
        String error;
        for(Opportunity opportunity: this.newOppList)
        {
            Integer count = Integer.valueOf(opportunity.Enquiry_Retry_Count__c);
            Integer count1 = Integer.valueOf(opportunity.Pre_Booking_Retry_Count__c);
            if(count == null)
                count = 0;
            if(count1 == null)
                count1 = 0;
            if(opportunity.DMS_Sync_Error_Details__c != null)
            {
                error = opportunity.DMS_Sync_Error_Details__c;
            if(error.contains(':') == true)
                error = error.substringBefore(':');
            }
            system.debug('error '+error );
            if(MuleUserId == CurrentUserId && error != null && opportunity.Variant__c != null && (!dmsErrors.contains(error)) && ((opportunity.StageName == ConstantsUtility.STAGE_NEW && opportunity.DMS_Enquiry_Name__c == null  &&  count < 3) || (opportunity.StageName == ConstantsUtility.STAGE_PREBOOKING && opportunity.Pre_Booking_Number__c == null && opportunity.Pre_booking_Submission_Date__c != null  &&  count1 < 3)))
            {
                system.debug('error '+error );
                oppIds.add(opportunity.Id);
                }
        }
        List<SF_Retry_Custom_Setting__c> retrySettings=SF_Retry_Custom_Setting__c.getAll().values();
        system.debug('error '+retrySettings[0].Retry__c);
        if(!oppIds.IsEmpty() && retrySettings[0].Retry__c == true && !System.isFuture() && !System.isBatch())
        {
            system.debug('error '+retrySettings[0].Retry__c);
            retriggerEnquiryAsyn(oppIds);
            }
    }



    /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Retry Enquiry If DMS no not present for 3 times and wont trigger if its a data error return from DMS
    **/
    @Future(callout=true)
    public Static void retriggerEnquiryAsyn(set<String> oppIds){

                List<Opportunity> oppLst = [Select Id,Enquiry_Retry_Count__c,StageName,Pre_Booking_Retry_Count__c from Opportunity where id in: oppIds];
                List<SF_Retry_Custom_Setting__c> retrySettings=SF_Retry_Custom_Setting__c.getAll().values();

                //Login call
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('SOAPAction', '""');
                req.setHeader('Accept', 'text/xml');
                req.setHeader('Content-Type','text/xml;charset=utf-8');
                req.setMethod('POST');
                req.setEndpoint(retrySettings[0].LoginEndPoint__c);
                req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + retrySettings[0].UserName__c + '</username><password>' + retrySettings[0].PassWord__c + '</password></login></Body></Envelope>');
                Dom.XmlNode resultElmt = (h.send(req).getBodyDocument().getRootElement()
                .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse','urn:partner.soap.sforce.com')
                .getChildElement('result','urn:partner.soap.sforce.com'));

                String res = resultElmt.getChildElement('sessionId','urn:partner.soap.sforce.com').getText();
                if(res != null)
                {
                    List<retryBodyRequest> brLst = new List<retryBodyRequest>();
                    String Stage='';
                    for(Opportunity opp : oppLst)
                    {    
                        Integer count;
                        if(opp.StageName == ConstantsUtility.STAGE_NEW)
                        {
                        Stage=opp.StageName;
                        count = Integer.valueOf(opp.Enquiry_Retry_Count__c);
                        if(count == null)
                            count = 0;
                        count+=1;
                        }
                        else if(opp.StageName == ConstantsUtility.STAGE_PREBOOKING)
                        {
                        Stage=opp.StageName;
                         count = Integer.valueOf(opp.Pre_Booking_Retry_Count__c);
                        if(count == null)
                            count = 0;
                        count+=1;
                        }
                        retryBody b = new retryBody(count);
                        String method = 'PATCH';
                        String url = '/services/data/v48.0/sobjects/Opportunity/'+opp.Id;
                        String referenceId = opp.Id;
                        retryBody body = b;
                        retryBodyRequest br = new retryBodyRequest(method,url,referenceId,body);
                        system.debug('1804 $$ ' + br);
                        brLst.add(br);
                    }
                    List<retryBodyRequest> rec = new List<retryBodyRequest>(brLst);
                    records br = new records(rec);
                    String strBodyOpp = JSON.serialize(br);
                    if(Stage == ConstantsUtility.STAGE_NEW)
                        strBodyOpp = strBodyOpp.replace('count','Enquiry_Retry_Count__c');
                    else if(Stage == ConstantsUtility.STAGE_PREBOOKING)
                        strBodyOpp = strBodyOpp.replace('count','Pre_Booking_Retry_Count__c');
                    Http h1 = new Http();
                    HttpRequest req1 = new HttpRequest();
                    req1.setHeader('Authorization', 'OAuth ' + res);
                    req1.setHeader('Content-Type', 'application/json');
                    req1.setEndpoint(retrySettings[0].updatePatchEndPoint__c+'composite');
                    req1.setBody(strBodyOpp);
                    req1.setMethod('POST');
                    HttpResponse res1 = h1.send(req1);
                    String strResponse = res1.getBody();
                }
            }


    /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Retry Enquiry If DMS no not present for 3 times and wont trigger if its a data error return from DMS
    **/
        public class retryBodyRequest{
            public string method;
            public string url;
            public string referenceId;
            public retryBody body;

            public retryBodyRequest(String method,String url,string referenceId,retryBody body){
                this.method = method;
                this.url = url;
                this.referenceId = referenceId;
                this.body= body;
            }
        }

    /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Retry Enquiry If DMS no not present for 3 times and wont trigger if its a data error return from DMS
    **/
        public class retryBody{
            public Integer count;

            public retryBody(Integer count){
                this.count = count;
            }
        }

     /**
    Author: Rahul Sharma
    Company: MSIL
    Description: Retry Enquiry If DMS no not present for 3 times and wont trigger if its a data error return from DMS
    **/
        public class records{
            public List<retryBodyRequest> compositeRequest;

            public records(List<retryBodyRequest> compositeRequest){
                this.compositeRequest = compositeRequest;
            }
        }

        /**
        Author: Deepak Kumar -
        Company: Techmatrix
        Description: Method to check for Account's Teir based on SVOC ID and update the INterested In Loyalty and called from updateFieldsUsingSVOCID
        Returns: void
        History:
        ====================================================
        1.0     16 April 2020  Deepak Kumar  Initial Version
    **/
    public static Opportunity polulateInterestedInLoyalty(Opportunity opportunity,Account account) {
        ConstantsUtility constantsUtilityIns = new ConstantsUtility();
        if(String.isNotEmpty(opportunity.Dealership_Channel__c) && opportunity.Dealership_Channel__c == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS){
            if (account.COMM_Tier__c != null) {
                opportunity.Interested_In_Loyalty__c =  constantsUtilityIns.HasLoyaltyConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            } else if (account.COMM_Loyalty_Card_Number__c != null) {
                opportunity.Interested_In_Loyalty__c = constantsUtilityIns.EnrolledInLoyaltyConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            } else if (account.COMM_Tier__c == null && opportunity.Interested_In_Loyalty__c == constantsUtilityIns.HasLoyaltyConst) {
                opportunity.Interested_In_Loyalty__c = constantsUtilityIns.NotPitchedConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            } else if (account.COMM_Loyalty_Card_Number__c == null && opportunity.Interested_In_Loyalty__c == constantsUtilityIns.EnrolledInLoyaltyConst) {
                opportunity.Interested_In_Loyalty__c = constantsUtilityIns.NotPitchedConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            }
        }else{
            if (account.Tier__c != null) {
                opportunity.Interested_In_Loyalty__c =  constantsUtilityIns.HasLoyaltyConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            } else if (account.Loyalty_Card_Number__c != null) {
                opportunity.Interested_In_Loyalty__c = constantsUtilityIns.EnrolledInLoyaltyConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            } else if (account.Tier__c == null && opportunity.Interested_In_Loyalty__c == constantsUtilityIns.HasLoyaltyConst) {
                opportunity.Interested_In_Loyalty__c = constantsUtilityIns.NotPitchedConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            } else if (account.Loyalty_Card_Number__c == null && opportunity.Interested_In_Loyalty__c == constantsUtilityIns.EnrolledInLoyaltyConst) {
                opportunity.Interested_In_Loyalty__c = constantsUtilityIns.NotPitchedConst;
                opportunity.Reason_not_Interested_in_Loyalty__c=NULL;
            }
         }
        return opportunity;
    }

   /*
    Author: Rahul Sharma
    Company: MSIL
    Description: Check for uniqueness of enquiry and send error with 18 digit id in case of duplicate
    Returns: void
    */
    public void uniquenessCheck(){

        map<String,Opportunity> newOppWithExternalId = new map<String,Opportunity>();
        map<String,String> oppIdWithExternalId = new map<String,String>();
        set<String> dealershipIds = new set<string>();
        set<String> sfIds = new set<string>();
        for (Opportunity opp : this.newOppList){
            if(opp.Dealership__c!=null)
                dealershipIds.add(opp.Dealership__c);
        }

        //Query the dealership details
            Map<Id,Account> dealershipMap = new Map<Id,Account>([SELECT Id,Dealer_Map_Code__c,Dealer_Location__c,Parent_Group__c,For_Code__c,For_Code__r.For_Code__c,Dealer_Code__c,
                                                                 Dealer_Comp_FA__c FROM Account WHERE Id in: dealershipIds]);

        for(opportunity opty : this.newOppList)
        {
            if (string.isNotBlank(opty.DMS_Enquiry_Name__c)){
                if(dealershipMap.size() > 0)
                {
                String externalId = dealershipMap.get(opty.Dealership__c).Parent_Group__c+
                        '_'+dealershipMap.get(opty.Dealership__c).Dealer_Map_Code__c+
                        '_'+dealershipMap.get(opty.Dealership__c).Dealer_Location__c+
                        '_'+opty.DMS_Enquiry_Name__c;
                newOppWithExternalId.put(externalId,opty);
                }
                if(trigger.isUpdate && string.isNotBlank(opty.Id))
                    sfIds.add(opty.Id);
            }
        }

        if(newOppWithExternalId.size() > 0)
        {
            List<Opportunity> lstOpp = new List<Opportunity>();
            if(trigger.isUpdate)
               lstOpp = [Select id,External_Id__c  from opportunity where External_Id__c in: newOppWithExternalId.keySet() and id not in: sfIds];
            else
               lstOpp = [Select id,External_Id__c  from opportunity where External_Id__c in: newOppWithExternalId.keySet()];
            if(!lstOpp.IsEmpty())
            {
                for(Opportunity opp : lstOpp)
                {
                    oppIdWithExternalId.put(opp.External_Id__c,opp.Id);

                }

                for(String str : newOppWithExternalId.keySet())
                {
                    if(oppIdWithExternalId.containsKey(str))
                    {
                        String error = 'Duplicate Record Found, Existing record id is : ' + oppIdWithExternalId.get(str);
                        (newOppWithExternalId.get(str)).addError(error);
                    }
                }

            }
        }
    }

    /**
        Author: Saloni Gupta
        Description: populate msds corporate code value
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    09 June 2020  Saloni Gupta  Initial Version
    **/
    public void populateMSDSFieldsValues(Boolean isInsert, Boolean isUpdate){
        system.debug('populateMSDSCorporateCode******* OpportunityTriggerHandler_Strategy');

        List<Id> corporateIdList = new List<Id>();
        Map<Id,String> corpIdvsCodeMap = new Map<Id,String>();

        for(Opportunity opp : this.newOppList){
            if(isUpdate && opp.StageName == 'Enrolled' && opp.Birthdate__c != null && opp.Enrollment_Date__c != null &&
              (opp.Birthdate__c != this.oldOppMap.get(opp.Id).Birthdate__c || opp.Enrollment_Date__c != this.oldOppMap.get(opp.Id).Enrollment_Date__c || opp.Age_on_Date_of_Enrollment__c == null)){
                  Integer days = opp.Birthdate__c.daysBetween(opp.Enrollment_Date__c);
                  opp.Age_on_Date_of_Enrollment__c= Integer.valueOf(days/365);

                if(opp.Age_on_Date_of_Enrollment__c >= 60){
                      opp.Age_Group__c = ConstantsUtility.Age_60_plus;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 55){
                        opp.Age_Group__c = ConstantsUtility.Age_55_to_60;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 50){
                        opp.Age_Group__c = ConstantsUtility.Age_50_to_55;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 45){
                        opp.Age_Group__c = ConstantsUtility.Age_45_to_50;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 40){
                        opp.Age_Group__c = ConstantsUtility.Age_40_to_45;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 35){
                        opp.Age_Group__c = ConstantsUtility.Age_35_to_40;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 30){
                        opp.Age_Group__c = ConstantsUtility.Age_30_to_35;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 25){
                        opp.Age_Group__c = ConstantsUtility.Age_25_to_30;
                }else if(opp.Age_on_Date_of_Enrollment__c >= 18){
                        opp.Age_Group__c = ConstantsUtility.Age_18_to_25;
                }

            }
            if(opp.Corporate_Name__c != null){
                corporateIdList.add(opp.Corporate_Name__c);
            }
            opp.Enquiry_Mode__c = ConstantsUtility.MSDS;
        }

        for(MSDS_Corporate__c corp : [select id,Corporate_Code__c from MSDS_Corporate__c where Id IN:corporateIdList AND Corporate_Code__c != null]){
            corpIdvsCodeMap.put(corp.Id,corp.Corporate_Code__c);
        }

        for(Opportunity opp : this.newOppList){
            if(corpIdvsCodeMap.containsKey(opp.Corporate_Name__c)){
                opp.Corporate_Code__c = corpIdvsCodeMap.get(opp.Corporate_Name__c);
            }

        }
    }

    /**
        Author: Saloni Gupta
        Description: check course value of msds enquiry
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    08 June 2020  Saloni Gupta  Initial Version
    **/
    public void checkCourseOnEnquiry(){
        system.debug('checkCourseOnEnquiry******* OpportunityTriggerHandler_Strategy');

        List<Opportunity> courseOppList = new List<Opportunity>();
        Map<Id,Id> oppIdvsCourseMap = new Map<Id,Id>();
        Map<Id,List<Course_Rollout__c>> mapCourseIdvsRollupList = new Map<Id,List<Course_Rollout__c>>();

        for(Opportunity opp :[select id, recordTypeId,Dealership__c, Dealership__r.For_Code__c, Dealership__r.For_Code__r.City_Code__c, Dealership__r.For_Code__r.Region_Code__c,
                                Dealership__r.For_Code__r.State_Code__c, Dealership__r.For_Code__r.Zone_Code__c, Customer_Type__c, Course__c,Course__r.RecordTypeId,Course__r.isVAS__c,Course__r.Category__c
                                from Opportunity where id IN: this.newOppList AND Course__c != null ]){
            system.debug('opp----'+opp);
            if(!opp.Course__r.isVAS__c &&
                opp.Course__r.RecordTypeId == msdsCourseRecordTypeId &&
                ((opp.Customer_Type__c == ConstantsUtility.Corporate_CustomerType && (opp.Course__r.Category__c == ConstantsUtility.All_Category  || opp.Course__r.Category__c  == ConstantsUtility.Corporate_Category)) ||
                (opp.Customer_Type__c == ConstantsUtility.Individual_CustomerType && (opp.Course__r.Category__c == ConstantsUtility.All_Category  || opp.Course__r.Category__c  == ConstantsUtility.Individual_Category)))){

                    if(opp.Dealership__c != null && opp.Dealership__r.For_Code__c != null){
                        oppIdvsCourseMap.put(opp.Id,opp.Course__c);
                        courseOppList.add(opp);
                    }
                    system.debug('courseOppList---'+courseOppList);
            }else{
                this.newOppMap.get(opp.Id).addError(System.Label.MSDSSelectedCourseErrorForType);
            }
        }
        if(!courseOppList.isEmpty()){
            for(Course_Rollout__c courseRolloutObj : [select Id,Product__c,Start_Date__c,End_Date__c,All_Region__c,All_State__c,All_Zone__c,City_Code__c,Region_Code__c,State_Code__c,
                                                    Zone_Code__c from Course_Rollout__c  where Product__c IN: oppIdvsCourseMap.values() AND Start_Date__c <= today AND End_Date__c > today ]){
                if(!mapCourseIdvsRollupList.containskey(courseRolloutObj.Product__c)){
                    mapCourseIdvsRollupList.put(courseRolloutObj.Product__c,new List<Course_Rollout__c>());
                }
                mapCourseIdvsRollupList.get(courseRolloutObj.Product__c).add(courseRolloutObj);
            }
            System.debug('mapCourseIdvsRollupList----'+mapCourseIdvsRollupList);
            for(Opportunity opp: courseOppList){
                Boolean ShowError = true;
                List<Course_Rollout__c> courseRolloutList= new List<Course_Rollout__c>();

                if(mapCourseIdvsRollupList.containsKey(opp.Course__c)){

                    courseRolloutList = mapCourseIdvsRollupList.get(opp.Course__c);
                    for(Course_Rollout__c rolloutObj : courseRolloutList){

                        if((opp.Dealership__r.For_Code__r.City_Code__c == rolloutObj.City_Code__c || rolloutObj.City_Code__c == ConstantsUtility.All) &&
                        (opp.Dealership__r.For_Code__r.State_Code__c == rolloutObj.State_Code__c || rolloutObj.All_State__c == true) &&
                        (opp.Dealership__r.For_Code__r.Region_Code__c == rolloutObj.Region_Code__c || rolloutObj.All_Region__c == true) &&
                        (opp.Dealership__r.For_Code__r.Zone_Code__c == rolloutObj.Zone_Code__c || rolloutObj.All_Zone__c == true) ){

                            ShowError = false;
                            break;
                        }
                    }

                    if(ShowError){
                        this.newOppMap.get(opp.Id).addError(System.Label.MSDSSelectedCourseErrorForLocation);
                    }
                }else{
                    this.newOppMap.get(opp.Id).addError(System.Label.MSDSSelectedCourseErrorForExpire);
                }


            }

        }
    }

    /**
        Author: Saloni Gupta
        Description: create Preliminary Checklist related to acctive RFC
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    15 May 2020  Saloni Gupta  Initial Version
        1.1    10 Aug 2020  Saloni Gupta  Add the conditions for Active Preliminary Checklist
        **/

      public void createPreliminaryChecklist(){

        List<Id> oppList = new List<Id>();
        Map<Id,RFC__c> oppIdVsRfc = new Map<Id,RFC__c>();
        List<RFC__c> rfcList = new List<RFC__c>();
        List<Preliminary_Checklist__c> checkList = new List<Preliminary_Checklist__c>();
        List<Preliminary_Checklist__c> updateCheckList = new List<Preliminary_Checklist__c>();


        for(Opportunity opp : this.newOppList){
            if(opp.Dealership_Channel__c != ConstantsUtility.COMMERCIAL_CHANNEL){
                oppList.add(opp.Id);
            }
        }
        if(!oppList.isEmpty()){

            for(RFC__c rfcObj : [select Id,Active__c, Enquiry__c ,(select id,rfc__c from Preliminary_Checklists__r where Active__c = true) from RFC__c where Active__c=true AND Enquiry__c IN:oppList]){
                oppIdVsRfc.put(rfcObj.Enquiry__c,rfcObj);
            }


            if(!oppIdVsRfc.isEmpty()){

                for(Id oppId :oppIdVsRfc.keyset()){
                    Boolean isDealloted = false;
                    Boolean isPcCreate = false;
                    RFC__c rfcObj = new RFC__c();
                    rfcObj.Id = oppIdVsRfc.get(oppId).Id;
                    rfcObj.VIN_Number__c = this.newOppMap.get(oppId).VIN__c;

                    if(this.newOppMap.get(oppId).Allotment_Status__c !=this.oldOppMap.get(oppId).Allotment_Status__c && this.newOppMap.get(oppId).VIN__c != null && this.newOppMap.get(oppId).Allotment_Status__c == ConstantsUtility.Allotted){
                        rfcObj.RFC_Status__c = ConstantsUtility.Allotted;
                        rfcObj.Allotment_Status__c = ConstantsUtility.Allotted;
                        rfcObj.Vehicle_Receiving_Date__c = system.now();
                        isPcCreate = true;

                    }else if(this.newOppMap.get(oppId).Allotment_Status__c !=this.oldOppMap.get(oppId).Allotment_Status__c && this.newOppMap.get(oppId).Allotment_Status__c == ConstantsUtility.DeAllotted){
                        rfcObj.RFC_Status__c = ConstantsUtility.DeAllotted;
                        rfcObj.Allotment_Status__c = ConstantsUtility.DeAllotted;
                        rfcObj.Vehicle_Receiving_Date__c = null;
                        isDealloted = true;

                    }else if((this.oldOppMap.get(oppId).StageName == ConstantsUtility.STAGE_BOOKING || this.oldOppMap.get(oppId).StageName == ConstantsUtility.RETAIL_NAME) &&
                                this.newOppMap.get(oppId).StageName == ConstantsUtility.STAGE_NEW){
                        rfcObj.RFC_Status__c = 'Canceled';
                        rfcObj.RFC_Cancellation_Reason__c = 'RFC Has been Canceled becasue stage is changed to booking or retail';
                        rfcObj.Active__c = false;
                        rfcObj.Allotment_Status__c = null;
                    }
                    rfcList.add(rfcObj);

                    if(oppIdVsRfc.get(oppId).Preliminary_Checklists__r.size() == 0 && isPcCreate == true){
                        Preliminary_Checklist__c checkObj = new Preliminary_Checklist__c();
                        checkObj.RFC__c = oppIdVsRfc.get(oppId).Id;
                        checkObj.Enquiry__c = oppId;
                        checkList.add(checkObj);
                    }else if(oppIdVsRfc.get(oppId).Preliminary_Checklists__r.size() > 0 && isDealloted == true){
                        Preliminary_Checklist__c checkObj = new Preliminary_Checklist__c();
                        checkObj.Id = oppIdVsRfc.get(oppId).Preliminary_Checklists__r[0].Id;
                        checkObj.Active__c = false;
                        updateCheckList.add(checkObj);
                    }
                }
            }
        }

        if(!rfcList.isEmpty()){
            update rfcList;
        }
        if(!checkList.isEmpty()){
            insert checkList;
        }
        if(!updateCheckList.isEmpty()){
            update updateCheckList;
        }
    }

     /**
        Author: Saloni Gupta
        Description: Booking or Retail gets canceled, the respective RFC will also be marked as canceled and inactive
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    21 May 2020  Saloni Gupta  Initial Version
        us860 : Booking/Retail Cancelation - RFC Cancel
    **/
    public void canceledActiveRFC(){
        Set<Id> oppIdSet = new Set<Id>();
        List<RFC__c> rfcList = new List<RFC__c>();
        for(Opportunity opp : this.newOppList){
            if(opp.stageName == ConstantsUtility.STAGE_CLOSELOST && this.oldOppMap.get(opp.Id).stageName != ConstantsUtility.STAGE_CLOSELOST){
                oppIdSet.add(opp.Id);
            }
        }
        if(!oppIdSet.isEmpty()){

            for(RFC__c rfcObj  : [select Id,Active__c, Enquiry__c from RFC__c where Active__c=true AND Enquiry__c IN:oppIdSet]){
                rfcObj.Active__c = false;
                rfcObj.RFC_Status__c = 'Canceled';
                rfcList.add(rfcObj);
            }

            if(!rfcList.isEmpty()){
                update rfcList;
            }
        }
    }
     /**
        Author: Saloni Gupta
        Description: populate followup fields for MSDS
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    16 July 2020  Saloni Gupta  Initial Version
    **/
    public void polulateFollowupMSDSField(){
        for(Opportunity oppObj : this.newOppList){
            oppObj.Current_Follow_Up_Enquiry_Action__c = ConstantsUtility.MSDS_FOLLOWUP_STAGE;
            oppObj.Current_Follow_Up_Enquiry_Status__c = ConstantsUtility.MSDS_FOLLOWUP_STATUS;
        }

    }

    /**
        Author: Saloni Gupta
        Description: check the selected vehicle is unavailable at the Dealership
        Returns: void
        History:
        Last Modified By:
        ====================================================
        1.0    15 July 2020  Saloni Gupta  Initial Version
    **/
    public void checkSelectedVehicle(String testDriveAssetRecordTypeId){

        for(Opportunity opp : [select Id, Preferred_Training_Vehicle__c, Preferred_Training_Vehicle__r.AccountId, Dealership__c, Preferred_Training_Vehicle__r.RecordTypeId from opportunity where Id IN:this.newOppList AND Preferred_Training_Vehicle__c != null]){
            if(opp.Dealership__c != opp.Preferred_Training_Vehicle__r.AccountId || opp.Preferred_Training_Vehicle__r.RecordTypeId != testDriveAssetRecordTypeId){
                 this.newOppMap.get(opp.Id).addError(System.Label.MSDSSelectedVehicleError);
            }
        }
    }
    /** 
     * Author: Rohit Gupta
     * Company: Techmatrix
     * Description: Method to update Accessories enquiries owner' coming from DMS owner to ACM 
     * */
    public void changeMSGAEnquiryOwnerToACM(){

       String MuleUserId = [select id from user where name =: ConstantsUtility.DMS_USER].ID;
     // String MuleUserId = [select id from user where name ='Admin DMS'].ID;
        // Set to store Dealership Account Ids
        Set<String> dealershipIdSet = new Set<String>();
        // Map to store Dealership Account ID as Key and list of ACM Ids as values
        Map<String, List<String>> ACMMap = new Map<String, List<String>>();

        String accessoryManager = ConstantsUtility.ACCESSORY_MANAGER;

        for(Opportunity opportunity: this.newOppList){
            if(opportunity.OwnerId == MuleUserId && opportunity.RecordTypeId == accessoriesSalesId){
                if(opportunity.Dealership__c != null){
                    dealershipIdSet.add(opportunity.Dealership__c);
                }
            }
        }
        if(dealershipIdSet.size() > 0){
            for(User user : [SELECT id, contact.AccountId FROM USER WHERE contact.AccountId IN :dealershipIdSet AND Designation__c = :accessoryManager  AND IsActive = true ]){
                if(ACMMap.containsKey(user.contact.AccountId)){
                    List<String> ACMList = ACMMap.get(user.contact.AccountId);
                    ACMList.add(user.Id);
                    ACMMap.put(user.contact.AccountId, ACMList);
                }else{
                    ACMMap.put(user.contact.AccountId, new List<String> {user.Id});
                }
            }

            for(Opportunity opportunity: this.newOppList){
                if(opportunity.OwnerId == MuleUserId && opportunity.RecordTypeId == accessoriesSalesId){
                    if(ACMMap.containsKey(Opportunity.Dealership__c)){
                        if(ACMMap.get(Opportunity.Dealership__c).size() > 0){
                            opportunity.OwnerId = ACMMap.get(opportunity.Dealership__c)[0];   
                        }                        
                    }                
                }
            }
        }       
    }

      /*
    Author: Rahul Sharma
    Company: MSIL
    Description: functionality to update owner of related open activities to the new enquiry owner
    Returns: void
    */
    public void updateRelatedOpenActivity(){
        String MuleUserId = MuleUserRecordId;
        String CurrentUserId = UserInfo.getUserId();
        map<Id,String> oppwithOwner = new map<Id,String>();
        //Loop through Opportunities
        for (Opportunity opp : this.newOppList) {
            if (MuleUserId == CurrentUserId && oldOppMap.get(opp.id).OwnerId != opp.OwnerId){
                oppwithOwner.put(opp.Id,opp.OwnerId);
            }
        }

        List<Task> tskLst = [Select id,OwnerId,WhatId from Task where whatid in: oppwithOwner.keyset() And Status =: ConstantsUtility.STATUS_OPEN];
        List<Task> tkLst = new List<Task>();
        if(tskLst.size()>0)
        {
            for(Task tk : tskLst)
            {
                if(oppwithOwner.containsKey(tk.WhatId))
                {
                    Task tsk = new Task(id=tk.id,OwnerId=oppwithOwner.get(tk.WhatId));
                    tkLst.add(tsk);
                }
            }
            if(tkLst.size() > 0)
            {
                TriggerHandler.bypass('OpportunityTriggerHandler');
                update tkLst;
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
            }
        }
    }

     
            /**
        Author: Rahul Sharma
        Description: Close all the followups when enquiry stage changes to Booking/Retail/Closed Lost in seperate transaction to avoid enquiry update fail due task unable to lock row error.
        Group: MSIL
        Returns: void
        History:
        Last Modified By:

    **/
    @future
    public static void closeFollowups(set<Id> oppIds, Boolean IsPreBooking)
    {
    List<Task> taskList = new List<Task>();
    List<Task> taskList1 = new List<Task>();
    if(oppIds.size() > 0)
    {
        if(IsPreBooking == true)
        {
            taskList1 = [SELECT Id, Status, WhatId, Enquiry_Scoring__c FROM TASK WHERE WhatId IN: oppIds AND Status =: ConstantsUtility.STATUS_OPEN AND RecordType.Name =: ConstantsUtility.PRE_BOOKING_FOLLOWUP ORDER BY OWNERID];
        }
        else
        {
            taskList1 = [SELECT Id, Status, WhatId, Enquiry_Scoring__c FROM TASK WHERE WhatId IN: oppIds AND Status =: ConstantsUtility.STATUS_OPEN ORDER BY OWNERID];
        }
      if(taskList1.size() > 0)
      {
        for(Task task: taskList1)
        {
          task.Status = ConstantsUtility.STATUS_COMPLETED;
          if(IsPreBooking == false && task.Enquiry_Scoring__c == null || String.isEmpty(task.Enquiry_Scoring__c)){
            task.Enquiry_Scoring__c = 'P';
          }
          taskList.add(task);
        }
        if(taskList.size() > 0 )
        {
          TriggerHandler.bypass('TaskTriggerHandler');
          update taskList;
          TriggerHandler.clearBypass('TaskTriggerHandler');
        }
      }
    }
    }
    
    /*
    Author: Rahul Sharma
    Company: MSIL
    Description: Compare incoming external id with old external id, if same then only update can happen
    Returns: void
    */
    public void checkExternalId(){
        String MuleUserId = MuleUserRecordId;
        String CurrentUserId = UserInfo.getUserId();
        map<Id,String> oppwithOwner = new map<Id,String>();
        //Loop through Opportunities
        for (Opportunity opp : this.newOppList) {
            if (MuleUserId == CurrentUserId && opp.External_id__c  != null && oldOppMap.get(opp.id).DMS_Enquiry_Name__c != null && oldOppMap.get(opp.id).External_id__c != null && oldOppMap.get(opp.id).External_id__c != opp.External_id__c){
                String error = 'SF Id and External Id Combination is not matching, External id is : ' + oldOppMap.get(opp.id).External_id__c + ' against sf id : '+opp.Id;
                opp.addError(error);
            }
        }
    }
    
     /**
        Author: Rahul Sharma
        Company: MSIL
        Description: Assign Enq with mode as NAV to dealer hostess and assign rest hostess to enq team 
    **/
    public void assignNAVEnquirytoHostess() {
        Set<String> dealerAccountIds = new Set<String>();

        for (Opportunity opp : this.newOppList) {
            if (UserInfo.getUserId() == label.Integration_User && opp.Dealership__c != null && (opp.DMS_Enq_Mode__c == 'Nav Portal' || opp.DMS_Enq_Mode__c == 'NAV')) 
            {
                String dealId = opp.Dealership__c;
                dealId = dealId.substring(0, 15); 
                dealerAccountIds.add(dealId);
            }
        }
        map<String,set<String>> dealerHostessMap = new map<String,set<String>>();
        set<String> hostessIds = new set<String>();
        
        if (dealerAccountIds.size() > 0) {
            for (User usr : [SELECT Id,Dealer_Account__c FROM User WHERE Dealer_Account__c IN:dealerAccountIds and IsActive = true and Profile.Name =: 'Dealer Hostess']) {
                if(!dealerHostessMap.containskey(usr.Dealer_Account__c))
                {
                    hostessIds.add(usr.Id);
                    dealerHostessMap.put(usr.Dealer_Account__c,hostessIds);
                }
                else
                {
                    Set<String> hostessIds1 = dealerHostessMap.get(usr.Dealer_Account__c);
                    hostessIds1.add(usr.Id);
                    dealerHostessMap.remove(usr.Dealer_Account__c);
                    dealerHostessMap.put(usr.Dealer_Account__c,hostessIds1);
                }
            }
            if(dealerHostessMap.size() > 0)
            {
                for (Opportunity opty : this.newOppList) {
                    if(UserInfo.getUserId() == label.Integration_User && opty.OwnerId == label.Integration_User && (opty.DMS_Enq_Mode__c == 'Nav Portal' || opty.DMS_Enq_Mode__c == 'NAV')){
                        String dealId = opty.Dealership__c;
                        dealId = dealId.substring(0, 15); 
                        if (dealerHostessMap.containsKey(dealId) && dealerHostessMap.get(dealId).size() > 0) {
                            List<String> spocUserList = new List<String>(dealerHostessMap.get(dealId));
                            if (spocUserList.size() > 1) {
                                opty.OwnerId = RandomUtility.findRandomStringFromList(spocUserList);
                            } else if (spocUserList.size() == 1) {
                                opty.OwnerId = spocUserList[0];
                            }
                        }
                    }
                }
            }
        }
    }
    
           /**
        Author: Rahul Sharma
        Company: MSIL
        Description: Assign Enq with mode as NAV to dealer hostess and assign rest hostess to enq team 
    **/
    public void assignNAVEnquiryToRestofDealerHostess() {
        system.debug('inside assignNAVEnquiryToRestofDealerHostess');
        Set<String> dealerAccountIds = new Set<String>();

        for (Opportunity opp : this.newOppList) {
             system.debug('opp is '+opp.Dealership__c + opp.DMS_Enq_Mode__c + opp);
            if (UserInfo.getUserId() == label.Integration_User && opp.Dealership__c != null && (opp.DMS_Enq_Mode__c == 'Nav Portal' || opp.DMS_Enq_Mode__c == 'NAV')) 
            {
                String dealId = opp.Dealership__c;
                dealId = dealId.substring(0, 15); 
                dealerAccountIds.add(dealId);
            }
        }
        system.debug('dealerAccountIds'+dealerAccountIds);
        map<String,set<String>> dealerHostessMap = new map<String,set<String>>();
        set<String> hostessIds = new set<String>();
        List<OpportunityTeamMember> OppTMems = new List<OpportunityTeamMember>();
        List<OpportunityShare> OppShareLst = new List<OpportunityShare>();
        if (dealerAccountIds.size() > 0) {
            for (User usr : [SELECT Id,Dealer_Account__c FROM User WHERE Dealer_Account__c IN:dealerAccountIds and IsActive = true and Profile.Name =: 'Dealer Hostess']) {
                if(!dealerHostessMap.containskey(usr.Dealer_Account__c))
                {
                    hostessIds.add(usr.Id);
                    dealerHostessMap.put(usr.Dealer_Account__c,hostessIds);
                }
                else
                {
                    Set<String> hostessIds1 = dealerHostessMap.get(usr.Dealer_Account__c);
                    hostessIds1.add(usr.Id);
                    dealerHostessMap.remove(usr.Dealer_Account__c);
                    dealerHostessMap.put(usr.Dealer_Account__c,hostessIds1);
                }
            }
            system.debug('dealerHostessMap'+dealerHostessMap);
            if(dealerHostessMap.size() > 0)
            {
            for (Opportunity opty : this.newOppList) {
                if(UserInfo.getUserId() == label.Integration_User && (opty.DMS_Enq_Mode__c == 'Nav Portal' || opty.DMS_Enq_Mode__c == 'NAV')){
                    String dealId = opty.Dealership__c;
                    dealId = dealId.substring(0, 15); 
                    if (dealerHostessMap.containsKey(dealId) && dealerHostessMap.get(dealId).size() > 0) {
                        system.debug('dealerHostessMap'+dealerHostessMap.get(dealId));
                        List<String> spocUserList = new List<String>(dealerHostessMap.get(dealId));
                        if (spocUserList.size() > 1) {
                            system.debug('dealerHostessMap'+spocUserList.size());    
                            for(Integer i=0;i<spocUserList.size();i++)
                            {
                                if(spocUserList[i] != opty.OwnerId)
                                {
                                    /* OpportunityTeamMember otm = new OpportunityTeamMember();
                                    otm.OpportunityId = opty.Id;
                                    otm.UserId = (Id)spocUserList[i];
                                    OppTMems.add(otm);*/
                                    OpportunityShare os = new OpportunityShare();
                                    os.OpportunityId = opty.Id;
                                    os.UserOrGroupId = (Id)spocUserList[i];
                                    os.RowCause = Schema.OpportunityShare.RowCause.Manual;
                                    os.OpportunityAccessLevel = 'Edit';
                                    OppShareLst.add(os);
                                }
                            }
                        } 
                    }
                }
            }
            }
            system.debug('OppShareLst'+OppShareLst);
            if(!OppShareLst.IsEmpty())
                insert OppShareLst;
           /* system.debug('OppTMems'+OppTMems);
            if(!OppTMems.IsEmpty())
                insert OppTMems;*/
        }
    }


    /**
        Author: Anuj Kumar
        Description: create Suzuki Connect Lineitem 
        Returns: void
        History:
        Last Modified By: Anuj (30 Oct 2020)
        ====================================================
        1.0  Anuj 11 Nov 2019      Initial Version
     **/
     
    public void createSuzukiConnectLineitem() {
        String productName = 'TELEMATICS UNIT';
        
        Map<String, OpportunityLineItem> oppIdWithLineItemMap = new Map<String, OpportunityLineItem>();
        for(Opportunity opp : this.newOppList){
            if(opp.RecordTypeId == accessoriesSalesId && opp.Suzuki_Connect__c){
                oppIdWithLineItemMap.put(opp.Id, new OpportunityLineItem());
            }
        }
        
        if(!oppIdWithLineItemMap.isEmpty()){
            string accProdId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_LINEOFBUSINESS).getRecordTypeId();

            List<Product2> products = [Select id, name, (Select id, unitPrice from priceBookEntries where isActive = true) 
                    from Product2 where recordTypeId =: accProdId AND Name =: productName ];
            
            
            if(!products.isEmpty()){
                for(String oppId : oppIdWithLineItemMap.keySet()){
                    
                    oppIdWithLineItemMap.put(oppId, new OpportunityLineItem(opportunityId = oppId, priceBookEntryId = products[0].priceBookEntries[0].Id, 
                        UnitPrice = products[0].priceBookEntries[0].UnitPrice, Quantity = 1));
                }
                
                if(!oppIdWithLineItemMap.values().isEmpty()){
                    insert oppIdWithLineItemMap.values();
                }
            }
        }
        
    }
    
    /**
        Author: Shaikh Mufiz
        Company: Techmatrix
        Description: Method to assign Ownership of Enquiry(Opportunity) to Accessories SPOC(s) when Enquiry(Opportunity) is of Accessories Sales Record Type and Enquiry(Opportunity) owner is Integration user.
        We will fetch Sales SPOC(s) from the Dealership field on Enquiry(Opportunity).
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     04 Jan 2021 Shaikh Mufiz  Initial Version
    **/
    public void assignEnquirytoAccessoriesSPOC() {
        //Set to add Dealership from Enquiry(Opportunity).
        Set<Id> dealerAccountIds = new Set<Id>();
        
        // Map to add Account Id and Sales SPOC(s) User Ids.
        Map<Id, set<String>> accessoriesSpocUserIdsMap = new Map<Id, set<String>>();
        
        //Dealer Channel Account Map
        //Map<Id, Account> accountChannelMap = new Map<Id, Account>();
        
        //get profile Ids of ATM CallCenter Users
        String atmProfileIds = Label.ATM_Profiles;
        boolean isATMCreated = atmProfileIds.contains(UserInfo.getProfileId());
        
        //Loop through all new Opportunities
        for (Opportunity opp : this.newOppList) {
            if ((UserInfo.getUserId() == label.Integration_User || isATMCreated) && opp.Dealership__c != null && (opp.LeadSource == 'CRM' || opp.LeadSource == 'ATM'))
                dealerAccountIds.add(opp.Dealership__c);
        }
        //Query Accessories SPOCs on Dealer(Account)
        if (dealerAccountIds.size() > 0) {
            for (Account accountObj : [SELECT Id, Accessories_SPOC_1__c, Accessories_SPOC_2__c FROM Account 
                                       WHERE Id IN : dealerAccountIds]) {
                                           // Set to add Accessories SPOC(s) User Ids.
                                           Set<String> accessoriesSpocIds = new Set<String>();
                                           if (String.isNotBlank(accountObj.Accessories_SPOC_1__c))
                                               accessoriesSpocIds.add(accountObj.Accessories_SPOC_1__c);
                                           if (String.isNotBlank(accountObj.Accessories_SPOC_2__c))
                                               accessoriesSpocIds.add(accountObj.Accessories_SPOC_2__c);
                                           
                                           //Fill the Map with Dealer(Account) and Accessories SPOC(s) User Ids.
                                           accessoriesSpocUserIdsMap.put(accountObj.Id, accessoriesSpocIds);
                                       }
            
            List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
            //Assign Enquiry(Opportunity) Owner from Integration user to Accessories SPOC(s)
            for (Opportunity opty : this.newOppList) {
                if(isATMCreated || (UserInfo.getUserId() == label.Integration_User && opty.OwnerId == label.Integration_User)){
                    if (accessoriesSpocUserIdsMap.containsKey(opty.Dealership__c) && accessoriesSpocUserIdsMap.get(opty.Dealership__c).size() > 0) {
                        
                        //assign a random dealer as an enquiry owner
                        List<String> spocUserList = new List<String>(accessoriesSpocUserIdsMap.get(opty.Dealership__c));
                        
                        //Added check for size because Random Utility was failing to size =1
                        if (spocUserList.size() > 1) {
                            opty.OwnerId = RandomUtility.findRandomStringFromList(spocUserList);
                        } else if (spocUserList.size() == 1) {
                            opty.OwnerId = spocUserList[0];
                        }
                        opportunitiesForUpdate.add(opty);
                    }
                }
            }
            //Assign the list to a static variable for trigger after event to get the Enquiry Ids and create MC records
            if (opportunitiesForUpdate.size() > 0) {
                OpportunityTriggerHelper.spocOptyList = opportunitiesForUpdate;
            }
        }
    } 

}