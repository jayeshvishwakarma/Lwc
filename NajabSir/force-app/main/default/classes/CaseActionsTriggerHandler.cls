/**
* @File Name          : CaseActionsTriggerHandler.cls
* @Description        : Trigger handler class for Case Actions
* @Author             :
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 06/02/2020, 11:29:29 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    06/02/2020, 11:29:29 PM                             Initial Version
**/
public without sharing class CaseActionsTriggerHandler extends TriggerHandler {

    private list<Case_Actions__c> newCaseActionList; //Used to store the list of new Cases
    private map<id, Case_Actions__c> oldCaseActionMap; //Used to store the map of old Cases
    private Map<Id, Case_Actions__c> newCaseActionsMap; //Used to store the map of new Case Actions

    private Map<Id, Case> caseMap = new Map<Id, Case>();
    public CaseActionsTriggerHandler() {
        this.newCaseActionList = (List<Case_Actions__c>) Trigger.new;
        this.oldCaseActionMap = (map<id, Case_Actions__c>) Trigger.oldmap;
        this.newCaseActionsMap = (Map<Id, Case_Actions__c>) Trigger.newMap;
    }

    //Methods executions before Insert of Case Action
    public override void beforeInsert() {
        // For Revalidation
        updateRevalidationRecordTypeIdServiceCases();

        // added by gitika Temporarily for L1L2L3L4L5L6 populate
        populateStakeholders();
        // method to restrict same recordtype case action creation under one case
        dupChckOfCaseActionWthSameCase();

        // Validations for Duplicate Requests
        validationForDuplicateCaseActions();

        // For Transfer Type case  Actions
        updateDealerTransferStakeHolders();

        // For Revalidation (product complaint and unjustified complaint)
        copyClosureFields();

        serviceUnjustifiedRevalidationValidation(); 

    }
    
    
    //Methods executions before Insert of Case Action
    public override void beforeUpdate() {

        changeCaseActionOwner();
        updateTransferEscalationsBeforeUpdate();
        
        updateApprovalNotifiers();

        // For Transfer Type case  Actions
        updateDealerTransferStakeHolders();
        updateCaseAccessForTransferCaseActions();
        //for Queue Assignment
        queueAssignment();

        closureFormChanged(); 
    }

    
    public override void afterInsert() {

        methodToUpdateCaseOnHoldWhenloggedInL3L5();
        methodToUpdateCaseOnHoldWhenloggedInL4L5();
        initiateApprovalProcess();
        // method is used to create MC Communication Record
        createMCCommunicationRecord();


        //Added by Anas Yar Khan on 27th July 2020
        CaseActionTriggerHelper.getMOSEscalationRecords();
        createMCCommunicationRecordMOSEscalation();
        //for Queue Assignment
        queueAssignment();
        sharingWhenLoggedInUserIsL3();

        // Added By Deepak 1st OCT
        sendCustomNotifications();
        sendChatterNotificationCCPnotResponded(); 
 
    }

    public override void afterupdate() {
        createCaseActionsShares();
        methodToUpdateOnHoldDuration();
        updateRelatedCaseStatus();
        // Added By Deepak
        createTransferredChildCase();
        // method is used to create MC Communication Record
        createMCCommunicationRecord();
        //Method to update the chatter notifications
        updateTransferEscalationsAfterUpdate();
        //Send chattter notifications to approvers
        sendChatterNotificationToApprovers();
        //Added by Anas Yar Khan on 27th July 2020
        CaseActionTriggerHelper.getMOSEscalationRecords();
        createMCCommunicationRecordMOSEscalation();

        // Added By Deepak 1st OCT
        sendCustomNotifications();
        //sendChatterNotifications(); 
        // TO Send Email/SMS Notifications
        sendEmailSMSApproval();
    }
    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to check if Change in closure fields
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        14/10/2020                Gitika Khandelwal            Initial Version
	**/
    public void closureFormChanged() {
        try {
            for (Case_Actions__c casAc : this.newCaseActionList) {
                if (casAc.Gaps_Identified__c == oldCaseActionMap.get(casAc.id).Gaps_Identified__c && casAc.Issue_Description__c == oldCaseActionMap.get(casAc.id).Issue_Description__c
                        && casAc.Action_Taken__c == oldCaseActionMap.get(casAc.id).Action_Taken__c && casAc.Counter_Measure_at_Dealer_Level__c == oldCaseActionMap.get(casAc.id).Counter_Measure_at_Dealer_Level__c
                        && casAc.Timeline_For_Implementation__c == oldCaseActionMap.get(casAc.id).Timeline_For_Implementation__c && casAc.Counter_Measure_at_RO_Level__c == oldCaseActionMap.get(casAc.id).Counter_Measure_at_RO_Level__c
                        && casAc.Timeline_For_Implementation_RO__c == oldCaseActionMap.get(casAc.id).Timeline_For_Implementation_RO__c) {
                    casAc.Closure_Form_Not_Changed__c = true;
                } else {
                    casAc.Closure_Form_Not_Changed__c = false;
                }
            }
        } catch (exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'closureFormChanged', '', null);
        }
    }
    
    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to send chatter Notification for CCP Not responded to L3
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        14/10/2020                Gitika Khandelwal            Initial Version
	**/
    public void sendChatterNotificationCCPnotResponded() {
        try {
            // map  of case recordid with set of Notifiers
            map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
            // map  of id with message
            map<Id, string> recordIdVsMessageMap = new map<Id, string>();
            // set to store ids for chatter Notification
            set<String> recordId = new set<String>();
            for (Case_Actions__c casAc : this.newCaseActionList) {
                if (String.isNotBlank(casAc.Case_Number__c) && casAc.recordTypeId == ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID && string.isNotBlank(casAc.L3A_Stakeholder__c)) {
                    recordId.add(casAc.L3A_Stakeholder__c);
                    recordIdVdNotifiersMap.put(casAc.id, recordId);
                    recordIdVsMessageMap.put(casAc.id, ConstantsUtility.CCP_NOT_RESPONDED_CHATTER_MSG);
                }
            }
            if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
            }
        } catch (exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'sendChatterNotificationCCPnotResponded', '', null);
        }
    }
   
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to populate stake Holder details on case Action
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void populateStakeholders() {
        try {
            // set to store case ids
            set<id> caseObjIds = new set<id>();
            // map to store case ids with stakholdermapping
            map<id, map<string, string>> mapofCaseIdWithStakeHoldersmap = new map<id, map<string, string>>();
            // map to store case ids with stakholdermapping MSIL
            map<id, map<string, string>> mapofCaseIdWithStakeHoldersmapMSIL = new map<id, map<string, string>>();
            // iteration to get case number with respect to case Action

            for (Case_Actions__c casAc : this.newCaseActionList) {
                if (String.isNotBlank(casAc.Case_Number__c)) {
                    caseObjIds.add(casAc.Case_Number__c);
                }
            }


            if (caseObjIds.size() > 0) {
                // Query to JSON details from case
                caseMap = getCaseMap(caseObjIds);
                // calling helper method from CaseActionTriggerHelper To get stakeholder mapping with respect to each case
                mapofCaseIdWithStakeHoldersmap = CaseActionTriggerHelper.mapOfcaseIdWithMapOfStakeHolders(caseMap.values(), ConstantsUtility.mapOfStakeholderJSONWithCaseActionFields);
                // calling helper method from CaseActionTriggerHelper To get stakeholder mapping with respect to each case for MSIL
                mapofCaseIdWithStakeHoldersmapMSIL = CaseActionTriggerHelper.mapOfcaseIdWithMapOfStakeHoldersMSILQuery(caseMap.values());

                for (Case_Actions__c casAction : this.newCaseActionList) {
                    System.debug('mapofCaseIdWithStakeHoldersmap ' + mapofCaseIdWithStakeHoldersmap);
                    if (mapofCaseIdWithStakeHoldersmap.containskey(casAction.Case_Number__c) && mapofCaseIdWithStakeHoldersmap.get(casAction.Case_Number__c).size() > 0
                            && casAction.RecordTypeId != ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID && casAction.RecordTypeId != ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID) {
                        for (string str : mapofCaseIdWithStakeHoldersmap.get(casAction.Case_Number__c).keyset()) {
                            casAction.put(str, (Id) mapofCaseIdWithStakeHoldersmap.get(casAction.Case_Number__c).get(str));

                        }
                    }
                    if (mapofCaseIdWithStakeHoldersmapMSIL.containskey(casAction.Case_Number__c) && mapofCaseIdWithStakeHoldersmapMSIL.get(casAction.Case_Number__c).size() > 0
                            && casAction.RecordTypeId == ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID) {
                        for (string str : mapofCaseIdWithStakeHoldersmapMSIL.get(casAction.Case_Number__c).keyset()) {
                            casAction.put(str, (Id) mapofCaseIdWithStakeHoldersmapMSIL.get(casAction.Case_Number__c).get(str));

                        }
                    }

                    if (caseMap.containsKey(casAction.Case_Number__c) && casAction.RecordTypeId != ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id) {
                        casAction = CaseActionTriggerHelper.getCaseActionMapping(caseMap, casAction);
                    }


                    if (casAction.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID && casAction.Dealership_ID__c != null) {
                        casAction.Dealer_Name__c = casAction.Dealership_ID__c;
                    }
                }
            }
        } catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseActionsTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'populateStakeholders', '', ehst);
        }
    }

    private Map<Id, Case> getCaseMap(Set<Id> caseIds) {
        caseMap = new Map<Id, Case>([
                Select id,Stakeholders_JSON__c,Selected_Hierarchy_Type__c,Case_Type__c,Channel__c,Business_Area__c,Case_Stage__c,Region_Code__c,Dealer_Name__c,Primary_Category__c,Primary_Category_ID__c,Secondary_Category__c,Secondary_Category_ID__c,NCH_Docket_Number__c,
                        Tertiary_Category__c,Tertiary_Category_ID__c,First_Name__c,Last_Name__c,Mobile_Number__c,Mobile_Number_1__c,Email__c,Model__c,Variant__r.Name,Origin,Mode__c,
                        createdDate,Customer_Satisfied_With_FCR__c,FCR_Conducted__c,Dealer_Code__c,Zone__c,Description,Additional_Information__c,Registration_No__c,Next_Escalation_Date__c,
                        Next_Escalation_Level__c,RecordTypeId
                from case
                where id in:caseIds
        ]);
        return caseMap;
    }

    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to update case Status To On Hold When logged in user is l3 or l5 and population of On Hold Duration for On Hold Sales
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void methodToUpdateCaseOnHoldWhenloggedInL3L5() {

        // list of Case Actions to update Approval Status for L3 and L5 and On Hold Duration for all
        list<Case_Actions__c> caseActionListToUpdate = new list<Case_Actions__c>();
        // list of Case to update Status to On Hold for L3 and L5
        list<Case> caseListToUpdate = new list<Case>();
        // map  of case Action recordid with set of Notifiers
        map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
        // map  of case Action recordid with message
        map<Id, string> recordIdVsMessageMap = new map<Id, string>();
        // set to store off days of Business Hour
        set<String> daysName = new set<String>();
        // set to store Holidays
        set<date> holidayDates = new set<date>();
        String message = '';
        Try {
            // Custom setting to store Notification messages w.r.t to Developer Recordtype Name
            Map<String, Approval_Notification_Setting__c> approvalTypeVsNotificationSettingsMap = new Map<String, Approval_Notification_Setting__c>();

            for (Approval_Notification_Setting__c notificationSetting : [SELECT Name,Approval_Type__c,Approved_Template__c,Rejected_Template__c FROM Approval_Notification_Setting__c WHERE isActive__c = true]) {
                approvalTypeVsNotificationSettingsMap.put(notificationSetting.Approval_Type__c, notificationSetting);
            }
            // Calling CaseActionHelper Method for off days calculation
            List<businessHours> businessHourList = [Select id,Name from businessHours where name = :ConstantsUtility.MSIL_BUSINESS_HOURS];
            if (businessHourList.size() > 0) {
                daysName = CaseActionTriggerHelper.getWeeksOffBasisBusinessHour(businessHourList[0].id);
            }

            // Calling CaseActionHelper Method for holidays calculation
            holidayDates = CaseActionTriggerHelper.geHolidays();
            // Calling CaseActionHelper Method
            map<string, integer> mapofcaseIdandRecordtypeIdwithHoldDuration = CaseActionTriggerHelper.populateOnHoldDuration(newCaseActionList, oldCaseActionMap, daysName, holidayDates);
            if (approvalTypeVsNotificationSettingsMap.containsKey(ConstantsUtility.Recordtype_On_Hold)) {
                Approval_Notification_Setting__c notificationSetting = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.Recordtype_On_Hold);
                if (notificationSetting.Approved_Template__c != null)
                    message = notificationSetting.Approved_Template__c;
            }

            // iteration of Case Action
            for (Case_Actions__c caseActionObj : newCaseActionList) {

                if (String.isNotBlank(caseActionObj.Case_Number__c) && caseActionObj.Recordtypeid == ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID) {
                    set<string> Notifierids = new set<string>();
                    if (mapofcaseIdandRecordtypeIdwithHoldDuration.containskey(caseActionObj.Case_Number__c)) {

                        integer duration = mapofcaseIdandRecordtypeIdwithHoldDuration.get(caseActionObj.Case_Number__c);
                        system.debug('methodToUpdateCaseOnHoldWhenloggedInL3L5 called-->' + duration);
                        // if Logged in user is L3 and Duration is less than 15 then update Case to On Hold
                        if (caseActionObj.L3A_Stakeholder__c == UserInfo.getUserId() && duration <= 15) {
                            // helper method to update case action as approved and populate On Hold Duration
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved));
                            // helper method to update case On Hold
                            caseListToUpdate.add(CaseTriggerHelper.getCaseInstance(caseActionObj));
                            // helper method to get set of Notifiers Id
                            Notifierids = CaseActionTriggerHelper.getNotifiers(caseActionObj, label.On_Hold_StakeHolders_Notifier_for_L3A);
                        }
                        // if Logged in user is L3 and Duration is more than 15 and Reason For Hold is 'Delay in RC due to RTO Issue' then update Case to On Hold
                        else if (caseActionObj.L3A_Stakeholder__c == UserInfo.getUserId() && duration > 15 && caseActionObj.Reason_For_Hold__c == ConstantsUtility.Delay_in_RC_due_to_RTO_Issue) {
                            // helper method to update case action as approved and populate On Hold Duration
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved));
                            // helper method to update case On Hold
                            caseListToUpdate.add(CaseTriggerHelper.getCaseInstance(caseActionObj));
                            // helper method to get set of Notifiers Id
                            Notifierids = CaseActionTriggerHelper.getNotifiers(caseActionObj, label.On_Hold_StakeHolders_Notifier_for_L3A);


                        }
                        // if Logged in user is L4 and Duration is less then 30  then update Case to On Hold
                        else if (caseActionObj.L4_Stakeholder__c == UserInfo.getUserId() && duration < 30) {
                            // helper method to update case action as approved and populate On Hold Duration
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved));
                            // helper method to update case On Hold
                            caseListToUpdate.add(CaseTriggerHelper.getCaseInstance(caseActionObj));
                            // helper method to get set of Notifiers Id
                            Notifierids = CaseActionTriggerHelper.getNotifiers(caseActionObj, label.On_Hold_StakeHolders);


                        }
                        // if Logged in user is L5 then update Case to On Hold
                        else if (caseActionObj.L5_Stakeholder__c == UserInfo.getUserId()) {
                            // helper method to update case action as approved and populate On Hold Duration
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved));
                            // helper method to update case On Hold
                            caseListToUpdate.add(CaseTriggerHelper.getCaseInstance(caseActionObj));
                            // helper method to get set of Notifiers Id
                            Notifierids = CaseActionTriggerHelper.getNotifiers(caseActionObj, label.On_Hold_StakeHolders);
                        }
                        // populate On Hold Duration for rest
                        else {
                            // helper method to populate On Hold Duration on Case Action
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, null));
                        }
                        // Chatter Notification
                        if (Notifierids.size() > 0 && message.length() > 0) {
                            recordIdVdNotifiersMap.put(caseActionObj.Id, Notifierids);
                            message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, caseActionObj.Case_Number_Text__c) : message;
                            recordIdVsMessageMap.put(caseActionObj.Id, message);
                        }
                    }
                }
            }
            if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
            }

            if (caseActionListToUpdate.size() > 0) {
                // TriggerHandler.bypass('CaseActionsTriggerHandler');
                update caseActionListToUpdate;
                // TriggerHandler.clearBypass('CaseActionsTriggerHandler');
            }

            if (caseListToUpdate.size() > 0) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update caseListToUpdate;
                TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }
        } catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseActionsTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'methodToUpdateCaseOnHoldWhenloggedInL3L5', '', ehst);
        }
    }

    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to update case Status To On Hold When logged in user is l4 or l5 and population of On Hold Duration for On Hold Service
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void methodToUpdateCaseOnHoldWhenloggedInL4L5() {

        // list of Case Actions to update Approval Status for L3 and L5 and On Hold Duration for all
        list<Case_Actions__c> caseActionListToUpdate = new list<Case_Actions__c>();
        // list of Case to update Status to On Hold for L3 and L5
        list<Case> caseListToUpdate = new list<Case>();
        // map  of case Action recordid with set of Notifiers
        map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
        // map  of case Action recordid with message
        map<Id, string> recordIdVsMessageMap = new map<Id, string>();
        // set to store off days of Business Hour
        set<String> daysName = new set<String>();
        // set to store Holidays
        set<date> holidayDates = new set<date>();
        String message = '';
        Try {
            // Custom setting to store Notification messages w.r.t to Developer Recordtype Name
            Map<String, Approval_Notification_Setting__c> approvalTypeVsNotificationSettingsMap = new Map<String, Approval_Notification_Setting__c>();

            for (Approval_Notification_Setting__c notificationSetting : [SELECT Name,Approval_Type__c,Approved_Template__c,Rejected_Template__c FROM Approval_Notification_Setting__c WHERE isActive__c = true]) {
                approvalTypeVsNotificationSettingsMap.put(notificationSetting.Approval_Type__c, notificationSetting);
            }
            // Calling CaseActionHelper Method for off days calculation
            List<businessHours> businessHourList = [Select id,Name from businessHours where name = :ConstantsUtility.MSIL_BUSINESS_HOURS];
            if (businessHourList.size() > 0) {
                daysName = CaseActionTriggerHelper.getWeeksOffBasisBusinessHour(businessHourList[0].id);
            }
            // Calling CaseActionHelper Method for holidays calculation
            holidayDates = CaseActionTriggerHelper.geHolidays();
            // Calling CaseActionHelper Method
            map<string, integer> mapofcaseIdandRecordtypeIdwithHoldDuration = CaseActionTriggerHelper.populateOnHoldDuration(newCaseActionList, oldCaseActionMap, daysName, holidayDates);
            if (approvalTypeVsNotificationSettingsMap.containsKey(ConstantsUtility.Recordtype_On_Hold_Service)) {
                Approval_Notification_Setting__c notificationSetting = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.Recordtype_On_Hold_Service);
                if (notificationSetting.Approved_Template__c != null)
                    message = notificationSetting.Approved_Template__c;
            }

            // iteration of Case Action
            for (Case_Actions__c caseActionObj : newCaseActionList) {

                if (String.isNotBlank(caseActionObj.Case_Number__c) && caseActionObj.Recordtypeid == ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID) {
                    set<string> Notifierids = new set<string>();
                    if (mapofcaseIdandRecordtypeIdwithHoldDuration.containskey(caseActionObj.Case_Number__c)) {

                        integer duration = mapofcaseIdandRecordtypeIdwithHoldDuration.get(caseActionObj.Case_Number__c);
                        system.debug('methodToUpdateCaseOnHoldWhenloggedInL4L5 called-->' + duration);
                        // if Logged in user is L4 and Duration is less than 7 then update Case to On Hold
                        if (caseActionObj.L4_Stakeholder__c == UserInfo.getUserId() && duration <= 7) {
                            // helper method to update case action as approved and populate On Hold Duration
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved));
                            // CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved);
                            // helper method to update case On Hold
                            caseListToUpdate.add(CaseTriggerHelper.getCaseInstance(caseActionObj));
                            // helper method to get set of Notifiers Id
                            Notifierids = CaseActionTriggerHelper.getNotifiers(caseActionObj, label.On_Hold_Service_StakeHolders_Notifier_for_L4);
                        }
                        // if Logged in user is L5 then update Case to On Hold
                        else if (caseActionObj.L5_Stakeholder__c == UserInfo.getUserId() && duration > 7 && duration <= 15) {
                            // helper method to update case action as approved and populate On Hold Duration
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved));
                            // CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, ConstantsUtility.Approved);
                            // helper method to update case On Hold
                            caseListToUpdate.add(CaseTriggerHelper.getCaseInstance(caseActionObj));
                            // helper method to get set of Notifiers Id
                            Notifierids = CaseActionTriggerHelper.getNotifiers(caseActionObj, label.On_Hold_StakeHolders);
                        }
                        // populate On Hold Duration for rest
                        else {
                            // helper method to populate On Hold Duration on Case Action
                            caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, null));
                            // CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, null);
                        }
                        // Chatter Notification
                        if (Notifierids.size() > 0 && message.length() > 0) {
                            recordIdVdNotifiersMap.put(caseActionObj.Id, Notifierids);
                            message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, caseActionObj.Case_Number_Text__c) : message;
                            recordIdVsMessageMap.put(caseActionObj.Id, message);
                        }
                    }
                }
            }
            if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
            }

            if (caseActionListToUpdate.size() > 0) {
                TriggerHandler.bypass('CaseActionsTriggerHandler');
                update caseActionListToUpdate;
                TriggerHandler.clearBypass('CaseActionsTriggerHandler');
            }

            if (caseListToUpdate.size() > 0) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update caseListToUpdate;
                TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }
        } catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseActionsTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'methodToUpdateCaseOnHoldWhenloggedInL4L5', '', ehst);
        }
    }
    
    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to update  On Hold Duration on Case Action
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void methodToUpdateOnHoldDuration() {
        try {
            list<Case_Actions__c> caseActionListToUpdate = new list<Case_Actions__c>();
            // set to store off days of Business Hour
            set<String> daysName = new set<String>();
            // set to store Holidays
            set<date> holidayDates = new set<date>();
            // Calling CaseActionHelper Method for off days calculation
            List<businessHours> businessHourList = [Select id,Name from businessHours where name = :ConstantsUtility.MSIL_BUSINESS_HOURS];
            if (businessHourList.size() > 0) {
                daysName = CaseActionTriggerHelper.getWeeksOffBasisBusinessHour(businessHourList[0].id);
            }
            // Calling CaseActionHelper Method for holidays calculation
            holidayDates = CaseActionTriggerHelper.geHolidays();
            map<string, integer> mapofcaseIdandRecordtypeIdwithHoldDuration = CaseActionTriggerHelper.populateOnHoldDuration(newCaseActionList, oldCaseActionMap, daysName, holidayDates);

            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (String.isNotBlank(caseActionObj.Case_Number__c) && (caseActionObj.Recordtypeid == ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID || caseActionObj.Recordtypeid == ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID)) {
                    if (mapofcaseIdandRecordtypeIdwithHoldDuration.containskey(caseActionObj.Case_Number__c)) {
                        integer duration = mapofcaseIdandRecordtypeIdwithHoldDuration.get(caseActionObj.Case_Number__c);
                        system.debug('methodToUpdateOnHoldDuration called-->' + duration);
                        // helper method to populate On Hold Duration on Case Action
                        caseActionListToUpdate.add(CaseActionTriggerHelper.getCaseActionInstance(caseActionObj, duration, null));

                    }
                }
            }
            TriggerHandler.bypass('CaseActionsTriggerHandler');

            if (caseActionListToUpdate.size() > 0) {
                update caseActionListToUpdate;
            }

            TriggerHandler.clearBypass('CaseActionsTriggerHandler');
        } catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseActionsTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'methodToUpdateOnHoldDuration', '', ehst);
        }
    }
    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method is to insert MC Communication record for On Hold Case Actions
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void createMCCommunicationRecord() {
        try {
            // list of MC Communication to be inserted
            list<MC_Communication__c> listToInsertMCCommunication = new list<MC_Communication__c>();
            map<string, string> mapL3idWithEmail = new map<string, string>();
            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (string.isNotBlank(caseActionObj.case_number__c) && (caseActionObj.L3A_Stakeholder__c != null || caseActionObj.L3B_Stakeholder__c != null) && string.isNotBlank(string.valueof(caseActionObj.Hold_Till_Date__c)) && caseActionObj.RecordTypeId == ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID &&
                        (trigger.isInsert || (trigger.isUpdate && caseActionObj.Hold_Till_Date__c != oldCaseActionMap.get(caseActionObj.id).Hold_Till_Date__c))) {
                    string l3Id;
                    if (caseActionObj.L3A_Stakeholder__c != null) {
                        l3Id = caseActionObj.L3A_Stakeholder__c;
                        mapL3idWithEmail.put(l3Id, NULL);
                    } else if (caseActionObj.L3B_Stakeholder__c != null) {
                        l3Id = caseActionObj.L3B_Stakeholder__c;
                        mapL3idWithEmail.put(l3Id, NULL);
                    }
                }
            }
            if (mapL3idWithEmail.size() > 0) {
                for (user us : [select id,email from user where id in :mapL3idWithEmail.keyset()]) {
                    mapL3idWithEmail.put(us.id, us.email);
                }
            }


            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (string.isNotBlank(caseActionObj.case_number__c) && (caseActionObj.L3A_Stakeholder__c != null || caseActionObj.L3B_Stakeholder__c != null) && string.isNotBlank(string.valueof(caseActionObj.Hold_Till_Date__c)) && caseActionObj.RecordTypeId == ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID &&
                        (trigger.isInsert || (trigger.isUpdate && caseActionObj.Hold_Till_Date__c != oldCaseActionMap.get(caseActionObj.id).Hold_Till_Date__c))) {
                    string l3Id;

                    if (caseActionObj.L3A_Stakeholder__c != null) {
                        l3Id = caseActionObj.L3A_Stakeholder__c;
                    } else if (caseActionObj.L3B_Stakeholder__c != null) {
                        l3Id = caseActionObj.L3B_Stakeholder__c;
                    }
                    string l3email = mapL3idWithEmail.containsKey(l3Id) ? mapL3idWithEmail.get(l3Id) : '';
                    listToInsertMCCommunication.add(new MC_Communication__c(case__c = caseActionObj.case_number__c, Escalation_Date_Time__c = caseActionObj.Hold_Till_Date__c - 1, Status__c = 'Queued', Communication_Type__c = 'Email', Type__c = ConstantsUtility.BULK_HOLD_UN_HOLD, To_Address__c = l3email));
                }
            }
            if (listToInsertMCCommunication.size() > 0) {
                insert listToInsertMCCommunication;
            }
        } catch (exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'createMCCommunicationRecord', '', null);
        }
    }
    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to add L3 To case Action Share  Team for Legal and NCH
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void sharingWhenLoggedInUserIsL3() {
        try {
            list<Case_Actions__Share> sharelist = new list<Case_Actions__Share>();
            map<string, string> mapOfCaseNumberWithUserId = new map<string, string>();
            for (case_actions__c casAcc : newCaseActionList) {
                mapOfCaseNumberWithUserId.put(casAcc.Case_Number__c, null);
            }
            if (mapOfCaseNumberWithUserId.size() > 0) {
                for (case cs : [select OwnerId,Id from case where id in :mapOfCaseNumberWithUserId.keyset()]) {
                    mapOfCaseNumberWithUserId.put(cs.Id, cs.OwnerId);
                }
            }
            for (case_actions__c casAcc : newCaseActionList) {
                if (casAcc.L3A_stakeholder__c != null && casAcc.L3A_stakeholder__c == UserInfo.getUserId() && (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID)) {
                    // Add share logic
                    Case_Actions__Share caseActionshare = new Case_Actions__Share();
                    caseActionshare.ParentId = casAcc.id;
                    caseActionshare.AccessLevel = 'Edit';
                    caseActionshare.UserOrGroupId = UserInfo.getUserId();
                    sharelist.add(caseActionshare);
                } else if (casAcc.RecordTypeId == ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID && mapOfCaseNumberWithUserId.containsKey(casAcc.Case_Number__c) && mapOfCaseNumberWithUserId.get(casAcc.Case_Number__c) == UserInfo.getUserId()) {
                    // Add share logic
                    Case_Actions__Share caseActionshare = new Case_Actions__Share();
                    caseActionshare.ParentId = casAcc.id;
                    caseActionshare.AccessLevel = 'Edit';
                    caseActionshare.UserOrGroupId = UserInfo.getUserId();
                    sharelist.add(caseActionshare);
                }
            }
            if (sharelist.size() > 0) {
                database.insert(sharelist, false);
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'sharingWhenLoggedInUserIsL3', '', null);
        } 
    }
    
    /**
        Author: Gitika Khandelwal
        Company: Techmatrix
        Description: Method to change case action Owner from Assignment Queue to channel,case type and business area basis queue.
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Gitika Khandelwal            Initial Version
	**/
    public void queueAssignment() {
        try {
            // used to store case Ids
            set<String> caseObjId = new set<String>();
            list<string> uniqueKeyList = new list<string>();
            map<string, string> mapOfUniqueKeyWithQueueId = new map<string, string>();
            // used to store Assignment_Queue Queue Ids
            string Assigned = [
                    SELECT Id, Name, DeveloperName, Email, Type
                    FROM Group
                    where Type = :ConstantsUtility.QUEUE
                    And DeveloperName = :ConstantsUtility.ASSIGNMENT_QUEUE
            ].Id;
            Assigned = String.valueof(Assigned).left(15);
            // iterating case Action
            for (Case_Actions__c casAcc : newCaseActionList) {
                string ownerid = String.valueof(casAcc.OwnerId).left(15);
                if (casAcc.Case_Number__c != null && ((trigger.isInsert && (ownerid == Assigned || (casAcc.Current_Approver__c != null && casAcc.Current_Approver__c == Assigned))) ||
                        (trigger.isUpdate && (ownerid == Assigned || (casAcc.Current_Approver__c != null && casAcc.Current_Approver__c == Assigned && casAcc.Current_Approver__c != oldCaseActionMap.get(casAcc.id).Current_Approver__c)
                        )))) {
                    caseObjId.add(casAcc.Case_Number__c);
                }
            }
            if (caseObjId.size() > 0) {
                // Query related case
                Map<Id, RecordType> caseActionRecordTypeMap = new Map<Id, RecordType>(
                [
                        SELECT Id,DeveloperName
                        FROM RecordType
                        WHERE SobjectType = :ConstantsUtility.CASE_ACTIONS
                ]
                );
                map<Id, case> mapOfcaseObjIdWithCase = new map<Id, case>([Select Channel__c,Business_area__c,Case_Type__c,Primary_Category__c from Case where id in :caseObjId]);

                // Queue Assignment
                for (Case_Actions__c casAcc : newCaseActionList) {
                    string ownerid = String.valueof(casAcc.OwnerId).left(15);
                    if (casAcc.Case_Number__c != null && mapOfcaseObjIdWithCase.containskey(casAcc.Case_Number__c) && ((trigger.isInsert && (ownerid == Assigned || (casAcc.Current_Approver__c != null && casAcc.Current_Approver__c == Assigned))) ||
                            (trigger.isUpdate && (ownerid == Assigned || (casAcc.Current_Approver__c != null && casAcc.Current_Approver__c == Assigned && casAcc.Current_Approver__c != oldCaseActionMap.get(casAcc.id).Current_Approver__c)
                            )))) {
                        case cse = mapOfcaseObjIdWithCase.get(casAcc.Case_Number__c);
                        // call helper method for Queue Assignment
                        string Key = (cse.Channel__c != null ? cse.Channel__c : '');
                        Key += (cse.Case_Type__c != null ? cse.Case_Type__c : '');
                        Key += (cse.Business_Area__c != null ? cse.Business_Area__c : '');
                        Id recordTypeId = casAcc.RecordTypeId;

                        if (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID) {
                            recordTypeId = (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID) ? ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID : recordTypeId;
                            Key += caseActionRecordTypeMap.get(RecordTypeId).DeveloperName;
                            system.debug('Key' + Key);
                        }
                        recordTypeId = (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID) ? ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID : recordTypeId;
                        // Key += false;

                        // --
                        uniqueKeyList.add(Key);
                    }
                }
                if (uniqueKeyList.size() > 0) {
                    mapOfUniqueKeyWithQueueId = caseTriggerHelper.getQueueAssignment(uniqueKeyList);
                    for (Case_Actions__c casAcc : newCaseActionList) {
                        string ownerid = String.valueof(casAcc.OwnerId).left(15);
                        if (casAcc.Case_Number__c != null && mapOfcaseObjIdWithCase.containskey(casAcc.Case_Number__c) && ((trigger.isInsert && (ownerid == Assigned || (casAcc.Current_Approver__c != null && casAcc.Current_Approver__c == Assigned))) ||
                                (trigger.isUpdate && (ownerid == Assigned || (casAcc.Current_Approver__c != null && casAcc.Current_Approver__c == Assigned && casAcc.Current_Approver__c != oldCaseActionMap.get(casAcc.id).Current_Approver__c)
                                )))) {
                            case cse = mapOfcaseObjIdWithCase.get(casAcc.Case_Number__c);
                            string Key = (cse.Channel__c != null ? cse.Channel__c : '');
                            Key += (cse.Case_Type__c != null ? cse.Case_Type__c : '');
                            Key += (cse.Business_Area__c != null ? cse.Business_Area__c : '');

                            Id recordTypeId = casAcc.RecordTypeId;
                            if (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID) {
                                recordTypeId = (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID) ? ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID : recordTypeId;
                                Key += caseActionRecordTypeMap.get(RecordTypeId).DeveloperName;
                            }
                            recordTypeId = (casAcc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.NCH_CASE_ACTION_RECORD_TYPE_ID || casAcc.RecordTypeId == ConstantsUtility.MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID) ? ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID : recordTypeId;
                            // Key += false;

                            if (mapOfUniqueKeyWithQueueId.containskey(Key)) {
                                casAcc.OwnerId = mapOfUniqueKeyWithQueueId.get(Key);
                            }
                        }
                    }
                    if (trigger.isafter) {
                        TriggerHandler.bypass('CaseActionsTriggerHandler');
                        update newCaseActionList;
                        TriggerHandler.clearBypass('CaseActionsTriggerHandler');
                    }
                }
            }
        } catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseActionsTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + e.getLineNumber(), 'queueAssignment', '', ehst);
        }
    }
   
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to inititate the approval process
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        08/06/2020                Prabhat Sharma            Initial Version
	**/
    public void initiateApprovalProcess() {
        try {
            //Set to store all case action record Ids
            set<Id> caseActionObjIds = new set<Id>();
            //Map to store record type Ids and set of record Ids for Approval process initiation
            Map<Id, set<Id>> recordTypeIdActionobjMap = new Map<Id, Set<Id>>();
            //Map to store the record type Id and it's name.
            Map<Id, RecordType> caseActionsRecordType = new Map<Id, RecordType>(ApprovalRequestService.fetchRecordTypeName(ConstantsUtility.CASEACTIONS_OBJECT));


            //Map for record type and Approval Process names from custom metadata type
            Map<String, String> approvalMatrixMap = new map<String, String>();
            for (Case_Action_Approval_Matrix__mdt approvalMatrixObj : [SELECT Id,DeveloperName,Approval_Process_API_Name__c FROM Case_Action_Approval_Matrix__mdt]) {
                approvalMatrixMap.put(approvalMatrixObj.DeveloperName, approvalMatrixObj.Approval_Process_API_Name__c);
            }


            for (Case_Actions__c caseActionObj : newCaseActionList) {
                caseActionObjIds = new set<Id>();
                if (recordTypeIdActionobjMap.containsKey(caseActionObj.RecordtypeId)) {
                    if (recordTypeIdActionobjMap.get(caseActionObj.RecordtypeId) != null) {
                        recordTypeIdActionobjMap.get(caseActionObj.RecordtypeId).add(caseActionObj.Id);
                    }
                } else {
                    caseActionObjIds.add(caseActionObj.Id);
                    recordTypeIdActionobjMap.put(caseActionObj.RecordtypeId, caseActionObjIds);
                }

            }

            //Loop through all the record type Ids and initiate the approval process 
            if (recordTypeIdActionobjMap.keySet().size() > 0) {
                for (Id caseActionRecTypeId : recordTypeIdActionobjMap.keySet()) {
                    if (caseActionsRecordType.containsKey(caseActionRecTypeId) && approvalMatrixMap.containsKey(caseActionsRecordType.get(caseActionRecTypeId).DeveloperName)) {
                        //Get Approval Process Name
                        String approvalProcessName = approvalMatrixMap.get(caseActionsRecordType.get(caseActionRecTypeId).DeveloperName);
                        //Get all the record Ids
                        set<Id> recordIds = new set<Id>();
                        recordIds = recordTypeIdActionobjMap.get(caseActionRecTypeId);
                        ApprovalRequestService.initiateApprovalRequests(recordIds, approvalProcessName);
                    }
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'initiateApprovalProcess', '', null);
        }
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to change the owner of the record everytime the requests gets approved or rejcted to maintian the edit access to the record owner only
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        08/06/2020                Prabhat Sharma            Initial Version
	**/
    public void changeCaseActionOwner() {
        try {
            system.debug('Im in before update');
            Map<Id, Set<String>> recordIdVdNotifiersMap = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
            Map<String, Approval_Notification_Setting__c> approvalTypeVsNotificationSettingsMap = new Map<String, Approval_Notification_Setting__c>();
            for (Approval_Notification_Setting__c notificationSetting : [SELECT Name,Approval_Type__c,Approved_Template__c,Rejected_Template__c FROM Approval_Notification_Setting__c WHERE isActive__c = true]) {
                approvalTypeVsNotificationSettingsMap.put(notificationSetting.Approval_Type__c, notificationSetting);
            }
            Map<Id, Case_Actions__c> actionsMap = new Map<Id, Case_Actions__c>([SELECT RecordType.DeveloperName FROM Case_Actions__c WHERE Id IN:oldCaseActionMap.keySet()]);
            Set<String> approversIds = new Set<String>();
            for (Case_Actions__c casActionObj : this.newCaseActionList) {
                if (casActionObj.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID && casActionObj.Dealership_ID__c != null
                        && oldCaseActionMap.get(casActionObj.Id).Dealership_ID__c != casActionObj.Dealership_ID__c) {
                    casActionObj.Dealer_Name__c = casActionObj.Dealership_ID__c;
                }

                //Ids add
                if (casActionObj.Case_Actions_Visibilities_IDs__c != null) {
                    approversIds.addAll(casActionObj.Case_Actions_Visibilities_IDs__c.split(';'));
                }
                system.debug('currentold' + casActionObj.Current_Approver__c);
                system.debug('currentold' + this.oldCaseActionMap.get(casActionObj.Id).Current_Approver__c);
                if (casActionObj.Current_Approver__c != null && this.oldCaseActionMap.get(casActionObj.Id).Current_Approver__c != casActionObj.Current_Approver__c && (casActionObj.Current_Approver__c).startsWith(ConstantsUtility.OO5)) {
					
                    if (!approversIds.contains(casActionObj.Current_Approver__c)) {
                        approversIds.add(casActionObj.Current_Approver__c);
                    }
                    if (this.oldCaseActionMap.get(casActionObj.Id).Current_Approver__c != null && !approversIds.contains(this.oldCaseActionMap.get(casActionObj.Id).Current_Approver__c)) {
                        approversIds.add(this.oldCaseActionMap.get(casActionObj.Id).Current_Approver__c);
                    }
                    List<String> approvalIdList = new List<String>();
                    approvalIdList.addAll(approversIds);
                    casActionObj.Case_Actions_Visibilities_IDs__c = String.join(approvalIdList, ';');
                }

                /** Specific to send the Notification to L6 for DNE Request */
                if (casActionObj.RecordTypeId == ConstantsUtility.DNE_CASE_ACTION_RECORD_TYPE_ID && UserInfo.getUserId() == casActionObj.L5_Stakeholder__c) {
                    Approval_Notification_Setting__c notificationSetting = approvalTypeVsNotificationSettingsMap.get(actionsMap.get(casActionObj.Id).RecordType.DeveloperName);
                    Set<String> userStrings = new Set<String>();
                    userStrings.add(casActionObj.L6A_Stakeholder__c);
                    recordIdVdNotifiersMap.put(casActionObj.Id, userStrings);
                    String message = notificationSetting.Approved_Template__c;
                    message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, casActionObj.Case_Number_Text__c) : message;
                    recordIdVsMessageMap.put(casActionObj.Id, message);
                }
            }
            if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'changeCaseActionOwner', '', null);
        }
    }


    /**
    Author: Gitika
    Company: Techmatrix
    Description: Method to update the related Case status basis on status of Approval
    Returns: void
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        08/06/2020                Prabhat Sharma            Initial Version
    **/
	public void updateRelatedCaseStatus() {
        try {
            list<case> casesToUpdate = new list<case>();
            // set used to store DNE Case ids
            set<Id> DNEcaseIds = new set<Id>();
            // set used to store Spam Case Action ids
            set<Id> spamCaseActions = new set<Id>();
            // map used to store case id with case action record
            map<string, case_actions__c> mapOfCaseIdsWithCaseAction = new map<string, case_actions__c>();
            //Loop through the Case Action records
            for (Case_Actions__c casAc : this.newCaseActionList) {
                /** Updating the original case status closed if the case action approved */
                if (casAc.Approval_Status__c == ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED && casAc.Approval_Status__c != oldCaseActionMap.get(casAc.id).Approval_Status__c) {
                    if (casAc.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID && casAc.Transferred_Dealer_Approver__c != null && UserInfo.getUserId() == casAc.Transferred_Dealer_Approver__c) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_STATUS_TRANSFERRED));
                    } else if (casAc.RecordTypeId == ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID) {
                        // casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_STATUS_ON_HOLD, IsStopped = true));
                        mapOfCaseIdsWithCaseAction.put(casAc.Case_Number__c, CasAc);
                    } else if (casAc.RecordTypeId == ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID) {
                        mapOfCaseIdsWithCaseAction.put(casAc.Case_Number__c, CasAc);
                    } else if (casAc.RecordTypeId == ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID) {
                        //Change added by Nitin on 9th Nov
                        if(casAc.Primary_Category__c==ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE && casAc.Secondary_Category__c==ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED){
                            casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_CLOSED,Revalidation_Flag__c=true,Ringi_Number__c=label.Suzuki_Connect_Ringi_Number));
                        }else{
                            casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_CLOSED));
                        }
                    } else if (casAc.RecordTypeId == ConstantsUtility.Service_Complaint_Closure_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_CLOSED));
                    } else if (casAc.RecordTypeId == ConstantsUtility.DEALER_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_CLOSED));
                    } else if (casAc.RecordTypeId == ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_CLOSED));
                    } else if (casAc.RecordTypeId == ConstantsUtility.DNE_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, DNE_Customer__c = true, DNE_Till_Date__c = system.today().adddays(integer.valueOf(Label.DNE_Check_Duration))));
                        DNEcaseIds.add(casAc.Case_Number__c);
                    } else if (casAc.RecordTypeId == ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, DNE_Customer__c = true, DNE_Till_Date__c = system.today().adddays(integer.valueOf(Label.DNE_Check_Duration)), status = ConstantsUtility.LEGAL));
                        DNEcaseIds.add(casAc.Case_Number__c);
                    } else if (casAc.RecordTypeId == ConstantsUtility.DUPLICATE_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_STATUS_ON_DUPLICATE));
                    } else if (casAc.RecordTypeId == ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, CCP_Complete_Time__c = Datetime.now(), CCP_Status__c = ConstantsUtility.CCP_STATUS_CONTACTED_BY_RO_NOT_CCA_COMPLETE, CCP_Next_Escalation_Date_Time__c = null, CCP_Outbound_Call_Date_Time__c = null));
                    } else if (casAc.RecordTypeId == ConstantsUtility.SPAM_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, status = ConstantsUtility.CASE_CLOSED));
                        spamCaseActions.add(casAc.Id);
                    } else if (casAc.RecordTypeId == ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID && casAc.Ringi_Number__c != null) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, Revalidation_Flag__c = true, Ringi_Number__c = casAc.Ringi_Number__c));
                    } else if (casAc.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID && casAc.Ringi_Number__c != null) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, Revalidation_Category__c = casAc.Revalidation_Category__c, Revalidation_Flag__c = true, Ringi_Number__c = casAc.Ringi_Number__c));
                    } else if (casAc.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, Revalidation_Category__c = casAc.Revalidation_Category__c, Revalidation_Flag__c = true));
                    }
                }
                /** ON REJECTION ACTION */
                if (casAc.Approval_Status__c == ConstantsUtility.STATUS_REJECTED && casAc.Approval_Status__c != oldCaseActionMap.get(casAc.id).Approval_Status__c) {
                    if (casAc.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID) {
                        casesToUpdate.add(new case (id = casAc.Case_Number__c, Workshop_Reason__c = casAc.Workshop_Reason__c));
                    }
                }
            }


            if (DNEcaseIds.size() > 0) {
                CaseActionsTriggerHandler.updateDNEonCustomer(DNEcaseIds);
            }
            if (spamCaseActions.size() > 0) {
                CaseActionsTriggerHandler.insertSpamRecord(spamCaseActions);
            }
            if (mapOfCaseIdsWithCaseAction.size() > 0) {
                CaseActionsTriggerHandler.updateCaseFieldsOnServiceOnHoldApproval(mapOfCaseIdsWithCaseAction);
            }
            // Update Case
            if (casesToUpdate.size() > 0 || mapOfCaseIdsWithCaseAction.size() > 0) {
                //TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                // Updated parent parent case  Milestones closed
                updateCaseMileStone();
                System.debug(casesToUpdate);
                update casesToUpdate;
                //TriggerHandler.clearBypass('CaseTriggerHandler_Strategy');
            }
        } catch (Exception e) {
            System.debug('Exception ' + e.getMessage());
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'updateRelatedCaseStatus', '', null);
        }
    }
    
    /**
        Author: Gitika
        Company: Techmatrix
        Description: Method to update the Customer as DNE Customer basis related DNE Case
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        02/07/2020                Gitika            Initial Version
	**/
	public static void updateDNEonCustomer(set<Id> DNEcaseIds) {
        try {
            list<Account> customerListToUpdate = new list<Account>();
            for (case cs : [Select Customer__c from case where id in :DNEcaseIds]) {
                if (string.isNotBlank(cs.Customer__c)) {
                    customerListToUpdate.add(new Account(id = cs.Customer__c, DNE_Case_Id__c = cs.Id, DNE_Till_Date__c = system.today().adddays(integer.valueOf(Label.DNE_Check_Duration))));
                }
            }

            if (customerListToUpdate.size() > 0) {
                TriggerHandler.bypass('AccountTriggerHandler');
                update customerListToUpdate;
                TriggerHandler.clearBypass('AccountTriggerHandler');
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'changeCaseActionOwner', '', null);
        }

    }
    
    
    /**
        Author: Gitika
        Company: Techmatrix
        Description: Method to insert Spam record
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        02/07/2020                Gitika            Initial Version
	**/
	public static void insertSpamRecord(set<Id> spamCaseActions) {
        try {
            // list used to store DNE Case ids
            List<Spam_Phone_Emails__c> listToInsert = new List<Spam_Phone_Emails__c>();
            for (case_actions__c caseAccObj : [Select Case_Number__r.Origin,Email__c,Mobile__c from case_actions__c where id in :spamCaseActions]) {
                Spam_Phone_Emails__c spam = new Spam_Phone_Emails__c();
                spam.RecordTypeId = caseAccObj.Case_Number__r.Origin == ConstantsUtility.EMAIL ? ConstantsUtility.EMAIL_SPAM_RECORD_TYPE_ID : ConstantsUtility.PHONE_SPAM_RECORD_TYPE_ID;
                spam.Email__c = string.isNotBlank(caseAccObj.Email__c) ? caseAccObj.Email__c : null;
                spam.Phone_No__c = string.isNotBlank(caseAccObj.Mobile__c) ? caseAccObj.Mobile__c : null;
                spam.From_Date__c = system.today();
                spam.To_Date__c = system.today().adddays(integer.valueOf(Label.Spam_Check_Duration));
                listToInsert.add(spam);
            }

            if (listToInsert.size() > 0) {
                insert listToInsert;
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'insertSpamRecord', '', null);
        }

    }
    
    
    /**
        Author: Gitika
        Company: Techmatrix
        Description: Method to update on hold start date and On Hold End date for service on hold
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        03/09/2020                Gitika            Initial Version
	**/
	public static void updateCaseFieldsOnServiceOnHoldApproval(map<string, case_actions__c> mapOfCaseIdsWithCaseAction) {
        try {
            // list used to store update Case ids
            List<case> listToUpdate = new List<case>();
            for (case caseObj : [Select Id,On_Hold_Start_date__c,On_Hold_End_date__c from case where id in :mapOfCaseIdsWithCaseAction.keyset()]) {
                case cs = new case();
                cs.id = caseObj.id;
                cs.status = ConstantsUtility.CASE_STATUS_ON_HOLD;
                cs.IsStopped = true;
                if (caseObj.On_Hold_Start_date__c == null)
                    cs.On_Hold_Start_date__c = mapOfCaseIdsWithCaseAction.get(caseObj.id).Hold_Start_date__c;
                    cs.On_Hold_End_date__c = mapOfCaseIdsWithCaseAction.get(caseObj.id).Hold_Till_date__c;
                listToUpdate.add(cs);
            }

            if (listToUpdate.size() > 0) {
                update listToUpdate;
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'updateCaseFieldsOnServiceOnHoldApproval', '', null);
        }

    }
    
    
    /**
        Author: Gitika
        Company: Techmatrix
        Description: Generic Method to Restrict Duplicate Case Action creation of same recordtype under single Case
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        03/07/2020                Gitika            Initial Version
	**/
	public void dupChckOfCaseActionWthSameCase() {
        try {
            // Set to contain all recordtype Developer Name of Case Action for duplicate check
            Set<String> caseActionRecordTypeNames = new Set<String>();
            // case object record ids
            Set<String> caseObjIds = new Set<String>();
            // Map of case ids with List of recordtypeids of case Action for duplicate check
            map<Id, list<String>> mapOfCaseIdWithListOfRecordtypeIds = new map<Id, list<String>>();


            // Looping Case Action for case number
            for (Case_Actions__c casAcc : this.newCaseActionList) {
                if (string.IsNotBlank(casAcc.Case_Number__c)) {
                    caseObjIds.add(casAcc.Case_Number__c);
                }
            }

            // Looping Custom Setting for duplicate check w.r.t to recordtype
            for (Case_Action_Creation_check_Under_Case__c caseActionRecortypeWithCreationCheck : Case_Action_Creation_check_Under_Case__c.getall().values()) {
                if (caseActionRecortypeWithCreationCheck.Single__c) {
                    caseActionRecordTypeNames.add(caseActionRecortypeWithCreationCheck.RecordType_DeveloperName__c);
                }
            }
            // Looping related case action records under same case
            if (caseActionRecordTypeNames.size() > 0 && caseObjIds.size() > 0) {
                for (Case_Actions__c casAcc : [Select Case_Number__c,RecordType.DeveloperName,RecordTypeId,Approval_Status__c from Case_Actions__c Where Case_Number__c in :caseObjIds and Approval_Status__c != 'Rejected']) {
                    if (caseActionRecordTypeNames.contains(casAcc.RecordType.DeveloperName)) {
                        if (!mapOfCaseIdWithListOfRecordtypeIds.containskey(casAcc.Case_Number__c)) {
                            mapOfCaseIdWithListOfRecordtypeIds.put(casAcc.Case_Number__c, new list<string>{
                                    casAcc.RecordTypeId
                            });
                        } else {
                            list<String> listOfRecordtypeId = mapOfCaseIdWithListOfRecordtypeIds.get(casAcc.Case_Number__c);
                            listOfRecordtypeId.add(casAcc.RecordTypeId);
                            mapOfCaseIdWithListOfRecordtypeIds.put(casAcc.Case_Number__c, listOfRecordtypeId);
                        }
                    }
                }
            }

            // Validation Looping
            for (Case_Actions__c casAcc : this.newCaseActionList) {
                if (mapOfCaseIdWithListOfRecordtypeIds.containskey(casAcc.Case_Number__c)
                        && mapOfCaseIdWithListOfRecordtypeIds.get(casAcc.Case_Number__c).contains(casAcc.recordtypeId)) {
                    casAcc.addError(casAcc.Name + ' ' + label.CASE_ACTION_DUP_ERROR_MSG);
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'dupChckOfCaseActionWthSameCase', '', null);
        }
    }
    
    /**
Author: Gitika Khandelwal
Company: Techmatrix
Description: This method is used to create MC Communication Records For Notifications
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        04/09/2020                Deepak Kumar              Initial Version
**/
    /*   public void createMCRecordsForATM() {
           //map of caseIds with Case Action Record
           map<id, Case_Actions__c> mapOfCaseIdsWithCaseAction = new map<id, Case_Actions__c>();
           // List to store Case Details
           List<Case> caseList = new List<Case>();
           for (Case_Actions__c caseActions : this.newCaseActionList) {

               if (String.isNotBlank(caseActions.Case_Number__c)) {
                   mapOfCaseIdsWithCaseAction.put(caseActions.Case_Number__c, caseActions);
               }

           }
           if (mapOfCaseIdsWithCaseAction.size() > 0) {
               for (Case cs : [
                       Select id,Stakeholders_JSON__c,Selected_Hierarchy_Type__c,Case_Sub_Type__c,Case_Type__c,Channel__c,Business_Area__c,Case_Stage__c,Region_Code__c,Dealer_Name__c,Primary_Category__c,Primary_Category_ID__c,Secondary_Category__c,Secondary_Category_ID__c,NCH_Docket_Number__c,
                               Tertiary_Category__c,Tertiary_Category_ID__c,First_Name__c,Last_Name__c,Mobile_Number__c,Mobile_Number_1__c,Email__c,Model__c,Variant__r.Name,Origin,Mode__c,
                               createdDate,Customer_Satisfied_With_FCR__c,FCR_Conducted__c,Dealer_Code__c,Zone__c,Description,Additional_Information__c,Registration_No__c,Next_Escalation_Date__c,
                               Next_Escalation_Level__c,RecordTypeId,On_Hold_End_Date__c,MSIL_Non_SF_Stakeholder_Email__c,Dealer_Address__c,Middle_name__c,Days_Open__c,CCP_Status__c,MSIL_Remarks__c,Latest_Escalation_Level__c,Variant__c,SVOC_ID__c,Customer__c,IsClosed
                       from case
                       where id in :mapOfCaseIdsWithCaseAction.keyset()
               ]) {
                   Case caseRecord = new Case();
                   caseRecord = cs;
                   caseRecord.Case_Type__c = mapOfCaseIdsWithCaseAction.get(cs.id).Name;
                   if (mapOfCaseIdsWithCaseAction.get(cs.id).Hold_Till_Date__c != null) {
                       caseRecord.On_Hold_End_date__c = mapOfCaseIdsWithCaseAction.get(cs.id).Hold_Till_Date__c;
                   }
                   caseList.add(caseRecord);
               }
               if (caseList.size() > 0) {
                   MCCommunicationService.createMCRecordsForATM(caseList, null);
               }
           }
       }*/
    
    
    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method is used to create a new case record once the Case action status changes to transferred
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        08/06/2020                Deepak Kumar              Initial Version
	**/
    public void createTransferredChildCase() {
        try {
            List<Case> transferCasesToInsert = new List<Case>();
            set<Id> caseIds = new Set<Id>();
            for (Case_Actions__c caseActions : this.newCaseActionList) {
                if (caseActions.Approval_Status__c == ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED && caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID
                        && caseActions.Approval_Status__c != oldCaseActionMap.get(caseActions.id).Approval_Status__c) {
                    caseIds.add(caseActions.Case_Number__c);
                }
            }
            if (caseIds.size() > 0) {
                Map<Id, Case> caseMap = getCases(caseIds);
                for (Case_Actions__c caseActions : this.newCaseActionList) {
                    if (caseMap.containsKey(caseActions.Case_Number__c)) {
                        Case newCase = new Case();
                        newCase = caseMap.get(caseActions.Case_Number__c).clone();
                        newCase.Id = null;
                        transferCasesToInsert.add(CaseActionTriggerHelper.getTransferredChildCaseFieldMapping(newCase, caseActions));
                    }
                }
            }
            if (transferCasesToInsert.size() > 0) {
                upsert transferCasesToInsert;
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'createTransferredChildCase', '', null);
        }
    }


    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method is used to get the case map based on case ids provided.
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        08/06/2020                Deepak Kumar              Initial Version
	**/
    private static Map<Id, Case> getCases(Set<Id> caseIds) {
        Map<Id, Case> caseMap = new Map<Id, Case>([
                SELECT Id,Case_Type__c,First_Name__c,Middle_Name__c,Last_Name__c,Email__c,Mobile_Number__c,
                        FCR_Conducted__c,Customer_Satisfied_With_FCR__c,Region_Code__c,Origin,Mode__c,NCH_Docket_Number__c,
                        Preferred_Mode_Of_Communication__c,Top_Management_Executive__c,Subject,Description,Additional_Information__c,
                        Enquiry__c,Booking_No__c,Invoice_No__c,Model__c,Variant__c,Color__c,Vehicle_Registration_Number__c,VIN_No__c,
                        Customer_Name__c
                FROM Case
                WHERE Id IN:caseIds
        ]);
        return caseMap;
    }


    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will check and update the record Fields
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Deepak Kumar              Initial Version
	**/
    public void updateTransferEscalationsBeforeUpdate() {
        CaseEscalationService.updateTransferEscalationsBeforeUpdate(newCaseActionList, oldCaseActionMap);
    }
    
    
    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will check and update the record Fields
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Deepak Kumar              Initial Version
	**/
    public void updateTransferEscalationsAfterUpdate() {
        CaseEscalationService.updateTransferEscalationsAfterUpdate(newCaseActionList, oldCaseActionMap);
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will Update the notifiers based on the approval process
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Deepak Kumar              Initial Version
	**/
    public void updateApprovalNotifiers() {
        try {
            Set<Id> caseActionsIds = new Set<Id>();
            for (Case_Actions__c caseActions : newCaseActionList) {
                if (caseActions.OwnerId != oldCaseActionMap.get(caseActions.Id).OwnerId || caseActions.Approval_Status__c != oldCaseActionMap.get(caseActions.Id).Approval_Status__c) {
                    caseActionsIds.add(caseActions.Id);
                }
            }
            if (caseActionsIds.size() > 0) {
                Map<Id, List<String>> caseActionIdVsRelatedUsersIdMap = new Map<Id, List<String>>();
                for (ProcessInstanceStep instance : [SELECT ActorId,ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId IN :caseActionsIds]) {
                    if (!caseActionIdVsRelatedUsersIdMap.containsKey(instance.ProcessInstance.TargetObjectId)) {
                        caseActionIdVsRelatedUsersIdMap.put(instance.ProcessInstance.TargetObjectId, new List<String>());
                    }
                    caseActionIdVsRelatedUsersIdMap.get(instance.ProcessInstance.TargetObjectId).add(instance.ActorId);
                }
                if (!caseActionIdVsRelatedUsersIdMap.isEmpty()) {
                    for (Case_Actions__c caseActions : newCaseActionList) {
                        if (caseActionIdVsRelatedUsersIdMap.containsKey(caseActions.Id)) {
                            List<String> usersIds = caseActionIdVsRelatedUsersIdMap.get(caseActions.Id);
                            //  System.debug('usersIds' + usersIds);
                            if (usersIds != null && usersIds.size() > 0) {
                                caseActions.Approval_Notifiers__c = CaseEscalationService.getUserLevelUsers(usersIds, caseActions); //String.join(usersIds, ',');
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'updateApprovalNotifiers', '', null);
        }
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will send the chatter notification to the related approver users
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        10/06/2020                Deepak Kumar              Initial Version
	**/
    public void sendChatterNotificationToApprovers() {
        try {

            Map<Id, Set<String>> recordIdVdNotifiersMap = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
            Map<Id, Case_Actions__c> actionsMap = new Map<Id, Case_Actions__c>([SELECT RecordType.DeveloperName,Case_Number__r.OwnerId FROM Case_Actions__c WHERE Id IN:oldCaseActionMap.keySet()]);
            for (Case_Actions__c caseActions : newCaseActionList) {
                if (caseActions.Approval_Status__c != oldCaseActionMap.get(caseActions.Id).Approval_Status__c &&
                        (caseActions.Approval_Status__c == ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED || caseActions.Approval_Status__c == ConstantsUtility.Rejected)) {
                    String message = caseActions.Approval_Chatter_Message__c != null ? caseActions.Approval_Chatter_Message__c : null;
                    if (message != null) {
                        Set<String> usersIds = new Set<String>();
                        if (caseActions.Approval_Notifiers__c != null) {
                            usersIds = CaseEscalationService.getUserIds(caseActions.Approval_Notifiers__c.split(','), caseActions);
                        } else if (caseActions.recordTypeId == ConstantsUtility.SPAM_CASE_ACTION_RECORD_TYPE_ID) {
                            usersIds.add(caseActions.OwnerId);
                            usersIds.add(actionsMap.get(caseActions.Id).Case_Number__r.OwnerId);
                        }
                        if (usersIds.size() > 0) {
                            recordIdVdNotifiersMap.put(caseActions.Id, usersIds);
                            recordIdVsMessageMap.put(caseActions.Id, message);
                        }
                    }
                }
            }
            if (!recordIdVdNotifiersMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
                // List<MC_Communication__c> communications = GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE, new set<Id>(recordIdVdNotifiersMap.keySet()), ConstantsUtility.CASE_ACTIONS, '');

            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'sendChatterNotificationToApprovers', '', null);
        }
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: It will update related Case Milestone closed
        History:
        ===============================================================
        1.0     30 Jun 2020      Deepak     Initial Version
	*/
    public void updateCaseMileStone() {
        try {
            Set<Id> closedCaseIds = new Set<Id>();
            //Loop through the Case Action records
            for (Case_Actions__c casAc : this.newCaseActionList) {
                /** Collecting the case ids for approved case actions */
                if (casAc.Approval_Status__c == ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED && casAc.Approval_Status__c != oldCaseActionMap.get(casAc.id).Approval_Status__c) {
                    /** Excluding the on hold type cases */
                    if (casAc.RecordTypeId != ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID) {
                        closedCaseIds.add(casAc.Case_Number__c);
                    }
                }
            }
            if (closedCaseIds.size() > 0) {
                List<String> milestoneNames = new List<String>();
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_FIRST_RESPONSE);
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_CASE_CLOSURE_TIME);
                MilestoneUtils.completeMilestone(closedCaseIds, milestoneNames, DateTime.now());
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'updateCaseMileStone', '', null);
        }
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will check for all the validations to create a duplicate case action.
        History:
        ===============================================================
        1.0     02 July 2020      Deepak     Initial Version
	*/
    public void validationForDuplicateCaseActions() {
        try {
            Set<Id> originalCaseIds = new Set<Id>(); // Set to store the duplicate case action Original case id
            Set<Id> caseIds = new Set<Id>(); // Set to store the current case ids which needs to mark as duplicate

            for (Case_Actions__c caseActions : this.newCaseActionList) {
                if (caseActions.RecordTypeId == ConstantsUtility.DUPLICATE_CASE_ACTION_RECORD_TYPE_ID) {
                    originalCaseIds.add(caseActions.Original_Complaint_No__c);
                    caseIds.add(caseActions.Case_Number__c);
                }
            }
            if (originalCaseIds.size() > 0) {
                Map<Id, Case> idVsCaseMap = new Map<Id, Case>([SELECT Status,IsClosed,CreatedDate,Assigned_Date__c FROM Case WHERE Id IN :caseIds]); // Map to Store the current case which needs to mark as closed
                Map<Id, Case> caseNumberVsCaseMap = new Map<Id, Case>([SELECT CaseNumber,CreatedDate,Status,IsClosed FROM Case WHERE Id IN :originalCaseIds]);  // Map to Store the Original case based on case Id
                // Move errors from customs setting to labels.
                String errorMessage;
                // Iteration for show the error based on conditions
                for (Case_Actions__c caseActions : this.newCaseActionList) {
                    errorMessage = null;
                    Case originalCase = caseNumberVsCaseMap.get(caseActions.Original_Complaint_No__c);
                    Case currentCase = idVsCaseMap.get(caseActions.Case_Number__c);
                    if (originalCase.CreatedDate > currentCase.CreatedDate) {
                        errorMessage = System.Label.Duplicate_Case_Created_Date_Error;
                    } else if (originalCase.IsClosed) {
                        errorMessage = System.Label.Original_Case_Not_Open_Error;
                    } else if (currentCase.Assigned_Date__c != null && Date.valueOf(currentCase.Assigned_Date__c).addDays(15) < Datetime.now()) {
                        errorMessage = System.Label.Duplicate_Case_Initiation_Delay_Error;
                    }
                    if (String.isNotBlank(errorMessage)) {
                        caseActions.addError(errorMessage);
                    }
                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'validationForDuplicateCaseActions', '', null);
        }
    }


    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will assign the Transfer stake holder for new dealer.
        History:
        ===============================================================
        1.0     02 July 2020      Deepak     Initial Version
	*/
    public void updateDealerTransferStakeHolders() {
        try {
            // Map to add access for the Transferred_Dealer_Approver user if the region is getting change
            Map<Id, Map<String, String>> caseIdVsUserIdAndAccessTypeMap = new Map<Id, Map<String, String>>();
            Set<Id> dealerIds = new Set<Id>();

            Set<Id> caseIds = new Set<Id>(); // Set to store the current case ids to create case Map
            for (Case_Actions__c caseActions : this.newCaseActionList) {
                // Specific Actions to Transfer case Action
                if (caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID) {
                    // if (Trigger.isInsert || (Trigger.isUpdate && caseActions.Dealership_ID__c != oldCaseActionMap.get(caseActions.Id).Dealership_ID__c))
                    caseIds.add(caseActions.Case_Number__c);
                }
            }
            if (caseMap.isEmpty()) {
                caseMap = getCaseMap(caseIds);
            }
            if (!caseMap.isEmpty()) {
                List<Case_Actions__c> otherRegionCaseActions = new List<Case_Actions__c>();
                Set<Id> categoryIdSet = new Set<Id>();
                List<Case> tempCases = new List<Case>();
                for (Case_Actions__c caseActions : this.newCaseActionList) {
                    if (caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID) {
                        caseActions.Dealer_Name__c = caseActions.Dealership_ID__c;
                        /** Assigning the Transferred_Dealer_Approver Based of on the region and case Type */
                        /*if (caseActions.Region_Code__c == caseMap.get(caseActions.Case_Number__c).Region_Code__c) {
                            caseActions.Transferred_Dealer_Approver__c = caseActions.L4_Stakeholder__c;
                            caseActions.Transferred_Dealer_L5__c = caseActions.L5_Stakeholder__c;
                        } else*/
                        //if (caseActions.Region_Code__c != caseMap.get(caseActions.Case_Number__c).Region_Code__c) {
                        /** If the Selected Dealer in not within the same region */
                        dealerIds.add(caseActions.Dealer_Name__c);
                        otherRegionCaseActions.add(caseActions);
                        categoryIdSet.add(getCategoryId(caseActions));
                        // Creating temp case object for Type Casting to use the existing methods
                        Case tempCaseObj = new Case();
                        tempCaseObj.Channel__c = caseActions.Channel__c;
                        tempCaseObj.Case_Type__c = caseActions.Case_Type__c;
                        tempCaseObj.Business_Area__c = caseActions.Business_Area__c;
                        tempCaseObj.Region_Code__c = caseActions.Region_Code__c;
                        tempCaseObj.Primary_Category_ID__c = caseActions.Primary_Category_ID__c;
                        tempCaseObj.Secondary_Category_ID__c = caseActions.Secondary_Category_ID__c;
                        tempCaseObj.Tertiary_Category_ID__c = caseActions.Tertiary_Category_ID__c;
                        tempCases.add(tempCaseObj);
                        // }
                    }
                }if (categoryIdSet.size() > 0) {
                    CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(categoryIdSet); // Calling this method only to store the value in public property
                    Map<String, String> caseTypeVsHierarchyMap = new Map<String, String>();
                    caseTypeVsHierarchyMap = CaseAssignmentServiceHelper.getHierarchySelectionMap(tempCases);
                    updateTransferredDealerApprover(dealerIds, otherRegionCaseActions, caseTypeVsHierarchyMap);
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'updateDealerTransferStakeHolders', '', null);
        }


    }

    private static void updateTransferredDealerApprover(Set<Id> dealerIds, List<Case_Actions__c> otherRegionCaseActions, Map<String, String> caseTypeVsHierarchyMap) {
        Map<Id, Account> dealerMap = getDealerMap(dealerIds);
        for (Case_Actions__c caseActions : otherRegionCaseActions) {
            String dealerStakeHolderHierarchyJson = dealerMap.get(caseActions.Dealer_Name__c).Stakeholder_Hierarchy__c;
            StakeholderHierarchy stakeholderHierarchy = StakeholderUtility.parseStakeholderHierarchyJson(dealerStakeHolderHierarchyJson);

            String key = caseActions.Channel__c + caseActions.Case_Type__c + CaseAssignmentServiceHelper.getActualLob(caseActions.Business_Area__c);
            if (caseTypeVsHierarchyMap.containsKey(key)) {
                getTransferredDealerApproverUser(caseTypeVsHierarchyMap.get(key), stakeholderHierarchy, caseActions);
                System.debug(caseActions.Transferred_Dealer_Approver__c);
            }
        }


    }
    private static void getTransferredDealerApproverUser(String hierarchyType, StakeholderHierarchy stakeholderHierarchy, Case_Actions__c caseActions) {
        List<StakeholderHierarchy.Sales> hierarchyList = new List<StakeholderHierarchy.Sales>();
        if (hierarchyType == ConstantsUtility.SALES_HIERARCHY && stakeholderHierarchy.sales != null && stakeholderHierarchy.sales.size() > 0) {
            hierarchyList = stakeholderHierarchy.sales;
        } else if (hierarchyType == ConstantsUtility.SERVICE_ARENA_HIERARCHY && stakeholderHierarchy.serviceArena != null && stakeholderHierarchy.serviceArena.size() > 0) {
            hierarchyList = stakeholderHierarchy.serviceArena;
        } else if (hierarchyType == ConstantsUtility.SERVICE_NEXA_HIERARCHY && stakeholderHierarchy.serviceNexa != null && stakeholderHierarchy.serviceNexa.size() > 0) {
            hierarchyList = stakeholderHierarchy.serviceNexa;
        } else if (hierarchyType == ConstantsUtility.ACCESSORIES_HIERARCHY && stakeholderHierarchy.accessories != null && stakeholderHierarchy.accessories.size() > 0) {
            hierarchyList = stakeholderHierarchy.accessories;
        } else if (hierarchyType == ConstantsUtility.TRUEVALUE_HIERARCHY && stakeholderHierarchy.trueValue != null && stakeholderHierarchy.trueValue.size() > 0) {
            hierarchyList = stakeholderHierarchy.trueValue;
        } else if (hierarchyType == ConstantsUtility.MSDS_HIERARCHY && stakeholderHierarchy.msds != null && stakeholderHierarchy.msds.size() > 0) {
            hierarchyList = stakeholderHierarchy.msds;
        } else if (hierarchyType == ConstantsUtility.MSGP_HIERARCHY && stakeholderHierarchy.msgp != null && stakeholderHierarchy.msgp.size() > 0) {
            hierarchyList = stakeholderHierarchy.msgp;
        } else if (hierarchyType == ConstantsUtility.LOYALTY_PROGRAM_HIERARCHY && stakeholderHierarchy.loyaltyProgram != null && stakeholderHierarchy.loyaltyProgram.size() > 0) {
            hierarchyList = stakeholderHierarchy.loyaltyProgram;
        } else if (hierarchyType == ConstantsUtility.FINANCE_HIERARCHY && stakeholderHierarchy.finance != null && stakeholderHierarchy.finance.size() > 0) {
            hierarchyList = stakeholderHierarchy.finance;
        } else if (hierarchyType == ConstantsUtility.MSIL_QUERY_HIERARCHY && stakeholderHierarchy.msilQuery != null && stakeholderHierarchy.msilQuery.size() > 0) {
            hierarchyList = stakeholderHierarchy.msilQuery;
        }
        if (hierarchyList.size() > 0) {
            for (StakeholderHierarchy.Sales holder : hierarchyList) {
                if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L4 && holder.recordId != '') {
                    caseActions.Transferred_Dealer_Approver__c = holder.recordId;
                } else if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L5 && holder.recordId != '') {
                    caseActions.Transferred_Dealer_L5__c = caseActions.L5_Stakeholder__c;
                }
            }
        }
    }

    private static Map<Id, Account> getDealerMap(Set<Id> dealerIds) {
        Map<Id, Account> dealerMap = new Map<Id, Account>(
        [
                SELECT Id,Primary_QCM__c,Territory_Sales_Manager__c,Stakeholder_Hierarchy__c
                FROM Account
                WHERE Id IN:dealerIds
        ]
        );
        return dealerMap;
    }

    private static Id getCategoryId(Case_Actions__c caseActions) {
        String categoryId;
        if (caseActions.Tertiary_Category_ID__c != null) {
            categoryId = caseActions.Tertiary_Category_ID__c;
        } else if (caseActions.Secondary_Category_ID__c != null) {
            categoryId = caseActions.Secondary_Category_ID__c;
        } else if (caseActions.Primary_Category_ID__c != null) {
            categoryId = caseActions.Primary_Category_ID__c;
        }
        return categoryId;
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method will added user read access to the related case for the transfer type case action
        History:
        ===============================================================
        1.0     27 July 2020      Deepak     Initial Version
	*/
    public void updateCaseAccessForTransferCaseActions() {
        try {
            // This Map will help to make the case access as per user.
            Map<Id, Map<Id, String>> caseIdVsUserIdAndAccessTypeMap = new Map<Id, Map<Id, String>>();
            Map<Id, List<Id>> caseIdVsUserIdMap = new Map<Id, List<Id>>();
            for (Case_Actions__c caseActions : newCaseActionList) {
                if (caseActions.RecordTypeId == ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID) {
                    /** If the  Transferred_Dealer_Approver__c is from different region adding the current case asses*/
                    if (caseActions.Transferred_Dealer_Approver__c != caseActions.L4_Stakeholder__c && caseActions.Approval_Status__c == ConstantsUtility.In_Progress && caseActions.Current_Approver__c == caseActions.Transferred_Dealer_Approver__c) {
                        Map<Id, String> userIdVsAccessTypeMap = new Map<Id, String>();
                        userIdVsAccessTypeMap.put(caseActions.Transferred_Dealer_Approver__c, ConstantsUtility.CASE_READ_ACCESS);
                        userIdVsAccessTypeMap.put(caseActions.Transferred_Dealer_L5__c, ConstantsUtility.CASE_READ_ACCESS);
                        if (caseIdVsUserIdAndAccessTypeMap.containsKey(caseActions.Case_Number__c)) {
                            Map<Id, String> userIdVsAccessTypeTempMap = caseIdVsUserIdAndAccessTypeMap.get(caseActions.Case_Number__c);
                            userIdVsAccessTypeTempMap.put(caseActions.Transferred_Dealer_Approver__c, ConstantsUtility.CASE_READ_ACCESS);
                            userIdVsAccessTypeTempMap.put(caseActions.Transferred_Dealer_L5__c, ConstantsUtility.CASE_READ_ACCESS);
                            // userIdVsAccessTypeTempMap.put(caseActions.Tra,ConstantsUtility.CASE_READ_ACCESS);
                        }
                        caseIdVsUserIdAndAccessTypeMap.put(caseActions.Case_Number__c, userIdVsAccessTypeMap);
                        /** Removing the case from from the Transferred_Dealer_Approver and  Transferred_Dealer_L5*/
                    } else if (caseActions.Approval_Status__c == ConstantsUtility.In_Progress && caseActions.Transferred_Dealer_Approver__c != null && caseActions.Current_Approver__c == caseActions.L4_Stakeholder__c) {
                        if (!caseIdVsUserIdMap.containsKey(caseActions.Case_Number__c)) {
                            caseIdVsUserIdMap.put(caseActions.Case_Number__c, new List<Id>());
                        }
                        caseIdVsUserIdMap.get(caseActions.Case_Number__c).add(caseActions.Transferred_Dealer_Approver__c);
                        caseIdVsUserIdMap.get(caseActions.Case_Number__c).add(caseActions.Transferred_Dealer_L5__c);
                    }
                }
            }
            if (!caseIdVsUserIdAndAccessTypeMap.isEmpty()) {
                // Calling CaseSharingService method to get the CaseTeamMember List to insert
                List<CaseTeamMember> caseTeamMembers = CaseSharingService.updateCaseTeamMembers(caseIdVsUserIdAndAccessTypeMap);
                if (caseTeamMembers != null && caseTeamMembers.size() > 0) {
                    Database.insert(caseTeamMembers, false);
                }
            }
            if (!caseIdVsUserIdMap.isEmpty()) {
                // Calling method to remove the accsess
                Boolean deleteResult = CaseSharingService.deleteCaseTeamMembers(caseIdVsUserIdMap);
                System.debug('deleteResult ' + deleteResult);

            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage(), 'updateCaseAccessForTransferCaseActions', '', null);
        }
    }


    /**
        Author: Anas Yar Khan
        Company: Techmatrix Consulting
        Description: This method is used to create MC Communication records
	*/
    public void createMCCommunicationRecordMOSEscalation() {
        try {
            List<MC_Communication__c> listMCCommunicatinRecordsToInsert = new List<MC_Communication__c>(); //list to store MC records to insert
            Set<Id> setCaseId = new Set<Id>();         //Set to store case Id
            Map<Id, Case> mapIdToCase = new Map<Id, Case>();   //Map to store Case in a  map
            List<MC_Communication__c> listMCCommunicationToUpdate = new List<MC_Communication__c>(); //List to store mc records to update
            Set<Id> setCaseActionId = new Set<Id>();      //Set to store caseAction Id
            Set<Id> setActiveCaseActionId = new Set<Id>(); //Set to store active case action Id
            //iterating over Trigger New
            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (caseActionObj.RecordTypeId != NULL && caseActionObj.RecordTypeId == ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id && caseActionObj.Case_Number__c != NULL) {
                    setCaseId.add(caseActionObj.Case_Number__c);
                }
            }
            //Getting case in a map
            if (setCaseId.size() > 0) {
                Map<String, Schema.SObjectField> fieldMap = Case.sObjectType.getDescribe().fields.getMap();
                Set<String> fieldNames = fieldMap.keySet();
                for (Case caseObj : Database.query('SELECT ' + String.join(new List<String>(fieldNames), ',') + ' FROM Case WHERE Id IN : setCaseId')) {
                    mapIdToCase.put(caseObj.Id, caseObj);
                }
            }

            if (mapIdToCase != NULL && mapIdToCase.keySet().size() > 0) {
                for (Case_Actions__c caseActionObj : newCaseActionList) {
                    if (caseActionObj.RecordTypeId != NULL && caseActionObj.RecordTypeId == ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id) {
                        if (trigger.isInsert) {
                            listMCCommunicatinRecordsToInsert.add(CaseActionTriggerHelper.getMCCommunicationRecord(caseActionObj, mapIdToCase));

                        } else if (trigger.isUpdate) {
                            if ((caseActionObj.Escalation_Level__c != NULL && caseActionObj.Escalation_Level__c != oldCaseActionMap.get(caseActionObj.Id).Escalation_Level__c)
                                    || (caseActionObj.Escalation_Status__c != NULL && caseActionObj.Escalation_Status__c != oldCaseActionMap.get(caseActionObj.Id).Escalation_Status__c)
                                    || (caseActionObj.Escalation_Update__c != NULL && caseActionObj.Escalation_Update__c != oldCaseActionMap.get(caseActionObj.Id).Escalation_Update__c)) {
                                if (caseActionObj.Escalation_Status__c == ConstantsUtility.Case_Action_Escalation_Status_Active) {
                                    listMCCommunicatinRecordsToInsert.add(CaseActionTriggerHelper.getMCCommunicationRecord(caseActionObj, mapIdToCase));
                                }
                            }

                            if (caseActionObj.Escalation_Status__c == ConstantsUtility.Case_Action_Escalation_Status_Inactive && caseActionObj.Escalation_Status__c != oldCaseActionMap.get(caseActionObj.Id).Escalation_Status__c) {
                                setCaseActionId.add(caseActionObj.Id);
                            }

                            if (caseActionObj.Escalation_Status__c == ConstantsUtility.Case_Action_Escalation_Status_Active && caseActionObj.Escalation_Status__c != oldCaseActionMap.get(caseActionObj.Id).Escalation_Status__c) {
                                setActiveCaseActionId.add(caseActionObj.Id);
                            }
                        }
                    }
                }
            }
            //getting MC Records of Inactive case Action
            if (setCaseActionId.size() > 0) {
                for (MC_Communication__c mcRecord : [SELECT Id,Status__c FROM MC_Communication__c WHERE Case_Action__c IN :setCaseActionId AND Status__c = :ConstantsUtility.MC_Communication_Status_Queued]) {
                    mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Cancelled;
                    listMCCommunicationToUpdate.add(mcRecord);
                }
            }
            //Update MC records of Inactive case actions to Cancelled
            if (listMCCommunicationToUpdate.size() > 0) {
                TriggerHandler.bypass('MCCommunicationTriggerHandler');
                update listMCCommunicationToUpdate;
                TriggerHandler.clearbypass('MCCommunicationTriggerHandler');
            }

            List<Case_Actions__c> listCaseActionsToUpdate = new List<Case_Actions__c>();
            if (listMCCommunicatinRecordsToInsert.size() > 0) {
                insert listMCCommunicatinRecordsToInsert;

                for (MC_Communication__c mcRecord : [SELECT Id,Case_Action__c FROM MC_Communication__c WHERE Id IN :listMCCommunicatinRecordsToInsert]) {
                    Case_Actions__c caseObjNew = new Case_Actions__c();
                    caseObjNew.Id = mcRecord.Case_Action__c;
                    caseObjNew.MC_Communication__c = mcRecord.Id;
                    if (setActiveCaseActionId.size() > 0 && setActiveCaseActionId.contains(mcRecord.Case_Action__c)) {
                        caseObjNew.Escalation_Level__c = ConstantsUtility.Case_Action_Escalation_Level_Amber;
                    }
                    listCaseActionsToUpdate.add(caseObjNew);
                }
            }

            if (listCaseActionsToUpdate.size() > 0) {
                TriggerHandler.bypass('CaseActionsTriggerHandler');
                update listCaseActionsToUpdate;
                TriggerHandler.clearbypass('CaseActionsTriggerHandler');
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', e.getMessage() + ':' + e.getLineNumber(), 'MC Communication Record Creation', '', null);
        }
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix Consulting
        Description: This method is used to update the record Type of the case action if it is a Service Revalidation case action
	*/
    public void updateRevalidationRecordTypeIdServiceCases() {
        try {
            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (caseActionObj.RecordTypeId != NULL && caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID && caseActionObj.Revalidation_Type__c != null && caseActionObj.Revalidation_Type__c == ConstantsUtility.SERVICE_REVALIDATION) {
                    if (caseActionObj.Revalidation_Category__c != null && caseActionObj.Revalidation_Category__c == ConstantsUtility.UNJUSTIFIED_COMPLAINT_REVALIDATION) {
                        caseActionObj.RecordTypeId = ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID;
                        caseActionObj.Name = ConstantsUtility.UNJUSTIFIED_COMPLAINT_REVALIDATION;
                    } else if (caseActionObj.Revalidation_Category__c != null && caseActionObj.Revalidation_Category__c == ConstantsUtility.PRODUCT_COMPLAINT_REVALIDATION) {
                        caseActionObj.RecordTypeId = ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID;
                        caseActionObj.Name = ConstantsUtility.PRODUCT_COMPLAINT_REVALIDATION;
                    }
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'updateRevalidationServiceCases', '', null);
        }

    }
    
    /**
        Author: Deepak Kumar
        Company: Techmatrix Consulting
        Description: This method is used provide the access of the case action to the all approver users.
	*/
    public void createCaseActionsShares() {
        try {


            MAp<Id, Case_Actions__Share> userIdVSharesMap = new Map<Id, Case_Actions__Share>();
            Map<Id, List<String>> caseActionIdVsApproverIdsMapIds = new Map<Id, List<String>>();

            Map<Id, Id> caseActionIdVsCaseIdMap = new Map<Id, Id>();
            for (Case_Actions__c caseActions : this.newCaseActionList) {
                if (caseActions.Case_Actions_Visibilities_IDs__c != null && caseActions.Case_Number__c != null) {
                    caseActionIdVsApproverIdsMapIds.put(caseActions.Id, caseActions.Case_Actions_Visibilities_IDs__c.split(';'));
                    caseActionIdVsCaseIdMap.put(caseActions.Id, caseActions.Case_Number__c);
                }
            }


            // Getting all case team members
            Map<Id, List<String>> caseIdVsMembersMap = new Map<Id, List<String>>();
            for (CaseTeamMember caseTeamMember : [SELECT Id,MemberId,ParentId FROM CaseTeamMember WHERE ParentId IN:caseActionIdVsCaseIdMap.values()]) {
                if (!caseIdVsMembersMap.containsKey(caseTeamMember.ParentId)) {
                    caseIdVsMembersMap.put(caseTeamMember.ParentId, new List<String>());
                }
                caseIdVsMembersMap.get(caseTeamMember.ParentId).add(caseTeamMember.MemberId);
            }
            for (Id caseActionId : caseActionIdVsApproverIdsMapIds.keySet()) {

                for (String approverId : caseActionIdVsApproverIdsMapIds.get(caseActionId)) {
                    // Add share logic
                    Case_Actions__Share caseActionshare = new Case_Actions__Share();
                    caseActionshare.ParentId = caseActionId;
                    caseActionshare.AccessLevel = 'Edit';
                    caseActionshare.UserOrGroupId = approverId;
                    userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                }

                // Case members addition ro case actions
                Id caseId = caseActionIdVsCaseIdMap.get(caseActionId);
                if (caseIdVsMembersMap.get(caseId) != null && caseIdVsMembersMap.get(caseId).size() > 0) {
                    for (String approverId : caseIdVsMembersMap.get(caseId)) {
                        // Add share logic
                        Case_Actions__Share caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActionId;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = approverId;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }
                }
            }

            // For Service Revalidation added access to the users
            for (Case_Actions__c caseActions : this.newCaseActionList) {
                if (caseActions.Case_Number__c != null && (caseActions.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID ||
                        caseActions.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID)) {

                    Case_Actions__Share caseActionshare = new Case_Actions__Share();

                    //  caseActionshare.UserOrGroupId = approverId;
                    if (caseActions.L6B_Stakeholder__c != null) {
                        caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActions.Id;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = caseActions.L6B_Stakeholder__c;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }if (caseActions.L8A_Stakeholder__c != null) {
                        caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActions.Id;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = caseActions.L8A_Stakeholder__c;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }if (caseActions.L8B_Stakeholder__c != null) {
                        caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActions.Id;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = caseActions.L8B_Stakeholder__c;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }if (caseActions.L8C_Stakeholder__c != null) {
                        caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActions.Id;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = caseActions.L8C_Stakeholder__c;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }if (caseActions.L8D_Stakeholder__c != null) {
                        caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActions.Id;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = caseActions.L8D_Stakeholder__c;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }if (caseActions.L8E_Stakeholder__c != null) {
                        caseActionshare = new Case_Actions__Share();
                        caseActionshare.ParentId = caseActions.Id;
                        caseActionshare.AccessLevel = 'Edit';
                        caseActionshare.UserOrGroupId = caseActions.L8E_Stakeholder__c;
                        userIdVSharesMap.put(caseActionshare.UserOrGroupId, caseActionshare);
                    }
                }
            }
            //Insert case actions share records
            if (!userIdVSharesMap.isEmpty()) {
                Database.insert(userIdVSharesMap.values(), false);
            }
        } catch (Exception exp) {
            System.debug('Exception Message ' + exp.getMessage() + ' ::: ' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'createCaseActionsShares', '', null);
        }

    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix Consulting
        Description:
	*/
    public void copyClosureFields() {
        try {
            Set<Id> caseIds = new Set<Id>();
            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (caseActionObj.Case_Number__c != null && (caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID ||
                        caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID)) {
                    caseIds.add(caseActionObj.Case_Number__c);
                }
            }
            if (caseIds.size() > 0) {
                Map<Id, Case_Actions__c> caseIdVsCaseActionsMap = new Map<Id, Case_Actions__c>();
                for (Case_Actions__c actions : [
                        SELECT Case_Number__c,Observation_1__c,Observation_2__c,Observation_3__c,Action_Taken_1__c,Action_Taken_2__c,Action_Taken_3__c,
                                Counter_Measure_Taken_1__c,Counter_Measure_Taken_2__c,Counter_Measure_Taken_3__c,Related_SAS_Number__c,Workshop_Reason__c
                        FROM Case_Actions__c
                        WHERE RecordTypeId = :ConstantsUtility.Service_Complaint_Closure_CASE_ACTION_RECORD_TYPE_ID AND Case_Number__c IN:caseIds
                ]) {
                    caseIdVsCaseActionsMap.put(actions.Case_Number__c, actions);
                }
                if (!caseIdVsCaseActionsMap.isEmpty()) {
                    for (Case_Actions__c caseActionObj : newCaseActionList) {
                        if (caseActionObj.Case_Number__c != null && (caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID ||
                                caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID) && caseIdVsCaseActionsMap.containsKey(caseActionObj.Case_Number__c)) {
                            Case_Actions__c closureCaseAction = caseIdVsCaseActionsMap.get(caseActionObj.Case_Number__c);
                            caseActionObj.Observation_1__c = closureCaseAction.Observation_1__c;
                            caseActionObj.Observation_2__c = closureCaseAction.Observation_2__c;
                            caseActionObj.Observation_3__c = closureCaseAction.Observation_3__c;
                            caseActionObj.Action_Taken_1__c = closureCaseAction.Action_Taken_1__c;
                            caseActionObj.Action_Taken_2__c = closureCaseAction.Action_Taken_2__c;
                            caseActionObj.Action_Taken_3__c = closureCaseAction.Action_Taken_3__c;
                            caseActionObj.Counter_Measure_Taken_1__c = closureCaseAction.Counter_Measure_Taken_1__c;
                            caseActionObj.Counter_Measure_Taken_2__c = closureCaseAction.Counter_Measure_Taken_2__c;
                            caseActionObj.Counter_Measure_Taken_3__c = closureCaseAction.Counter_Measure_Taken_3__c;
                            caseActionObj.Related_SAS_Number__c = closureCaseAction.Related_SAS_Number__c;
                            caseActionObj.Workshop_Reason__c = closureCaseAction.Workshop_Reason__c;
                        }
                    }
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'copyClosureFields', '', null);
        }

    }
    
    /**
        Author: Deepak Kumar
        Company: Techmatrix Consulting
        Description: This method is to chech the validations related to Unjustified Revalidation
	*/
    public void serviceUnjustifiedRevalidationValidation() {
        try {
            Set<Id> caseIds = new Set<Id>();
            for (Case_Actions__c caseActionObj : newCaseActionList) {
                if (caseActionObj.Case_Number__c != null && caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID) {
                    caseIds.add(caseActionObj.Case_Number__c);
                }
            }
            if (caseIds.size() > 0) {
                Map<Id, Case_Actions__c> caseIdVsCaseActionsMap = new Map<Id, Case_Actions__c>();
                for (Case_Actions__c actions : [
                        SELECT Case_Number__c, Approval_Status__c,L4_Stakeholder__c
                        FROM Case_Actions__c
                        WHERE RecordTypeId = :ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID AND Case_Number__c IN:caseIds
                        ORDER BY LastModifiedDate ASC
                ]) {
                    caseIdVsCaseActionsMap.put(actions.Case_Number__c, actions);
                }
                if (!caseIdVsCaseActionsMap.isEmpty()) {
                    for (Case_Actions__c caseActionObj : newCaseActionList) {
                        if (caseIdVsCaseActionsMap.get(caseActionObj.Case_Number__c) != null) {
                            Case_Actions__c oldCaseActions = caseIdVsCaseActionsMap.get(caseActionObj.Case_Number__c);
                            if (oldCaseActions.Approval_Status__c == ConstantsUtility.Rejected && UserInfo.getUserId() != caseActionObj.L4_Stakeholder__c) {
                                // Re-Submitting The Request
                                caseActionObj.addError(System.Label.Unjustified_Revalidation_Initiation_User_Error);
                            } else if (oldCaseActions.Approval_Status__c != ConstantsUtility.Rejected) {
                                caseActionObj.addError(caseActionObj.Name + ' ' + System.Label.CASE_ACTION_DUP_ERROR_MSG);
                            }
                        }
                    }
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'serviceUnjustifiedRevalidationValidation', '', null);
        }

    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix Consulting
        Description: This method will be use to send the Custom notification on approval process.
    */
    public void sendCustomNotifications() {
        try {
            List<CustomNotificationType> customNotificationTypes = new List<CustomNotificationType>();
            customNotificationTypes = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :Label.ATM_Custom_Approval_Notification_Name LIMIT 1];
            if (customNotificationTypes.size() > 0) {
                Set<Id> queueIds = new Set<Id>();

                for (Case_Actions__c caseActionObj : newCaseActionList) {
                    Set<String> users = new Set<String>();
                    if (caseActionObj.Case_Number__c != null && (caseActionObj.Current_Approver__c != null && oldCaseActionMap.get(caseActionObj.Id).Current_Approver__c != caseActionObj.Current_Approver__c)
                            || (caseActionObj.Approved_Rejection_Notifiers__c != null && oldCaseActionMap.get(caseActionObj.Id).Approved_Rejection_Notifiers__c != caseActionObj.Approved_Rejection_Notifiers__c)) {

                        if (oldCaseActionMap.get(caseActionObj.Id).Approved_Rejection_Notifiers__c != caseActionObj.Approved_Rejection_Notifiers__c && caseActionObj.Approval_Status__c == ConstantsUtility.In_Progress) {
                            // Current status notification to to other users
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setTitle(caseActionObj.Approval_Chatter_Title__c);
                            notification.setBody(caseActionObj.Approval_Chatter_Message__c);
                            notification.setSenderId(UserInfo.getUserId());
                            notification.setNotificationTypeId(customNotificationTypes[0].Id);
                            notification.setTargetId(caseActionObj.Id); // target object id
                            List<String> notifiers = new List<String>();

                            for (String str : caseActionObj.Approved_Rejection_Notifiers__c.split(ConstantsUtility.COMMA)) {
                                str = str.trim();
                                if (str != null && str != '') {
                                    users.add(str);
                                }
                            }
                            if (users.size() > 0) {
                                notification.send(users);
                            }
                        }
                        // Need to Send the Custom Notifications //2
                        if (oldCaseActionMap.get(caseActionObj.Id).Current_Approver__c != caseActionObj.Current_Approver__c && caseActionObj.Current_Approver__c != caseActionObj.L1_Stakeholder__c && caseActionObj.Approval_Status__c == ConstantsUtility.In_Progress && !users.contains(caseActionObj.Current_Approver__c)) {
                            // Process Initiation Notification to next approver
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setTitle(caseActionObj.Initiation_Notification_Title__c);
                            notification.setBody(caseActionObj.Initiation_Notification_Message__c);
                            notification.setSenderId(UserInfo.getUserId());
                            notification.setNotificationTypeId(customNotificationTypes[0].Id);
                            notification.setTargetId(caseActionObj.Id); // target object id
                            if (caseActionObj.Current_Approver__c.startsWith(ConstantsUtility.UserPrefix)) {
                                notification.send(new Set<String>{
                                        caseActionObj.Current_Approver__c
                                });
                            }
                        }
                    }
                    // Revalidation Deviation Scenario //3
                    if (caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID && oldCaseActionMap.get(caseActionObj.Id).Approval_Status__c == ConstantsUtility.Pending_Ringi_Approval) {
                        // users.clear();
                        //sys
                        if (caseActionObj.L2A_Stakeholder__c != null) {
                            users.add(caseActionObj.L2A_Stakeholder__c);
                        }if (caseActionObj.L3A_Stakeholder__c != null) {
                            users.add(caseActionObj.L3A_Stakeholder__c);
                        }if (caseActionObj.L4_Stakeholder__c != null) {
                            users.add(caseActionObj.L4_Stakeholder__c);
                        }if (caseActionObj.L5_Stakeholder__c != null) {
                            users.add(caseActionObj.L5_Stakeholder__c);
                        }if (caseActionObj.L6A_Stakeholder__c != null) {
                            users.add(caseActionObj.L6A_Stakeholder__c);
                        }
                        if (users.size() > 0) {
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setTitle(caseActionObj.Approval_Chatter_Title__c);
                            notification.setBody(caseActionObj.Approval_Chatter_Message__c);
                            notification.setSenderId(UserInfo.getUserId());
                            notification.setNotificationTypeId(customNotificationTypes[0].Id);
                            notification.setTargetId(caseActionObj.Id); // target object id
                            notification.send(users);
                        }
                    }
                    // 4 -- If owner of the record Assigned to Queue
                    if (String.valueOf(caseActionObj.OwnerId).startsWith('00G') && oldCaseActionMap.get(caseActionObj.Id).OwnerId != caseActionObj.OwnerId) {
                        queueIds.add(caseActionObj.OwnerId);
                    }
                }
                if (queueIds.size() > 0) { // If owner of the record Assigned to Queue
                    Map<Id, Set<String>> queueIdVsUsersMap = getQueueMembersMap(queueIds);
                    if (!queueIdVsUsersMap.isEmpty()) {
                        for (Case_Actions__c caseActionObj : newCaseActionList) {
                            if (String.valueOf(caseActionObj.OwnerId).startsWith('00G') && oldCaseActionMap.get(caseActionObj.Id).OwnerId != caseActionObj.OwnerId) {
                                if (queueIdVsUsersMap.containsKey(caseActionObj.OwnerId)) {
                                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                                    notification.setTitle(caseActionObj.Approval_Chatter_Title__c);
                                    notification.setBody(caseActionObj.Approval_Chatter_Message__c);
                                    notification.setSenderId(UserInfo.getUserId());
                                    notification.setNotificationTypeId(customNotificationTypes[0].Id);
                                    notification.setTargetId(caseActionObj.Id); // target object id
                                    List<String> notifiers = new List<String>();
                                    Set<String> users = new Set<String>();
                                    for (String str : queueIdVsUsersMap.get(caseActionObj.OwnerId)) {
                                        str = str.trim();
                                        if (str != null && str != '') {
                                            users.add(str);
                                        }
                                    }
                                    if (users.size() > 0) {
                                        notification.send(users);
                                    }
                                }
                            }
                        }
                    }
                }


            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'sendCustomNotifications', '', null);
        }

    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix Consulting
        Description: This method will be used to send the Custom notification on approval process to others users then current approvers.
   */
    public void sendChatterNotifications() {
        try {
            Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();

            Map<Id, Set<String>> escalationUsersInit = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMapInit = new Map<Id, String>();

            Set<Id> queueIds = new Set<Id>();

            for (Case_Actions__c caseActionObj : newCaseActionList) {
                Set<String> users = new Set<String>();
                // 1 // to other users Approve/Reject
                if (caseActionObj.Approval_Status__c == ConstantsUtility.In_Progress && caseActionObj.Approved_Rejection_Notifiers__c != null && oldCaseActionMap.get(caseActionObj.Id).Approved_Rejection_Notifiers__c != caseActionObj.Approved_Rejection_Notifiers__c) {
                    for (String str : caseActionObj.Approved_Rejection_Notifiers__c.split(ConstantsUtility.COMMA)) {
                        str = str.trim();
                        if (str != null && str != '') {
                            users.add(str);
                            System.debug('users >>' + users);
                        }
                    }
                    if (users.size() > 0) {
                        recordIdVsMessageMap.put(caseActionObj.Id, caseActionObj.Approval_Chatter_Message__c);
                        escalationUsers.put(caseActionObj.Id, users);
                        System.debug(escalationUsers);
                    }
                }
                // 2 TO Next approved only in approval case
                System.debug(caseActionObj.Approval_Status__c);
                if (caseActionObj.Approval_Status__c == ConstantsUtility.In_Progress && caseActionObj.Current_Approver__c != null && oldCaseActionMap.get(caseActionObj.Id).Current_Approver__c != caseActionObj.Current_Approver__c
                        && !users.contains(caseActionObj.Current_Approver__c)) {
                    // Process Initiation Notification to next approver

                    //users.add(caseActionObj.Current_Approver__c);
                    escalationUsersInit.put(caseActionObj.Id, new Set<String>{
                            caseActionObj.Current_Approver__c
                    });
                    System.debug(escalationUsersInit);
                    recordIdVsMessageMapInit.put(caseActionObj.Id, caseActionObj.Initiation_Notification_Message__c);
                }
                // Revalidation Deviation Scenario //3
                if (caseActionObj.RecordTypeId == ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID && oldCaseActionMap.get(caseActionObj.Id).Approval_Status__c == ConstantsUtility.Pending_Ringi_Approval) {
                    // users.clear();
                    //sys
                    if (caseActionObj.L2A_Stakeholder__c != null) {
                        users.add(caseActionObj.L2A_Stakeholder__c);
                    }if (caseActionObj.L3A_Stakeholder__c != null) {
                        users.add(caseActionObj.L3A_Stakeholder__c);
                    }if (caseActionObj.L4_Stakeholder__c != null) {
                        users.add(caseActionObj.L4_Stakeholder__c);
                    }if (caseActionObj.L5_Stakeholder__c != null) {
                        users.add(caseActionObj.L5_Stakeholder__c);
                    }if (caseActionObj.L6A_Stakeholder__c != null) {
                        users.add(caseActionObj.L6A_Stakeholder__c);
                    }
                    if (users.size() > 0) {
                        escalationUsers.put(caseActionObj.Id, users);
                        recordIdVsMessageMap.put(caseActionObj.Id, caseActionObj.Approval_Chatter_Message__c);
                    }
                }
                // 4 -- If owner of the record Assigned to Queue
                if (String.valueOf(caseActionObj.OwnerId).startsWith('00G') && oldCaseActionMap.get(caseActionObj.Id).OwnerId != caseActionObj.OwnerId) {
                    // users.clear();
                    queueIds.add(caseActionObj.OwnerId);

                }
            }

            if (queueIds.size() > 0) {
                Map<Id, Set<String>> queueIdVsUsersMap = getQueueMembersMap(queueIds);
                if (queueIdVsUsersMap != null && !queueIdVsUsersMap.isEmpty()) {
                    system.debug('fffff');
                    for (Case_Actions__c caseActionObj : newCaseActionList) {
                        if (String.valueOf(caseActionObj.OwnerId).startsWith('00G') && oldCaseActionMap.get(caseActionObj.Id).OwnerId != caseActionObj.OwnerId) {
                            if (queueIdVsUsersMap.containsKey(caseActionObj.OwnerId)) {
                                escalationUsers.put(caseActionObj.Id, queueIdVsUsersMap.get(caseActionObj.OwnerId));
                                recordIdVsMessageMap.put(caseActionObj.Id, caseActionObj.Initiation_Notification_Message__c);
                            }
                        }
                    }
                }
            }
            System.debug('Next ' + escalationUsersInit);
            System.debug('Ohter Message ' + escalationUsers);
            if (!recordIdVsMessageMapInit.isEmpty() && !escalationUsersInit.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(escalationUsersInit, recordIdVsMessageMapInit);
            }
            if (!recordIdVsMessageMap.isEmpty() && !escalationUsers.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
            }


        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'sendChatterNotifications', '', null);
        }
    }
    
    
    
    
    public static Map<Id, Set<String>> getQueueMembersMap(Set<Id> queueIds) {
        Map<Id, Set<String>> queueIdVsUsersMap = new Map<Id, Set<String>>();
        for (GroupMember member : [select UserOrGroupId,GroupId from GroupMember where GroupId IN:queueIds]) {
            if (String.valueOf(member.UserOrGroupId).startsWith(ConstantsUtility.UserPrefix)) {
                if (!queueIdVsUsersMap.containsKey(member.GroupId)) {
                    queueIdVsUsersMap.put(member.GroupId, new Set<String>());
                }
                queueIdVsUsersMap.get(member.GroupId).add(member.UserOrGroupId);
            }
        }
        return queueIdVsUsersMap;
    }

    /**
      Author: Deepak Kumar
      Company: Techmatrix Consulting
      Description: This method will be used to send the SMS and Email to the stakeholders during the Approval process
                    using the MC Communication records
      */
    public void sendEmailSMSApproval() {
        system.debug('sendEmailSMSApproval--RECUSRION--');
        if(AvoidRecursion.isAfterRun()){
            try {
                List<Case_Actions__c> caseActionWithNotifiers = new List<Case_Actions__c>();
                for (Case_Actions__c caseActionObj : newCaseActionList) {
                    if (caseActionObj.Approval_Email_Notifiers__c != null && oldCaseActionMap.get(caseActionObj.Id).Approval_Email_Notifiers__c != caseActionObj.Approval_Email_Notifiers__c) {
                        caseActionWithNotifiers.add(caseActionObj);
                    }
                }
                // Case Actions with Notifiers changes
                if (!caseActionWithNotifiers.isEmpty()) {
                    Map<String, Case_Approvals_SMS_Email_Matrix__mdt> approvalsSmsEmailMatricesMap = getApprovalsSmsEmailMatricesMap();
                    if (!approvalsSmsEmailMatricesMap.isEmpty()) {
                        Set<String> relatedStakeholderIds = new Set<String>();
                        for (Case_Actions__c caseActionObj : caseActionWithNotifiers) {
                            Set<String> stakeHolders = new Set<String>();
                            // Splitting the Approval_Email_Notifiers__c for SMS and Email
                            for (String notification : caseActionObj.Approval_Email_Notifiers__c.split(',')) {
                                Case_Approvals_SMS_Email_Matrix__mdt approvalsSmsEmailMatrix = approvalsSmsEmailMatricesMap.get(notification);
                                Set<String> toHolders = getListFromString(approvalsSmsEmailMatrix.To_Recipient__c); // TO Stake Holders
                                Set<String> ccHolders = getListFromString(approvalsSmsEmailMatrix.CC_Recipients__c); // CC Stake Holders
                                Set<String> smsHolders = getListFromString(approvalsSmsEmailMatrix.SMS_Notifiers__c); // SMS Stake Holders
                                stakeHolders.addAll(toHolders);
                                stakeHolders.addAll(ccHolders);
                                stakeHolders.addAll(smsHolders);
                                if (!stakeHolders.isEmpty()) {
                                    relatedStakeholderIds.addAll(getStakeHoldersUserId(stakeHolders, caseActionObj));
                                }
                            }
                        }
                        
                        if (!relatedStakeholderIds.isEmpty()) {
                            Map<Id, User> usersMap = getUsersByIds(relatedStakeholderIds);
                            // MC Communications List to insert
                            List<MC_Communication__c> mcCommunications = new List<MC_Communication__c>();
                            // Iterating to create the MC Communication Records
                            for (Case_Actions__c caseActionObj : caseActionWithNotifiers) {
                                Set<String> stakeHolders = new Set<String>();
                                // Splitting the Approval_Email_Notifiers__c for SMS and Email
                                for (String notification : caseActionObj.Approval_Email_Notifiers__c.split(',')) {
                                    MC_Communication__c mcCommunication = new MC_Communication__c();
                                    mcCommunication.Case__c = caseActionObj.Case_Number__c;
                                    mcCommunication.Status__c = ConstantsUtility.MC_Communication_Status_Queued;
                                    
                                    Case_Approvals_SMS_Email_Matrix__mdt approvalsSmsEmailMatrix = approvalsSmsEmailMatricesMap.get(notification);
                                    if (approvalsSmsEmailMatrix.Communication_Type__c == ConstantsUtility.EMAIL) {
                                        // For EMAIL COMMUNICATION
                                        mcCommunication.Communication_Type__c = approvalsSmsEmailMatrix.Communication_Type__c;
                                        mcCommunication.Type__c = approvalsSmsEmailMatrix.Notification_Type__c;
                                        
                                        Set<String> toHolders = getListFromString(approvalsSmsEmailMatrix.To_Recipient__c); // TO Stake Holders
                                        Set<String> toUserIds = toHolders != null ? getStakeHoldersUserId(toHolders, caseActionObj) : new Set<String>();
                                        mcCommunication.To_Address__c = getEmails(toUserIds, usersMap);
                                        Set<String> ccHolders = getListFromString(approvalsSmsEmailMatrix.CC_Recipients__c); // CC Stake Holders
                                        Set<String> ccUserIds = ccHolders != null ? getStakeHoldersUserId(ccHolders, caseActionObj) : new Set<String>();
                                        mcCommunication.CC_Address__c = getEmails(ccUserIds, usersMap);
                                        mcCommunications.add(mcCommunication);
                                        
                                    } else {
                                        // For SMS COMMUNICATION
                                        mcCommunication.Communication_Type__c = approvalsSmsEmailMatrix.Communication_Type__c;
                                        mcCommunication.Type__c = approvalsSmsEmailMatrix.Notification_Type__c;
                                        
                                        Set<String> smsHolders = getListFromString(approvalsSmsEmailMatrix.SMS_Notifiers__c); // SMS Stake Holders
                                        Set<String> smsUserIds = smsHolders != null ? getStakeHoldersUserId(smsHolders, caseActionObj) : new Set<String>();
                                        mcCommunication.Recipient_Phone_Numbers__c = getPhoneNumbers(smsUserIds, usersMap);
                                        mcCommunications.add(mcCommunication);
                                    }
                                }
                            }
                            // Inserting the MC Communications records
                            if (!mcCommunications.isEmpty()) {
                                insert mcCommunications;
                            }
                        }
                    }
                }
            } catch (Exception exp) {
                ExceptionHandler.LogError('CaseActionsTriggerHandler', exp.getMessage(), 'sendEmailSMSApproval', '', null);
            }
        }

    }

    private static Map<String, Case_Approvals_SMS_Email_Matrix__mdt> getApprovalsSmsEmailMatricesMap() {
        Map<String, Case_Approvals_SMS_Email_Matrix__mdt> approvalsSmsEmailMatricesMap = new Map<String, Case_Approvals_SMS_Email_Matrix__mdt>();
        for (Case_Approvals_SMS_Email_Matrix__mdt approvalsSmsEmailMatrix : [SELECT CC_Recipients__c,Communication_Type__c,DeveloperName, Notification_Type__c, SMS_Notifiers__c, To_Recipient__c FROM Case_Approvals_SMS_Email_Matrix__mdt]) {
            approvalsSmsEmailMatricesMap.put(approvalsSmsEmailMatrix.DeveloperName, approvalsSmsEmailMatrix);
        }
        return approvalsSmsEmailMatricesMap;
    }
    
    private static Set<String> getStakeHoldersUserId(Set<String> stakeHolders, Case_Actions__c caseActionObj) {
        Set<String> userIds = new Set<String>();
        for (String stakeholder : stakeHolders) {
            if (caseActionObj.get(stakeholder) != null) {
                userIds.add(String.valueOf(caseActionObj.get(stakeholder)));
            }
        }
        return userIds;
    }
    
    private static Map<Id, User> getUsersByIds(Set<String> userIds) {
        Map<Id, User> userMap = new Map<Id, User>([SELECT Phone,Email FROM User WHERE Id IN:userIds]);
        return userMap;
    }
    
    private static String getEmails(Set<String> userIds, Map<Id, User> userMap) {
        system.debug('userIds==>'+userIds);
        List<String> emails = new List<String>();
        for (String userId : userIds) {
            if(userMap.containsKey(userId) && userMap.get(userId)!=null)
            	emails.add(userMap.get(userId).Email);
        }
        return String.join(emails, ConstantsUtility.COMMA);
    }
    
    private static String getPhoneNumbers(Set<String> userIds, Map<Id, User> userMap) {
        List<String> emails = new List<String>();
        for (String userId : userIds) {
            if (userMap.get(userId).Phone != null) {
                emails.add(userMap.get(userId).Phone);
            }
        }
        return String.join(emails, ConstantsUtility.COMMA);
    }
    private static Set<String> getListFromString(String inputStr) {
        Set<String> stringSet = new Set<String>();
        if (inputStr != null && inputStr.trim() != '') {
            stringSet.addAll(inputStr.split(ConstantsUtility.COMMA));
        }
        return stringSet;
    }
    
    
}