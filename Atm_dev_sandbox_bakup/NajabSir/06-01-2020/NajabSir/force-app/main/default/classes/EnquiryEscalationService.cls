public with sharing class EnquiryEscalationService {
    public EnquiryEscalationService() {}


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to update Escaltion fields on Enquiry based on which Escaltion will happen.
        Returns: void
        History:
        ====================================================
        1.0     22 Jul 2019  Prabhat Sharma  Initial Version 
    **/
    public void escalationFieldUpdates(List<Opportunity> triggerNewList, Map<Id,Opportunity> triggerOldMap){
        //Map to have the user id and user details as key value
        Map<Id,User> opportunityOwnerIdTitleMap = new Map<Id,User>();
        
        //set to store Dealership Ids
        set<Id> dealershipIds = new set<Id>();

        
        //Loop through trigger.new and create a map
        //In case of insert, if owner is not integration user
        //In case of update, either enquiry is escalated or owner has been changed
        for(Opportunity oppty : triggerNewList){
            if(oppty.OwnerID!=label.Integration_User && 
                (trigger.isInsert || (trigger.isUpdate && (oppty.Escalated__c || oppty.OwnerId!=triggerOldMap.get(oppty.Id).OwnerId)))){
                opportunityOwnerIdTitleMap.put(oppty.OwnerId,null);
                dealershipIds.add(oppty.Dealership__c);
            }
        }
        
        
        if(opportunityOwnerIdTitleMap.keySet().size()>0){
            
            //Map to store custom setting values
            map<String,Enquiry_Escalations__c> escalationMap = new map<String,Enquiry_Escalations__c>();
            
            //Get all details from Escalation custom settings
            Map<String, Enquiry_Escalations__c> escalations = Enquiry_Escalations__c.getAll();
            List<String> allEscalations = new List<String>();
            allEscalations.addAll(escalations.keySet());
            
            //Loop through custom setting details and seperte details for Maruti generated and Dealer generated enquiries
            for (String esc : allEscalations) {
                Enquiry_Escalations__c  escalate = escalations.get(esc);
                //Create a unique key
                String str = escalate.Source__c+' '+escalate.Name;
                escalationMap.put(str,escalate);
            }
            
            //Get the possible enquiry sources for Maruti generated enquiries
            set<String> marutiGeneratedEnquiries = new set<String>();
            marutiGeneratedEnquiries.addAll(label.Maruti_Generated_Enquiries.split(';'));
            
            //Get the recordtype Id for Vehicle Sales Enquiry 
            String vehicleSalesRecordTypeId = OpportunityTriggerHandler.vehicleSalesId;


            //Get the user titles,profiles of the Owner Ids
            for(User us : [SELECT Id,Title,Profile.Name,Designation__c FROM User WHERE Id IN: opportunityOwnerIdTitleMap.keySet()]){
                opportunityOwnerIdTitleMap.put(us.Id,us);         
            }
            

            //Map to store the dealer Ids as key and their business hours as values
            map<Id,Id> dealerBusinessHourMap = new map<Id,Id>();
            //Get Business Hours details from the Dealership details 
            for(Account dealer : [SELECT Id,Business_Hours__c FROM Account WHERE Id in: dealershipIds]){
                if(dealer.Business_Hours__c!=null){
                    dealerBusinessHourMap.put(dealer.Id,dealer.Business_Hours__c);
                }
            }


            //loop through trigger new list
            for(Opportunity opty : triggerNewList){
                
                //To store enquiry's Line of Business
                String enquiryLineOfBusiness;
                //Get the type of generate enquiry i.e Maruti / Dealer
                String enquiryType;
                if(String.isNotBlank(opty.LeadSource) && marutiGeneratedEnquiries.contains(opty.LeadSource)){
                    //If Enquiry source mataches with Maruti generated enquiries
                    enquiryType = ConstantsUtility.MARUTI_ENQUIRY;
                    //Maruti - Maruti
                    enquiryLineOfBusiness = ConstantsUtility.MARUTI_ENQUIRY;
                }else{
                    //Dealer generated enquiries
                    enquiryType = ConstantsUtility.DEALER_ENQUIRY;
                    //Nexa - Arena - ISL -Rural
                    enquiryLineOfBusiness = String.isNotBlank(opty.ISL_Rural__c) ? opty.ISL_Rural__c : opty.Line_Of_Business__c;
                }

                //To store user's desgnation to define escalations
                String userDesignation;
                
                //Get the Business Hour Id of the dealership
                Id businessHourId = dealerBusinessHourMap.containsKey(opty.Dealership__c) ? dealerBusinessHourMap.get(opty.Dealership__c) : null;
                

                //Fill Current User Designation
                if(opportunityOwnerIdTitleMap.containsKey(opty.OwnerId)){ 
                    userDesignation = opportunityOwnerIdTitleMap.get(opty.OwnerId).Profile.Name;  // Change Designation to profile name based on DSE allocation time issue (16 Jna 2020) By Prabhat
                } 
                
                
                //A unqique key to be used in identifying the type/dealer/level of escalation needed
                String customKey = enquiryType+' '+enquiryLineOfBusiness;

                //If No DSE is assigned to an enquiry - DSE allocation escalation starts
                if(opty.Time_for_Next_Escalation__c==null && opty.DSE_Allocation_Time__c==null && opty.Last_Follow_Up_Update_Time__c ==null && String.isBlank(opty.Level_Escalated__c)){
                    
                    //First Level of Escalation for DSE Allocation Time
                    String firstLevelEscalation = customKey+' '+ConstantsUtility.FIRST_LEVEL_ESCALATION;

                    //Get the number of minutes to be added
                    Integer addMinutes = escalationMap.containsKey(firstLevelEscalation) ? Integer.valueOf(escalationMap.get(firstLevelEscalation).Time_to_Escalation__c) : Integer.valueOf(label.Default_Time_for_Escalation);

                    //Check if the time falls within business hours of the dealership
                    DateTime targetTime = DateTime.now().addMinutes(addMinutes);
                    targetTime = (businessHourId!=null) ? checkBusinessHours(businessHourId,targetTime,addMinutes) : targetTime;

                    //Update time for next escalation for DSE allocation
                    opty.Time_for_Next_Escalation__c = targetTime;
                    //Update type of allocation as DSE Allocation time
                    opty.Type_of_Escalation__c = ConstantsUtility.DSE_TYPE_ESCALATION;
                } 
                

                //When DSE is assigned to the enquiry, populate below fields
                if(String.isNotBlank(userDesignation) && userDesignation.contains(ConstantsUtility.DSE_PROFILE_NAME) && opty.DSE_Allocation_Time__c==null){
                    
                    //First Level of Escalation for DSE Allocation Time
                    String firstLevelEscalation = enquiryType+' '+enquiryType+' '+ConstantsUtility.FOLLOWUP_CONST+' '+ConstantsUtility.FIRST_LEVEL_ESCALATION;
                   
                    //Get the number of minutes to be added
                    Integer addMinutes = escalationMap.containsKey(firstLevelEscalation) ? Integer.valueOf(escalationMap.get(firstLevelEscalation).Time_to_Escalation__c) : Integer.valueOf(label.Default_Time_for_Escalation);

                    //DSE Allocation time to current time
                    opty.DSE_Allocation_Time__c = DateTime.now();
                    //Type of next escalation will be for follow up completion
                    opty.Type_of_Escalation__c = ConstantsUtility.FOLLOWUP_ESCALATION;


                    //Check if the time falls within business hours of the dealership
                    DateTime targetTime = DateTime.now().addMinutes(addMinutes);
                    targetTime = (businessHourId!=null) ? checkBusinessHours(businessHourId,targetTime,addMinutes) : targetTime;

                    //Type of next escalation will be time for first follow up escalation time
                    opty.Time_for_Next_Escalation__c = targetTime;
                    //Ensure no value in Level value in Level escalated field
                    opty.Level_Escalated__c = null;
                }
                
                
                
                //This will be used as a reference to populate all the notifiers at all levels
                if(String.isNotBlank(opty.Type_of_Escalation__c) && opty.Type_of_Escalation__c==ConstantsUtility.FOLLOWUP_ESCALATION)
                    customKey = enquiryType+' '+enquiryType+' '+ConstantsUtility.FOLLOWUP_CONST;
                
                
                //Loop through the escalation matrix label and extract current list of escalation
                list<Enquiry_Escalations__c> tempList = new list<Enquiry_Escalations__c>();
                for(String tempStr : escalationMap.keySet()){
                    if(String.isNotBlank(customKey) && tempStr.contains(customKey) && escalationMap.get(tempStr).Type_Of_Escalation__c==opty.Type_of_Escalation__c)
                        tempList.add(escalationMap.get(tempStr));
                }
                
                
                //Loop through the list generated and update all level of notifiers on Enquiry
                for(Enquiry_Escalations__c tempscl : tempList){
                    if(tempscl.Level_of_Escalation__c.contains(ConstantsUtility.LEVEL_2))
                        opty.Level_2_Notification__c = tempscl.Notifiers__c;
                    else if(tempscl.Level_of_Escalation__c.contains(ConstantsUtility.LEVEL_3))
                        opty.Level_3_Notification__c = tempscl.Notifiers__c;
                    else if(tempscl.Level_of_Escalation__c.contains(ConstantsUtility.LEVEL_4))
                        opty.Level_4_Notification__c = tempscl.Notifiers__c;
                    else if(tempscl.Level_of_Escalation__c.contains(ConstantsUtility.LEVEL_5))
                        opty.Level_5_Notification__c = tempscl.Notifiers__c;
                }
                
                

                //If Enquiry is Escalated, the Escalated check will be marked as true by Marketing cloud
                if(opty.Escalated__c){
                    //Variable for adding minutes based on custom key defined
                    Integer addMinutes=0; 
                    //If the enquiry has already been escalated, escalate it to next level if exists in matrix
                    if(String.isNotBlank(opty.Level_Escalated__c)){
                        List<String> currentLevelSplit = opty.Level_Escalated__c.split(' ');
                        String nextLevel = label.Custom_Key_For_Level+' '+String.valueOf(Integer.valueOf(currentLevelSplit[1])+1);
                        
                        //Unique Key for Maruti/Dealer generated enquiries
                        customKey+=' '+nextLevel;
                        
                        //If the unqiue key exists in the escalation matrix
                        if(escalationMap.containsKey(customKey)){
                            //If it's not the last level
                            if(escalationMap.get(customKey).Time_to_Escalation__c!=null){
                                addMinutes = Integer.valueOf(escalationMap.get(customKey).Time_to_Escalation__c);

                                //Check if the time falls within business hours of the dealership
                                DateTime targetTime = opty.DSE_Allocation_Time__c!=null ? opty.DSE_Allocation_Time__c.addMinutes(addMinutes) : opty.CreatedDate.addMinutes(addMinutes);
                                targetTime = (businessHourId!=null) ? checkBusinessHours(businessHourId,targetTime,addMinutes) : targetTime;
                                //Populate the next time for escalation
                                opty.Time_for_Next_Escalation__c = targetTime;
                            }
                            //At last level of escalation, below field will be set to blank
                            else{
                                opty.Time_for_Next_Escalation__c=null;
                                opty.Type_of_Escalation__c = null;
                            }
                            //Update the Level to which the enquiry has been escalated
                            opty.Level_Escalated__c = nextLevel;
                        }
                    }
                    //If it is being escalated for the first time, the first level will be Level 2
                    else{
                        //Second level of escalation
                        customKey = customKey+' '+ConstantsUtility.LEVEL_2;
                        //Add minutes based on the unique key
                        addMinutes = escalationMap.containsKey(customKey) ? Integer.valueOf(escalationMap.get(customKey).Time_to_Escalation__c) : Integer.valueOf(label.Default_Time_for_Escalation);
                        //Stamp Level 2 as first level escalation
                        opty.Level_Escalated__c = ConstantsUtility.LEVEL_2;
                        
                        //Check if the time falls within business hours of the dealership, 
                        //Based on DSE is assigned or not assigned, time of next escalation varies
                        DateTime targetTime = opty.DSE_Allocation_Time__c!=null ? opty.DSE_Allocation_Time__c.addMinutes(addMinutes) : opty.CreatedDate.addMinutes(addMinutes);
                        targetTime = (businessHourId!=null) ? checkBusinessHours(businessHourId,targetTime,addMinutes) : targetTime;
                        
                        //Populate the next time for escalation
                        opty.Time_for_Next_Escalation__c = targetTime;
                    }

                    //Turn the flag to False
                    opty.Escalated__c = false;

                } 

                //When Last follow up date is updated, blank out below fields to stop further escalations
                if(opty.Last_Follow_Up_Update_Time__c !=null){
                    opty.Time_for_Next_Escalation__c=null;
                    opty.Type_of_Escalation__c = null;
                }
            }
        }
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
    public void postEscalationChatterMessage(List<Opportunity> newOppList, 
                                             map<Id,Opportunity> newOppMap, 
                                             map<Id,Opportunity> oldOppMap,
                                             Boolean isInsert){
        //Store the Ids of escalated enquiries 
        set<Id> escaltedEnquiryIds = new set<Id>();
        //set of chatter post users
        map<Id,set<String>> chatterPostUsers = new map<Id,set<String>>(); 
        //set of SFMC user list
        map<Id,set<String>> sfmcUsers = new map<Id,set<String>>(); 
        //Enquiries to update 
        List<Opportunity> enquiriesToUpdate = new list<Opportunity>();
        //To be included later
        map<Id,map<String,String>> enuiqryIdUserIdTitleMap = new map<Id,map<String,String>>();


        //Loop through trigger.new and check if Time of Next Escalation has been changed
        for(Opportunity opp : newOppList){
            if((isInsert && opp.Level_Escalated__c==null) ||
                (!isInsert && 
                ((String.isNotBlank(opp.Level_Escalated__c) && opp.Time_for_Next_Escalation__c!=oldOppMap.get(opp.Id).Time_for_Next_Escalation__c) || 
                (String.isBlank(opp.Level_Escalated__c) &&  oldOppMap.get(opp.Id).Type_of_Escalation__c!=opp.Type_of_Escalation__c && opp.Type_of_Escalation__c == ConstantsUtility.FOLLOWUP_ESCALATION)
                ))){
                escaltedEnquiryIds.add(opp.Id);
            }
        }
        
        
        //Update esclated flag to false and query all the manager ids starting from Territory sales manager to 5 level up
        if(escaltedEnquiryIds.size()>0){
            //This will store the ass
            map<Id,Id> userAccountIdEnquiryIdMap = new map<Id,Id>();
            map<String,String> userIdMap = new map<String,String>();
            list<Opportunity> enquiryList = new list<Opportunity>([SELECT Id,AccountId,Level_Escalated__c,Level_2_Notification__c,Recordtype.Name,Type_of_Escalation__c,
                                Level_3_Notification__c,Level_4_Notification__c,Level_5_Notification__c,ISL_Rural__c,
                                Time_for_Next_Escalation__c ,
                                OwnerId, Owner.isActive, Owner.Designation__c,
                                Owner.ManagerId, Owner.Manager.isActive, Owner.Manager.Designation__c,
                                Dealership__r.TSM_ISL__c, Dealership__r.TSM_ISL__r.isActive, Dealership__r.TSM_ISL__r.User_Role_Text__c,
                                Dealership__r.Territory_Sales_Manager__c, Dealership__r.Territory_Sales_Manager__r.isActive, Dealership__r.Territory_Sales_Manager__r.User_Role_Text__c,
                                Dealership__r.TSM_Rural__c, Dealership__r.TSM_Rural__r.isActive, Dealership__r.TSM_Rural__r.User_Role_Text__c,
                                Dealership__r.Territory_Sales_Manager__r.ManagerId, Dealership__r.Territory_Sales_Manager__r.Manager.isActive, Dealership__r.Territory_Sales_Manager__r.Manager.User_Role_Text__c,
                                Dealership__r.TSM_MGA__c, Dealership__r.TSM_MGA__r.isActive, Dealership__r.TSM_MGA__r.User_Role_Text__c,
                                Dealership__r.Territory_Sales_Manager__r.Manager.ManagerId, Dealership__r.Territory_Sales_Manager__r.Manager.Manager.isActive, Dealership__r.Territory_Sales_Manager__r.Manager.Manager.User_Role_Text__c,
                                Dealership__r.Territory_Sales_Manager__r.Manager.Manager.ManagerId, Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.isActive, Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.User_Role_Text__c,
                                Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.ManagerId, Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.Manager.isActive, Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.Manager.User_Role_Text__c,
                                Escalated__c FROM Opportunity 
                                WHERE Id in: escaltedEnquiryIds
                            ]);
                
                //Loop through the eslacted enquiries
                for(Opportunity oppty : enquiryList){ 
                    
                    //For Account Teams
                    if(oppty.AccountId!=null)
                        userAccountIdEnquiryIdMap.put(oppty.AccountId,oppty.Id);
                        

                    //Initialize the map for every Enquiry
                    userIdMap = new map<String,String>();

                    //Owner details
                    if(oppty.Owner.isActive && oppty.Owner.Designation__c!=null){
                        userIdMap.put(oppty.OwnerId,oppty.Owner.Designation__c);
                    }
                    //Owner Manager's details
                    if(oppty.Owner.ManagerId!=null && oppty.Owner.Manager.isActive && oppty.Owner.Manager.Designation__c!=null)
                        userIdMap.put(oppty.Owner.ManagerId,oppty.Owner.Manager.Designation__c);
                    
                    //TSM details
                    if(oppty.Dealership__r.Territory_Sales_Manager__c!=null && oppty.Dealership__r.Territory_Sales_Manager__r.isActive && oppty.Dealership__r.Territory_Sales_Manager__r.User_Role_Text__c!=null){
                        userIdMap.put(oppty.Dealership__r.Territory_Sales_Manager__c,oppty.Dealership__r.Territory_Sales_Manager__r.User_Role_Text__c);
                    
                        //TSM Manager's details
                        if(oppty.Dealership__r.Territory_Sales_Manager__r.ManagerId!=null && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.isActive && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.User_Role_Text__c!=null)
                            userIdMap.put(oppty.Dealership__r.Territory_Sales_Manager__r.ManagerId,oppty.Dealership__r.Territory_Sales_Manager__r.Manager.User_Role_Text__c);
                        
                        //TSM Manager Manager's details
                        if(oppty.Dealership__r.Territory_Sales_Manager__r.Manager.ManagerId!=null && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.isActive && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.User_Role_Text__c!=null)
                            userIdMap.put(oppty.Dealership__r.Territory_Sales_Manager__r.Manager.ManagerId, oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.User_Role_Text__c);
                        
                        //TSM Manager Manager Manager's details
                        if(oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.ManagerId!=null && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.isActive && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.User_Role_Text__c!=null)
                            userIdMap.put(oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.ManagerId, oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.User_Role_Text__c);
                        
                        //TSM Manager Manager Manager Manager's details
                        if(oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.ManagerId!=null && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.Manager.isActive && oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.Manager.User_Role_Text__c!=null)
                            userIdMap.put(oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.ManagerId, oppty.Dealership__r.Territory_Sales_Manager__r.Manager.Manager.Manager.Manager.User_Role_Text__c);
                    }

                    //ISL TSM 
                    if(oppty.ISL_Rural__c==ConstantsUtility.ISL_LINEOFBUSINESS && oppty.Dealership__r.TSM_ISL__c!=null && oppty.Dealership__r.TSM_ISL__r.isActive && oppty.Dealership__r.TSM_ISL__r.User_Role_Text__c!=null){
                        userIdMap.put(oppty.Dealership__r.TSM_ISL__c, oppty.Dealership__r.TSM_ISL__r.User_Role_Text__c);
                    }
                    //Rural TSM 
                    if(oppty.ISL_Rural__c==ConstantsUtility.RURAL_LINEOFBUSINESS && oppty.Dealership__r.TSM_Rural__c!=null && oppty.Dealership__r.TSM_Rural__r.isActive && oppty.Dealership__r.TSM_Rural__r.User_Role_Text__c!=null){
                        userIdMap.put(oppty.Dealership__r.TSM_Rural__c, oppty.Dealership__r.TSM_Rural__r.User_Role_Text__c);
                    }
                    
                    //Accessories Enquiries
                    if(oppty.Recordtype.Name==ConstantsUtility.ACCESSORIES_SALES_CONST && oppty.Dealership__r.TSM_MGA__c!=null && oppty.Dealership__r.TSM_MGA__r.isActive && oppty.Dealership__r.TSM_MGA__r.User_Role_Text__c!=null){
                        userIdMap.put(oppty.Dealership__r.TSM_MGA__c, oppty.Dealership__r.TSM_MGA__r.User_Role_Text__c);
                    }
                    

                    enuiqryIdUserIdTitleMap.put(oppty.Id,userIdMap);
                }
                

                //Querying users from Account Team members for the related Account Id
                for(AccountTeamMember atm : [SELECT User.isActive, UserId,User.Designation__c,Title,AccountId FROM AccountTeamMember WHERE AccountId in: userAccountIdEnquiryIdMap.keySet()]){
                    userIdMap = new map<String,String>();
                    if(atm.User.isActive)
                        userIdMap.put(atm.UserId,atm.User.Designation__c);
                    String enquiryId = userAccountIdEnquiryIdMap.get(atm.AccountId);
                    //Add the user ids in same map as filled above
                    if(enuiqryIdUserIdTitleMap.containsKey(enquiryId) && enuiqryIdUserIdTitleMap.get(enquiryId)!=null)
                        enuiqryIdUserIdTitleMap.get(enquiryId).putAll(userIdMap);
                    else
                        enuiqryIdUserIdTitleMap.put(enquiryId,userIdMap);
                }
                
                //This will have the enquiry Ids and their list of titles to which escalation will happen 
                map<Id,set<String>> enquiryIdLevelMap = new map<Id,set<String>>();
                //This will have the enquiry Ids and their list of titles to which escalation will happen for SFMC 
                map<Id,set<String>> enquiryIdLevelMapSFMC = new map<Id,set<String>>();
                //temp set for chatter post users
                set<String> tempTitles;
                //temp set for SFMC
                set<String> tempSFMCTitles; 
                
            
                map<Id,String> enquirIdLevelToBeEscalatedMap = new map<Id,String>();
                //Loop through all escalated enquiries
                for(Opportunity tempOpp : enquiryList){
                    //Create a new set for the user titles to be posted on Chatter
                    tempTitles = new set<String>();
                    tempSFMCTitles = new set<String>();
                    
                    if(String.isBlank(tempOpp.Level_Escalated__c) && (isInsert || (!isInsert && tempOpp.Type_of_Escalation__c==ConstantsUtility.FOLLOWUP_ESCALATION)) && String.isNotBlank(tempOpp.Level_2_Notification__c)){
                        tempSFMCTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        enquirIdLevelToBeEscalatedMap.put(tempOpp.Id,ConstantsUtility.LEVEL_2);
                    }
                    //If esclated level is Level 2
                    else if(tempOpp.Level_Escalated__c==ConstantsUtility.LEVEL_2 && String.isNotBlank(tempOpp.Level_2_Notification__c)){
                        tempTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        //SFMC records
                        enquirIdLevelToBeEscalatedMap.put(tempOpp.Id,ConstantsUtility.LEVEL_3);
                        tempSFMCTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        if(String.isNotBlank(tempOpp.Level_3_Notification__c))
                            tempSFMCTitles.addAll(tempOpp.Level_3_Notification__c.split(';'));
                    }
                    //If esclated level is Level 3
                    else if(tempOpp.Level_Escalated__c==ConstantsUtility.LEVEL_3 && String.isNotBlank(tempOpp.Level_3_Notification__c)){
                        tempTitles.addAll(tempOpp.Level_3_Notification__c.split(';'));
                        tempTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        
                        //SFMC records
                        enquirIdLevelToBeEscalatedMap.put(tempOpp.Id,ConstantsUtility.LEVEL_4);
                        tempSFMCTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        tempSFMCTitles.addAll(tempOpp.Level_3_Notification__c.split(';'));
                        if(String.isNotBlank(tempOpp.Level_4_Notification__c))
                            tempSFMCTitles.addAll(tempOpp.Level_4_Notification__c.split(';'));
                    }
                    //If esclated level is Level 4
                    else if(tempOpp.Level_Escalated__c==ConstantsUtility.LEVEL_4 && String.isNotBlank(tempOpp.Level_4_Notification__c)){
                        tempTitles.addAll(tempOpp.Level_4_Notification__c.split(';'));
                        tempTitles.addAll(tempOpp.Level_3_Notification__c.split(';'));
                        tempTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        
                        //SFMC records
                        enquirIdLevelToBeEscalatedMap.put(tempOpp.Id,ConstantsUtility.LEVEL_5);
                        tempSFMCTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                        tempSFMCTitles.addAll(tempOpp.Level_3_Notification__c.split(';'));
                        tempSFMCTitles.addAll(tempOpp.Level_4_Notification__c.split(';'));
                        if(String.isNotBlank(tempOpp.Level_5_Notification__c))
                            tempSFMCTitles.addAll(tempOpp.Level_5_Notification__c.split(';'));
                    }
                    //If esclated level is Level 5
                    else if(tempOpp.Level_Escalated__c==ConstantsUtility.LEVEL_5 && String.isNotBlank(tempOpp.Level_5_Notification__c)){
                        tempTitles.addAll(tempOpp.Level_5_Notification__c.split(';'));
                        tempTitles.addAll(tempOpp.Level_4_Notification__c.split(';'));
                        tempTitles.addAll(tempOpp.Level_3_Notification__c.split(';'));
                        tempTitles.addAll(tempOpp.Level_2_Notification__c.split(';'));
                    }
                    //for chatter post
                    enquiryIdLevelMap.put(tempOpp.Id,tempTitles);
                    
                    //For SFMC cases -- added to avoid creation of MC record for last level of escalation
                    if(tempOpp.Time_for_Next_Escalation__c!=null)
                        enquiryIdLevelMapSFMC.put(tempOpp.Id,tempSFMCTitles);
                }
                    
                
                set<String> tempChatIds;
                set<String> tempSFMCIds;
                //Loop through all enquiry Ids and get the users Ids to which chatter post is required
                for(String enquiryId : enuiqryIdUserIdTitleMap.keySet()){
                    tempChatIds = new set<String>();
                    tempSFMCIds = new set<String>();
                    //This loop will iterate over all the user ids and will filter only ids to which chatter post will be created
                    for(String key : enuiqryIdUserIdTitleMap.get(enquiryId).keySet()){
                        //Get the user title of the user and add in the chatter post
                        String userDesignation = enuiqryIdUserIdTitleMap.get(enquiryId).get(key);
                        
                        //If enquiry is getting created, get the Ids of all Level 2 users
                        if(String.isNotBlank(userDesignation) && enquiryIdLevelMapSFMC.containsKey(enquiryId) && enquiryIdLevelMapSFMC.get(enquiryId).contains(userDesignation)){ 
                            tempSFMCIds.add(key);
                        }
                        if(!IsInsert && String.isNotBlank(userDesignation) && enquiryIdLevelMap.containsKey(enquiryId) && enquiryIdLevelMap.get(enquiryId).contains(userDesignation)){ 
                            tempChatIds.add(key);
                            
                            //Put enquiry id as key and all the user ids as values for chatter post
                            chatterPostUsers.put(enquiryId,tempChatIds);
                        }
                    }
                    
                    //In case enquiry is created, get first level of user for SFMC
                    sfmcUsers.put(enquiryId,tempSFMCIds);
                }
                 
                //Get Escalation Messages based on escaltion type from Custom metdata type 
                map<String,String> esclationMessageMap = new map<String,String>();
                for(Enquiry_Escalation_Messages__mdt esclationMsg : [SELECT MasterLabel,Escalation_Message__c FROM Enquiry_Escalation_Messages__mdt]){
                    esclationMessageMap.put(esclationMsg.MasterLabel,esclationMsg.Escalation_Message__c);
                }
                
                //For bulk chatter post
                List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
                
                //Post to chatter by looping through the Users to which chatter posts to be created
                for(String enquiryId : chatterPostUsers.keySet()){

                    //Create chatter message body
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    //Create text message for chatter
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    //Feed element input
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    
                    
                    //Get the enquiry escalation type
                    String escType = String.isNotBlank(newOppMap.get(enquiryId).Type_of_Escalation__c) ? newOppMap.get(enquiryId).Type_of_Escalation__c : oldOppMap.get(enquiryId).Type_of_Escalation__c; 
                    //Get the message based on escalation type
                    String messageBody = esclationMessageMap.containsKey(escType) ? esclationMessageMap.get(escType) : 'Metadata records missing';
                    
                    //Add the message body in body input of feedElement
                    textSegmentInput.text = messageBody+' ';
                    
                    messageBodyInput.messageSegments.add(textSegmentInput);
                    
                    //Add all the users id to receive chatter post and notification
                    for(String chatterUser : chatterPostUsers.get(enquiryId)){
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        mentionSegmentInput.id = chatterUser;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                    }

                    //Add the complete body along with @mentioned users in feed body
                    feedItemInput.body = messageBodyInput;
                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                    //Chatter post against enquiry
                    feedItemInput.subjectId = enquiryId;
                    //Make it visible to internal and external users
                    feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                    //Create a batch of inputs for bulk chatter post
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                    batchInputs.add(batchInput);
                }
            
                //In case enquiry is getting created or updated, SFMC MC Communcation records needs to be created.
                if(sfmcUsers.size()>0){
                    OpportunityTriggerHelper.esclationUsers = sfmcUsers; 
                    OpportunityTriggerHelper.esclationLevels = enquirIdLevelToBeEscalatedMap;
                    GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.ESCALATION_MC_TYPE,new set<Id>(sfmcUsers.keySet()),ConstantsUtility.OPPORTUNITY,'');
                }
             
                //Post to chatter
                if(!test.isRunningTest()){
                    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                }
        }
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to check if Time of Escaltion is within business hours. Returns next valid date time if outside business hours
        Returns: DateTime
        History:
        ====================================================
        1.0     22 Jul 2019  Prabhat Sharma  Initial Version 
    **/
    public DateTime checkBusinessHours(Id businessHourId, DateTime tempDateTime, Integer addMinutes){
        
        DateTime validDateTime;
        if(BusinessHours.isWithin(businessHourId, tempDateTime)){
            validDateTime = tempDateTime;
        }
        else{
           
            system.debug('tempDateTime'+tempDateTime);
            system.debug('addMinutes'+addMinutes);
            //Start Date Time by reducing the minutes
            DateTime tempStartdt = tempDateTime.addMinutes(addMinutes*(-1));
            system.debug('tempStartdt'+tempStartdt);
            //End Date Time minutes added already)
            DateTime tempEnddt = tempDateTime;
            system.debug('tempEnddt'+tempEnddt);
            
            //Time difference in milliseconds traversing business hours
            Long inputMillisecs = BusinessHours.diff(businessHourId, tempStartdt, tempEnddt);
            
            //Get the Duration in minutes
            Integer durationInMinutes = (inputMillisecs/1000).intValue();
            durationInMinutes = durationInMinutes/60;
            system.debug('durationInMinutes'+durationInMinutes);
            //Get the next valid date time
            DateTime nextValidDateTime = BusinessHours.nextStartDate(businessHourId, tempEnddt);
            
            //Add desired minutes to it
            validDateTime = durationInMinutes!=0 ? nextValidDateTime.addMinutes(durationInMinutes) : nextValidDateTime.addMinutes(addMinutes);
            system.debug('validDateTime'+validDateTime);
        }
       
        return validDateTime;
    }
}