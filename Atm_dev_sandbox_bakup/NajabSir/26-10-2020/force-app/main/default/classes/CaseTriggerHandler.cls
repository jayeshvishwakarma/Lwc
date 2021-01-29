/**
* @File Name          : CaseTriggerHandler.cls
* @Description        : Trigger handler class for case
* @Author             : Nishant Prajapati
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 4/20/2020, 11:29:29 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM         Nishant                Initial Version
* 1.1A   21/02/2020, 11:15:00 AM        Nitin                 Made changes in Map to store Account instead of ID and 
Made changes in query to fetch Dealer Account
* 1.1A   09/03/2020, 11:15:00 AM        Sunit                 Add shareCustomerRecord method
* 1.1A   12/03/2020, 11:15:00 AM        Sunit                 Add updateSubject method
**/


/** =============================================================================================================== */
/** =============================================================================================================== */

/** DO NOT USE THIS CLASS, ALL CHANGES MOVED TO CaseTriggerStrategyHelper CLASSS
 *
 */
/** =============================================================================================================== */
/** =============================================================================================================== */



public with sharing class CaseTriggerHandler extends TriggerHandler {
   /**
   
    Bypass_Setting__c bypassSetting = Bypass_Setting__c.getInstance(UserInfo.getUserId());
    private list<Case> newCaseList; //Used to store the list of new Cases
    private Map<Id, Case> oldCaseList; //Used to store the list of old Cases
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
    List<Account> listMSAllianzRecord;
    
    
    public CaseTriggerHandler() {
        this.newCaseList = (List<Case>) Trigger.new;
        this.oldCaseList = (Map<Id, Case>) Trigger.oldMap;
        caseOwnerIdSet = new set<Id>();
        caseOwnerToUserAccountMap = new Map<Id, Account>();
        this.OldCasemap = (map<id, Case>) Trigger.oldmap;
        this.newCaseMap = (Map<Id, Case>) Trigger.NewMap;
    }
    
    public override void beforeInsert() {

        //update subject of the case for outbound dealer cases
        updateSubject();

        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, null);
        //update standard Account field with owner's User Account for controlling case visibility
        updateUserAccountonCase();
        //Added by Anas Yar Khan on 12th July to perform actions on MOS Complaints Case
        CaseTriggerHelper.getData();
        updateFieldsOnMOSCase();
        // Added by Gitika
        updateEscalationDetails();
        markOrFilterQueryAsSpam();
        // Added by Deepak 4 Aug.
        updateCCPOutboundCallingTime();
        ccpCampaignDetection();
        // Added by Deepak 11 Aug.
        populateL3AL4AndStatus();
        updateEmailQueueAndTimeAssignedToAgent();
        // Added by Deepak 25 Aug.
        updateExternalStakeHolder();
    }
    
    //Method to be run on After Insert
    public override void afterInsert() {
        dncCaseSubmitforApproval();
        //share customer record with dealer group
        shareCustomerRecord();
        caseTeamCreation();
        // FOR TESTING
        CaseSharingService.shareCaseToMembers(newCaseList);
        //Added by Anas Yar Khan on 27th July
        listMSAllianzRecord = CaseTriggerHelper.getMSAllianzRecord();
        MOSCaseAfterEvent();
        postChatterAndMCRecordsEscalation();
        markQueryAsSpam();
        

    }
    
    public override void beforeUpdate() {
        //update reason for lost if case is moved from lost to another stage
        updateCaseReasonForLost();
        //update standard Accountfield with owner's User Account for controlling case visibility

        caseBulkHoldRequest();
        updateCaseResolutionTime();
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);
        //update standard Account field with owner's User Account for controlling case visibility
        updateUserAccountonCase();
        
        //Added by Anas Yar Khan on 12th July to perform actions on MOS Complaints Case
        CaseTriggerHelper.getData();
        CaseTriggerHelper.getStageValidationMetadataRecords();
        updateFieldsOnMOSCase();
        updatePreviousOwner();
        updateEscalationDetails();
        updateEmailQueueAndTimeAssignedToAgent();
        // Added by Deepak 11 Aug.
        populateL3AL4AndStatus();
        // Added by Deepak 25 Aug.
        populateCustomerBasedOnSVOCId();
        
        populateRevalidationType();
    }
    
    public override void afterUpdate() {
        System.debug('Inside afterUpdate');
        //update associated tasks to closed when a case is closed by Integration User
        updateRelatedCaseTasks();
        caseTeamCreation();
        // FOR TESTING
        CaseSharingService.shareCaseToMembers(newCaseList);
        //Added by Anas Yar Khan
        CaseTriggerHelper.getDataForCaseEscalation();
        listMSAllianzRecord = CaseTriggerHelper.getMSAllianzRecord();
        MOSCaseAfterEvent();
        postChatterAndMCRecordsEscalation();
        
        sendChatterNotificationOnQC();
        markMcCommunicationCancelled();
        
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
 
    public void caseTeamCreation() {
        System.debug('Inside caseTeamCreation');
        List<CaseTeamMember> ctmList = new List<CaseTeamMember>();
        
        for (Case cs : newCaseList) {
            if ((Trigger.isInsert == true || (Trigger.isUpdate == true && oldCaseList.get(cs.Id).get('ownerid') != cs.ownerid))
                && (cs.recordtypeid == RenewalRecTypeId || cs.recordtypeid == vehicleserviceRecTypeId
                    || cs.recordtypeid == dncRecTypeId)) {
                        caseOwnerIdSet.add(cs.OwnerId);
                    }
        }
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
                        caseObj.adderror(label.Spam_Query_Error_Message);
                    }
                if ((caseObj.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID ||
                     caseObj.RecordTypeId == ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID) && caseObj.Origin == ConstantsUtility.EMAIL && string.isNotBlank((caseObj.SuppliedEmail).toLowercase()) && mapOfEmailWithSpamObj.containsKey(caseObj.SuppliedEmail)) {
                         caseObj.adderror(label.Spam_Query_Error_Message);
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
 
    public void markMcCommunicationCancelled() {
        map<id, case> mapOfcase = new map<id, case>();
        List<MC_Communication__c> mcComList = new list<MC_Communication__c>();
        for (Case caseObj : newCaseList) {
            if (caseObj.CCP_Complete_Time__c != null || caseObj.IsClosed == true) {
                mapOfcase.put(caseObj.id, caseObj);
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
 
    public void updateEmailQueueAndTimeAssignedToAgent() {
        for (case caseobj : newCaseList) {
            if (trigger.isInsert && caseobj.recordTypeId == ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID && (String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OOG)) {
                caseobj.Email_Queue_Id__c = caseobj.OwnerId;
                caseobj.email__c = caseobj.SuppliedEmail != null ? caseobj.SuppliedEmail : null;
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
 
    public void updatePreviousOwner() {
        for (case caseobj : newCaseList) {
            if (oldCasemap.get(caseobj.Id).OwnerId != caseobj.OwnerId && (String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OOG)
                && (String.valueof(oldCasemap.get(caseobj.Id).OwnerId)).startsWith(ConstantsUtility.OO5)) {
                    caseobj.Previous_Owner__c = oldCasemap.get(caseobj.Id).OwnerId;
                }
            if ((String.valueof(caseobj.OwnerId)).startsWith(ConstantsUtility.OO5) && oldCasemap.get(caseobj.Id).OwnerId == caseobj.OwnerId
                && caseobj.Change_owner_to_Previous_owner__c == true && String.isNotBlank(caseobj.Previous_Owner__c)) {
                    caseobj.OwnerId = caseobj.Previous_Owner__c;
                    caseObj.status = ConstantsUtility.CASE_PENDING_MSIL_RESPONSE;
                    caseobj.Change_owner_to_Previous_owner__c = false;
                }
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
                    }
            }
            if (caseList.size() > 0) {
                // calling helper method for stakeholder mapping
                mapofCaseIdWithStakeHoldersmap = CaseActionTriggerHelper.mapOfcaseIdWithMapOfStakeHolders(caseList, ConstantsUtility.mapOfStakeholderJSONWithBulkHoldFields);
                
                for (case cs : caseList) {
                    // check for bulk hold cases
                    
                    boolean caninitiate = false;
                    
                    if (mapofCaseIdWithStakeHoldersmap.containskey(cs.Id) && mapofCaseIdWithStakeHoldersmap.get(cs.Id).size() > 0) {
                        for (string str : label.Bulk_Hold_intiators.split(';')) {
                            if (mapofCaseIdWithStakeHoldersmap.get(cs.Id).containskey(str) && mapofCaseIdWithStakeHoldersmap.get(cs.Id).get(str) == userinfo.getUserId().left(15)) {
                                caninitiate = true;
                                break;
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
Author: Sunit kumar chand
Company: Techmatrix
Description: It will share customer record to user
Inputs:
Returns:
History:
================
1.0     09 Mar 2020      Sunit     Initial Version
 
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
 
    public void updateSubject() {
        for (Case cs : newCaseList) {
            system.debug('updateSubject------->' + newCaseList);
            if (String.isBlank(cs.Subject) && RenewalRecTypeId == cs.RecordTypeId) {
                String policyNo = String.isEmpty(cs.Policy_No__c) ? '' : cs.Policy_No__c;
                String expiryDate = String.valueOf(cs.Expiry_Date__c) == null ? '' : String.valueOf(cs.Expiry_Date__c);
                list<string> expiryDateParts = expiryDate.split(' ');
                cs.Subject = String.isEmpty(cs.Type) ? '' : cs.Type + ' ' + policyNo + ' ' + expiryDateParts[0];
            }
            
            
            //Update the Status as Closed if Customer Satisfied with FCR Is Yes for Queries
            if ((cs.Case_Type__c == ConstantsUtility.DEALER_QUERY || cs.Case_Type__c == ConstantsUtility.MSIL_QUERY_CASE_TYPE) && cs.FCR_Conducted__c == ConstantsUtility.YES && cs.Customer_Satisfied_With_FCR__c == ConstantsUtility.YES) {
                cs.Status = ConstantsUtility.CASE_CLOSED;
            }
            
            if (cs.Status != ConstantsUtility.CASE_CLOSED) {
                //Assigned Entitlements to ATM Related Cases
                cs.EntitlementId = System.label.ATM_Entitlement_ID ;
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
            for (Case cs : newCaseList) {
                system.debug('newCaseList updateUserAccountonCase------>' + newCaseList);
                if ((Trigger.isInsert == true || (Trigger.isUpdate == true && oldCaseList.get(cs.Id).get('ownerid') != cs.ownerid))
                        && (cs.recordtypeid == RenewalRecTypeId || cs.recordtypeid == vehicleserviceRecTypeId || cs.recordtypeid == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID
                ||cs.recordtypeid == ConstantsUtility.DEALER_QUERY_FEEDBACK_CASE_RECORD_TYPE_ID)) {
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
 
    public void updateRelatedCaseTasks() {
        try {
            
            //return if this is not integration User updating the record
            if (UserInfo.getuserId() != System.label.Integration_User) {
                return;
            }
            
            list<case> insertedCases = new list<case>();
            for (case cs : newCaseList) {
                if (cs.recordtypeid == RenewalRecTypeId && oldCaseList.get(cs.Id).get('isClosed') != true && (cs.status == 'Lost' || cs.status == 'Converted')) {
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
 
    public void updateCaseReasonForLost() {
        try {
            if (UserInfo.getUserId() == System.label.Integration_User) {
                for (case cs : newCaseList) {
                    Case oldCase = oldCaseList.get(cs.Id);
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
     
    public void updateCaseResolutionTime() {
        try {
            for (Case caseObj : newCaseList) {
                if (caseObj.Status == ConstantsUtility.CASE_STATUS_RESOLVED && OldCasemap.get(caseObj.Id).Status != caseObj.Status) {
                    caseObj.Resolved_date__c = Date.today();
                    caseObj.Case_Resolution_Time__c = caseObj.Assigned_Date__c != null ? Date.valueOf(caseObj.Assigned_Date__c).daysBetween(Date.today()) : null;
                }
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
    
    public void updateFieldsOnMOSCase() {
        //try {
        Map<Id,Account> mapIdToMosMaster = CaseTriggerHelper.getMapIdToMOSMaster(newCaseList);
        Map<String, List<Task>> mapCaseIdAndStageToListOfTask;
        
        if (trigger.isUpdate) {
            mapCaseIdAndStageToListOfTask = CaseTriggerHelper.getTaskList(newCaseList);
            
        }
        
        for (Case caseObj : newCaseList) {
            if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                
                //Assignment of M call cases and cases created in Salesforce to Pending for Allocation Queue
                if (trigger.isInsert && CaseTriggerHelper.mapQueueNameToId != NULL && CaseTriggerHelper.mapQueueNameToId.keySet().size() > 0 && CaseTriggerHelper.mapQueueNameToId.containsKey(ConstantsUtility.PendingForAllocationQueue) && CaseTriggerHelper.mapQueueNameToId.get(ConstantsUtility.PendingForAllocationQueue) != NULL) {
                    if (caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall && String.isBlank(caseObj.Job_Type__c)) {
                        caseObj.OwnerId = CaseTriggerHelper.mapQueueNameToId.get(ConstantsUtility.PendingForAllocationQueue);
                    }
                    
                    if (caseObj.Origin == ConstantsUtility.OriginSalesforce) {
                        caseObj.OwnerId = CaseTriggerHelper.mapQueueNameToId.get(ConstantsUtility.PendingForAllocationQueue);
                    }
                }
                
                //Case Type Population based on Entered Distance and Allocated Dealer
                CaseTriggerHelper.populateCaseType(mapIdToMosMaster, caseObj);
                
                //Complaint_Registration_Time__c popluation based on Created Date
                if (caseObj.Complaint_Registration_Time__c == NULL && trigger.isBefore && trigger.isInsert) {
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
                if (caseObj.Job_Type__c != NULL && caseObj.Job_Type__c != ConstantsUtility.JOB_TYPE_Accidental && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation && CaseObj.Allocated_Dealer__c == NULL) {
                    caseObj.addError(Label.Error_Message_on_MOS_Case_Update);
                }
                
                //populate Next follow Up time
                if (CaseTriggerHelper.mapKeyToMOSLogic != NULL && CaseTriggerHelper.mapKeyToMOSLogic.keySet().size() > 0 && trigger.isInsert) {
                    CaseTriggerHelper.popluateNextFollowUpTime(caseObj);
                }
                
                if (trigger.isUpdate) {
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
                                    caseObj.addError(ConstantsUtility.mosStageValidationError + listAllowedStages);
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
                        if (mapCaseIdAndStageToListOfTask != NULL && mapCaseIdAndStageToListOfTask.keySet().size() > 0 && mapCaseIdAndStageToListOfTask.containsKey(key)) {
                            List<Task> listTask = mapCaseIdAndStageToListOfTask.get(key);
                            caseObj.Next_Follow_Up_Time__c = listTask[0].Next_Follow_Up_Time__c;
                            caseObj.Next_FollowUp_Remarks__c = listTask[0].Next_Follow_Up_remarks__c;
                            caseObj.Repeat_Call_Notification__c = listTask[0].Repeat_Call_Notification__c;
                        } else {
                            if (CaseTriggerHelper.mapKeyToMOSLogic != NULL && CaseTriggerHelper.mapKeyToMOSLogic.keySet().size() > 0) {
                                CaseTriggerHelper.popluateNextFollowUpTime(caseObj);
                            }
                        }
                    }
                    
                    //Populaton of Time field on Towing SUb Stage Update
                    if (caseObj.Towing_Sub_stage__c == ConstantsUtility.TOWING_SUB_STAGE_Pending_for_Out_for_Service && caseObj.Towing_Sub_stage__c != oldCasemap.get(caseObj.Id).Towing_Sub_stage__c) {
                        caseObj.Towing_Allocated_Time_2__c = System.now();
                    }
                    
                    //Job Type Validation
                    if (caseObj.Job_Type__c != NULL && oldCasemap.get(caseObj.Id).Job_Type__c != NULL && caseObj.Job_Type__c != oldCasemap.get(caseObj.Id).Job_Type__c && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall) {
                        caseObj.addError(ConstantsUtility.JobTypeValidationError);
                    }
                    
                    //Customer Consent Validation
                    if (caseObj.Customer_Consent__c != oldCasemap.get(caseObj.Id).Customer_Consent__c && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                        caseObj.addError(ConstantsUtility.CustomerConsentValidationError);
                    }
                    
                    //Allocated Dealer Validation
                    if (caseObj.Allocated_Dealer__c != oldCasemap.get(caseObj.Id).Allocated_Dealer__c && caseObj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation) {
                        caseObj.addError(ConstantsUtility.AllocatedDealerValidationError);
                    }
                    
                    
                }
                
                //populate Job type based on Customer Consent
                if (String.isNotBlank(caseObj.Customer_Consent__c)) {
                    CaseTriggerHelper.populateJobType(caseObj);
                }
                
                //Assignment of Queue
                if (CaseTriggerHelper.setIntegrationUserId != NULL && CaseTriggerHelper.setIntegrationUserId.size() > 0 && CaseTriggerHelper.mapQueueNameToId != NULL && CaseTriggerHelper.mapQueueNameToId.keySet().size() > 0) {
                    if (trigger.isInsert) {
                        CaseTriggerHelper.assignQueue(caseObj);
                    } else {
                        if ((caseObj.MOS_Case_Stage__c != oldCasemap.get(caseObj.Id).MOS_Case_Stage__c)
                            || (caseObj.Job_Type__c != oldCasemap.get(caseObj.Id).Job_Type__c)
                            || (caseObj.Towing_Sub_stage__c != oldCasemap.get(caseObj.Id).Towing_Sub_stage__c)) {
                                CaseTriggerHelper.assignQueue(caseObj);
                            }
                    }
                }
                
            }
        }
        //} catch (Exception e) {
        //ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'MOS Case', '', null);
        //}
    }
    
    
    /*
Author : Anas Yar Khan
Company : Techmatrix Consulting
Description : This method is used to create MOS Task for MOS Case everytime stage changed.
Events : After Update
Return Type : Void
 
    public void MOSCaseAfterEvent() {
        //try {
        List<Task> listMOSTaskToInsert = new List<Task>();
        Set<Id> setCaseId = new Set<Id>();
        Map<String, Set<Id>> mapEscalationTypeToCaseId = new Map<String, Set<Id>>();
        Map<String, Map<String, MOS_Escalation__mdt>> newEscalationTypeToMetadataRecords = new Map<String, Map<String, MOS_Escalation__mdt>>();
        Map<Id, Case_Actions__c> mapCaseIdAndCaseActionIdToCaseActionRecord = new Map<Id, Case_Actions__c>();
        Map<String, String> mapEscalationTypeToCaseActionFieldApi = new Map<String, String>();
        Set<Id> setClosedCaseId = new Set<Id>();
        Set<Id> setOwnerChangedCaseId = new Set<Id>();
        Set<Id> setOwnerChangeUserCaseId = new Set<Id>();
        Boolean fetchCaseActionRecords = false;
        List<MC_Communication__c> listMCCommunicationToUpdate = new List<MC_Communication__c>();
        List<MC_Communication__c> listMCCommunicationToInsert = new List<MC_Communication__c>();
        
        if (trigger.isUpdate) {
            mapEscalationTypeToCaseId = CaseTriggerHelper.mapEscalationTypeToCaseId;
            newEscalationTypeToMetadataRecords = CaseTriggerHelper.newEscalationTypeToMetadataRecords;
            mapEscalationTypeToCaseActionFieldApi = CaseTriggerHelper.mapEscalationTypeToCaseActionFieldApi;
        }
        
        System.debug('mapEscalationTypeToCaseId-->' + mapEscalationTypeToCaseId);
        System.debug('newEscalationTypeToMetadataRecords-->' + newEscalationTypeToMetadataRecords);
        System.debug('mapEscalationTypeToCaseActionFieldApi-->' + mapEscalationTypeToCaseActionFieldApi);
        for (Case caseObj : newCaseList) {
            if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                if (trigger.isUpdate) {
                    //Check for Owner Change
                    if (caseObj.OwnerId != oldCasemap.get(caseObj.Id).OwnerId) {
                        setOwnerChangedCaseId.add(caseObj.Id);
                        if (String.valueof(caseObj.OwnerId).startsWith('005')) {
                            setOwnerChangeUserCaseId.add(caseObj.Id);
                        }
                    }
                    
                    //Check for Stage Change
                    if (caseObj.MOS_Case_Stage__c != NULL && caseObj.MOS_Case_Stage__c != oldCasemap.get(caseObj.Id).MOS_Case_Stage__c) {
                        Task newTaskObj = CaseTriggerHelper.getNewTaskRecord(caseObj);
                        listMOSTaskToInsert.add(newTaskObj);
                        setCaseId.add(caseObj.Id);
                        if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown) {
                            MOSCaseCommunicationsService.BreakdownPendingForOutForService(caseObj, listMCCommunicationToInsert);
                        }
                       
                        if (caseObj.Allocated_Dealer__c != NULL && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != listMSAllianzRecord[0].Id && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service) {
                            MOSCaseCommunicationsService.AllocatedDealerNotMSAllianz(caseObj, listMCCommunicationToInsert);
                        }
                        
                    }
                    
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
                        if (caseObj.Job_Type__c != NULL && (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_Case_Stage_Resolved || caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_Case_Stage_Resolved_On_Call)) {
                            listMCCommunicationToInsert.add(MOSCaseCommunicationsService.getMCCommunicationRecord(caseObj, ConstantsUtility.Case_Closure_Customer));
                        }
                    }
                    
                    if (caseObj.Towing_Destination_Dealer__c != oldCasemap.get(caseObj.Id).Towing_Destination_Dealer__c && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental) {
                        MOSCaseCommunicationsService.TowingDestinationDealerSelected(caseObj, listMCCommunicationToInsert);
                    }
                    
                    
                } else if (trigger.isInsert) {
                    if (caseObj.MOS_Case_Stage__c != NULL) {
                        Task newTaskObj = CaseTriggerHelper.getNewTaskRecord(caseObj);
                        listMOSTaskToInsert.add(newTaskObj);
                        if (caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown) {
                            MOSCaseCommunicationsService.BreakdownPendingForOutForService(caseObj, listMCCommunicationToInsert);
                        }
                    }
                    
                    if (caseObj.Towing_Destination_Dealer__c != NULL && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental) {
                        MOSCaseCommunicationsService.TowingDestinationDealerSelected(caseObj, listMCCommunicationToInsert);
                    }
                    
                    
                    if (caseObj.Allocated_Dealer__c != NULL && listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c != listMSAllianzRecord[0].Id && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service) {
                        MOSCaseCommunicationsService.AllocatedDealerNotMSAllianz(caseObj, listMCCommunicationToInsert);
                    }
                    
                }
            }
        }
        
        //Changed the Owner of the Open MOS Task and OpenFollow Ups
        if (setOwnerChangedCaseId.size() > 0) {
            List<Task> listTaskUpdate = new List<Task>();
            for (Task taskObj : [SELECT Id,OwnerId,WhatId FROM TASK WHERE WhatId IN :setOwnerChangedCaseId AND RecordTypeId IN (:ConstantsUtility.MOS_TASK_RecordType_Id, :ConstantsUtility.TASK_MOS_Follow_Up_RecordType_Id) AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                taskObj.OwnerId = newCaseMap.get(taskObj.WhatId).OwnerId;
                listTaskUpdate.add(taskObj);
            }
            
            if (listTaskUpdate.size() > 0) {
                update listTaskUpdate;
            }
            if (setOwnerChangeUserCaseId.size() > 0) {
                List<Case_Actions__c> listActionsToUpdate = new List<Case_Actions__c>();
                for (Case_Actions__c caseActionObj : [SELECT Id,OwnerId,Case_Number__c FROM Case_Actions__c WHERE Case_Number__c IN :setOwnerChangedCaseId]) {
                    caseActionObj.OwnerId = newCaseMap.get(caseActionObj.Case_Number__c).OwnerId;
                    listActionsToUpdate.add(caseActionObj);
                }
                
                if (listActionsToUpdate.size() > 0) {
                    update listActionsToUpdate;
                }
            }
        }
        
        //Update all open follow up and mos task as closed when case is marked as closed
        if (setClosedCaseId.size() > 0) {
            List<Task> listTaskUpdate = new List<Task>();
            List<Case_Actions__c> listCaseActionToUpdate = new List<Case_Actions__c>();
            for (Task taskObj : [SELECT Id,Status FROM TASK WHERE WhatId IN :setClosedCaseId AND RecordTypeId IN (:ConstantsUtility.MOS_TASK_RecordType_Id, :ConstantsUtility.TASK_MOS_Follow_Up_RecordType_Id) AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                taskObj.Status = ConstantsUtility.MOS_Task_Status_Closed;
                listTaskUpdate.add(taskObj);
            }
            
            if (listTaskUpdate.size() > 0) {
                update listTaskUpdate;
            }
            
            for (Case_Actions__c caseActionObj : [SELECT Id,Escalation_Status__c FROM Case_Actions__c WHERE Case_Number__c IN :setClosedCaseId AND Escalation_Status__c = :ConstantsUtility.Case_Action_Escalation_Status_Active]) {
                caseActionObj.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Inactive;
                listCaseActionToUpdate.add(caseActionObj);
            }
            
            if (listCaseActionToUpdate.size() > 0) {
                update listCaseActionToUpdate;
            }
            
        }
        
        System.debug('mapEscalationTypeToCaseId-->' + mapEscalationTypeToCaseId);
        
        if (trigger.isUpdate && setCaseId.size() > 0) {
            List<Task> listTaskToUpdate = new List<Task>();
            for (Task taskObj : [SELECT Id,Status,WhatId FROM TASK WHERE WhatId IN :setCaseId AND RecordTypeId = :ConstantsUtility.MOS_TASK_RecordType_Id AND Status = :ConstantsUtility.MOS_TASK_Status_Open]) {
                taskObj.Status = ConstantsUtility.MOS_Task_Status_Closed;
                listTaskToUpdate.add(taskObj);
            }
            
            if (listTaskToUpdate.size() > 0) {
                update listTaskToUpdate;
            }
        }
        
        List<Case_Actions__c> listCaseActionToInsert = new List<Case_Actions__c>();
        
        if (listMOSTaskToInsert.size() > 0) {
            insert listMOSTaskToInsert;
            
            Map<Id, Id> mapCaseIdToTaskId = new Map<Id, Id>();
            for (Task taskObj : [SELECT Id,WhatId FROM Task WHERE Id IN :listMOSTaskToInsert]) {
                mapCaseIdToTaskId.put(taskObj.WhatId, taskObj.Id);
            }
            
            if (trigger.isInsert) {
                if (mapCaseIdToTaskId != NULL && mapCaseIdToTaskId.keySet().size() > 0) {
                    for (Case caseObj : newCaseList) {
                        if (caseObj.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
                            Case_Actions__c followUpCaseAction = CaseTriggerHelper.getCaseActionRecord(caseObj);
                            followUpCaseAction.Name = caseObj.CaseNumber + ConstantsUtility.Hypen + ConstantsUtility.MOS_FollowUp_Escalation;
                            followUpCaseAction.Case_Type__c = ConstantsUtility.Case_Action_Type_MOS_followUp;
                            followUpCaseAction.Follow_up_ID__c = mapCaseIdToTaskId.get(caseObj.Id);
                            listCaseActionToInsert.add(followUpCaseAction);
                            System.debug('followUpCaseAction-->' + followUpCaseAction.Case_Type__c);
                            Case_Actions__c allocationCaseAction = CaseTriggerHelper.getCaseActionRecord(caseObj);
                            allocationCaseAction.Name = caseObj.CaseNumber + ConstantsUtility.Hypen + ConstantsUtility.Allocation_Escalation;
                            allocationCaseAction.Case_Type__c = ConstantsUtility.Case_Action_Type_MOS_Allocation;
                            listCaseActionToInsert.add(allocationCaseAction);
                            
                            Case_Actions__c reachCaseAction = CaseTriggerHelper.getCaseActionRecord(caseObj);
                            reachCaseAction.Name = caseObj.CaseNumber + ConstantsUtility.Hypen + ConstantsUtility.Reach_Escalation;
                            reachCaseAction.Case_Type__c = ConstantsUtility.Case_Action_Type_MOS_Reach;
                            listCaseActionToInsert.add(reachCaseAction);
                            
                            System.debug('followUpCaseAction-->' + followUpCaseAction.Case_Type__c);
                        }
                    }
                }
            }
            
            if (trigger.isUpdate) {
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
                        update listOfFollowUpCaseActionToUpdate;
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
                System.debug('caseAction.Case_Type__c-->' + caseAction.Case_Type__c);
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
            update mapIdToCase.values();
        }
        
        if (fetchCaseActionRecords) {
            mapCaseIdAndCaseActionIdToCaseActionRecord = CaseTriggerHelper.getMapOfCaseActionsRecord(newCaseList);
        }
        
        List<Case_Actions__c> listCaseActionToUpdate = new List<Case_Actions__c>();
        
        if (trigger.isUpdate) {
            if (mapEscalationTypeToCaseId != NULL && mapEscalationTypeToCaseId.keySet().size() > 0) {
                for (String escalationType : mapEscalationTypeToCaseId.keySet()) {
                    Set<Id> tempSetCaseId = mapEscalationTypeToCaseId.get(escalationType);
                    System.debug('tempSetCaseId-->' + tempSetCaseId);
                    if (tempSetCaseId != NULL && tempSetCaseId.size() > 0) {
                        for (Id caseId : tempSetCaseId) {
                            System.debug('caseId-->' + caseId);
                            //String key = newCaseMap.get(caseId).JobType__c+ConstantsUtility.keySeparator+newCaseMap.get(caseId).Case_Type__c+ConstantsUtility.keySeparator+newCaseMap.get(caseId).MOS_Case_Stage__c+mapCaseIdAndCaseActionIdToCaseActionRecord.get(newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType))).Escalation_Level__c+ConstantsUtility.keySeparator+escalationType;
                            if (newEscalationTypeToMetadataRecords.containsKey(escalationType)) {
                                Map<String, MOS_Escalation__mdt> mapKeyToMetadataRecords = newEscalationTypeToMetadataRecords.get(escalationType);
                                if(newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType)) != NULL) {
                                    String key = newCaseMap.get(caseId).Job_Type__c + ConstantsUtility.keySeparator + newCaseMap.get(caseId).Case_Type__c + ConstantsUtility.keySeparator + newCaseMap.get(caseId).MOS_Case_Stage__c + ConstantsUtility.KeySeparator + mapCaseIdAndCaseActionIdToCaseActionRecord.get((ID) newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType))).Escalation_Level__c + ConstantsUtility.keySeparator + escalationType;
                                    Case_Actions__c newCaseAction = new Case_Actions__c();
                                    System.debug('key-->' + key);
                                    newCaseAction.Id = (Id) newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType));
                                    System.debug('NewCaseActionId-->' + newCaseMap.get(caseId).get(mapEscalationTypeToCaseActionFieldApi.get(escalationType)));
                                    if (mapKeyToMetadataRecords.containsKey(key)) {
                                        MOS_Escalation__mdt mosEscalation = mapKeyToMetadataRecords.get(key);
                                        if (mosEscalation.Value__c.split(',').contains((String) newCaseMap.get(caseId).get(mosEscalation.Condition__c))) {
                                            newCaseAction.Escalation_Status__c = ConstantsUtility.Case_Action_Escalation_Status_Active;
                                            if (newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c) != NULL) {
                                                System.debug('escalationType-->' + escalationType);
                                                System.debug('(DateTime) newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c)--->' + (DateTime) newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c));
                                                newCaseAction.Escalation_Update__c = (DateTime) newCaseMap.get(caseId).get(mosEscalation.Escalation_Update__c);
                                                System.debug('escalationtype-->' + escalationType);
                                                if (escalationType != 'Reach') {
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
                                                        if (escalationType != 'Reach') {
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
        
        System.debug('listCaseActionToUpdate-->' + listCaseActionToUpdate);
        if (listCaseActionToUpdate.size() > 0) {
            update listCaseActionToUpdate;
        }
        
        if (listMCCommunicationToUpdate.size() > 0) {
            update listMCCommunicationToUpdate;
        }
        
        if (listMCCommunicationToInsert.size() > 0) {
            //insert listMCCommunicationToInsert;
        }
        
        
        //} catch (Exception e) {
        // ExceptionHandler.LogError('CaseTriggerHandler', e.getMessage(), 'MOS Case System generated MOS Task', '', null);
        //}
    }
    
    /**
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to update the CCP info on case based on the Custom metadata
Return Type : Case
 
    public void updateCCPOutboundCallingTime() {
        try {
            Map<String, Case_Escalations_Matrix__mdt> caseTypeVsCaseEscalationsMatrixMap = new Map<String, Case_Escalations_Matrix__mdt>();
            caseTypeVsCaseEscalationsMatrixMap = getCaseTypeVsCaseEscalationsMatrixMap(caseTypeVsCaseEscalationsMatrixMap);
            for (Case caseObj : newCaseList) {
                if ((caseObj.RecordTypeId == ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID || caseObj.RecordTypeId == ConstantsUtility.REPEAT_COMPLAINT_CASE_RECORD_TYPE_ID)
                    && caseObj.Dealer_Name__c != null && caseObj.Case_Type__c != null && caseObj.Case_Type__c == ConstantsUtility.COMPLAINT_CASE_TYPE && caseObj.Business_Area__c != null
                    && (caseObj.Business_Area__c == ConstantsUtility.SALES_CASE_BUSINESS_AREA || caseObj.Business_Area__c == ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA ||
                        caseObj.Business_Area__c == ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA)) {
                            String caseType = caseObj.Business_Area__c.contains(ConstantsUtility.SALES_CASE_BUSINESS_AREA) ? ConstantsUtility.SALES_CASE_BUSINESS_AREA : ConstantsUtility.CASE_TYPE_SERVICE;
                            // Condition 1
                            if (caseObj.CCP_Outbound_Call_Date_Time__c == null && caseObj.CCP_Attempt_No__c == null) {
                                caseType = caseType + '_' + 1;
                                caseObj = updateCCPInfo(caseTypeVsCaseEscalationsMatrixMap, caseObj, caseType);
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
 
    public static Case updateCCPInfo(Map<String, Case_Escalations_Matrix__mdt> caseTypeVsCaseEscalationsMatrixMap, Case caseObj, String caseTypeKey) {
        if (caseTypeVsCaseEscalationsMatrixMap.containsKey(caseTypeKey)) {
            Case_Escalations_Matrix__mdt caseEscalationsMatrix = caseTypeVsCaseEscalationsMatrixMap.get(caseTypeKey);
            if (caseEscalationsMatrix.Time_to_Next_Escalation__c != null && caseEscalationsMatrix.CCP_Outbound_Call_To__c != null) {
                caseObj.CCP_Outbound_Call_Date_Time__c = Datetime.now().addMinutes(Integer.valueOf(caseEscalationsMatrix.Time_to_Next_Escalation__c));
                Id businessHourId = label.Business_Hour_Id;
                EnquiryEscalationService escalationService = new EnquiryEscalationService();
                caseObj.CCP_Outbound_Call_Date_Time__c = escalationService.checkBusinessHours(businessHourId, caseObj.CCP_Outbound_Call_Date_Time__c, Integer.valueOf(caseEscalationsMatrix.Time_to_Next_Escalation__c));
                caseObj.CCP_Outbound_Call_To__c = caseEscalationsMatrix.CCP_Outbound_Call_To__c;
                caseObj.CCP_Attempt_No__c = caseEscalationsMatrix.CCP_Attempt_No__c;
            }
        }
        // System.debug(caseTypeKey);
        return caseObj;
        
        
    }
    public static Map<String, Case_Escalations_Matrix__mdt> getCaseTypeVsCaseEscalationsMatrixMap(Map<String, Case_Escalations_Matrix__mdt> caseTypeVsCaseEscalationsMatrixMap) {
        for (Case_Escalations_Matrix__mdt matrix : [SELECT Id,Business_Area__c,Case_Type__c,CCP_Attempt_No__c,CCP_Outbound_Call_To__c,Time_to_Next_Escalation__c FROM Case_Escalations_Matrix__mdt WHERE Escalation_Type__c = :ConstantsUtility.ESCALATION_TYPE_CCP_INITIATION]) {
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
 
    public static Map<Id, Case> ccpCampaignDetectionHelper(List<Case> cases, Map<Id, Case> caseMap) {
        // Map for the CaseAssignmentMatrix based on campaign Code
        Map<String, Case_Queue_Assignment_Matrix__mdt> campaignCodeVsCaseAssignmentMatrixMap = new Map<String, Case_Queue_Assignment_Matrix__mdt>();
        Map<String, Case_Queue_Assignment_Matrix__mdt> uniqueKeyVsCaseAssignmentMatrixMap = new Map<String, Case_Queue_Assignment_Matrix__mdt>();
        for (Case_Queue_Assignment_Matrix__mdt assignmentMatrix : [SELECT Id,Campaign_Code__c,Campaign_Name__c,CCP_Outbound_Call_To__c,Location__c,Mobile_Prefix__c,Channel__c,Case_Type__c, Business_Area__c,Primary_Category__c FROM Case_Queue_Assignment_Matrix__mdt WHERE Campaign_Code__c != null]) {
            campaignCodeVsCaseAssignmentMatrixMap.put(assignmentMatrix.Campaign_Code__c, assignmentMatrix);
            String uniqueKey = assignmentMatrix.Channel__c + assignmentMatrix.Case_Type__c + assignmentMatrix.Business_Area__c;
            uniqueKey += assignmentMatrix.CCP_Outbound_Call_To__c ;
            uniqueKey += assignmentMatrix.Primary_Category__c != null ? assignmentMatrix.Primary_Category__c : '';
            uniqueKeyVsCaseAssignmentMatrixMap.put(uniqueKey, assignmentMatrix);
        }
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
                        /**  If the CCP Outbound Call To is equal to Call To Customer  
                        if (caseObj.CCP_Outbound_Call_To__c == ConstantsUtility.CCP_OUTBOUND_CALL_TO_CUSTOMER) {
                            caseObj.Mobile_Number_1__c = mobilePreFix + caseObj.Mobile_Number__c;
                            /**  If the CCP Outbound Call To is equal to Call To Dealership  
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
                            }
                            caseObj.Mobile_Number_4__c = System.Label.Default_Phone_L4;
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
                String phone = System.Label.Default_Phone_L4;
                if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L2A) {
                    phone = holder.phone != '' ? holder.phone : phone;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L2A, phone);
                } else if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L2B) {
                    phone = holder.phone != '' ? holder.phone : phone;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L2B, phone);
                } if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L3A) {
                    phone = holder.phone != '' ? holder.phone : System.Label.Default_Phone_L4;
                    levelVsPhoneNumberMap.put(ConstantsUtility.NOTIFIER_L3A, phone);
                } if (holder.stakeHolder == ConstantsUtility.NOTIFIER_L4 && phone != '') {
                    phone = holder.phone != '' ? holder.phone : System.Label.Default_Phone_L4;
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
Description : This method is used to send the chatter notification to L1, L2A and L3A
Events : after update
Return Type : void
 
    public void sendChatterNotificationOnQC() {
        try {
            // Custom setting to store Notification messages w.r.t to Developer Recordtype Name
            Map<String, Approval_Notification_Setting__c> approvalTypeVsNotificationSettingsMap = new Map<String, Approval_Notification_Setting__c>();
            for (Approval_Notification_Setting__c notificationSetting : [SELECT Name,Approval_Type__c,Approved_Template__c,Notifiers__c FROM Approval_Notification_Setting__c WHERE isActive__c = true]) {
                approvalTypeVsNotificationSettingsMap.put(notificationSetting.Approval_Type__c, notificationSetting);
            }
            
            Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
            Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
            
            for (Case newCase : newCaseList) {
                String message ;
                String stakeHolderHierarchyJSOn ;
                String selectedHierarchyType ;
                String notifiers ;
                Case oldCase = oldCasemap.get(newCase.Id);
                
                // Condition 1 :  When the QA team updates details on the case and discarded case
                if (newCase.QC_Status__c == ConstantsUtility.QC_STATUS_NOT_OK && (newCase.QC_Status__c != oldCase.QC_Status__c || newCase.QC_Done_By__c != oldCase.QC_Done_By__c || newCase.QC_Remarks__c != oldCase.QC_Remarks__c)) {
                    message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Approved_Template__c;
                    notifiers = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Notifiers__c;
                    stakeHolderHierarchyJSOn = newCase.Stakeholders_JSON__c;
                    selectedHierarchyType = newCase.Selected_Hierarchy_Type__c;
                    // Condition 2 :  When the QA team updates details on the case
                } else if (newCase.QC_Status__c != oldCase.QC_Status__c || newCase.QC_Done_By__c != oldCase.QC_Done_By__c || newCase.QC_Remarks__c != oldCase.QC_Remarks__c) {
                    message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_DONE).Approved_Template__c;
                    notifiers = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Notifiers__c;
                    stakeHolderHierarchyJSOn = newCase.Stakeholders_JSON__c;
                    selectedHierarchyType = newCase.Selected_Hierarchy_Type__c;
                    //  Condition 3 :  When the QA team updates details on the case and Assign the case to new dealership
                } else if (CaseAssignmentService.isCategoryUpdated(newCase, oldCase) && oldCase.Dealer_Name__c != newCase.Dealer_Name__c) {
                    message = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_DEALER_CHANGED).Approved_Template__c;
                    notifiers = approvalTypeVsNotificationSettingsMap.get(ConstantsUtility.QC_CHECK_CASE_DISCARDED).Notifiers__c;
                    stakeHolderHierarchyJSOn = oldCase.Stakeholders_JSON__c;
                    selectedHierarchyType = oldCase.Selected_Hierarchy_Type__c;
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
                    }
                }
            }
            if (!escalationUsers.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
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
                for (Account account : [SELECT Id,SVOC_ID__c FROM Account WHERE SVOC_ID__c IN :sVOCIdSet]) {
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
Author : Deepak Kumar
Company : Techmatrix Consulting
Description : This method is used to populate the Revalidation Type on case
Events : after update
Return Type : void
 
    public void populateRevalidationType() {
        try {
            
            for (Case newCase : newCaseList) {
                newCase.Revalidation_Type__c = ConstantsUtility.SALES_REVALIDATION;
                if (newCase.Case_Type__c != null && newCase.Case_Type__c == ConstantsUtility.COMPLAINT_CASE_TYPE &&
                    (newCase.Business_Area__c != null && newCase.Business_Area__c == ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA
                     || newCase.Business_Area__c != null && newCase.Business_Area__c == ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA)) {
                         newCase.Revalidation_Type__c = ConstantsUtility.SERVICE_REVALIDATION;
                     }
                
            }
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' At ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('CaseTriggerHandler', exp.getMessage(), 'populateRevalidationType', '', null);
        }
    }
**/
}