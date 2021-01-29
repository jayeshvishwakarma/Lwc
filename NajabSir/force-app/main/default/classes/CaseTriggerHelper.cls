/**
* @File Name          : CaseTriggerHelper.cls
* @Description        : Helper class for Case Trigger Handler
* @Author             : 
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 6/12/2020, 11:29:29 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    6/12/2020, 11:29:29 PM                               Initial Version 
**/
public without sharing class CaseTriggerHelper {
    //Variables declaration added by Anas Yar Khan on 24th July 2020
    public static Map<String, MOS_Task_Calculations__mdt> mapKeyToMOSLogic;
    public static Map<String, MOS_Task_Calculations__mdt> mapKeyToMOSLogicWithCaseType;
    public static List<Account> listMSAllianzRecord;
    public static Map<String, String> mapKeyToQueueName;
    public static Map<String, String> mapQueueNameToId;
    public static Map<String, MOS_Case_Time_Population__mdt> mapStageNameToFieldAPIName;
    public static Set<Id> setIntegrationUserId;
    public static Map<String, Set<String>> mapConditionFieldToEscalationType;
    public static Map<String, Set<Id>> mapEscalationTypeToCaseId = new Map<String, Set<Id>>();
    public static Map<String, Map<String, MOS_Escalation__mdt>> newEscalationTypeToMetadataRecords = new Map<String, Map<String, MOS_Escalation__mdt>>();
    public static Map<String, String> mapEscalationTypeToCaseActionFieldApi = new Map<String, String>();
    public static Map<String, MOS_Case_Stage_Change_Validations__mdt> mapStageToAllowedStage = new Map<String, MOS_Case_Stage_Change_Validations__mdt>();
    public static Map<String,List<MOS_Time_dependent_Communication__mdt>> mapKeyToCommunicationRecords = new Map<String,List<MOS_Time_dependent_Communication__mdt>>();
    public static Boolean byPassMOSCommunication = false;         //Variable to store the value whether MC communication records are need to created or not
    public static Map<String,String> mapDesignationMSAllianzToPhoneNumbers;
    public static Map<String,Set<String>> mapRoleToPhoneNumbers;
    public static Map<String,String> mapTechnicianIdToPhoneNumbers;
    public static Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers;
    public static Set<String> setContact = new Set<String>();
    public static Set<String> setRole = new Set<String>();
    public static Set<String> setDesignation = new Set<String>();
    public static Set<String> setStakeHolder = new Set<String>();
    public static Map<String,MOS_Time_dependent_Communication__mdt> mapKeyToCommunicationRecordsNotTimeDependent = new Map<String,MOS_Time_dependent_Communication__mdt>();
    public static Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToEmails;
    public static Map<String,String> mapRoleUser = new Map<String,String>();
    public static Map<Id,Id> mapAllocatedDealerToTechnicianId;
    public static Map<Id,Account> mapIdToAllocatedDealer = new Map<Id,Account>();
    public static Map<Id,String> mapIdToTechnicianId = new Map<Id,String>();
    //Method to get custom setting whether MC communications records needs to be created or not
    public static void getByPassMOSCommunication() {
        Bypass_Setting__c bypassSetting = Bypass_Setting__c.getOrgDefaults();
        if(bypassSetting != NULL) {
            byPassMOSCommunication = bypassSetting.Skip_MOS_Communication__c;     
        }
    }
    
    //method to get the MC Communication records condition from Custom metadata
    public static void getCommunicationRecords() {
        for(MOS_Time_dependent_Communication__mdt mosCommunication : [SELECT Job_Type__c,Stage__c,Case_Source__c,Notification_Type__c,Audience__c,Time_Duration__c,Dealer_Equal_To__c,Dealer_Not_Equal_To__c,Counter__c  
                                                                      FROM MOS_Time_dependent_Communication__mdt WHERE (Counter__c = 1 OR Counter__c = 0)]) {
                                                                          String key = mosCommunication.Job_Type__c + ConstantsUtility.keySeparator + mosCommunication.Stage__c + ConstantsUtility.keySeparator + mosCommunication.Case_Source__c;
                                                                          List<MOS_Time_dependent_Communication__mdt> listMOSCommunication = new List<MOS_Time_dependent_Communication__mdt>();
                                                                          
                                                                          if(mosCommunication.counter__c == 0) {
                                                                              mapKeyToCommunicationRecordsNotTimeDependent.put(mosCommunication.Notification_Type__c,mosCommunication);
                                                                          }
                                                                          else {
                                                                              if(mapKeyToCommunicationRecords.containsKey(key)) {
                                                                                  listMOSCommunication =  mapKeyToCommunicationRecords.get(key);
                                                                              }
                                                                              listMOSCommunication.add(mosCommunication);
                                                                              mapKeyToCommunicationRecords.put(key,listMOSCommunication);
                                                                          }
                                                                          
                                                                          if(mosCommunication.Audience__c != NULL) {
                                                                              populateSet(mosCommunication.Audience__c,setContact,setRole,setDesignation,setStakeHolder);      
                                                                          }
                                                                      }
    }
    
    //Method to get the recipient audience for MC Communication
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
    
    //This method called in before insert and before update and fills the required information that needed
    public static void getData() {
        mapKeyToMOSLogic = getMetadataRecords();
        mapKeyToMOSLogicWithCaseType = getMetadataRecordsWithCaseType();
        listMSAllianzRecord = getMSAllianzRecord();
        mapKeyToQueueName = getMetadataRecordsWithQueue();
        mapStageNameToFieldAPIName = getMetadataForTimePopulation();
        setIntegrationUserId = getIntegrationUserDetails();
        //mapStageToAllowedStage = getStageValidationMetadataRecords();
        if (mapKeyToQueueName != NULL && mapKeyToQueueName.keySet().size() > 0) {
            mapQueueNameToId = getQueueMap(mapKeyToQueueName);
        }
    }
    
    public static void getDataForCaseEscalation() {
        mapConditionFieldToEscalationType = getEscalationMapConditionFieldToEscalationType();
        newEscalationTypeToMetadataRecords = getMOSEscalationMetadataRecords();
    }
    
    
    public static Map<Id, Case_Actions__c> getMapOfCaseActionsRecord(List<Case> newCaseList) {
        return new Map<Id, Case_Actions__c>([SELECT Id,Case_Number__c,Escalation_Level__c,MC_Communication__c FROM Case_Actions__c WHERE Case_Number__c IN :newCaseList]);
        
    }
    
    public static Map<String, Map<String, MOS_Escalation__mdt>> getMOSEscalationMetadataRecords() {
        Map<String, Map<String, MOS_Escalation__mdt>> newEscalationTypeToMetadataRecords = new Map<String, Map<String, MOS_Escalation__mdt>>();
        for (MOS_Escalation__mdt mosEscalation : [
            SELECT Job_Type__c,MOS_Case_Type__c,MOS_Case_Stage__c,Escalation_Type__c,
            Escalation_Level__c,Escalation_Update__c,Duration__c,Case_Action_Record_Id_Field__c,
            Alternate_Escalation_Update__c,Alternate_Duration__c,Value__c,Condition__c
            FROM MOS_Escalation__mdt
        ]) {
            
            String key = mosEscalation.Job_Type__c;
            key += ConstantsUtility.keySeparator + mosEscalation.MOS_Case_Type__c;
            key += ConstantsUtility.keySeparator + mosEscalation.MOS_Case_Stage__c;
            key += ConstantsUtility.keySeparator + mosEscalation.Escalation_Level__c;
            key += ConstantsUtility.keySeparator + mosEscalation.Escalation_Type__c;
            
            Map<String, MOS_Escalation__mdt> keyToMetadataRedcords = new Map<String, MOS_Escalation__mdt>();
            
            if (newEscalationTypeToMetadataRecords.containsKey(mosEscalation.Escalation_Type__c)) {
                keyToMetadataRedcords = newEscalationTypeToMetadataRecords.get(mosEscalation.Escalation_Type__c);
            }
            keyToMetadataRedcords.put(key, mosEscalation);
            newEscalationTypeToMetadataRecords.put(mosEscalation.Escalation_Type__c, keyToMetadataRedcords);
            
        }
        return newEscalationTypeToMetadataRecords;
    }
    
    public static Map<String, Set<String>> getEscalationMapConditionFieldToEscalationType() {
        Map<String, Set<String>> mapConditionFieldToEscalationType = new Map<String, Set<String>>();
        for (MOS_Escalation__mdt mosEscalation : [SELECT Condition__c,Escalation_Type__c,Case_Action_Record_Id_Field__c FROM MOS_Escalation__mdt]) {
            Set<String> setEscalationType = new Set<String>();
            if (mapConditionFieldToEscalationType.containsKey(mosEscalation.Condition__c)) {
                setEscalationType = mapConditionFieldToEscalationType.get(mosEscalation.Condition__c);
                
            }
            setEscalationType.add(mosEscalation.Escalation_Type__c);
            mapConditionFieldToEscalationType.put(mosEscalation.Condition__c, setEscalationType);
            
            if (!mapEscalationTypeToCaseId.containsKey(mosEscalation.Escalation_Type__c)) {
                mapEscalationTypeToCaseId.put(mosEscalation.Escalation_Type__c, new Set<Id>());
            }
            /*if(!mapEscalationTypeToCaseId.containsKey(mosEscalation.Escalation_Type__c)) {
mapEscalationTypeToCaseId.put(mosEscalation.Escalation_Type__c,new Set<Id>());    
}
*/
            if (!mapEscalationTypeToCaseActionFieldApi.containsKey(mosEscalation.Escalation_Type__c)) {
                mapEscalationTypeToCaseActionFieldApi.put(mosEscalation.Escalation_Type__c, mosEscalation.Case_Action_Record_Id_Field__c);
            }
            
        }
        return mapConditionFieldToEscalationType;
    }
    
    /*
Author : Gitika
Company : Techmatrix Consulting
Description : This helper method is used to fetch Queue Basis Case Type, Business Area and Channel
Return Type : map<string,string>
*/
    public static map<string, string> getQueueAssignment(list<string> unquieKeyList) {
        
        map<string, string> mapOfUniqueKeyWithQueueDevName = new map<string, string>();
        map<string, string> mapOfUniqueKeyWithQueueId = new map<string, string>();
        map<string, string> mapOfQueueDevNameWithId = new map<string, string>();
        mapOfQueueDevNameWithId.put(ConstantsUtility.UNASSIGNED_QUEUE, null);
        for (Case_Queue_Assignment_Matrix__mdt caseQueueMatrixObj : [
            SELECT Queue_Developer_Name__c,channel__c,business_Area__c,case_type__c,legal__c,Process_Type__c
            FROM Case_Queue_Assignment_Matrix__mdt
            where Queue_Developer_Name__c != null
        ]) {
            string Key = (caseQueueMatrixObj.Channel__c != null ? caseQueueMatrixObj.Channel__c : '');
            Key += (caseQueueMatrixObj.Case_Type__c != null ? caseQueueMatrixObj.Case_Type__c : '');
            Key += (caseQueueMatrixObj.Business_Area__c != null ? caseQueueMatrixObj.Business_Area__c : '');
            Key += (caseQueueMatrixObj.Process_Type__c != null ? caseQueueMatrixObj.Process_Type__c : '');
            //  Key +=  caseQueueMatrixObj.legal__c;
            
            mapOfUniqueKeyWithQueueDevName.put(key, caseQueueMatrixObj.Queue_Developer_Name__c);
            mapOfQueueDevNameWithId.put(caseQueueMatrixObj.Queue_Developer_Name__c, null);
        }
        
        if (mapOfQueueDevNameWithId.size() > 0) {
            if (caseTriggerHelper.getQueueMapWithDevNameAndId(mapOfQueueDevNameWithId) != null) {
                mapOfQueueDevNameWithId = caseTriggerHelper.getQueueMapWithDevNameAndId(mapOfQueueDevNameWithId);
                for (string str : unquieKeyList) {
                    if (mapOfUniqueKeyWithQueueDevName.containskey(str) && mapOfQueueDevNameWithId.containskey(mapOfUniqueKeyWithQueueDevName.get(str))) {
                        mapOfUniqueKeyWithQueueId.put(str, mapOfQueueDevNameWithId.get(mapOfUniqueKeyWithQueueDevName.get(str)));
                    } else {
                        mapOfUniqueKeyWithQueueId.put(str, mapOfQueueDevNameWithId.get(ConstantsUtility.UNASSIGNED_QUEUE));
                    }
                }
            }
            
        }
        return mapOfUniqueKeyWithQueueId;
    }
    /*
Author : Gitika
Company : Techmatrix Consulting
Description : This method is used to Query queue
Events : 
Return Type : map<String,string>
*/
    public static map<String, string> getQueueMapWithDevNameAndId(map<String, string> mapQueueDevNameWithId) {
        for (Group grp : [
            SELECT Id, Name, DeveloperName, Email, Type
            FROM Group
            where Type = :ConstantsUtility.QUEUE
            And DeveloperName in :mapQueueDevNameWithId.keySet()
        ]) {
            mapQueueDevNameWithId.put(grp.DeveloperName, grp.Id);
        }
        return mapQueueDevNameWithId;
    }
    
    /*
Author : Gitika
Company : Techmatrix Consulting
Description : This helper method is used to fetch Queue Basis Case Type, Business Area and Channel
Return Type : String
*/
    
    public static string getQueueName(string channel, string BusinessArea, string caseType, boolean isLegal) {
        
        string unAssigned;
        
        // Querying custom metadata
        list<Case_Queue_Assignment_Matrix__mdt> caseQueueMatrixObj = [
            SELECT Queue_Developer_Name__c
            FROM Case_Queue_Assignment_Matrix__mdt
            where channel__c = :channel and business_Area__c = :BusinessArea and case_type__c = :caseType
            and legal__c = :isLegal
        ];
        if (caseQueueMatrixObj.size() > 0) {
            if (CaseTriggerHelper.getQueue(caseQueueMatrixObj[0].Queue_Developer_Name__c) != null) {
                unAssigned = CaseTriggerHelper.getQueue(caseQueueMatrixObj[0].Queue_Developer_Name__c);
            } else {
                unAssigned = CaseTriggerHelper.getQueue(ConstantsUtility.UNASSIGNED_QUEUE);
            }
            return unAssigned;
        }
        unAssigned = CaseTriggerHelper.getQueue(ConstantsUtility.UNASSIGNED_QUEUE);
        return unAssigned;
    }
    /*
Author : Gitika
Company : Techmatrix Consulting
Description : This method is used to Query queue
Events : 
Return Type : String
*/
    public static string getQueue(string queueDevName) {
        return ([
            SELECT Id, Name, DeveloperName, Email, Type
            FROM Group
            where Type = :ConstantsUtility.QUEUE
            And DeveloperName = :queueDevName
        ].Id);
    }
    
    
    /**
        Author: Gitika
        Company: Techmatrix
        Description: Helper  Method to create instance of Case For update
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0                                                           Initial Version
	*/
    public static case getCaseInstance(case_Actions__c caseAction) {
        case caseObj = new case();
        caseObj.id = caseAction.Case_Number__c;
        caseObj.status = ConstantsUtility.CASE_STATUS_ON_HOLD;
        caseObj.IsStopped = true;
        return caseObj;
    }
    
    
    /*
        Author : Gitika
        Company : Techmatrix Consulting
        Description : This helper method is used to create spam Case Action
        Return Type : case_Actions__c
	*/
    public static case_Actions__c createCaseAction(case caseObj, string Manager) {
        case_Actions__c caseActionObj = new case_Actions__c();
        caseActionObj.Case_Number__c = caseObj.Id;
        caseActionObj.Name = ConstantsUtility.SPAM_PRIMARY_CATEGORY;
        caseActionObj.case_type__c = String.isNotBlank(caseObj.case_type__c) ? caseObj.case_type__c : '';
        caseActionObj.business_Area__c = String.isNotBlank(caseObj.business_Area__c) ? caseObj.business_Area__c : '';
        caseActionObj.channel__c = String.isNotBlank(caseObj.channel__c) ? caseObj.channel__c : '';
        caseActionObj.mobile__c = String.isNotBlank(caseObj.Mobile_Number__c) ? caseObj.Mobile_Number__c : '';
        caseActionObj.email__c = String.isNotBlank(caseObj.email__c) ? caseObj.email__c : '';
        caseActionObj.Primary_Category__c = String.isNotBlank(caseObj.Primary_Category__c) ? caseObj.Primary_Category__c : '';
        caseActionObj.recordTypeId = ConstantsUtility.SPAM_CASE_ACTION_RECORD_TYPE_ID;
        caseActionObj.Case_Owner_Manager__c = String.isNotBlank(Manager) ? Manager : null;
        return caseActionObj;
    }
   
    /*
        Author : Anas Yar Khan
        Company : Techmatrix Consulting
        Description : This method is used to update/prepopulate the Case Type on MOS Case based on the entered distance and Allocated Dealer
        Events : Before Update,before Update
        Return Type : Void
	*/
    public static void populateCaseType(Map<Id, Account> mapIdToMosMaster, Case caseObj) {
        if (mapIdToMosMaster != NULL && mapIdToMosMaster.keySet().size() > 0
            && caseObj.Allocated_Dealer__c != NULL && mapIdToMosMaster.containsKey(caseObj.Allocated_Dealer__c)
            && mapIdToMosMaster.get(caseObj.Allocated_Dealer__c) != NULL && mapIdToMosMaster.get(caseObj.Allocated_Dealer__c).MOS_Category__c != NULL) {
                //Scenario when it would MOS is when both entered and calculated is <= 15 KM
                 if (caseObj.Entered_Distance__c != NULL && 
                    caseObj.Calculated_Distance__c != NULL && 
                    caseObj.Entered_Distance__c <= ConstantsUtility.ENTERED_DISTANCE && 
                    caseObj.Calculated_Distance__c <= ConstantsUtility.ENTERED_DISTANCE) {
                            caseObj.Case_Type__c = ConstantsUtility.CASE_TYPE_MOS;
                    } //Scenario when it would MOS is when only entered distance is present.
                else if(caseObj.Entered_Distance__c != NULL && 
                    caseObj.Calculated_Distance__c == NULL && 
                    caseObj.Entered_Distance__c <= ConstantsUtility.ENTERED_DISTANCE) {
                            caseObj.Case_Type__c = ConstantsUtility.CASE_TYPE_MOS;
                    }
                 else{
                            caseObj.Case_Type__c = ConstantsUtility.CASE_TYPE_NON_MOS;
                 }   

            }else{
                // Default scenario should be Non MOS
                caseObj.Case_Type__c =  ConstantsUtility.CASE_TYPE_NON_MOS;
            }

    }
    
    
    
    /*
        Author : Anas Yar Khan
        Company : Techmatrix Consulting
        Description : This method is used to update/prepopulate the Case Type on MOS Case based on the entered distance and Allocated Dealer
        Events : Before Update,before insert
        Return Type : Map of Id to MOS MASTER
	*/	
    public static Map<Id,Account> getMapIdToMOSMaster(List<Case> newCaseList) {
        Set<Id> setAllocatedDealerId = new Set<Id>();               //Set to store the Id of Allocated Dealer
        mapAllocatedDealerToTechnicianId = new Map<Id,Id>();
        //Loop to iterate over MOS Case and store allocated dealer in set
        for (Case caseObj : newCaseList) {
            if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID && caseObj.Allocated_Dealer__c != NULL) {
                setAllocatedDealerId.add(caseObj.Allocated_Dealer__c);
            }
        }
        
        //Map to store Allocated dealer records
        Map<Id, Account> mapIdToMosMaster;
        
        //Query Allocated Dealer records
        if (setAllocatedDealerId.size() > 0) {
            mapIdToMosMaster = new Map<Id,Account>([SELECT Id,MOS_Category__c,Dealer_Geo_Location__Latitude__s,Dealer_Geo_Location__Longitude__s,DMS_Primaries__c FROM Account WHERE Id IN :setAllocatedDealerId]);
        }
        //Allocated dealer to MOS technician User
        Set<Id> setUserId = new Set<Id>();
        if(mapIdToMosMaster != NULL && mapIdToMosMaster.keySet().size() > 0) {
            for(Id accountId : mapIdToMosMaster.keySet()) {
                if(mapIdToMosMaster.get(accountId).DMS_Primaries__c != NULL) {
                    String jsonString = mapIdToMosMaster.get(accountId).DMS_Primaries__c;
                    List<Object> listObject = (List<Object>) JSON.deserializeUntyped(jsonString);
                    if(listObject != NULL && listObject.size() > 0) {
                        for(Object obj : listObject) {
                            Map<String,Object> mapStringToValue = (Map<String,Object>)obj;
                            if(mapStringToValue.get(ConstantsUtility.Level) == ConstantsUtility.primaryMOSTechnician && (Id)mapStringToValue.get(ConstantsUtility.SFID) != NULL) {
                                setUserId.add((Id)mapStringToValue.get(ConstantsUtility.SFID));		    
                            }
                        }
                    }    
                }
            }    
        }
        
        //Query User Records
        Map<Id,Id> mapUserIdToContactId = new Map<Id,Id>();
        if(setUserId.size() > 0) {
            for(User usr : [SELECT Id,ContactId FROM User WHERE Id IN :setUserId]) {
                mapUserIdToContactId.put(usr.Id,usr.ContactId);	    
            }
        }
        
        //Map Allocated Dealer to Contact Technician
        if(mapIdToMosMaster != NULL && mapIdToMosMaster.keySet().size() > 0 && mapUserIdToContactId.keySet().size() > 0) {
            for(Id accountId : mapIdToMosMaster.keySet()) {
                if(mapIdToMosMaster.get(accountId).DMS_Primaries__c != NULL) {
                    String jsonString = mapIdToMosMaster.get(accountId).DMS_Primaries__c;
                    List<Object> listObject = (List<Object>) JSON.deserializeUntyped(jsonString);
                    if(listObject != NULL && listObject.size() > 0) {
                        for(Object obj : listObject) {
                            Map<String,Object> mapStringToValue = (Map<String,Object>)obj;
                            if(mapStringToValue.get(ConstantsUtility.Level) == ConstantsUtility.primaryMOSTechnician && (Id)mapStringToValue.get(ConstantsUtility.SFID) != NULL 
                               && mapUserIdToContactId.containskey((Id)mapStringToValue.get(ConstantsUtility.SFID))) {
                                   mapAllocatedDealerToTechnicianId.put(accountId,mapUserIdToContactId.get((Id)mapStringToValue.get(ConstantsUtility.SFID)));		    
                               }
                        }
                    }    
                }
            }    
        }
        
        return mapIdToMosMaster;
    }
    
    
    /*
        Author : Anas Yar Khan
        Company : Techmatrix Consulting
        Description : This method is used to update/prepopulate the Priority on MOS Case based on the Family Involvement
        Events : Before Update
        Return Type : Void
	*/
    public static void populatePriority(Case caseObj) {
        if (caseObj.Family_involvement__c != NULL) {
            caseObj.Priority = ConstantsUtility.PRIORITY_MEDIUM;
        }
    }
    
    
    /*
        Author : Anas Yar Khan
        Company : Techmatrix Consulting
        Description : This method is used to update/prepopulate the Towing Sub Stage on MOS Case 
        Events : Before Update
        Return Type : Void
	*/
    public static void populateTowingSubStage(Case caseObj) {
        if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_TOWING_REQUIRED && String.isBlank(caseObj.Towing_Sub_stage__c)) {
            caseObj.Towing_Sub_stage__c = ConstantsUtility.TOWING_SUB_STAGE_Pending_for_Allocation;
        }
    }
    
    
    /*
        Author : Anas Yar Khan
        Company : Techmatrix Consulting
        Description : This method is used to update/prepopulate the Allocated Dealer on MOS Case 
        Events : Before Update
        Return Type : Void
	*/
    public static void populateAllocatedDealer(Case caseObj) {
        
        if (caseObj.Job_Type__c != NULL && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.Allocated_Dealer__c == NULL) {
            caseObj.Allocated_Dealer__c = listMSAllianzRecord[0].Id;
        }
        
        if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Towing_required && caseObj.Towing_Sub_Stage__c == ConstantsUtility.TOWING_SUB_STAGE_Pending_for_Allocation) {
            caseObj.Towing_Allocated_Dealer_2__c = listMSAllianzRecord[0].Id;
        }
        
    }
    
    
    /*
        Author : Anas Yar Khan
        Company : Techmatrix Consulting
        Description : This method is used to get MOS Follow Up Calculation Records
        Events : Before Update,Before Insert
        Return Type : Map
	*/
    public static Map<String, MOS_Task_Calculations__mdt> getMetadataRecords() {
        
        Map<String, MOS_Task_Calculations__mdt> mapKeyToMOSLogic = new Map<String, MOS_Task_Calculations__mdt>();
        
        for (MOS_Task_Calculations__mdt mosCalculation : [SELECT Job_Type__c,Case_Stage__c,Case_Sub_Stage__c,Case_Type__c,Field__c,Delta_Time__c,Alternate_Field__c,Alternate_Delta_Time__c FROM MOS_Task_Calculations__mdt]) {
            String key = mosCalculation.Job_Type__c + ConstantsUtility.keySeparator + mosCalculation.Case_Stage__c;
            if (String.isNotBlank(mosCalculation.Case_Sub_Stage__c)) {
                key += ConstantsUtility.keySeparator + mosCalculation.Case_Sub_Stage__c;
            }
            mapKeyToMOSLogic.put(key, mosCalculation);
        }
        
        return mapKeyToMOSLogic;
    }
    
    /* 
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description :  This method is used to get the Custom metadata records for Stage Validations
Events : Before Update
*/
    public static void getStageValidationMetadataRecords() {
        for (MOS_Case_Stage_Change_Validations__mdt caseStageValidation : [SELECT Job_Type__c,Current_Stage__c,Allowed_Stage__c,Particular_Stage__c,Field_API_Name__c FROM MOS_Case_Stage_Change_Validations__mdt]) {
            mapStageToAllowedStage.put(caseStageValidation.Job_Type__c + ConstantsUtility.keySeparator + caseStageValidation.Current_Stage__c, caseStageValidation);
        }
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get MOS Follow Up Calculation Records with Case Type
Events : Before Update,Before Insert
Return Type : Map
*/
    
    public static Map<String, MOS_Task_Calculations__mdt> getMetadataRecordsWithCaseType() {
        Map<String, MOS_Task_Calculations__mdt> mapKeyToMOSLogicWithCaseType = new Map<String, MOS_Task_Calculations__mdt>();
        for (MOS_Task_Calculations__mdt mosCalculation : [SELECT Job_Type__c,Case_Stage__c,Case_Sub_Stage__c,Case_Type__c,Field__c,Delta_Time__c,Alternate_Field__c,Alternate_Delta_Time__c FROM MOS_Task_Calculations__mdt WHERE Case_Type__c != NULL]) {
            String key = mosCalculation.Job_Type__c + ConstantsUtility.keySeparator + mosCalculation.Case_Stage__c;
            if (String.isNotBlank(mosCalculation.Case_Sub_Stage__c)) {
                key += ConstantsUtility.keySeparator + mosCalculation.Case_Sub_Stage__c;
            }
            key += ConstantsUtility.keySeparator + mosCalculation.Case_Type__c;
            mapKeyToMOSLogicWithCaseType.put(key, mosCalculation);
        }
        
        return mapKeyToMOSLogicWithCaseType;
        
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to populate the Next followup time on Case
Events : Before Update,Before Insert
Return Type : void
*/
    
    public static void popluateNextFollowUpTime(Case caseObj) {
        String key = getKey(caseObj);
        String keyNew = key;
        if (String.isNotBlank(caseObj.Case_Type__c)) {
            keyNew += ConstantsUtility.keySeparator + caseObj.Case_Type__c;
        }
        if (mapKeyToMOSLogic.containsKey(key)) {
            MOS_Task_Calculations__mdt mosLogicRecord = mapKeyToMOSLogic.get(key);
            if (String.isNotBlank(mosLogicRecord.Case_Type__c)) {
                if (mapKeyToMOSLogicWithCaseType != NULL && mapKeyToMOSLogicWithCaseType.keySet().size() > 0 && mapKeyToMOSLogicWithCaseType.containsKey(keyNew)) {
                    popluateNextFollowUpTimeFromCustomMetadataRecord(mapKeyToMOSLogicWithCaseType.get(keyNew), caseObj);
                }
            } else {
                popluateNextFollowUpTimeFromCustomMetadataRecord(mosLogicRecord, caseObj);
            }
        }
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to populate the Next followup time from Metadata records
Events : Before Update,Before Insert
Return Type : Map
*/
    
    public static void popluateNextFollowUpTimeFromCustomMetadataRecord(MOS_Task_Calculations__mdt mosLogicRecord, Case caseObj) {
        if (mosLogicRecord.Field__c == 'LastModifiedDate') {
            caseObj.Next_Follow_Up_Time__c = System.now().addSeconds(Integer.valueOf(mosLogicRecord.Delta_Time__c));
        } else {
            DateTime newDateTime;
            if (caseObj.get(mosLogicRecord.Field__c) != NULL) {
                newDateTime = (DateTime) caseObj.get(mosLogicRecord.Field__c);
                caseObj.Next_Follow_Up_Time__c = newDateTime.addSeconds(Integer.valueOf(mosLogicRecord.Delta_Time__c));
            } else if (String.isNotBlank(mosLogicRecord.Alternate_Field__c) && mosLogicRecord.Alternate_Delta_Time__c != NULL) {
                if (caseObj.get(mosLogicRecord.Alternate_Field__c) != NULL) {
                    newDateTime = (DateTime) caseObj.get(mosLogicRecord.Alternate_Field__c);
                    caseObj.Next_Follow_Up_Time__c = newDateTime.addSeconds(Integer.valueOf(mosLogicRecord.Alternate_Delta_Time__c));
                }
            }
        }
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get Task list
Events : Before Update,Before Insert
Return Type : Map
*/
    
    public static Map<String, List<Custom_Activity__c>> getTaskList(List<Case> newCaseList) {
        Set<String> setStage = new Set<String>();
        Set<Id> setCaseId = new Set<Id>();
        Map<String, List<Custom_Activity__c>> mapCaseIdAndStageToListOfTask = new Map<String, List<Custom_Activity__c>>();
        for (Case caseObj : newCaseList) {
            setCaseId.add(caseObj.Id);
            if (String.isNotBlank(caseObj.MOS_Case_Stage__c)) {
                setStage.add(caseObj.MOS_Case_Stage__c);
            }
        }
        
        if (setStage.size() > 0) {
            for (Custom_Activity__c taskObj : [
                SELECT Next_Follow_Up_time__c,Next_Follow_Up_remarks__c,Repeat_Call_Notification__c,Complaint_Status__c,Case__c
                FROM Custom_Activity__c
                WHERE Case__c IN :setCaseId
                AND RecordTypeId = :ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId
                AND Complaint_Status__c IN :setStage
                ORDER BY CreatedDate DESC
            ]) {
                String key = taskObj.Case__c + ConstantsUtility.keySeparator + taskObj.Complaint_Status__c;
                List<Custom_Activity__c> listTask = new List<Custom_Activity__c>();
                if (mapCaseIdAndStageToListOfTask.containsKey(key)) {
                    listTask = mapCaseIdAndStageToListOfTask.get(key);
                }
                listTask.add(taskObj);
                mapCaseIdAndStageToListOfTask.put(key, listTask);
            }
        }
        return mapCaseIdAndStageToListOfTask;
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to populate job type on case bases on Customer Consent
Events : Before Update,Before Insert
Return Type : Void
*/
    public static void populateJobType(Case caseObj) {
        if (caseObj.Customer_Consent__c == ConstantsUtility.Technician_Assistance) {
            caseObj.Job_Type__c = ConstantsUtility.Job_Type_Breakdown;
        } else if (caseObj.Customer_Consent__c == ConstantsUtility.Towing_Assistance) {
            caseObj.Job_Type__c = ConstantsUtility.JOB_TYPE_Accidental;
        }
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the MS Allianz MOS Master record
Events : Before Update,Before Insert
Return Type : List
*/
    
    public static List<Account> getMSAllianzRecord() {
        return [SELECT Id,Name FROM Account WHERE Name = :ConstantsUtility.MOS_MASTER_MS_ALLIANZ];
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the Metadata Records with Queue Name
Events : Before Update,Before Insert
Return Type : Map
*/
    public static Map<String, String> getMetadataRecordsWithQueue() {
        Map<String, String> mapKeyToQueueName = new Map<String, String>();
        
        for (MOS_Task_Calculations__mdt mosCalculation : [SELECT Job_Type__c,Case_Stage__c,Case_Sub_Stage__c,Queue__c FROM MOS_Task_Calculations__mdt WHERE Queue__c != NULL]) {
            String key = mosCalculation.Job_Type__c + ConstantsUtility.keySeparator + mosCalculation.Case_Stage__c;
            if (String.isNotBlank(mosCalculation.Case_Sub_Stage__c)) {
                key += ConstantsUtility.keySeparator + mosCalculation.Case_Sub_Stage__c;
            }
            mapKeyToQueueName.put(key, mosCalculation.Queue__c);
        }
        return mapKeyToQueueName;
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the information of Integration User
Events : Before Update,Before Insert
Return Type : List
*/
    
    public static Set<Id> getIntegrationUserDetails() {
        Set<Id> setIntegrationUserId = new Set<Id>();
        for(User usr :[SELECT Id FROM User WHERE /*Name = :ConstantsUtility.Integration_User AND*/ Is_Mule_User__c = true]){
            setIntegrationUserId.add(usr.Id);    
        }
        return setIntegrationUserId;
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the information of Queues
Events : Before Update,Before Insert
Return Type : Map
*/
    
    public static Map<String, String> getQueueMap(Map<String, String> mapKeyToQueueName) {
        Set<String> setQueueName = new Set<String>();
        Map<String, String> mapQueueNameToId = new Map<String, String>();
        for (String queueName : mapKeyToQueueName.values()) {
            setQueueName.add(queueName);
        }
        if (setQueueName.size() > 0) {
            for (Group que : [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name IN :setQueueName]) {
                mapQueueNameToId.put(que.Name, que.Id);
            }
        }
        return mapQueueNameToId;
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to assign cases to respective queue
Events : Before Update,Before Insert
Return Type : Void
*/
    public static void assignQueue(Case caseObj,Boolean isInsert) {
        if(isInsert) {
            String key = getKey(caseObj);
            if (mapKeyToQueueName.containsKey(key) && mapKeyToQueueName.get(key) != NULL 
                && mapQueueNameToId.containsKey(mapKeyToQueueName.get(key)) 
                && mapQueueNameToId.get(mapKeyToQueueName.get(key)) != NULL) {
                    caseObj.OwnerId = mapQueueNameToId.get(mapKeyToQueueName.get(key));
                }    
        }//Run the logic only if the owner is integratrion user if its a queue
        else if ((setIntegrationUserId.contains(caseObj.OwnerId) 
                    || (!(string.valueof(caseObj.OwnerID).startsWith(ConstantsUtility.UserPrefix))))
                    && (!isInsert)) {
            String key = getKey(caseObj);
            if (mapKeyToQueueName.containsKey(key) && mapKeyToQueueName.get(key) != NULL 
                && mapQueueNameToId.containsKey(mapKeyToQueueName.get(key)) 
                && mapQueueNameToId.get(mapKeyToQueueName.get(key)) != NULL){
                    caseObj.OwnerId = mapQueueNameToId.get(mapKeyToQueueName.get(key));
                }
        }
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get combination of Job Type,Case Stage and Sub Stage
Events : Before Update,Before Insert
Return Type : Void
*/
    public static String getKey(Case caseObj) {
        String key = '';
        if (String.isNotBlank(caseObj.Job_Type__c)) {
            key += caseObj.Job_Type__c;
        }
        if (String.isNotBlank(caseObj.MOS_Case_Stage__c)) {
            key += ConstantsUtility.keySeparator + caseObj.MOS_Case_Stage__c;
        }
        if (String.isNotBlank(caseObj.Towing_Sub_stage__c)) {
            key += ConstantsUtility.keySeparator + caseObj.Towing_Sub_stage__c;
        }
        return key;
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to get the metadata records which helps to populate time on the basis of the MOS Case Stage
Events : Before Update,Before Insert
Return Type : Map
*/
    public static Map<String, MOS_Case_Time_Population__mdt> getMetadataForTimePopulation() {
        Map<String, MOS_Case_Time_Population__mdt> mapStageNameToFieldAPIName = new Map<String, MOS_Case_Time_Population__mdt>();
        for (MOS_Case_Time_Population__mdt mosCaseTime : [SELECT Label,Field_API_Name__c,Field_API_Name_need_to_be_Blank__c FROM MOS_Case_Time_Population__mdt]) {
            mapStageNameToFieldAPIName.put(mosCaseTime.Label, mosCaseTime);
        }
        return mapStageNameToFieldAPIName;
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used populate time on the basis of the MOS Case Stage
Events : Before Update,Before Insert
Return Type : Map
*/
    public static void populateTimeOnStageChange(Case caseObj, String stageName) {
        if (mapStageNameToFieldAPIName.containsKey(stageName) && mapStageNameToFieldAPIName.get(stageName) != NULL) {
            MOS_Case_Time_Population__mdt mosCaseTime = mapStageNameToFieldAPIName.get(stageName);
            caseObj.put(mosCaseTime.Field_API_Name__c, System.now());
            if (String.isNotBlank(mosCaseTime.Field_API_Name_need_to_be_Blank__c)) {
                caseObj.put(mosCaseTime.Field_API_Name_need_to_be_Blank__c, null);
            }
        }
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used get MOS task record when the stage changes
Events : after Update,after Insert
Return Type : Task record
*/
    public static Task getNewTaskRecord(Id caseObjId,String ownerId,String caseStage) {
        Task newTaskObj = new Task();
        newTaskObj.RecordTypeId = ConstantsUtility.MOS_TASK_RecordType_Id;
        newTaskObj.WhatId = caseObjId;
        //newTaskObj.Call_Origin__c = ConstantsUtility.Call_Origin_Customer;
        //newTaskObj.Call_Direction__c = ConstantsUtility.Call_Direction_Outbound;
        //newTaskObj.Customer_Mobile__c = caseObj.Mobile_Number__c;
        //newTaskObj.Complaint_Status__c = caseObj.MOS_Case_Stage__c;
        newTaskObj.Subject = Label.MOS_TASK_Subject + ' ' + caseStage;
        newTaskObj.Status = ConstantsUtility.MOS_TASK_Status_Open;
        newTaskObj.ActivityDate = Date.today();
        newTaskObj.IsReminderSet = true;
        newTaskObj.ReminderDateTime = System.now();
        newTaskObj.OwnerId = ownerId;
        //newTaskObj.Due_Date_Time__c = System.now().addMinutes(ConstantsUtility.Fifteen_Minutes);
        return newTaskObj;
    }
    
    public static Custom_Activity__c getNewCustomTaskRecord(Case caseObj) {
        Custom_Activity__c newTaskObj = new Custom_Activity__c();
        newTaskObj.RecordTypeId = ConstantsUtility.CustomActivityMOSTaskRecordTypeId;
        newTaskObj.Case__c = caseObj.Id;
        newTaskObj.Call_Origin__c = ConstantsUtility.Call_Origin_Customer;
        newTaskObj.Call_Direction__c = ConstantsUtility.Call_Direction_Outbound;
        newTaskObj.Mobile__c = caseObj.Mobile_Number__c;
        newTaskObj.Complaint_Status__c = caseObj.MOS_Case_Stage__c;
        newTaskObj.Subject__c = Label.MOS_TASK_Subject + ' ' + caseObj.MOS_Case_Stage__c;
        String subject = Label.MOS_TASK_Subject + ' ' + caseObj.MOS_Case_Stage__c;
        if(String.isNotBlank(subject) && subject.length() > 80) {
            newTaskObj.Name =  subject.substring(0,76)+'...';     
        }
        else if(String.isNotBlank(subject) && subject.length() <= 80) {
            newTaskObj.Name =  subject;    
        }
        newTaskObj.Status__c = ConstantsUtility.MOS_TASK_Status_Open;
        //newTaskObj.ActivityDate = Date.today();
        newTaskObj.Reminder_Set__c  = true;
        newTaskObj.Reminder_DateTime__c = System.now();
        newTaskObj.OwnerId = caseObj.OwnerId;
        newTaskObj.Due_Date_Time__c = System.now().addMinutes(ConstantsUtility.Fifteen_Minutes);
        return newTaskObj;    
    }
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used get Case Action record when the MOS case is inserted
Events : after Insert
Return Type : Case Action record
*/
    
    public static Case_Actions__c getCaseActionRecord(Case caseObj) {
        Case_Actions__c caseAction = new Case_Actions__c();
        caseAction.RecordTypeId = ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id;
        caseAction.Case_Number__c = caseObj.Id;
        caseAction.Escalation_Update__c = System.now();
        caseAction.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Active;
        caseAction.Escalation_Level__c = ConstantsUtility.Case_Action_Escalation_Level_Amber;
        caseAction.Channel__c = 'MOS';
        return caseAction;
    }
    
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : Method to get the phone numbers of MC communication in a corresponding Maps
*/
    public static void getMCCommunicationAudiencePhoneNumbers(Set<Id> setTechnicianId,Set<Id> setAllocatedDealerId,Boolean msAllianz,List<Account> listMSAllianzRecords) {
        mapDesignationMSAllianzToPhoneNumbers = new Map<String,String>();
        mapRoleToPhoneNumbers = new Map<String,Set<String>>();
        mapTechnicianIdToPhoneNumbers = new Map<String,String>();
        mapAllocatedDealerToStakeHolderToPhoneNumbers = new Map<String,Map<String,String>>();
        mapAllocatedDealerToStakeHolderToEmails = new Map<String,Map<String,String>>();
        for(User usr : [SELECT Id,Email,UserRole.Name FROM USER WHERE UserRole.Name IN (:ConstantsUtility.RoleHOMOS,:ConstantsUtility.DPM_WPDCS_Role)]) {
            mapRoleUser.put(usr.UserRole.Name,usr.Email);    
        }
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
            for(Contact con : [SELECT Id,Phone,FE_Technician_ID__c FROM Contact WHERE Id IN :setTechnicianId]) {
                mapIdToTechnicianId.put(con.Id,con.FE_Technician_ID__c);
                if(con.Phone != NULL) {
                    mapTechnicianIdToPhoneNumbers.put(con.Id,con.Phone);    
                }
            }    
        }
        
        if(msAllianz && setDesignation.size() > 0 &&listMSAllianzRecords != NULL && listMSAllianzRecords.size() > 0) {
            for(Contact con : [SELECT Id,Phone,Designation__c FROM Contact WHERE AccountId = :listMSAllianzRecords[0].Id AND Designation__c IN :setDesignation]) {
                if(con.Phone != NULL) {
                    mapDesignationMSAllianzToPhoneNumbers.put(con.Designation__c,con.Phone);   
                }    
            }
        }
        
        if(setAllocatedDealerId != NULL && setAllocatedDealerId.size() > 0 && setStakeHolder.size() > 0) {
            for(Account acc : [SELECT Id,Stakeholder_Hierarchy__c,Name,Dealer_Code__c,BillingState,BillingCity
                               FROM Account WHERE Id IN :setAllocatedDealerId]) {
                                   mapIdToAllocatedDealer.put(acc.Id,acc);
                if(acc.Stakeholder_Hierarchy__c != NULL) {
                    Map<String,String> mapPhoneNumbers = new Map<String,String>();
                    Map<String,String> mapEmails = new Map<String,String>();
                    Map<String,Object> mapStakeHoldersToPhoneNumbers = (Map<String,Object>)	JSON.deserializeUntyped(acc.Stakeholder_Hierarchy__c );
                    If(mapStakeHoldersToPhoneNumbers != NULL && mapStakeHoldersToPhoneNumbers.keySet().size() > 0) {
                        populateHierarchy(mapStakeHoldersToPhoneNumbers,ConstantsUtility.SERVICE_NEXA_HIERARCHY,ConstantsUtility.NEXA_CASE_CHANNEL,mapPhoneNumbers,'phone'); 
                        populateHierarchy(mapStakeHoldersToPhoneNumbers,ConstantsUtility.SERVICE_ARENA_HIERARCHY,ConstantsUtility.ARENA_CASE_CHANNEL,mapPhoneNumbers,'phone');
                        populateHierarchy(mapStakeHoldersToPhoneNumbers,ConstantsUtility.SERVICE_NEXA_HIERARCHY,ConstantsUtility.NEXA_CASE_CHANNEL,mapEmails,'email');
                        populateHierarchy(mapStakeHoldersToPhoneNumbers,ConstantsUtility.SERVICE_ARENA_HIERARCHY,ConstantsUtility.ARENA_CASE_CHANNEL,mapEmails,'email');
                    }
                    mapAllocatedDealerToStakeHolderToPhoneNumbers.put(acc.Id,mapPhoneNumbers);
                    mapAllocatedDealerToStakeHolderToEmails.put(acc.Id,mapEmails);
                } 
            }    
        }
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : Method to Parse Allocated Dealer Hierarchy and populate phone numbers in a map
*/
    public static void populateHierarchy(Map<String,Object> mapStakeHoldersToPhoneNumbers,String nodeName,String channel,Map<String,String> mapPhoneNumbers,String key) {
        if(mapStakeHoldersToPhoneNumbers.containsKey(nodeName) && mapStakeHoldersToPhoneNumbers.get(nodeName) != NULL)  {
            List<Object> listServiceStakeHolder = (List<Object>) mapStakeHoldersToPhoneNumbers.get(nodeName);
            if(listServiceStakeHolder != NULL && listServiceStakeHolder.size() > 0) {
                for(Object obj : listServiceStakeHolder) {
                    Map<String,Object> mapKeyToValue = (Map<String,Object>)Obj;
                    if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0) {
                        if(setStakeHolder.contains((String)mapKeyToValue.get('stakeHolder')) && (String)mapKeyToValue.get(key) != NULL) {
                            mapPhoneNumbers.put((String)mapKeyToValue.get('stakeHolder')+ConstantsUtility.keySeparator+channel,(String)mapKeyToValue.get(key));    
                        }
                    }
                }
            }
        } 
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : Method to create CaseTeamMember 
*/
    
    //@future
    public static void createCaseTeamMembers(String triggerNew,String triggerOldMap,Boolean isInsert,Boolean isUpdate) {
        try{
            //list to store trigger new list
            List<Object> triggerNewList = (List<Object>)JSON.deserializeUntyped(triggerNew);
            //Map to store trigger old map
            Map<String,Object> triggerOldMapCase = (Map<String,Object>)JSON.deserializeUntyped(triggerOldMap);
            //set to store allocated dealer id
            Set<Id> setAllocatedDealer = new Set<Id>();
            //iterating over trigger new list to populated allocated dealer id set
            for(Object obj : triggerNewList) {
                Map<String,Object> mapFieldAPIToValue = (Map<String,Object>)obj;
                if(isInsert && (String)mapFieldAPIToValue.get('Allocated_Dealer__c') != NULL) {
                    setAllocatedDealer.add((String)mapFieldAPIToValue.get('Allocated_Dealer__c'));		    
                }
                else if(isUpdate && (String)mapFieldAPIToValue.get('Allocated_Dealer__c') != NULL) {
                    Map<String,Object> mapOldValueSet = (Map<String,Object>)triggerOldMapCase.get((String)mapFieldAPIToValue.get('Id'));
                    if((String)mapFieldAPIToValue.get('Allocated_Dealer__c') != (String)mapOldValueSet.get('Allocated_Dealer__c')){
                        setAllocatedDealer.add((String)mapFieldAPIToValue.get('Allocated_Dealer__c'));    
                    }    
                } 
            }
            //Map to store account in a map
            Map<Id,Account> mapIdToAllocatedDealer;
            if(setAllocatedDealer.size() > 0) {
                mapIdToAllocatedDealer = new Map<Id,Account>([SELECT Id,Arena_SRV_TSM__c,Service_SPOC_2__c,Service_SPOC_4__c,Nexa_SRV_TSM__c FROM Account WHERE Id IN :setAllocatedDealer]);	    
            }
            //fetching case team role
            Map<String,Id> mapCaseTeamRoleNameToRoleId = new Map<String,Id>();
            for(CaseTeamRole ctr : [SELECT Id,Name FROM CaseTeamRole WHERE Name IN :ConstantsUtility.setCaseTeamRoleMOS]) {
                mapCaseTeamRoleNameToRoleId.put(ctr.Name,ctr.Id);    
            }
            //list to store CaseTeamMember to insert
            List<CaseTeamMember> listCaseMember = new List<CaseTeamMember>();
            //Itearting over trigger new list to create CaseTeamMember
            //set to store Case id
            Set<Id> setCaseId = new Set<Id>();
            
            if(mapIdToAllocatedDealer != NULL && mapIdToAllocatedDealer.keySet().size() > 0 && mapCaseTeamRoleNameToRoleId.keySet().size() > 0) {
                for(Object obj : triggerNewList) {
                    Map<String,Object> mapFieldAPIToValue = (Map<String,Object>)obj;   
                    if(isInsert &&(String)mapFieldAPIToValue.get('Allocated_Dealer__c') != NULL && mapIdToAllocatedDealer.containsKey((String)mapFieldAPIToValue.get('Allocated_Dealer__c'))) {
                        createCaseTeamMember((String)mapFieldAPIToValue.get('Channel__c'),
                                             mapIdToAllocatedDealer.get((String)mapFieldAPIToValue.get('Allocated_Dealer__c')),
                                             mapCaseTeamRoleNameToRoleId,(String)mapFieldAPIToValue.get('Id'),listCaseMember);    
                    }
                    else if(isUpdate &&(String)mapFieldAPIToValue.get('Allocated_Dealer__c') != NULL && mapIdToAllocatedDealer.containsKey((String)mapFieldAPIToValue.get('Allocated_Dealer__c'))) {
                        Map<String,Object> mapOldValueSet = (Map<String,Object>)triggerOldMapCase.get((String)mapFieldAPIToValue.get('Id'));
                        if((String)mapFieldAPIToValue.get('Allocated_Dealer__c') != (String)mapOldValueSet.get('Allocated_Dealer__c')){
                            setCaseId.add((Id)mapFieldAPIToValue.get('Id'));
                            createCaseTeamMember((String)mapFieldAPIToValue.get('Channel__c'),
                                                 mapIdToAllocatedDealer.get((String)mapFieldAPIToValue.get('Allocated_Dealer__c')),
                                                 mapCaseTeamRoleNameToRoleId,(String)mapFieldAPIToValue.get('Id'),listCaseMember);     
                        } 	    
                    }
                }    
            }
            //Inserting Case Team Member
            if(listCaseMember.size() > 0) {
                insert listCaseMember;
                if(isUpdate && setCaseId.size() > 0) {
                    delete [SELECT Id FROM CaseTeamMember WHERE ParentId IN :setCaseId AND Id NOT IN :listCaseMember AND TeamRole.Name IN :ConstantsUtility.setCaseTeamRoleMOS];
                }
            }    
        }
        catch(Exception e) {
            ExceptionHandler.LogError('CaseTriggerHelper', e.getMessage()+':'+e.getLineNumber() , 'createCaseTeamMembers', '', null);
        }
        
    }
    
    public static void createCaseTeamMember(String channel,Account allocatedDealer,Map<String,Id> mapCaseTeamRoleNameToRoleId,
                                            String caseObjId,List<CaseTeamMember> listCaseMember) {
                                                if(channel == ConstantsUtility.NEXA_CASE_CHANNEL) {
                                                    getCaseTeamMember(mapCaseTeamRoleNameToRoleId,ConstantsUtility.MOSTSMCTR,allocatedDealer.Nexa_SRV_TSM__c,caseObjId,listCaseMember);
                                                    getCaseTeamMember(mapCaseTeamRoleNameToRoleId,ConstantsUtility.MOSROCCTR,allocatedDealer.Service_SPOC_4__c,caseObjId,listCaseMember);
                                                }
                                                else if(channel == ConstantsUtility.ARENA_CASE_CHANNEL) {
                                                    getCaseTeamMember(mapCaseTeamRoleNameToRoleId,ConstantsUtility.MOSTSMCTR,allocatedDealer.Arena_SRV_TSM__c,caseObjId,listCaseMember);
                                                    getCaseTeamMember(mapCaseTeamRoleNameToRoleId,ConstantsUtility.MOSROCCTR,allocatedDealer.Service_SPOC_2__c,caseObjId,listCaseMember);
                                                }
                                            }
    
    public static void getCaseTeamMember(Map<String,Id> mapCaseTeamRoleNameToRoleId,String roleName,String memberId,String parentId,List<CaseTeamMember> listCaseMember) {
        if(mapCaseTeamRoleNameToRoleId.containsKey(roleName) && memberId != NULL) {
            CaseTeamMember ctm = new CaseTeamMember();
            ctm.MemberId = memberId;
            ctm.ParentId = parentId;
            ctm.TeamRoleId = mapCaseTeamRoleNameToRoleId.get(roleName);
            listCaseMember.add(ctm);
        }    
    }
    
    public static void updateDetailsOnCaseFromAsset(Case caseObj,Map<String,Asset> mapVehicleNumberToVehicleAsset) {
        caseObj.Variant__c =  mapVehicleNumberToVehicleAsset.get(caseObj.Vehicle_Registration_Number__c).Product2Id; 
        caseObj.Variant_Description__c = mapVehicleNumberToVehicleAsset.get(caseObj.Vehicle_Registration_Number__c).Product2.Name;
        if(caseObj.Model_Txt__c == NULL) {
            caseObj.Model_Txt__c = mapVehicleNumberToVehicleAsset.get(caseObj.Vehicle_Registration_Number__c).Product2.Family;
        }
        caseObj.Color_Description__c = mapVehicleNumberToVehicleAsset.get(caseObj.Vehicle_Registration_Number__c).Color_of_the_Car__c; 	    
    }
    
}