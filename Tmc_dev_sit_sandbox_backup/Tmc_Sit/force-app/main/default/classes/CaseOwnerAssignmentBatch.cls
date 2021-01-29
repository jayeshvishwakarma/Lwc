/**
     * @File Name          : CaseOwnerAssignmentBatch.cls
     * @Description        : This batch class is responsible to update the JSON Hierarchy on the Dealer master and the Recipient Masters.
     * @Author             : Deepak Kumar
     * @Last Modified By   : Deepak Kumar
     * @Last Modified On   : 14/07/2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        14/07/2020                Deepak Kumar              Initial Version
**/


global class CaseOwnerAssignmentBatch implements Database.Batchable<sObject> {
    global String query;
    global String objectType;
    public static Set<String> usersIds = new Set<String>();
    global CaseOwnerAssignmentBatch(String objectType) {
        this.objectType = objectType;

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (objectType != null && objectType == 'Account') {
            String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
            String query = 'SELECT ';
            String fields = getDealerConstructedFields();
            if (fields != '') {
                query += fields.trim() + ', ';
            }
            query += 'Stakeholder_Hierarchy__c,Region_Code__c,DMS_Primaries__c,Dealer_Type__c,Channel__c FROM Account WHERE  RecordTypeId = :recordTypeId';
            System.debug('Query-->'+query);
            //Database.query(query);
            return Database.getQueryLocator(query);
        } else {
            return Database.getQueryLocator([
                    SELECT Active__c, Business_Area__c, Case_Stage__c, Case_Type__c, Channel__c, Name, Type__c
                    FROM Category__c
                    WHERE
                    Case_Type__c = :ConstantsUtility.MSIL_QUERY_CASE_TYPE OR
                    (Case_Type__c = :ConstantsUtility.COMPLAINT_CASE_TYPE AND Business_Area__c = :ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA AND
                    Case_Stage__c = :ConstantsUtility.CASE_STAGE_POST_SALES AND Type__c = :ConstantsUtility.SECONDARY_CATEGORY AND Primary_Category__r.Name = :ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT)
            ]);
        }
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            /** Dealer Related */
            if (objectType == 'Account') {
                usersIds.clear();
                ProcessDealerQuery(scope);
            } else {
                // Further Process to MSIL query AND MS Corporate
                ProcessMsilQuery(scope);
            }
        } catch (Exception exp) {
            System.debug('Exception  Message :: ' + exp.getMessage() + ' At ' + exp.getStackTraceString());
            ExceptionHandler.stackTrace stackTrace = new ExceptionHandler.stackTrace();
            stackTrace.componentName = 'CaseOwnerAssignmentBatch';
            stackTrace.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('CaseOwnerAssignmentBatch', exp.getMessage() + ' -- ' + exp.getStackTraceString(), '', '', stackTrace);
        }


    }
    global void finish(Database.BatchableContext BC) {
        System.debug('CaseOwnerAssignmentBatch Batch Finished');
    }

    /**
     Author: Deepak Kumar
     Company: Techmatrix
     Description: This method is used to process the dealer records
     Returns: String
     History:
     * Ver         Date                     Author                    Modification
     *==============================================================================
     * 1.0          29/07/2020             Deepak                     Initial Version
  **/
    private static void processDealerQuery(List<SObject> scope) {
        List<Account> dealerAccounts = (List<Account>) scope; // TypeCasting to sObject to Account
        System.debug('dealerAccounts ' + dealerAccounts.size());
        Map<String, Case_Assignment_Hierarchy__mdt> lobVsCaseAssignmentHierarchyMap = getLobVsCaseAssignmentHierarchyMap();
        Map<String, Complaint_Coordinator__c> regionTypeVsComplaintCoordinatorMap = getComplaintCoordinatorForDealer();
        List<Account> dealerAccountsToUpdate = new List<Account>();
        // Set<Id> usersIds = new Set<Id>();
        for (Account dealerAccount : dealerAccounts) {
            if (dealerAccount.Id != '0011s00000GIZxI') {
                //continue;
            }
            // Stake Holder hierarchy for hierarchy type objects
            StakeholderHierarchy stakeholderHierarchy = getStakeholderHierarchyInstance(); // new StakeholderHierarchy();

            // Iteration over the  lobVsCaseAssignmentHierarchyMap to get the Lobs
            for (String lob : lobVsCaseAssignmentHierarchyMap.keySet()) {
                // Stake Holder hierarchy Json Object
                StakeholderHierarchy.Sales hierarchyObject = new StakeholderHierarchy.Sales();
                Case_Assignment_Hierarchy__mdt caseAssignmentHierarchy = lobVsCaseAssignmentHierarchyMap.get(lob);
                lob = lob.split('_')[0];
                String recordId = '';
                String email = '';
                String phone = '';
                hierarchyObject.refName = caseAssignmentHierarchy.Reference_Type__c;
                hierarchyObject.stakeHolder = caseAssignmentHierarchy.Level__c;
                if (caseAssignmentHierarchy.Object__c == 'Account') {
                    if (caseAssignmentHierarchy.Reference_Field__c.contains('.')) {
                        List<String> fields = caseAssignmentHierarchy.Reference_Field__c.split('\\.');
                        sObject ob = dealerAccount;
                        for (Integer i = 0; i < fields.size(); i++) {
                            ob = ob;
                            String str = fields[i];
                            if (ob != null && i != (fields.size() - 1)) {
                                ob = ob.getSobject(str);
                            } else if (ob != null) {
                                recordId = (String) ob.get(str);
                            }
                        }
                    } else {
                        recordId = (String) dealerAccount.get(caseAssignmentHierarchy.Reference_Field__c);
                    }
                } else if (caseAssignmentHierarchy.Object__c == 'Complaint_Coordinator__c') {
                    String regionTypeKey = dealerAccount.Channel__c + dealerAccount.Region_Code__c + caseAssignmentHierarchy.Reference_Type__c;
                    String typeKey = dealerAccount.Channel__c + caseAssignmentHierarchy.Reference_Type__c;
                    Complaint_Coordinator__c complaintCoordinator;
                    complaintCoordinator = regionTypeVsComplaintCoordinatorMap.containsKey(regionTypeKey) ? regionTypeVsComplaintCoordinatorMap.get(regionTypeKey) : null;
                    complaintCoordinator = complaintCoordinator != null && regionTypeVsComplaintCoordinatorMap.containsKey(typeKey) ? regionTypeVsComplaintCoordinatorMap.get(typeKey) : complaintCoordinator;
                    if (complaintCoordinator != null) {
                        // recordId = (String) complaintCoordinator.get(caseAssignmentHierarchy.Reference_Field__c);
                        if (caseAssignmentHierarchy.Reference_Field__c.contains('.')) {
                            List<String> fields = caseAssignmentHierarchy.Reference_Field__c.split('\\.');
                            sObject ob = complaintCoordinator;
                            for (Integer i = 0; i < fields.size(); i++) {
                                ob = ob;
                                String str = fields[i];
                                if (ob != null && i != (fields.size() - 1)) {
                                    ob = ob.getSobject(str);
                                } else if (ob != null) {
                                    recordId = (String) ob.get(str);
                                }
                            }
                        } else {
                            recordId = (String) complaintCoordinator.get(caseAssignmentHierarchy.Reference_Field__c);
                        }
                        // recordId = (String) complaintCoordinator.get(caseAssignmentHierarchy.Reference_Field__c);
                        System.debug('recordId ' + recordId);
                    }
                }

                hierarchyObject.recordId = recordId != null ? recordId : '';
                hierarchyObject.email = email;
                hierarchyObject.phone = phone;
                if (recordId != '' && recordId != null) {
                    usersIds.add(recordId);
                }
                //   System.debug('lob '+lob);
                stakeholderHierarchy = addHierarchy(stakeholderHierarchy, hierarchyObject, lob);
            }

            /** FROM DMS_Primaries__c Field */
            if (dealerAccount.DMS_Primaries__c != null) {
                StakeholderHierarchy hierarchy = getUsersFromDMSPrimaries(dealerAccount);
                if (hierarchy.sales != null && hierarchy.sales.size() > 0) {
                    stakeholderHierarchy.sales.addAll(hierarchy.sales);
                }
                if (hierarchy.serviceNexa != null && hierarchy.serviceNexa.size() > 0) {
                    stakeholderHierarchy.serviceNexa.addAll(hierarchy.serviceNexa);
                }
                if (hierarchy.serviceArena != null && hierarchy.serviceArena.size() > 0) {
                    stakeholderHierarchy.serviceArena.addAll(hierarchy.serviceArena);
                }
                if (hierarchy.accessories != null) {
                    stakeholderHierarchy.accessories.addAll(hierarchy.accessories);
                }
                if (hierarchy.trueValue != null) {
                    stakeholderHierarchy.trueValue.addAll(hierarchy.trueValue);
                }
                if (hierarchy.msds != null) {
                    stakeholderHierarchy.msds.addAll(hierarchy.msds);
                }
                if (hierarchy.msgp != null) {
                    stakeholderHierarchy.msgp.addAll(hierarchy.msgp);
                }
                if (hierarchy.loyaltyProgram != null) {
                    stakeholderHierarchy.loyaltyProgram.addAll(hierarchy.loyaltyProgram);
                }
                if (hierarchy.finance != null) {
                    stakeholderHierarchy.finance.addAll(hierarchy.finance);
                }
                System.debug(hierarchy);
            }
            dealerAccount.Stakeholder_Hierarchy__c = JSON.serialize(stakeholderHierarchy);
            dealerAccountsToUpdate.add(dealerAccount);
        }
        if (usersIds.size() > 0) {
            Map<Id, User> userMap = getUserMap(usersIds);
            for (Account dealerAccount : dealerAccountsToUpdate)
                dealerAccount.Stakeholder_Hierarchy__c = UpdatePhoneAndEmail(dealerAccount.Stakeholder_Hierarchy__c, userMap);
        }
        if (dealerAccountsToUpdate.size() > 0) {
            // test a bypass a
            TriggerHandler.bypass('AccountTriggerHandler');
            update dealerAccountsToUpdate;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }

    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: Method get the fields Stikng to Append on the Dealer Query From Case Assignment hierarchy
        Returns: String
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0          29/07/2020                Deepak                     Initial Version
    **/
    private static String getDealerConstructedFields() {
        String fields = '';
        Set<String> referenceFields = new Set<String>();
        List<String> referenceFieldsList = new List<String>();
        for (Case_Assignment_Hierarchy__mdt caseAssignmentHierarchy : [SELECT Reference_Field__c,Reference_Type__c,DeveloperName,LOB__c,Level__c,Object__c FROM Case_Assignment_Hierarchy__mdt WHERE Object__c = 'Account']) {
            if (caseAssignmentHierarchy.Reference_Field__c != null && caseAssignmentHierarchy.Reference_Field__c != '') {
                referenceFields.add(caseAssignmentHierarchy.Reference_Field__c);
            }
        }
        referenceFieldsList.addAll(referenceFields);
        return String.join(referenceFieldsList, ',');
    }
    private static Map<String, Complaint_Coordinator__c> getComplaintCoordinatorForDealer() {
        Map<String, Complaint_Coordinator__c> regionTypeVsComplaintCoordinatorMap = new Map<String, Complaint_Coordinator__c>();
        for (Complaint_Coordinator__c complaintCoordinator : [SELECT Channel__c, Contact__c, Id, Name, Region__c, Type__c, User__c,User__r.ManagerId, Zone__c FROM Complaint_Coordinator__c]) {
            regionTypeVsComplaintCoordinatorMap.put(complaintCoordinator.Channel__c + complaintCoordinator.Region__c + complaintCoordinator.Type__c, complaintCoordinator); // With Region
            regionTypeVsComplaintCoordinatorMap.put(complaintCoordinator.Channel__c + complaintCoordinator.Type__c, complaintCoordinator); // Without Region
        }
        return regionTypeVsComplaintCoordinatorMap;
    }
    private static Map<String, Case_Assignment_Hierarchy__mdt> getLobVsCaseAssignmentHierarchyMap() {
        Map<String, Case_Assignment_Hierarchy__mdt> lobVsCaseAssignmentHierarchyMap = new Map<String, Case_Assignment_Hierarchy__mdt>();
        for (Case_Assignment_Hierarchy__mdt hierarchy : [SELECT Reference_Field__c,Reference_Type__c,DeveloperName,LOB__c,Level__c,Object__c FROM Case_Assignment_Hierarchy__mdt]) {
            lobVsCaseAssignmentHierarchyMap.put(hierarchy.LOB__c + '_' + hierarchy.Reference_Type__c + '_' + hierarchy.Level__c, hierarchy);
        }
        return lobVsCaseAssignmentHierarchyMap;
    }
    private static StakeholderHierarchy addHierarchy(StakeholderHierarchy stakeholderHierarchy, StakeholderHierarchy.Sales hierarchyObject, String lob) {

        if (lob == ConstantsUtility.SALES_CASE_BUSINESS_AREA) {
            stakeholderHierarchy.sales.add(hierarchyObject);
        } else if (lob == ConstantsUtility.SERVICE_ARENA_HIERARCHY) {
            stakeholderHierarchy.serviceArena.add(hierarchyObject);
        } else if (lob == ConstantsUtility.SERVICE_NEXA_HIERARCHY) {
            stakeholderHierarchy.serviceNexa.add(hierarchyObject);
        } else if (lob == ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA) {
            stakeholderHierarchy.accessories.add(hierarchyObject);
        } else if (lob == ConstantsUtility.LOYALTY_PROGRAM_CASE_BUSINESS_AREA) {
            stakeholderHierarchy.loyaltyProgram.add(hierarchyObject);
        } else if (lob == ConstantsUtility.FINANCE_CASE_BUSINESS_AREA) {
            stakeholderHierarchy.finance.add(hierarchyObject);
        } else if (lob == ConstantsUtility.TRUEVALUE_CASE_CHANNEL) {
            stakeholderHierarchy.trueValue.add(hierarchyObject);
        } else if (lob == ConstantsUtility.MSDS_CASE_CHANNEL) {
            stakeholderHierarchy.msds.add(hierarchyObject);
        } else if (lob == ConstantsUtility.MSGP_CASE_CHANNEL) {
            stakeholderHierarchy.msgp.add(hierarchyObject);
        }
        return stakeholderHierarchy;

    }
    private static Map<Id, User> getUserMap(Set<String> userIds) {
        Map<Id, User> userMap = new Map<Id, User>(
        [SELECT Id,Phone,Email,Name,MobilePhone,UserRole.Name FROM User WHERE Id IN:userIds AND IsActive = true]
        );
        return userMap;
    }
    private static String UpdatePhoneAndEmail(String stakeholderHierarchyString, Map<Id, User> userMap) {
        StakeholderHierarchy stakeholderHierarchy = StakeholderUtility.parseStakeholderHierarchyJson(stakeholderHierarchyString);

        if (stakeholderHierarchy.sales != null && stakeholderHierarchy.sales.size() > 0) {
            stakeholderHierarchy.sales = getUpdateHierarchyList(stakeholderHierarchy.sales, userMap);
        }if (stakeholderHierarchy.serviceNexa != null && stakeholderHierarchy.serviceNexa.size() > 0) {
            stakeholderHierarchy.serviceNexa = getUpdateHierarchyList(stakeholderHierarchy.serviceNexa, userMap);
        }if (stakeholderHierarchy.serviceArena != null && stakeholderHierarchy.serviceArena.size() > 0) {
            stakeholderHierarchy.serviceArena = getUpdateHierarchyList(stakeholderHierarchy.serviceArena, userMap);
        }if (stakeholderHierarchy.accessories != null && stakeholderHierarchy.accessories.size() > 0) {
            stakeholderHierarchy.accessories = getUpdateHierarchyList(stakeholderHierarchy.accessories, userMap);
        }if (stakeholderHierarchy.trueValue != null && stakeholderHierarchy.trueValue.size() > 0) {
            stakeholderHierarchy.trueValue = getUpdateHierarchyList(stakeholderHierarchy.trueValue, userMap);
        }if (stakeholderHierarchy.msds != null && stakeholderHierarchy.msds.size() > 0) {
            stakeholderHierarchy.msds = getUpdateHierarchyList(stakeholderHierarchy.msds, userMap);
        }if (stakeholderHierarchy.msgp != null && stakeholderHierarchy.msgp.size() > 0) {
            stakeholderHierarchy.msgp = getUpdateHierarchyList(stakeholderHierarchy.msgp, userMap);
        }if (stakeholderHierarchy.loyaltyProgram != null && stakeholderHierarchy.loyaltyProgram.size() > 0) {
            stakeholderHierarchy.loyaltyProgram = getUpdateHierarchyList(stakeholderHierarchy.loyaltyProgram, userMap);
        }if (stakeholderHierarchy.finance != null && stakeholderHierarchy.finance.size() > 0) {
            stakeholderHierarchy.finance = getUpdateHierarchyList(stakeholderHierarchy.finance, userMap);
        }if (stakeholderHierarchy.msilQuery != null && stakeholderHierarchy.msilQuery.size() > 0) {
            stakeholderHierarchy.msilQuery = getUpdateHierarchyList(stakeholderHierarchy.msilQuery, userMap);
        }
        return JSON.serialize(stakeholderHierarchy);
    }
    private static List<StakeholderHierarchy.Sales> getUpdateHierarchyList(List<StakeholderHierarchy.Sales> stakeholderHierarchyList, Map<Id, User> userMap) {
        for (StakeholderHierarchy.Sales holder : stakeholderHierarchyList) {
            if (holder.recordId != '' && userMap.containsKey(holder.recordId)) {
                holder.email = userMap.get(holder.recordId).Email;
                holder.phone = userMap.get(holder.recordId).Phone != null ? userMap.get(holder.recordId).Phone : '';
                //  holder.phone = userMap.get(holder.recordId).Name;
                holder.refName = userMap.get(holder.recordId).UserRole != null ? userMap.get(holder.recordId).UserRole.Name : '';
            }
        }
        return stakeholderHierarchyList;
    }

    private static boolean checkJson(String jsonString) {
        try {
            List<DMSPrimaries> dmsPrimaries = new List<DMSPrimaries>();
            dmsPrimaries = (List<DMSPrimaries>) JSON.deserialize(jsonString, List<DMSPrimaries>.class);
            return true;
        } catch (Exception e) {
            return false;
        }

    }
    private static StakeholderHierarchy getUsersFromDMSPrimaries(Account dealerAccount) {
        StakeholderHierarchy hierarchy = new StakeholderHierarchy();
        hierarchy.sales = new List<StakeholderHierarchy.Sales>();
        hierarchy.serviceNexa = new List<StakeholderHierarchy.Sales>();
        hierarchy.serviceArena = new List<StakeholderHierarchy.Sales>();
        hierarchy.accessories = new List<StakeholderHierarchy.Sales>();
        hierarchy.trueValue = new List<StakeholderHierarchy.Sales>();
        hierarchy.msds = new List<StakeholderHierarchy.Sales>();
        hierarchy.msgp = new List<StakeholderHierarchy.Sales>();
        hierarchy.loyaltyProgram = new List<StakeholderHierarchy.Sales>();
        hierarchy.finance = new List<StakeholderHierarchy.Sales>();

        if (checkJson(dealerAccount.DMS_Primaries__c)) {

            List<DMSPrimaries> dmsPrimaries = new List<DMSPrimaries>();

            dmsPrimaries = (List<DMSPrimaries>) JSON.deserialize(dealerAccount.DMS_Primaries__c, List<DMSPrimaries>.class);

            if (dmsPrimaries != null && dmsPrimaries.size() > 0) {
                Map<String, String> levelVsUserIdMap = new Map<String, String>();
                for (DMSPrimaries dms : dmsPrimaries) {
                    if (dms.level != null && dms.SFID != null) {
                        levelVsUserIdMap.put(dms.level, dms.SFID);
                        usersIds.add(dms.SFID);
                    }
                }
                if (!levelVsUserIdMap.isEmpty()) {
                    // Scenario 1 for SALES DEALERS
                    StakeholderHierarchy.Sales stakeholder = new StakeholderHierarchy.Sales();
                    if (dealerAccount.Dealer_Type__c == ConstantsUtility.DEALER_TYPE_S || dealerAccount.Dealer_Type__c == ConstantsUtility.DEALER_TYPE_TV
                            || dealerAccount.Dealer_Type__c == ConstantsUtility.DEALER_TYPE_3S) {
                        // SALES  L2
                        stakeholder = getDmsPrimaries(levelVsUserIdMap, 'SalesL2A', ConstantsUtility.NOTIFIER_L2A);
                        if (stakeholder != null) {
                            hierarchy.sales.add(stakeholder);
                            // FOR ALL LOBs/Nodes we need Sales L2A
                            hierarchy.accessories.add(stakeholder);
                            hierarchy.trueValue.add(stakeholder);
                            hierarchy.msds.add(stakeholder);
                            hierarchy.msgp.add(stakeholder);
                            hierarchy.loyaltyProgram.add(stakeholder);
                            hierarchy.finance.add(stakeholder);
                        }
                        stakeholder = getDmsPrimaries(levelVsUserIdMap, 'SalesL2B', ConstantsUtility.NOTIFIER_L2B);
                        if (stakeholder != null) {
                            hierarchy.sales.add(stakeholder);
                            // FOR ALL LOBs/Nodes we need Sales L2B
                            hierarchy.accessories.add(stakeholder);
                            hierarchy.trueValue.add(stakeholder);
                            hierarchy.msds.add(stakeholder);
                            hierarchy.msgp.add(stakeholder);
                            hierarchy.loyaltyProgram.add(stakeholder);
                            hierarchy.finance.add(stakeholder);
                        }
                    }if (dealerAccount.Dealer_Type__c == ConstantsUtility.DEALER_TYPE_3S || dealerAccount.Dealer_Type__c == ConstantsUtility.DEALER_TYPE_2S) {
                        // Scenario 2 for SALES AND SERVICE BOTH DEALERS

                        stakeholder = getDmsPrimaries(levelVsUserIdMap, 'ServiceL1A', ConstantsUtility.NOTIFIER_L1A);
                        if (stakeholder != null) {
                            hierarchy.serviceNexa.add(stakeholder);
                            hierarchy.serviceArena.add(stakeholder);
                        }
                        stakeholder = getDmsPrimaries(levelVsUserIdMap, 'ServiceL1B', ConstantsUtility.NOTIFIER_L1B);
                        if (stakeholder != null) {
                            hierarchy.serviceNexa.add(stakeholder);
                            hierarchy.serviceArena.add(stakeholder);
                        }
                        stakeholder = getDmsPrimaries(levelVsUserIdMap, 'ServiceL2A', ConstantsUtility.NOTIFIER_L2A);
                        if (stakeholder != null) {
                            hierarchy.serviceNexa.add(stakeholder);
                            hierarchy.serviceArena.add(stakeholder);
                        }
                        stakeholder = getDmsPrimaries(levelVsUserIdMap, 'ServiceL2B', ConstantsUtility.NOTIFIER_L2B);
                        if (stakeholder != null) {
                            hierarchy.serviceNexa.add(stakeholder);
                            hierarchy.serviceArena.add(stakeholder);
                        }
                        if (dealerAccount.Dealer_Type__c == ConstantsUtility.DEALER_TYPE_2S) {
                            // FOR ALL LOBs/Nodes we need Sales L2A
                            stakeholder = getDmsPrimaries(levelVsUserIdMap, 'SalesL2A', ConstantsUtility.NOTIFIER_L2A);
                            if (stakeholder != null) {
                                hierarchy.accessories.add(stakeholder);
                                hierarchy.trueValue.add(stakeholder);
                                hierarchy.msds.add(stakeholder);
                                hierarchy.msgp.add(stakeholder);
                                hierarchy.loyaltyProgram.add(stakeholder);
                                hierarchy.finance.add(stakeholder);
                            }
                            // FOR ALL LOBs/Nodes we need Sales L2B
                            stakeholder = getDmsPrimaries(levelVsUserIdMap, 'SalesL2B', ConstantsUtility.NOTIFIER_L2A);
                            if (stakeholder != null) {
                                hierarchy.accessories.add(stakeholder);
                                hierarchy.trueValue.add(stakeholder);
                                hierarchy.msds.add(stakeholder);
                                hierarchy.msgp.add(stakeholder);
                                hierarchy.loyaltyProgram.add(stakeholder);
                                hierarchy.finance.add(stakeholder);
                            }
                        }
                    }
                }
            }
        }
        return hierarchy;
    }
    private static StakeholderHierarchy.Sales getDmsPrimaries(Map<String, String> levelVsUserIdMap, String key, String stakeHolder) {
        if (levelVsUserIdMap.containsKey(key)) {
            String recordId = levelVsUserIdMap.get(key) != null ? levelVsUserIdMap.get(key) : '';
            return getHierarchyObject('', recordId, '', '', stakeHolder);
        }
        return null;
    }
    private static StakeholderHierarchy.Sales getHierarchyObject(String refName, String recordId, String email, String phone, String stakeHolder) {
        StakeholderHierarchy.Sales hierarchyObject = new StakeholderHierarchy.Sales();
        hierarchyObject.refName = refName;
        hierarchyObject.recordId = recordId;
        hierarchyObject.email = email;
        hierarchyObject.phone = phone;
        hierarchyObject.stakeHolder = stakeHolder;
        return hierarchyObject;
    }
    public class DMSPrimaries {
        public String level;
        public String SFID;
        public String MSPIN;
    }
    private static StakeholderHierarchy getStakeholderHierarchyInstance() {
        StakeholderHierarchy stakeholderHierarchy = new StakeholderHierarchy();
        stakeholderHierarchy.sales = new List<StakeholderHierarchy.Sales>();
        //stakeholderHierarchy.service = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.serviceArena = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.serviceNexa = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.accessories = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.trueValue = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.msds = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.msgp = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.loyaltyProgram = new List<StakeholderHierarchy.Sales>();
        stakeholderHierarchy.finance = new List<StakeholderHierarchy.Sales>();

        return stakeholderHierarchy;
    }


    private static void ProcessMsilQuery(List<SObject> scope) {
        Set<Id> categoriesIds = new Set<Id>();
        List<Recipient_Master__c> recipientMastersToUpdateList = new List<Recipient_Master__c>();
        // Iteration of category
        List<Category__c> msilQueryCategories = (List<Category__c>) scope; // TypeCasting to sObject to Category
        for (Category__c category : msilQueryCategories) {
            categoriesIds.add(category.Id);
        }
        Map<Id, List<Recipient_List__c>> categoryIdVsRecipientListMap = CaseAssignmentServiceHelper.getRecipientListMap(categoriesIds);
        List<Id> recipientMasterIds = CaseAssignmentServiceHelper.getRecipientMasterIds(categoryIdVsRecipientListMap);
        if (recipientMasterIds.size() > 0) {
            Map<String, Complaint_Coordinator__c> externalIdVsComplaintCoordinatorMap = getComplaintCoordinatorsMap();
            // Iterating over  recipientMasters
            for (Recipient_Master__c recipientMaster : CaseAssignmentServiceHelper.getRecipientMasterMap(recipientMasterIds).values()) {
                String rMChannel = recipientMaster.External_ID__c.split(ConstantsUtility.UNDER_SCORE)[0]; // Channel on Recipient Masters
                if (rMChannel == ConstantsUtility.ARENA_CASE_CHANNEL) {
                    rMChannel = 'NRM';
                } else if (rMChannel == ConstantsUtility.NEXA_CASE_CHANNEL) {
                    rMChannel = 'EXC';
                } else if (rMChannel == ConstantsUtility.COMMERCIAL_CASE_CHANNEL) {
                    rMChannel = 'COM';
                }
                String lastValueOnExtId = recipientMaster.External_ID__c.split(ConstantsUtility.UNDER_SCORE)[recipientMaster.External_ID__c.split(ConstantsUtility.UNDER_SCORE).size() - 1]; // Last value on external Id Recipient Masters
                StakeholderHierarchy stakeholderHierarchy = new StakeholderHierarchy(); // Object for JSON

                // Hierarchy Lists
                List<StakeholderHierarchy.Sales> msilQueryHolderList = new List<StakeholderHierarchy.Sales>();
                List<StakeholderHierarchy.Sales> suzukiConnectHolderList = new List<StakeholderHierarchy.Sales>();
                Set<String> stakeholders = getMsilUsers(recipientMaster); // All Stakeholders in a set
                Set<String> uniqueKeys = new Set<String>();
                if (stakeholders != null && stakeholders.size() > 0) {
                    for (String st : stakeholders) {
                        uniqueKeys.add(rMChannel + ConstantsUtility.UNDER_SCORE + st);
                        if (recipientMaster.Region__c != null) {
                            uniqueKeys.add(rMChannel + ConstantsUtility.UNDER_SCORE + st + ConstantsUtility.UNDER_SCORE + recipientMaster.Region__c);
                        }
                        uniqueKeys.add(rMChannel + ConstantsUtility.UNDER_SCORE + st + ConstantsUtility.UNDER_SCORE + lastValueOnExtId);
                    }
                }
                if (uniqueKeys.size() > 0) {
                    for (String uniqueKey : uniqueKeys) {
                        uniqueKey = uniqueKey.trim();
                        uniqueKey = uniqueKey.toLowerCase();
                        Complaint_Coordinator__c coordinator = externalIdVsComplaintCoordinatorMap.containsKey(uniqueKey) ? externalIdVsComplaintCoordinatorMap.get(uniqueKey) : null;
                        if (coordinator != null) {
                            if ((recipientMaster.Hierarchy_Type__c).containsIgnoreCase(ConstantsUtility.SUZUKI_CONNECT_HIERARCHY)) {
                                // SUZUKI CONNECT RM
                                StakeholderHierarchy.Sales holder = getStakeHolderObject(coordinator);
                                suzukiConnectHolderList.add(holder);
                            } else {
                                // MSIL QUERY RM
                                StakeholderHierarchy.Sales holder = getStakeHolderObject(coordinator);
                                msilQueryHolderList.add(holder);
                            }
                        }
                    }
                }
                stakeholderHierarchy.suzukiConnect = suzukiConnectHolderList.size() > 0 ? suzukiConnectHolderList : null;
                stakeholderHierarchy.msilQuery = msilQueryHolderList.size() > 0 ? msilQueryHolderList : null;
                Recipient_Master__c recipientMasterToUpdate = new Recipient_Master__c();
                recipientMasterToUpdate.Id = recipientMaster.Id;
                recipientMasterToUpdate.MSIL_Stakeholder_JSON__c = JSON.serialize(stakeholderHierarchy);
                recipientMastersToUpdateList.add(recipientMasterToUpdate);
            }
            if (recipientMastersToUpdateList.size() > 0) {
                System.debug('recipientMastersToUpdate size ' + recipientMastersToUpdateList.size());
                update recipientMastersToUpdateList;
            }
        }
    }
    private static Map<String, Complaint_Coordinator__c> getComplaintCoordinatorsMap() {
        Map<String, Complaint_Coordinator__c> externalIdVsComplaintCoordinatorMap = new Map<String, Complaint_Coordinator__c>();
        for (Complaint_Coordinator__c coordinator : [SELECT Channel__c, Contact__c, Id, Name, Region__c, Type__c, User__c,User__r.Phone,User__r.Email,User__r.Name, Zone__c,External_Id__c,Contact__r.Email,Contact__r.Phone,Contact__r.Name,Contact__r.RecordTypeId,User__r.IsActive FROM Complaint_Coordinator__c]) {
            if (coordinator.User__c != null && !coordinator.User__r.IsActive) {
                continue;
            }
            externalIdVsComplaintCoordinatorMap.put(String.valueOf(coordinator.External_Id__c).toLowerCase(), coordinator);
        }
        return externalIdVsComplaintCoordinatorMap;
    }
    private static Set<String> getMsilUsers(Recipient_Master__c recipientMaster) {
        Set<String> msilUsers = new Set<String>();

        List<String> tempList = new List<String>();
        tempList = recipientMaster.Level_0_To__c != null ? recipientMaster.Level_0_To__c.split(';') : tempList;
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_0_Cc__c != null ? recipientMaster.Level_0_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_1_To__c != null ? recipientMaster.Level_1_To__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_1_Cc__c != null ? recipientMaster.Level_1_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_2_To__c != null ? recipientMaster.Level_2_To__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_2_Cc__c != null ? recipientMaster.Level_2_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_3_To__c != null ? recipientMaster.Level_3_To__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_3_Cc__c != null ? recipientMaster.Level_3_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_4_To__c != null ? recipientMaster.Level_4_To__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_4_Cc__c != null ? recipientMaster.Level_4_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_5_To__c != null ? recipientMaster.Level_5_To__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_5_Cc__c != null ? recipientMaster.Level_5_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_6_To__c != null ? recipientMaster.Level_6_To__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        tempList = recipientMaster.Level_6_Cc__c != null ? recipientMaster.Level_6_Cc__c.split(';') : new List<String>();
        msilUsers.addAll(tempList);
        return msilUsers;
    }
    private static StakeholderHierarchy.Sales getStakeHolderObject(Complaint_Coordinator__c complaintCoordinator) {
        StakeholderHierarchy.Sales holder = new StakeholderHierarchy.Sales();
        holder.refName = complaintCoordinator.Type__c;
        holder.stakeHolder = complaintCoordinator.Type__c ;
        holder.email = '' ;
        holder.phone = '' ;
        holder.recordId = '' ;
        if (complaintCoordinator.User__c != null) {
            // holder.refName = complaintCoordinator.User__r.Name ;
            holder.email = complaintCoordinator.User__r.Email;
            holder.phone = complaintCoordinator.User__r.Phone != null ? complaintCoordinator.User__r.Phone : '';
            holder.recordId = complaintCoordinator.User__c ;
        } else if (complaintCoordinator.Contact__c != null && complaintCoordinator.Contact__r.RecordTypeId == ConstantsUtility.MSIL_STAKEHOLDER_CONTACT_RECORDTYPE_ID) {
            // holder.refName = complaintCoordinator.Contact__r.Name;
            holder.email = complaintCoordinator.Contact__r.Email != null ? complaintCoordinator.Contact__r.Email : '';
            holder.phone = complaintCoordinator.Contact__r.Phone != null ? complaintCoordinator.Contact__r.Phone : '';
            holder.recordId = complaintCoordinator.Contact__c != null ? complaintCoordinator.Contact__c : '' ;
        }
        return holder;
    }

}