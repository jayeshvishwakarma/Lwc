public with sharing class CaseEscalationService {
/**
Author: Gitika 
Company: Techmatrix
Description: method is used to update escalation details on case
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static void updateEscalationDetails(List<Case> triggerNewList, Map<Id, Case> triggerOldMap) {
    // map to store CCP Escalation Details.
    map<string, Case_Escalations_Matrix__mdt> ccpCaseEscaltionMap = new map<string, Case_Escalations_Matrix__mdt>();
    // map to store Case Resolution Escalation Details.
    map<string, Case_Escalations_Matrix__mdt> caseResolutionCaseEscaltionMap = new map<string, Case_Escalations_Matrix__mdt>();
    // helper method to retrieve records from Case Escalation Matrix metadata for CCP 
    ccpCaseEscaltionMap = CaseEscalationService.getEscalationsMatrices(ConstantsUtility.CCP);
    // helper method to retrieve records from Case Escalation Matrix metadata for Case Resolution 
    caseResolutionCaseEscaltionMap = CaseEscalationService.getEscalationsMatrices(ConstantsUtility.CASE_RESOLUTION);

    if (Trigger.IsInsert) {
        CaseEscalationService.insertCall(triggerNewList, ccpCaseEscaltionMap, caseResolutionCaseEscaltionMap);
    } else if (Trigger.IsUpdate) {
        CaseEscalationService.updateCall(triggerNewList, triggerOldMap, ccpCaseEscaltionMap, caseResolutionCaseEscaltionMap);
    }

}
/**
Author: Gitika 
Company: Techmatrix
Description: method is used For Insert Event
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/

public static void insertCall(List<Case> triggerNewList, map<string, Case_Escalations_Matrix__mdt> ccpCaseEscaltionMap, map<string, Case_Escalations_Matrix__mdt> caseResolutionCaseEscaltionMap) {
    // Instance of EnquiryEscalationService for checkBusinessHours method
    EnquiryEscalationService enqEscaltion = new EnquiryEscalationService();
    // Business Hour Id Stored in label
    Id businessHourId = label.Business_Hour_Id;

    // Case iteration starts..
    try {
        for (Case caseObj : triggerNewList) {
            // key with Channel+CaseType+BusinessArea
            String mainKey;
            // key with Channel+CaseType+BusinessArea+PrimaryCategory
            String mainKeyWithPrimarycat;

            mainKey = (caseObj.Channel__c != null ? caseObj.Channel__c : '');
            mainKey += (caseObj.Case_Type__c != null ? caseObj.Case_Type__c : '');
            mainKey += (caseObj.Business_Area__c != null ? caseObj.Business_Area__c : '');

            mainKeyWithPrimarycat = mainKey + (caseObj.Primary_Category__c != null ? caseObj.Primary_Category__c : '');

            // Insert Event For CCP Escalation
            if (Trigger.IsInsert && String.isNotBlank(String.valueOf(caseObj.Assigned_Date__c)) && String.isBlank(caseObj.CCP_Escalated_Level__c) && String.isBlank(String.valueOf(caseObj.CCP_Next_Escalation_Date_Time__c))) {
                if (CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, ConstantsUtility.LEVEL_1) != null) {
                    caseObj.CCP_Next_Escalation_Date_Time__c = CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, ConstantsUtility.LEVEL_1);
                }
            }
            // Insert Event For Case Escalation
            if (Trigger.IsInsert && String.isNotBlank(String.valueOf(caseObj.Assigned_Date__c)) && String.isBlank(String.valueOf(caseObj.Latest_Escalation_Date__c)) && String.isBlank(caseObj.Latest_Escalation_Level__c) &&
                    String.isBlank(String.valueOf(caseObj.Next_Escalation_Date__c)) && String.isBlank(caseObj.Next_Escalation_Level__c)) {
                if (CaseEscalationService.populateEscalationTime(caseObj, caseResolutionCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, true, ConstantsUtility.LEVEL_1) != null) {
                    caseObj.Next_Escalation_Date__c = CaseEscalationService.populateEscalationTime(caseObj, caseResolutionCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, true, ConstantsUtility.LEVEL_1);
                    caseObj.Next_Escalation_Level__c = ConstantsUtility.LEVEL_1;
                }
            }

        }
    } catch (Exception e) {
        
        ExceptionHandler.LogError('CaseEscalationService', e.getMessage() + e.getLineNumber(), 'insertCall', '', null);
    }
}
/**
Author: Gitika 
Company: Techmatrix
Description: method is used For update Event
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/

public static void updateCall(List<Case> triggerNewList, Map<Id, Case> triggerOldMap, map<string, Case_Escalations_Matrix__mdt> ccpCaseEscaltionMap, map<string, Case_Escalations_Matrix__mdt> caseResolutionCaseEscaltionMap) {
    // Instance of EnquiryEscalationService for checkBusinessHours method
    EnquiryEscalationService enqEscaltion = new EnquiryEscalationService();
    // Business Hour Id Stored in label
    Id businessHourId = label.Business_Hour_Id;

    // Case iteration starts..
    try {
        for (Case caseObj : triggerNewList) {
        // Escalations should not run when case is On Hold
        if(caseObj.status !='On Hold'){
            String mainKey;
            // key with Channel+CaseType+BusinessArea+PrimaryCategory
            String mainKeyWithPrimarycat;

            mainKey = (caseObj.Channel__c != null ? caseObj.Channel__c : '');
            mainKey += (caseObj.Case_Type__c != null ? caseObj.Case_Type__c : '');
            mainKey += (caseObj.Business_Area__c != null ? caseObj.Business_Area__c : '');

            mainKeyWithPrimarycat = mainKey + (caseObj.Primary_Category__c != null ? caseObj.Primary_Category__c : '');

            // Update Event for CCP Escalation
            if (Trigger.Isupdate  && triggerOldMap.get(caseObj.id).status!='On Hold' && String.isNotBlank(String.valueOf(caseObj.Assigned_Date__c)) && caseObj.CCP_Escalated__c == true && triggerOldMap.get(caseObj.id).CCP_Escalated__c == false) {
                caseObj.CCP_Escalated__c = false;
                if (string.isBlank(caseObj.CCP_Escalated_Level__c)) {
                    if (CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainKey, mainkeyWithPrimarycat, false, ConstantsUtility.LEVEL_2) != null) {
                        caseObj.CCP_Escalated_Level__c = ConstantsUtility.LEVEL_1;
                        caseObj.CCP_Next_Escalation_Date_Time__c = CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, ConstantsUtility.LEVEL_2);
                    } else {
                        caseObj.CCP_Next_Escalation_Date_Time__c = null;
                    }
                } else {
                    string level = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.CCP_Escalated_Level__c.split(' ')[1]) + 2);
                    if (CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, level) != null) {
                        caseObj.CCP_Escalated_Level__c = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.CCP_Escalated_Level__c.split(' ')[1]) + 1);
                        caseObj.CCP_Next_Escalation_Date_Time__c = CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, level);
                    } else {
                        caseObj.CCP_Escalated_Level__c = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.CCP_Escalated_Level__c.split(' ')[1]) + 1);
                        caseObj.CCP_Next_Escalation_Date_Time__c = null;
                    }
                }
            }
            // Update Event for Case Resolution Escalation
            if (Trigger.Isupdate && triggerOldMap.get(caseObj.id).status!='On Hold' && String.isNotBlank(String.valueOf(caseObj.Assigned_Date__c)) && caseObj.Case_Resolution_Escalated__c == true && triggerOldMap.get(caseObj.id).Case_Resolution_Escalated__c == false) {
                caseObj.Case_Resolution_Escalated__c = false;
                caseObj.Latest_Escalation_Date__c = caseObj.Next_Escalation_Date__c != null ? caseObj.Next_Escalation_Date__c : (caseObj.Latest_Escalation_Date__c != null ? caseObj.Latest_Escalation_Date__c : null);
                caseObj.Latest_Escalation_Level__c = caseObj.Next_Escalation_Level__c != null ? caseObj.Next_Escalation_Level__c : (caseObj.Latest_Escalation_Level__c != null ? caseObj.Latest_Escalation_Level__c : null);
                string level = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.Next_Escalation_Level__c.split(' ')[1]) + 1);

                if (CaseEscalationService.populateEscalationTime(caseObj, caseResolutionCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, true, level) != null) {
                    caseObj.Next_Escalation_Level__c = level;
                    caseObj.Next_Escalation_Date__c = CaseEscalationService.populateEscalationTime(caseObj, caseResolutionCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, true, level);
                } else {
                    caseObj.Next_Escalation_Date__c = null;
                    caseObj.Next_Escalation_Level__c = null;
                }
            }
            // recalculate after On Hold 
            if(String.isNotBlank(String.valueOf(caseObj.Assigned_Date__c)) && caseObj.status != 'On Hold' && triggerOldMap.get(caseObj.id).status=='On Hold'){
               // Update Event for CCP Escalation
                if (string.isBlank(caseObj.CCP_Escalated_Level__c)) {
                    if (CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainKey, mainkeyWithPrimarycat, false,ConstantsUtility.LEVEL_1) != null) {
                        caseObj.CCP_Next_Escalation_Date_Time__c = CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false,ConstantsUtility.LEVEL_1);
                    } else {
                        caseObj.CCP_Next_Escalation_Date_Time__c = null;
                    }
                } else {
                    string level = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.CCP_Escalated_Level__c.split(' ')[1]) + 1);
                    if (CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, level) != null) {
                        caseObj.CCP_Next_Escalation_Date_Time__c = CaseEscalationService.populateEscalationTime(caseObj, ccpCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, false, level);
                    } else {
                        caseObj.CCP_Escalated_Level__c = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.CCP_Escalated_Level__c.split(' ')[1]) + 1);
                        caseObj.CCP_Next_Escalation_Date_Time__c = null;
                    }
                }
                // Update Event for Case Resolution Escalation 
                string level = label.Custom_Key_For_Level + ' ' + (caseObj.Latest_Escalation_Level__c != null ? String.valueOf(Integer.valueOf(caseObj.Latest_Escalation_Level__c.split(' ')[1]) + 1) :'1');

                if (CaseEscalationService.populateEscalationTime(caseObj, caseResolutionCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, true, level) != null) {
                    caseObj.Next_Escalation_Level__c = level;
                    caseObj.Next_Escalation_Date__c = CaseEscalationService.populateEscalationTime(caseObj, caseResolutionCaseEscaltionMap, enqEscaltion, businessHourId, mainkey, mainkeyWithPrimarycat, true, level);
                } else {
                    caseObj.Next_Escalation_Date__c = null;
                    caseObj.Next_Escalation_Level__c = null;
                }  
            }
        }else{
            caseObj.Next_Escalation_Date__c = null;
            caseObj.Next_Escalation_Level__c = null; 
            caseObj.CCP_Next_Escalation_Date_Time__c = null; 
        }

        }
    } catch (Exception e) {
        
        ExceptionHandler.LogError('CaseEscalationService', e.getMessage() + e.getLineNumber(), 'updateCall', '', null);
    }
}
/**
Author: Gitika 
Company: Techmatrix
Description: method is used to get EscalationsMatrices
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static Datetime populateEscalationTime(Case caseObj, map<string, Case_Escalations_Matrix__mdt> caseEscalationMatrix, EnquiryEscalationService enqEscaltion,
        Id businessHourId, string key, string keyWithPrimarycat, boolean isCaseResolution, string level) {

    key = key + level;
    keyWithPrimarycat = keyWithPrimarycat + level;

    if (caseEscalationMatrix.containskey(key) || caseEscalationMatrix.containskey(keyWithPrimarycat)) {
        string keyValue = caseEscalationMatrix.containskey(keyWithPrimarycat) ? keyWithPrimarycat : key;
        Integer addMinutes = 0;
        if (isCaseResolution) {
            addMinutes = caseEscalationMatrix.get(keyValue) != null ? Integer.valueOf(caseEscalationMatrix.get(keyValue).Time_to_Next_Escalation__c) * 24 * 60 : Integer.valueOf(label.Default_Time_for_Escalation);
        } else {
            addMinutes = caseEscalationMatrix.get(key) != null ? Integer.valueOf(caseEscalationMatrix.get(key).Time_to_Next_Escalation__c) : Integer.valueOf(label.Default_Time_for_Escalation);
        }
        DateTime assignedDateTime = caseObj.Assigned_Date__c;
        integer noOfDays=0;
        if(String.isNotBlank(String.valueOf(caseObj.On_Hold_Start_date__c)) && String.isNotBlank(String.valueOf(caseObj.On_Hold_End_date__c))){
            noOfDays = (caseObj.On_Hold_Start_date__c).daysBetween(caseObj.On_Hold_End_date__c);
            system.debug('noOfDays-->'+noOfDays);
        }
        assignedDateTime = assignedDateTime.adddays(noOfDays);
        system.debug('assignedDateTime-->'+assignedDateTime);
        assignedDateTime = assignedDateTime.addMinutes(addminutes);
        system.debug('assignedDateTime-->'+assignedDateTime);
        system.debug('addMinutes-->'+addMinutes);
        // for testing need to be removed
        caseObj.test__c=assignedDateTime;
        assignedDateTime = (businessHourId != null) ? enqEscaltion.checkBusinessHours(businessHourId, assignedDateTime, addminutes) : assignedDateTime;
        return assignedDateTime;
    }
    return null;
}
/**
Author: Gitika 
Company: Techmatrix
Description: method is used to get EscalationsMatrices
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static map<string, Case_Escalations_Matrix__mdt> getEscalationsMatrices(String escalationType) {
    // map of Case Escalation matrix metadata with key as Channel__c+Case_Type__c+Business_Area__c+Escalation_Level__c
    map<string, Case_Escalations_Matrix__mdt> caseEscaltionMap = new map<string, Case_Escalations_Matrix__mdt>();

    for (Case_Escalations_Matrix__mdt caseEscalationsMatrices : [
            SELECT Id,Case_Type__c,Escalation_Level__c,Channel__c,Business_Area__c,
                    Escalation_Type__c,Notifiers__c,MasterLabel,Time_to_Next_Escalation__c,Primary_Category__c
            FROM Case_Escalations_Matrix__mdt
            where Escalation_Type__c = :escalationType
    ]) {

        String key = (caseEscalationsMatrices.Channel__c != null ? caseEscalationsMatrices.Channel__c : '');
        key += (caseEscalationsMatrices.Case_Type__c != null ? caseEscalationsMatrices.Case_Type__c : '');
        key += (caseEscalationsMatrices.Business_Area__c != null ? caseEscalationsMatrices.Business_Area__c : '');
        key += (caseEscalationsMatrices.Escalation_Level__c != null ? caseEscalationsMatrices.Escalation_Level__c : '');
        caseEscaltionMap.put(key, caseEscalationsMatrices);
    }
    return caseEscaltionMap;
}
/**
Author: Gitika 
Company: Techmatrix
Description: method is used to create MC Communication Records
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static void postChatterAndMCRecordsEscalation(List<Case> triggerNewList, Map<Id, Case> triggerOldMap) {

    map<string, Case_Escalations_Matrix__mdt> ccpCaseEscaltionMap = new map<string, Case_Escalations_Matrix__mdt>();

    map<string, Case_Escalations_Matrix__mdt> ccpReminderCaseEscaltionMap = new map<string, Case_Escalations_Matrix__mdt>();

    map<string, Case_Escalations_Matrix__mdt> caseResolutionCaseEscaltionMap = new map<string, Case_Escalations_Matrix__mdt>();

    List<Case> ccpCaseList = new List<Case>();

    List<Case> caseResolutionList = new List<Case>();

    Set<Id> primaryCatId = new Set<Id>();
    map<string, String> mapOfDealerIdWithName = new map<string, String>();
    map<string, String> mapOfVariantIdWithName = new map<string, String>();
    map<string, For_Code__c> mapOfForCodeIdWithCity = new map<string, For_Code__c>();
    ccpCaseEscaltionMap = CaseEscalationService.getEscalationsMatrices(ConstantsUtility.CCP);

    ccpReminderCaseEscaltionMap = CaseEscalationService.getEscalationsMatrices(ConstantsUtility.CCP_REMINDER);

    caseResolutionCaseEscaltionMap = CaseEscalationService.getEscalationsMatrices(ConstantsUtility.CASE_RESOLUTION);

    for (case caseObj : triggerNewList) {
        if (String.IsNotBlank(caseObj.Primary_Category_ID__c) && String.isNotBlank(String.valueof(caseObj.Next_Escalation_Date__c)) && (Trigger.isInsert
                || (Trigger.isUpdate && caseObj.Next_Escalation_Date__c != triggerOldMap.get(caseObj.id).Next_Escalation_Date__c))) {
                caseResolutionList.add(caseObj);

              if (caseObj.Tertiary_Category_ID__c != null) {
                primaryCatId.add(caseObj.Tertiary_Category_ID__c);
                } else if (caseObj.Secondary_Category_ID__c != null) {
                primaryCatId.add(caseObj.Secondary_Category_ID__c);
                } else if (caseObj.Primary_Category_ID__c != null) {
                primaryCatId.add(caseObj.Primary_Category_ID__c);
                }

            if(caseObj.Dealer_Name__c!=null){
                mapOfDealerIdWithName.put(caseObj.Dealer_Name__c,null);
            }if(caseObj.Variant__c!=null){
                mapOfVariantIdWithName.put(caseObj.Variant__c,null);
            }if(caseObj.for_Code__c!=null){
                mapOfForCodeIdWithCity.put(caseObj.for_Code__c,null);
            }
        }
        if (String.isNotBlank(String.valueof(caseObj.CCP_Next_Escalation_Date_Time__c)) && (Trigger.isInsert
                || (Trigger.isUpdate && caseObj.CCP_Next_Escalation_Date_Time__c != triggerOldMap.get(caseObj.id).CCP_Next_Escalation_Date_Time__c))) {
            ccpCaseList.add(caseObj);
            if(caseObj.Dealer_Name__c!=null){
                mapOfDealerIdWithName.put(caseObj.Dealer_Name__c,null);
            }if(caseObj.Variant__c!=null){
                mapOfVariantIdWithName.put(caseObj.Variant__c,null);
            }if(caseObj.for_Code__c!=null){
                mapOfForCodeIdWithCity.put(caseObj.for_Code__c,null);
            }
        }
    }
    if(mapOfDealerIdWithName.size()>0){
        for(Account acc : [Select Name,Id from Account where id in :mapOfDealerIdWithName.keyset()]){
            mapOfDealerIdWithName.put(acc.id,acc.name); 
        }
    }
    if(mapOfVariantIdWithName.size()>0){
        for(Product2 prod : [Select Name,Id from Product2 where id in :mapOfVariantIdWithName.keyset()]){
            mapOfVariantIdWithName.put(prod.id,prod.name); 
        }
    }
    if(mapOfForCodeIdWithCity.size()>0){
        for(For_Code__c city : [Select Name,Id,For_Code__c from For_Code__c where id in :mapOfForCodeIdWithCity.keyset()]){
            mapOfForCodeIdWithCity.put(city.id,city); 
        }
    }
    if (ccpCaseList.size() > 0) {
        CaseEscalationService.ccpMcCommunication(ccpCaseList, ccpCaseEscaltionMap,ConstantsUtility.CCP,mapOfDealerIdWithName,mapOfVariantIdWithName,mapOfForCodeIdWithCity);
        CaseEscalationService.ccpMcCommunication(ccpCaseList, ccpReminderCaseEscaltionMap,ConstantsUtility.CCP_REMINDER,mapOfDealerIdWithName,mapOfVariantIdWithName,mapOfForCodeIdWithCity);
    }
    if (caseResolutionList.size() > 0 && primaryCatId.size() > 0) {
        CaseEscalationService.caseResolutionMcCommunication(caseResolutionList, primaryCatId,caseResolutionCaseEscaltionMap,mapOfDealerIdWithName,mapOfVariantIdWithName,mapOfForCodeIdWithCity);
    }
}
/**
Author: Gitika 
Company: Techmatrix
Description: method to Create MC Communication Record For CCP 
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static void ccpMcCommunication(List<Case> ccpCaseList, map<string, Case_Escalations_Matrix__mdt> ccpCaseEscaltionMap,String Type,
                                      map<string, String> mapOfDealerIdWithName,map<string, String> mapOfVariantIdWithName,map<string,For_Code__c> mapOfForCodeIdWithCity) {

    list<MC_Communication__c> mcComList = new list<MC_Communication__c>();
    try {
        // map  of case recordid with set of Notifiers
        map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
       // map  of id with message
       map<Id, string> recordIdVsMessageMap = new map<Id, string>();

        map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders = CaseEscalationService.mapOfcaseIdWithMapOfStakeHolders(ccpCaseList);

        for (Case caseObj : ccpCaseList) {
            map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails = new map<string, StakeholderHierarchy.Sales>();
            List<String> notifiers = new List<String>();
            String mainKey;
            String mainKeyWithPrimarycat;

            mainKey = (caseObj.Channel__c != null ? caseObj.Channel__c : '');
            mainKey += (caseObj.Case_Type__c != null ? caseObj.Case_Type__c : '');
            mainKey += (caseObj.Business_Area__c != null ? caseObj.Business_Area__c : '');

            mainKeyWithPrimarycat = mainKey + (caseObj.Primary_Category__c != null ? caseObj.Primary_Category__c : '');

            string ccpNextEscalationLevel = String.isNotBlank(caseObj.CCP_Escalated_Level__c) ? String.valueOf(Integer.valueOf(caseObj.CCP_Escalated_Level__c.split(' ')[1]) + 1) : '1';
            string customMetadataLevel = label.Custom_Key_For_Level + ' ' + ccpNextEscalationLevel;

            mainKey = mainKey + customMetadataLevel;

            if (ccpCaseEscaltionMap.containsKey(mainKey) && mapOfCaseIdWithStakeHolders.containskey(caseObj.id) && mapOfCaseIdWithStakeHolders.get(caseObj.id).size() > 0) {
                notifiers = String.isNotBlank(ccpCaseEscaltionMap.get(mainKey).Notifiers__c) ? ccpCaseEscaltionMap.get(mainKey).Notifiers__c.split('\\,') : notifiers;
                mapOFStakeholderWithdetails = mapOfCaseIdWithStakeHolders.get(caseObj.id);
            }
            if (notifiers.size() > 0 && mapOFStakeholderWithdetails.size() > 0) {
                string mobile='';
                MC_Communication__c mc = new MC_Communication__c();
                mc= MCCommunicationService.getMCComCaseMapping(caseObj,mc,null,null,mapOfDealerIdWithName,mapOfVariantIdWithName);
                mc.General_Field_1__c = caseObj.case_sub_type__c;
                mc.dealer_Field_1__c = mapOfDealerIdWithName.containsKey(caseObj.Dealer_Name__c)?mapOfDealerIdWithName.get(caseObj.Dealer_Name__c):null;
                mc.Escalation_Date_Time__c = caseObj.CCP_Next_Escalation_Date_Time__c;
                mc.General_Field_2__c = customMetadataLevel;
                mc.Case__c = caseObj.id;
                mc.Type__C=Type;
                mc.Status__c='Queued';

                // send chatter notification
                // set to store ids for chatter Notification
                if(Type==ConstantsUtility.CCP){
                  set<String> recordId= new set<String>();
                  // chatter Notification
                  for (string str : notifiers) {
                    if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).recordId)) {
                        recordId.add(mapOFStakeholderWithdetails.get(str).recordId); }
                    }
                 if(recordId.size()>0){
                    recordIdVsMessageMap.put(caseObj.id, CaseEscalationService.chatterNotificationMapping(mc,caseObj,ConstantsUtility.CASE_CCP_CHATTER_MSG,mapOfForCodeIdWithCity));
                    recordIdVdNotifiersMap.put(caseObj.id,recordId);
                 }
                }

                mcComList.add(CaseEscalationService.mcMapping(mc.clone(),notifiers,null,null,mapOFStakeholderWithdetails));
                mc.clone().cc_Address__c='';
                mc.clone().To_Address__c='';
                mcComList.add(CaseEscalationService.mcMapping(mc,null,null,notifiers,mapOFStakeholderWithdetails));
                
            }

        }
        if (mcComList.size() > 0) {
            insert mcComList;
        }
        // method to send chatter notification
        if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
            ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
        }
    } catch (Exception e) {
        
        ExceptionHandler.LogError('CaseEscalationService', e.getMessage() + e.getLineNumber(), 'ccpMCComunication', '', null);
    }
}
/**
Author: Gitika 
Company: Techmatrix
Description: method to Create MC Communication Record For Case Resolution
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static void caseResolutionMcCommunication(List<Case> caseResolutionList, Set<Id> primaryCatId,map<string, Case_Escalations_Matrix__mdt> caseResolutionCaseEscaltionMap,
                                                 map<string, String> mapOfDealerIdWithName,map<string, String> mapOfVariantIdWithName,map<string,For_Code__c> mapOfForCodeIdWithCity) {

    list<MC_Communication__c> mcComList = new list<MC_Communication__c>();
    try {
        // map  of case recordid with set of Notifiers
        map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
       // map  of id with message
       map<Id, string> recordIdVsMessageMap = new map<Id, string>();

        map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders = CaseEscalationService.mapOfcaseIdWithMapOfStakeHolders(caseResolutionList);

        Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();

        categoryIdVsMapOfRegionAndRecipientMasterMap = CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(primaryCatId);

        for (Case caseObj : caseResolutionList) {

            map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails = new map<string, StakeholderHierarchy.Sales>();

            list<string> toNotifiers = new list<String>();
            List<String> notifiers = new List<String>();
            list<string> ccNotifiers = new list<String>();
            String Mobile='';
            String toEmail='';
            String ccEmail='';
            String categoryID='';

            Map<String, Recipient_Master__c> regionWithRecipientMaster = new Map<String, Recipient_Master__c>();
            String mainKey;
            String mainKeyWithPrimarycat;

            mainKey = (caseObj.Channel__c != null ? caseObj.Channel__c : '');
            mainKey += (caseObj.Case_Type__c != null ? caseObj.Case_Type__c : '');
            mainKey += (caseObj.Business_Area__c != null ? caseObj.Business_Area__c : '');

            
            if (caseObj.Tertiary_Category_ID__c != null) {
                categoryID =caseObj.Tertiary_Category_ID__c;
                } else if (caseObj.Secondary_Category_ID__c != null) {
                categoryID =caseObj.Secondary_Category_ID__c;
                } else if (caseObj.Primary_Category_ID__c != null) {
                    categoryID =caseObj.Primary_Category_ID__c;
                }

            mainKeyWithPrimarycat = mainKey + categoryID;

            if(String.isnotBlank(caseObj.Next_Escalation_Level__c)){
                string level = label.Custom_Key_For_Level + ' ' + String.valueOf(Integer.valueOf(caseObj.Next_Escalation_Level__c.split(' ')[1]) + 1);
                mainKey = mainKey + level;
            }

            if( mapOfCaseIdWithStakeHolders.containskey(caseObj.id) && mapOfCaseIdWithStakeHolders.get(caseObj.id).size() > 0){
                mapOFStakeholderWithdetails = mapOfCaseIdWithStakeHolders.get(caseObj.id);
            }

            if (caseResolutionCaseEscaltionMap.containsKey(mainKey) ) {
                notifiers = String.isNotBlank(caseResolutionCaseEscaltionMap.get(mainKey).Notifiers__c) ? caseResolutionCaseEscaltionMap.get(mainKey).Notifiers__c.split('\\,') : notifiers;
            }
            if (categoryIdVsMapOfRegionAndRecipientMasterMap.containskey(categoryID)) {

                regionWithRecipientMaster = categoryIdVsMapOfRegionAndRecipientMasterMap.get(categoryID);

                Recipient_Master__c recipientMasterRecord = regionWithRecipientMaster.containsKey(caseObj.Region_Code__c) ? regionWithRecipientMaster.get(caseObj.Region_Code__c) : (regionWithRecipientMaster.containsKey(ConstantsUtility.REGION_ALL) ? regionWithRecipientMaster.get(ConstantsUtility.REGION_ALL) : null);

                if (recipientMasterRecord != null && ConstantsUtility.mapOfLevelWithRecipentMasterLevelFields.containskey(caseObj.Next_Escalation_Level__c)) {

                    toNotifiers = String.isNotBlank((string) recipientMasterRecord.get(ConstantsUtility.mapOfLevelWithRecipentMasterLevelFields.get(caseObj.Next_Escalation_Level__c).split(';')[1])) ?
                            string.valueof(recipientMasterRecord.get(ConstantsUtility.mapOfLevelWithRecipentMasterLevelFields.get(caseObj.Next_Escalation_Level__c).split(';')[1])).split(';') : toNotifiers;

                    ccNotifiers = String.isNotBlank((string) recipientMasterRecord.get(ConstantsUtility.mapOfLevelWithRecipentMasterLevelFields.get(caseObj.Next_Escalation_Level__c).split(';')[0])) ?
                            string.valueof(recipientMasterRecord.get(ConstantsUtility.mapOfLevelWithRecipentMasterLevelFields.get(caseObj.Next_Escalation_Level__c).split(';')[0])).split(';') : ccNotifiers;

                }

            }
            if ((toNotifiers.size() > 0 || notifiers.size()>0) && mapOFStakeholderWithdetails.size() > 0) {
                // Creating MC Communcation records for each stakeholder
                
                MC_Communication__c mc = new MC_Communication__c();
                mc= MCCommunicationService.getMCComCaseMapping(caseObj,mc,null,null,mapOfDealerIdWithName,mapOfVariantIdWithName);
                mc.General_Field_1__c = caseObj.case_sub_type__c;
                mc.Escalation_Date_Time__c = caseObj.Next_Escalation_Date__c;
                mc.General_Field_2__c = String.isnotBlank(caseObj.Next_Escalation_Level__c) ? caseObj.Next_Escalation_Level__c : null;
                mc.Case__c = caseObj.id;
                mc.Type__C=ConstantsUtility.DEALER_RESOLUTION_ESCALATION;
                mc.Status__c='Queued';

                // send chatter notification
                // set to store ids for chatter Notification
                 set<String> recordId= new set<String>();
                  // chatter Notification
                 for (string str : notifiers) {
                  if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).recordId)) {
                       recordId.add(mapOFStakeholderWithdetails.get(str).recordId); }
                  }
                if(recordId.size()>0){
                    recordIdVsMessageMap.put(caseObj.id, CaseEscalationService.chatterNotificationMapping(mc,caseObj,ConstantsUtility.CASE_CASE_RESOLUTION_CHATTER_MSG,mapOfForCodeIdWithCity));
                    recordIdVdNotifiersMap.put(caseObj.id,recordId);
                }

                mcComList.add(CaseEscalationService.mcMapping(mc.clone(),toNotifiers,ccNotifiers,null,mapOFStakeholderWithdetails));
                mc.clone().cc_Address__c='';
                mc.clone().To_Address__c='';
                mcComList.add(CaseEscalationService.mcMapping(mc,null,null,notifiers,mapOFStakeholderWithdetails));
            
            }       
        }
        if (mcComList.size() > 0) {
            insert mcComList;
        }
        // method to send chatter notification
        if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
            ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
        }
    } catch (Exception e) {
        
        ExceptionHandler.LogError('CaseEscalationService', e.getMessage() + e.getLineNumber(), 'caseResolutionMCComunication', '', null);
    }
}

/**
Author: Gitika
Company: Techmatrix
Description: Method to MC Comm Mapping
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
public static MC_Communication__c mcMapping(MC_Communication__c mcRecord1,list<string> toNotifiersEmail,list<string> ccNotifiersEmail,
                                           list<string> notifiersphone,map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails) {
 string toEmail='';
 string ccEmail='';
 string Mobile='';


 if(toNotifiersEmail != null){
    mcRecord1.Communication_Type__c='Email';
    for (string str : toNotifiersEmail) {
        system.debug('str-->'+str);
        
        if(mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)){
            system.debug('dd-->'+mapOFStakeholderWithdetails.get(str).email);
            toEmail = toEmail+mapOFStakeholderWithdetails.get(str).email+',';
        }
    }
    toEmail=toEmail.removeEnd(',');
    mcRecord1.To_Address__c=toEmail;
    if(ccNotifiersEmail != null){
        for (string str : ccNotifiersEmail) {
            if(mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)){
                ccEmail = ccEmail+mapOFStakeholderWithdetails.get(str).email+',';
            }
        }
        ccEmail=ccEmail.removeEnd(',');
        mcRecord1.cc_Address__c=ccEmail;
    }

 }
 else if(notifiersphone != null){
    mcRecord1.Communication_Type__c='SMS';
    for (string str : notifiersphone) {
        if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).phone)) {
            Mobile = Mobile+mapOFStakeholderWithdetails.get(str).phone+',';
            
        }
    }
   Mobile=Mobile.removeEnd(',');
   mcRecord1.Recipient_Phone_Numbers__c = String.isnotblank(Mobile) ? Mobile : null;
  
  }
   return mcRecord1;
 }
/**
Author: Gitika
Company: Techmatrix
Description: Method to store Chatter Notifications mapping
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
public static string chatterNotificationMapping(MC_Communication__c mcRecord1,case caseRecord,string message,map<string, For_Code__c> mapOfForCodeIdWithCity){

        string caseType = caseRecord.Case_Type__c != null?caseRecord.Case_Type__c:'';
        string caseNumber = caseRecord.CaseNumber != null?caseRecord.CaseNumber:'';
        string duration = mcRecord1.Escalation_Date_Time__c != null?string.valueof((mcRecord1.Escalation_Date_Time__c.getTime()-datetime.now().getTime())/(1000*60*60)):'';
        string customerName = '';
        customerName = customerName + (mcRecord1.Customer_Field_1__c != null?mcRecord1.Customer_Field_1__c+' ':'');
        customerName = customerName + (mcRecord1.Customer_Field_2__c != null?mcRecord1.Customer_Field_2__c+' ':'');
        customerName = customerName + (mcRecord1.Customer_Field_3__c != null?mcRecord1.Customer_Field_3__c:'');
        string customerPhoneNo = caseRecord.Mobile_Number__c != null?caseRecord.Mobile_Number__c:'';
        string primaryCategory = caseRecord.Primary_Category__c != null?caseRecord.Primary_Category__c:'';
        string Variant = mcRecord1.General_Field_7__c != null?mcRecord1.General_Field_7__c:'';
        string dealerName = mcRecord1.Dealer_Field_1__c != null?mcRecord1.Dealer_Field_1__c:'';
        string dealerCode = mcRecord1.Dealer_Field_3__c != null?mcRecord1.Dealer_Field_3__c:'';
        string forCode ='';
        if(mapOfForCodeIdWithCity!=null){
            forCode = string.isNotblank(caseRecord.For_Code__c)?(mapOfForCodeIdWithCity.containsKey(caseRecord.For_Code__c)?mapOfForCodeIdWithCity.get(caseRecord.For_Code__c).For_Code__c:''):'';
        }
        string city='';
        if(mapOfForCodeIdWithCity!=null){
            city = string.isNotblank(caseRecord.For_Code__c)?(mapOfForCodeIdWithCity.containsKey(caseRecord.For_Code__c)?mapOfForCodeIdWithCity.get(caseRecord.For_Code__c).Name:''):'';
        }
        string Region = mcRecord1.General_Field_6__c != null?mcRecord1.General_Field_6__c:'';
        string LevelofEscalation = mcRecord1.General_Field_2__c != null?mcRecord1.General_Field_2__c:'';
        string CaseSubType = caseRecord.Case_sub_Type__c != null?caseRecord.Case_sub_Type__c:'';
        string Channel = caseRecord.Channel__c != null?caseRecord.Channel__c:'';
        string BusinessArea = caseRecord.Business_Area__c != null?caseRecord.Business_Area__c:'';
        string CaseStage = caseRecord.Case_stage__c != null?caseRecord.Case_stage__c:'';


        message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT,caseNumber) : message;
        message = message.contains(ConstantsUtility.CASE_TYPE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_TYPE_REPLACEMENT,caseType) : message;
        message = message.contains(ConstantsUtility.DURATION_REPLACEMENT) ? message.replace(ConstantsUtility.DURATION_REPLACEMENT,duration) : message;
        message = message.contains(ConstantsUtility.CUSTOMER_NAME_REPLACEMENT) ? message.replace(ConstantsUtility.CUSTOMER_NAME_REPLACEMENT,customerName) : message;
        message = message.contains(ConstantsUtility.CUSTOMER_PHONE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CUSTOMER_PHONE_NUMBER_REPLACEMENT,customerPhoneNo) : message;
        message = message.contains(ConstantsUtility.PRIMARY_CATEGORY_REPLACEMENT) ? message.replace(ConstantsUtility.PRIMARY_CATEGORY_REPLACEMENT,primaryCategory) : message;
        message = message.contains(ConstantsUtility.VARIANT_REPLACEMENT) ? message.replace(ConstantsUtility.VARIANT_REPLACEMENT,Variant) : message;
        message = message.contains(ConstantsUtility.DEALER_NAME_REPLACEMENT) ? message.replace(ConstantsUtility.DEALER_NAME_REPLACEMENT,dealerName) : message;
        message = message.contains(ConstantsUtility.DEALER_CODE_REPLACEMENT) ? message.replace(ConstantsUtility.DEALER_CODE_REPLACEMENT,dealerCode) : message;
        message = message.contains(ConstantsUtility.FOR_CODE_REPLACEMENT) ? message.replace(ConstantsUtility.FOR_CODE_REPLACEMENT,forCode) : message;
        message = message.contains(ConstantsUtility.CITY_REPLACEMENT) ? message.replace(ConstantsUtility.CITY_REPLACEMENT,city) : message;
        message = message.contains(ConstantsUtility.REGION_REPLACEMENT) ? message.replace(ConstantsUtility.REGION_REPLACEMENT,Region) : message;
        message = message.contains(ConstantsUtility.LEVEL_OF_ESCALATION_REPLACEMENT) ? message.replace(ConstantsUtility.LEVEL_OF_ESCALATION_REPLACEMENT,LevelofEscalation) : message;
        message = message.contains(ConstantsUtility.CASE_SUB_TYPE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_SUB_TYPE_REPLACEMENT,CaseSubType) : message;
        message = message.contains(ConstantsUtility.CHANNEL_REPLACEMENT) ? message.replace(ConstantsUtility.CHANNEL_REPLACEMENT,Channel) : message;
        message = message.contains(ConstantsUtility.BUSINESS_AREA_REPLACEMENT) ? message.replace(ConstantsUtility.BUSINESS_AREA_REPLACEMENT,BusinessArea) : message;
        message = message.contains(ConstantsUtility.CASE_STAGE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_STAGE_REPLACEMENT,CaseStage) : message;

 return message;
}


/**
Author: Gitika
Company: Techmatrix
Description: Method to get stakeholder Mapping with respect to CaseID
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/

public static map<Id, map<string, StakeholderHierarchy.Sales>> mapOfcaseIdWithMapOfStakeHolders(list<case> caselist) {
    // map of case id with stakeholder map with Field name and recordid
    map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeholdermap = new map<Id, map<string, StakeholderHierarchy.Sales>>();

    for (case cs : caselist) {
        if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null) {
            // calling helper method to get stakeholder mapping with respect to each case id
            mapOfCaseIdWithStakeholdermap.put(cs.id, CaseEscalationService.getStakeHolderMapping(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c));
        }
    }

    return mapOfCaseIdWithStakeholdermap;

}
/**
Author: Gitika
Company: Techmatrix
Description: Helper  Method to get stakeholder Mapping
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
public static map<string, StakeholderHierarchy.Sales> getStakeHolderMapping(String stakeholderHierarchyString, String selectedHierarchyType) {
    // map of stakeHolder Field name and recordid
    map<string, StakeholderHierarchy.Sales> mapOfStakeholders = new map<string, StakeholderHierarchy.Sales>();
    // parsing JSON with help of parseStakeholderHierarchyJson method
    List<StakeholderHierarchy.Sales> hierarchyList = StakeholderUtility.getSelectedHierarchyList(stakeholderHierarchyString, selectedHierarchyType);

    for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {

        if (string.isNotBlank(stakeholders.recordId) && string.isNotBlank(stakeholders.stakeHolder)) {
            
                mapOfStakeholders.put(stakeholders.stakeHolder, stakeholders);
            
        }
    }
    return mapOfStakeholders;
}

/**
Author: Deepak Kumar
Company: Techmatrix
Description: Update the Number of escalation days conditionality and also update the Transfer escalation datetime
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        10/06/2020                Deepak Kumar              Initial Version
**/
public static void updateTransferEscalationsBeforeUpdate(List<Case_Actions__c> newCaseActionList, Map<Id, Case_Actions__c> OldCaseActionMap) {
    try {
        Map<String, Case_Escalations_Matrix__mdt> escalationLevelVsCaseEscalationsMatrixMap = getCaseEscalationsMatrixLevelMap();
        if (!escalationLevelVsCaseEscalationsMatrixMap.isEmpty()) {
            for (Case_Actions__c caseActions : newCaseActionList) {
                if (caseActions.State__c != ConstantsUtility.Approved && caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID && caseActions.Transfer_Escalation_Date_Time__c != null
                        && caseActions.Transfer_Escalation_Date_Time__c != OldCaseActionMap.get(caseActions.id).Transfer_Escalation_Date_Time__c) {
                    /** Condition 1 IF Transfer Escalation Day is blank */
                    if (caseActions.Transfer_Escalation_Day__c == null) {
                        caseActions.Transfer_Escalation_Day__c = 1;
                    } else {
                        caseActions.Transfer_Escalation_Day__c += 1;
                    }
                    caseActions.Dealer_Name__c = caseActions.Dealership_ID__c;
                    Integer transferEscalationDay = Integer.valueOf(caseActions.Transfer_Escalation_Day__c);
                    Case_Escalations_Matrix__mdt caseEscalationsMatrix;
                    caseEscalationsMatrix = getCaseEscalationNotifier(transferEscalationDay, caseEscalationsMatrix, escalationLevelVsCaseEscalationsMatrixMap);
                    if (caseEscalationsMatrix != null) {
                        caseActions.Transfer_Escalation_Notifiers__c = caseEscalationsMatrix.Notifiers__c;
                    }
                } else if (caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID && caseActions.Approval_Status__c == ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED && caseActions.Approval_Status__c != OldCaseActionMap.get(caseActions.id).Approval_Status__c) {
                    caseActions.Transfer_Escalation_Date_Time__c = null;
                }
            }
        }
    } catch (Exception exp) {
        System.debug('Exception Message ::' + exp.getMessage() + ' Stack Trace ::' + exp.getStackTraceString() + ' At Line :: ' + exp.getLineNumber());
        ExceptionHandler.LogError('CaseEscalationService', exp.getMessage(), 'Case_Actions__c', null, null);
    }
}
private static Map<String, Case_Escalations_Matrix__mdt> getCaseEscalationsMatrixLevelMap() {
    List<Case_Escalations_Matrix__mdt> caseEscalationsMatrices = new List<Case_Escalations_Matrix__mdt>();
    caseEscalationsMatrices = [
            SELECT Id,Case_Type__c,Escalation_Level__c,Escalation_Type__c,Notifiers__c,MasterLabel
            FROM Case_Escalations_Matrix__mdt
            WHERE Escalation_Type__c = :ConstantsUtility.ESCALATION_TYPE_TRANSFER
    ];
    Map<String, Case_Escalations_Matrix__mdt> escalationLevelVsCaseEscalationsMatrixMap = new Map<String, Case_Escalations_Matrix__mdt>();
    for (Case_Escalations_Matrix__mdt caseEscalationsMatrix : caseEscalationsMatrices) {
        escalationLevelVsCaseEscalationsMatrixMap.put(caseEscalationsMatrix.Escalation_Level__c, caseEscalationsMatrix);
    }
    return escalationLevelVsCaseEscalationsMatrixMap;
}
private static Case_Escalations_Matrix__mdt getCaseEscalationNotifier(Integer transferEscalationDay, Case_Escalations_Matrix__mdt caseEscalationsMatrix, Map<String, Case_Escalations_Matrix__mdt> escalationLevelVsCaseEscalationsMatrixMap) {
    if (transferEscalationDay == 1) {
        caseEscalationsMatrix = escalationLevelVsCaseEscalationsMatrixMap.get(ConstantsUtility.LEVEL_1);
    } else if (transferEscalationDay == 2) {
        caseEscalationsMatrix = escalationLevelVsCaseEscalationsMatrixMap.get(ConstantsUtility.LEVEL_2);
    } else if (transferEscalationDay == 3) {
        caseEscalationsMatrix = escalationLevelVsCaseEscalationsMatrixMap.get(ConstantsUtility.LEVEL_3);
    } else if (transferEscalationDay == 4) {
        caseEscalationsMatrix = escalationLevelVsCaseEscalationsMatrixMap.get(ConstantsUtility.LEVEL_4);
    } else {
        caseEscalationsMatrix = escalationLevelVsCaseEscalationsMatrixMap.get(ConstantsUtility.LEVEL_3);
    }
    return caseEscalationsMatrix;
}
/**
Author: Deepak Kumar
Company: Techmatrix
Description: Checking for Notifier and create MC comm. records conditinally
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        10/06/2020                Deepak Kumar              Initial Version
**/
public static void updateTransferEscalationsAfterUpdate(List<Case_Actions__c> newCaseActionList, Map<Id, Case_Actions__c> OldCaseActionMap) {
    try {
        Map<String, Case_Escalations_Matrix__mdt> escalationLevelVsCaseEscalationsMatrixMap = getCaseEscalationsMatrixLevelMap();
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();

        if (!escalationLevelVsCaseEscalationsMatrixMap.isEmpty()) {
            for (Case_Actions__c caseActions : newCaseActionList) {
                if (caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID && caseActions.Transfer_Escalation_Date_Time__c != null
                        && caseActions.Transfer_Escalation_Date_Time__c != OldCaseActionMap.get(caseActions.id).Transfer_Escalation_Date_Time__c && caseActions.Transfer_Escalation_Notifiers__c != null) {
                    List<String> notifiersStrings = caseActions.Transfer_Escalation_Notifiers__c.split(',');
                    escalationUsers.put(caseActions.Id, getUserIds(notifiersStrings, caseActions));
                    recordIdVsMessageMap.put(caseActions.Id, 'You have pending approval related to ' + caseActions.Case_Number_Text__c + ', Please review.');
                    // Hard code for now.
                }
            }
            if (!escalationUsers.isEmpty()) {
                // System.debug(escalationUsers);
                // ADD CHATTER AS WELL
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
                OpportunityTriggerHelper.esclationUsers = escalationUsers;
                List<MC_Communication__c> communications = GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE, new set<Id>(escalationUsers.keySet()), ConstantsUtility.CASE_ACTIONS, '');
            }
        }
    } catch (Exception exp) {
        System.debug('Exception Message ::' + exp.getMessage() + ' Stack Trace ::' + exp.getStackTraceString() + ' At Line :: ' + exp.getLineNumber());
        ExceptionHandler.LogError('CaseEscalationService', exp.getMessage(), 'Case_Actions__c', null, null);
    }
}

public static Set<String> getUserIds(List<String> notifiersStrings, Case_Actions__c caseActions) {
    Set<String> usersIdSet = new Set<String>();
    for (String notifier : notifiersStrings) { 
        if (notifier == ConstantsUtility.NOTIFIER_L1A && caseActions.L1_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L1_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L2A && caseActions.L2A_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L2A_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L3A && caseActions.L3A_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L3A_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L4 && caseActions.L4_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L4_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L5 && caseActions.L5_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L5_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L6A && caseActions.L6A_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L6A_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L7 && caseActions.L7A_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L7A_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L8A && caseActions.L8A_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L8A_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L9 && caseActions.L9_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L9_Stakeholder__c);
        } else if (notifier == ConstantsUtility.NOTIFIER_L10 && caseActions.L10_Stakeholder__c != null) {
            usersIdSet.add(caseActions.L10_Stakeholder__c);
        } 
    }
    return usersIdSet;
}
public static String getUserLevelUsers(List<Id> userIds, Case_Actions__c caseActions) {
    List<String> levelUsers = new List<String>();
    for (String userId : userIds) {
        if (userId == caseActions.L1_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L1A);
        } else if (userId == caseActions.L2A_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L2A);
        } else if (userId == caseActions.L3A_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L3A);
        } else if (userId == caseActions.L4_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L4);
        } else if (userId == caseActions.L5_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L5);
        } else if (userId == caseActions.L6A_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L6A);
        } else if (userId == caseActions.L7A_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L7);
        } else if (userId == caseActions.L8A_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L8A);
        } else if (userId == caseActions.L9_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L9);
        } else if (userId == caseActions.L10_Stakeholder__c) {
            levelUsers.add(ConstantsUtility.NOTIFIER_L10);
        }
    }
    if (levelUsers.size() > 0) {
        return String.join(levelUsers, ',');
    }
    return null;
}

}