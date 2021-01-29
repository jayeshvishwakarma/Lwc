/**
* @File Name          : OpportunityTriggerHandler.cls
* @Description        : Trigger handler class for Opportuntiy (Enquiry)
* @Author             : 
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 1/20/2020, 11:26:51 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM                                Initial Version
1.1    26/08/2019, 9:14:54 AM        Sunit                  checkBookingCancellationReason method is added 
1.2    09/12/2019                    subhojit               Added dummy account creation logic
**/

//CODE REVIEWED BY: Prabhat Sharma


public without sharing class OpportunityTriggerHandler extends TriggerHandler{
    
    private Map<Id, Opportunity> newOppMap; //Used to store the map of new Opportunities
    private list<Opportunity> newOppList; // Used to store the list of new Opportunities
    private Map<Id, Opportunity> oldOppMap; // Used to store Map of old Opportunities 
    
    //Enquiry Escalation Service Class
    EnquiryEscalationService escSrvc;
    OpportunityTriggerHelper oppHelper;
    
    public static Id vehicleSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE).getRecordTypeId();
    private static Id accessoriesSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_SALES_CONST).getRecordTypeId();
    private static String preBookingTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.PRE_BOOKING_FOLLOWUP).getRecordTypeId();
    private static String generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE).getRecordTypeId();
    
    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public OpportunityTriggerHandler() {
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.newOppList = (List<Opportunity>) Trigger.new;
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap; 
        //Instantiate service class
        escSrvc = new EnquiryEscalationService();
        //Instantiate Helper Class
        oppHelper = new OpportunityTriggerHelper();
    }
    
    
    //Methods executions before Insert of Enquiry 
    public override void beforeInsert() {
        updateGenderAndCustomerType();
        //Update Close date on Enquiry from current plus 3 months date
        populateCloseDate();
        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        updateDealerAndStandardAccount();
        //Change Ownership of Enquiry(Opportunity)to Sales SPOC when Enquiry is of Vehicle Sales Record Type and 
        //Enquiry owner is Integration user.
        assignEnquirytoSalesSPOC();
        //Update Escalation Fields based on Escalation Matrix
        //This will the populate the notifiers for each levels for both allocated and unallocated enquiries
        updateEscalationFields();
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        setStageTime();
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        updateEnquiryName(); 
        //Update the Cusytomer attributes to opportunity
        updateCustomerAttributes(); 
        //Method to count the variant changes on enquiry.
        populateVariantChangesCount();
        //create dummy customer account in case of no account is populated
        createDummyAccountOnOpportunity();
        
        
    }   
    
    
    //Methods executions before update of Enquiry 
    public override void beforeUpdate() {
        updateGenderAndCustomerType();
        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        updateDealerAndStandardAccount();
        //Populate Previous owner on Enquiry
        updatePreviousOwneronEnquiry();
        //Prevent mulesoft user from changing status back to New
        preventWrongStageChange();
        //Update Escalation Fields based on Escalation Matrix
        updateEscalationFields();
        //This method will check BookingCancellationReason field and update opportunity stage to New if BookingCancellationReason is Post-Pone and previous value of BookingCancellationReason is blank.
        checkBookingCancellationReason();
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        setStageTime();
        //executes when Reatil Cancellation Date on Enquiry gets populated
        changeEnquiryStage();
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        updateEnquiryName(); 
        //Method to count the variant changes on enquiry.
        populateVariantChangesCount();
        //Method to change enquiry stage back to new from pre-booking when pre-booking number is null
        //changeEnquiryStagePreBookingToNew();
        changeBookingAndRetailDate();
        
        //send employer status to enq owner
        notifyEnqOwnerAboutEmployerStatus();
        
    }
    
    
    //Method executions after insert of Enquiry
    public override void afterInsert(){
        //Send notifications to SPOC
        notifySpocForDSEAllocation();
        //This method will create Pre-Booking Followup Task for an Enquiry
        createPreBookingFollowUp();
        //To add Opportunity team members under an Enquiry
        addOpportunityTeamMembers(); 
        //create MC Communication records on DSE Allocation
        createMCrecordsOnDSEAllocationOrUntagging();
        //Escalations
        postChatterMessage();
        
        
    }
    
    
    //Methods executions after update of Enquiry 
    public override void afterUpdate() {
        //Update SVOC ID on Enquiry and on Account
        updateFieldsUsingSVOCID(); 
        //Post chatter message and notification for Escalated Enquiries
        postChatterMessage();
        //To add Opportunity team members under an Enquiry
        addOpportunityTeamMembers(); 
        //create MC Communication records on DSE Allocation
        createMCrecordsOnDSEAllocationOrUntagging();
        // if stage = "Retail" then all the Followup  will be closed .
        closedFollowup();
        //changeEnquiryStagePreBookingToNew();
        closePreBookingFollowups();
        
        
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
    public void populateCloseDate(){
        //get standard pricebook2 id
        // List<Pricebook2> lsPB = [select id from Pricebook2 where isStandard = true limit 1];
        String pricebook2Id = '';
        StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance();        
        if (lsPB != null){
            pricebook2Id = lsPB.PriceBookId__c;
        }
        
        //Loop through all new Opportunities
        for(Opportunity opp : this.newOppList){
            
            //Updating Close Date from 3 months from now
            opp.CloseDate = opp.RecordTypeId==vehicleSalesId ? system.today().addMonths(Integer.valueOf(label.Add_Months_to_Enquiry_Close_Date)) : system.today().addMonths(Integer.valueOf(label.Accessoires_Enquiry_Close_Date));
            
            //Pre-Populating Address Type 1 and Address Type 2 Field
            opp.Address_Type_1__c = ConstantsUtility.RESIDENCE;
            opp.Address_Type_2__c = ConstantsUtility.OFFICE;
            
            
            if (pricebook2Id != '')
                opp.Pricebook2Id = pricebook2Id;
            
            //Rahul adding changes for integration to run. Need to remove it.   
            //if(string.isEmpty(opp.Test_Drive_Given__c)){  
            opp.Test_Drive_Given__c = 'N';  
            //} 
            //if(string.isEmpty(opp.Mode_Of_Communication__c)){ 
            opp.Mode_Of_Communication__c = 'M'; 
            
            //Rahul End. Updated the values.
            
            //Rajesh - Set recordtype to Accessories if enquiry number starts with SF
            if (lsPB != null && lsPB.SetOptyRecordTypeId__c == true){
                if(opp.dms_enquiry_name__c != null && (opp.dms_enquiry_name__c.startsWith('SF') || opp.dms_enquiry_name__c.startsWith('WGP'))&& opp.recordtypeid != accessoriesSalesId){
                    opp.recordtypeid = accessoriesSalesId;
                }
                else if(opp.dms_enquiry_name__c != null && opp.dms_enquiry_name__c.startsWith('ENQ') && opp.recordtypeid != vehicleSalesId){
                    opp.recordtypeid = vehicleSalesId;
                }  
            }
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
    public void assignEnquirytoSalesSPOC(){
        System.debug('coming in this function');
        
        //Set to add Dealership from Enquiry(Opportunity). 
        Set<Id> dealerAccountIds = new Set<Id>();
        
        // Map to add Account Id and Sales SPOC(s) User Ids. 
        Map<Id,set<String>> accountSalesSpocUserIdsMap = new Map<Id,set<String>>();
        
        //Dealer Channel Account Map
        Map<Id,Account> accountChannelMap = new Map<Id,Account>();
        //This to randomly assign the SPOCs for Opportunities
        Integer counter=0;
        
        //Loop through all new Opportunities
        for(Opportunity opp : this.newOppList){
            if(UserInfo.getUserId() == label.Integration_User && opp.Dealership__c!=null) //Removed vehile sales record type Id condition for Accessories Enquiries
                dealerAccountIds.add(opp.Dealership__c);
        }
        // Set to add Sales SPOC(s) User Ids.
        set<String> tempSpocIds;
        
        //Query Sales SPOCs on Dealer(Account)
        if(dealerAccountIds.size()>0){
            for(Account acc : [SELECT Id,Sales_SPOC_1__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c,Channel__c 
                               FROM Account WHERE Id IN: dealerAccountIds]){
                                   
                                   //Adding channel as value and Dealership ID as key
                                   accountChannelMap.put(acc.Id,acc);
                                   
                                   tempSpocIds = new Set<String>();
                                   if(acc.Sales_SPOC_1__c!=null)
                                       tempSpocIds.add(acc.Sales_SPOC_1__c);
                                   if(acc.Sales_SPOC_2__c!=null)
                                       tempSpocIds.add(acc.Sales_SPOC_2__c);
                                   if(acc.Sales_SPOC_3__c!=null)
                                       tempSpocIds.add(acc.Sales_SPOC_3__c);
                                   if(acc.Sales_SPOC_4__c!=null)
                                       tempSpocIds.add(acc.Sales_SPOC_4__c);
                                   if(acc.Sales_SPOC_5__c!=null)
                                       tempSpocIds.add(acc.Sales_SPOC_5__c);
                                   
                                   //Fill the Map with Dealer(Account) and Sales SPOC(s) User Ids.
                                   accountSalesSpocUserIdsMap.put(acc.Id,tempSpocIds);
                               }
            
            map<String,String> channelMap = new map<String,String>(ConstantsUtility.channelModelMap);
            List<Opportunity> tempOpty = new list<Opportunity>();
            //Assign Enquiry(Opportunity) Owner from Integration user to Sales SPOC(s)
            for(Opportunity opty : this.newOppList){
                if(accountSalesSpocUserIdsMap.containsKey(opty.Dealership__c) && accountSalesSpocUserIdsMap.get(opty.Dealership__c).size()>0){
                    
                    //assign a random dealer as an enquiry owner
                    List<String> spocUserList = new List<String>(accountSalesSpocUserIdsMap.get(opty.Dealership__c));
                    
                    //Added check for size because Random Utility was failing to size =1
                    if(spocUserList.size()>1){
                        opty.OwnerId = RandomUtility.findRandomStringFromList(spocUserList);
                    }else if(spocUserList.size()==1){
                        opty.OwnerId = spocUserList[0];
                    }
                    
                    tempOpty.add(opty);
                }
                //Default LOB and Dealership Channel
                if(accountChannelMap.containsKey(opty.Dealership__c) && accountChannelMap.get(opty.Dealership__c).Channel__c!=null){
                    if(channelMap.containsKey(accountChannelMap.get(opty.Dealership__c).Channel__c)){
                        opty.line_of_business__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                        opty.Temporary_LOB_Admin_use__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                        opty.dealership_channel__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                    }
                }
            }
            //Assign the list to a static variable for trigger after event to get the Enquiry Ids and create MC records
            if(tempOpty.size()>0){
                OpportunityTriggerHelper.spocOptyList = tempOpty;
            }
        }
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
**/
    public void addOpportunityTeamMembers(){
        try{
            //List to insert the OpportunityTeamMember records
            list<OpportunityTeamMember> oppTeamMemberList = new list<OpportunityTeamMember>();
            //List to insert the OpportunityShare records
            list<OpportunityShare> oppSharesToInsert = new list<OpportunityShare>();
            //List to delete the previous OpportunityTeamMember records for related Enquiry id
            list<OpportunityTeamMember> oppTeamMemberDeleteList;
            
            //Set to contains the Opportunity Dealership__c field
            set<Id> dealershipIdSet = new set<Id>();
            map<Id,set<Id>> oppTsmUsersMap = new map<Id,set<Id>>();
            
            //Set to delete previous OpportunityTeamMember records for related Enquiry id
            set<Id> oppIdSet = new set<Id>();
            
            //Accessories Record type Id
            Id acessoriesSalesRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_SALES_CONST).getRecordTypeId();
            
            for(opportunity opp : this.newOppList){
                //Check if dealership is not blank or Dealership has changed
                if((trigger.isInsert && opp.Dealership__c!=null) || (trigger.isUpdate && ((opp.Dealership__c != this.oldOppMap.get(opp.id).Dealership__c)||
                                                                                          (opp.ISL_Rural__c  != this.oldOppMap.get(opp.id).ISL_Rural__c )||
                                                                                          (opp.Accessories_DSE1__c != this.oldOppMap.get(opp.Id).Accessories_DSE1__c) ||
                                                                                          (opp.OwnerId != this.oldOppMap.get(opp.Id).OwnerId)))){
                                                                                              dealershipIdSet.add(opp.Dealership__c); 
                                                                                              oppIdSet.add(opp.id);
                                                                                          }
            }
            
            //Check dealershipSet size 
            if(dealershipIdSet.size()>0){
                
                //Map to put all the Id related Account records 
                map<Id,Account> accountMap = new map<id,Account>([SELECT id,Finance_Manager__c,Territory_Sales_Manager__c,
                                                                  TSM_ISL__c,TSM_MGA__c,TSM_Rural__c,Accessories_SPOC_1__c,
                                                                  Accessories_SPOC_2__c FROM Account WHERE Id in:dealershipIdSet
                                                                  AND Recordtype.Name=:ConstantsUtility.DEALER_RECORDTYPE]);
                
                oppTeamMemberDeleteList = new list<OpportunityTeamMember>([SELECT id from OpportunityTeamMember
                                                                           WHERE OpportunityId in: oppIdSet]);
                
                
                set<Id> tempSet;
                //Loop through all new Opportunities
                for(Opportunity opp : this.newOppList){
                    tempSet = new set<Id>();
                    
                    
                    //Check if accountMap contains Opportunity Dealership id 
                    if(accountMap.containskey(opp.Dealership__c)){
                        
                        //Adding Accessories DSE from Enquiry level
                        if(opp.Accessories_DSE1__c !=null){
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),ConstantsUtility.ACCESSORIES_DSE));
                            tempSet.add(opp.Accessories_DSE1__c);
                        }
                        
                        //Adding Accessories SPOC 1 for every opportunity
                        if(accountMap.get(opp.Dealership__c).Accessories_SPOC_1__c != null){
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),ConstantsUtility.ACCESSORIES_SPOC_1));
                            tempSet.add(accountMap.get(opp.Dealership__c).Accessories_SPOC_1__c);
                        }
                        
                        //Adding Accessories SPOC 2 for every opportunity
                        if(accountMap.get(opp.Dealership__c).Accessories_SPOC_2__c != null){
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),ConstantsUtility.ACCESSORIES_SPOC_2));
                            tempSet.add(accountMap.get(opp.Dealership__c).Accessories_SPOC_2__c);
                        }
                        
                        //Adding Primary TSM for every Opportunity 
                        if(accountMap.get(opp.Dealership__c).Territory_Sales_Manager__c !=null){
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),
                                                                                        ConstantsUtility.PRIMARY_TSM));
                            tempSet.add(accountMap.get(opp.Dealership__c).Territory_Sales_Manager__c);
                        }
                        
                        
                        //Adding Finance managers to Opportunity team for Dealers
                        if(accountMap.get(opp.Dealership__c).Finance_Manager__c != null){
                            //Adding finance mamanger
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),
                                                                                        ConstantsUtility.FINANCE_MANAGER));
                            tempSet.add(accountMap.get(opp.Dealership__c).Finance_Manager__c);
                        }
                        
                        
                        //Adding TSM in Opportunity team for ISL for Maruti Personas 
                        if(opp.ISL_Rural__c==ConstantsUtility.ISL_LINEOFBUSINESS && 
                           accountMap.get(opp.Dealership__c).TSM_ISL__c != null){
                               //Adding TSM ISL
                               oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),
                                                                                           ConstantsUtility.TSM_ISL));
                               //For Opportunity Share
                               tempSet.add(accountMap.get(opp.Dealership__c).TSM_ISL__c);
                           }
                        
                        //Adding TSM in Opportunity team for RURAL for Maruti Personas 
                        else if(opp.ISL_Rural__c==ConstantsUtility.RURAL_LINEOFBUSINESS && 
                                accountMap.get(opp.Dealership__c).TSM_Rural__c != null){
                                    //Adding TSM Rurual
                                    oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),
                                                                                                ConstantsUtility.TSM_RURAL));
                                    //For Opportunity Share
                                    tempSet.add(accountMap.get(opp.Dealership__c).TSM_Rural__c);
                                    
                                }
                        //Adding TSM in Opportunity team for ACCESSORIES for Maruti Personas 
                        //Rajesh - removed condition on accessories record type so mga tsm will see all enquiries
                        else if(accountMap.get(opp.Dealership__c).TSM_MGA__c != null){
                            //Adding TSM MGA
                            oppTeamMemberList.add(oppHelper.createOppTeamMemberInstance(opp,accountMap.get(opp.Dealership__c),
                                                                                        ConstantsUtility.TSM_MGA));
                            //For Opportunity Share
                            tempSet.add(accountMap.get(opp.Dealership__c).TSM_MGA__c);
                        }
                        oppTsmUsersMap.put(opp.id,tempSet);
                    } 
                }
                //Get all Opportunity share records to be inserted
                oppSharesToInsert = createOppShareRecords(oppTsmUsersMap);
            }
            
            
            
            //Insert Opportunity Share records
            if(oppSharesToInsert.size()>0){
                insert oppSharesToInsert;
            }
            //Delete previous Opportunity team member records
            if(Schema.sObjectType.OpportunityTeamMember.isDeletable() && oppTeamMemberDeleteList != null)
                delete oppTeamMemberDeleteList;
            //Insert Opportunity team member records
            if(oppTeamMemberList.size()>0){
                insert oppTeamMemberList;
            }
            
        }catch(System.DmlException e){ExceptionHandler.LogError('OpportunityTriggerHandler addOpportunityTeamMembers', e.getMessage(),'OpportunityTriggerHandler', '', null);}
        
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
    public list<OpportunityShare> createOppShareRecords(map<Id,set<Id>> oppTsmUserMap){ 
        list<OpportunityShare> oppShareToInsert = new list<OpportunityShare>();
        
        map<Id,set<Id>> oppShareMap = new map<Id,set<Id>>();
        set<Id> tempIdSet;
        
        //Query all Opportunity share records related to the Opportunities
        for(opportunityshare oppShare : [SELECT UserOrGroupId,OpportunityId  FROM OpportunityShare WHERE OpportunityId in :oppTsmUserMap.keyset()]){
            tempIdSet = new set<Id>();
            if(oppShareMap.containsKey(oppShare.OpportunityId) && oppShareMap.get(oppShare.OpportunityId)!=null){
                oppShareMap.get(oppShare.OpportunityId).add(oppShare.UserOrGroupId);
            }
            else{
                tempIdSet.add(oppShare.UserOrGroupId);
                oppShareMap.put(oppShare.OpportunityId,tempIdSet);
            }
        }
        
        //Loop through all Opportunities
        for(Id opptyId : oppTsmUserMap.keySet()){
            //Loop through all available users
            for(Id tempId : oppTsmUserMap.get(opptyId)){
                if(tempId!=null && oppShareMap.containsKey(opptyId) && !oppShareMap.get(opptyId).contains(tempId)){
                    //Create Opportunity share records
                    oppShareToInsert.add(oppHelper.createOppShareRecords(opptyId,tempId));
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
                opp.Previous_Enquiry_Owner__c=this.oldOppMap.get(opp.Id).ownerId;
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
    public void checkBookingCancellationReason(){
        try{
            // This loop is used to traverse through the list of opportunity got updated
            for(Opportunity opp: this.newOppList){
                // This condition will check if owner of Opportunity is changed then it will store previous Opportunity owner in 'Previous Enquiry Owner'
                if(opp.Booking_Cancellation_Reason__c != Null && String.isBlank(this.oldOppMap.get(opp.Id).Booking_Cancellation_Reason__c)){
                    opp.StageName=ConstantsUtility.STAGE_NEW;
                    opp.Pre_booking_Submission_Date__c=null;
                }
                /*else if(String.isNotBlank(opp.Booking_Cancellation_Reason__c) && opp.Booking_Cancellation_Reason__c!=label.Booking_Cancellation_Reason && String.isBlank(this.oldOppMap.get(opp.Id).Booking_Cancellation_Reason__c)){
opp.StageName=ConstantsUtility.STAGE_CLOSELOST;
}*/
            }
        }
        catch(Exception e){ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='OpportunityTriggerHandler checkBookingCancellationReason'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('OpportunityTriggerHandler checkBookingCancellationReason', e.getMessage(), 'OpportunityTriggerHandler', '', ehst);
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
1.0     19 Jul 2019  Ritika Mehendiratta  Initial Version
1.1     29 Oct 2019  Prabhat Sharma       Added logic to populate Accessories DSE field for Accessories Enquiries
**/
    public void updateDealerAndStandardAccount(){
        
        //Map to store the Portal User Ids as keys and Dealer Account ID as values
        map<Id,Id> userContactAccountMap = new map<Id,Id>();
        //Map to store the Portal User Ids as keys and User Account ID as values
        map<Id,Id> userAccountUserAccountMap = new map<Id,Id>();
        
        //Map to store the Portal User Ids as keys and User Account ID as values
        map<Id,String> userDesignationMap = new map<Id,String>();
        //Map to store the Portal User Ids as keys and User Account ID as values
        map<Id,String> accountChannelMap = new map<Id,String>();
        
        //Map to store the Contact Ids as keys and User ID as values
        map<Id,String> contactUserIdsMap = new map<Id,String>();
        
        //Channel model Map
        map<String,String> channelModelMap = new map<String,String>(ConstantsUtility.channelModelMap);
        
        //Loop through trigger.new
        for(Opportunity opp : this.newOppList){
            //Populating Mobile no. for SFMC
            if(opp.Mobile__c!=null && (trigger.isInsert || (trigger.isUpdate && this.oldOppMap.get(opp.Id).Mobile__c!=opp.Mobile__c))){
                //populate SFMC Mobile field
                opp.Mobile_SFMC__c = ConstantsUtility.COUNTRY_CODE+String.valueof(opp.Mobile__c);
            }
            
            if(opp.OwnerID!=label.Integration_User && (trigger.isInsert || (trigger.isUpdate && this.oldOppMap.get(opp.Id).OwnerID!=opp.OwnerId)))
                userContactAccountMap.put(opp.ownerId,null);
            
           //Populate Exchange Vehicle Evaluator
            if(opp.Exchange_Vehicle_Evaluator_Contact__c !=null && (trigger.isInsert || (trigger.isUpdate && this.oldOppMap.get(opp.Id).Exchange_Vehicle_Evaluator_Contact__c != opp.Exchange_Vehicle_Evaluator_Contact__c))){
                //populate Exchange Vehicle Evaluator 
                contactUserIdsMap.put(opp.Exchange_Vehicle_Evaluator_Contact__c, null);
            }
          
            
        }
        
        //If the map has something...
        if(contactUserIdsMap != null && contactUserIdsMap.keySet().size()>0){
            
            //Looping through all portal users to get their IDs
            for(User portalUser : [Select id, ContactId from user where UserType =: ConstantsUtility.POWER_PARTNER AND ContactId IN : contactUserIdsMap.keySet()]){
                if(contactUserIdsMap.containsKey(portalUser.ContactId)){
                    contactUserIdsMap.put(portalUser.ContactId, portalUser.Id);
                }
            }
            
            if(contactUserIdsMap.values() != Null && contactUserIdsMap.values().size() > 0){
                for(Opportunity oppty : this.newOppList){
                    //Update the Exchange Vehicle Evaluator field on Enquiry
                    if(oppty.Exchange_Vehicle_Evaluator_Contact__c != Null && contactUserIdsMap != null && contactUserIdsMap.containsKey(oppty.Exchange_Vehicle_Evaluator_Contact__c)){
                        oppty.Exchange_Vehicle_Evaluator__c = contactUserIdsMap.get(oppty.Exchange_Vehicle_Evaluator_Contact__c);
                    }
                }
            }
            
        }
        
     
        
        //If the map has something...
        if(userContactAccountMap.keySet().size()>0){
            
            //Looping through all portal users to get their account IDs
            for(User portalUser : [Select id,ContactId,Contact.AccountId,Contact.Account.Channel__c,Designation__c from user where id in :usercontactAccountMap.keySet()]){
                if(portalUser.ContactId != null){
                    userContactAccountMap.put(portalUser.Id, portalUser.Contact.AccountId);
                    //Dealership channe field on Enquiry
                    accountChannelMap.put(portalUser.Contact.AccountId,portalUser.Contact.Account.Channel__c);
                    //Added to check the designation for Accessories Enquiries
                    userDesignationMap.put(portalUser.Id,portalUser.Designation__c);
                }
            }
            
            //Loop through all the accounts
            for (Account userAcc : [select id,user__c from Account where recordtype.developername =: ConstantsUtility.USER_ACCT_RECORDTYPE and user__c in :userContactAccountMap.keySet()]){
                userAccountUserAccountMap.put(userAcc.user__c, userAcc.id);
            }
            
            //Populating Account Id on Enquiry
            for(Opportunity oppty : this.newOppList){
                
                //Update the Dealership
                if(userContactAccountMap.containsKey(oppty.OwnerId) && userContactAccountMap.get(oppty.OwnerId)!=null){
                    oppty.Dealership__c = userContactAccountMap.get(oppty.OwnerId);
                    
                    if(accountChannelMap.get(oppty.Dealership__c)!=null && channelModelMap.containsKey(accountChannelMap.get(oppty.Dealership__c))){
                        oppty.Dealership_Channel__c = channelModelMap.get(accountChannelMap.get(oppty.Dealership__c));
                    }
                }
                
                //Update the standard Account field on Enquiry
                //This will enable the visiblity for the Account team of that account
                if(userAccountUserAccountMap.containsKey(oppty.OwnerId) && userAccountUserAccountMap.get(oppty.OwnerId)!=null)
                    oppty.AccountId = userAccountUserAccountMap.get(oppty.OwnerId); 
                
                //Check if the enquiry is an Accessories Enquiry and the Owner is an Accessories DSE, 
                //Update the Accessories DSE field on Enquiry
                if(oppty.RecordtypeId == accessoriesSalesId && userDesignationMap.containsKey(oppty.OwnerId) && 
                   userDesignationMap.get(oppty.OwnerId)==ConstantsUtility.ACCESSORIES_DSE_DESIGNATION){
                       oppty.Accessories_DSE1__c = oppty.OwnerId; 
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
    public void updateEscalationFields(){
        //To avoid recursive call of trigger as DML is required to update the Escalated flag to false
        //if(AvoidRecursion.isBeforeRun()){
        //Calling Escalation Service Class to Update the fields
        escSrvc.escalationFieldUpdates(this.newOppList, this.oldOppMap);
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
    public void postChatterMessage(){ 
        //Call Escaltion Service Class
        escSrvc.postEscalationChatterMessage(this.newOppList, this.newOppMap, this.oldOppMap,trigger.isInsert);
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
    public void setStageTime(){
        
        //Variable to store Dealership Ids
        set<Id> dealershipIds = new set<Id>();
        set<Id> colorIds= new set<Id>();
        //Loop through trigger new and get the dealerships Ids
        for (Opportunity opp : this.newOppList){
            if(opp.Dealership__c!=null)
                dealershipIds.add(opp.Dealership__c);
            if(opp.color__c != null)
                colorIds.add(opp.Color__c);
        }
        
        if(dealershipIds.size()>0){
            //Query the dealership details
            Map<Id,Account> dealershipMap = new Map<Id,Account>([SELECT Id,Dealer_Map_Code__c,Dealer_Location__c,Parent_Group__c,For_Code__c,For_Code__r.For_Code__c,Dealer_Code__c,
                                                                 Dealer_Comp_FA__c FROM Account WHERE Id in: dealershipIds]);
            
            //Query Variant Master Records
            Map<Id,Color_Variant_Master__c> colorVariantMap= new Map<Id,Color_Variant_Master__c>([SELECT Id,Name,Color_Code__c FROM Color_Variant_Master__c WHERE Id in: colorIds]);
            
            Set<String> oppStageSet= new Set<String>();
            List<OpportunityStage> stageList= new list<OpportunityStage>([SELECT Id, ApiName FROM OpportunityStage WHERE IsClosed = true]);
            
            //Loop through closed Opportuntiy stages
            for(OpportunityStage opp : stageList){
                oppStageSet.add(opp.ApiName);
            } 
            
            //Loop through trigger new
            for(Opportunity opty : this.newOppList){
                
                //Enquiry Stage
                String data = ConstantsUtility.OPEN_CURLY_BRACES;
                
                String enquiryStage='';
                enquiryStage = (oppStageSet.contains(opty.stagename) && trigger.isUpdate) ? this.oldOppMap.get(opty.id).StageName : opty.StageName;
                
                //Enquiry Stage
                data+=oppHelper.createKeyValueStructure(ConstantsUtility.STAGE_LABEL,enquiryStage);
                
                //Dealer Map Code
                if(opty.Dealership__c!=null && dealershipMap.containsKey(opty.Dealership__c)){
                    //Dealer Map Code
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.DEALERMAPCODE_LABEL,dealershipMap.get(opty.Dealership__c).Dealer_Map_Code__c);
                    //Dealer For Code
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.FORCODE_LABEL,dealershipMap.get(opty.Dealership__c).For_Code__r.For_Code__c);
                    //Pre-Booking Number
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.PRE_BOOKING_LABEL,opty.Pre_Booking_Number__c);
                    //Adding the Dealer Code
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.DEALER_CODE,dealershipMap.get(opty.Dealership__c).Dealer_Code__c);
                    //Parent Group
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.DEALERPARENTGROUP_LABEL,dealershipMap.get(opty.Dealership__c).Parent_Group__c);
                    //Dealer Location
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.DEALERLOCATIONCODE_LABEL,dealershipMap.get(opty.Dealership__c).Dealer_Location__c);
                    //Dealer COMP FA
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.DEALER_COMP_FA,dealershipMap.get(opty.Dealership__c).Dealer_Comp_FA__c);
                } 
                
                //Adding the Color Code
                String colorCode='';
                if(opty.Color__c!=null && colorVariantMap.containsKey(opty.Color__c)){
                    colorCode=colorVariantMap.get(opty.Color__c).Color_Code__c;                   
                }
                data+=oppHelper.createKeyValueStructure(ConstantsUtility.COLOR_LABEL,colorCode);
                
                //Adding DMS Enquiry Number
                data+=oppHelper.createKeyValueStructure(ConstantsUtility.DMS_ENQUIRY_NUM,opty.DMS_Enquiry_Name__c);
                //Adding Booking Number
                data+=oppHelper.createKeyValueStructure(ConstantsUtility.BOOKING_NUMBER,opty.Booking_Number__c);
                
                //Adding Enquiry Record Type
                if(opty.RecordTypeId==vehicleSalesId){
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.RECORD_TYPE_CONST,ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE);
                }else{
                    data+=oppHelper.createKeyValueStructure(ConstantsUtility.RECORD_TYPE_CONST,ConstantsUtility.ACCESSORIES_SALES_CONST);
                } 
                
                
                // Added By: Anuj (Requested by Rajesh related to DMS)  
                if(opty.Last_Follow_Up_Update_Time__c != Null && this.oldOppMap != Null &&  
                   this.oldOppMap.get(opty.id).Last_Follow_Up_Update_Time__c != opty.Last_Follow_Up_Update_Time__c ){ 
                       data+=oppHelper.createKeyValueStructure(ConstantsUtility.IS_FOLLOW_UP_UPDATE, String.valueOf(True));    
                   }else{  
                       data+=oppHelper.createKeyValueStructure(ConstantsUtility.IS_FOLLOW_UP_UPDATE, String.valueOf(False));   
                   }
                
                
                //Time Stamp
                data+=oppHelper.createKeyValueStructure(ConstantsUtility.TIMESTAMP_LABEL,String.valueOf(Datetime.now())); 
                data = data.removeEnd(ConstantsUtility.COMMA);
                
                //Closed Curly Braces
                data+=ConstantsUtility.CLOSE_CURLY_BRACES;
                //Update the data in Last Modified Details field
                opty.Last_Modified_Details__c = data;
                
                
                //Rahul Adding logic to get the external Id
                //Should be populated only if Enquiry Number is generate.
                //Should be a combination of dealer map code, Dealer location Code, Dealer Parent group and Enquriy 
                if (string.isNotBlank(opty.DMS_Enquiry_Name__c)){
                    opty.External_Id__c = dealershipMap.get(opty.Dealership__c).Parent_Group__c+
                        '_'+dealershipMap.get(opty.Dealership__c).Dealer_Map_Code__c+
                        '_'+dealershipMap.get(opty.Dealership__c).Dealer_Location__c+
                        '_'+opty.DMS_Enquiry_Name__c;
                }
                
                //if the stage of Enquiry changed to Retail then update Send_BCR_Time__c equals to null
                if(opty.stageName == ConstantsUtility.RETAIL_NAME && (trigger.isInsert || (trigger.isUpdate && oldOppMap.get(opty.Id).Stagename!=  opty.stageName))){
                   opty.Send_BCR_Time__c =null;
                }
                   
                //Rajesh - temporary fix to solve line of business not defaulted by Mulesoft user
                try{
                    if(trigger.isInsert){
                        
                        //Temporary fix to remove dots from the Name fields
                        if(String.isNotBlank(opty.First_Name__c)){
                            opty.First_Name__c = opty.First_Name__c.contains('.') ? opty.First_Name__c.remove('.').trim() : opty.First_Name__c.trim();
                        }
                        if(String.isNotBlank(opty.Middle_Name__c)){
                            opty.Middle_Name__c = opty.Middle_Name__c.contains('.') ? opty.Middle_Name__c.remove('.').trim() : opty.Middle_Name__c.trim();
                        }
                        if(String.isNotBlank(opty.Last_Name__c)){
                            opty.Last_Name__c = opty.Last_Name__c.contains('.') ? opty.Last_Name__c.remove('.').trim() : opty.Last_Name__c.trim();
                        }
                    }
                }
                catch (Exception e){
                    ExceptionHandler.LogError('OpportunityTriggerHandler default lob', e.getMessage(),'OpportunityTriggerHandler', '', null);
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
    public void notifySpocForDSEAllocation(){
        try{
            set<Id> oppIdSet = new set<Id>();
            List<Opportunity> optyList = new list<Opportunity>(OpportunityTriggerHelper.spocOptyList);
            if(optyList.size()>0){
                for(Opportunity opp : optyList){
                    oppIdSet.add(opp.Id);
                }
                
                //If SPOC has been assigned
                if(oppIdSet.size()>0){
                    GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.SPOC_TO_ALLOT_DSE,oppIdSet,ConstantsUtility.OPPORTUNITY,'');
                }
            }
        }catch(Exception e){ExceptionHandler.LogError('OpportunityTriggerHandler notifySpocForDSEAllocation', e.getMessage(),'OpportunityTriggerHandler', '', null);
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
    public void createPreBookingFollowUp(){
        try{
            //if(AvoidRecursion.isPreBookingInsertRun()){
            
            //List of Followup tasks to be inserted
            List<Task> followUpTasksToInsert= new list<Task>();
            //Map to store enquiry Id as key and Prebooking Task Id as value
            map<String,Task> enquiryIdFollowUpIdMap = new map<String,Task>();
            
            //Get PreBooking Task Record type ID
            
            
            set<Id> customerIds = new set<Id>();
            for (Opportunity opp : this.newOppList){
                if (opp.Customer__c != null)
                    customerIds.add(opp.Customer__c);
            }
            
            Map<String, Account> accountIdWithObjMap = new Map<String, Account>();
            
            //Query PersonContact to poulate on Name ID field on task record.
            Map<Id,Account> mapAccount = new Map<Id,Account>([select id,personcontactid from Account where id in :customerIds]);
            
            for(Opportunity opp : this.newOppList){
                if(!AvoidRecursion.processedEnquiryIds.contains(opp.Id)){
                    //If Dealership is not blank
                    //Create Task record instance
                    Task followUp = new Task();
                    if(opp.Dealership__c!=null && opp.RecordTypeId==vehicleSalesId){
                        //Populate relevant fields on Task 
                        followUp = oppHelper.createTaskRecordInstance(opp, preBookingTaskRecordTypeId, ConstantsUtility.PRE_BOOKING_FOLLOWUP, ConstantsUtility.PREBOOKING_FOLLOWUP_TYPE);
                    }else if(opp.Dealership__c != null && opp.RecordTypeId == accessoriesSalesId){
                        //Populate relevant fields on Task 
                        followUp = oppHelper.createTaskRecordInstance(opp, generalTaskRecordTypeId, ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE, ConstantsUtility.GENERAL_FOLLOWUP_TYPE);
                    }
                    //Populate Name field on task Record
                    if (mapAccount.get(opp.Customer__c) != null)
                        followUp.Enquiry_Customer__c = mapAccount.get(opp.Customer__c).PersonContactId;
                    
                    enquiryIdFollowUpIdMap.put(opp.Id,followUp);
                    
                    //Recusrion Fix - Prabhat 17th Jan
                    AvoidRecursion.processedEnquiryIds.add(opp.Id);
                    
                }
                
                // Update Enquiry Exists CheckBox
                if(!accountIdWithObjMap.containsKey(opp.Customer__c))
                    accountIdWithObjMap.put(opp.Customer__c, new Account(Id = opp.Customer__c, SFMC_Sync__c = True, Enquiry_Exists__pc = True));
                accountIdWithObjMap.get(opp.Customer__c).SFMC_Sync__c = True;
                accountIdWithObjMap.get(opp.Customer__c).Enquiry_Exists__pc = True;
            }
            
            if(enquiryIdFollowUpIdMap.values().size()>0){
                //Create Pre-Booking Follow ups
                insert enquiryIdFollowUpIdMap.values();
                
                List<Opportunity> oppFieldsToUpdate = new List<Opportunity>();
                
                for(String enquiryId : enquiryIdFollowUpIdMap.keySet()){
                    Opportunity oppObj = new Opportunity();
                    oppObj.Current_Open_Follow_up__c = enquiryIdFollowUpIdMap.get(enquiryId).Id;
                    oppObj.Current_Follow_Up_Time__c = enquiryIdFollowUpIdMap.get(enquiryId).ReminderDateTime;
                    oppObj.Current_Follow_Up_Type__c = enquiryIdFollowUpIdMap.get(enquiryId).Type;
                    oppObj.Id = enquiryId;
                    oppFieldsToUpdate.add(oppObj);
                }
                
                //Update fields on Opportunity
                TriggerHandler.bypass('OpportunityTriggerHandler');
                update oppFieldsToUpdate;
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
            }
            
            if(accountIdWithObjMap.values() != Null && accountIdWithObjMap.values().size() > 0){
                TriggerHandler.bypass('AccountTriggerHandler');
                update accountIdWithObjMap.values();
                TriggerHandler.clearBypass('AccountTriggerHandler');
            }
            
            //}
        }catch(Exception e){    
            ExceptionHandler.LogError('OpportunityTriggerHandler createPreBookingFollowUp', e.getMessage(), 'OpportunityTriggerHandler', '', null); 
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
**/
    public void updateFieldsUsingSVOCID(){
        if(AvoidRecursion.isSVOCAfterRun()){
            try{
                //Map to have SVOC ID as key and Account ID as value
                map<string,string> svocIdAccountIdMap = new map<string,string>();
                
                //List to update all customers SVOC ID field
                map<Id,Account> accountToUpdate = new map<Id,Account>();
                
                //List to update all customers SVOC ID field
                list<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
                
                //List have Opportunities for which new Accounts will be created
                list<Opportunity> newAccountsForOpps = new List<Opportunity>();
                
                
                //Loop through trigger.new
                for(Opportunity opp : this.newOppList){
                    if(String.isNotBlank(opp.SVOC_ID__c) && opp.SVOC_ID__c!=this.oldOppMap.get(opp.Id).SVOC_ID__c){
                        svocIdAccountIdMap.put(opp.SVOC_ID__c,null);
                    }
                }
                
                //If there is a change in SVOC ID field, proceed further
                if(svocIdAccountIdMap.size()>0){
                    
                    //Map to store the search results for all accounts
                    map<string, string> searchResultMap = SVOCSearchUtility.searchCustomersBySVOCIds(svocIdAccountIdMap);
                    
                    //Query and loop through all the filtered enquiries
                    for(Opportunity opty : [SELECT Id,Name,Customer__c,SVOC_ID__c,Customer__r.Status__c,Customer__r.SVOC_ID__c,
                                            First_Name__c,Last_Name__c,Email__c,Mobile__c FROM Opportunity
                                            WHERE SVOC_ID__c in : svocIdAccountIdMap.keyset()]){
                                                
                                                //If customer NOT FOUND and previous value was a BLANK value
                                                if(searchResultMap.containsKey(opty.SVOC_ID__c) && String.isBlank(searchResultMap.get(opty.SVOC_ID__c)) &&
                                                   String.isBlank(this.oldOppMap.get(opty.Id).SVOC_ID__c)){
                                                       //Update customer SVOC ID field and no change in status
                                                       Account tempAcc = oppHelper.updateAccountSVOCDetails(opty, false, true);
                                                       accountToUpdate.put(tempAcc.Id,tempAcc);
                                                   }
                                                
                                                //If customer NOT FOUND and previous value was a NON BLANK value
                                                else if(searchResultMap.containsKey(opty.SVOC_ID__c) && String.isBlank(searchResultMap.get(opty.SVOC_ID__c)) &&
                                                        String.isNotBlank(this.oldOppMap.get(opty.Id).SVOC_ID__c)){
                                                            //Add enquiries for which new Accounts to be created
                                                            newAccountsForOpps.add(opty);
                                                            // If previous customer is a propsect, mark it as duplicate
                                                            Account tempAcc = oppHelper.updateAccountSVOCDetails(opty, false, false);
                                                            accountToUpdate.put(tempAcc.Id,tempAcc);
                                                            
                                                        }
                                                //If customer is FOUND and previous value was BLANK or a NON BLANK value
                                                else if(searchResultMap.containsKey(opty.SVOC_ID__c) && String.isNotBlank(searchResultMap.get(opty.SVOC_ID__c)) && 
                                                        opty.Customer__c!=searchResultMap.get(opty.SVOC_ID__c)){
                                                            // If previous customer is a propsect, mark it as duplicate
                                                            Account tempAcc = oppHelper.updateAccountSVOCDetails(opty, true, false);
                                                            accountToUpdate.put(tempAcc.Id,tempAcc);
                                                            // Update customer field on Enquiry with newly found Customer record
                                                            opty.Customer__c = searchResultMap.get(opty.SVOC_ID__c);
                                                            opportunitiesToUpdate.add(opty);
                                                        }
                                            }
                    
                    
                    //If new Accounts needs to be created
                    if(newAccountsForOpps.size()>0){
                        //Get the IDs of newly created customer accounts
                        map<string, string> newSearchResultMap = SVOCSearchUtility.createPersonAccounts(newAccountsForOpps);
                        
                        //Loop through all the enquiries and map the customer with newly created records
                        for(Opportunity newopty : [SELECT Id,SVOC_ID__c,Customer__c FROM Opportunity WHERE Id in : newAccountsForOpps]){
                            if(newSearchResultMap.containsKey(newopty.SVOC_ID__c) && String.isNotBlank(newSearchResultMap.get(newopty.SVOC_ID__c))){
                                newopty.Customer__c = newSearchResultMap.get(newopty.SVOC_ID__c);
                                opportunitiesToUpdate.add(newopty);
                            }
                        }
                    }
                    
                    //Update customer with SVOC Ids
                    if(accountToUpdate.size()>0){
                        update accountToUpdate.values();
                    }
                    
                    //Update Enquiries with new customer lookups
                    if(opportunitiesToUpdate.size()>0){
                        update opportunitiesToUpdate;
                    }
                    
                }
            }catch(Exception e){ExceptionHandler.LogError('OpportunityTriggerHandler updateFieldsUsingSVOCID', e.getMessage(), 'OpportunityTriggerHandler', '', null);
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
    public void changeEnquiryStage(){
        for(Opportunity opp : this.newOppList){ 
            
            if(opp.Retail_Cancellation_Date__c <> null && this.oldOppMap.get(opp.Id).Retail_Cancellation_Date__c == null){
                opp.stageName= ConstantsUtility.STAGE_BOOKING;
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
**/
    public void updateEnquiryName(){
        for (Opportunity opp: this.newOppList){
            String optyName ='';
            if(opp.First_Name__c!=null)
                optyName = opp.First_Name__c+ConstantsUtility.BLANK_SPACE;
            if(opp.Middle_Name__c!=null)
                optyName+= opp.Middle_Name__c+ConstantsUtility.BLANK_SPACE;
            if(opp.Last_Name__c!=null)
                optyName+= opp.Last_Name__c+ConstantsUtility.BLANK_SPACE;
            
            opp.Name = optyName;
            
            if(opp.RecordTypeId == vehicleSalesId){
                opp.Name += ConstantsUtility.OPEN_BRACKET+ConstantsUtility.NEWCAR_ENQ+ConstantsUtility.CLOSE_BRACKET;
            }else{
                opp.Name += ConstantsUtility.OPEN_BRACKET+ConstantsUtility.ACCESSORIES_ENQ+ConstantsUtility.CLOSE_BRACKET;
            }
            
            
            //whenever Gate_Pass_Date__c is null and StageName equals to Retail
            if(opp.Gate_Pass_Date__c != null && opp.StageName == ConstantsUtility.RETAIL_NAME && (trigger.isInsert || (trigger.IsUpdate && this.oldOppMap.get(opp.Id).Gate_Pass_Date__c==null))){
                opp.StageName = ConstantsUtility.DEL_CLOSED_WON_NAME;
                opp.CloseDate = System.today();
            }
            //whenever stage is changing from new to PreBooking or Booking 
            if(trigger.isUpdate && opp.StageName == ConstantsUtility.STAGE_NEW && (this.oldOppMap.get(opp.id).StageName == ConstantsUtility.STAGE_PREBOOKING || this.oldOppMap.get(opp.id).StageName == ConstantsUtility.STAGE_BOOKING)){
                opp.Pre_Booking_Number__c = null;
                opp.Booking_Number__c = null;
                opp.Pre_booking_Submission_Date__c = null;
            }
            //Whenever Enquiry Color is populated first time 
            if(opp.Color__c!=null && (trigger.IsInsert || (trigger.isUpdate && this.oldOppMap.get(opp.id).Color__c!=null)))
                opp.Color_Captured_Time__c = DateTime.now();
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
**/
    public void createMCrecordsOnDSEAllocationOrUntagging(){
        //Set to have Opportunity Ids if Owner is a DSE
        set<Id> userIdSet = new set<Id>();
        //set to have filtered Opportunity Ids where owner is DSE
        set<Id> dseAllocationOppIdSet = new set<Id>();
        //set to have filtered Opportunity Ids where DSE is untagged
        set<Id> dseUntaggedOppIdSet = new set<Id>();
        
        
        for(Opportunity opp : this.newOppList){
            //Check if owner has changed
            if(trigger.isInsert || (trigger.isUpdate && ((opp.OwnerId != this.oldOppMap.get(opp.id).OwnerId)))){
                userIdSet.add(opp.OwnerId);
                if(trigger.isUpdate){
                    userIdSet.add(this.oldOppMap.get(opp.id).OwnerId);
                }
            }
        }
        
        if(userIdSet.size()>0){
            Map<Id,User> userIdMap = new map<Id,User>([SELECT Id,Title,Profile.Name FROM User WHERE Id in: userIdSet]);
            
            //Loop through all new/old Opportunity
            for(Opportunity opp : this.newOppList){
                //Check for DSE Allocation to an Enquiry
                if(userIdMap.containsKey(opp.OwnerId) && String.isNotBlank(userIdMap.get(opp.OwnerId).Profile.Name) && userIdMap.get(opp.OwnerId).Profile.Name==ConstantsUtility.DSE_PROFILE_NAME){
                    dseAllocationOppIdSet.add(opp.Id);
                }
                //Check for DSE Untagged
                if(trigger.isUpdate && userIdMap.containsKey(this.oldOppMap.get(opp.id).OwnerId) && 
                   String.isNotBlank(userIdMap.get(this.oldOppMap.get(opp.id).OwnerId).Profile.Name) && 
                   userIdMap.get(this.oldOppMap.get(opp.id).OwnerId).Profile.Name==ConstantsUtility.DSE_PROFILE_NAME){
                       dseUntaggedOppIdSet.add(opp.Id);
                   }
            }
            
            //Create Marketing communication records for DSE Allocation
            if(dseAllocationOppIdSet.size()>0){
                GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.DSE_ALLOCATION,dseAllocationOppIdSet,ConstantsUtility.OPPORTUNITY,'');
            }
            
            //Create Marketing communication records for Untagged DSEs
            if(dseUntaggedOppIdSet.size()>0){
                GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.DSE_UNTAGGED,dseUntaggedOppIdSet,ConstantsUtility.OPPORTUNITY,'');
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
    public void closedFollowup(){
        
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Opportunity opp :newOppList){
            //oldOppMap != Null && oldOppMap.containsKey(opp.Id) && oldOppMap.get(opp.id).stageName != opp.stageName &&
            // above conditions removed by Rohit as discussed with Rahul.
            if(opp.stageName == ConstantsUtility.RETAIL_NAME || opp.stageName == ConstantsUtility.STAGE_CLOSELOST )
            {
                opportunityIdSet.add(opp.id);
            }
        }
        List<Task> taskList = new List<Task>();
        if(opportunityIdSet.size() > 0){
            for(Task tsk : [select id, Status, WhatId from Task Where WhatId IN : opportunityIdSet 
                            AND Status =: ConstantsUtility.STATUS_OPEN])
            {
                tsk.Status = ConstantsUtility.STATUS_COMPLETED;
                taskList.add(tsk);
            }
            if(taskList.size() > 0){
                update taskList;
            }
        }
    }
 /**
Author: Rohit
Description: Close all the Pre booking followups when enquiry stage changes to Booking 
Returns: void
History:
Last Modified By:
====================================================

**/
    public void closePreBookingFollowups(){
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Task> taskList = new List<Task>();
        
        for(Opportunity opp: newOppList){
            if(opp.StageName == ConstantsUtility.STAGE_BOOKING){
                opportunityIdSet.add(opp.Id);
            }
        }
        
        if(opportunityIdSet.size() > 0){
        
            for(Task task: [SELECT Id, Status, WhatId FROM TASK WHERE WhatId IN: opportunityIdSet AND Status =: ConstantsUtility.STATUS_OPEN 
                            AND RecordType.Name =: ConstantsUtility.PRE_BOOKING_FOLLOWUP]){
                task.Status = ConstantsUtility.STATUS_COMPLETED;
                taskList.add(task);
            }
            
            if(taskList.size() > 0 ){
                update taskList;
            }
            
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
    public void updateCustomerAttributes(){
        
        try{
            set<id> customerIdSet = new set<id>();//vairable to store the customer IDs.
            
            for(Opportunity opp :newOppList){
                //If the customer if not blank then add the Ids.
                if(opp.customer__c != null){
                    customerIdSet.add(opp.Customer__c);
                }
            }
            
            
            //Fetch the customer details if the customers have been populated,
            if(customerIdSet.size() > 0){
                
                //Map for key as Opportunity field and value as Account field
                map<String,String> optyAcctFieldMap = new map<String,String>();
                
                String query = 'SELECT Id,';
                
                //Loop through custom metadata type to get all the fields
                //Builds SOQL string for query
                for(Customer_Attribute_Mapping__mdt  fields : [SELECT Account_Field_API__c,Opportunity_Field_API__c FROM Customer_Attribute_Mapping__mdt]){
                    query+=fields.Account_Field_API__c+ConstantsUtility.COMMA;
                    if(fields.Opportunity_Field_API__c != Null){
                        optyAcctFieldMap.put(fields.Opportunity_Field_API__c,fields.Account_Field_API__c);    
                    }                                                                                                    
                }
                
                
                query = query.removeEnd(ConstantsUtility.COMMA);
                query+=' FROM Account WHERE Id in: customerIdSet';
                
                map<Id,Account> customerMap = new map<Id,Account>((List<Account>)Database.query(query));
                
                for(Opportunity opp : newOppList){
                    Account acc = customerMap.get(opp.customer__c);
                    
                    //Loop through all the fields and map it with Opportuntiy fields
                    for(String field : optyAcctFieldMap.keySet()){
                        String acctField = optyAcctFieldMap.get(field);
                        if(acc!=null && opp.get(field)==null){
                            opp.put(field,acc.get(acctField));
                        }
                    }
                    
                    //Copying address from Customer to Enquiry
                    if(opp.customer__c != null){    
                        copyAccountAddress(opp.recordTypeId, opp, acc); 
                    }
                    
                    
                }
            }
        }catch(Exception ex){ ExceptionHandler.LogError('OpportunityTriggerHandler - updateCustomerAttributes', ex.getMessage(), 'Opportunity',null, null); throw new unexpectedException('An exception has occurred. Please contact your salesfore administrator');}    
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
    public opportunity copyAccountAddress(String recordTypeId, Opportunity opp, Account acc){   
        
        Integer billingStreetLength = acc.BillingStreet != Null ? acc.BillingStreet.length() : ConstantsUtility.ZERO;   
        
        if(opp.recordTypeId == vehicleSalesId){ 
            return updateAddressFields(ConstantsUtility.BILL_To_ADDRESS_LINE_FIELD, billingStreetLength, ConstantsUtility.THIRTY, opp, acc);    
        }else if(opp.recordTypeId == accessoriesSalesId){   
            return updateAddressFields(ConstantsUtility.ADDRESS_LINE_FIELD, billingStreetLength, ConstantsUtility.FIFTY, opp, acc); 
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
    public static opportunity updateAddressFields(string firstField, Integer billingStreetLength, Integer firstFieldIndex, Opportunity opp, Account acc){   
        
        if(billingStreetLength > firstFieldIndex){  
            opp.put(firstField, acc.BillingStreet.subString(ConstantsUtility.ZERO, firstFieldIndex));   
            
            if(billingStreetLength >= (firstFieldIndex + ConstantsUtility.THIRTY)){ 
                opp.BillTo_Address_Line_2__c = acc.BillingStreet.subString(firstFieldIndex, firstFieldIndex + ConstantsUtility.THIRTY); 
            }else if( (billingStreetLength > firstFieldIndex) && (billingStreetLength < (firstFieldIndex + ConstantsUtility.THIRTY))){  
                opp.BillTo_Address_Line_2__c = acc.BillingStreet.subString(firstFieldIndex, billingStreetLength);   
            }   
            
            if(billingStreetLength >= (firstFieldIndex + ConstantsUtility.SIXTY)){  
                opp.BillTo_Address_Line_3__c = acc.BillingStreet.subString(firstFieldIndex + ConstantsUtility.THIRTY, firstFieldIndex + ConstantsUtility.SIXTY);    
            }else if((billingStreetLength > (firstFieldIndex + ConstantsUtility.THIRTY)) && (billingStreetLength < (firstFieldIndex + ConstantsUtility.SIXTY))){    
                opp.BillTo_Address_Line_3__c = acc.BillingStreet.subString(ConstantsUtility.SIXTY, billingStreetLength);    
            }   
        }else{  
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
    public void populateVariantChangesCount(){
        
        List<String> profileNameList = system.label.By_Pass_Variant_Changes != Null ? 
            system.label.By_Pass_Variant_Changes.split(';') : 
        new List<String>();
        
        List<User> userInfo = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        
        for(opportunity opp : this.newOppList){
            if(this.oldOppMap == Null  && opp.Variant__c != Null){
                opp.Variant_Modified_Count__c = 1;
            }else if(this.oldOppMap != Null && this.newOppList != Null){
                
                if(userInfo != Null && profileNameList != Null && !profileNameList.contains(userInfo[0].Profile.Name)){
                    
                    Integer countLimit = system.label.Restrict_variant_count_limit != Null ? Integer.valueOf(system.label.Restrict_variant_count_limit) : 0;
                    if(this.oldOppMap.get(opp.Id).Variant__c != opp.Variant__c && opp.Variant_Modified_Count__c > countLimit){
                        opp.addError(system.label.Variant_Changes_Count_Msg);
                    }else if(opp.Variant__c != Null && this.oldOppMap.get(opp.Id).Variant__c != opp.Variant__c){
                        opp.Variant_Modified_Count__c = opp.Variant_Modified_Count__c!=null? opp.Variant_Modified_Count__c + 1 : 1;
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
1.0  Subhojit  10 Dec 2019      Initial Version 
**/
    public void createDummyAccountOnOpportunity(){
        try{ 
            Map<Opportunity,Account> mapOppNewDummyAccount=new Map<Opportunity,Account>();
            String sCustomerrecTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.CUSTOMER_RECORDTYPE).getRecordTypeId();
            for(Opportunity oppVar: this.newOppList){
                if(oppVar.Customer__c==null){
                    Account accVar=new Account();
                    accVar.RecordtypeId=sCustomerrecTypeId;
                    accVar.FirstName=oppVar.First_Name__c;
                    accVar.LastName=oppVar.Last_Name__c;
                    if(accVar.LastName==null)
                        accVar.LastName='.';
                    accVar.PersonEmail=oppVar.Email__c;
                    accVar.PersonMobilePhone=oppVar.Mobile__c;
                    accVar.Status__c=ConstantsUtility.PROSPECT_CUSTOMER;
                    accVar.PersonBirthDate=oppVar.Birthdate__c;
                    accvar.OwnerId=system.label.Integration_User;
                    mapOppNewDummyAccount.put(oppVar,accVar);
                }
                
            }
            if(mapOppNewDummyAccount.size()>0){
                insert mapOppNewDummyAccount.values();
                
                for(Opportunity oppVar: mapOppNewDummyAccount.keySet())
                    oppVar.Customer__c=mapOppNewDummyAccount.get(oppVar).Id;
            }
        }
        catch(Exception e){ExceptionHandler.LogError('OpportunityTriggerHandler createDummyAccountOnOpportunity', e.getMessage(), 'OpportunityTriggerHandler', '', null); }
    } 
    
    /**
Author: Rahul Raghunathan
Description: Method to prevent the update from stage to New when in prebooking by Mulesoft User.
Returns: void

====================================================
1.0  Rahul Raghunathan  06 Jan 2020      Initial Version 
**/
    
    public void preventWrongStageChange(){
        
        //Check if the new stage is new and previous stage is present in custom setting AvoidStageChanges,
        //then revert the change. Avoidstagechanges will hold stage name in a pattern of :<stagename>:
        Custom_Validation_Exception_Setting__c currSetting = Custom_Validation_Exception_Setting__c.getInstance(userInfo.getUserId());
        String preventStages = 'none';
        if (currSetting != null){
            preventStages = currSetting.AvoidStageChanges__c;
        }
        
        if(preventStages!=null){ 
            for(Opportunity opp :newOppList){
                if((opp.stageName == 'New') && preventStages != null && oldOppMap.get(opp.id) != null && oldOppMap.get(opp.id).StageName != 'New'  
                   && (preventStages.contains(':' + oldOppMap.get(opp.id).StageName + ':'))){
                       opp.stageName = oldOppMap.get(opp.id).StageName;
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
    public void updateGenderAndCustomerType()
    {
        String MuleUserId = [select id from user where name =: ConstantsUtility.DMS_USER].ID;
        String CurrentUserId = UserInfo.getUserId(); 
       
        //Loop through Opportunities
        for(Opportunity opp : this.newOppList){
            if(opp.Gender__c == null)
                opp.Gender__c = 'M';
            if(opp.Customer_Type__c == null)    
                opp.Customer_Type__c = 'I';
            
            //functionality to update 'If other Employees' field if user is Mule and 'Employer Name' is 'Others'
            if(MuleUserId == CurrentUserId && opp.Employer_Name__c != null && opp.Employer_Name__c == Label.Other_Employer_Id && opp.If_Other_Employers__c == null)
             {
              opp.If_Other_Employers__c = ConstantsUtility.OTHER_VALUE;  
              }
              
            if(trigger.isUpdate && opp.Line_Of_Business__c == null && opp.Temporary_LOB_Admin_use__c != null){
                opp.Line_Of_Business__c = opp.Temporary_LOB_Admin_use__c;
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
    
        String MuleUserId = [select id from user where name =: ConstantsUtility.DMS_USER].ID;
        String CurrentUserId = UserInfo.getUserId();
		String error;
        for(Opportunity opportunity: this.newOppList){
			if(opportunity.DMS_Sync_Error_Details__c == null)
                error = 'abc';
            else    
                error  =  opportunity.DMS_Sync_Error_Details__c;
            if(MuleUserId == CurrentUserId && (opportunity.StageName == ConstantsUtility.STAGE_PREBOOKING || opportunity.StageName == ConstantsUtility.STAGE_NEW) && error.contains('EMPLOYEE APPROVAL STATUS IS PENDING FOR USERID:')){
               
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
}