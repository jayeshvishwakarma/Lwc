/**
* @File Name          : CaseTriggerStrategyHelper.cls
* @Description        : Strategy class for case trigger
* @Author             : Prabhat Sharma
* @Group              : 
* @Last Modified By   : Anas Yar Khan
* @Last Modified On   : 08/25/2020, 11:29:29 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM         Anas                Initial Version

**/
public without sharing class CaseTriggerStrategyHelper {
    Bypass_Setting__c bypassSetting = Bypass_Setting__c.getInstance(UserInfo.getUserId());
    private list<Case> newCaseList; //Used to store the list of new Cases
    //private static list<Case> newCaseList; //Used to store the list of new Cases
    private list<Case> oldCaseList; //Used to store the list of old Cases
    private map<Id, Case> oldCasemap;
    private map<Id, Case> newCaseMap;
    public static Id userAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('User_Account').getRecordTypeId();
    //Bulk Hold Object Record Type
    //public static Id bulkHoldCaseActionRecordTypeId = CaseTriggerHelper.fetchRecordTypeIdsByObject(ConstantsUtility.CASEACTIONS_OBJECT, ConstantsUtility.Bulk_Hold);
    public static Id RenewalRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
    public static Id vehicleserviceRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    public static Id dncRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
    set<Id> caseOwnerIdSet;
    Map<Id, Account> caseOwnerToUserAccountMap;
    public static List<Case> newCases = new List<Case>(); // new Cases or trigger.new
    public static Map<String, String> caseTypeVsHierarchyMap = new Map<String, String>(); // Map to store the key related Hierarchy type
    // Map to store the categoryId and related region and Recipient Master
    public static Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();
    private static CaseTriggerStrategyHelper instance = null;


    public CaseTriggerStrategyHelper() {
        caseOwnerIdSet = new set<Id>();
        caseOwnerToUserAccountMap = new Map<Id, Account>();
    }

    public static CaseTriggerStrategyHelper getInstance(List<Case> newCaseList, List<Case> oldCaseList, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {

        if (instance == null) instance = new CaseTriggerStrategyHelper();
        instance.newCaseList = newCaseList;
        instance.newCaseMap = newCaseMap;
        instance.oldCaseMap = oldCaseMap;
        instance.oldCaseList = oldCaseList;
        return instance;
    }
    /**
   Author: Sunit
   Company: Techmatrix
   Description: Method to mcCom Record
   Returns: void
   History:
   * Ver         Date                     Author                    Modification
   *==============================================================================
   * 1.0        4/09/2020                Gitika            Initial Version
   **/
    public void createMCRecordsForSuzukiConnect() {
        MCCommunicationService.suzukiConnectCaseCreationMcRecCreation(newCaseList);
    }

    /**
    Author: Sunit kumar chand
    Company: Techmatrix
    Description: This method is used to insert case record in PANA CRM
    Inputs:
    Returns:
    History:
    =================
    1.2     16 Nov 2020      Sunit     Initial Version
    */
    @Future(callout=true)
    public static void panaCRMRecordCreation(String caseData, String caseId) {
        System.debug('Inside panaCRMRecordCreation');
        System.debug(caseData);
        BasicReturn br = JITMuleSoftIntegration.genericJITCallWithoutContinuation('PanaCRM_Case_Creation', caseData, '', '');
        if (br.code == 200 || br.code == 201) {
            Case cs = new Case();
            cs.Id = caseId;
            cs.PanaCRM_Case_Creation_Status__c = 'Success';
            update cs;
        }
    }

    /**
   Author: Nitin
   Company: Techmatrix
   Description: This method is used to update Salesforce_External_Id__c with CaseNumber(Suzuki Connect Cases only)
   Inputs:
   Returns:
   History:
   =================
   1.2     16 Nov 2020      Nitin     Initial Version
   */
    public void updateSalesforceExternalId() {
        try {
            List<Case> updateCase = new List<Case>();
            for (Case cs : newCaseList) {
                if (cs.Business_Area__c == ConstantsUtility.ACCESSORIES_LINEOFBUSINESS &&
                        cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT && cs.Case_Stage__c == ConstantsUtility.CASE_STAGE_POST_SALES) {
                    Case csRec = new Case();
                    csRec.Id = cs.Id;
                    csRec.Salesforce_External_Id__c = cs.CaseNumber;
                    updateCase.add(csRec);
                }
            }
            if (updateCase.size() > 0) {
                database.update(updateCase, false);
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage() + ':' + e.getLineNumber(), 'updateSalesforceExternalId', '', null);
        }
    }

    /**
    Author: Sunit kumar chand
    Company: Techmatrix
    Description: This method is used to update staus of Suzuki connect case
    Inputs:
    Returns:
    History:
    =================
    1.2     06 Nov 2020      Sunit     Initial Version
    */
    public void suzukiConnectUpdate() {
        try {
            Constant_Value__c cv = ProjectUtility.getConstantValue('Suzuki Connect');
            Map<String, String> suzukiConnectMap = new Map<String, String>();
            for (Suzuki_Connect_Case_Status_Mapping__mdt suzukiConnect : [select Id,MasterLabel,Cast_Status__c from Suzuki_Connect_Case_Status_Mapping__mdt]) {
                suzukiConnectMap.put(suzukiConnect.MasterLabel, suzukiConnect.Cast_Status__c);
            }
            for (Case cs : newCaseList) {
                if (oldCaseMap.get(cs.Id).get('Job_Status__c') != cs.Job_Status__c && suzukiConnectMap.containsKey(cs.Job_Status__c)) {
                    cs.status = suzukiConnectMap.get(cs.Job_Status__c);
                    if (cs.status == 'Open') {
                        if (cs.Channel__c == 'Nexa') {
                            cs.OwnerId = cv.Nexa_Suzuki_Connect_Queue_Id__c;
                        } else if (cs.Channel__c == 'Arena') {
                            cs.OwnerId = cv.Arena_Suzuki_Connect_Queue_Id__c;
                        }
                    }
                } //RecordTye Check added because when Case is on Hold Next Esclation date need to removed(Nitin 13th Nov)
                if (cs.RecordTypeId == ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && (cs.Status == ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT || cs.Status == ConstantsUtility.CASE_STATUS_ON_HOLD)
                        && cs.Business_Area__c == ConstantsUtility.ACCESSORIES_LINEOFBUSINESS && oldCaseMap.get(cs.Id).Status != cs.Status &&
                        cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT && cs.Case_Stage__c == 'Post Sales') {
                    cs.Next_Escalation_Date__c = null;
                }
                System.debug(cs.RecordTypeId);
                System.debug(ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID);
                System.debug(oldCaseMap.get(cs.Id).get('Status'));
                System.debug(ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT);
                if (cs.RecordTypeId == ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && oldCaseMap.get(cs.Id).get('Status') == ConstantsUtility.CASE_STATUS_ON_HOLD &&
                        cs.Business_Area__c == ConstantsUtility.ACCESSORIES_LINEOFBUSINESS && oldCaseMap.get(cs.Id).Status != cs.Status &&
                        cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT && cs.Case_Stage__c == 'Post Sales') {
                    System.debug('Inside if');
                    cs.On_Hold_End_Date__c = System.today();
                    cs.IsStopped = false;
                }
            }

        } catch (Exception e) {
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage() + ':' + e.getLineNumber(), 'suzukiConnectUpdate', '', null);
        }
    }

    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: It will create case team as per owner's account team
Inputs:
Returns:
History:
=================
1.1A     06 June 2020      Sunit     Initial Version
*/
    public void caseTeamCreation() {

        System.debug('Inside caseTeamCreation');
        List<CaseTeamMember> ctmList = new List<CaseTeamMember>();

        for (Case cs : newCaseList) {
            if ((Trigger.isInsert == true || (Trigger.isUpdate == true && oldCaseMap.get(cs.Id).get('ownerid') != cs.ownerid))
                    && (cs.recordtypeid == RenewalRecTypeId || cs.recordtypeid == vehicleserviceRecTypeId
                    || cs.recordtypeid == dncRecTypeId)) {
                caseOwnerIdSet.add(cs.OwnerId);
            }
        }
        system.debug('userAccountRecordTypeId---' + userAccountRecordTypeId);
        if (caseOwnerIdSet.size() > 0) {
            List<Account> accList = [
                    select id,User__c,User__r.Contact.AccountID, (select userid from AccountTeamMembers)
                    From Account
                    WHERE RecordTypeId = :userAccountRecordTypeId AND User__c IN :caseOwnerIdSet
            ];
            for (Account acc : accList) {
                caseOwnerToUserAccountMap.put(acc.User__c, acc);
            }
            if (caseOwnerToUserAccountMap.size() > 0) {
                String teamRole = 'Agent team';
                CaseTeamRole role = [select Id from CaseTeamRole where Name = :teamRole limit 1];
                for (Case cs : newCaseList) {
                    if (caseOwnerToUserAccountMap.get(cs.ownerId) != null && caseOwnerToUserAccountMap.get(cs.ownerId).AccountTeamMembers.size() > 0) {
                        for (AccountTeamMember atm : caseOwnerToUserAccountMap.get(cs.ownerId).AccountTeamMembers) {
                            System.debug(atm.UserId);
                            //System.debug(caseOwnerCaseMapping.get(atm.UserId));
                            CaseTeamMember ctm = new CaseTeamMember();
                            ctm.ParentId = cs.Id;
                            ctm.MemberId = atm.UserId;
                            ctm.TeamRoleId = role.Id;
                            ctmList.add(ctm);
                        }
                    }
                }
            }
        }
        if (ctmList.size() > 0) {
            caseTeamDeletion(newCaseList);
            insert ctmList;
        }

    }
    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: It will delete case team
Inputs:
Returns:
History:
=================
1.1A     06 June 2020      Sunit     Initial Version
*/
    public void caseTeamDeletion(List<Case> caseList) {

        List <CaseTeamMember> ctmList = [Select Id from CaseTeamMember where ParentId IN:caseList];
        delete ctmList;
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to mark query as spam and create Spam Case Action.
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        28/07/2020                Gitika            Initial Version
**/
    public void markQueryAsSpam() {
        list<case_Actions__c> listTOInsert = new list<case_Actions__c>();
        Try {
            User user = [Select ManagerId from user where id = :userInfo.getUserId()];
            for (Case caseObj : newCaseList) {
                if (caseObj.RecordTypeId == ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID &&
                        caseObj.Channel__c == ConstantsUtility.MS_CORPORATE_CASE_CHANNEL && caseObj.Case_Type__c == ConstantsUtility.INTERNAL_CASE_TYPE
                        && caseObj.Business_Area__c == ConstantsUtility.INTERNAL_CASE_BUSINESS_AREA && caseObj.Primary_Category__c == ConstantsUtility.SPAM_PRIMARY_CATEGORY) {

                    listTOInsert.add(CaseTriggerHelper.createCaseAction(caseObj, string.valueof(user.ManagerId)));
                }
            }
            if (listTOInsert.size() > 0) {
                insert listTOInsert;
            }
        } catch (exception e) {

        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to mark Or Filter Query As Spam.
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        28/07/2020                Gitika            Initial Version
**/
    public void markOrFilterQueryAsSpam() {
        map<string, Spam_Phone_Emails__c> mapOfEmailWithSpamObj = new map<string, Spam_Phone_Emails__c>();
        map<string, Spam_Phone_Emails__c> mapOfPhoneWithSpamObj = new map<string, Spam_Phone_Emails__c>();
        try {
            for (Spam_Phone_Emails__c spam : [Select Email__c,Phone_No__c,From_Date__c,To_Date__c,RecordTypeId from Spam_Phone_Emails__c]) {
                if (spam.RecordTypeId == ConstantsUtility.EMAIL_SPAM_RECORD_TYPE_ID && String.isNotBlank(spam.Email__c)) {
                    mapOfEmailWithSpamObj.put(spam.Email__c, spam);
                } else if (spam.RecordTypeId == ConstantsUtility.PHONE_SPAM_RECORD_TYPE_ID && String.isNotBlank(spam.Phone_No__c)) {
                    mapOfPhoneWithSpamObj.put(spam.Phone_No__c, spam);
                }
            }
            for (Case caseObj : newCaseList) {
                if ((caseObj.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID ||
                        caseObj.RecordTypeId == ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID ||
                        caseObj.RecordTypeId == ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID) && String.isNotBlank(caseObj.Mobile_Number__c)
                        && mapOfPhoneWithSpamObj.containsKey(caseObj.Mobile_Number__c) && system.today() >= mapOfPhoneWithSpamObj.get(caseObj.Mobile_Number__c).From_Date__c
                        && system.today() <= mapOfPhoneWithSpamObj.get(caseObj.Mobile_Number__c).To_Date__c) {
                  //  caseObj.adderror(label.Spam_Query_Error_Message);
                }
                if ((caseObj.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID ||
                        caseObj.RecordTypeId == ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID) && caseObj.Origin == ConstantsUtility.EMAIL && string.isNotBlank((caseObj.SuppliedEmail).toLowercase()) && mapOfEmailWithSpamObj.containsKey(caseObj.SuppliedEmail)) {
                  //  caseObj.adderror(label.Spam_Query_Error_Message);
                }
            }
        } catch (Exception e) {

        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to mark mc communication record status cancelled once case is resolved.
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        28/07/2020                Gitika            Initial Version
**/
    public void markMcCommunicationCancelled() {
        map<id, case> mapOfcase = new map<id, case>();
        List<MC_Communication__c> mcComList = new list<MC_Communication__c>();
        for (Case caseObj : newCaseList) {
            //RecordType Condition added for Suzuki Connect by Nitin on 07/01/2020
            if (caseObj.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID || caseObj.RecordTypeId == ConstantsUtility.REPEAT_COMPLAINT_CASE_RECORD_TYPE_ID
                || caseObj.RecordTypeId == ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID || caseObj.RecordTypeId == ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID
                || caseObj.RecordTypeId == ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID) {
                    if (caseObj.CCP_Complete_Time__c != null || caseObj.IsClosed == true) {
                        mapOfcase.put(caseObj.id, caseObj);
                    }
                }
        }
        if (mapOfcase.size() > 0) {
            for (MC_Communication__c mcCom : [Select id,Type__c,Status__c,Case__c from MC_Communication__c where Case__c in :mapOfcase.keySet()]) {
                if (mapOfcase.get(mcCom.Case__c).IsClosed && mcCom.Type__c == ConstantsUtility.DEALER_RESOLUTION_ESCALATION) {
                    mcComList.add(new MC_Communication__c(id = mcCom.id, Status__c = ConstantsUtility.CANCELLED));
                } else if (mapOfcase.get(mcCom.Case__c).CCP_Complete_Time__c != null && (mcCom.Type__c == ConstantsUtility.CCP || mcCom.Type__c == ConstantsUtility.CCP_REMINDER)) {
                    mcComList.add(new MC_Communication__c(id = mcCom.id, Status__c = ConstantsUtility.CANCELLED));
                }
            }
            if (mcComList.size() > 0) {
                update mcComList;
            }
        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to initiate escalation
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        01/08/2020                Gitika            Initial Version
**/
    public void updateEscalationDetails() {
        caseEscalationService.updateEscalationDetails(newCaseList, oldCasemap);
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to create MC Communication for Escalation
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        01/08/2020                Gitika            Initial Version
**/
    public void postChatterAndMCRecordsEscalation() {
        caseEscalationService.postChatterAndMCRecordsEscalation(newCaseList, oldCasemap);
    }

    /**
Author: Gitika
Company: Techmatrix
Description: Method to store Email ID Queue and Time Assigned To Agent for Email Case
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        24/08/2020                Gitika            Initial Version
**/
    public void updateEmailQueueAndTimeAssignedToAgent() {
        for (case caseobj : newCaseList) {
            if (trigger.isInsert && caseobj.recordTypeId == ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID && (String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OOG)) {
                caseobj.Email_Queue_Id__c = caseobj.OwnerId;
                caseobj.Email__c = string.isNotBlank(caseobj.SuppliedEmail) ? caseobj.SuppliedEmail : null;
            } else if (trigger.isUpdate && caseobj.recordTypeId == ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID && oldCasemap.get(caseobj.Id).OwnerId != caseobj.OwnerId
                    && (String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OO5)
                    && (String.valueof(oldCasemap.get(caseobj.Id).OwnerId)).startsWith(ConstantsUtility.OOG)) {
                caseobj.Time_Assigned_to_Agent__c = system.now();
            }
        }
    }
    /**
/**
Author: Gitika
Company: Techmatrix
Description: Method to store previous owner if current user is queue
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        28/07/2020                Gitika            Initial Version
**/
    public void updatePreviousOwner() {
        try {
            for (case caseobj : newCaseList) {
                if (oldCasemap.get(caseobj.Id).OwnerId != caseobj.OwnerId && (String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OOG)
                        && (String.valueof(oldCasemap.get(caseobj.Id).OwnerId)).startsWith(ConstantsUtility.OO5)) {
                    caseobj.Previous_Owner__c = String.valueOf(oldCasemap.get(caseobj.Id).OwnerId).substring(0, 15);
                }
                if ((String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OO5) && oldCasemap.get(caseobj.Id).OwnerId == caseobj.OwnerId
                        && caseobj.Change_owner_to_Previous_owner__c == true && String.isNotBlank(caseobj.Previous_Owner__c) && (caseobj.Previous_Owner__c).startsWith(ConstantsUtility.OO5)) {
                    caseobj.OwnerId = caseobj.Previous_Owner__c;
                    caseobj.Change_owner_to_Previous_owner__c = false;
                }
            }
        } catch (exception e) {
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'updatePreviousOwner', '', null);
        }

    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to Insert Buld Hold Cases and for updated Case action status for revalidation process
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        05/06/2020                Gitika            Initial Version
**/
    public void caseBulkHoldRequest() {
        // Map of Bulk Hold Till Date with Buld Hold Case data
        map<date, Bulk_Hold_Cases__c> mapOfBulkHoldTillDateWithBuldHoldCaseObj = new map<date, Bulk_Hold_Cases__c>();
        // List of Case Actions to be inserted.
        list<Case_Actions__c> caseactionToInsertList = new list<Case_Actions__c>();
        // Map of Bulk Hold Till Date with Case Ids
        map<date, set<String>> mapOfBulkHoldTillDateWithRegion = new map<date, set<String>>();
        map<date, set<String>> mapOfBulkHoldTillDateWithDealerShip = new map<date, set<String>>();
        // Set of Case Ids
        set<Id> caseObjIds = new set<Id>();
        set<String> regionCode = new set<String>();
        set<String> dealerShipIds = new set<String>();
        // Map of Case Ids with stakeholder mapping
        map<Id, map<string, string>> mapofCaseIdWithStakeHoldersmap = new map<Id, map<string, string>>();
        List<case> caseList = new list<Case>();
        try {
            for (case cs : newCaseList) {

                // check for bulk hold cases
                if (string.isNotBlank(string.valueof(cs.Bulk_Hold_Till_Date__c)) && string.isNotBlank(cs.Bulk_Hold_Status__c)
                        && string.isBlank(string.valueof(OldCasemap.get(cs.id).Bulk_Hold_Till_Date__c)) && string.isBlank(OldCasemap.get(cs.id).Bulk_Hold_Status__c)) {
                    caseList.add(cs);
                    regionCode = new set<string>();
                    dealerShipIds = new set<string>();
                    if (mapOfBulkHoldTillDateWithRegion.containskey(cs.Bulk_Hold_Till_Date__c)) {
                        mapOfBulkHoldTillDateWithRegion.get(cs.Bulk_Hold_Till_Date__c).add(cs.Region_code__c);
                    } else {
                        regionCode.add(cs.Region_code__c);
                        mapOfBulkHoldTillDateWithRegion.put(cs.Bulk_Hold_Till_Date__c, regionCode);
                    }
                    if (mapOfBulkHoldTillDateWithDealerShip.containskey(cs.Bulk_Hold_Till_Date__c)) {
                        mapOfBulkHoldTillDateWithDealerShip.get(cs.Bulk_Hold_Till_Date__c).add(cs.Dealer_Name__c);
                    } else {
                        dealerShipIds.add(cs.Dealer_Name__c);
                        mapOfBulkHoldTillDateWithDealerShip.put(cs.Bulk_Hold_Till_Date__c, dealerShipIds);
                    }
                }/*else if(string.isNotBlank(string.valueof(cs.Bulk_Hold_Till_Date__c)) && string.isNotBlank(string.valueof(OldCasemap.get(cs.id).Bulk_Hold_Till_Date__c))){
cs.adderror('Bulk Hold has already been initiated');  
}*/

            }
            if (caseList.size() > 0) {
                // calling helper method for stakeholder mapping
                mapofCaseIdWithStakeHoldersmap = CaseActionTriggerHelper.mapOfcaseIdWithMapOfStakeHolders(caseList, ConstantsUtility.mapOfStakeholderJSONWithBulkHoldFields);
                for (case cs : caseList) {
                    // check for bulk hold cases

                    boolean caninitiate = false;

                    if (mapofCaseIdWithStakeHoldersmap.containskey(cs.Id) && mapofCaseIdWithStakeHoldersmap.get(cs.Id).size() > 0) {
                        for (string str : label.Bulk_Hold_intiators.split(';')) {
                            if (mapofCaseIdWithStakeHoldersmap.get(cs.Id).containskey(str)) {
                                //Changes Made by Nitin on 09/12/2020
                                if ((mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str)).substring(0, 15) == (userinfo.getUserId()).substring(0, 15)) {
                                    caninitiate = true;
                                    break;
                                }
                                /*if(mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str).length()==15 &&  mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str)== userinfo.getUserId().left(15)) {
                                    caninitiate = true;
                                    break;
                                }else if(mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str).length()>15 &&  mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str)== userinfo.getUserId()) {
                                    caninitiate = true;
                                    break;
                                }*/
                                //Changes Made by Nitin on 09/12/2020
                            }
                        }
                        if (caninitiate == true) {
                            caseObjIds.add(cs.Id);
                            if (!mapOfBulkHoldTillDateWithBuldHoldCaseObj.containskey(cs.Bulk_Hold_Till_Date__c)) {
                                //creating Bulk hold case for same Bulk Hold Till Date
                                Bulk_Hold_Cases__c bulkcase = new Bulk_Hold_Cases__c();
                                bulkcase.Hold_Start_Date__c = cs.Bulk_Hold_Start_Date__c;
                                bulkcase.Hold_Till_Date__c = cs.Bulk_Hold_Till_Date__c;
                                bulkcase.Comments__c = cs.Bulk_Hold_Comments__c;
                                bulkcase.Approval_Status__c = ConstantsUtility.In_Progress;
                                bulkcase.Case_Type__c = String.isNotBlank(cs.Case_Type__c) ? cs.Case_Type__c : null;
                                bulkcase.Region_code__c = String.isNotBlank(cs.Region_code__c) ? cs.Region_code__c : null;
                                if (mapOfBulkHoldTillDateWithDealerShip.containsKey(cs.Bulk_Hold_Till_Date__c) && mapOfBulkHoldTillDateWithDealerShip.get(cs.Bulk_Hold_Till_Date__c).size() == 1) {
                                    for (string str : mapofCaseIdWithStakeHoldersmap.get(cs.Id).keyset()) {
                                        bulkcase.put(str, (Id) mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str));

                                    }

                                } else if (mapOfBulkHoldTillDateWithRegion.containsKey(cs.Bulk_Hold_Till_Date__c) && mapOfBulkHoldTillDateWithRegion.get(cs.Bulk_Hold_Till_Date__c).size() == 1) {

                                    for (string str : mapofCaseIdWithStakeHoldersmap.get(cs.Id).keyset()) {
                                        if (str != ConstantsUtility.L3_STAKEHOLDER)
                                            bulkcase.put(str, (Id) mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str));

                                    }

                                }
                                mapOfBulkHoldTillDateWithBuldHoldCaseObj.put(cs.Bulk_Hold_Till_Date__c, bulkcase);
                            }
                        } ELSE {
                            system.debug('UtilityClass.How--->' + UtilityClass.skipInternalCaseActionValidation);
                            cs.adderror(Label.Bulk_Hold_Initation_Check_Error);
                        }
                    } ELSE {
                        cs.adderror(Label.StakeHolder_Mapping_Error);
                    }


                }

                if (mapOfBulkHoldTillDateWithBuldHoldCaseObj.size() > 0)
                    insert mapOfBulkHoldTillDateWithBuldHoldCaseObj.values();

                for (case cs : caseList) {
                    if (mapOfBulkHoldTillDateWithBuldHoldCaseObj.containskey(cs.Bulk_Hold_Till_Date__c)) {
                        cs.Bulk_Hold_Case__c = mapOfBulkHoldTillDateWithBuldHoldCaseObj.get(cs.Bulk_Hold_Till_Date__c).id;

                        caseactionToInsertList.add(new Case_Actions__c(name = ConstantsUtility.Bulk_Hold,
                                Case_Number__c = cs.id,
                                Hold_Start_Date__c = mapOfBulkHoldTillDateWithBuldHoldCaseObj.get(cs.Bulk_Hold_Till_Date__c).Hold_Start_Date__c,
                                Hold_Till_Date__c = mapOfBulkHoldTillDateWithBuldHoldCaseObj.get(cs.Bulk_Hold_Till_Date__c).Hold_Till_Date__c,
                                RecordTypeId = ConstantsUtility.BULK_HOLD_CLOSURE_ACTION_RECORD_TYPE_ID,
                                Bulk_Hold_Case__c = mapOfBulkHoldTillDateWithBuldHoldCaseObj.get(cs.Bulk_Hold_Till_Date__c).id));

                    }
                }

                if (caseactionToInsertList.size() > 0)
                    Insert caseactionToInsertList;
            }
        } catch (exception e) {
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'caseBulkHoldRequest', '', null);
        }

    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to mcCom Record
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        4/09/2020                Gitika            Initial Version
**/
    public void createMCRecordsForATM() {
        sendCaseRegistrationNotification();
        MCCommunicationService.createMCRecordsForATM(newCaseList, oldCasemap);

    }


    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: It will share customer record to user
Inputs:
Returns:
History:
================
1.0     09 Mar 2020      Sunit     Initial Version
*/
    public void shareCustomerRecord() {
        //System.debug('Inside shareCustomerRecord');
        //List<String> caseIdList=new List<String>();
        List<String> ownerIdList = new List<String>();
        for (Case cs : newCaseList) {
            System.debug('Inside for');
            System.debug(cs.Customer__r.SVOC_ID__c);
            //caseIdList.add(cs.id);
            if (cs.recordtypeid == vehicleserviceRecTypeId || cs.recordtypeid == RenewalRecTypeId)
                ownerIdList.add(cs.OwnerId);
        }
        if (ownerIdList == null || ownerIdList.size() == 0) {
            return;
        }
        Map<String, User> ownerMap = new Map<String, User>([
                SELECT
                        Id,
                        Account.Parent_Group__c
                FROM User
                WHERE Id = :ownerIdList
        ]);
        List<Customer_Visibility__c> cvList = new List<Customer_Visibility__c>();
        for (Case cs : newCaseList) {
            System.debug(ownerMap.get(cs.OwnerId).Account);
            if (!String.isBlank(cs.Customer__c)) {
                Customer_Visibility__c cv = new Customer_Visibility__c();
                cv.Dealer_Public_Group_Name__c = ownerMap.get(cs.OwnerId).Account != null ? ownerMap.get(cs.OwnerId).Account.Parent_Group__c : null;
                cv.Related_User__c = cs.OwnerId;
                cv.Transaction_Type__c = System.label.Transaction_Type_OTP;
                cv.Transaction_Date__c = System.now();
                cv.Start_Datetime__c = System.now();
                cv.Customer_Account__c = cs.Customer__c;
                cv.SVOC_ID__c = cs.Customer__r.SVOC_ID__c;
                cv.Access_Processing_Status__c = System.label.Access_Process_Status_Success;
                cv.Sync_Status__c = System.label.Access_Sync_Status;
                cvList.add(cv);
            }
        }
        if (cvList.size() > 0) {
            insert cvList;
        }
    }

    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: It will update subject if suject is blank and Record type is MI Renewal
Inputs:
Returns:
History:
================
1.0     12 Mar 2020      Sunit     Initial Version
*/
    public void updateSubject() {
        for (Case cs : newCaseList) {
            system.debug('updateSubject------->' + newCaseList);
            if (String.isBlank(cs.Subject) && RenewalRecTypeId == cs.RecordTypeId) {
                String policyNo = String.isEmpty(cs.Policy_No__c) ? '' : cs.Policy_No__c;
                String expiryDate = String.valueOf(cs.Expiry_Date__c) == null ? '' : String.valueOf(cs.Expiry_Date__c);
                list<string> expiryDateParts = expiryDate.split(' ');
                cs.Subject = String.isEmpty(cs.Type) ? '' : cs.Type + ' ' + policyNo + ' ' + expiryDateParts[0];
            }
        }

    }

    public void udpateEntitlementDetails() {
        for (Case cs : newCaseList) {
            //Assigned Entitlements to ATM Related Cases
            cs.EntitlementId = System.label.ATM_Entitlement_ID ;
            //Update the Status as Closed if Customer Satisfied with FCR Is Yes for Queries
            if ((cs.Case_Type__c == ConstantsUtility.DEALER_QUERY || cs.Case_Type__c == ConstantsUtility.DEALER_FEEDBACK_CASE_TYPE || cs.Case_Type__c == ConstantsUtility.MSIL_QUERY_CASE_TYPE) && cs.FCR_Conducted__c == ConstantsUtility.YES && cs.Customer_Satisfied_With_FCR__c == ConstantsUtility.YES) {
                cs.Status = ConstantsUtility.CASE_CLOSED;
            }
        }
    }

    //This method is added when a DNC case is submitted it will invoke the Approval Process
    //This method is added to remove the manual intervention to call Approval Process
    //Added by Nitin Ghai(04/03/2020)
    public void dncCaseSubmitforApproval() {

        //return if this is integration User updating the record
        if (UserInfo.getuserId() == System.label.Integration_User) {
            return;
        }

        try {
            Id dncrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
            for (Case cs : newCaseList) {
                if (cs.RecordTypeId == dncrecordTypeId && String.isNotBlank(cs.Mobile_Number__c) && cs.Status == 'New') {
                    system.debug('cs------->Rec' + cs);
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Customer has requested for Approval');
                    req1.setObjectId(cs.Id);
                    req1.setProcessDefinitionNameOrId('Approval_Process_for_DNC');
                    Approval.ProcessResult result = Approval.process(req1);
                }
            }
        } catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'dncCaseSubmitforApproval', '', ehst);
        }
    }
    //update standard Account field with owner's User Account for controlling case visibility
    public void updateUserAccountonCase() {
        System.debug(bypassSetting.Skip_Update_User_Account_on_Case__c);
        if (!bypassSetting.Skip_Update_User_Account_on_Case__c) {
            system.debug('Inside updateUserAccountonCase');
            system.debug('oldCaseMap' + Trigger.OperationType);
            system.debug('oldCaseMap' + this.oldCaseMap);
            for (Case cs : newCaseList) {
                if ((Trigger.isInsert == true || (Trigger.isUpdate == true && oldCaseMap.get(cs.Id).get('ownerid') != cs.ownerid)) && (cs.recordtypeid == RenewalRecTypeId || cs.recordtypeid == vehicleserviceRecTypeId)) {
                    caseOwnerIdSet.add(cs.OwnerId);
                }
            }
            if (caseOwnerIdSet.size() > 0) {
                for (Account acc : [
                        select
                                id,
                                User__c,
                                User__r.Contact.AccountID
                        From Account
                        WHERE RecordTypeId = :userAccountRecordTypeId AND User__c <> NULL AND User__c IN :caseOwnerIdSet
                ]) {
                    caseOwnerToUserAccountMap.put(acc.User__c, acc);
                }
                if (caseOwnerToUserAccountMap.size() > 0) {
                    for (Case cs : newCaseList) {
                        if (caseOwnerToUserAccountMap.containsKey(cs.ownerId)) {
                            cs.AccountId = caseOwnerToUserAccountMap.get(cs.ownerId).Id;
                            system.debug('cs.AccountId---->' + cs.AccountId);
                        }
                    }
                }
            }
        }
    }

    /**
Author: Mahith Madwesh
Company: Salesforce
Description: If a case is closed, then related tasks status will be marked as complete
Inputs:
Returns:
History:
================
1.0     15 Mar 2020      Mahith     Initial Version
*/
    public void updateRelatedCaseTasks() {
        try {

            //return if this is not integration User updating the record
            if (UserInfo.getuserId() != System.label.Integration_User) {
                return;
            }

            list<case> insertedCases = new list<case>();
            for (case cs : newCaseList) {
                if (cs.recordtypeid == RenewalRecTypeId && oldCaseMap.get(cs.Id).get('isClosed') != true && (cs.status == 'Lost' || cs.status == 'Converted')) {
                    insertedCases.add(cs);
                }
            }
            if (insertedCases == null || insertedCases.size() == 0) {
                return;
            }
            //addedd a limit to avoid governance errors in case updates via integration
            list<task> relatedTasks = [
                    SELECT
                            Id,
                            case__c,
                            Status
                    FROM Task
                    WHERE case__c IN :insertedCases and Status = 'Open'
                    limit 5000
            ];

            list<task> tasksUpdate = new list<task>();
            for (task t : relatedTasks) {
                t.Status = 'Completed';
                tasksUpdate.add(t);
            }
            if (tasksUpdate != null && tasksUpdate.size() > 0)
                update tasksUpdate;
        } catch (Exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseTriggerHandler';
            system.debug(e.getMessage());
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'updateRelatedCaseTasks', '', ehst);
        }
    }

    /**
Author: Mahith Madwesh
Company: Salesforce
Description: If a case status is lost and changed to anything else, then the reason for lost field is updated to null.
and If a case is changed from IClosed true to false, then the reason for lost field is updated to null.
This runs only for integration user
Inputs:
Returns:
History:
================
1.0     18 Mar 2020      Mahith     Initial Version
*/
    public void updateCaseReasonForLost() {
        try {
            if (UserInfo.getUserId() == System.label.Integration_User) {
                for (case cs : newCaseList) {
                    Case oldCase = oldCaseMap.get(cs.Id);
                    if (oldCase.IsClosed == true && cs.isClosed == false) {
                        cs.Reason_for_Lost__c = null;
                    }
                }
            }
        } catch (Exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'CaseTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'updateCaseFields', '', ehst);
        }
    }

    /**
Author: Deepak Kumar
Company: Techmatrix
Description: It will update Case resolution time if status is updated to resolved
Inputs:
Returns:
History:
===============================================================
1.0     20 Jun 2020      Deepak     Initial Version
*/
    public void updateCaseResolutionTime() {
        list<MC_Communication__c> mcList = new list<MC_Communication__c>();
        try {
            for (Case caseObj : newCaseList) {
                // Updating the Case  Resolve date and Case Resolution time id case get resolved
                if (caseObj.Status == ConstantsUtility.CASE_STATUS_RESOLVED && OldCasemap.get(caseObj.Id).Status != caseObj.Status) {
                    caseObj.Resolved_date__c = Date.today();
                    caseObj.Case_Resolution_Time__c = caseObj.Assigned_Date__c != null ? Date.valueOf(caseObj.Assigned_Date__c).daysBetween(Date.today()) : null;

                    if (caseObj.Mobile_Number__c != null && (caseObj.recordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID || caseObj.recordTypeId == ConstantsUtility.REPEAT_COMPLAINT_CASE_RECORD_TYPE_ID)) {
                        MC_Communication__c mcRecord = new MC_Communication__c();
                        mcRecord.Recipient_Phone_Numbers__c = caseObj.Mobile_Number__c;
                        mcRecord.case__c = caseObj.id;
                        mcRecord.Type__c = ConstantsUtility.OTP_VERIFICATION_MC_COM_TYPE;
                        mcRecord.General_Field_1__c = caseObj.Case_Sub_Type__c;
                        mcRecord.Phone_2__c = caseObj.Mobile_Number__c;
                        mcRecord.Dealer_Field_1__c = (caseObj.Dealer_Address__c != null ? caseObj.Dealer_Address__c : null);
                        mcList.add(mcRecord);
                    }
                }
            }
            if (mcList.size() > 0) {
                insert mcList;
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'updateCaseResolutionTime', '', null);
        }
    }


    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to update/prepopulate the fields on MOS Case
Events : Before Insert
Return Type : Void
*/
    public void updateFieldsOnMOSCase(Boolean isInsert, Boolean isUpdate, List<Account> listMSAllianzRecord) {
        try {
            Map<Id, Account> mapIdToMosMaster = CaseTriggerHelper.getMapIdToMOSMaster(newCaseList);
            Map<String, List<Custom_Activity__c>> mapCaseIdAndStageToListOfTask;
            Map<String, String> mapApiToLabel = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Case.Model__c.getDescribe();
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry v : values) {
                mapApiToLabel.put(v.getValue(), v.getLabel());
            }

            Map<Id, Color_Variant_Master__c > mapIdToColorName = new Map<Id, Color_Variant_Master__c>([SELECT Id,Name FROM Color_Variant_Master__c]);


            if (isUpdate) {
                mapCaseIdAndStageToListOfTask = CaseTriggerHelper.getTaskList(newCaseList);
            }
            //MOS Case Security Logic
            Set<Id> setContactId = new Set<Id>();
            Set<String> setVehicleRegistrationNumber = new Set<String>();
            Set<Id> setProductId = new Set<Id>();
            for (Case caseObj : newCaseList) {
                if (isInsert && caseObj.Vehicle_Registration_Number__c != NULL && caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    setVehicleRegistrationNumber.add(caseObj.Vehicle_Registration_Number__c);
                } else if (isUpdate && caseObj.Vehicle_Registration_Number__c != oldCasemap.get(caseObj.Id).Vehicle_Registration_Number__c && caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    setVehicleRegistrationNumber.add(caseObj.Vehicle_Registration_Number__c);
                }

                if (isInsert && caseObj.Technician_Id__c != NULL && caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    setContactId.add(caseObj.Technician_Id__c);
                } else if (isUpdate && caseObj.Technician_Id__c != oldCasemap.get(caseObj.Id).Technician_Id__c && caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    if (caseObj.Technician_ID__c == NULL) {
                        caseObj.AccountId = NULL;
                    } else {
                        setContactId.add(caseObj.Technician_Id__c);
                    }
                }

                if (isInsert && caseObj.Variant__c != NULL && caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    setProductId.add(caseObj.Variant__c);
                } else if (isUpdate && caseObj.Variant__c != oldCasemap.get(caseObj.Id).Variant__c && caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    setProductId.add(caseObj.Variant__c);
                }

            }

            Map<Id, Id> contactUserMap = new Map<Id, Id>();
            Map<Id, Id> technicianIdToDealerId = new Map<Id, Id>();
            if (setContactId.size() > 0) {
                for (Account acc : [SELECT Id,User__r.ContactID FROM Account WHERE User__r.ContactID IN :setContactId]) {
                    contactUserMap.put(acc.User__r.ContactID, acc.Id);
                }
                for (Contact con : [SELECT Id,AccountId FROM Contact WHERE Id IN :setContactId]) {
                    technicianIdToDealerId.put(con.Id, con.AccountId);
                }
            }

            Map<String, Asset> mapVehicleNumberToVehicleAsset = new Map<String, Asset>();
            if (setVehicleRegistrationNumber.size() > 0) {
                for (Asset ast : [
                        SELECT Id,Registration_Number__c,Product2Id,Product2.Name,Product2.Family,Color_of_the_Car__c,Product2.Model__c,Product2.Channel__c
                        FROM Asset
                        WHERE Registration_Number__c IN :setVehicleRegistrationNumber
                        AND RecordType.Name = 'Vehicle'
                ]) {
                    
                    mapVehicleNumberToVehicleAsset.put(ast.Registration_Number__c.tolowercase(), ast);
                }
            }

            Map<Id, Product2> mapIdToVariant;
            if (setProductId.size() > 0) {
                mapIdToVariant = new Map<Id, Product2>([SELECT Id,Name FROM Product2 WHERE Id IN :setProductId]);
            }

            for (Case caseObj : newCaseList) {
                if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    //Origin Salesforce
                    if (isInsert && String.isBlank(caseObj.Origin)) {
                        caseObj.Origin = 'Salesforce';
                    }

                    //Model, Color and Variant is required for Salesforce Internal Users
                     /*if (isInsert && (caseObj.Model__c == NULL || caseObj.Color__c == NULL || caseObj.Variant__c == NULL)
                            && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Please select Model, Color and Variant');
                    }*/

                    //Towing destination Dealer can not be MS Allianz
                    if (isInsert && caseObj.Towing_Destination_Dealer__c != NULL
                            && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0
                            && caseObj.Towing_Destination_Dealer__c == listMSAllianzRecord[0].Id && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Towing Destination Dealer can not be MS Allianz');
                    } else if (isUpdate && caseObj.Towing_Destination_Dealer__c != NULL
                            && caseObj.Towing_Destination_Dealer__c != oldCasemap.get(caseObj.Id).Towing_Destination_Dealer__c
                            && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0
                            && caseObj.Towing_Destination_Dealer__c == listMSAllianzRecord[0].Id && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Towing Destination Dealer can not be MS Allianz');
                    }

                    //Model or Model text is required
                    if (caseObj.Model__c == NULL && caseObj.Model_Txt__c == NULL) {
                        caseObj.addError('Please select Model');
                    }

                    //Color or Color Description is required
                    if (caseObj.Color__c == NULL && caseObj.Color_Description__c == NULL) {
                        caseObj.addError('Please select color');
                    }

                    //Update Model Txt field
                    if (isInsert && caseObj.Model__c != NULL && caseObj.Model_Txt__c == NULL) {
                        caseObj.Model_Txt__c = mapApiToLabel.get(caseObj.Model__c);
                    } else if (isUpdate && caseObj.Model__c != oldCasemap.get(caseObj.Id).Model__c && caseObj.Model_Txt__c == NULL) {
                        caseObj.Model_Txt__c = mapApiToLabel.get(caseObj.Model__c);
                    }

                    //update Color Description Field
                    if (isInsert && caseObj.Color__c != NULL && caseObj.Color_Description__c == NULL) {
                        caseObj.Color_Description__c = mapIdToColorName.get(caseObj.Color__c).Name;
                    } else if (isUpdate && caseObj.Color__c != oldCasemap.get(caseObj.Id).Color__c && caseObj.Color_Description__c == NULL) {
                        caseObj.Color_Description__c = mapIdToColorName.get(caseObj.Color__c).Name;
                    }

                    //update Variant Description Field
                    if (isInsert && caseObj.Variant__c != NULL && caseObj.Variant_Description__c == NULL && mapIdToVariant != NULL) {
                        caseObj.Variant_Description__c = mapIdToVariant.get(caseObj.Variant__c).Name;
                    } else if (isUpdate && caseObj.Variant__c != oldCasemap.get(caseObj.Id).Variant__c && caseObj.Variant_Description__c == NULL && mapIdToVariant != NULL) {
                        caseObj.Variant_Description__c = mapIdToVariant.get(caseObj.Variant__c).Name;
                    }

                    //Channel Transformation
                    if (caseObj.Model_Txt__c != NULL) {
                        if (caseObj.Model_Txt__c.containsIgnoreCase(ConstantsUtility.BALENO)
                                || caseObj.Model_Txt__c.containsIgnoreCase(ConstantsUtility.CIAZ)
                                || caseObj.Model_Txt__c.containsIgnoreCase(ConstantsUtility.IGNIS)
                                || caseObj.Model_Txt__c.containsIgnoreCase(ConstantsUtility.SCROSS)
                                || caseObj.Model_Txt__c.containsIgnoreCase(ConstantsUtility.XL6)) {
                            caseObj.Channel__c = ConstantsUtility.NEXA_CASE_CHANNEL;
                        } else {
                            caseObj.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
                        }
                    }

                    
                    if (isInsert && caseObj.Vehicle_Registration_Number__c != NULL && mapVehicleNumberToVehicleAsset != NULL
                            && mapVehicleNumberToVehicleAsset.keySet().size() > 0 && mapVehicleNumberToVehicleAsset.containsKey(caseObj.Vehicle_Registration_Number__c.tolowerCase())) {
                        CaseTriggerHelper.updateDetailsOnCaseFromAsset(caseObj, mapVehicleNumberToVehicleAsset);
                    } else if (isUpdate && caseObj.Vehicle_Registration_Number__c != oldCasemap.get(caseObj.Id).Vehicle_Registration_Number__c && mapVehicleNumberToVehicleAsset != NULL
                            && mapVehicleNumberToVehicleAsset.keySet().size() > 0 && mapVehicleNumberToVehicleAsset.containsKey(caseObj.Vehicle_Registration_Number__c.tolowerCase())) {
                        CaseTriggerHelper.updateDetailsOnCaseFromAsset(caseObj, mapVehicleNumberToVehicleAsset);
                    }
                    //Checking for ETA Time
                    if (isInsert && caseObj.ETA_Time__c != NULL && caseObj.ETA_Time__c <= Datetime.now() && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError(ConstantsUtility.CannotEnterETATimeInPast);
                    } else if (isUpdate && caseObj.ETA_Time__c != NULL && caseObj.ETA_Time__c != oldCasemap.get(caseObj.Id).ETA_Time__c && caseObj.ETA_Time__c <= Datetime.now() && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError(ConstantsUtility.CannotEnterETATimeInPast);
                    }

                    //Checking for Towing Reached Time
                    if (isInsert && caseObj.Towing_Reached_Time_2__c != NULL && caseObj.Towing_Reached_Time_2__c <= Datetime.now() && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Enter future time in Towing Reached time');
                    } else if (isUpdate && caseObj.Towing_Reached_Time_2__c != NULL && caseObj.Towing_Reached_Time_2__c != oldCasemap.get(caseObj.Id).Towing_Reached_Time_2__c && caseObj.Towing_Reached_Time_2__c <= Datetime.now() && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Enter future time in Towing Reached time');
                    }

                    //Checking for Towing ETA Time
                    if (isInsert && caseObj.Towing_ETA_2__c != NULL && caseObj.Towing_ETA_2__c <= Datetime.now() && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Enter future time in Towing ETA time');
                    } else if (isUpdate && caseObj.Towing_ETA_2__c != NULL && caseObj.Towing_ETA_2__c != oldCasemap.get(caseObj.Id).Towing_ETA_2__c && caseObj.Towing_ETA_2__c <= Datetime.now() && CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                        caseObj.addError('Enter future time in Towing ETA time');
                    }


                    //Check for Closed Case
                    if (isUpdate && caseObj.Status == ConstantsUtility.CaseStatusClosed && caseObj.Status == oldCasemap.get(caseObj.Id).Status) {
                        Boolean isClosed = true;
                        if (caseObj.RO_Observation__c != oldCaseMap.get(caseObj.Id).RO_Observation__c) {
                            isClosed = false;
                        }
                        if (caseObj.Action_Taken__c != oldCaseMap.get(caseObj.Id).Action_Taken__c) {
                            isClosed = false;
                        }
                        if (isClosed) {
                            caseObj.addError(ConstantsUtility.CanNotEditClosedCase);
                        }
                    }

                    //Assignment of M call cases and cases created in Salesforce to Pending for Allocation Queue
                    if (isInsert && CaseTriggerHelper.mapQueueNameToId != NULL && CaseTriggerHelper.mapQueueNameToId.keySet().size() > 0 && CaseTriggerHelper.mapQueueNameToId.containsKey(ConstantsUtility.PendingForAllocationQueue) && CaseTriggerHelper.mapQueueNameToId.get(ConstantsUtility.PendingForAllocationQueue) != NULL) {
                        if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall && String.isBlank(caseObj.Job_Type__c)) {
                            caseObj.OwnerId = CaseTriggerHelper.mapQueueNameToId.get(ConstantsUtility.PendingForAllocationQueue);
                        }

                        if (caseObj.Origin == ConstantsUtility.OriginSalesforce) {
                            caseObj.OwnerId = CaseTriggerHelper.mapQueueNameToId.get(ConstantsUtility.PendingForAllocationQueue);
                        }
                    }

                    //Breakdown cases can not be allocated to MS Allianz
                    if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId()) && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown && listMSAllianzRecord != NULL
                            && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != NULL && caseObj.Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                        caseObj.addError(ConstantsUtility.BreakdownAllocatedDealerMSAllianz);
                    }

                    //Case Type Population based on Entered Distance and Allocated Dealer
                    CaseTriggerHelper.populateCaseType(mapIdToMosMaster, caseObj);

                    //Complaint_Registration_Time__c popluation based on Created Date
                    if (caseObj.Complaint_Registration_Time__c == NULL && isInsert) {
                        caseObj.Complaint_Registration_Time__c = (caseObj.CreatedDate != NULL ? caseObj.CreatedDate : System.now());
                    }

                    //Update the Priority if Family Involvement is other than <<Blank>>
                    CaseTriggerHelper.populatePriority(caseObj);

                    //Update Towing Substage
                    CaseTriggerHelper.populateTowingSubStage(caseObj);

                    //population of Allocated dealer
                    if (CaseTriggerHelper.listMSAllianzRecord != NULL && CaseTriggerHelper.listMSAllianzRecord.size() > 0) {
                        CaseTriggerHelper.populateAllocatedDealer(caseObj);
                    }
                    //Allocated dealer should be entered manually by user
                    if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                            && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())
                            && caseObj.Job_Type__c != NULL && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                            && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation
                            && CaseObj.Allocated_Dealer__c == NULL) {
                        caseObj.addError(Label.Error_Message_on_MOS_Case_Update);
                    }

                    //populate Next follow Up time
                    if (CaseTriggerHelper.mapKeyToMOSLogic != NULL && CaseTriggerHelper.mapKeyToMOSLogic.keySet().size() > 0 && isInsert) {
                        CaseTriggerHelper.popluateNextFollowUpTime(caseObj);
                    }

                    if (isUpdate) {
                        //Update Job Type based on Customer consent
                        if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall && caseObj.Customer_Consent__c != oldCasemap.get(caseObj.Id).Customer_Consent__c) {
                            if (caseObj.Customer_Consent__c == ConstantsUtility.CustomerConsentTechnicianAssistance) {
                                caseObj.Job_Type__c = ConstantsUtility.Job_Type_Breakdown;
                            } else if (caseObj.Customer_Consent__c == ConstantsUtility.CustomerConsentTowingAssistance) {
                                caseObj.Job_Type__c = ConstantsUtility.JOB_TYPE_Accidental;
                            }
                        }
                        //Stage Change logic
                        if (caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c != oldCasemap.get(caseObj.Id).MOS_Case_Stage__c) {
                            //Stage Validation
                            if (CaseTriggerHelper.mapStageToAllowedStage != NULL && CaseTriggerHelper.mapStageToAllowedStage.keySet().size() > 0) {
                                String keyJobTypeAndCaseStage = caseObj.Job_Type__c + ConstantsUtility.keySeparator + oldCasemap.get(caseObj.Id).MOS_Case_Stage__c;
                                if (CaseTriggerHelper.mapStageToAllowedStage.containsKey(keyJobTypeAndCaseStage)) {
                                    MOS_Case_Stage_Change_Validations__mdt stageValidation = CaseTriggerHelper.mapStageToAllowedStage.get(keyJobTypeAndCaseStage);
                                    List<String> listAllowedStages = stageValidation.Allowed_Stage__c.split(',');
                                    if (listAllowedStages.contains(caseObj.MOS_Case_Stage__c)) {
                                        if (String.isNotBlank(stageValidation.Particular_Stage__c)) {
                                            List<String> listParticularStage = stageValidation.Particular_Stage__c.split(',');
                                            if (listParticularStage.contains(caseObj.MOS_Case_Stage__c)) {
                                                for (String fieldAPIName : stageValidation.Field_API_Name__c.split(',')) {
                                                    caseObj.put(fieldAPIName, null);
                                                }
                                            }
                                        }
                                    } else {
                                        if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                                                && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId())) {
                                            caseObj.addError(ConstantsUtility.mosStageValidationError + listAllowedStages);
                                        }
                                    }
                                }
                            }
                            
                            
                            
                            //Making Task Completed change
                            if (caseObj.Task_Completed__c == ConstantsUtility.MOS_Task_Status_Completed) {
                                caseObj.Task_Completed__c = ConstantsUtility.StageChanged1;
                            } else if (caseObj.Task_Completed__c == ConstantsUtility.StageChanged1) {
                                caseObj.Task_Completed__c = ConstantsUtility.StageChanged2;
                            } else {
                                caseObj.Task_Completed__c = ConstantsUtility.StageChanged1;
                            }

                            //Making Resolved time blank
                            if (caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_STAGE_Resolved) {
                                caseObj.Resolved_Time__c = null;
                            }
                            //populate Time on respective field on Stage changes
                            if (CaseTriggerHelper.mapStageNameToFieldAPIName != NULL && CaseTriggerHelper.mapStageNameToFieldAPIName.keySet().size() > 0) {
                                CaseTriggerHelper.populateTimeOnStageChange(caseObj, caseObj.MOS_Case_Stage__c);
                            }

                            //populate Next follow Up time
                            String key = caseObj.Id + ConstantsUtility.keySeparator + caseObj.MOS_Case_Stage__c;
                            system.debug('== key '+key);
                            
                            if (mapCaseIdAndStageToListOfTask != NULL && mapCaseIdAndStageToListOfTask.keySet().size() > 0 && mapCaseIdAndStageToListOfTask.containsKey(key)) {
                                system.debug('== IN IF');
                                List<Custom_Activity__c> listTask = mapCaseIdAndStageToListOfTask.get(key);
                                caseObj.Next_Follow_Up_Time__c = listTask[0].Next_Follow_Up_Time__c;
                                caseObj.Next_FollowUp_Remarks__c = listTask[0].Next_Follow_Up_remarks__c;
                                caseObj.Repeat_Call_Notification__c = listTask[0].Repeat_Call_Notification__c;
                            } else {
                                system.debug('== IN ELSE');
                                if (CaseTriggerHelper.mapKeyToMOSLogic != NULL && CaseTriggerHelper.mapKeyToMOSLogic.keySet().size() > 0) {
                                    system.debug('== IN === '+caseObj);
                                    CaseTriggerHelper.popluateNextFollowUpTime(caseObj);
                                }
                            }
                        }else{
                            // towing sub stage changing next follow up time logic
                            if (caseObj.Towing_Sub_stage__c != NULL && caseObj.Towing_Sub_stage__c != oldCasemap.get(caseObj.Id).Towing_Sub_stage__c) {
                                CaseTriggerHelper.popluateNextFollowUpTime(caseObj);
                            }
                        }
                        
                        

                        //Populaton of Time field on Towing SUb Stage Update
                        if (caseObj.Towing_Sub_stage__c == ConstantsUtility.TOWING_SUB_STAGE_Pending_for_Out_for_Service && caseObj.Towing_Sub_stage__c != oldCasemap.get(caseObj.Id).Towing_Sub_stage__c) {
                            caseObj.Towing_Allocated_Time_2__c = System.now();
                        }

                        //Job Type Validation
                        if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                                && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId()) &&
                                caseObj.Job_Type__c != NULL && oldCasemap.get(caseObj.Id).Job_Type__c != NULL && caseObj.Job_Type__c != oldCasemap.get(caseObj.Id).Job_Type__c && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall) {
                            caseObj.addError(ConstantsUtility.JobTypeValidationError);
                        }

                        //Customer Consent Validation
                        if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                                && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId()) && caseObj.Customer_Consent__c != oldCasemap.get(caseObj.Id).Customer_Consent__c && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                            caseObj.addError(ConstantsUtility.CustomerConsentValidationError);
                        }

                        //Allocated Dealer Validation
                        if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0
                                && !CaseTriggerHelper.setIntegrationUserId.contains(UserInfo.getUserId()) && caseObj.Allocated_Dealer__c != oldCasemap.get(caseObj.Id).Allocated_Dealer__c && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                            caseObj.addError(ConstantsUtility.AllocatedDealerValidationError);
                        }


                    }

                    //populate Job type based on Customer Consent
                    if (String.isNotBlank(caseObj.Customer_Consent__c)) {
                        CaseTriggerHelper.populateJobType(caseObj);
                    }

                    //Populate AccountId
                    if (caseObj.Technician_ID__c != NULL && contactUserMap.containsKey(caseObj.Technician_ID__c)) {
                        caseObj.AccountId = contactUserMap.get(caseObj.Technician_ID__c);
                    }

                    //Update Allocated Dealer on Case
                    if (isInsert && caseObj.Technician_Id__c != NULL && technicianIdToDealerId.containsKey(caseObj.Technician_ID__c)) {
                        caseObj.Allocated_Dealer__c = technicianIdToDealerId.get(caseObj.Technician_ID__c);
                    } else if (isUpdate && technicianIdToDealerId.containsKey(caseObj.Technician_ID__c) && caseObj.Technician_ID__c != oldCaseMap.get(caseObj.Id).Technician_ID__c) {
                        caseObj.Allocated_Dealer__c = technicianIdToDealerId.get(caseObj.Technician_ID__c);
                    }

                    //Assignment of Queue
                    if (CaseTriggerHelper.setIntegrationUserId != NULL &&
                            CaseTriggerHelper.setIntegrationUserId.size() > 0 &&
                            CaseTriggerHelper.mapQueueNameToId != NULL &&
                            CaseTriggerHelper.mapQueueNameToId.keySet().size() > 0) {
                        if (isInsert) {
                            CaseTriggerHelper.assignQueue(caseObj, true);
                        } else {
                            if ((caseObj.MOS_Case_Stage__c != oldCasemap.get(caseObj.Id).MOS_Case_Stage__c)
                                    || (caseObj.Job_Type__c != oldCasemap.get(caseObj.Id).Job_Type__c)
                                    || (caseObj.Towing_Sub_stage__c != oldCasemap.get(caseObj.Id).Towing_Sub_stage__c)) {
                                CaseTriggerHelper.assignQueue(caseObj, false);
                            }
                        }
                    }
                    //Population of Dealer Location On case
                    if (isInsert && mapIdToMosMaster != NULL && mapIdToMosMaster.keySet().size() > 0 && caseObj.Allocated_Dealer__c != NULL
                            && mapIdToMosMaster.containsKey(caseObj.Allocated_Dealer__c)) {
                        caseObj.Dealer_Location__Latitude__s = mapIdToMosMaster.get(caseObj.Allocated_Dealer__c).Dealer_Geo_Location__Latitude__s;
                        caseObj.Dealer_Location__Longitude__s = mapIdToMosMaster.get(caseObj.Allocated_Dealer__c).Dealer_Geo_Location__Longitude__s;
                    } else if (isUpdate && mapIdToMosMaster != NULL && mapIdToMosMaster.keySet().size() > 0 && caseObj.Allocated_Dealer__c != NULL
                            && mapIdToMosMaster.containsKey(caseObj.Allocated_Dealer__c)
                            && caseObj.Allocated_Dealer__c != oldCasemap.get(caseObj.Id).Allocated_Dealer__c) {
                        caseObj.Dealer_Location__Latitude__s = mapIdToMosMaster.get(caseObj.Allocated_Dealer__c).Dealer_Geo_Location__Latitude__s;
                        caseObj.Dealer_Location__Longitude__s = mapIdToMosMaster.get(caseObj.Allocated_Dealer__c).Dealer_Geo_Location__Longitude__s;
                    }

                    //Update Technician Id
                    if (isInsert && caseObj.Allocated_Dealer__c != NULL && caseObj.Technician_ID__c == NULL
                            && CaseTriggerHelper.mapAllocatedDealerToTechnicianId != NULL
                            && CaseTriggerHelper.mapAllocatedDealerToTechnicianId.keySet().size() > 0
                            && CaseTriggerHelper.mapAllocatedDealerToTechnicianId.containsKey(caseObj.Allocated_Dealer__c)) {
                        caseObj.Technician_ID__c = CaseTriggerHelper.mapAllocatedDealerToTechnicianId.get(caseObj.Allocated_Dealer__c);
                    } else if (isUpdate && caseObj.Allocated_Dealer__c != oldCaseMap.get(caseObj.Id).Allocated_Dealer__c /*&& caseObj.Technician_ID__c == NULL*/
                            && CaseTriggerHelper.mapAllocatedDealerToTechnicianId != NULL
                            && CaseTriggerHelper.mapAllocatedDealerToTechnicianId.keySet().size() > 0
                            && CaseTriggerHelper.mapAllocatedDealerToTechnicianId.containsKey(caseObj.Allocated_Dealer__c)) {
                        caseObj.Technician_ID__c = CaseTriggerHelper.mapAllocatedDealerToTechnicianId.get(caseObj.Allocated_Dealer__c);
                    }

                }
            }
        } catch (Exception e) {
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage() + ':' + e.getLineNumber(), 'MOS Case before Event', '', null);
        }
    }


    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to create MOS Task for MOS Case everytime stage changed.
Events : After Update
Return Type : Void
*/
    public void MOSCaseAfterEvent(Boolean isInsert, Boolean isUpdate, List<Account> listMSAllianzRecord) {
        try {
            List<Task> listMOSTaskToInsert = new List<Task>();
            List<Custom_Activity__c> listCustomActivityToInsert = new List<Custom_Activity__c>();
            Set<Id> setCaseId = new Set<Id>();
            Map<String, Set<Id>> mapEscalationTypeToCaseId = new Map<String, Set<Id>>();
            Map<String, Map<String, MOS_Escalation_mdt__c>> newEscalationTypeToMetadataRecords = new Map<String, Map<String, MOS_Escalation_mdt__c>>();
            Map<Id, Case_Actions__c> mapCaseIdAndCaseActionIdToCaseActionRecord = new Map<Id, Case_Actions__c>();
            Map<String, String> mapEscalationTypeToCaseActionFieldApi = new Map<String, String>();
            Set<Id> setClosedCaseId = new Set<Id>();
            Boolean fetchCaseActionRecords = false;
            List<MC_Communication__c> listMCCommunicationToUpdate = new List<MC_Communication__c>();
            List<MC_Communication__c> listMCCommunicationToInsert = new List<MC_Communication__c>();
            Set<Id> setPFOFSCaseId = new Set<Id>();
            Set<Id> setReachedCaseId = new Set<Id>();
            List<Case> listMOSCase = new List<Case>();
            Set<Id> setCityId = new Set<Id>();
            Map<Id, String> mapCityIdToCityCode = new Map<Id, String>();
            Map<Id, String> mapCityIdToName = new Map<Id, String>();
            if (isUpdate) {
                mapEscalationTypeToCaseId = CaseTriggerHelper.mapEscalationTypeToCaseId;
                newEscalationTypeToMetadataRecords = CaseTriggerHelper.newEscalationTypeToMetadataRecords;
                mapEscalationTypeToCaseActionFieldApi = CaseTriggerHelper.mapEscalationTypeToCaseActionFieldApi;
            }
            if (!CaseTriggerHelper.byPassMOSCommunication) {
                //Get all allocatedDealer and Technician Id
                Set<Id> setTechnicianId = new Set<Id>();
                Set<Id> setAllocatedDealerId = new Set<Id>();
                Boolean msAllianz = false;
                for (case caseObj : newCaseList) {
                    if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                        if (caseObj.City__c != NULL) {
                            setCityId.add(caseObj.City__c);
                        }
                        if (caseObj.Technician_Id__c != NULL) {
                            setTechnicianId.add(caseObj.Technician_Id__c);
                        }
                        if (caseObj.Allocated_Dealer__c != NULL) {
                            setAllocatedDealerId.add(caseObj.Allocated_Dealer__c);
                            if (listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && listMSAllianzRecord[0].Id == caseObj.Allocated_Dealer__c) {
                                msAllianz = true;
                            }
                        }

                        if (caseObj.Towing_Destination_Dealer__c != NULL) {
                            setAllocatedDealerId.add(caseObj.Towing_Destination_Dealer__c);
                        }
                    }
                }

                if (setCityId != NULL && setCityId.size() > 0) {
                    for (City__c city : [SELECT Id,City_Code__c,Name FROM City__c WHERE Id IN :setCityId]) {
                        mapCityIdToCityCode.put(city.Id, city.City_Code__c);
                        mapCityIdToName.put(city.Id, city.Name);
                    }
                }

                //Get all the Audience for MOS MC Communication
                CaseTriggerHelper.getMCCommunicationAudiencePhoneNumbers(setTechnicianId, setAllocatedDealerId, msAllianz, listMSAllianzRecord);
            }

            for (Case caseObj : newCaseList) {
                if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                    listMOSCase.add(caseObj);

                    if (isUpdate) {
                        if (caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c != oldCasemap.get(caseObj.Id).MOS_Case_Stage__c) {
                            Custom_Activity__c newTaskObj = CaseTriggerHelper.getNewCustomTaskRecord(caseObj);
                            listCustomActivityToInsert.add(newTaskObj);
                            setCaseId.add(caseObj.Id);
                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown && caseObj.Allocated_Dealer__c != NULL) {
                                if (caseObj.Mobile_Number__c != NULL) {
                                    MOSCaseCommunicationsService.BreakdownPendingForOutForService(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                                }

                                MOSCaseCommunicationsService.OFSReminder(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecords, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                            }

                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Allocated_Dealer__c != NULL /*&& caseObj.Allocated_Dealer__c != oldCaseMap.get(caseObj.Id).Allocated_Dealer__c*/ && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != listMSAllianzRecord[0].Id && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service) {
                                MOSCaseCommunicationsService.AllocatedDealerNotMSAllianz(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                            }

                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.Allocated_Dealer__c != NULL) {
                                MOSCaseCommunicationsService.OFSReminder(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecords, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                            }

                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Job_Type__c != NULL && caseObj.Allocated_Dealer__c != NULL && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != listMSAllianzRecord[0].Id && caseObj.MOS_Case_Stage__c == ConstantsUtility.Customer_Cancelled && ConstantsUtility.setCancelledReason.contains(caseObj.Customer_Cancellation__c)) {
                                if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                    MOSCaseCommunicationsService.checkForCommunicationRecord(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                            ConstantsUtility.Case_Cancelled_MCall, listMCCommunicationToInsert, caseObj,
                                            listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                            CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                            CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                } else {
                                    MOSCaseCommunicationsService.checkForCommunicationRecord(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                            ConstantsUtility.Customer_Cancelled, listMCCommunicationToInsert, caseObj,
                                            listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                            CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                            CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                }
                            }

                            if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.ETA_Time__c != NULL && caseObj.Allocated_Dealer__c != NULL) {
                                if (listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                                    if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_MCall_MS_Allianz, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }
                                    } else {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_MS_Allianz, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }
                                    }
                                } else {
                                    if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_MCall_Dealer, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }
                                    } else {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_Dealer, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }
                                    }
                                }
                            }

                            if (oldCasemap.get(caseObj.Id).MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service) {
                                setPFOFSCaseId.add(caseObj.Id);
                            }
                            if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Reached) {
                                setReachedCaseId.add(caseObj.Id);
                            }

                            //Email communication for Cancelled Customer
                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.MOS_Case_Stage__c == ConstantsUtility.Customer_Cancelled && ConstantsUtility.setCancelledReasonEmail.contains(caseObj.Customer_Cancellation__c) && caseObj.Allocated_Dealer__c != NULL) {
                                MOSCaseCommunicationsService.sendCustomerCancelledEmail(CaseTriggerHelper.mapAllocatedDealerToStakeHolderToEmails, listMCCommunicationToInsert, CaseTriggerHelper.mapRoleUser, caseObj, mapCityIdToName, CaseTriggerHelper.mapIdToAllocatedDealer);
                            }
                            //Send Emails to MS Allianz
                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                    && caseObj.Towing_Sub_stage__c == ConstantsUtility.TOWING_SUB_STAGE_Pending_for_Allocation && listMSAllianzRecord != NULL
                                    && listMSAllianzRecord.size() > 0 && caseobj.Towing_Allocated_Dealer_2__c == listMSAllianzRecord[0].Id
                                    && (caseObj.MOS_Case_Stage__c == ConstantsUtility.TowingIsRequired || caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Towing_required)) {
                                MOSCaseCommunicationsService.sendEmailToMSAllianz(caseObj, listMCCommunicationToInsert, mapCityIdToName);
                            }
                        }

                        //}

                        if (CaseTriggerHelper.mapConditionFieldToEscalationType != NULL && CaseTriggerHelper.mapConditionFieldToEscalationType.keySet().size() > 0) {
                            for (String conditionField : CaseTriggerHelper.mapConditionFieldToEscalationType.keySet()) {
                                if (caseObj.get(conditionField) != oldCaseMap.get(caseObj.Id).get(conditionField)) {
                                    fetchCaseActionRecords = true;
                                    for (String escalationType : CaseTriggerHelper.mapConditionFieldToEscalationType.get(conditionField)) {
                                        if (mapEscalationTypeToCaseId != NULL && mapEscalationTypeToCaseId.keySet().size() > 0) {
                                            Set<Id> tempSetCaseId = mapEscalationTypeToCaseId.get(escalationType);
                                            tempSetCaseId.add(caseObj.Id);
                                            mapEscalationTypeToCaseId.put(escalationType, tempSetCaseId);
                                        }
                                    }
                                }
                            }
                        }

                        //Storing closed Case Id in set
                        if (caseObj.Status != oldCasemap.get(caseObj.Id).Status && caseObj.Status == ConstantsUtility.CaseStatusClosed) {
                            setClosedCaseId.add(caseObj.Id);
                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Job_Type__c != NULL && (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_Case_Stage_Resolved || caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_Case_Stage_Resolved_On_Call)) {
                                listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj, ConstantsUtility.Case_Closure_Customer, caseObj.Mobile_Number__c));
                            }
                        }

                        if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Towing_Destination_Dealer__c != oldCasemap.get(caseObj.Id).Towing_Destination_Dealer__c && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental) {
                            MOSCaseCommunicationsService.TowingDestinationDealerSelected(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                        }

                        if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Customer_feedback__c != NULL && caseObj.Customer_feedback__c != oldCaseMap.get(caseObj.Id).Customer_feedback__c && (caseObj.Customer_feedback__c == ConstantsUtility.Poor || caseObj.Customer_feedback__c == ConstantsUtility.Average)) {
                            MOSCaseCommunicationsService.checkForCommunicationRecord(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                    ConstantsUtility.Poor_Feedback, listMCCommunicationToInsert, caseObj,
                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');

                            if (caseObj.Allocated_Dealer__c != NULL && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != listMSAllianzRecord[0].Id) {
                                MOSCaseCommunicationsService.sendCustomerFeedbackEmail(CaseTriggerHelper.mapAllocatedDealerToStakeHolderToEmails, listMCCommunicationToInsert, CaseTriggerHelper.mapRoleUser, caseObj, mapCityidToName, CaseTriggerHelper.mapIdToAllocatedDealer);
                            }
                        }


                        //Send Email to MS Allianz
                        if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && String.isNotBlank(caseObj.FE_CaseNumber__c) && caseObj.FE_CaseNumber__c != oldCaseMap.get(caseObj.Id).FE_CaseNumber__c) {
                            MOSCaseCommunicationsService.sendEmailToMSAllianz(caseObj, listMCCommunicationToInsert, mapCityIdToName);
                        }

                    } else if (isInsert) {
                        if (caseObj.MOS_Case_Stage__c != NULL) {
                            Custom_Activity__c newTaskObj = CaseTriggerHelper.getNewCustomTaskRecord(caseObj);
                            listCustomActivityToInsert.add(newTaskObj);
                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown && caseObj.Allocated_Dealer__c != NULL) {
                                if (caseObj.Mobile_Number__c != NULL) {
                                    MOSCaseCommunicationsService.BreakdownPendingForOutForService(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                                }

                                MOSCaseCommunicationsService.OFSReminder(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecords, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                            }

                            if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.Allocated_Dealer__c != NULL) {
                                MOSCaseCommunicationsService.OFSReminder(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecords, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                            }

                            if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.ETA_Time__c != NULL && caseObj.Allocated_Dealer__c != NULL) {
                                if (listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                                    if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_MCall_MS_Allianz, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }

                                    } else {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_MS_Allianz, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }

                                    }
                                } else {
                                    if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_MCall_Dealer, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }

                                    } else {
                                        if (!CaseTriggerHelper.byPassMOSCommunication) {
                                            MC_Communication__c mcRecord = MOSCaseCommunicationsService.checkForCommunicationRecordReturn(CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent,
                                                    ConstantsUtility.Towing_ETA_Breach_Dealer, caseObj,
                                                    listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers,
                                                    CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers,
                                                    CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers, 'Allocated_Dealer__c');
                                            mcRecord.Escalation_Date_Time__c = caseObj.ETA_Time__c;
                                            listMCCommunicationToInsert.add(mcRecord);
                                        }

                                    }
                                }
                            }
                        }

                        if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Towing_Destination_Dealer__c != NULL && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental) {
                            MOSCaseCommunicationsService.TowingDestinationDealerSelected(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                        }


                        if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Allocated_Dealer__c != NULL && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != listMSAllianzRecord[0].Id && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service) {
                            MOSCaseCommunicationsService.AllocatedDealerNotMSAllianz(caseObj, listMCCommunicationToInsert, CaseTriggerHelper.mapKeyToCommunicationRecordsNotTimeDependent, listMSAllianzRecord, CaseTriggerHelper.mapDesignationMSAllianzToPhoneNumbers, CaseTriggerHelper.mapRoleToPhoneNumbers, CaseTriggerHelper.mapTechnicianIdToPhoneNumbers, CaseTriggerHelper.mapAllocatedDealerToStakeHolderToPhoneNumbers);
                        }

                        //Send emails to MS Allianz
                        if (!CaseTriggerHelper.byPassMOSCommunication && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && String.isNotBlank(caseObj.FE_CaseNumber__c)) {
                            MOSCaseCommunicationsService.sendEmailToMSAllianz(caseObj, listMCCommunicationToInsert, mapCityIdToName);
                        }

                    }
                }
            }

            //Update all open follow up and mos task as closed when case is marked as closed
            if (setClosedCaseId.size() > 0) {
                List<Task> listTaskUpdate = new List<Task>();
                List<Case_Actions__c> listCaseActionToUpdate = new List<Case_Actions__c>();
                List<Custom_Activity__c> listCustomActivityToUpdate = new List<Custom_Activity__c>();
                for (Task taskObj : [SELECT Id,Status FROM TASK WHERE WhatId IN :setClosedCaseId AND RecordTypeId IN (:ConstantsUtility.MOS_TASK_RecordType_Id, :ConstantsUtility.TASK_MOS_Follow_Up_RecordType_Id) AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                    taskObj.Status = ConstantsUtility.MOS_Task_Status_Closed;
                    listTaskUpdate.add(taskObj);
                }

                for (Case_Actions__c caseActionObj : [SELECT Id,Escalation_Status__c FROM Case_Actions__c WHERE Case_Number__c IN :setClosedCaseId AND Escalation_Status__c = :ConstantsUtility.Case_Action_Escalation_Status_Active]) {
                    caseActionObj.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Inactive;
                    listCaseActionToUpdate.add(caseActionObj);
                }

                for (Custom_Activity__c taskObj : [SELECT Id,Status__c FROM Custom_Activity__c WHERE Case__c IN :setClosedCaseId AND RecordTypeId IN (:ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId, :ConstantsUtility.CustomActivityMOSTaskRecordTypeId) AND Status__c = :ConstantsUtility.MOS_TASK_Status_Open]) {
                    taskObj.Status__c = ConstantsUtility.MOS_Task_Status_Closed;
                    listCustomActivityToUpdate.add(taskObj);
                }

                if (listTaskUpdate.size() > 0) {
                    TriggerHandler.bypass('TaskTriggerHandler');
                    update listTaskUpdate;
                    TriggerHandler.clearBypass('TaskTriggerHandler');
                }

                if (listCaseActionToUpdate.size() > 0) {
                    update listCaseActionToUpdate;
                }

                if (listCustomActivityToUpdate.size() > 0) {
                    update listCustomActivityToUpdate;
                }

            }

            if (isUpdate && setCaseId.size() > 0) {
                List<Task> listTaskToUpdate = new List<Task>();
                List<Custom_Activity__c> listCustomActivityToUpdate = new List<Custom_Activity__c>();
                for (Task taskObj : [SELECT Id,Status,WhatId FROM TASK WHERE WhatId IN :setCaseId AND RecordTypeId = :ConstantsUtility.MOS_TASK_RecordType_Id AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                    taskObj.Status = ConstantsUtility.MOS_Task_Status_Closed;
                    listTaskToUpdate.add(taskObj);
                }

                for (Custom_Activity__c taskObj : [SELECT Id,Status__c,Case__c FROM Custom_Activity__c WHERE Case__c IN :setCaseId AND RecordTypeId = :ConstantsUtility.CustomActivityMOSTaskRecordTypeId AND Status__c = :ConstantsUtility.MOS_TASK_Status_Open]) {
                    taskObj.Status__c = ConstantsUtility.MOS_Task_Status_Closed;
                    listCustomActivityToUpdate.add(taskObj);
                }

                if (listTaskToUpdate.size() > 0) {
                    TriggerHandler.bypass('TaskTriggerHandler');
                    update listTaskToUpdate;
                    TriggerHandler.clearBypass('TaskTriggerHandler');
                }

                if (listCustomActivityToUpdate.size() > 0) {
                    update listCustomActivityToUpdate;
                }
            }

            List<Case_Actions__c> listCaseActionToInsert = new List<Case_Actions__c>();

            if (listCustomActivityToInsert.size() > 0) {
                insert listCustomActivityToInsert;
                for (Custom_Activity__c ca : [SELECT Id,Case__c,Case__r.MOS_Case_Stage__c,Case__r.OwnerId,Subject__c FROM Custom_Activity__c WHERE Id IN :listCustomActivityToInsert]) {
                    Task taskObj = CaseTriggerHelper.getNewTaskRecord(ca.Case__c, ca.Case__r.OwnerId, ca.Case__r.MOS_Case_Stage__c);
                    taskObj.Custom_Activity__c = ca.Id;
                    taskObj.Subject = ca.Subject__c;
                    listMOSTaskToInsert.add(taskObj);
                }

                if (listMOSTaskToInsert.size() > 0) {
                    TriggerHandler.bypass('TaskTriggerHandler');
                    insert listMOSTaskToInsert;
                    TriggerHandler.clearbypass('TaskTriggerHandler');
                }


                Map<Id, Id> mapCaseIdToTaskId = new Map<Id, Id>();
                for (Task taskObj : [SELECT Id,WhatId FROM Task WHERE Id IN :listMOSTaskToInsert]) {
                    mapCaseIdToTaskId.put(taskObj.WhatId, taskObj.Id);
                }

                if (isInsert) {
                    if (mapCaseIdToTaskId != NULL && mapCaseIdToTaskId.keySet().size() > 0) {
                        for (Case caseObj : newCaseList) {
                            if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                                Case_Actions__c followUpCaseAction = CaseTriggerHelper.getCaseActionRecord(caseObj);
                                followUpCaseAction.Name = caseObj.CaseNumber + ConstantsUtility.Hypen + ConstantsUtility.MOS_FollowUp_Escalation;
                                followUpCaseAction.Case_Type__c = ConstantsUtility.Case_Action_Type_MOS_followUp;
                                followUpCaseAction.Follow_up_ID__c = mapCaseIdToTaskId.get(caseObj.Id);
                                listCaseActionToInsert.add(followUpCaseAction);

                                Case_Actions__c allocationCaseAction = CaseTriggerHelper.getCaseActionRecord(caseObj);
                                allocationCaseAction.Name = caseObj.CaseNumber + ConstantsUtility.Hypen + ConstantsUtility.Allocation_Escalation;
                                allocationCaseAction.Case_Type__c = ConstantsUtility.Case_Action_Type_MOS_Allocation;
                                listCaseActionToInsert.add(allocationCaseAction);

                                Case_Actions__c reachCaseAction = CaseTriggerHelper.getCaseActionRecord(caseObj);
                                reachCaseAction.Name = caseObj.CaseNumber + ConstantsUtility.Hypen + ConstantsUtility.Reach_Escalation;
                                reachCaseAction.Case_Type__c = ConstantsUtility.Case_Action_Type_MOS_Reach;
                                listCaseActionToInsert.add(reachCaseAction);
                            }
                        }
                    }
                }

                if (isUpdate) {
                    if (mapCaseIdToTaskId != NULL && mapCaseIdToTaskId.keySet().size() > 0) {
                        List<Case_Actions__c> listOfFollowUpCaseActionToUpdate = new List<Case_Actions__c>();
                        for (Id caseId : mapCaseIdToTaskId.keySet()) {
                            if (newCaseMap.containsKey(caseId) && newCaseMap.get(caseId) != NULL && String.isNotBlank(newCaseMap.get(caseId).Escalation_Follow_up__c)) {
                                Case_Actions__c caseActionObj = new Case_Actions__c();
                                caseActionObj.Id = newCaseMap.get(caseId).Escalation_Follow_up__c;
                                caseActionObj.Follow_up_ID__c = mapCaseIdToTaskId.get(caseId);
                                listOfFollowUpCaseActionToUpdate.add(caseActionObj);
                            }
                        }

                        if (listOfFollowUpCaseActionToUpdate.size() > 0) {
                            TriggerHandler.bypass('CaseActionsTriggerHandler');
                            update listOfFollowUpCaseActionToUpdate;
                            TriggerHandler.clearBypass('CaseActionsTriggerHandler');
                        }
                    }
                }

            }

            Map<Id, Case> mapIdToCase = new Map<Id, Case>();

            if (listCaseActionToInsert.size() > 0) {
                insert listCaseActionToInsert;

                for (Case_Actions__c caseAction : [SELECT Id,Case_Number__c,Case_Type__c FROM Case_Actions__c WHERE Id IN :listCaseActionToInsert]) {
                    Case caseObjNew = new Case();
                    caseObjNew.Id = caseAction.Case_Number__c;
                    if (mapIdToCase.containsKey(caseAction.Case_Number__c)) {
                        caseObjNew = mapIdToCase.get(caseAction.Case_Number__c);
                    }
                    if (caseAction.Case_Type__c == ConstantsUtility.Case_Action_Type_MOS_followUp) {
                        caseObjNew.Escalation_Follow_up__c = caseAction.Id;
                    } else if (caseAction.Case_Type__c == ConstantsUtility.Case_Action_Type_MOS_Reach) {
                        caseObjNew.Escalation_Reach__c = caseAction.Id;
                    } else {
                        caseObjNew.Escalation_Allocation__c = caseAction.Id;
                    }
                    mapIdToCase.put(caseAction.Case_Number__c, caseObjNew);
                }
            }

            if (mapIdToCase != NULL && mapIdToCase.keySet().size() > 0) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update mapIdToCase.values();
                TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
            }

            if (fetchCaseActionRecords) {
                mapCaseIdAndCaseActionIdToCaseActionRecord = CaseTriggerHelper.getMapOfCaseActionsRecord(newCaseList);
            }

            List<Case_Actions__c> listCaseActionToUpdate = new List<Case_Actions__c>();

            if (isUpdate) {
                if (mapEscalationTypeToCaseId != NULL && mapEscalationTypeToCaseId.keySet().size() > 0) {
                    for (String escalationType : mapEscalationTypeToCaseId.keySet()) {
                        Set<Id> tempSetCaseId = mapEscalationTypeToCaseId.get(escalationType);
                        if (tempSetCaseId != NULL && tempSetCaseId.size() > 0) {
                            for (Id caseId : tempSetCaseId) {
                                if (newEscalationTypeToMetadataRecords.containsKey(escalationType)) {
                                    Map<String, MOS_Escalation_mdt__c> mapKeyToMetadataRecords = newEscalationTypeToMetadataRecords.get(escalationType);
                                    if (newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType)) != NULL) {
                                        String key = newCaseMap.get(caseId).Job_Type__c + ConstantsUtility.keySeparator + newCaseMap.get(caseId).Case_Type__c + ConstantsUtility.keySeparator + newCaseMap.get(caseId).MOS_Case_Stage__c + ConstantsUtility.KeySeparator + mapCaseIdAndCaseActionIdToCaseActionRecord.get((ID) newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType))).Escalation_Level__c + ConstantsUtility.keySeparator + escalationType;
                                        Case_Actions__c newCaseAction = new Case_Actions__c();
                                        newCaseAction.Id = (Id) newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType));
                                        if (mapKeyToMetadataRecords.containsKey(key)) {
                                            MOS_Escalation_mdt__c mosEscalation = mapKeyToMetadataRecords.get(key);
                                            if (mosEscalation.Value__c.split(',').contains((String) newCaseMap.get(caseId).get(mosEscalation.Condition__c))) {
                                                newCaseAction.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Active;
                                                if (newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c) != NULL) {
                                                    newCaseAction.Escalation_Update__c = (DateTime) newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c);
                                                    if (escalationType != ConstantsUtility.Reached) {
                                                        newCaseAction.Escalation_Level__c = ConstantsUtility.Case_Action_Escalation_Level_Amber;
                                                    } else {
                                                        if (newCaseMap.get(caseId).Case_Type__c != oldCaseMap.get(caseId).Case_Type__c && newCaseMap.get(caseId).Case_Type__c != NULL) {
                                                            MC_Communication__c mcCommunicationRecord = new MC_Communication__c();
                                                            mcCommunicationRecord.Id = (Id) mapCaseIdAndCaseActionIdToCaseActionRecord.get((ID) newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType))).MC_Communication__c;
                                                            mcCommunicationRecord.Escalation_Date_Time__c = ((DateTime) newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c)).addSeconds(Integer.valueOf(mosEscalation.Duration__c));
                                                            listMCCommunicationToUpdate.add(mcCommunicationRecord);
                                                        }
                                                    }
                                                } else {
                                                    if (mosEscalation.Alternate_Escalation_Update__c != NULL) {
                                                        if (newCaseMap.get(caseId).get(mosEscalation.Alternate_Escalation_Update__c) != NULL) {
                                                            newCaseAction.Escalation_Update__c = (DateTime) newCaseMap.get(caseId).get(mosEscalation.Alternate_Escalation_Update__c);
                                                            if (escalationType != ConstantsUtility.Reached) {
                                                                newCaseAction.Escalation_Level__c = ConstantsUtility.Case_Action_Escalation_Level_Amber;
                                                            } else {
                                                                if (newCaseMap.get(caseId).Case_Type__c != oldCaseMap.get(caseId).Case_Type__c && newCaseMap.get(caseId).Case_Type__c != NULL) {
                                                                    MC_Communication__c mcCommunicationRecord = new MC_Communication__c();
                                                                    mcCommunicationRecord.Id = (Id) mapCaseIdAndCaseActionIdToCaseActionRecord.get((ID) newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType))).MC_Communication__c;
                                                                    mcCommunicationRecord.Escalation_Date_Time__c = ((DateTime) newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c)).addSeconds(Integer.valueOf(mosEscalation.Duration__c));
                                                                    listMCCommunicationToUpdate.add(mcCommunicationRecord);
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                newCaseAction.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Inactive;
                                            }
                                        } else {
                                            newCaseAction.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Inactive;
                                        }
                                        listCaseActionToUpdate.add(newCaseAction);
                                    }
                                }
                            }

                        }
                    }
                }
            }

            if (setPFOFSCaseId.size() > 0) {
                for (MC_Communication__c mcRecord : [SELECT Id,Status__c FROM MC_Communication__c WHERE Case__c IN :setPFOFSCaseId AND Type__c IN :ConstantsUtility.setPFOFS AND Status__c = :ConstantsUtility.MC_Communication_Status_Queued]) {
                    mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Cancelled;
                    listMCCommunicationToUpdate.add(mcRecord);
                }
            }

            if (setReachedCaseId.size() > 0) {
                for (MC_Communication__c mcRecord : [SELECT Id,Status__c FROM MC_Communication__c WHERE Case__c IN :setReachedCaseId AND Type__c IN :ConstantsUtility.setReached AND Status__c = :ConstantsUtility.MC_Communication_Status_Queued]) {
                    mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Cancelled;
                    listMCCommunicationToUpdate.add(mcRecord);
                }
            }

            if (listCaseActionToUpdate.size() > 0) {
                update listCaseActionToUpdate;
            }

            if (listMCCommunicationToUpdate.size() > 0) {
                update listMCCommunicationToUpdate;
            }

            if (listMCCommunicationToInsert.size() > 0) {
                insert listMCCommunicationToInsert;
            }

            if (listMOSCase.size() > 0) {
                FESyncServiceClass.publishPlatformEvent(listMOSCase, CaseTriggerHelper.setIntegrationUserId, oldCaseMap, isUpdate, mapCityIdToName, CaseTriggerHelper.mapIdToTechnicianId);
                CaseTriggerHelper.createCaseTeamMembers(JSON.serialize(listMOSCase), JSON.serialize(oldCaseMap), isInsert, isUpdate);
            }

        } catch (Exception e) {
            ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage() + ':' + e.getLineNumber(), 'MOS Case After Event', '', null);
        }

    }

    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to update the CCP info on case based on the Custom metadata
Return Type : Case
*/
    public void updateCCPOutboundCallingTime() {
        try {
            Map<String, Case_Escalations_Matrix_mdt__c> caseTypeVsCaseEscalationsMatrixMap = new Map<String, Case_Escalations_Matrix_mdt__c>();
            caseTypeVsCaseEscalationsMatrixMap = getCaseTypeVsCaseEscalationsMatrixMap(caseTypeVsCaseEscalationsMatrixMap);
            Id businessHourId = [SELECT Id FROM BusinessHours WHERE Name = :label.Business_Hour_Id].Id;

            for (Case caseObj : newCaseList) {
                if ((caseObj.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID || caseObj.RecordTypeId == ConstantsUtility.REPEAT_COMPLAINT_CASE_RECORD_TYPE_ID)
                        && caseObj.Dealer_Name__c != null && caseObj.Case_Type__c != null && caseObj.Case_Type__c == ConstantsUtility.COMPLAINT_CASE_TYPE && caseObj.Business_Area__c != null
                        && (caseObj.Business_Area__c == ConstantsUtility.SALES_CASE_BUSINESS_AREA || caseObj.Business_Area__c == ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA ||
                        caseObj.Business_Area__c == ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA)) {
                    String caseType = caseObj.Business_Area__c;
                    //String caseType = caseObj.Business_Area__c.contains(ConstantsUtility.SALES_CASE_BUSINESS_AREA) ? ConstantsUtility.SALES_CASE_BUSINESS_AREA : ConstantsUtility.CASE_TYPE_SERVICE;
                    // Condition 1
                    if (caseObj.CCP_Outbound_Call_Date_Time__c == null && caseObj.CCP_Attempt_No__c == null) {
                        caseType = caseType + '_' + 1;
                        caseObj = updateCCPInfo(caseTypeVsCaseEscalationsMatrixMap, caseObj, caseType, businessHourId);
                    }
                }
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'updateCCPOutboundCallingTime', '', null);
        }

    }
    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to update the CCP info on case based on the Custom metadata
Return Type : Case
*/
    public static Case updateCCPInfo(Map<String, Case_Escalations_Matrix_mdt__c> caseTypeVsCaseEscalationsMatrixMap, Case caseObj, String caseTypeKey, Id businessHourId) {
        if (caseTypeVsCaseEscalationsMatrixMap.containsKey(caseTypeKey)) {
            Case_Escalations_Matrix_mdt__c caseEscalationsMatrix = caseTypeVsCaseEscalationsMatrixMap.get(caseTypeKey);
            if (caseEscalationsMatrix.Time_to_Next_Escalation__c != null && caseEscalationsMatrix.CCP_Outbound_Call_To__c != null && caseObj.Assigned_Date__c != null) {
                caseObj.CCP_Outbound_Call_Date_Time__c = caseObj.Assigned_Date__c.addMinutes(Integer.valueOf(caseEscalationsMatrix.Time_to_Next_Escalation__c));
                //Id businessHourId = label.Business_Hour_Id;
                EnquiryEscalationService escalationService = new EnquiryEscalationService();
                caseObj.CCP_Outbound_Call_Date_Time__c = escalationService.checkBusinessHours(businessHourId, caseObj.CCP_Outbound_Call_Date_Time__c, Integer.valueOf(caseEscalationsMatrix.Time_to_Next_Escalation__c));
                caseObj.CCP_Outbound_Call_To__c = caseEscalationsMatrix.CCP_Outbound_Call_To__c;
                caseObj.CCP_Attempt_No__c = caseEscalationsMatrix.CCP_Attempt_No__c;
            }
        }
        // System.debug(caseTypeKey);
        return caseObj;


    }
    public static Map<String, Case_Escalations_Matrix_mdt__c> getCaseTypeVsCaseEscalationsMatrixMap(Map<String, Case_Escalations_Matrix_mdt__c> caseTypeVsCaseEscalationsMatrixMap) {
        for (Case_Escalations_Matrix_mdt__c matrix : [SELECT Id,Business_Area__c,Case_Type__c,CCP_Attempt_No__c,CCP_Outbound_Call_To__c,Time_to_Next_Escalation__c FROM Case_Escalations_Matrix_mdt__c WHERE Escalation_Type__c = :ConstantsUtility.ESCALATION_TYPE_CCP_INITIATION]) {
            caseTypeVsCaseEscalationsMatrixMap.put(matrix.Business_Area__c + '_' + Integer.valueOf(matrix.CCP_Attempt_No__c), matrix);
        }
        return caseTypeVsCaseEscalationsMatrixMap;
    }

    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This is the helper method to update the CCP information  like campaign id and related mobile numbers
Events : Before insert
Return Type : void
*/
    public void ccpCampaignDetection() {
        try {
            List<Case> cases = new List<Case>();
            for (Case caseObj : newCaseList) {
                // Check for Insert and Update
                Case oldCaseObj = Trigger.isUpdate ? oldCasemap.get(caseObj.Id) : null;
                cases.add(caseObj);
            }
            if (cases.size() > 0) {
                ccpCampaignDetectionHelper(cases, null);
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'ccpCampaignDetection', '', null);
        }
    }
    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This is the helper method to update the CCP information  like campaign id and related mobile numbers and called from Task Trigger Handler as well
Return Type : map of case
*/
    public static Map<Id, Case> ccpCampaignDetectionHelper(List<Case> cases, Map<Id, Case> caseMap) {
        // Map for the CaseAssignmentMatrix based on campaign Code
        Map<String, Case_Queue_Assignment_Matrix__mdt> campaignCodeVsCaseAssignmentMatrixMap = new Map<String, Case_Queue_Assignment_Matrix__mdt>();
        Map<String, Case_Queue_Assignment_Matrix__mdt> uniqueKeyVsCaseAssignmentMatrixMap = new Map<String, Case_Queue_Assignment_Matrix__mdt>();
        for (Case_Queue_Assignment_Matrix__mdt assignmentMatrix : [SELECT Id,Campaign_Code__c,CCP_Outbound_Call_To__c,Location__c,Mobile_Prefix__c,Channel__c,Case_Type__c, Business_Area__c,Primary_Category__c FROM Case_Queue_Assignment_Matrix__mdt WHERE Campaign_Code__c != null]) {
            campaignCodeVsCaseAssignmentMatrixMap.put(assignmentMatrix.Campaign_Code__c, assignmentMatrix);
            String uniqueKey = assignmentMatrix.Channel__c + assignmentMatrix.Case_Type__c + assignmentMatrix.Business_Area__c;
            uniqueKey += assignmentMatrix.CCP_Outbound_Call_To__c ;
            uniqueKey += assignmentMatrix.Primary_Category__c != null ? assignmentMatrix.Primary_Category__c : '';
            uniqueKeyVsCaseAssignmentMatrixMap.put(uniqueKey, assignmentMatrix);
        }
        System.debug(campaignCodeVsCaseAssignmentMatrixMap.keySet());
        if (!campaignCodeVsCaseAssignmentMatrixMap.isEmpty()) {
            Map<String, Campaign> campaignCodeVsCampaignMap = new Map<String, Campaign>();
            // Getting all the Campaigns based on campaign Code
            for (Campaign campaign : [SELECT Id,Campaign_Code__c FROM Campaign WHERE Campaign_Code__c IN :campaignCodeVsCaseAssignmentMatrixMap.keySet() AND RecordTypeId = :ConstantsUtility.CAMPAIGN_CALL_CAMPAIGN_RECORD_TYPE_ID]) {
                campaignCodeVsCampaignMap.put(campaign.Campaign_Code__c, campaign);
            }
            if (!campaignCodeVsCampaignMap.isEmpty()) {
                // Iterating onc case list to update the campaign id on it.
                for (Case caseObj : cases) {
                    // Check for Insert and Update
                    String uniqueKey = caseObj.Channel__c + caseObj.Case_Type__c + caseObj.Business_Area__c;
                    uniqueKey += caseObj.CCP_Outbound_Call_To__c ;
                    Case_Queue_Assignment_Matrix__mdt assignmentMatrix;
                    if (uniqueKeyVsCaseAssignmentMatrixMap.containsKey(uniqueKey)) {
                        assignmentMatrix = uniqueKeyVsCaseAssignmentMatrixMap.get(uniqueKey);
                    }
                    uniqueKey += caseObj.Primary_Category__c != null ? caseObj.Primary_Category__c : '';
                    // again getting the assignment Matrix with updated key if any
                    if (uniqueKeyVsCaseAssignmentMatrixMap.containsKey(uniqueKey)) {
                        assignmentMatrix = uniqueKeyVsCaseAssignmentMatrixMap.get(uniqueKey);
                    }
                    if (assignmentMatrix != null) {
                        String campaignCode = assignmentMatrix.Campaign_Code__c;
                        if (campaignCodeVsCampaignMap.containsKey(campaignCode)) {
                            caseObj.CampaignId__c = campaignCodeVsCampaignMap.get(campaignCode).Id;  // Updating the CampaignId on case object
                        }
                        String mobilePreFix = assignmentMatrix.Mobile_Prefix__c != null ? assignmentMatrix.Mobile_Prefix__c : '';
                        /**  If the CCP Outbound Call To is equal to Call To Customer */
                        if (caseObj.CCP_Outbound_Call_To__c == ConstantsUtility.CCP_OUTBOUND_CALL_TO_CUSTOMER) {
                            caseObj.Mobile_Number_1__c = mobilePreFix + caseObj.Mobile_Number__c;
                            /**  If the CCP Outbound Call To is equal to Call To Dealership */
                        } else if (caseObj.CCP_Outbound_Call_To__c == ConstantsUtility.CCP_OUTBOUND_CALL_TO_DEALERSHIP && caseObj.Stakeholders_JSON__c != null && caseObj.Selected_Hierarchy_Type__c != null) {
                            // Calling method to get the phone number
                            Map<String, String> levelVsPhoneNumberMap = getMobileNumber(caseObj.Stakeholders_JSON__c, caseObj.Selected_Hierarchy_Type__c);
                            if (levelVsPhoneNumberMap.containsKey(ConstantsUtility.NOTIFIER_L2A)) {
                                caseObj.Mobile_Number_1__c = mobilePreFix + levelVsPhoneNumberMap.get(ConstantsUtility.NOTIFIER_L2A);
                            } else if (levelVsPhoneNumberMap.containsKey(ConstantsUtility.NOTIFIER_L2B)) {
                                caseObj.Mobile_Number_1__c = mobilePreFix + levelVsPhoneNumberMap.get(ConstantsUtility.NOTIFIER_L2B);
                            } if (levelVsPhoneNumberMap.containsKey(ConstantsUtility.NOTIFIER_L3A)) {
                                caseObj.Mobile_Number_2__c = mobilePreFix + levelVsPhoneNumberMap.get(ConstantsUtility.NOTIFIER_L3A);
                            }if (levelVsPhoneNumberMap.containsKey(ConstantsUtility.NOTIFIER_L4)) {
                                caseObj.Mobile_Number_3__c = mobilePreFix + levelVsPhoneNumberMap.get(ConstantsUtility.NOTIFIER_L4);
                                caseObj.Mobile_Number_4__c = caseObj.Mobile_Number_3__c;
                            }

                        }
                    }
                    if (caseMap != null) {
                        caseMap.put(caseObj.Id, caseObj);
                    }
                }
            }
        }
        return caseMap;
    }

    private static Map<String, String> getMobileNumber(String StakeholderHierarchyString, String selectedHierarchyType) {

        List<StakeholderHierarchy.Sales> hierarchyList = StakeholderUtility.getSelectedHierarchyList(StakeholderHierarchyString, selectedHierarchyType);
        Map<String, String> levelVsPhoneNumberMap = new Map<String, String>();
        if (hierarchyList.size() > 0) {
            //            System.debug('hierarchyList ' + hierarchyList);
            // Iteration over the Stakeholder list to get the phone numbers
            for (StakeholderHierarchy.Sales holder : hierarchyList) {
                String phone ;// = System.Label.Default_Phone_L4;
                String tempNumber;
                if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L2A) {
                    phone = holder.phone != '' ? holder.phone : phone;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L2A, phone);
                    tempNumber = phone;
                } else if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L2B) {
                    phone = holder.phone != '' ? holder.phone : phone;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L2B, phone);
                    tempNumber = phone;
                } if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L3A) {
                    phone = holder.phone != '' ? holder.phone : tempNumber;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L3A, phone);
                    tempNumber = phone;
                } if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L4 && phone != '') {
                    phone = holder.phone != '' ? holder.phone : tempNumber;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L4, phone);
                }
            }
        }
        return levelVsPhoneNumberMap;
    }

    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to update the if of the L3A and L4 user
Events : Before insert and before Update
Return Type : void
*/
    public void populateL3AL4AndStatus() {
        try {
            for (Case caseObj : newCaseList) {
                // Check for Insert and Update
                if (Trigger.isInsert || (Trigger.isUpdate && caseObj.Stakeholders_JSON__c != oldCasemap.get(caseObj.Id).Stakeholders_JSON__c) && caseObj.Selected_Hierarchy_Type__c != null) {
                    List<StakeholderHierarchy.Sales> hierarchyList = StakeholderUtility.getSelectedHierarchyList(caseObj.Stakeholders_JSON__c, caseObj.Selected_Hierarchy_Type__c);
                    for (StakeholderHierarchy.Sales holder : hierarchyList) {
                        if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L3A && holder.recordId != null && holder.recordId != '') {
                            caseObj.L3_Stakeholder__c = holder.recordId;
                        } else if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L4 && holder.recordId != null && holder.recordId != '') {
                            caseObj.L4_Stakeholder__c = holder.recordId;
                        }
                    }
                }
                // Updating the status if QC check fail
                if (caseObj.QC_Status__c == ConstantsUtility.QC_STATUS_NOT_OK && Trigger.isUpdate) {
                    caseObj.Status = ConstantsUtility.CASE_STATUS_ON_DISCARDED;
                }
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'populateL3AL4', '', null);
        }
    }

    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used toUpdate the QA/Qc info on case
Events : before update
Return Type : void
*/
    public void updateQCInfo() {
        try {
            Set<Id> closedCaseIds = new Set<Id>();
            for (Case newCase : newCaseList) {
                Case oldCase = oldCasemap.get(newCase.Id);
                // Updated Escalation Info on closed case
                if (newCase.IsClosed || newCase.Status == ConstantsUtility.CASE_CLOSED || newCase.Status == ConstantsUtility.CASE_STATUS_TRANSFERRED
                        || newCase.Status == ConstantsUtility.CASE_STATUS_ON_DUPLICATE || newCase.Status == ConstantsUtility.CASE_STATUS_ON_DISCARDED
                        || newCase.Status == ConstantsUtility.LEGAL) {
                    newCase.Next_Escalation_Date__c = null;
                    newCase.CCP_Next_Escalation_Date_Time__c = null;
                    newCase.Next_Escalation_Level__c = null;
                    newCase.CCP_Next_Escalated_Level__c = null;
                    closedCaseIds.add(newCase.Id);
                }
                // Condition 1 :  When the QA team updates details on the case and discarded case
                if (newCase.QC_Status__c != null && (newCase.QC_Status__c != oldCase.QC_Status__c || newCase.QC_Remarks__c != oldCase.QC_Remarks__c)) {
                    newCase.QC_Date_Time__c = Datetime.now();
                    newCase.QC_Done_By__c = UserInfo.getUserId();
                }
            }
            if (!closedCaseIds.isEmpty()) {
                // FOR CLOSE THE MILESTONES
                List<String> milestoneNames = new List<String>();
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_CASE_CLOSURE_TIME);
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_FIRST_RESPONSE);
                MilestoneUtils.completeMilestone(closedCaseIds, milestoneNames, DateTime.now());
            }


        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'updateQCInfo', '', null);
        }
    }

    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to send the chatter notification to L1, L2A and L3A
Events : after update
Return Type : void
*/
    public void sendChatterNotificationOnQC() {
        try {
            // Custom setting to store Notification messages w.r.t to Developer Recordtype Name
            Map<String, Approval_Notification_Setting__c> approvalTypeVsNotificationSettingsMap = new Map<String, Approval_Notification_Setting__c>();
            for (Approval_Notification_Setting__c notificationSetting : [SELECT Name,Approval_Type__c,Approved_Template__c,Notifiers__c FROM Approval_Notification_Setting__c WHERE isActive__c = true]) {
                approvalTypeVsNotificationSettingsMap.put(notificationSetting.Approval_Type__c, notificationSetting);
            }

            Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
            List<MC_Communication__c> mcCommunications = new List<MC_Communication__c>();
            for (Case newCase : newCaseList) {
                String message ;
                String stakeHolderHierarchyJSOn ;
                String selectedHierarchyType ;
                String notifiers ;
                Case oldCase = oldCasemap.get(newCase.Id);
                // Variables for Email
                String EmailType ;
                List<String> toEmailAddress = new List<String>();
                List<String> ccEmailAddress = new List<String>();
                // Condition 1 :  When the QA team updates details on the case and discarded case
                if (newCase.QC_Status__c == ConstantsUtility.QC_STATUS_NOT_OK && (newCase.QC_Status__c != oldCase.QC_Status__c || newCase.QC_Done_By__c != oldCase.QC_Done_By__c || newCase.QC_Remarks__c != oldCase.QC_Remarks__c)) {
                    message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Approved_Template__c;
                    notifiers = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Notifiers__c;
                    stakeHolderHierarchyJSOn = newCase.Stakeholders_JSON__c;
                    selectedHierarchyType = newCase.Selected_Hierarchy_Type__c;
                    EmailType = ConstantsUtility.QA_DISCARD;
                    // Condition 2 :  When the QA team updates details on the case
                } else if (newCase.QC_Status__c != oldCase.QC_Status__c || newCase.QC_Done_By__c != oldCase.QC_Done_By__c || newCase.QC_Remarks__c != oldCase.QC_Remarks__c) {
                    message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_DONE).Approved_Template__c;
                    notifiers = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Notifiers__c;
                    stakeHolderHierarchyJSOn = newCase.Stakeholders_JSON__c;
                    selectedHierarchyType = newCase.Selected_Hierarchy_Type__c;
                    EmailType = ConstantsUtility.QA_INITIATION;
                    //  Condition 3 :  When the QA team updates details on the case and Assign the case to new dealership
                } else if (CaseAssignmentService.isCategoryUpdated(newCase, oldCase) && oldCase.Dealer_Name__c != newCase.Dealer_Name__c) {
                    message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_DEALER_CHANGED).Approved_Template__c;
                    notifiers = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Notifiers__c;
                    stakeHolderHierarchyJSOn = oldCase.Stakeholders_JSON__c;
                    selectedHierarchyType = oldCase.Selected_Hierarchy_Type__c;
                    EmailType = ConstantsUtility.QA_NEW_ALLOCATION;
                }
                if (message != null && stakeHolderHierarchyJSOn != null && stakeHolderHierarchyJSOn != null) {
                    message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, newCase.CaseNumber) : message;
                    message = message.contains(ConstantsUtility.CASE_TYPE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_TYPE_REPLACEMENT, newCase.Case_Type__c) : message;
                    List<StakeholderHierarchy.Sales> holders = StakeholderUtility.getSelectedHierarchyList(stakeHolderHierarchyJSOn, selectedHierarchyType);
                    for (StakeholderHierarchy.Sales holder : holders) {
                        if (notifiers != null && notifiers.split(',').contains(holder.stakeHolder) && holder.recordId != '') {
                            if (!escalationUsers.containsKey(newCase.Id)) {
                                escalationUsers.put(newCase.Id, new Set<String>());
                            }
                            escalationUsers.get(newCase.Id).add(holder.recordId);
                            recordIdVsMessageMap.put(newCase.Id, message);
                        }
                        if (EmailType != null && holder.stakeHolder != null && holder.email != null) {
                            if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L1A || holder.stakeHolder == ConstantsUtility.NOTIFIER_L2A
                                    || holder.stakeHolder == ConstantsUtility.NOTIFIER_L3A) {
                                toEmailAddress.add(holder.email);
                            } else if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L4 || holder.stakeHolder == ConstantsUtility.NOTIFIER_L6A) {
                                ccEmailAddress.add(holder.email);
                            }
                        }
                    }
                }
                //Added by Nitin to create MC Records for SMS(Suzuki Connect) whem Case is Closed(7th Nov)//
                if (newCase.IsClosed == true && oldCaseMap.get(newCase.Id).Status != newCase.Status && newCase.RecordTypeId == ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID
                        && newCase.Business_Area__c == ConstantsUtility.ACCESSORIES_LINEOFBUSINESS && newCase.Case_Stage__c == 'Post Sales' &&
                        newCase.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT) {
                    if (String.isBlank(newCase.Closure_Mode__c) && newCase.Closure_Mode__c != ConstantsUtility.SATISFACTION_NOTE) {
                        EmailType = ConstantsUtility.SMS_CASE_CLOSURE_WO_SN;
                    } else if (String.isNotBlank(newCase.Closure_Mode__c) && newCase.Closure_Mode__c == ConstantsUtility.SATISFACTION_NOTE) {
                        EmailType = ConstantsUtility.SMS_CASE_CLOSURE_SN;
                    }
                }
                if (EmailType != null) {
                    MC_Communication__c communication = new MC_Communication__c();
                    communication.Type__c = EmailType;
                    communication.To_Address__c = String.join(toEmailAddress, ',');
                    communication.CC_Address__c = String.join(ccEmailAddress, ',');
                    communication.Case__c = newCase.Id;
                    communication.General_Field_1__c = newCase.Case_Sub_Type__c;
                    communication.Dealer_Field_1__c = newCase.Dealer_Name__c;
                    //Added by Nitin to create MC Records for SMS(Suzuki Connect) 7th Nov//
                    if (String.isnotblank(newCase.Mobile_Number__c) && (EmailType == ConstantsUtility.SMS_CASE_CLOSURE_WO_SN || EmailType == ConstantsUtility.SMS_CASE_CLOSURE_SN)) {
                        communication.Communication_Type__c = 'SMS';
                        communication.Recipient_Phone_Numbers__c = newCase.Mobile_Number__c;
                        communication.Phone_2__c = newCase.Mobile_Number__c;
                        communication.Status__c = ConstantsUtility.MC_Communication_Status_Queued;
                        communication.To_Address__c = '';communication.CC_Address__c = '';communication.Escalation_Date_Time__c = System.now();
                    }
                    //Added by Nitin to create MC Records for SMS(Suzuki Connect) 7th Nov//
                    mcCommunications.add(communication);
                }
            }
            if (!escalationUsers.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
            }
            if (mcCommunications.size() > 0) {
                insert mcCommunications;
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'sendChatterNotificationOnQC', '', null);
        }
    }

    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to update the External StakeHolder picklist
Events : after update
Return Type : void
*/
    public void updateExternalStakeHolder() {
        try {
            for (Case newCase : newCaseList) {
                newCase.External_Stakeholder__c = newCase.RecordTypeId == ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID ? ConstantsUtility.YES : newCase.External_Stakeholder__c;
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'updateExternalStakeHolder', '', null);
        }
    }


    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to update Customer on case based on the svocId populated on case
Events : after update
Return Type : void
*/
    public void populateCustomerBasedOnSVOCId() {
        try {
            Set<String> sVOCIdSet = new Set<String>();
            for (Case newCase : newCaseList) {
                if (newCase.SVOC_ID__c != null && oldCasemap.get(newCase.Id).SVOC_ID__c != newCase.SVOC_ID__c != null) {
                    sVOCIdSet.add(newCase.SVOC_ID__c);
                }
            }
            if (sVOCIdSet.size() > 0) {
                Map<String, Id> svocIdVsAccountIdMap = new Map<String, Id>();
                for (Account account : [SELECT Id,SVOC_ID__c FROM Account WHERE SVOC_ID__c IN :sVOCIdSet AND RecordType.Name = :ConstantsUtility.DEALER_RECORDTYPE]) {
                    svocIdVsAccountIdMap.put(account.SVOC_ID__c, account.Id);
                }
                if (!svocIdVsAccountIdMap.isEmpty()) {
                    for (Case newCase : newCaseList) {
                        if (newCase.SVOC_ID__c != null && svocIdVsAccountIdMap.containsKey(newCase.SVOC_ID__c)) {
                            newCase.Customer__c = svocIdVsAccountIdMap.get(newCase.SVOC_ID__c);
                        }
                    }
                }
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'populateCustomerBasedOnSVOCId', '', null);
        }
    }

    /**
    Author : Nitin
    Company : Techmatrix Consulting
    Description : This Method is used to change Parent Case Status to (On Hold Pending Dealer Support) when child Child Case is created as 'Device Connection To be checked' primary
                  Category(Suzuki Connect)
    Events : after insert
    Return Type : void
    */
    public void suzukiConnectParentCaseOnHold() {
        try {
            set<Id> childCaseId = new set<Id>();
            List<Case> updateParent = new List<Case>();
            for (Case newCase : newCaseList) {
                if (newCase.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID && String.isNotBlank(newCase.ParentId)
                        && newCase.Status == ConstantsUtility.STATUS_OPEN && newCase.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE
                        && (newCase.Secondary_Category__c == ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED || newCase.Secondary_Category__c == ConstantsUtility.REPLACEMENT)) {
                    childCaseId.add(newCase.Id);
                }
            }
            if (childCaseId.size() > 0) {
                Map<String, Group> developerNameVsQueueMap = ProjectUtility.getQueueMap();
                for (Case prntCase : [
                        Select ParentId,Parent.Status
                        from Case
                        where Id IN:childCaseId
                        AND (Parent.Job_Status__c = :ConstantsUtility.PENDING_FOR_DEVICE_INSPECTION OR Parent.Job_Status__c = :ConstantsUtility.RESOLVED_BY_STAKEHOLDER_REPLACEMENT)
                        AND Parent.Case_Stage__c = :ConstantsUtility.CASE_STAGE_POST_SALES
                        AND Parent.Business_Area__c = :ConstantsUtility.ACCESSORIES_LINEOFBUSINESS
                        AND Parent.RecordTypeId = :ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID
                        AND Parent.Primary_Category__c = :ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT
                        AND Parent.Status = :ConstantsUtility.STATUS_OPEN
                ]) {
                    Case cs = new Case();
                    cs.Id = prntCase.ParentId;
                    cs.On_Hold_Start_Date__c = date.today();
                    cs.IsStopped = true;
                    cs.Status = ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT;
                    if (developerNameVsQueueMap.containsKey(ConstantsUtility.ON_HOLD_PENDING_DEALER_SUPPORT_QUEUE)) {
                        cs.OwnerId = developerNameVsQueueMap.get(ConstantsUtility.ON_HOLD_PENDING_DEALER_SUPPORT_QUEUE).Id;
                    }
                    System.debug(cs);
                    updateParent.add(cs);
                }
                if (updateParent.size() > 0) {
                    //TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                    update updateParent;
                    //TriggerHandler.clearbypass('CaseTriggerHandler_Strategy');
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', exp.getMessage(), 'suzukiConnectParentCaseOnHold', '', null);
        }
    }

    /**
    Author : Nitin
    Company : Techmatrix Consulting
    Description : Method to update Parent Case(Suzuki Connect) to Inspection/Replacement Done when child(Complaint) case is Closed
    Events : afterUpdate
    Return Type : void
    */
    public void updateParentSuzukiInspectionDone() {
        try {
            set<Id> parentCaseId = new set<Id>();
            List<Case> updateCase = new List<Case>();
            for (Case newCase : newCaseList) {
                if (newCase.isClosed == true && String.isNotBlank(newCase.ParentId) && newCase.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID
                        && newCase.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE && (newCase.Secondary_Category__c == ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED) || newCase.Secondary_Category__c == ConstantsUtility.REPLACEMENT) {
                    parentCaseId.add(newCase.ParentId);
                }
            }
            if (parentCaseId.size() > 0) {
                Map<String, Case> suzukiParentCase = new Map<String, Case>([
                        Select Id,Status
                        from Case
                        where ID IN:parentCaseId
                        AND RecordTypeId = :ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID
                        AND Case_Stage__c = :ConstantsUtility.CASE_STAGE_POST_SALES
                        AND Business_Area__c = :ConstantsUtility.ACCESSORIES_LINEOFBUSINESS
                        AND Status = :ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT
                        AND Primary_Category__c = :ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT
                ]);
                if (suzukiParentCase.size() > 0) {
                    Map<String, Group> developerNameVsQueueMap = ProjectUtility.getQueueMap();
                    for (Case newCase : newCaseList) {
                        if (newCase.isClosed == true &&
                                String.isNotBlank(newCase.ParentId) &&
                                newCase.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID &&
                                newCase.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE &&
                                (newCase.Secondary_Category__c == ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED || newCase.Secondary_Category__c == ConstantsUtility.REPLACEMENT) && suzukiParentCase.containsKey(newCase.ParentId)) {
                            Case cs = new Case();
                            cs.Id = newCase.ParentId;
                            cs.On_Hold_End_Date__c = (newCase.ClosedDate).Date();
                            cs.IsStopped = false;
                            cs.Status = ConstantsUtility.INSPECTION_REPLACEMENT_DONE;
                            if (newCase.Channel__c == 'Nexa' && developerNameVsQueueMap.containsKey(ConstantsUtility.NEXA_SUZUKI_CONNECT_QUEUE)) {
                                cs.OwnerId = developerNameVsQueueMap.get(ConstantsUtility.NEXA_SUZUKI_CONNECT_QUEUE).Id;

                            } else if (newCase.Channel__c == 'Arena' && developerNameVsQueueMap.containsKey(ConstantsUtility.ARENE_SUZUKI_CONNECT_QUEUE)) {
                                cs.OwnerId = developerNameVsQueueMap.get(ConstantsUtility.ARENE_SUZUKI_CONNECT_QUEUE).Id;

                            }
                            updateCase.add(cs);
                        }
                    }
                    if (updateCase.size() > 0) {
                        update updateCase;
                    }
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', exp.getMessage(), 'updateParentSuzukiInspectionDone', '', null);
        }
    }

    /**
Author : Nitin
Company : Techmatrix Consulting
Description : This Method is used to send chatter Notifications when Case is On Hold
Events : after Update
Return Type : void
*/
    public void suzukiConnectOnHoldChatterNotifications() {
        try {
            Set<Id> categoryIds = new Set<Id>(); // Set to store the lower most category id from the case
            // map  of case recordid with set of Notifiers
            map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
            // map  of id with message
            map<Id, string> recordIdVsMessageMap = new map<Id, string>();
            List<Case> caseList = new List<Case>();
            // map to store Case Resolution Escalation Details.
            map<string, Case_Escalations_Matrix_mdt__c> caseResolutionCaseEscaltionMap = new map<string, Case_Escalations_Matrix_mdt__c>();
            // helper method to retrieve records from Case Escalation Matrix metadata for Case Resolution 
            //caseResolutionCaseEscaltionMap = CaseEscalationService.getEscalationsMatrices(ConstantsUtility.CASE_STATUS_ON_HOLD);
            List<MC_Communication__c> createMC = new List<MC_Communication__c>();
            for (Case cs : newCaseList) {
                if (oldCaseMap.get(cs.Id).Status != cs.Status && (cs.Status == ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT || cs.Status == ConstantsUtility.CASE_STATUS_ON_HOLD)
                        && cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT) {
                    categoryIds.add(CaseAssignmentService.getCategoryId(cs));
                    caseList.add(cs);
                }
            }
            if (categoryIds.size() > 0 && caseList.size() > 0) {
                categoryIdVsMapOfRegionAndRecipientMasterMap = CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(categoryIds);
                // stakeholder mapping
                map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders = CaseEscalationService.mapOfcaseIdWithMapOfStakeHolders(caseList);
                system.debug('mapOfCaseIdWithStakeHolders--->' + mapOfCaseIdWithStakeHolders);
                for (Case caseObj : newCaseList) {
                    if (oldCaseMap.get(caseObj.Id).Status != caseObj.Status && (caseObj.Status == ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT || CaseObj.Status == ConstantsUtility.CASE_STATUS_ON_HOLD)
                            && caseObj.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT) {
                        map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails = new map<string, StakeholderHierarchy.Sales>();
                        List<String> toNotifiers = new List<String>();
                        List<String> ccNotifiers = new List<String>();
                        List<String> toAddress = new List<String>();
                        List<String> ccAddres = new List<String>();
                        if (mapOfCaseIdWithStakeHolders.containskey(caseObj.Id) && mapOfCaseIdWithStakeHolders.get(caseObj.Id).size() > 0) {
                            mapOFStakeholderWithdetails = mapOfCaseIdWithStakeHolders.get(caseObj.Id);
                        }
                        if (mapOFStakeholderWithdetails.size() > 0) {
                            toNotifiers = (categoryIdVsMapOfRegionAndRecipientMasterMap.get(caseObj.Secondary_Category_ID__c).get('All').Level_0_To__c).split('\\;');
                            ccNotifiers = (categoryIdVsMapOfRegionAndRecipientMasterMap.get(caseObj.Secondary_Category_ID__c).get('All').Level_0_Cc__c).split('\\;');
                            set<String> recordId = new set<String>();
                            //Fetching To Address for MC Record
                            if (toNotifiers.size() > 0) {
                                for (string str : toNotifiers) {
                                    /*Commenting because for On Hold at Level 0 To users are not SF Users
/*if (((mapOFStakeholderWithdetails.get(str).recordId).startsWith('005') || (mapOFStakeholderWithdetails.get(str).recordId).startsWith('00G')) && 
mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).recordId)) {
recordId.add(mapOFStakeholderWithdetails.get(str).recordId); }*/
                                    if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)) {
                                        toAddress.add(mapOFStakeholderWithdetails.get(str).email);
                                    }
                                }
                            }//Fetching CC Address for MC Record
                            if (ccNotifiers.size() > 0) {
                                for (string str : ccNotifiers) {
                                    /*Commenting because for On Hold CC users are not required to be notified
if (((mapOFStakeholderWithdetails.get(str).recordId).startsWith('005') || (mapOFStakeholderWithdetails.get(str).recordId).startsWith('00G')) && 
mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).recordId)) {
recordId.add(mapOFStakeholderWithdetails.get(str).recordId); }*/
                                    if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)) {
                                        ccAddres.add(mapOFStakeholderWithdetails.get(str).email);
                                    }
                                }
                            }
                            /*if(recordId.size()>0){
recordIdVsMessageMap.put(caseObj.Id,caseObj.Case_Type__c+' ref. no. '+caseObj.CaseNumber+' is submitted for Technical Hold request');
recordIdVdNotifiersMap.put(caseObj.Id,recordId);
}*/
                            if (toAddress.size() > 0 || ccAddres.size() > 0) {
                                MC_Communication__c mc = new MC_Communication__c();
                                mc.Case__c = caseObj.Id;
                                mc.To_Address__c = (String.valueOf(toAddress)).replaceAll('[()\\s+]', '');
                                mc.CC_Address__c = (String.valueOf(ccAddres)).replaceAll('[()\\s+]', '');
                                mc.Type__c = ConstantsUtility.SINGLE_HOLD_INITIATION;
                                mc.Escalation_Date_Time__c = System.Now();
                                mc.Status__c = ConstantsUtility.MC_Communication_Status_Queued;
                                mc.Communication_Type__c = ConstantsUtility.EMAIL;
                                createMC.add(mc);
                            }
                        }
                    }
                }
                // method to send chatter notification
                if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                    ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
                }
                if (createMC.size() > 0) {
                    insert createMC;
                }
            }

        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', exp.getMessage(), 'suzukiConnectOnHoldChatterNotifications', '', null);
        }
    }
    /**
    Author : Sunit Kumar Chand
    Company : Techmatrix Consulting
    Description : 
    Events : after update
    Return Type : void
    */
    public void createSuzukiConnetFeedpost() {
        try {
            List<FeedItem> feedItemList = new List<FeedItem>();
            for (Case cs : newCaseList) {
                if (oldCaseMap.get(cs.Id).Suzuki_Connect_Remark__c != cs.Suzuki_Connect_Remark__c
                        && cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT) {
                    FeedItem fi = CaseActionCreation.getFeedItem(cs.id, cs.Suzuki_Connect_Remark__c, ConstantsUtility.TEXT_POST, null);
                    feedItemList.add(fi);
                }
            }
            if (feedItemList.size() > 0) {
                insert feedItemList;
            }
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', ex.getMessage(), 'createSuzukiConnetFeedpost', '', null);
        }
    }
    /**
    Author : Nitin
    Company : Techmatrix Consulting
    Description : MEthod to update Escalation date to when Case is on hold/Inspection Done
    Events : after update
    Return Type : void
    */
    public void updateSuzukiConnectMCrecords() {
        try {
            Set<Id> caseId = new Set<Id>();
            List<MC_Communication__c> mcUpdate = new List<MC_Communication__c>();
            for (Case cs : newCaseList) {
                if (oldCaseMap.get(cs.Id).Status != cs.Status && (cs.Status == ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT || cs.Status == ConstantsUtility.INSPECTION_REPLACEMENT_DONE)
                    && cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT) {
                        caseId.add(cs.Id);
                    } //Added by Nitin on 07/01/2021
                else if(oldCaseMap.get(cs.Id).Status != cs.Status && cs.Status == ConstantsUtility.CASE_STATUS_ON_HOLD
                        && cs.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT){
                            caseId.add(cs.Id);
                        }//Added by Nitin on 07/01/2021
            }
            if (caseId.size() > 0) {
                for (MC_Communication__c mc : [
                        Select ID,Type__c,Case__c,Case__r.Status,Case__r.Next_Escalation_Date__c
                        From MC_Communication__c
                        where
                        Type__c = :ConstantsUtility.DEALER_RESOLUTION_ESCALATION
                        AND Status__c = :ConstantsUtility.MC_Communication_Status_Queued
                        AND Case__c IN:caseId
                ]) {//Added ConstantsUtility.CASE_STATUS_ON_HOLD by Nitin on 07/01/2021  
                    if (mc.Case__r.Status == ConstantsUtility.ON_HOLD_DEALER_PENDING_DEALER_SUPPORT || mc.Case__r.Status == ConstantsUtility.INSPECTION_REPLACEMENT_DONE
                       || mc.Case__r.Status == ConstantsUtility.CASE_STATUS_ON_HOLD){
                        MC_Communication__c mrec = new MC_Communication__c();
                        mrec.Id = mc.Id;
                        mrec.Escalation_Date_Time__c = mc.Case__r.Next_Escalation_Date__c;
                        mcUpdate.add(mrec) ;
                    }

                }
                if (mcUpdate.size() > 0) {
                    update mcUpdate;
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', exp.getMessage(), 'updateSuzuiConnectMCrecords', '', null);
        }
    }

    /**
    Author : Nitin
    Company : Techmatrix Consulting
    Description : This Method is used to mark the milestone to Closed when Suzuki Connect Case are marked to Closed
    Events : before insert
    Return Type : void
    */
    public void updateMileStonetoCloseforSuzukiConnect() {
        try {
            Set<Id> closedCaseIds = new Set<Id>();
            //Loop through the Case Action records
            for (Case cas : this.newCaseList) {
                /** Collecting the case ids Closed Suzuki Connect Cases**/
                if (cas.isClosed == true && cas.Business_Area__c == ConstantsUtility.ACCESSORIES_LINEOFBUSINESS
                        && cas.Case_Stage__c == ConstantsUtility.CASE_STAGE_POST_SALES
                        && cas.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT) {
                    closedCaseIds.add(cas.Id);
                }
            }
            if (closedCaseIds.size() > 0) {
                List<String> milestoneNames = new List<String>();
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_CASE_CLOSURE_TIME);
                MilestoneUtils.completeMilestone(closedCaseIds, milestoneNames, DateTime.now());
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', exp.getMessage(), 'updateMileStonetoCloseforSuzukiConnect', '', null);
        }
    }

    /**
    Author : Nitin
    Company : Techmatrix Consulting
    Description : This Method is used to restrict child Case creation for Suzuki Connect(Device Connection To be checked) if an open case already exist
    Events : before insert
    Return Type : void
    */
    public void restrictChildCaseCreation() {
        try {

            set<Id> parentCaseId = new set<Id>();
            Map<String, List<String>> parentChildCaseIdMap = new Map<String, List<String>>();
            for (Case newCase : newCaseList) {
                if (String.isNotBlank(newCase.ParentId) && newCase.Status == ConstantsUtility.STATUS_OPEN && (newCase.Secondary_Category__c == ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED || newCase.Secondary_Category__c == ConstantsUtility.REPLACEMENT)
                        && newCase.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID && newCase.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE) {
                    parentCaseId.add(newCase.ParentId);
                }
            }
            for (Case cs : [
                    Select Id,Parent.Id,Parent.Status
                    from Case
                    where Parent.Id IN:parentCaseId AND RecordTypeId = :ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID
                    AND Primary_Category__c = :ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE AND Secondary_Category__c = :ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED
                    AND Status = 'Open'
                    AND Parent.RecordTypeId = :ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID
            ]) {
                if (parentChildCaseIdMap.containsKey(cs.Parent.Id)) {
                    parentChildCaseIdMap.get(cs.Parent.Id).add(cs.Id);
                } else {
                    parentChildCaseIdMap.put(cs.Parent.Id, new List<String>{
                            cs.Id
                    });
                }
            }
            for (Case newCase : newCaseList) {
                if (String.isNotBlank(newCase.ParentId) && newCase.Status == ConstantsUtility.STATUS_OPEN && (newCase.Secondary_Category__c == ConstantsUtility.DEVICE_CONNECTION_TO_BE_CHECKED || newCase.Secondary_Category__c == ConstantsUtility.REPLACEMENT)
                        && newCase.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID && newCase.Primary_Category__c == ConstantsUtility.SUZUKI_CONNECT_DEALER_ASSISTANCE
                        && parentChildCaseIdMap.containsKey(newCase.ParentId)) {
                    newCase.addError(label.Child_Case_Restrict);
                }
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('CaseTriggerStratergyHelper', exp.getMessage(), 'restrictChildCaseCreation', '', null);
        }
    }

    /**
    Author : Deepak Kumar
    Company : Techmatrix Consulting
    Description : This method is used to Send the Chatter Notification to the StakeHolder on Case Creation
    Events : after insert
    Return Type : void
    */
    public void sendCaseRegistrationNotification() {
        try {
            System.debug('sendCaseRegistrationNotification ');
            Set<String> sVOCIdSet = new Set<String>();
            Map<String, Approval_Notification_Setting__c> notificationTypeVsNotificationMap = CaseAssignmentService.getNotificationTypeVsNotificationMap();
            if (!notificationTypeVsNotificationMap.isEmpty()) {
                Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
                Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
                for (Case newCase : newCaseList) {
                    System.debug(newCase.Case_Registration_Notifiers_Internal__c);
                    if (trigger.isInsert && newCase.Case_Registration_Notifiers_Internal__c != null && newCase.Case_Registration_Notifiers_Internal__c.split(ConstantsUtility.COMMA).size() > 0 && notificationTypeVsNotificationMap.containsKey(newCase.Case_Type__c)) {
                        String message = notificationTypeVsNotificationMap.get(newCase.Case_Type__c).Approved_Template__c;
                        message = getBindedMessage(message, newCase);
                        System.debug('message ' + message);
                        List<String> notifiersIds = newCase.Case_Registration_Notifiers_Internal__c.split(ConstantsUtility.COMMA);
                        if (notifiersIds != null && notifiersIds.size() > 0) {
                            Set<String> ids = new Set<String>();
                            ids.addAll(notifiersIds);
                            escalationUsers.put(newCase.Id, ids);
                            recordIdVsMessageMap.put(newCase.Id, message);
                        }
                    }
                }
                System.debug(escalationUsers);
                // Sending the notifications
                if (!escalationUsers.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                    System.debug('OK ');
                    ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
                    // Chatter Notifications Sent
                }
            }


        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'sendCaseRegistrationNotification', '', null);
        }
    }

    private static String getBindedMessage(String message, Case newCase) {
        message = message.contains(ConstantsUtility.CASE_SUB_TYPE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_SUB_TYPE_REPLACEMENT, newCase.Case_Sub_Type__c) : message;
        message = message.contains(ConstantsUtility.CHANNEL_REPLACEMENT) ? message.replace(ConstantsUtility.CHANNEL_REPLACEMENT, newCase.Channel__c) : message;
        message = message.contains(ConstantsUtility.BUSINESS_AREA_REPLACEMENT) ? message.replace(ConstantsUtility.BUSINESS_AREA_REPLACEMENT, newCase.Business_Area__c) : message;
        message = message.contains(ConstantsUtility.CASE_STAGE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_STAGE_REPLACEMENT, newCase.Case_Stage__c) : message;
        message = message.contains(ConstantsUtility.CASE_TYPE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_TYPE_REPLACEMENT, newCase.Case_Type__c) : message;
        message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, newCase.CaseNumber) : message;
        message = message.contains(ConstantsUtility.DEALER_CODE_REPLACEMENT) ? message.replace(ConstantsUtility.DEALER_CODE_REPLACEMENT, newCase.Dealer_Code__c) : message;

        return message;
    }

    /**
    Author : Sunit
    Company : Techmatrix Consulting
    Description : This wrapper is used to For PANA CRM Case creation
    */
    public Class PanaCRMRecordCreation {
        String vinNo;
        String imeiNo;
        String tcuNo;
        String tcuIccid;
        String dealerName;
        String dealerAddress;
        String dealerContactNumber;
        String tcuSaleDate;
        String tcuExpiryDate;
        String customerName;
        String customerContact;
        String address;
        String state;
        String city;
        String country;
        String postalCode;
        String sfdcId;
        String vehicleModel;
        String serviceActivationDate;
        String tcuServiceStatus;
        String primaryContactNo;
        String odometerReading;
        String remark;
        public PanaCRMRecordCreation(String vinNo, String imeiNo, String tcuNo, String tcuIccid,
                String dealerName,
                String dealerAddress,
                String dealerContactNumber,
                String tcuSaleDate,
                String tcuExpiryDate,
                String customerName,
                String customerContact,
                String address,
                String state,
                String city,
                String country,
                String postalCode,
                String sfdcId,
                String vehicleModel,
                String serviceActivationDate,
                String tcuServiceStatus,
                String primaryContactNo,
                String odometerReading,
                String remark) {
            this.vinNo = vinNo;
            this.imeiNo = imeiNo;
            this.tcuNo = tcuNo;
            this.tcuIccid = tcuIccid;
            this.dealerName = dealerName;
            this.dealerAddress = dealerAddress;
            this.dealerContactNumber = dealerContactNumber;
            this.tcuSaleDate = tcuSaleDate;
            this.tcuExpiryDate = tcuExpiryDate;
            this.customerName = customerName;
            this.customerContact = customerContact;
            this.address = address;
            this.state = state;
            this.city = city;
            this.country = country;
            this.postalCode = postalCode;
            this.sfdcId = sfdcId;
            this.vehicleModel = vehicleModel;
            this.serviceActivationDate = serviceActivationDate;
            this.tcuServiceStatus = tcuServiceStatus;
            this.primaryContactNo = primaryContactNo;
            this.odometerReading = odometerReading;
            this.remark = remark;
        }

    }

    public void updateCaseMapFields() {

        for (Case cs : this.newCaseList) {

            //cs.Case_NewMap__c = JSON.serialize(cs);
            if (cs.Id != Null && this.newCaseMap.containsKey(cs.Id)) {
                //    cs.Case_OldMap__C = JSON.serialize(this.newCaseMap.get(cs.Id));
            }

        }

    }

    /**
    Author : Deepak
    Company : Techmatrix Consulting
    Description : This method used copy the Customer Address On Case Record
    */
    public void copyCustomerAddressOnCase() {
        try {
            Set<Id> customerIds = new Set<Id>();
            for (Case newCase : newCaseList) {
                if (trigger.isInsert && newCase.Customer__c != null) {
                    customerIds.add(newCase.Customer__c);
                }
            }
            if (!customerIds.isEmpty()) {
                Map<Id,Account> idVsCustomerMap = new Map<Id,Account>([Select Id,BillingStreet,BillingCity,BillingState, BillingPostalCode,BillingCountry FROM Account Where Id IN: customerIds ]);
                for (Case newCase : newCaseList) {
                    if (trigger.isInsert && newCase.Customer__c != null && idVsCustomerMap.containsKey(newCase.Customer__c)) {
                        Account customerAccount = idVsCustomerMap.get(newCase.Customer__c);
                        String address = '';
                        address += customerAccount.BillingStreet != null ? customerAccount.BillingStreet + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingCity != null ? customerAccount.BillingCity + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingState != null ? customerAccount.BillingState + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingPostalCode != null ? customerAccount.BillingPostalCode + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingCountry != null ? customerAccount.BillingCountry + ConstantsUtility.COMMA : address;
                        newCase.Address__c = address.length() < 255 ? address : address.substring(0, 255);
                    }
                }
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerStrategyHelper', exp.getMessage(), 'copyCustomerAddressOnCase', '', null);
        }
    }
}