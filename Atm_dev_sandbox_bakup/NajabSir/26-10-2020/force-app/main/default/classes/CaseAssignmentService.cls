/**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: Service class to assign the case to the appropriate user
    History:
    * Version         Date                     Author                    Modification
    *==============================================================================
    * 1.0        25/06/2020                Deepak Kumar              Initial Version
**/

public without sharing class CaseAssignmentService {
    // Map to store the categoryId and related region and Recipient Master

    public static Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();

    public static Map<Id, Opportunity> enquiryMap = new Map<Id, Opportunity>();
    public static Map<Id, Account> dealershipMap = new Map<Id, Account>();
    public static Map<String, Group> developerNameVsQueueMap = new Map<String, Group>(); // Map to store the developer name as key and queue as value
    public static List<Case> newCases = new List<Case>(); // new Cases or trigger.new
    public static Map<Id, User> userMap = new Map<Id, User>();
    public static Map<String, String> caseTypeVsHierarchyMap = new Map<String, String>(); // Map to store the key related Hierarchy type

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: This method is used to update the caseOwner and stamp the the JSON on the case
       Input : List of Case
       History:
       * Version         Date                     Author                    Modification
       *==============================================================================
       * 1.0        07/07/2020                Deepak Kumar              Initial Version
   **/
    public static void assignCasesToStakeHolders(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        try {
            newCases = caseList;
            Set<Id> categoryIds = new Set<Id>(); // Set to store the lower most category id from the case
            Set<Id> enquiryIds = new Set<Id>(); // Set to store the enquiry ids of the case
            Set<Id> dealerIds = new Set<Id>();   // Set to store the dealer ids of the case

            for (Case newCase : newCases) {
                // In the case of category update
                Boolean isCategoryUpdate = false;
                if (oldCaseMap != null) {
                    isCategoryUpdate = isCategoryUpdated(newCase, oldCaseMap.get(newCase.Id));
                }
                if (newCase.Case_Type__c != ConstantsUtility.INTERNAL_CASE_TYPE && (oldCaseMap == null || isCategoryUpdate)) {
                    categoryIds.add(getCategoryId(newCase));
                    if (newCase.Enquiry__c != null) {
                        enquiryIds.add(newCase.Enquiry__c);
                    }
                    if (newCase.Dealer_Name__c != null) {
                        dealerIds.add(newCase.Dealer_Name__c);
                    }
                }


            }
            if (categoryIds.size() > 0) {
                categoryIdVsMapOfRegionAndRecipientMasterMap = CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(categoryIds);
                //System.debug('categoryIdVsMapOfRegionAndRecipientMasterMap ::: ' + categoryIdVsMapOfRegionAndRecipientMasterMap);
                // categoryIdVsMapOfRegionAndRecipientMasterMap is filled now.
                enquiryMap = getEnquiryMap(enquiryIds); // enquiry Map
                dealershipMap = getDealerMap(dealerIds); // Dealer Map
                developerNameVsQueueMap = getQueueMap(); // Queue Map
                userMap = getUserMap();
                caseTypeVsHierarchyMap = CaseAssignmentServiceHelper.getHierarchySelectionMap(newCases); // Hierarchy Type Map fill with Recipient Master's Hierarchy type
                // System.debug('caseTypeVsHierarchyMap ' + caseTypeVsHierarchyMap);
                newCases = updateStakeHolderJsonAndOwnerId(); // Stamp JSON ON case then updated the OwnerId

                /** RESET MILE STONES */
                resetMileStones(newCases, oldCaseMap);

            }
        } catch (Exception exp) {
            System.debug('Exception Message ::' + exp.getMessage() + ' At Line ' + exp.getLineNumber() + ' ' + exp.getStackTraceString());
            ExceptionHandler.stackTrace stackTrace = new ExceptionHandler.stackTrace();
            stackTrace.componentName = 'CaseAssignmentService';
            stackTrace.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseAssignmentService', exp.getMessage(), '', '', stackTrace);
        }
    }
    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method is used to return the lower most categoryId from Tertiary to Primary
        Input : Case Object instance
        History:
        * Version         Date                     Author                    Modification
        *==============================================================================
        * 1.0        07/07/2020                Deepak Kumar              Initial Version
    **/
    public static Id getCategoryId(Case caseObj) {
        Id categoryId; // Include Switch case here
        if (caseObj.Tertiary_Category_ID__c != null) {
            categoryId = caseObj.Tertiary_Category_ID__c;
        } else if (caseObj.Secondary_Category_ID__c != null) {
            categoryId = caseObj.Secondary_Category_ID__c;
        } else If (caseObj.Primary_Category_ID__c != null) {
            categoryId = caseObj.Primary_Category_ID__c;
        }
        return categoryId;
    }

    private static Map<Id, Opportunity> getEnquiryMap(Set<Id> enquiryIds) {
        Map<Id, Opportunity> enquiryMap = new Map<Id, Opportunity>(
        [SELECT OwnerId,Owner.IsActive FROM Opportunity WHERE Id IN:enquiryIds]
        );
        return enquiryMap;
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
    private static Map<String, Group> getQueueMap() {
        Map<String, Group> developerNameVsQueueMap = new Map<String, Group>();
        for (Group groupObj : [SELECT DeveloperName,Id FROM Group WHERE Type = 'Queue']) {
            developerNameVsQueueMap.put(groupObj.DeveloperName, groupObj);
        }
        return developerNameVsQueueMap;
    }
    /**
     Author: Deepak Kumar
     Company: Techmatrix
     Description: This method is used to get the queue Id
     Input : Queue Developer Name
     History:
     * Version         Date                     Author                    Modification
     *==============================================================================
     * 1.0        07/07/2020                Deepak Kumar              Initial Version
    **/
    public static Id getQueueId(String queueDeveloperName) {
        if (developerNameVsQueueMap.containsKey(queueDeveloperName)) {
            return developerNameVsQueueMap.get(queueDeveloperName).Id;
        }
        return null;
    }
    // This method  will return all of Id if users who all can be possibly participate later
    static Map<Id, User> getUserMap() {
        Set<Id> userIds = new Set<Id>(); // Set of Id if users who all can be possibly participate later
        for (Case newCase : newCases) {
            //userIds.add(newCase.OwnerId);
            if (newCase.Enquiry__c != null && enquiryMap.get(newCase.Enquiry__c).Owner.IsActive) {
                userIds.add(enquiryMap.get(newCase.Enquiry__c).OwnerId);
            }if (newCase.Dealer_Name__c != null && dealershipMap.get(newCase.Dealer_Name__c).Primary_QCM__c != null) {
                userIds.add(dealershipMap.get(newCase.Dealer_Name__c).Primary_QCM__c);
                /*if (dealershipMap.get(newCase.Dealer_Name__c).Territory_Sales_Manager__c != null) {
                    userIds.add(dealershipMap.get(newCase.Dealer_Name__c).Territory_Sales_Manager__c);
                }*/
            }
        }
        Map<Id, User> userMap = new Map<Id, User>(
        [SELECT Id,Phone,Email,Name,MobilePhone FROM User WHERE Id IN:userIds]
        );
        return userMap;
    }

    // Main Iteration on cases.
    private static List<Case> updateStakeHolderJsonAndOwnerId() {
        for (Case newCase : newCases) {
            /** FOR  MSIL QUERY CASES AND MS CORPORATE  CASES JSON STAMPING */
            if (newCase.Case_Type__c == ConstantsUtility.MSIL_QUERY_CASE_TYPE || newCase.Channel__c == ConstantsUtility.MS_CORPORATE_CASE_CHANNEL) {
                newCase = CaseAssignmentServiceHelper.updateStakeholderHierarchyJsonForMSILAndOwnerId(newCase); // JSON STAMPING AND OWNER UPDATE
            } else if (newCase.Case_Type__c != ConstantsUtility.MSIL_QUERY_CASE_TYPE) {
                newCase = updateStakeholderHierarchyJson(newCase); // StakeHolder JSON Stamping
                newCase = updatedOwnerFromJSON(newCase);  // Assign the OwnerId to the case
            }


        }
        return newCases;
    }

    // JSON UPDATE METHODS
    private static Case updateStakeholderHierarchyJson(Case newCase) {
        if (newCase.Dealer_Name__c != null) {
            String stakeholderHierarchyString = dealershipMap.get(newCase.Dealer_Name__c).Stakeholder_Hierarchy__c;
            if (stakeholderHierarchyString != null) {
                newCase.Stakeholders_JSON__c = getUpdatedHierarchyJson(stakeholderHierarchyString, newCase);
            }
        }
        return newCase;
    }
    
    
    private static String getUpdatedHierarchyJson(String stakeholderHierarchyString, Case newCase) {
        StakeholderHierarchy stakeholderHierarchy = StakeholderUtility.parseStakeholderHierarchyJson(stakeholderHierarchyString);
        List<StakeholderHierarchy.Sales> l1L2List = getL1l2InJSONInList(newCase);
        String categoryId = getCategoryId(newCase);
        Recipient_Master__c relatedRecipientMaster = CaseAssignmentServiceHelper.getRecipientMasterByCategoryIdAndRegionCode(categoryId, newCase.Region_Code__c);
        List<String> masterHierarchyTypes = new List<String>();
        if (relatedRecipientMaster.Hierarchy_Type__c != null) {
            masterHierarchyTypes = relatedRecipientMaster.Hierarchy_Type__c.split(';');
            // Iteration on the masterHierarchyTypes to get the related business area instead.
            for (String str : masterHierarchyTypes) {
                String hierarchyKey = newCase.Channel__c + newCase.Case_Type__c + str;
                stakeholderHierarchy = updateStakeHolderList(hierarchyKey, l1L2List, stakeholderHierarchy);
            }
        }
        return JSON.serialize(stakeholderHierarchy);
    }
    
    
    private static StakeholderHierarchy updateStakeHolderList(String hierarchyKey, List<StakeholderHierarchy.Sales> l1L2List, StakeholderHierarchy stakeholderHierarchy) {
        String hierarchyType = caseTypeVsHierarchyMap.get(hierarchyKey);
        // INCLUDE SWITCH CASE HERE OR MAP
        if (hierarchyType == ConstantsUtility.SALES_HIERARCHY && stakeholderHierarchy.sales != null && stakeholderHierarchy.sales.size() > 0) {
            stakeholderHierarchy.sales.addAll(l1L2List);
        } else if (hierarchyType == ConstantsUtility.ACCESSORIES_HIERARCHY && stakeholderHierarchy.accessories != null && stakeholderHierarchy.accessories.size() > 0) {
            stakeholderHierarchy.accessories.addAll(l1L2List);
        } else if (hierarchyType == ConstantsUtility.TRUEVALUE_HIERARCHY && stakeholderHierarchy.trueValue != null && stakeholderHierarchy.trueValue.size() > 0) {
            stakeholderHierarchy.trueValue.addAll(l1L2List);
        } else if (hierarchyType == ConstantsUtility.MSDS_HIERARCHY && stakeholderHierarchy.msds != null && stakeholderHierarchy.msds.size() > 0) {
            stakeholderHierarchy.msds.addAll(l1L2List);
        } else if (hierarchyType == ConstantsUtility.MSGP_HIERARCHY && stakeholderHierarchy.msgp != null && stakeholderHierarchy.msgp.size() > 0) {
            stakeholderHierarchy.msgp.addAll(l1L2List);
        } else if (hierarchyType == ConstantsUtility.LOYALTY_PROGRAM_HIERARCHY && stakeholderHierarchy.loyaltyProgram != null && stakeholderHierarchy.loyaltyProgram.size() > 0) {
            stakeholderHierarchy.loyaltyProgram.addAll(l1L2List);
        } else if (hierarchyType == ConstantsUtility.FINANCE_HIERARCHY && stakeholderHierarchy.finance != null && stakeholderHierarchy.finance.size() > 0) {
            stakeholderHierarchy.finance.addAll(l1L2List);
        } // NO need to added for SERVICE HIERARCHY
        /*else if (hierarchyType == ConstantsUtility.SERVICE_ARENA_HIERARCHY && stakeholderHierarchy.serviceArena != null && stakeholderHierarchy.serviceArena.size() > 0) {
             stakeholderHierarchy.serviceArena.addAll(l1L2List);  // NO Need to Add in Service Case
        }else if (hierarchyType == ConstantsUtility.SERVICE_NEXA_HIERARCHY && stakeholderHierarchy.serviceNexa != null && stakeholderHierarchy.serviceNexa.size() > 0) {
            stakeholderHierarchy.serviceNexa.addAll(l1L2List);  // NO Need to Add in Service Case
        } */

        return stakeholderHierarchy;
    }
    
    
    /** This method is used to generate the List of initial JSON for L1  */
    private static List<StakeholderHierarchy.Sales> getL1l2InJSONInList(Case newCase) {
        Id l1Id;
        if (newCase.Enquiry__c != null && enquiryMap.get(newCase.Enquiry__c).Owner.IsActive) {
            l1Id = enquiryMap.get(newCase.Enquiry__c).OwnerId;
        }
        List<StakeholderHierarchy.Sales> saleList = new List<StakeholderHierarchy.Sales>(); // List of the initial JSON to add the L1 and L2
        StakeholderHierarchy.Sales sales = new StakeholderHierarchy.Sales();
        // Adding L1 to the List
        if (l1Id != null) {
            sales.recordId = userMap.get(L1Id).Id;
            sales.email = userMap.get(L1Id).Email;
            sales.phone = userMap.get(L1Id).Phone != null ? userMap.get(L1Id).Phone : '';
            sales.refName = userMap.get(L1Id).Name;
            sales.stakeHolder = ConstantsUtility.NOTIFIER_L1A; 
            saleList.add(sales);
        } else {
            sales.recordId = '';
            sales.email = '';
            sales.phone = '';
            sales.refName = '';
            sales.stakeHolder = ConstantsUtility.NOTIFIER_L1A;
            saleList.add(sales);
        }
        return saleList;
    }

    
    // OWNER UPDATE METHODS
    private static Case updatedOwnerFromJSON(Case newCase) {

        Id cateGoryId = getCategoryId(newCase);
        Recipient_Master__c relatedRecipientMaster = CaseAssignmentServiceHelper.getRecipientMasterByCategoryIdAndRegionCode(cateGoryId, newCase.Region_Code__c);
        if (relatedRecipientMaster != null && relatedRecipientMaster.Owner_Type__c == ConstantsUtility.RM_OWNER_TYPE_USER) {
            String hierarchyType = newCase.Channel__c + newCase.Case_Type__c + CaseAssignmentServiceHelper.getActualLob(newCase.Business_Area__c);

            hierarchyType = caseTypeVsHierarchyMap.get(hierarchyType); // Selection of hierarchy Type
            newCase.Selected_Hierarchy_Type__c = hierarchyType; // Updating the hierarchyType so it can help in case sharing

            newCase.OwnerId = getOwnerBasedOnHierarchyTypeAndRecipientMaster(relatedRecipientMaster.Case_Ownership__c, newCase.Stakeholders_JSON__c, hierarchyType);
            newCase.Assignment_Error_Message__c = null;
            newCase.Assigned_Date__c = Datetime.now();
            if (newCase.OwnerId == null) {
                newCase.OwnerId = getQueueId(ConstantsUtility.UNASSIGNED_QUEUE);
                newCase.Assignment_Error_Message__c = ConstantsUtility.CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_MASTER_ERROR;
                newCase.Assigned_Date__c = null;
            }
        } else if (relatedRecipientMaster != null && relatedRecipientMaster.Owner_Type__c == ConstantsUtility.RM_OWNER_TYPE_QUEUE) { // Queue Owner
            newCase.OwnerId = getQueueId(relatedRecipientMaster.Queue_Name__c);
            newCase.Assignment_Error_Message__c = ConstantsUtility.CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_QUEUE_ON_MASTER;
        } else {   // UnAssigned Queue Owner
            newCase.OwnerId = CaseAssignmentService.getQueueId(ConstantsUtility.UNASSIGNED_QUEUE);
            newCase.Assignment_Error_Message__c = ConstantsUtility.CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_MASTER_NOT_FOUND;
        }
        return newCase;
    }
    
    
    private static Id getOwnerBasedOnHierarchyTypeAndRecipientMaster(String relatedOwners, String stakeHoldersJson, String hierarchyType) {
        Id ownerId;
        List<String> userList = relatedOwners.split(';'); // Possible owners list
        StakeholderHierarchy stakeholderHierarchy = StakeholderUtility.parseStakeholderHierarchyJson(stakeHoldersJson); // Parsed JSON

        if (hierarchyType == ConstantsUtility.SALES_HIERARCHY && stakeholderHierarchy.sales != null && stakeholderHierarchy.sales.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.sales, userList);
        } else if (hierarchyType == ConstantsUtility.SERVICE_NEXA_HIERARCHY && stakeholderHierarchy.serviceNexa != null && stakeholderHierarchy.serviceNexa.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.serviceNexa, userList);
        }else if (hierarchyType == ConstantsUtility.SERVICE_ARENA_HIERARCHY && stakeholderHierarchy.serviceArena != null && stakeholderHierarchy.serviceArena.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.serviceArena, userList);
        }else if (hierarchyType == ConstantsUtility.ACCESSORIES_HIERARCHY && stakeholderHierarchy.accessories != null && stakeholderHierarchy.accessories.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.accessories, userList);
        } else if (hierarchyType == ConstantsUtility.TRUEVALUE_HIERARCHY && stakeholderHierarchy.trueValue != null && stakeholderHierarchy.trueValue.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.trueValue, userList);
        } else if (hierarchyType == ConstantsUtility.MSDS_HIERARCHY && stakeholderHierarchy.msds != null && stakeholderHierarchy.msds.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.msds, userList);
        } else if (hierarchyType == ConstantsUtility.MSGP_HIERARCHY && stakeholderHierarchy.msgp != null && stakeholderHierarchy.msgp.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.msgp, userList);
        } else if (hierarchyType == ConstantsUtility.LOYALTY_PROGRAM_HIERARCHY && stakeholderHierarchy.loyaltyProgram != null && stakeholderHierarchy.loyaltyProgram.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.loyaltyProgram, userList);
        } else if (hierarchyType == ConstantsUtility.FINANCE_HIERARCHY && stakeholderHierarchy.finance != null && stakeholderHierarchy.finance.size() > 0) {
            ownerId = getOwnerBasedOnSelectedHierarchyJson(stakeholderHierarchy.finance, userList);
        }
        return ownerId;
    }
    private static Id getOwnerBasedOnSelectedHierarchyJson(List<StakeholderHierarchy.Sales> stakeHolderList, List<String> users) {
        Id ownerId;
        users.sort();
        // PUT THIS IN A MAP (stakeHolderList) - then iterate
        for (String user : users) {
            for (StakeholderHierarchy.Sales holder : stakeHolderList) {
                if (user == holder.stakeHolder && holder.recordId != null && holder.recordId != '') {
                    ownerId = Id.valueOf(holder.recordId);
                    break;
                }
            }
            if (ownerId != null) {
                break;
            }

        }
        return ownerId;
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: This method is used to determine that Category and related fields have changed or not
       Input : Case Object instance
       History:
       * Version         Date                     Author                    Modification
       *==============================================================================
       * 1.0        07/07/2020                Deepak Kumar              Initial Version
   **/
    public static Boolean isCategoryUpdated(Case newCase, Case oldCase) {
        if (oldCase.Channel__c != newCase.Channel__c || oldCase.Case_Type__c != newCase.Case_Type__c || oldCase.Business_Area__c != newCase.Business_Area__c
                || oldCase.Case_Stage__c != newCase.Case_Stage__c || oldCase.Primary_Category_ID__c != newCase.Primary_Category_ID__c
                || oldCase.Secondary_Category_ID__c != newCase.Secondary_Category_ID__c || oldCase.Tertiary_Category_ID__c != newCase.Tertiary_Category_ID__c
                || oldCase.Outlet_Type__c != newCase.Outlet_Type__c || oldCase.For_Code__c != newCase.For_Code__c
                || oldCase.Dealer_Name__c != newCase.Dealer_Name__c) {
            return true;
        }
        return false;
    }

    /**
       Author: Deepak Kumar
       Company: Techmatrix
       Description: This method is used to Reset the milestones of the case once the dealer updated
       Input : Case Object instance
       History:
       * Version         Date                     Author                    Modification
       *==============================================================================
       * 1.0        25/08/2020                Deepak Kumar              Initial Version
   **/
    public static void resetMileStones(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        if (oldCaseMap != null && !oldCaseMap.isEmpty()) {
            Set<Id> caseIds = new Set<Id>();
            for (Case caseObj : newCases) {
                Case OldCase = oldCaseMap.get(caseObj.Id);
                // If assignment updated
                if (OldCase != null && OldCase.Assigned_Date__c != caseObj.Assigned_Date__c) {
                    caseIds.add(caseObj.Id);
                }
            }
            if (caseIds.size() > 0) {
                List<String> milestoneNames = new List<String>();
               // milestoneNames.add(ConstantsUtility.CASE_MILESTONE_FIRST_RESPONSE);
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_CASE_CLOSURE_TIME);
                MilestoneUtils.completeMilestone(caseIds, milestoneNames, DateTime.now());
            }

        }
    }
}