/**
* @File Name          : CaseActionTriggerHelper.cls
* @Description        : Helper class for Case Action Trigger Handler
* @Author             :
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 6/12/2020, 11:29:29 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    6/12/2020, 11:29:29 PM                               Initial Version
**/
public class CaseActionTriggerHelper {

//Added by Anas Yar Khan
    public static Map<String, MOS_Escalation__mdt> mapMOSEscalation = new Map<String, MOS_Escalation__mdt>(); //Map to store MOS Escalation Custom metadata records
    public static Map<String, List<String>> mapRoleToPhoneNumbers = new Map<String, List<String>>();  //Map to store Phone numbers related to Role
/*
Author: Anas Yar Khan
Company: Techmatrix Consulting
Description: Method to get MOS Escalation metadata record in Map
Returns: void
*/
    public static void getMOSEscalationRecords() {
        Set<String> setRole = new Set<String>(); //Set to store Role Name
        //fetching MOS Escalation Custom metadata records
        for (MOS_Escalation__mdt mosEscalation : [
                SELECT Job_Type__c,MOS_Case_Type__c,MOS_Case_Stage__c,Channel__c,Notification_Type__c,Escalation_Audience__c,
                        Duration__c,Escalation_Type__c,Escalation_Level__c,Escalation_Update__c,Alternate_Escalation_Update__c,Alternate_Duration__c
                FROM MOS_Escalation__mdt
        ]) {
            mapMOSEscalation.put(mosEscalation.Job_Type__c + ConstantsUtility.keySeparator + mosEscalation.MOS_Case_Type__c + ConstantsUtility.keySeparator + mosEscalation.MOS_Case_Stage__c + ConstantsUtility.keySeparator + mosEscalation.Escalation_Level__c + ConstantsUtility.keySeparator + mosEscalation.Escalation_Type__c, mosEscalation);
            if (String.isNotBlank(mosEscalation.Escalation_Audience__c)) {
                //adding role name to Set
                setRole.add(mosEscalation.Escalation_Audience__c);
            }
        }

        if (setRole.size() > 0) {
            
            /*//fetching user with roles
            for (User usr : [SELECT Id,MobilePhone,UserRole.Name FROM User WHERE UserRole.Name IN :setRole]) {
                List<String> listMobilePhone = new List<String>();
                if (mapRoleToPhoneNumbers.containsKey(usr.UserRole.Name)) {
                    listMobilePhone = mapRoleToPhoneNumbers.get(usr.UserRole.Name);
                }
                listMobilePhone.add(usr.MobilePhone);
                mapRoleToPhoneNumbers.put(usr.UserRole.Name, listMobilePhone);
            }*/
            Set<Id> setUserId = new Set<Id>();
            Map<Id,String> mapUserToPhoneNumber = new Map<Id,String>();
            List<GroupMember> listGroupMembers = [SELECT UserOrGroupId,Group.Name 
                                                  FROM GroupMember 
                                                  WHERE Group.Name IN :setRole 
                                                  AND UserOrGroupId != NULL];
            
            if(listGroupMembers != NULL && listGroupMembers.size() > 0) {
                for(GroupMember gm : listGroupMembers) {
                    if(String.valueof(gm.UserOrGroupId).startsWith(ConstantsUtility.UserPrefix)) {
                        setUserId.add(gm.UserOrGroupId);    
                    }    
                }    
            }
            
            if(setUserId.size() > 0) {
                for (User usr : [SELECT Id,MobilePhone FROM User WHERE Id IN :setUserId AND MobilePhone != NULL]) {
                	mapUserToPhoneNumber.put(usr.Id,usr.MobilePhone);		    
                }   
            }
            
            if(listGroupMembers != NULL && listGroupMembers.size() > 0 && mapUserToPhoneNumber.keySet().size() > 0) {
            	for(GroupMember gm : listGroupMembers) {
                    if(String.valueof(gm.UserOrGroupId).startsWith(ConstantsUtility.UserPrefix) 
                       && mapUserToPhoneNumber.containsKey(gm.UserOrGroupId)) {
                    	List<String> listMobilePhone = new List<String>();
                        if(mapRoleToPhoneNumbers.containsKey(gm.Group.Name)) {
                        	listMobilePhone = mapRoleToPhoneNumbers.get(gm.Group.Name);	    
                        }
                        listMobilePhone.add(mapUserToPhoneNumber.get(gm.UserOrGroupId));
                        mapRoleToPhoneNumbers.put(gm.Group.Name, listMobilePhone);
                    }    
                }    
            }
        }
    }


/**
Author: Gitika
Company: Techmatrix
Description: Method to return map of case Number and On Hold Duration
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/

    public static map<string, integer> populateOnHoldDuration(list<Case_Actions__c> casAclist, map<id, Case_Actions__c> oldCaseActionMap, set<string> offDays, set<date> holidays) {
        // set of store Case Object ID
        set<Id> caseObjId = new set<Id>();
        // Map of case number with On hold duration
        map<string, integer> mapofcaseIdandRecordtypeIdwithHoldDuration = new map<string, integer>();
        // iteration of case action for only On Hold Cases
        for (Case_Actions__c caseActionObj : casAclist) {
            if (String.isNotBlank(caseActionObj.Case_Number__c) && (caseActionObj.Recordtypeid == ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID || caseActionObj.Recordtypeid == ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID)
                    && (trigger.isInsert || (trigger.isupdate
                    && (caseActionObj.Hold_Start_Date__c != oldCaseActionMap.get(caseActionObj.id).Hold_Start_Date__c || caseActionObj.Hold_Till_Date__c != oldCaseActionMap.get(caseActionObj.id).Hold_Till_Date__c)
                    ))) {
                caseObjId.add(caseActionObj.Case_Number__c);
            }
        }

        // Aggregate Query to get MIN of Hold Start date and MAX of Hold Till date

        for (AggregateResult groupedResults : [
                select Case_number__c, Recordtypeid, min(hold_Start_Date__c)holdstart,max(hold_till_Date__c) holdTill
                from Case_actions__c
                where Approval_Status__c != :ConstantsUtility.Rejected and Case_number__c in :caseObjId
                group by Case_number__c, Recordtypeid
        ]) {

            //  Integer duration = ((Date) groupedResults.get('holdstart')).daysBetween((Date) groupedResults.get('holdTill'));
            integer duration = 0;
            for (date dateStart = (Date) groupedResults.get('holdstart'); dateStart <= (Date) groupedResults.get('holdTill'); dateStart = dateStart + 1) {

                if (!holidays.contains(dateStart)) {
                    datetime dt = datetime.newInstance(dateStart, Time.newInstance(0, 0, 0, 0));
                    if (!offDays.contains(dt.format('EEEE'))) {
                        duration++;
                    }
                }
            }
            mapofcaseIdandRecordtypeIdwithHoldDuration.put((string) groupedResults.get('Case_number__c'), duration);

        }
        return mapofcaseIdandRecordtypeIdwithHoldDuration;
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method for to get Off Days With respect to Business Hour
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    public static set<String> getWeeksOffBasisBusinessHour(string businessHourId) {
        set<String> daysName = new set<String>();
        BusinessHours businessHour = [
                SELECT Id, SundayStartTime, SundayEndTime,
                        MondayStartTime, MondayEndTime,
                        TuesdayStartTime, TuesdayEndTime,
                        WednesdayStartTime, WednesdayEndTime,
                        ThursdayStartTime, ThursdayEndTime,
                        FridayStartTime, FridayEndTime,
                        SaturdayStartTime, SaturdayEndTime
                FROM BusinessHours
                where id = :businessHourId
        ];

        if (String.isBlank(String.valueOf(businessHour.SundayStartTime))) {
            daysName.add(ConstantsUtility.SUNDAY);
        }if (String.isBlank(String.valueOf(businessHour.MondayStartTime))) {
            daysName.add(ConstantsUtility.MONDAY);
        }if (String.isBlank(String.valueOf(businessHour.TuesdayStartTime))) {
            daysName.add(ConstantsUtility.TUESDAY);
        } if (String.isBlank(String.valueOf(businessHour.WednesdayStartTime))) {
            daysName.add(ConstantsUtility.Wednesday);
        } if (String.isBlank(String.valueOf(businessHour.ThursdayStartTime))) {
            daysName.add(ConstantsUtility.Thursday);
        } if (String.isBlank(String.valueOf(businessHour.FridayStartTime))) {
            daysName.add(ConstantsUtility.Friday);
        } if (String.isBlank(String.valueOf(businessHour.SaturdayStartTime))) {
            daysName.add(ConstantsUtility.Saturday);
        }

        return daysName;

    }
/**
Author: Gitika
Company: Techmatrix
Description: Method to get holidays 
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    public static set<date> geHolidays() {
        set<date> holidayDate = new set<date>();
        for (Holiday holi : [SELECT Id, Description, Name, ActivityDate FROM Holiday]) {
            holidayDate.add(holi.ActivityDate);
        }
        return holidayDate;
    }
/**
Author: Gitika
Company: Techmatrix
Description: Method for Case Action mapping
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/

    public static case_Actions__c getCaseActionMapping(map<id, case> caseMap, case_Actions__c casAction) {

        casAction.Case_Type__c = String.isBlank(casAction.Case_Type__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Case_Type__c) ? caseMap.get(casAction.Case_Number__c).Case_Type__c : null) : casAction.Case_Type__c;
        casAction.Channel__c = String.isBlank(casAction.Channel__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Channel__c) ? caseMap.get(casAction.Case_Number__c).Channel__c : null) : casAction.Channel__c;
        casAction.Business_Area__c = String.isBlank(casAction.Business_Area__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Business_Area__c) ? caseMap.get(casAction.Case_Number__c).Business_Area__c : null) : casAction.Business_Area__c;
        casAction.Case_Stage__c = String.isBlank(casAction.Case_Stage__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Case_Stage__c) ? caseMap.get(casAction.Case_Number__c).Case_Stage__c : null) : casAction.Case_Stage__c;
        casAction.Region_Code__c = String.isBlank(casAction.Region_Code__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Region_Code__c) ? caseMap.get(casAction.Case_Number__c).Region_Code__c : null) : casAction.Region_Code__c;
        casAction.Dealer_Name__c = String.isBlank(casAction.Dealer_Name__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Dealer_Name__c) ? caseMap.get(casAction.Case_Number__c).Dealer_Name__c : null) : casAction.Dealer_Name__c;
        casAction.Primary_Category__c = String.isBlank(casAction.Primary_Category__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Primary_Category__c) ? caseMap.get(casAction.Case_Number__c).Primary_Category__c : null) : casAction.Primary_Category__c;
        casAction.Primary_Category_ID__c = String.isBlank(casAction.Primary_Category_ID__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Primary_Category_ID__c) ? caseMap.get(casAction.Case_Number__c).Primary_Category_ID__c : null) : casAction.Primary_Category_ID__c;
        casAction.Secondary_Category__c = String.isBlank(casAction.Secondary_Category__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Secondary_Category__c) ? caseMap.get(casAction.Case_Number__c).Secondary_Category__c : null) : casAction.Secondary_Category__c;
        casAction.Secondary_Category_ID__c = String.isBlank(casAction.Secondary_Category_ID__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Secondary_Category_ID__c) ? caseMap.get(casAction.Case_Number__c).Secondary_Category_ID__c : null) : casAction.Secondary_Category_ID__c;
        casAction.Tertiary_Category__c = String.isBlank(casAction.Tertiary_Category__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Tertiary_Category__c) ? caseMap.get(casAction.Case_Number__c).Tertiary_Category__c : null) : casAction.Tertiary_Category__c;
        casAction.Tertiary_Category_ID__c = String.isBlank(casAction.Tertiary_Category_ID__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Tertiary_Category_ID__c) ? caseMap.get(casAction.Case_Number__c).Tertiary_Category_ID__c : null) : casAction.Tertiary_Category_ID__c;
        casAction.Customer_Name__c = String.isBlank(casAction.Customer_Name__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).First_Name__c) ? caseMap.get(casAction.Case_Number__c).First_Name__c : null) : casAction.Customer_Name__c;
        casAction.Mobile__c = String.isBlank(casAction.Mobile__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Mobile_Number__c) ? caseMap.get(casAction.Case_Number__c).Mobile_Number__c : null) : casAction.Mobile__c;
        casAction.Email__c = String.isBlank(casAction.Email__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Email__c) ? caseMap.get(casAction.Case_Number__c).Email__c : null) : casAction.Email__c;
        casAction.Model__c = String.isBlank(casAction.Model__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Model__c) ? caseMap.get(casAction.Case_Number__c).Model__c : null) : casAction.Model__c;
        casAction.Variant__c = String.isBlank(casAction.Variant__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Variant__r.Name) ? caseMap.get(casAction.Case_Number__c).Variant__r.Name : null) : casAction.Variant__c;
        casAction.Case_Source__c = String.isBlank(casAction.Case_Source__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Origin) ? caseMap.get(casAction.Case_Number__c).Origin : null) : casAction.Case_Source__c;
        casAction.Case_Createddate__c = casAction.Case_Createddate__c == null ? (caseMap.get(casAction.Case_Number__c).createdDate != null ? caseMap.get(casAction.Case_Number__c).createdDate : null) : casAction.Case_Createddate__c;
        casAction.Customer_Satisfied_With_FCR__c = String.isBlank(casAction.Customer_Satisfied_With_FCR__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Customer_Satisfied_With_FCR__c) ? caseMap.get(casAction.Case_Number__c).Customer_Satisfied_With_FCR__c : null) : casAction.Customer_Satisfied_With_FCR__c;
        casAction.FCR_Conducted__c = String.isBlank(casAction.FCR_Conducted__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).FCR_Conducted__c) ? caseMap.get(casAction.Case_Number__c).FCR_Conducted__c : null) : casAction.FCR_Conducted__c;
        casAction.Dealer_Code__c = String.isBlank(casAction.Dealer_Code__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Dealer_Code__c) ? caseMap.get(casAction.Case_Number__c).Dealer_Code__c : null) : casAction.Dealer_Code__c;
        casAction.Zone__c = String.isBlank(casAction.Zone__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Zone__c) ? caseMap.get(casAction.Case_Number__c).Zone__c : null) : casAction.Zone__c;
        casAction.Case_Description__c = String.isBlank(casAction.Case_Description__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Description) ? caseMap.get(casAction.Case_Number__c).Description : null) : casAction.Case_Description__c;
        casAction.Additional_Information__c = String.isBlank(casAction.Additional_Information__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Additional_Information__c) ? caseMap.get(casAction.Case_Number__c).Additional_Information__c : null) : casAction.Additional_Information__c;
        casAction.Registration_No__c = String.isBlank(casAction.Registration_No__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).Registration_No__c) ? caseMap.get(casAction.Case_Number__c).Registration_No__c : null) : casAction.Registration_No__c;
        casAction.NCH_Docket_Number__c = String.isBlank(casAction.NCH_Docket_Number__c) ? (String.isNotBlank(caseMap.get(casAction.Case_Number__c).NCH_Docket_Number__c) ? caseMap.get(casAction.Case_Number__c).NCH_Docket_Number__c : null) : casAction.NCH_Docket_Number__c;
        return casAction;

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

    public static map<Id, map<string, string>> mapOfcaseIdWithMapOfStakeHolders(list<case> caselist, map<string, string> mapOfStakeholderJSONWithObjectFields) {
        // map of case id with stakeholder map with Field name and recordid
        map<Id, map<string, string>> mapOfCaseIdWithStakeholdermap = new map<Id, map<string, string>>();

        for (case cs : caselist) {
            if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null) {
                // calling helper method to get stakeholder mapping with respect to each case id
                mapOfCaseIdWithStakeholdermap.put(cs.id, CaseActionTriggerHelper.getStakeHolderMapping(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c, mapOfStakeholderJSONWithObjectFields));
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
    public static map<string, string> getStakeHolderMapping(String stakeholderHierarchyString, String selectedHierarchyType, map<string, string> mapOfStakeholderJSONWithObjectFields) {
        // map of stakeHolder Field name and recordid
        map<string, string> mapOfStakeholders = new map<string, string>();
        // parsing JSON with help of parseStakeholderHierarchyJson method
        List<StakeholderHierarchy.Sales> hierarchyList = new List<StakeholderHierarchy.Sales>(); // LIst to iterate the list of the stake holders
        hierarchyList = StakeholderUtility.getSelectedHierarchyList(stakeholderHierarchyString, selectedHierarchyType);
        for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {

            if (string.isNotBlank(stakeholders.recordId) && string.isNotBlank(stakeholders.stakeHolder)) {
                if (mapOfStakeholderJSONWithObjectFields.containskey(stakeholders.stakeHolder)) {
                    mapOfStakeholders.put(mapOfStakeholderJSONWithObjectFields.get(stakeholders.stakeHolder), stakeholders.recordId);
                }
            }
        }
        return mapOfStakeholders;
    }
/**
Author: Gitika
Company: Techmatrix
Description: Method to get stakeholder Mapping with respect to CaseID For MSIL Query
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/

    public static map<Id, map<string, string>> mapOfcaseIdWithMapOfStakeHoldersMSILQuery(list<case> caselist) {
// map of case id with stakeholder map with Field name and recordid
        map<Id, map<string, string>> mapOfCaseIdWithStakeholdermap = new map<Id, map<string, string>>();
        Set<Id> categoryIdSet = new Set<Id>();
        Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();

        for (case cs : caselist) {
            if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null && cs.RecordtypeId == ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID) {
                categoryIdSet.add(CaseActionTriggerHelper.getCategoryId(cs));
            }
        }
        if (categoryIdSet.size() > 0) {
            categoryIdVsMapOfRegionAndRecipientMasterMap = CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(categoryIdSet);
            for (case cs : caselist) {
                map<string, string> mapOfStakeholderMapping = new map<string, string>();
                Map<String, Recipient_Master__c> regionWithRecipientMaster = new Map<String, Recipient_Master__c>();
                if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null && cs.RecordtypeId == ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID) {
                    String categoryId = CaseActionTriggerHelper.getCategoryId(cs) != null ? getCategoryId(cs) : '';
                    if (categoryId.length() > 0 && categoryIdVsMapOfRegionAndRecipientMasterMap.containskey(categoryId)) {
                        regionWithRecipientMaster = categoryIdVsMapOfRegionAndRecipientMasterMap.get(categoryId);
                        Recipient_Master__c recipientMasterRecord = regionWithRecipientMaster.containsKey(cs.Region_Code__c) ? regionWithRecipientMaster.get(cs.Region_Code__c) : (regionWithRecipientMaster.containsKey(ConstantsUtility.REGION_ALL) ? regionWithRecipientMaster.get(ConstantsUtility.REGION_ALL) : null);
                        if (recipientMasterRecord.Level_1_To__c != null && CaseActionTriggerHelper.getStakeHolderMappingForMSILQuery(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c).containsKey((recipientMasterRecord.Level_1_To__c).split(';')[0])) {

                            mapOfStakeholderMapping.put(ConstantsUtility.L1_STAKEHOLDER, CaseActionTriggerHelper.getStakeHolderMappingForMSILQuery(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c).get((recipientMasterRecord.Level_1_To__c).split(';')[0]));
                        }
                    }
                    // calling helper method to get stakeholder mapping with respect to each case id
                    mapOfCaseIdWithStakeholdermap.put(cs.id, mapOfStakeholderMapping);
                }
            }
        }
        return mapOfCaseIdWithStakeholdermap;

    }

    private static Id getCategoryId(Case caseObj) {
        String categoryId;
        if (caseObj.Tertiary_Category_ID__c != null) {
            categoryId = caseObj.Tertiary_Category_ID__c;
        } else if (caseObj.Secondary_Category_ID__c != null) {
            categoryId = caseObj.Secondary_Category_ID__c;
        } else if (caseObj.Primary_Category_ID__c != null) {
            categoryId = caseObj.Primary_Category_ID__c;
        }
        return categoryId;
    }
/**
Author: Gitika
Company: Techmatrix
Description: Helper  Method to get stakeholder Mapping For MSIL Query
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/

    public static map<string, string> getStakeHolderMappingForMSILQuery(String stakeholderHierarchyString, String selectedHierarchyType) {
// map of stakeHolder Field name and recordid
        map<string, string> mapOfStakeholders = new map<string, string>();
// parsing JSON with help of parseStakeholderHierarchyJson method
        List<StakeholderHierarchy.Sales> hierarchyList = new List<StakeholderHierarchy.Sales>(); // LIst to iterate the list of the stake holders
        hierarchyList = StakeholderUtility.getSelectedHierarchyList(stakeholderHierarchyString, selectedHierarchyType);
        for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {

            if (string.isNotBlank(stakeholders.recordId) && string.isNotBlank(stakeholders.stakeHolder)) {
                mapOfStakeholders.put(stakeholders.stakeHolder, stakeholders.recordId);
            }
        }
        return mapOfStakeholders;
    }
/**
Author: Gitika
Company: Techmatrix
Description: Helper  Method to create instance of Case Action
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
*/
    public static case_Actions__c getCaseActionInstance(case_Actions__c caseAction, Integer duration, String Status) {
        case_Actions__c caseAcc = new case_Actions__c();
        caseAcc.id = caseAction.id;
        caseAcc.On_Hold_Duration__c = duration;
        if (Status != null) {
            caseAcc.Approval_Status__c = Status;
        }
        if (caseAction.Reason_For_Hold__c == ConstantsUtility.Delay_in_RC_due_to_RTO_Issue && duration > 15) {
            caseAcc.Hold_Till_Date__c = (caseAction.Tentative_Delivery_Date__c != null ? caseAction.Tentative_Delivery_Date__c : caseAction.Hold_Till_Date__c);
        }
        return caseAcc;
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Helper  Method to add notifiers id to list of string
Returns: Set<string>
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
*/
    public static Set<String> getNotifiers(Case_Actions__c casAcc, String customLabel) {
        Set<String> Notifierids = new Set<String>();
        for (string str : customLabel.split(';')) {
            if ((String) casAcc.get(str) != null) {
                Notifierids.add((String) casAcc.get(str));
            }
        }
        return Notifierids;
    }
/*
Author: Anas Yar Khan
Company: Techmatrix Consulting
Description: This method is used to get the MC Communication record
Returns: void
*/
    public static MC_Communication__c getMCCommunicationRecord(Case_Actions__c caseActionObj, Map<Id, Case> mapIdToCase) {
        MC_Communication__c mcRecord = new MC_Communication__c();
        //mcRecord.Type__c = ConstantsUtility.MC_Communication_Type_MOS_Escalation;
        mcRecord.Case__c = caseActionObj.Case_Number__c;
        mcRecord.Case_Action__c = caseActionObj.Id;
        mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Queued;
        if (mapIdToCase.containsKey(caseActionObj.Case_Number__c)) {
            String key = mapIdToCase.get(caseActionObj.Case_Number__c).Job_Type__c;
            key += ConstantsUtility.keySeparator + mapIdToCase.get(caseActionObj.Case_Number__c).Case_Type__c;
            key += ConstantsUtility.keySeparator + mapIdToCase.get(caseActionObj.Case_Number__c).MOS_Case_Stage__c;
            key += ConstantsUtility.keySeparator + caseActionObj.Escalation_Level__c;

            if (mapIdToCase.get(caseActionObj.Case_Number__c).Allocation_Time__c != NULL && mapIdToCase.get(caseActionObj.Case_Number__c).Complaint_Registration_Time__c != NULL) {
                mcRecord.General_Field_4__c = String.valueOf(getMinutesFromTwoDateTimeFields(mapIdToCase.get(caseActionObj.Case_Number__c).Allocation_Time__c, mapIdToCase.get(caseActionObj.Case_Number__c).Complaint_Registration_Time__c));

                if (mapIdToCase.get(caseActionObj.Case_Number__c).Out_for_Service_Time__c != NULL) {
                    mcRecord.General_Field_3__c = String.valueOf(getMinutesFromTwoDateTimeFields(mapIdToCase.get(caseActionObj.Case_Number__c).Out_for_Service_Time__c, mapIdToCase.get(caseActionObj.Case_Number__c).Allocation_Time__c));
                }

                if (mapIdToCase.get(caseActionObj.Case_Number__c).Reached_Time__c != NULL) {
                    mcRecord.General_Field_3__c = String.valueOf(getMinutesFromTwoDateTimeFields(mapIdToCase.get(caseActionObj.Case_Number__c).Reached_Time__c, mapIdToCase.get(caseActionObj.Case_Number__c).Complaint_Registration_Time__c));
                }
            }

            if (caseActionObj.Case_Type__c == ConstantsUtility.Case_Action_Type_MOS_followUp) {
                key += ConstantsUtility.keySeparator + ConstantsUtility.FollowUp;
            } else if (caseActionObj.Case_Type__c == ConstantsUtility.Case_Action_Type_MOS_Reach) {
                key += ConstantsUtility.keySeparator + ConstantsUtility.Reached;
            } else {
                key += ConstantsUtility.keySeparator + ConstantsUtility.Allocation;
            }


            if (mapMOSEscalation != NULL && mapMOSEscalation.keySet().size() > 0 && mapMOSEscalation.containsKey(key)) {
                MOS_Escalation__mdt mosEscalation = mapMOSEscalation.get(key);
                mcRecord.Type__c = mosEscalation.Notification_Type__c;
                if (mapRoleToPhoneNumbers.containsKey(mosEscalation.Escalation_Audience__c) && mapRoleToPhoneNumbers.get(mosEscalation.Escalation_Audience__c) != NULL) {
                    mcRecord.Recipient_Phone_Numbers__c = String.join(mapRoleToPhoneNumbers.get(mosEscalation.Escalation_Audience__c), ',');
                }
                DateTime newDateTime = caseActionObj.Escalation_Update__c;
                if (mapIdToCase.get(caseActionObj.Case_Number__c).get(mosEscalation.Escalation_Update__c) != NULL) {
                    mcRecord.Escalation_Date_Time__c = newDateTime.addSeconds(Integer.valueOf(mosEscalation.Duration__c));
                    mcRecord.General_Field_5__c = String.valueOf(mosEscalation.Duration__c / 60);
                } else {
                    if (String.isNotBlank(mosEscalation.Alternate_Escalation_Update__c)) {
                        if (mapIdToCase.get(caseActionObj.Case_Number__c).get(mosEscalation.Alternate_Escalation_Update__c) != NULL) {
                            mcRecord.Escalation_Date_Time__c = newDateTime.addSeconds(Integer.valueOf(mosEscalation.Alternate_Duration__c));
                            mcRecord.General_Field_5__c = String.valueOf(mosEscalation.Alternate_Duration__c / 60);
                        }
                    }
                }
            }
        }
        return mcRecord;
    }
/*
Author: Anas Yar Khan
Company: Techmatrix Consulting
Description: This method is used to time difference between 2 date time fields
Returns: Long
*/

    public static Long getMinutesFromTwoDateTimeFields(DateTime field1, DateTime field2) {
        Long dt1Long = field2.getTime();
        Long dt2Long = field1.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        return minutes;
    }

    /*
    Author: Deepak Kumar
    Company: Techmatrix Consulting
    Description: This method is used to get the mapped case object from Case Action
    Returns: Long
    */
    public static Case getTransferredChildCaseFieldMapping(Case newCase,Case_Actions__c caseActions){
        if (caseActions.Region_Code__c != null && caseActions.Region_Code__c == newCase.Region_Code__c) {
            newCase.Id = caseActions.Case_Number__c;
        } else {
            newCase.ParentId = caseActions.Case_Number__c;
        }
        newCase.RecordTypeId = ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID;
        newCase.Channel__c = caseActions.Channel__c;
        newCase.Business_Area__c = caseActions.Business_Area__c;
        newCase.Case_Stage__c = caseActions.Case_Stage__c;
        newCase.Region_Code__c = caseActions.Region_Code__c;
        newCase.Dealer_Name__c = caseActions.Dealer_Name__c;
        newCase.For_Code__c = caseActions.For_Code__c;
        newCase.Outlet_Type__c = caseActions.Outlet_Type__c;
        newCase.Primary_Category__c = caseActions.Primary_Category__c;
        newCase.Primary_Category_ID__c = caseActions.Primary_Category_ID__c;
        newCase.Secondary_Category__c = caseActions.Secondary_Category__c;
        newCase.Secondary_Category_ID__c = caseActions.Secondary_Category_ID__c;
        newCase.Tertiary_Category__c = caseActions.Tertiary_Category__c;
        newCase.Tertiary_Category_ID__c = caseActions.Tertiary_Category_ID__c;

        return newCase;
    }
}