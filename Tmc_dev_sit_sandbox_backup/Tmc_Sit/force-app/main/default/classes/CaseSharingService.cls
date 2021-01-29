/**
    * @File Name          : CaseSharingService.cls
    * @Description        : Service Class to share the case visibility to the respective users
    * @Author             : Deepak Kumar
    * @Group              :
    * @Last Modified By   :
    * @Last Modified On   : 6/12/2020, 11:29:29 PM
    * @Modification Log   :
    *==============================================================================
    * Ver         Date                     Author                 Modification
    *==============================================================================
    * 1.0       17 JUl 2020               Deepak                  Initial Version
**/

public without sharing class CaseSharingService {
    public static Map<String, Case_Team_Members_By_Channel__mdt> lobVsCaseTeamMembersByChannelsMap = new Map<String, Case_Team_Members_By_Channel__mdt>();
    public static Map<Id, String> caseIdVsCaseLobMap = new Map<Id, String>(); // Map of CaseId and selected Lob
    // Map of caseId and Related lob vs users list
    public static Map<Id, Map<String, List<StakeholderHierarchy.Sales>>> caseIdVsHierarchyAndJsonListMap = new Map<Id, Map<String, List<StakeholderHierarchy.Sales>>>();

    // This Map will help to make the case access as per user.
    public static Map<Id, Map<Id, String>> caseIdVsUserIdAndAccessTypeMap = new Map<Id, Map<Id, String>>();

    /**
       Author: Deepak
       Company: Techmatrix
       Description: This method is meant to assign the case visibility to respective members
       Returns: void
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0       17 Jul 2020               Deepak                   Initial Version
   **/
    public static void shareCaseToMembers(List<Case> newCases) {
        try {
            lobVsCaseTeamMembersByChannelsMap = getLobVsCaseTeamMembersByChannelsMap(); // Custom metadata map
            caseIdVsCaseLobMap = getCaseIdVsCaseLobMap(newCases); // This map help to select the metadata record to get the users and related access
            caseIdVsHierarchyAndJsonListMap = getCaseAndRelatedStakeHoldersMap(newCases); //  CaseId, hierarchy type and and related hierarchy list map
            //  System.debug('caseIdVsHierarchyAndJsonListMap '+caseIdVsHierarchyAndJsonListMap);
            for (Case newCase : newCases) {
                if (newCase.Stakeholders_JSON__c != null && newCase.Selected_Hierarchy_Type__c != null) {
                    newCase = addRelatedUsers(newCase);
                }
            }
            if (!caseIdVsUserIdAndAccessTypeMap.isEmpty()) {
                //   System.debug('caseIdVsUserIdAndAccessTypeMap  ::'+caseIdVsUserIdAndAccessTypeMap);
                List<CaseTeamMember> caseTeamMembersToInsert = updateCaseTeamMembers(caseIdVsUserIdAndAccessTypeMap);
                //    System.debug('caseTeamMembersToInsert ::: '+caseTeamMembersToInsert);
                if (caseTeamMembersToInsert != null && caseTeamMembersToInsert.size() > 0) {
                    // System.debug('caseTeamMembersToInsert '+caseTeamMembersToInsert);
                    Database.SaveResult[] srList = Database.insert(caseTeamMembersToInsert, false);

                    // Iterate through each returned results
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            for (Database.Error err : sr.getErrors()) {
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                }
            }
        } catch (Exception exp) {
            System.debug('Exception Message ::' + exp.getMessage() + ' Stack trace ::' + exp.getStackTraceString());
            ExceptionHandler.LogError('shareCaseToMembers', exp.getMessage(), 'Case', null, null);


        }
    }
    private static Case addRelatedUsers(Case newCase) {

        Map<String, List<StakeholderHierarchy.Sales>> hierarchyTypeVsRelatedUsersMap = caseIdVsHierarchyAndJsonListMap.get(newCase.Id);
        if (hierarchyTypeVsRelatedUsersMap.containsKey(newCase.Selected_Hierarchy_Type__c)) {
            List<StakeholderHierarchy.Sales> selectedHierarchyList = hierarchyTypeVsRelatedUsersMap.get(newCase.Selected_Hierarchy_Type__c);
            String selectedLob = caseIdVsCaseLobMap.get(newCase.Id);
            System.debug(caseIdVsCaseLobMap);
            System.debug(lobVsCaseTeamMembersByChannelsMap);
            Case_Team_Members_By_Channel__mdt caseTeamMembersByChannel = lobVsCaseTeamMembersByChannelsMap.get(selectedLob);
            //   System.debug('caseTeamMembersByChannel  '+caseTeamMembersByChannel);
            List<String> relatedUsers = caseTeamMembersByChannel.User_Type__c.split(','); // Related users
            List<String> relatedAccess = caseTeamMembersByChannel.Access_Type__c.split(',');  // Related users Access level
            Map<Id, String> userIdVsAccessTypeMap = new Map<Id, String>();
            for (StakeholderHierarchy.Sales holder : selectedHierarchyList) {
                for (Integer i = 0; i < relatedUsers.size(); i++) {
                    String relatedUser = relatedUsers[i];
                    if (holder.stakeHolder == relatedUser && String.isNotBlank(holder.recordId)) {
                        userIdVsAccessTypeMap.put(holder.recordId, relatedAccess[i]);
                    }
                }
            }
            caseIdVsUserIdAndAccessTypeMap.put(newCase.Id, userIdVsAccessTypeMap);
        }
        return newCase;

    }

    // This method return the map of Lob and related CaseTeamMembersByChannel
    private static Map<String, Case_Team_Members_By_Channel__mdt> getLobVsCaseTeamMembersByChannelsMap() {
        //
        for (Case_Team_Members_By_Channel__mdt caseTeamMembersByChannel : [SELECT LOB__c,Access_Type__c,User_Type__c FROM Case_Team_Members_By_Channel__mdt]) {
            lobVsCaseTeamMembersByChannelsMap.put(caseTeamMembersByChannel.LOB__c, caseTeamMembersByChannel);
        }

        return lobVsCaseTeamMembersByChannelsMap;
    }
    private static Map<Id, String> getCaseIdVsCaseLobMap(List<Case> newCases) {
        for (Case newCase : newCases) {
            if (newCase.Channel__c == ConstantsUtility.NEXA_CASE_CHANNEL || newCase.Channel__c == ConstantsUtility.ARENA_CASE_CHANNEL || newCase.Channel__c == ConstantsUtility.COMMERCIAL_CASE_CHANNEL) {
                if (newCase.Case_Type__c == ConstantsUtility.COMPLAINT_CASE_TYPE || newCase.Case_Type__c == ConstantsUtility.DEALER_QUERY_CASE_TYPE || newCase.Case_Type__c == ConstantsUtility.DEALER_FEEDBACK_CASE_TYPE) {
                    if (newCase.Business_Area__c == ConstantsUtility.SALES_CASE_BUSINESS_AREA) {
                        caseIdVsCaseLobMap.put(newCase.Id, newCase.Business_Area__c);
                    } else if (newCase.Business_Area__c == ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA || newCase.Business_Area__c == ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA) {
                        caseIdVsCaseLobMap.put(newCase.Id, ConstantsUtility.SERVICE_CASE_BUSINESS_AREA);  // SERVICE WORKSHOP
                    } else if (newCase.RecordTypeId!=ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && newCase.Business_Area__c == ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA) {
                        caseIdVsCaseLobMap.put(newCase.Id, newCase.Business_Area__c);  // ACC
                    } else if (newCase.Business_Area__c == ConstantsUtility.FINANCE_CASE_BUSINESS_AREA) {
                        caseIdVsCaseLobMap.put(newCase.Id, newCase.Business_Area__c);  // FINANCE
                    }else if (newCase.RecordTypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && newCase.Business_Area__c == ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA) { //Added By Nitin on 18/12/2020
                        caseIdVsCaseLobMap.put(newCase.Id, ConstantsUtility.SUZUKI_CONNECT_NAME); //Suzuki Connect //Accessories //Added By Nitin on 18/12/2020
                    } 
                }
                /*  if (newCase.Case_Type__c == ConstantsUtility.MSIL_QUERY_CASE_TYPE) {
                      caseIdVsCaseLobMap.put(newCase.Id, newCase.Case_Type__c);
                  }*/
            } else if (newCase.Channel__c == ConstantsUtility.MSDS_CASE_CHANNEL) {
                caseIdVsCaseLobMap.put(newCase.Id, newCase.Channel__c);
            } if (newCase.Case_Type__c == ConstantsUtility.MSIL_QUERY_CASE_TYPE) {
                caseIdVsCaseLobMap.put(newCase.Id, newCase.Case_Type__c);
            }
        }
        return caseIdVsCaseLobMap;
    }


    /**
    Author: Deepak
    Company: Techmatrix
    Description: This method with return the CaseId vs related Lob type and related users
    input: List of Case
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0       17 Jul 2020               Deepak                   Initial Version
**/
    public static Map<Id, Map<String, List<StakeholderHierarchy.Sales>>> getCaseAndRelatedStakeHoldersMap(List<Case> newCases) {
        for (Case newCase : newCases) {
            if (String.isNotBlank(newCase.Stakeholders_JSON__c)) {
                Map<String, List<StakeholderHierarchy.Sales>> getJsonHierarchyMap =
                        caseIdVsHierarchyAndJsonListMap.put(newCase.Id, getJsonHierarchyMap(newCase.Stakeholders_JSON__c));
            }
        }
        return caseIdVsHierarchyAndJsonListMap;
    }
    private static Map<String, List<StakeholderHierarchy.Sales>> getJsonHierarchyMap(String jsonHierarchy) {
        StakeholderHierarchy stakeholderHierarchy = StakeholderUtility.parseStakeholderHierarchyJson(jsonHierarchy);
        Map<String, List<StakeholderHierarchy.Sales>> hierarchyTypeVsRelatedUsersMap = new Map<String, List<StakeholderHierarchy.Sales>>();
        if (stakeholderHierarchy.sales != null && stakeholderHierarchy.sales.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.SALES_HIERARCHY, stakeholderHierarchy.sales);
        }if (stakeholderHierarchy.serviceArena != null && stakeholderHierarchy.serviceArena.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.SERVICE_ARENA_HIERARCHY, stakeholderHierarchy.serviceArena);
        } if (stakeholderHierarchy.serviceNexa != null && stakeholderHierarchy.serviceNexa.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.SERVICE_NEXA_HIERARCHY, stakeholderHierarchy.serviceNexa);
        }if (stakeholderHierarchy.accessories != null && stakeholderHierarchy.accessories.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.ACCESSORIES_HIERARCHY, stakeholderHierarchy.accessories);
        }if (stakeholderHierarchy.trueValue != null && stakeholderHierarchy.trueValue.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.TRUEVALUE_HIERARCHY, stakeholderHierarchy.trueValue);
        }if (stakeholderHierarchy.msds != null && stakeholderHierarchy.msds.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.MSDS_HIERARCHY, stakeholderHierarchy.msds);
        }if (stakeholderHierarchy.msgp != null && stakeholderHierarchy.msgp.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.MSGP_HIERARCHY, stakeholderHierarchy.msgp);
        }if (stakeholderHierarchy.loyaltyProgram != null && stakeholderHierarchy.loyaltyProgram.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.LOYALTY_PROGRAM_HIERARCHY, stakeholderHierarchy.loyaltyProgram);
        }if (stakeholderHierarchy.finance != null && stakeholderHierarchy.finance.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.FINANCE_HIERARCHY, stakeholderHierarchy.finance);
        }if (stakeholderHierarchy.msilQuery != null && stakeholderHierarchy.msilQuery.size() > 0) {
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.MSIL_QUERY_HIERARCHY, stakeholderHierarchy.msilQuery);
        }if (stakeholderHierarchy.suzukiConnect != null && stakeholderHierarchy.suzukiConnect.size() > 0) { //Added By Nitin on 18/12/2020 for Suzuki Connect
            hierarchyTypeVsRelatedUsersMap.put(ConstantsUtility.SUZUKI_CONNECT_HIERARCHY, stakeholderHierarchy.suzukiConnect);
        }//Added By Nitin on 18/12/2020 for Suzuki Connect
        return hierarchyTypeVsRelatedUsersMap;
    }


    /**
       Author: Deepak
       Company: Techmatrix
       Description: This method will add access of user through the case team members and return the List of case Team Members  to insert after.
       input: Map of CaseId and related UserId and access type map
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0       20 Jul 2020               Deepak                   Initial Version
   **/
    public static List<CaseTeamMember> updateCaseTeamMembers(Map<Id, Map<Id, String>> caseIdVsUserIdAndAccessTypeMap) {
        List<CaseTeamMember> caseTeamMembersToInsert = new List<CaseTeamMember>();
        Map<String, String> CaseTeamMemberNameVsIdMap = getCaseTeamMemberMap();
        for (Id caseId : caseIdVsUserIdAndAccessTypeMap.keySet()) {
            Map<Id, String> userIdVsAccessTypeMap = caseIdVsUserIdAndAccessTypeMap.get(caseId);
            for (Id userId : userIdVsAccessTypeMap.keySet()) {
                CaseTeamMember caseTeamMember = new CaseTeamMember();
                caseTeamMember.ParentId = caseId;
                caseTeamMember.MemberId = userId;
                String roleName = 'Case ' + userIdVsAccessTypeMap.get(userId) + ' Access';
                caseTeamMember.TeamRoleId = CaseTeamMemberNameVsIdMap.get(roleName);
                caseTeamMembersToInsert.add(caseTeamMember);
            }
        }
        return caseTeamMembersToInsert;
    }
    // This method is used to get the map of access type case role id for case
    private static Map<String, String> getCaseTeamMemberMap() {
        Map<String, String> CaseTeamMemberNameVsIdMap = new Map<String, String>();
        for (CaseTeamRole caseTeamRole : [SELECT Name,Id FROM CaseTeamRole]) {
            CaseTeamMemberNameVsIdMap.put(caseTeamRole.Name, caseTeamRole.Id);
        }

        return CaseTeamMemberNameVsIdMap;
    }


    /**
       Author: Deepak
       Company: Techmatrix
       Description: This is a generic method to remove the access from the case
       input: Map of CaseId and related User Ids
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0       21 Jul 2020               Deepak                   Initial Version
   **/
    public static Boolean deleteCaseTeamMembers(Map<Id, List<Id>> caseIdVsUserIdsMap) {
        System.debug(caseIdVsUserIdsMap);
        List<CaseTeamMember> caseTeamMembersToDelete = new List<CaseTeamMember>();
        for (CaseTeamMember teamMember : [SELECT Id,ParentId,MemberId FROM CaseTeamMember WHERE ParentId IN:caseIdVsUserIdsMap.keySet()]) {
            if (caseIdVsUserIdsMap.containsKey(teamMember.ParentId) && caseIdVsUserIdsMap.get(teamMember.ParentId).contains(teamMember.MemberId)) {
                caseTeamMembersToDelete.add(teamMember);
            }
        }
        if (caseTeamMembersToDelete.size() > 0) {
            delete caseTeamMembersToDelete;
            return true;
        }
        return false;
    }

}