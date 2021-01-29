public without sharing class CaseAssignmentServiceHelper {
    public static Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();
    public static Map<String, String> caseTypeVsHierarchyMap = new Map<String, String>();

    /**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: This method is used to get the categoryId,Region and Related RecipientMaster Map
    Input : Set of Category Id
    History:
    * Version         Date                     Author                    Modification
    *==============================================================================
    * 1.0        07/07/2020                Deepak Kumar              Initial Version
    **/
    public static Map<String, Map<String, Recipient_Master__c>> getCategoryRecipientMasterMap(Set<Id> categoryIds) {
        // Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();
        List<Recipient_List__c> categoryRelatedRecipientList = new List<Recipient_List__c>(); // List to store the related Recipient List
        //  System.debug('categoryIds' +categoryIds);
        categoryRelatedRecipientList = getRecipientList(categoryIds);
        // System.debug('categoryRelatedRecipientList '+categoryRelatedRecipientList);
        Map<String, Id> regionVsRecipientMasterIdMap = getRegionVsRecipientMasterId(categoryRelatedRecipientList);  // region and Recipient Master Id Map
        Map<Id, String> categoryIdVsRegionMap = getCategoryIdVsRegionMap(categoryRelatedRecipientList);  //categoryId and Region Map
        Map<Id, Recipient_Master__c> recipientMasterMap = getRecipientMasterMap(regionVsRecipientMasterIdMap.values()); // Recipient Master Map
        // Iterating the category to fill the categoryIdVsMapOfRegionAndRecipientMasterMap
        for (Id categoryId : categoryIds) {
            String region_categoryId = categoryIdVsRegionMap.get(categoryId);
            if (regionVsRecipientMasterIdMap.containsKey(region_categoryId)) {
                Id recipientMasterId = regionVsRecipientMasterIdMap.get(region_categoryId);
                if (recipientMasterMap.containsKey(recipientMasterId)) {
                    Recipient_Master__c recipientMaster = recipientMasterMap.get(recipientMasterId);
                    Map<String, Recipient_Master__c> regionVsRecipientMastersMapTemp = new Map<String, Recipient_Master__c>(); // Temp map to store the region code and related Recipient Master
                    String region = region_categoryId.split('_')[0];
                    regionVsRecipientMastersMapTemp.put(region, recipientMaster);
                    categoryIdVsMapOfRegionAndRecipientMasterMap.put(categoryId, regionVsRecipientMastersMapTemp);

                }
            }
        }
        return categoryIdVsMapOfRegionAndRecipientMasterMap;
    }
    private static List<Recipient_List__c> getRecipientList(Set<Id> categoryIds) {
        return [SELECT Id,Region__c,Recipient_Master__c,Category__c FROM Recipient_List__c WHERE Category__c IN:categoryIds];
    }
    private static Map<String, Id> getRegionVsRecipientMasterId(List<Recipient_List__c> recipientLists) {
        Map<String, Id> regionVsRecipientMasterIdMap = new Map<String, Id>();
        for (Recipient_List__c recipientList : recipientLists) {
            if (recipientList.Region__c == null) {
                recipientList.Region__c = ConstantsUtility.REGION_ALL;
            }
            regionVsRecipientMasterIdMap.put(recipientList.Region__c + '_' + recipientList.Category__c, recipientList.Recipient_Master__c);
        }
        return regionVsRecipientMasterIdMap;
    }
    private static Map<Id, String> getCategoryIdVsRegionMap(List<Recipient_List__c> recipientLists) {
        Map<Id, String> categoryIdVsRegionMap = new Map<Id, String> ();
        for (Recipient_List__c recipient : recipientLists) {
            if (recipient.Region__c == null) {
                recipient.Region__c = ConstantsUtility.REGION_ALL;
            }
            categoryIdVsRegionMap.put(recipient.Category__c, recipient.Region__c + '_' + recipient.Category__c);
        }
        return categoryIdVsRegionMap;
    }
    private static Map<Id, Recipient_Master__c> getRecipientMasterMap(List<Id> recipientMasterIds) {
        Map<Id, Recipient_Master__c> recipientMasterMap = new Map<Id, Recipient_Master__c>(
        [
                SELECT
                        Case_Ownership__c,
                        Hierarchy_Type__c,
                        MSIL_Stakeholder_JSON__c,
                        Id,
                        Level_0_Cc__c,
                        Level_0_To__c,
                        Level_1_Cc__c,
                        Level_1_To__c,
                        Level_2_Cc__c,
                        Level_2_To__c,
                        Level_3_Cc__c,
                        Level_3_To__c,
                        Level_4_Cc__c,
                        Level_4_To__c,
                        Level_5_Cc__c,
                        Level_5_To__c,
                        Level_6_Cc__c,
                        Level_6_To__c,
                        Name,
                        Owner_Type__c,
                        Queue_Name__c
                FROM Recipient_Master__c
                WHERE Id IN:recipientMasterIds
        ]
        );
        return recipientMasterMap;
    }


    /**
         Author: Deepak Kumar
         Company: Techmatrix
         Description: This method will create a map of hierarchy to select the JSON.
         Input : Case Object instance
         History:
         * Version         Date                     Author                    Modification
         *==============================================================================
         * 1.0        07/07/2020                Deepak Kumar              Initial Version
     **/
    public static Map<String, String> getHierarchySelectionMap(List<Case> newCases) {
        for (Case newCase : newCases) {
            getHierarchyBasedOnRecipientMaster(newCase);
        }
        return caseTypeVsHierarchyMap;
    }
    private static void getHierarchyBasedOnRecipientMaster(Case newCase) {
        String categoryId = CaseAssignmentService.getCategoryId(newCase);
        Recipient_Master__c relatedRecipientMaster = getRecipientMasterByCategoryIdAndRegionCode(categoryId, newCase.Region_Code__c);
        if(relatedRecipientMaster !=null && relatedRecipientMaster.Hierarchy_Type__c !=null){
            // System.debug('relatedRecipientMaster 1 '+relatedRecipientMaster);
            List<String> masterHierarchyTypes = relatedRecipientMaster.Hierarchy_Type__c.split(';');
            // Iteration on the masterHierarchyTypes to get the related business area instead.
            for (String str : masterHierarchyTypes) {
                String hierarchyKey = newCase.Channel__c + newCase.Case_Type__c + str;
                getHierarchyTypeMap(hierarchyKey, newCase,str); // Filling the Hierarchy Type Map.

            }
        }
    }
    private static void getHierarchyTypeMap(String hierarchyKey, Case newCase,String businessAreaType) {
        if (newCase.Channel__c == ConstantsUtility.NEXA_CASE_CHANNEL || newCase.Channel__c == ConstantsUtility.ARENA_CASE_CHANNEL
                || newCase.Channel__c == ConstantsUtility.COMMERCIAL_CASE_CHANNEL) {
            nexaArenaCommercial(hierarchyKey, newCase,businessAreaType);
        } else if (newCase.Channel__c == ConstantsUtility.MSDS_CASE_CHANNEL) {
            caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.MSDS_HIERARCHY);
        } else if (newCase.Channel__c == ConstantsUtility.TRUEVALUE_CASE_CHANNEL) {
            caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.TRUEVALUE_HIERARCHY);
        } else if (newCase.Channel__c == ConstantsUtility.MSGP_CASE_CHANNEL) {
            caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.MSGP_HIERARCHY);
        } else if (newCase.Channel__c == ConstantsUtility.MS_CORPORATE_CASE_CHANNEL) {  /** SPECIAL CASE FOR MS CORPORATE CASES IT WILL PICK THE SAME MSIL QUERY CASES */
            caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.MSIL_QUERY_HIERARCHY); //
        }
    }
    private static void nexaArenaCommercial(String hierarchyKey, Case newCase,String businessAreaType) {
        // Check for Case Type
        if (newCase.Case_Type__c == ConstantsUtility.COMPLAINT_CASE_TYPE || newCase.Case_Type__c == ConstantsUtility.DEALER_QUERY_CASE_TYPE
                || newCase.Case_Type__c == ConstantsUtility.DEALER_FEEDBACK_CASE_TYPE) {
            // Updated Business ara type else use previous commented code
            if (businessAreaType == ConstantsUtility.SALES_CASE_BUSINESS_AREA) {
                caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.SALES_HIERARCHY);
            } else if (businessAreaType == ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA) {
                caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.ACCESSORIES_HIERARCHY); // Accessories
            } else if (businessAreaType == ConstantsUtility.LOYALTY_PROGRAM_CASE_BUSINESS_AREA) {
                caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.LOYALTY_PROGRAM_HIERARCHY);  // Loyalty Program
            } else if (businessAreaType == ConstantsUtility.FINANCE_CASE_BUSINESS_AREA) {
                caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.FINANCE_HIERARCHY);  // Finance
            } else if (businessAreaType == ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA || businessAreaType == ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA || businessAreaType == ConstantsUtility.SERVICE_CASE_BUSINESS_AREA) {
                String type = newCase.Channel__c == ConstantsUtility.ARENA_CASE_CHANNEL ? ConstantsUtility.SERVICE_ARENA_HIERARCHY : ConstantsUtility.SERVICE_NEXA_HIERARCHY;
                caseTypeVsHierarchyMap.put(hierarchyKey, type);  // SERVICE WORKSHOP
            }
        }
        if (newCase.Case_Type__c == ConstantsUtility.MSIL_QUERY_CASE_TYPE) {
            caseTypeVsHierarchyMap.put(hierarchyKey, ConstantsUtility.MSIL_QUERY_HIERARCHY);
        }
    }
    /**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: This method is used to get the Hierarchy for the MSIL Query cases.
    Input : ListL<Case>
    History:
    * Version         Date                     Author                    Modification
    *==============================================================================
    * 1.0        14/07/2020                Deepak Kumar              Initial Version
    **/
    public static Case updateStakeholderHierarchyJsonForMSILAndOwnerId(Case newCase) {
        String categoryId = CaseAssignmentService.getCategoryId(newCase);
        Recipient_Master__c recipientMaster = getRecipientMasterByCategoryIdAndRegionCode(categoryId, newCase.Region_Code__c);
        // System.debug('recipientMaster ::'+recipientMaster);
        newCase.MSIL_Non_SF_Stakeholder_Email__c = null;
        newCase.MSIL_Non_SF_Stakeholder_Phone__c = null;
        String caseHierarchyType = newCase.Channel__c + newCase.Case_Type__c + getActualLob(newCase.Business_Area__c);
        String jsonHierarchyType = caseTypeVsHierarchyMap.get(caseHierarchyType);
        newCase.Stakeholders_JSON__c = recipientMaster.MSIL_Stakeholder_JSON__c; // JSON STAMPING
        newCase.Selected_Hierarchy_Type__c = jsonHierarchyType; // Selection of hierarchy Type
        if (recipientMaster != null && recipientMaster.MSIL_Stakeholder_JSON__c != null && recipientMaster.Owner_Type__c == ConstantsUtility.RM_OWNER_TYPE_USER && newCase.Stakeholders_JSON__c != null) {
            // CODE TO UPDATE the OwnerId.
            String ownerAndEmail = getOwnerIdForMSIL(newCase.Stakeholders_JSON__c, recipientMaster.Case_Ownership__c, jsonHierarchyType);
            newCase.OwnerId = ownerAndEmail !=null && ownerAndEmail.split('-')[0].startsWith(ConstantsUtility.UserPrefix) ? ownerAndEmail.split('-')[0] : null;  // Assigning OwnerID
            newCase.Assignment_Error_Message__c = null;
            newCase.Assigned_Date__c = DateTime.now();
            if (newCase.OwnerId == null) {
                newCase.OwnerId = CaseAssignmentService.getQueueId(ConstantsUtility.UNASSIGNED_QUEUE);
                newCase.Assignment_Error_Message__c = ConstantsUtility.CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_MASTER_ERROR;
                newCase.Assigned_Date__c =null;
            }
        } else if (recipientMaster != null && recipientMaster.Owner_Type__c == ConstantsUtility.RM_OWNER_TYPE_QUEUE) {
            newCase.OwnerId = CaseAssignmentService.getQueueId(recipientMaster.Queue_Name__c);
            newCase.Assignment_Error_Message__c = ConstantsUtility.CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_QUEUE_ON_MASTER;
            System.debug(newCase.Stakeholders_JSON__c);
            if(newCase.Stakeholders_JSON__c != null){
                String ownerAndEmail = getOwnerIdForMSIL(newCase.Stakeholders_JSON__c, recipientMaster.Case_Ownership__c, jsonHierarchyType);
                System.debug('ownerAndEmail '+ownerAndEmail);
                newCase.MSIL_Non_SF_Stakeholder_Email__c = ownerAndEmail !=null && !ownerAndEmail.split('-')[0].startsWith(ConstantsUtility.UserPrefix) && ownerAndEmail.split('-')[1] !=null ? ownerAndEmail.split('-')[1] :null ; // Assigning Email
                newCase.MSIL_Non_SF_Stakeholder_Phone__c = ownerAndEmail !=null && !ownerAndEmail.split('-')[0].startsWith(ConstantsUtility.UserPrefix) && ownerAndEmail.split('-')[2] !=null ? ownerAndEmail.split('-')[2] :null ; // Assigning Phone
            }
        } else {
            // Code to update the Assignment error reason
            newCase.OwnerId = CaseAssignmentService.getQueueId(ConstantsUtility.UNASSIGNED_QUEUE);
            newCase.Assignment_Error_Message__c = ConstantsUtility.CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_MASTER_NOT_FOUND;

        }
        return newCase;
    }
    private static String getOwnerIdForMSIL(String msilHierarchyJson, String msilOwners, String jsonHierarchyType) {
        String ownerId;
        StakeholderHierarchy stakeholderHierarchy = StakeholderUtility.parseStakeholderHierarchyJson(msilHierarchyJson);
        List<String> msilOwnerList = msilOwners.split(';');
        if ((jsonHierarchyType == ConstantsUtility.MSIL_QUERY_HIERARCHY || jsonHierarchyType == ConstantsUtility.MS_CORPORATE_HIERARCHY) // For both MS CORPORATE AND MSIL QUERY.
                && (stakeholderHierarchy.msilQuery != null && stakeholderHierarchy.msilQuery.size() > 0)) {
            msilOwnerList.sort();
            for (String msilUser : msilOwnerList) {
                for (StakeholderHierarchy.Sales holder : stakeholderHierarchy.msilQuery) {
                    if (msilUser == holder.stakeHolder && holder.recordId != null && holder.recordId != '') {
                        ownerId = holder.recordId + '-'+holder.email + '-'+ holder.phone;
                        break;
                    }
                }
                if (ownerId != null) {
                    break;
                }
            }

        }
        return ownerId;
    }

    /**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: This method will return the Recipient_Master based,
    Input : String categoryId, String regionCode
    History:
    * Version         Date                     Author                    Modification
    *==============================================================================
    * 1.0        14/07/2020                Deepak Kumar              Initial Version
    **/
    public static Recipient_Master__c getRecipientMasterByCategoryIdAndRegionCode(String categoryId, String regionCode) {
        Recipient_Master__c recipientMaster = new Recipient_Master__c();
        if (regionCode == null) {
            regionCode = ConstantsUtility.REGION_ALL;
        }
        if (categoryIdVsMapOfRegionAndRecipientMasterMap.containsKey(categoryId)) {
            recipientMaster = categoryIdVsMapOfRegionAndRecipientMasterMap.get(categoryId).get(regionCode);
            if(recipientMaster == null){
                recipientMaster = categoryIdVsMapOfRegionAndRecipientMasterMap.get(categoryId).get(ConstantsUtility.REGION_ALL);
            }
        }
        return recipientMaster;
    }

    /**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: This Method will get business area as an input and return the Hierarchy type String to get the Actual hierarchy type
    Input : String String
    History:
    * Version         Date                     Author                    Modification
    *==============================================================================
    * 1.0        14/07/2020                Deepak Kumar              Initial Version
    **/

    public static String getActualLob(String businessArea){
        String actualLob='';
        if(businessArea == ConstantsUtility.SALES_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        }else if(businessArea == ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA;
        }else if(businessArea == ConstantsUtility.LOYALTY_PROGRAM_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.LOYALTY_PROGRAM_CASE_BUSINESS_AREA;
        } else if(businessArea == ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.SERVICE_CASE_BUSINESS_AREA;
        }else if(businessArea == ConstantsUtility.SERVICE_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.SERVICE_CASE_BUSINESS_AREA;
        }else if(businessArea == ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.SERVICE_CASE_BUSINESS_AREA;
        } else if(businessArea == ConstantsUtility.DRIVING_SCHOOL_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSDS_LOB;
        }else if(businessArea == ConstantsUtility.DISTRIBUTOR_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSDS_LOB;
        }else if(businessArea == ConstantsUtility.WORKSHOPS_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSDS_LOB;
        }else if(businessArea == ConstantsUtility.BUYER_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.TRUEVALUE_CASE_CHANNEL;
        }else if(businessArea == ConstantsUtility.SELLER_EXCHANGE_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.TRUEVALUE_CASE_CHANNEL;
        }else if(businessArea == ConstantsUtility.TV_SALES_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.TRUEVALUE_CASE_CHANNEL;
        }else if(businessArea == ConstantsUtility.INTERNATIONAL_MARKETING_EXPORTS_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        }else if(businessArea == ConstantsUtility.DOMESTIC_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        }else if(businessArea == ConstantsUtility.MIBPL_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        }else if(businessArea == ConstantsUtility.SUZUKI_MOTORCYCLES_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        }else if(businessArea == ConstantsUtility.FINANCE_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.FINANCE_CASE_BUSINESS_AREA;
        }else if(businessArea == ConstantsUtility.NONE_CASE_BUSINESS_AREA){
            actualLob  =  ConstantsUtility.NONE_CASE_BUSINESS_AREA;
        }

        return actualLob;
    }
}