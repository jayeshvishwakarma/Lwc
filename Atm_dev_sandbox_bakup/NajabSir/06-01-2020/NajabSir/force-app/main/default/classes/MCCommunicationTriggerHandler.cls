/**
* @File Name          : MCCommunicationTriggerHandler.cls
* @Description        : Trigger handler class for MC COmmunication
* @Author             : 
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 1/10/2020, 1:55:22 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    14/11/2019, 3:12:16 PM                              Initial Version 
**/

//CODE REVIEWED BY: Prabhat Sharma

public without sharing class MCCommunicationTriggerHandler extends TriggerHandler {
    
    private Map<Id, MC_Communication__c > newMcComMap;
    private List<MC_Communication__c > newMcComList;
    private Map<Id, MC_Communication__c > oldMcComMap;
    
    //Added by Anas Yar Khan
    public static List<String> listEscalationLevel;
    public static Map<String,MOS_Time_dependent_Communication__mdt> mapKeyToCommunicationRecords;
    public static List<Account> listMSAllianzRecord = CaseTriggerHelper.getMSAllianzRecord();
    public static Set<String> setRole = new Set<String>();
    public static Set<String> setContact = new Set<String>();
    public static Set<String> setDesignation = new Set<String>();
    public static Set<String> setStakeHolder = new Set<String>();
    public static Map<String,String> mapDesignationMSAllianzToPhoneNumbers;
    public static Map<String,Set<String>> mapRoleToPhoneNumbers;
    public static Map<String,String> mapTechnicianIdToPhoneNumbers;
    public static Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers;
    //constructor
    public MCCommunicationTriggerHandler() {
        this.newMcComMap = (Map<Id, MC_Communication__c >) Trigger.newMap;
        this.newMcComList = (list<MC_Communication__c >) Trigger.New;
        this.oldMcComMap = (Map<Id, MC_Communication__c >) Trigger.oldMap;
    }
    
    //Method for before insert
    public override void beforeInsert() {
        updateCustomerOnMCCommunication();
        updateBrochureURLs();
        caseEscalationsUpdatePhoneEmail();
    }
    
    //Method for before insert
    public override void afterInsert() {
        chatterPostToNotifyDSE();
        //Added by Anas Yar Khan
        updateOtherMCCommunicationAsCancelled();
        createTaskCustomer();
    }
    
    //Method for after update 
    public override void afterUpdate() {
        updateEscalationFlagOnEnquiry();
        caseEscalationsFieldUpdate();
        // added by zakir on 14-10-2020
        bulkHoldUnholdReminder(); 
        //Added by Anas Yar Khan on 28th July 2020
        listEscalationLevel = getPicklistValues();
        mapKeyToCommunicationRecords = getMOSCommunicationRecords();
        updateEscalationLevelOnCaseAction();
        sendChatterNotification();
    }
        /**
Author: Gitika 
Description: Method to send chatter notifications
Inputs: None
Returns: void
History:
====================================================
1.0  5/11/2020, 3:12:16 PM  
**/
public void sendChatterNotification(){
    CaseEscalationService.sendChatterNotifications(newMcComList);
}
    /**
Author: Rajesh Ramachandran
Description: Method to update the Brochure URLs in URL field.
Inputs: None
Returns: void
History:
====================================================
1.0  10/01/2020, 3:12:16 PM  Rajesh Ramachandran  Initial Version
1.0  10/30/2020, 3:12:16 PM  Nitin Ghai  Added Conditions for ATM
**/
    public void updateBrochureURLs() {
        List<BrochureURL__mdt> brUrl = [select id,MasterLabel, DeveloperName, Brochure_URL__c from BrochureURL__mdt];
        if (brUrl == null || brUrl.size() == 0)
            return;
        Map<String, String> mapModelToURl = new Map<String, String>();
        for (BrochureURL__mdt br : brUrl) {
            mapModelToURl.put(br.masterLabel, br.Brochure_URL__c);
        }
        map<String,String> modelMap = EmailQuotePDFCtrl.modelCodeLabelMap(); //Added by Nitin
        for (MC_Communication__c mc : newMcComList) {
            if (mc.type__c == 'Send Brochure' && mc.General_Field_2__c != null && mc.Case__c==NULL) {
                mc.URL_1__c = mapModelToURl.get(mc.General_Field_2__c);
            }else if(mc.type__c == ConstantsUtility.SEND_BROCHURE_METADATA && mc.General_Field_2__c != null && mc.Case__c!=NULL) {
                mc.URL_1__c = mapModelToURl.get(modelMap.get(mc.General_Field_2__c));
            }else if(mc.type__c == ConstantsUtility.Accessories_Brochure && mc.General_Field_2__c != null && mc.Case__c!=NULL) {
                mc.URL_1__c = mapModelToURl.get(modelMap.get(mc.General_Field_2__c));
            }else if(mc.type__c == ConstantsUtility.Car_Configurator_Link && mc.Case__c!=NULL) {
                mc.URL_1__c = mapModelToURl.get(mc.type__c);
            }else if(mc.type__c == ConstantsUtility.Showroom_Visit && mc.Case__c!=NULL) {
                mc.URL_1__c = mapModelToURl.get(mc.type__c);
            }else if(mc.type__c == ConstantsUtility.Owner_Manual && mc.Case__c!=NULL) {
                mc.URL_1__c = mapModelToURl.get(mc.type__c);
            }
        }
    }
    
    /**
Author: Anuj Kumar
Company: Techmatrix
Description: Method to update the Customer from Related enquiry.
Inputs: None
Returns: void
History:
====================================================
1.0  18/12/2019, 3:12:16 PM  Anuj Kumar  Initial Version
**/
    public void updateCustomerOnMCCommunication() {
        
        Map<String, String> enquiryIdWithCustomerMap = new Map<String, String>();
        
        //Loop through MC Communication
        for (MC_Communication__c mc : newMcComList) {
            if (mc.Enquiry_MD__c != null) {
                enquiryIdWithCustomerMap.put(mc.Enquiry_MD__c, null);
            }
        }
        
        //Loop through Enquiries
        for (Opportunity opp : [Select id, customer__c from Opportunity Where Id IN:enquiryIdWithCustomerMap.keySet()]) {
            if (opp.customer__c != null)
                enquiryIdWithCustomerMap.put(opp.Id, opp.customer__c);
        }
        
        //Assign Customer field
        if (enquiryIdWithCustomerMap != Null && enquiryIdWithCustomerMap.size() > 0) {
            for (MC_Communication__c mc : newMcComList) {
                if (mc.Enquiry_MD__c != null && enquiryIdWithCustomerMap.containsKey(mc.Enquiry_MD__c)) {
                    mc.Customer__c = enquiryIdWithCustomerMap.get(mc.Enquiry_MD__c);
                }
            }
        }
        
    }
    
    
    /**
Author: Prabhat Sharma
Company: Techmatrix
Description: Method to update the Escalation flag to true once the Escaltion message is sent for a level
Inputs: None
Returns: void
History:
====================================================
1.0  14/11/2019, 3:12:16 PM  Prabhat Sharma  Initial Version
**/
    public void updateEscalationFlagOnEnquiry() {
        try {
            //set to store the enqiuiry Ids
            set<Id> enquiryIds = new set<Id>();
            list<MC_Communication__c> validMCComms = new list<MC_Communication__c>();
            for (MC_Communication__c mcCom : this.newMcComList) {
                //Check if type is Escalation and SFMC Flag is set to true
                if (mcCom.Type__c == ConstantsUtility.ESCALATION_MC_TYPE && mcCom.SFMC_Flag__c && !this.oldMcComMap.get(mcCom.Id).SFMC_Flag__c) {
                    enquiryIds.add(mcCom.Enquiry_MD__c);
                    validMCComms.add(mcCom);
                }
            }
            
            //Only if the above criteria is true mark the Escalation flag to true 
            if (enquiryIds.size() > 0) {
                list<Opportunity> oppToUpdate = new list<Opportunity>();
                map<Id, Opportunity> enquiryMap = new map<Id, Opportunity>([SELECT Id,Type_of_Escalation__c,Time_for_Next_Escalation__c FROM Opportunity WHERE Id in:enquiryIds]);
                
                for (MC_Communication__c mcCom : validMCComms) {
                    if (String.isNotBlank(mcCom.General_Field_1__c) && mcCom.Escalation_Date_Time__c != null && mcCom.Enquiry_MD__c != null) {
                        if (enquiryMap.containsKey(mcCom.Enquiry_MD__c) && enquiryMap.get(mcCom.Enquiry_MD__c).Type_of_Escalation__c == mcCom.General_Field_1__c &&
                            enquiryMap.get(mcCom.Enquiry_MD__c).Time_for_Next_Escalation__c == mcCom.Escalation_Date_Time__c) {
                                Opportunity opp = new Opportunity();
                                opp.Escalated__c = true;
                                opp.Id = mcCom.Enquiry_MD__c;
                                oppToUpdate.add(opp);
                            }
                    }
                }
                
                if (oppToUpdate.size() > 0) {
                    update oppToUpdate;
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('MCCommunicationTrigger', e.getMessage(), 'MC Communication', null, null);
        }
        
    }
    
    /**
Author: Prabhat Sharma
Company: Techmatrix
Description: Method to create chatter post when hostess clicks on Notify DSE button
Inputs: None
Returns: void
History:
====================================================
1.0  03/02/2020, 3:12:16 PM  Prabhat Sharma  Initial Version
**/
    public void chatterPostToNotifyDSE() {
        
        map<Id, Id> enquirySalesUsersMap = new map<Id, Id>();
        //Loop through MC Communication
        for (MC_Communication__c mc : newMcComList) {
            if (mc.Type__c == ConstantsUtility.SHOWROOM_WELCOME && mc.Enquiry_MD__c != null && mc.Internal_User__c != null) {
                enquirySalesUsersMap.put(mc.Enquiry_MD__c, mc.Internal_User__c);
            }
        }
        
        //Create Chatter Post
        if (enquirySalesUsersMap.keySet().size() > 0) {
            //For bulk chatter post
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            
            for (Id enquiryId : enquirySalesUsersMap.keySet()) {
                //Create chatter message body
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                //Create text message for chatter
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                //Feed element input
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                
                String messageBody = label.Notify_DSE_Chatter_Message ;
                
                //Add the message body in body input of feedElement
                textSegmentInput.text = messageBody + ' ';
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                //Add all the users id to receive chatter post and notification
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = enquirySalesUsersMap.get(enquiryId);
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                
                
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
            //Post to chatter
            if (!test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        }
        
    }
    
    /**
Author: Deepak Kumar
Company: Techmatrix
Description:
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        11/06/2020                Deepak Kumar              Initial Version
**/
    public void caseEscalationsFieldUpdate() {
        try {
            Set<Id> caseActionsIds = new Set<Id>();
            for (MC_Communication__c mcCommunication : newMcComList) {
                if (mcCommunication.Status__c == 'Picked' && string.isBlank(oldMcComMap.get(mcCommunication.Id).Status__c)  
                    && mcCommunication.Type__c == ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE
                    && mcCommunication.Escalation_Date_Time__c != null && mcCommunication.Case_Action__c != null) {
                        caseActionsIds.add(mcCommunication.Case_Action__c);
                    }
            }
            if (caseActionsIds.size() > 0) {
                List<Case_Actions__c> caseActionsToUpdate = new List<Case_Actions__c>();
                for (Case_Actions__c caseActions : [SELECT Transfer_Escalation_Date_Time__c FROM Case_Actions__c WHERE Id IN:caseActionsIds]) {
                    caseActions.Transfer_Escalation_Date_Time__c = caseActions.Transfer_Escalation_Date_Time__c.addDays(1);
                    caseActionsToUpdate.add(caseActions);
                }
                if (caseActionsToUpdate.size() > 0) {
                    update caseActionsToUpdate;
                }
            }
        } catch (Exception exp) {
            System.debug('Exception  Message :: ' + exp.getMessage() + ' At ' + exp.getStackTraceString());
            ExceptionHandler.LogError('MCCommunicationTrigger', exp.getMessage(), 'MC Communication', null, null);
        }
    }
    //Added By zakir- 14-10-2020
    public void bulkHoldUnholdReminder(){
        try {
            Set<Id> caseActionsId = new Set<Id>();
            Set<Id> caseActionId = new Set<Id>();
            map<Id,set<string>> mapCaseActionIdToUser = new map<Id,set<string>>();
            map<Id,string> mapCaseTypeToCaseNumber = new map<Id,string>();
            for (MC_Communication__c mcCommunication : newMcComList) {
                caseActionId.add(mcCommunication.Case_Action__c);
            }
             if(caseActionId.size() > 0)
            {
                for(Case_Actions__c caseAction :[select Id,Case_Type__c,Case_Number_Text__c,Hold_Till_Date__c,L1_Stakeholder__c,L2A_Stakeholder__c, L3A_Stakeholder__c 
                                                 from Case_Actions__c where Id IN : caseActionId ]){
                     set<string> userList = new set<string>();
                   string chatterMessage = 'Chatter message '+caseAction.Case_Type__c+' ref. no. '+caseAction.Case_Number_Text__c+' hold would expire on '+ caseAction.Hold_Till_Date__c +1 ;
                     userList.add(caseAction.L1_Stakeholder__c); 
                    userList.add(caseAction.L2A_Stakeholder__c);
                    userList.add(caseAction.L3A_Stakeholder__c);
                    mapCaseActionIdToUser.put(caseAction.id,userList) ;
                    mapCaseTypeToCaseNumber.put(caseAction.Id,chatterMessage);                               
                }
            }
            if(mapCaseActionIdToUser.keyset().size() > 0 && mapCaseTypeToCaseNumber.keyset().size() > 0 ){
                system.debug('chatter notification');
                ChatterNotificationUtil.sendChatterNotification(mapCaseActionIdToUser,mapCaseTypeToCaseNumber);
             }
        }
        catch (Exception exp) {
            System.debug('Exception  Message :: ' + exp.getMessage() + ' At ' + exp.getStackTraceString());
        }
    }
    
    
    /**
Author: Deepak Kumar
Company: Techmatrix
Description:
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        11/06/2020                Deepak Kumar              Initial Version
**/
    public void caseEscalationsUpdatePhoneEmail() {
        try {
            Set<Id> internalUserIds = new Set<Id>();
            for (MC_Communication__c mcCommunication : newMcComList) {
                if (mcCommunication.Type__c == ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE && mcCommunication.Internal_User__c != null) {
                    internalUserIds.add(mcCommunication.Internal_User__c);
                }
            }
            Map<Id, User> internalUserMap = new Map<Id, User>();
            for (User user : [SELECT Id, MobilePhone,Email FROM User WHERE Id IN:internalUserIds]) {
                internalUserMap.put(user.Id, user);
            }
            for (MC_Communication__c mcCommunication : newMcComList) {
                if (mcCommunication.Type__c == ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE && mcCommunication.Internal_User__c != null) {
                    mcCommunication.Email_1__c = internalUserMap.get(mcCommunication.Internal_User__c).Email;
                    mcCommunication.Phone_1__c = internalUserMap.get(mcCommunication.Internal_User__c).MobilePhone;
                }
            }
        } catch (Exception exp) {
            System.debug('Exception  Message :: ' + exp.getMessage() + ' At ' + exp.getStackTraceString());
            ExceptionHandler.LogError('MCCommunicationTrigger', exp.getMessage(), 'MC Communication', null, null);
        }
    }
        /*
Author : Gitika
Company : Techmatrix Consulting
Description : This method is used to Create Task Whenever MC Commuincation Type contains Customer
*/  
    public void createTaskCustomer() {
        List<Task> TaskList = new List<Task>();
        try {
          for(MC_Communication__c mcCommunication : newMcComList){
            if(mcCommunication.type__c!=null && mcCommunication.type__c.contains('Customer') && mcCommunication.case__c!=null){
                TaskList.add(new Task (Whatid=mcCommunication.case__c,Subject='Interaction History-'+mcCommunication.type__c));   
              }
          }
          insert TaskList;
         }
         catch(Exception exp) {
            ExceptionHandler.LogError('MCCommunicationTriggerHandler', exp.getMessage() +':'+exp.getLineNumber(), 'createTaskCustomer', null, null);    
        }
        }

    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to update the Escalation Level of Case Action when the Status changed to Picked
*/
    public void updateEscalationLevelOnCaseAction() {
        try {
            Set<Id> setCaseActionId = new Set<Id>();                    //Set to store case action Id
            List<Case_Actions__c> listCaseActionToUpdate = new List<Case_Actions__c>();       //list to store case actions records to be updated
            Map<Id,Case> mapIdToCase = new Map<Id,Case>();               //Map to store case
            List<MC_Communication__c> listTimeDependentMCRecords = new List<MC_Communication__c>();   //list of MC records that are independent of MOS Escalations
            Set<Id> setCaseId = new Set<Id>();                          //Set to store Case id
            
            for (MC_Communication__c mcRecord : newMcComList) {
                if (mcRecord.Status__c == ConstantsUtility.MC_Communication_Status_Picked
                    && mcRecord.Status__c != oldMcComMap.get(mcRecord.Id).Status__c) {
                        if(mcRecord.Case_Action__c != NULL) {
                            setCaseActionId.add(mcRecord.Case_Action__c);
                        }
                        if(mcRecord.Counter__c != NULL && mcRecord.Case__c != NULL) {
                            listTimeDependentMCRecords.add(mcRecord);
                            setCaseId.add(mcRecord.Case__c);    
                        }
                        
                    }
            }
            
            if (setCaseActionId.size() > 0) {
                for (Case_Actions__c caseActionObj : [SELECT Id,Escalation_Level__c,Case_Number__c 
                                                      FROM Case_Actions__c 
                                                      WHERE Id IN :setCaseActionId 
                                                      AND RecordTypeId = :ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id]) {
                                                          if (listEscalationLevel.indexOf(caseActionObj.Escalation_Level__c) != listEscalationLevel.size() - 1) {
                                                              caseActionObj.Escalation_Level__c = listEscalationLevel.get(listEscalationLevel.indexOf(caseActionObj.Escalation_Level__c) + 1);
                                                              listCaseActionToUpdate.add(caseActionObj);
                                                              
                                                              if(caseActionObj.Case_Number__c != NULL) {
                                                                  Case caseObj = new Case();
                                                                  caseObj.Id = caseActionObj.Case_Number__c;
                                                                  if(caseActionObj.Escalation_Level__c == ConstantsUtility.Red) {
                                                                      caseObj.Priority = ConstantsUtility.PRIORITY_MEDIUM;
                                                                  }  
                                                                  else if(caseActionObj.Escalation_Level__c == ConstantsUtility.RedPlus)  {
                                                                      caseObj.Priority = ConstantsUtility.PRIORITY_HIGH;   
                                                                  }
                                                                  mapIdToCase.put(caseActionObj.Case_Number__c,caseObj);
                                                              }
                                                          }
                                                      }
            }
            
            if(listTimeDependentMCRecords.size() > 0 && setCaseId.size() > 0) {
                List<MC_Communication__c> listMCCommunicationRecordToInsert = new List<MC_Communication__c>();
                Map<Id,Case> mapIdToMOSCase = new Map<Id,Case>([SELECT Id,Job_Type__c,MOS_Case_Stage__c,MOS_Case_Source__c,Allocated_Dealer__c,Technician_Id__c,Channel__c 
                                                                FROM Case 
                                                                WHERE Id IN :setCaseId 
                                                                AND RecordTypeId = :ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID]);
                
                if(mapIdToMOSCase != NULL && mapIdToMOSCase.keySet().size() > 0 && mapKeyToCommunicationRecords != NULL && mapKeyToCommunicationRecords.keySet().size() > 0) {
                    
                    Set<Id> setTechicianId = new Set<Id>();
                    Set<Id> setAllocatedDealerId = new Set<Id>();
                    Boolean msAllianz = false;
                    for(Id caseId : mapIdToMOSCase.keySet()) {
                        Case caseObj = mapIdToMOSCase.get(caseId);
                        if(caseObj.Technician_Id__c != NULL) {
                            setTechicianId.add(caseObj.Technician_Id__c);
                        }
                        if(caseObj.Allocated_Dealer__c != NULL) {
                            setAllocatedDealerId.add(caseObj.Allocated_Dealer__c); 
                            if(listMSAllianzRecord[0].Id == caseObj.Allocated_Dealer__c) {
                                msAllianz = true;        
                            }
                        }
                    }
                    
                    getMCCommunicationAudiencePhoneNumbers(setTechicianId,setAllocatedDealerId,msAllianz,listMSAllianzRecord);
                    
                    for(MC_Communication__c mcRecord : listTimeDependentMCRecords) {
                        if(mapIdToMOSCase.containsKey(mcRecord.Case__c)) {
                            Case caseObj = mapIdToMOSCase.get(mcRecord.Case__c);
                            String key = caseObj.Job_Type__c + ConstantsUtility.keySeparator + caseObj.MOS_Case_Stage__c +  ConstantsUtility.keySeparator;
                            if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                key += ConstantsUtility.MOSCaseSourceMCall;    
                            } 
                            else {
                                key += ConstantsUtility.MOSCaseSourceNOTMCall;     
                            }
                            key += ConstantsUtility.keySeparator + String.valueOf(mcRecord.Counter__c + 1);
                            if(mapKeyToCommunicationRecords.containsKey(key) && mapKeyToCommunicationRecords.get(key) != NULL) {
                                MOS_Time_dependent_Communication__mdt mosCommunication = mapKeyToCommunicationRecords.get(key);
                                if(String.isNotBlank(mosCommunication.Dealer_Not_Equal_To__c) && caseObj.Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                                    continue;
                                }
                                else {
                                    String phoneNumbers = MOSCaseCommunicationsService.getPhoneNumbers(caseObj,mosCommunication.Audience__c,listMSAllianzRecord,mapDesignationMSAllianzToPhoneNumbers,mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,'Allocated_Dealer__c');
                                    MC_Communication__c mcCommunication =  MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj,mcRecord.Type__c,phoneNumbers);
                                    mcCommunication.Escalation_Date_Time__c = mcRecord.Escalation_Date_Time__c.addSeconds(Integer.valueOf(mosCommunication.Time_Duration__c));
                                    mcCommunication.Counter__c = mcRecord.Counter__c + 1;
                                    listMCCommunicationRecordToInsert.add(mcCommunication);
                                }
                            }
                        }
                    }
                }
                if(listMCCommunicationRecordToInsert.size() > 0) {
					TriggerHandler.bypass('MCCommunicationTriggerHandler');
                    insert listMCCommunicationRecordToInsert;
                    TriggerHandler.clearbypass('MCCommunicationTriggerHandler');
                }
                
            }
            
            if (listCaseActionToUpdate.size() > 0) {
                update listCaseActionToUpdate;
            }
            
            if(mapIdToCase.keySet().size() > 0) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update mapIdToCase.values();
                TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }    
        }
        catch(Exception exp) {
            ExceptionHandler.LogError('MCCommunicationTriggerHandler', exp.getMessage() +':'+exp.getLineNumber(), 'Update Escalation Level on Case Actions of MOS Cases', null, null);    
        }
    }
    
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the picklist values of Escalation Level field
*/
    public List<String> getPicklistValues() {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case_Actions__c.Escalation_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to update the status as Cancelled when new MC communications record is created for Escalations
*/
    public void updateOtherMCCommunicationAsCancelled() {
        try{
            List<MC_Communication__c> listMCCommunicationToUpdate = new List<MC_Communication__c>();    //List to store the MC communication records to update
            Set<Id> setCaseActionId = new Set<Id>();                                                    //Set to store the Case Action record Id
            Map<Id,Case_Actions__c> mapIdToCaseAction;                                                  //Map to store Case Actions
            //Iterating through new list of MC Records
            for(MC_Communication__c mcRecord : newMcComList) {
                //Check for Case Action ID
                if(mcRecord.Case_Action__c != NULL) {
                    setCaseActionId.add(mcRecord.Case_Action__c);	    
                }
            }
            
            //Getting the Case Actions records in a map 
            //This is used only to update MC communication of Case Action of Particular record type
            if(setCaseActionId.size() > 0) {
                mapIdToCaseAction = new Map<Id,Case_Actions__c>([SELECT Id,RecordTypeId 
                                                                 FROM Case_Actions__c 
                                                                 WHERE Id IN :setCaseActionId 
                                                                 AND RecordTypeId = :ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id]);    
            }
            
            //Fetching MC communication records to update
            if(mapIdToCaseAction != NULL && mapIdToCaseAction.keySet().size() > 0) {
                for(MC_Communication__c mcRecord : [SELECT Id,Status__c FROM MC_Communication__c 
                                                    WHERE Id NOT IN :newMcComList 
                                                    AND Case_Action__c IN :mapIdToCaseAction.keySet()
                                                    AND Status__c = :ConstantsUtility.MC_Communication_Status_Queued]) {
                                                        mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Cancelled;
                                                        listMCCommunicationToUpdate.add(mcRecord);
                                                    }
            }
            
            //Updating MC Communication records
            if(listMCCommunicationToUpdate.size() > 0) {
                TriggerHandler.bypass('MCCommunicationTriggerHandler');
                update listMCCommunicationToUpdate;
                TriggerHandler.clearbypass('MCCommunicationTriggerHandler');
            }
        }
        catch(Exception exp) {
            ExceptionHandler.LogError('MCCommunicationTriggerHandler', exp.getMessage() +':'+exp.getLineNumber(), 'Update MOS Cases Escalation MC Communication records as Cancelled', null, null);     
        }
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the time dependent MOS Communications records
*/
    public static Map<String,MOS_Time_dependent_Communication__mdt> getMOSCommunicationRecords() {
        Map<String,MOS_Time_dependent_Communication__mdt> mapMOSCommunicationRecords = new Map<String,MOS_Time_dependent_Communication__mdt>();
        for(MOS_Time_dependent_Communication__mdt mosCommunication : [SELECT Job_Type__c,Stage__c,Case_Source__c,Notification_Type__c,Audience__c,Time_Duration__c,Dealer_Equal_To__c,Dealer_Not_Equal_To__c,Counter__c  
                                                                      FROM MOS_Time_dependent_Communication__mdt WHERE Counter__c > 1]) {
                                                                          String key = mosCommunication.Job_Type__c + ConstantsUtility.keySeparator + mosCommunication.Stage__c + ConstantsUtility.keySeparator + mosCommunication.Case_Source__c + ConstantsUtility.keySeparator + String.valueOf(mosCommunication.Counter__c);
                                                                          mapMOSCommunicationRecords.put(key,mosCommunication);
                                                                          
                                                                          if(mosCommunication.Audience__c != NULL) {
                                                                              populateSet(mosCommunication.Audience__c,setContact,setRole,setDesignation,setStakeHolder);      
                                                                          }
                                                                      }
        return mapMOSCommunicationRecords;
    } 
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to populate the Mc Communication Reciepient Audience
*/
    public static void populateSet(String audience,Set<String> setContact,Set<String> setRole,Set<String> setDesignation,Set<String> setStakeHolder) {
        for(String aud : audience.split(',')) {
            if(aud.contains(ConstantsUtility.Contact)) {
                setContact.add(aud.split('#')[1]);
            }
            else if(aud.contains(ConstantsUtility.Role)) {
                setRole.add(aud.split('#')[1]);
            }
            else if(aud.contains(ConstantsUtility.Account)) {
                setDesignation.add(aud.split('#')[1]);
            }
            else if(aud.contains(ConstantsUtility.Hierarchy)) {
                setStakeHolder.add(aud.split('#')[1]);
            }
        }    
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the phone numbers of Mc Communication Reciepient Audience in Maps
*/
    
    public static void getMCCommunicationAudiencePhoneNumbers(Set<Id> setTechnicianId,Set<Id> setAllocatedDealerId,Boolean msAllianz,List<Account> listMSAllianzRecords) {
        mapDesignationMSAllianzToPhoneNumbers = new Map<String,String>();
        mapRoleToPhoneNumbers = new Map<String,Set<String>>();
        mapTechnicianIdToPhoneNumbers = new Map<String,String>();
        mapAllocatedDealerToStakeHolderToPhoneNumbers = new Map<String,Map<String,String>>();
        if(setRole.size() > 0) {
            for(User usr : [SELECT Id,MobilePhone,UserRole.Name FROM User WHERE UserRole.Name IN :setRole]) {
                if(usr.MobilePhone != NULL) {
                    Set<String> setPhoneNumbers = new Set<String>();  
                    if(mapRoleToPhoneNumbers.containsKey(usr.UserRole.Name)) {
                        setPhoneNumbers = mapRoleToPhoneNumbers.get(usr.UserRole.Name);   
                    }  
                    setPhoneNumbers.add(usr.MobilePhone);
                    mapRoleToPhoneNumbers.put(usr.UserRole.Name,setPhoneNumbers);
                }
            }
        }
        
        if(setContact.size() > 0 && setTechnicianId != NULL && setTechnicianId.size() > 0) {
            for(Contact con : [SELECT Id,Phone FROM Contact WHERE Id IN :setTechnicianId]) {
                if(con.Phone != NULL) {
                    mapTechnicianIdToPhoneNumbers.put(con.Id,con.Phone);    
                }
            }    
        }
        
        if(msAllianz && setDesignation.size() > 0 && listMSAllianzRecords != NULL && listMSAllianzRecords.size() > 0) {
            for(Contact con : [SELECT Id,Phone,Designation__c FROM Contact WHERE AccountId = :listMSAllianzRecords[0].Id AND Designation__c IN :setDesignation]) {
                if(con.Phone != NULL) {
                    mapDesignationMSAllianzToPhoneNumbers.put(con.Designation__c,con.Phone);  
                }    
            }
        }
        
        if(setAllocatedDealerId != NULL && setAllocatedDealerId.size() > 0 && setStakeHolder.size() > 0) {
            for(Account acc : [SELECT Id,Stakeholder_Hierarchy__c FROM Account WHERE Id IN :setAllocatedDealerId]) {
                if(acc.Stakeholder_Hierarchy__c != NULL) {
                    Map<String,String> mapPhoneNumbers = new Map<String,String>();
                    Map<String,Object> mapStakeHoldersToPhoneNumbers = (Map<String,Object>)	JSON.deserializeUntyped(acc.Stakeholder_Hierarchy__c );
                    If(mapStakeHoldersToPhoneNumbers != NULL && mapStakeHoldersToPhoneNumbers.keySet().size() > 0) {
                        getPhoneNumbersFromAllocatedDealerHierarchy(mapStakeHoldersToPhoneNumbers,ConstantsUtility.SERVICE_NEXA_HIERARCHY,ConstantsUtility.NEXA_CASE_CHANNEL,mapPhoneNumbers);
                        getPhoneNumbersFromAllocatedDealerHierarchy(mapStakeHoldersToPhoneNumbers,ConstantsUtility.SERVICE_ARENA_HIERARCHY,ConstantsUtility.ARENA_CASE_CHANNEL,mapPhoneNumbers);
                        mapAllocatedDealerToStakeHolderToPhoneNumbers.put(acc.Id,mapPhoneNumbers);   
                    } 
                    
                }    
            }
        }
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the phone numbers from the Allocated Dealer Hierarchy
*/
    public static void getPhoneNumbersFromAllocatedDealerHierarchy(Map<String,Object> mapStakeHoldersToPhoneNumbers,String nodeName,String channel,Map<String,String> mapPhoneNumbers) {
        if(mapStakeHoldersToPhoneNumbers.containsKey(nodeName) && mapStakeHoldersToPhoneNumbers.get(nodeName) != NULL)  {
            List<Object> listServiceStakeHolder = (List<Object>) mapStakeHoldersToPhoneNumbers.get(nodeName);
            if(listServiceStakeHolder != NULL && listServiceStakeHolder.size() > 0) {
                for(Object obj : listServiceStakeHolder) {
                    Map<String,Object> mapKeyToValue = (Map<String,Object>)Obj;
                    if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0) {
                        if(setStakeHolder.contains((String)mapKeyToValue.get('stakeHolder')) && (String)mapKeyToValue.get('phone') != NULL) {
                            mapPhoneNumbers.put((String)mapKeyToValue.get('stakeHolder')+ConstantsUtility.keySeparator+channel,(String)mapKeyToValue.get('phone'));    
                        }
                    }
                }
            }
        }
    }
}