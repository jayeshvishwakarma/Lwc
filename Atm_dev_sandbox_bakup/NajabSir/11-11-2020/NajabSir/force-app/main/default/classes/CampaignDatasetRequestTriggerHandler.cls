/**
* @Autho:- Najab Maghribi
* @Company-: Techmatrix Consulting
* @Description-: Handler class for CampaignDatasetRequestTrigger.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       27 Oct 2020    Najab     Intial Version
**/

public without sharing class CampaignDatasetRequestTriggerHandler extends TriggerHandler{
    private list<Adhoc_Campaign_Request__c> campaignDatasetReqList; // Used to store the list of new User
    private Map<Id, Adhoc_Campaign_Request__c> campaignDatasetReqOldMap; // Used to store Map of old User
    public static Schema.DescribeSObjectResult adhocCampaignDescribe = Schema.SObjectType.Adhoc_Campaign_Request__c; 
    
    private List<Adhoc_Campaign_Request__Share> SMCAAndSeniorAdvisiorShareRecords {get;set;}
    public CampaignDatasetRequestTriggerHandler() {
        this.campaignDatasetReqList = (list<Adhoc_Campaign_Request__c>) Trigger.new;
        this.campaignDatasetReqOldMap = (Map<Id, Adhoc_Campaign_Request__c>) Trigger.oldMap;
        //adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share>();
    }
    public override void beforeInsert() {
        updateCRMDeptField();
        //Added by Shaikh Mufiz on 10.11.2020
        updateBusinessHoursField();
    }
    public override void afterInsert() {
        createApexSharingRecord();
        createSMCAAndSeniorAdvisiorSharingRec();
        updateAdditionalFileSharingRec();
        notifyUsers();
        notificationSendToApprover();
    }
    
    public override void beforeUpdate() {
        updateCRMDeptField();
        updateDataSetReqStatus();
        updateApexSharingRecord();
        //Added by Shaikh Mufiz on 06.11.2020
        makeStatusExecuted();
        //Added by Shaikh Mufiz on 17.11.2020
        validationForDataSubmittedToDPS();
    }
    
    public override void afterUpdate() {
        System.debug('After update call');
        updateAdditionalFileSharingRec();        
        notifyUsers();
        notificationSendToApprover();
        //Added by Shaikh Mufiz on 04.11.2020
        createDatasetRequestRecords();
    }
    
    //Added by Shaikh Mufiz on 13.11.2020
    public override void beforeDelete(){
        String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        for(Adhoc_Campaign_Request__c adhocObj : (List<Adhoc_Campaign_Request__c >) Trigger.old){
            String recordTypeName = adhocCampaignDescribe.getRecordTypeInfosById().get(adhocObj.RecordTypeId).getDeveloperName();
            if(recordTypeName == 'aCRM_Dataset' && profileName != 'System Administrator'){
                adhocObj.addError('Record can only be deleted by a System Administrator.');
            }
        }
    }
    
    public void updateDataSetReqStatus(){
        if(campaignDatasetReqList.size()>0){
            Set<Id> parentIds = new Set<Id>();
            for(Adhoc_Campaign_Request__c datasetReqObj : campaignDatasetReqList){
                String recordTypeName = adhocCampaignDescribe.getRecordTypeInfosById().get(datasetReqObj.RecordTypeId).getDeveloperName();
                //Access the "old" record by its ID in Trigger.oldMap
                Adhoc_Campaign_Request__c oldDatasetReq = campaignDatasetReqOldMap.get(datasetReqObj.Id);
                if(recordTypeName == 'aCRM_Dataset' && oldDatasetReq.Data_Submitted_to_DPS__c != datasetReqObj.Data_Submitted_to_DPS__c && datasetReqObj.Data_Submitted_to_DPS__c == true){
                    if(datasetReqObj.Status__c == 'Pending Data Submission to DPS'){
                        datasetReqObj.Status__c = 'Data Submitted to DPS';
                        // Add Parent ids for update child records as well
                        parentIds.add(datasetReqObj.Id);
                    } else{
                        datasetReqObj.addError('Status must be "Pending Data Submission to DPS"');
                    }
                }
            }
            // Update child records status
            if(parentIds.size() > 0)
                updateChildRecordsStatus(parentIds);
        }
    }
    
    public void createApexSharingRecord(){
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        String creativeApprovalRecTypeId = Schema.SObjectType.Adhoc_Campaign_Request__c.getRecordTypeInfosByDeveloperName().get('Creative_Approval').getRecordTypeId();
        String offLineRecId = Schema.SObjectType.Adhoc_Campaign_Request__c.getRecordTypeInfosByDeveloperName().get('Offline_Campaigns').getRecordTypeId();
        String onlineRecId = Schema.SObjectType.Adhoc_Campaign_Request__c.getRecordTypeInfosByDeveloperName().get('Online_Campaigns').getRecordTypeId();
        if(campaignDatasetReqList.size() > 0){
            List<Adhoc_Campaign_Request__Share> adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share >(); 
            Set<String> ownerIdSet = new Set<String>();
            for(Adhoc_Campaign_Request__c datasetReqObj : campaignDatasetReqList){
                ownerIdSet.add(datasetReqObj.OwnerId);
            }
            
            Map<Id, User> userIdMap = new Map<Id, User>([Select id, Name from User where ID In: ownerIdSet]);
            for(Adhoc_Campaign_Request__c datasetReqObj : campaignDatasetReqList){
                Set<String> userIdSet = new Set<String>();
                if((creativeApprovalRecTypeId == datasetReqObj.recordTypeId
                    || offLineRecId == datasetReqObj.recordTypeId
                    || onlineRecId == datasetReqObj.recordTypeId) 
                    && (datasetReqObj.CRM_2_Spoc_L1__c != null
                    || datasetReqObj.CRM_1_Spoc_L1__c != null
                    || datasetReqObj.Research_SPOC__c != null)){
                
                
                    if(datasetReqObj.CRM_2_Spoc_L1__c != null){
                        userIdSet.add(datasetReqObj.CRM_2_Spoc_L1__c);
                        adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.CRM_2_Spoc_L1__c));
                    }
                    if(datasetReqObj.CRM_1_Spoc_L1__c != null){
                        userIdSet.add(datasetReqObj.CRM_1_Spoc_L1__c);
                        adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.CRM_1_Spoc_L1__c));
                    }
                    if(datasetReqObj.Research_SPOC__c != null){
                        userIdSet.add(datasetReqObj.Research_SPOC__c);
                        adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.Research_SPOC__c));
                    }
                    escalationUsers.put(datasetReqObj.id, userIdSet);
                    string emailTemplateMessage = 'Please enter Budget requested for ';
                    emailTemplateMessage += datasetReqObj.Name + ' by ';
                    emailTemplateMessage += userIdMap.containsKey(datasetReqObj.ownerId) ? userIdMap.get(datasetReqObj.ownerId).Name : '';
                    recordIdVsMessageMap.put(datasetReqObj.id, emailTemplateMessage);
                }
                if(datasetReqObj.SMCA__c != null){
                    adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.SMCA__c));
                }
                if(datasetReqObj.Senior_Advisor__c != null){
                    adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.Senior_Advisor__c));
                }
            }
            
            if(adhocCampaignReqShareRecords.size() > 0){
                insert adhocCampaignReqShareRecords;
            }
            if(escalationUsers.size() > 0 && recordIdVsMessageMap != null){
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
            }
        }
    }
    public void createSMCAAndSeniorAdvisiorSharingRec(){
        String creativeApprovalRecTypeId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Creative_Approval').getRecordTypeId();
        SMCAAndSeniorAdvisiorShareRecords = new List<Adhoc_Campaign_Request__Share >();
        List<Adhoc_Campaign_Request__Share> adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share >();
        for(Adhoc_Campaign_Request__c datasetReqObj : campaignDatasetReqList){
            if(datasetReqObj.recordTypeId == creativeApprovalRecTypeId && datasetReqObj.SMCA__c != null){
                adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.SMCA__c));
            }
            if(datasetReqObj.recordTypeId == creativeApprovalRecTypeId && datasetReqObj.Senior_Advisor__c != null){
                adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.Senior_Advisor__c));
            }
        }
        if(SMCAAndSeniorAdvisiorShareRecords.size() > 0){
            INSERT SMCAAndSeniorAdvisiorShareRecords;
        }
    }
    public List<Adhoc_Campaign_Request__Share> createSharingRecord(Adhoc_Campaign_Request__c datasetReqObj, String groupOrUserId){
        List<Adhoc_Campaign_Request__Share> adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share>();
        Adhoc_Campaign_Request__Share adhocCampaignReqShareRecord = new Adhoc_Campaign_Request__Share();
        adhocCampaignReqShareRecord.ParentId = datasetReqObj.Id;
        adhocCampaignReqShareRecord.UserOrGroupId = groupOrUserId;
        adhocCampaignReqShareRecord.RowCause = Schema.Adhoc_Campaign_Request__Share.RowCause.Dept_Head__c;
        adhocCampaignReqShareRecord.AccessLevel = 'edit';
        adhocCampaignReqShareRecords.add(adhocCampaignReqShareRecord);
        return adhocCampaignReqShareRecords;
    }
    
    public void updateApexSharingRecord(){
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        if(campaignDatasetReqList.size()>0){
            List<Adhoc_Campaign_Request__Share> adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share >();
            Set<Id> adhocCampaignRequestUserIds = new Set<Id>(); 
            
            Set<String> ownerIdSet = new Set<String>();
            for(Adhoc_Campaign_Request__c datasetReqObj : campaignDatasetReqList){
                ownerIdSet.add(datasetReqObj.OwnerId);
            }
            
            Map<Id, User> userIdMap = new Map<Id, User>([Select id, Name from User where ID In: ownerIdSet]);
            
            for(Adhoc_Campaign_Request__c datasetReqObj : campaignDatasetReqList){
                Set<String> userIdSet = new Set<String>();
                //Access the "old" record by its ID in Trigger.oldMap
                Adhoc_Campaign_Request__c oldDatasetReq = campaignDatasetReqOldMap.get(datasetReqObj.Id);
                if(String.isBlank(datasetReqObj.CRM_2_Spoc_L1__c)){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.CRM_2_Spoc_L1__c);
                }
                if(String.isBlank(datasetReqObj.CRM_1_Spoc_L1__c)){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.CRM_1_Spoc_L1__c );
                }
                if(String.isBlank(datasetReqObj.Research_SPOC__c)){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.Research_SPOC__c );
                }
                if(datasetReqObj.CRM_2_Spoc_L1__c != null && datasetReqObj.CRM_2_Spoc_L1__c != oldDatasetReq.CRM_2_Spoc_L1__c){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.CRM_2_Spoc_L1__c);
                    userIdSet.add(datasetReqObj.CRM_2_Spoc_L1__c);
                    adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.CRM_2_Spoc_L1__c));
                }
                if(datasetReqObj.CRM_1_Spoc_L1__c != null && datasetReqObj.CRM_1_Spoc_L1__c != oldDatasetReq.CRM_1_Spoc_L1__c) {
                    adhocCampaignRequestUserIds.add(oldDatasetReq.CRM_1_Spoc_L1__c );
                    userIdSet.add(datasetReqObj.CRM_1_Spoc_L1__c);
                    adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.CRM_1_Spoc_L1__c));
                }
                if(datasetReqObj.Research_SPOC__c != null && datasetReqObj.Research_SPOC__c != oldDatasetReq.Research_SPOC__c ){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.Research_SPOC__c);
                    userIdSet.add(datasetReqObj.Research_SPOC__c );
                    adhocCampaignReqShareRecords.addAll(createSharingRecord(datasetReqObj, datasetReqObj.Research_SPOC__c));
                }
                if(datasetReqObj.SMCA__c == null && datasetReqObj.SMCA__c != oldDatasetReq.SMCA__c){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.SMCA__c); 
                }
                if(datasetReqObj.Senior_Advisor__c == null && datasetReqObj.SMCA__c != oldDatasetReq.SMCA__c){
                    adhocCampaignRequestUserIds.add(oldDatasetReq.Senior_Advisor__c); 
                }
                escalationUsers.put(datasetReqObj.id, userIdSet);
                string emailTemplateMessage = 'Please enter Budget requested for ';
                emailTemplateMessage += datasetReqObj.Name + ' by ';
                emailTemplateMessage += userIdMap.containsKey(datasetReqObj.ownerId) ? userIdMap.get(datasetReqObj.ownerId).Name : '';
                recordIdVsMessageMap.put(datasetReqObj.id, emailTemplateMessage);
            }
            if(adhocCampaignRequestUserIds.size() > 0){
                List<Adhoc_Campaign_Request__Share> campaignDatasetSharingRecords = [SELECT id 
                                                                                     FROM Adhoc_Campaign_Request__Share
                                                                                     Where  UserOrGroupId IN : adhocCampaignRequestUserIds
                                                                                    ];
                if(campaignDatasetSharingRecords.size() > 0){
                    //Delete campaignDatasetSharingRecords;
                }                            
            }
            if(adhocCampaignReqShareRecords.size() > 0){
                insert adhocCampaignReqShareRecords;
                system.debug('== Update escalationUsers '+escalationUsers);
                system.debug('== Update recordIdVsMessageMap '+recordIdVsMessageMap);
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
            }
        }  
    }
    
    public void updateCRMDeptField(){
        
        String offLineRecId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Offline_Campaigns').getRecordTypeId();
        String onlineRecId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Online_Campaigns').getRecordTypeId();
        String aCrmRecId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('aCRM_Dataset').getRecordTypeId();
        String creativeApprovalRecTypeId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Creative_Approval').getRecordTypeId();
        List<String> roleNameList = new List<String>();
        Map<String, String> roleNameWithUsrIdMap = new Map<String, String>();
        List<Adhoc_Campaign_Request__Share> adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share>();
        for(Adhoc_Campaign_Request__c rec : campaignDatasetReqList){
            Set<String> recordOwnerSet = new Set<String>();
            
            if(String.isNotBlank(rec.recordTypeId) && rec.recordTypeId == creativeApprovalRecTypeId){
                recordOwnerSet.add(rec.ownerId);
                Map<String, User> managerIdMap = new Map<String, User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId  FROM User WHERE Id IN : recordOwnerSet]);
                if(managerIdMap.containsKey(rec.OwnerId)){
                    if(String.isNotBlank(managerIdMap.get(rec.OwnerId).Manager.ManagerId)){
                        //rec.Divisional_Manager__c = managerIdMap.get(rec.OwnerId).managerId;
                        rec.Divisional_Manager__c = managerIdMap.get(rec.OwnerId).Manager.ManagerId;
                        if(String.isNotBlank(managerIdMap.get(rec.OwnerId).Manager.Manager.ManagerId)){
                            rec.EO__c = managerIdMap.get(rec.OwnerId).Manager.Manager.ManagerId;
                        }
                    }
                }   
            }
            if(String.isNotBlank(rec.recordTypeId)){
                if(rec.recordTypeId == onlineRecId && (String.isNotBlank(rec.Must_Have_Medium__c) && rec.Must_Have_Medium__c.contains('Call'))){
                    rec.CRM1_Team__c = true;
                }if(rec.recordTypeId == onlineRecId && (String.isNotBlank(rec.Must_Have_Medium__c) && (rec.Must_Have_Medium__c.contains('SMS') || rec.Must_Have_Medium__c.contains('Email') || rec.Must_Have_Medium__c.contains('Push')) )){
                    rec.CRM2_Team__c = true;
                }if(rec.recordTypeId == offLineRecId && (String.isNotBlank(rec.Must_Have_Medium__c) && rec.Must_Have_Medium__c.contains('Mass Media'))){
                    rec.Media__c = true;
                }if(rec.recordTypeId == offLineRecId && (String.isNotBlank(rec.Must_Have_Medium__c) && rec.Must_Have_Medium__c.contains('Digital'))){
                    rec.Digital__c = true;
                }if(rec.recordTypeId == offLineRecId && (String.isNotBlank(rec.Must_Have_Medium__c) && rec.Must_Have_Medium__c.contains('Research'))){
                    rec.Research__c = true;
                }
                if(rec.recordTypeId == offLineRecId){
                    roleNameList.add('Media_DPM');
                    roleNameList.add('Digital_DPM');
                    roleNameList.add('Research_DPM');
                    
                }else if(rec.recordTypeId == onlineRecId || rec.recordTypeId == aCrmRecId){
                    roleNameList.add('CRM1_DPM');
                    roleNameList.add('CRM2_DPM');
                    roleNameList.add('MKT_3_DVM');
                }else if(rec.recordTypeId == creativeApprovalRecTypeId){
                    roleNameList.add('SMCA');
                    roleNameList.add('Senior_Advisor');
                    
                }
            }

            if(UserTriggerHandler.brandRoleMap.containsKey(UserInfo.getUserRoleId())){
                if(rec.Department__c != UserTriggerHandler.brandRoleMap.get(UserInfo.getUserRoleId()).Department__c){
                    rec.Department__c.addError('You can only create a record with the department as' + UserTriggerHandler.brandRoleMap.get(UserInfo.getUserRoleId()).Department__c);
                }
            }
            
        }
        
        if(!roleNameList.isEmpty()){
            
            for(User usr : [SELECT id, name, UserRole.DeveloperName, IsActive from user where UserRole.DeveloperName IN: roleNameList AND IsActive = true]){
                roleNameWithUsrIdMap.put(usr.UserRole.DeveloperName, usr.Id);
            }
        }
        
        system.debug('== roleNameWithUsrIdMap '+roleNameWithUsrIdMap);
        
        if(!roleNameWithUsrIdMap.isEmpty()){
            
            for(Adhoc_Campaign_Request__c rec : campaignDatasetReqList){
                if(String.isNotBlank(rec.recordTypeId)){
                    
                    if(rec.recordTypeId == offLineRecId){
                        rec.CRM1_DPM__c = roleNameWithUsrIdMap.containsKey('Media_DPM') ? roleNameWithUsrIdMap.get('Media_DPM') : null;
                        rec.CRM2_DPM__c = roleNameWithUsrIdMap.containsKey('Digital_DPM') ? roleNameWithUsrIdMap.get('Digital_DPM') : null;
                        rec.Research_Dept_Head__c = roleNameWithUsrIdMap.containsKey('Research_DPM') ? roleNameWithUsrIdMap.get('Research_DPM') : null;
                        
                    }else if(rec.recordTypeId == onlineRecId || rec.recordTypeId == aCrmRecId){
                        rec.CRM1_DPM__c = roleNameWithUsrIdMap.containsKey('CRM1_DPM') ? roleNameWithUsrIdMap.get('CRM1_DPM') : null;
                        rec.CRM2_DPM__c = roleNameWithUsrIdMap.containsKey('CRM2_DPM') ? roleNameWithUsrIdMap.get('CRM2_DPM') : null;
                        rec.Research_Dept_Head__c = roleNameWithUsrIdMap.containsKey('MKT_3_DVM') ? roleNameWithUsrIdMap.get('MKT_3_DVM') : null;
                    }else if(rec.recordTypeId == creativeApprovalRecTypeId){
                        rec.SMCA__c = roleNameWithUsrIdMap.containsKey('SMCA') ? roleNameWithUsrIdMap.get('SMCA') : null;
                        rec.Senior_Advisor__c = roleNameWithUsrIdMap.containsKey('Senior_Advisor') ? roleNameWithUsrIdMap.get('Senior_Advisor') : null;
                        if(Trigger.isUpdate){
                            adhocCampaignReqShareRecords.addAll(createSharingRecord(rec, rec.SMCA__c));
                            adhocCampaignReqShareRecords.addAll(createSharingRecord(rec, rec.Senior_Advisor__c));
                        }
                    }    
                }
            }
            if(adhocCampaignReqShareRecords.size() > 0){
                insert adhocCampaignReqShareRecords;
            }
        }
        
    }
    
    
    public void updateAdditionalFileSharingRec(){
        
        String offLineRecId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Offline_Campaigns').getRecordTypeId();
    
        List<Additional_File_Sharing__c> additionalFileRecList = new List<Additional_File_Sharing__c>();
        
        Map<String, Additional_File_Sharing__c> recIdWithAdditionalRecMap = new Map<String, Additional_File_Sharing__c>();
        
        for(Adhoc_Campaign_Request__c rec : campaignDatasetReqList){
            if(String.isNotBlank(rec.recordTypeId) && rec.recordTypeId == offLineRecId 
               && rec.Must_Have_Medium__c != null && rec.Campaign_Stage__c != null && rec.Research_SPOC__c != null && 
               rec.Campaign_Stage__c == 'Initiated' && rec.Additional_File_Sharing__c == null && 
               (rec.Must_Have_Medium__c.contains('Research') &&
                (rec.Must_Have_Medium__c.contains('Digital') || rec.Must_Have_Medium__c.contains('Mass Media')))){
                    
                    recIdWithAdditionalRecMap.put(rec.id, new Additional_File_Sharing__c(ownerId = rec.Research_SPOC__c, Request_Status__c = 'Pending'));
                    
                }
            if(trigger.isUpdate && rec.Research_SPOC__c != null && campaignDatasetReqOldMap.get(rec.Id).Research_SPOC__c != rec.Research_SPOC__c && 
               rec.Additional_File_Sharing__c != null){
                   recIdWithAdditionalRecMap.put(rec.id, new Additional_File_Sharing__c(Id = rec.Additional_File_Sharing__c, ownerId = rec.Research_SPOC__c));
               }
        }
        
        if(!recIdWithAdditionalRecMap.isEmpty()){
            
            upsert recIdWithAdditionalRecMap.values();
            
            List<Adhoc_Campaign_Request__c> adhocCamList = new List<Adhoc_Campaign_Request__c>();
            
            for(String adhocRecId : recIdWithAdditionalRecMap.keySet()){
                adhocCamList.add(new Adhoc_Campaign_Request__c(Id = adhocRecId, Additional_File_Sharing__c = recIdWithAdditionalRecMap.get(adhocRecId).Id));
            }
            
            if(!adhocCamList.isEmpty()){
                TriggerHandler.bypass('CampaignDatasetRequestTriggerHandler');
                update adhocCamList;
                TriggerHandler.clearBypass('CampaignDatasetRequestTriggerHandler');
            }
            
        }    
    }
    
    public void notifyUsers(){
        List<Adhoc_Campaign_Request__Share> adhocCampaignReqShareRecords = new List<Adhoc_Campaign_Request__Share>();
        String creativeApprovalRecTypeId = Schema.SObjectType.Adhoc_Campaign_Request__c.getRecordTypeInfosByDeveloperName().get('Creative_Approval').getRecordTypeId();
        String offLineRecId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Offline_Campaigns').getRecordTypeId();
        String onlineRecId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('Online_Campaigns').getRecordTypeId();
        System.debug('notifyUsers call');
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        
        Map<Id, Set<String>> usersOfCRMExecution = new Map<Id, Set<String>>();
        Map<Id, String> recordIdAndMessageCRMExecutionMap = new Map<Id, String>();
        
        //Added by Najab on 25/11/2020
        Map<Id, String> recordIdVsActionMessage = new Map<Id, String>();
        Map<Id, Set<String>> recipientUserIdMap = new Map<Id, Set<String>>();
        //=======================End Here=========================//
        
        Set<String> ownerIdSet = new Set<String>();
        Set<String> recordIds = new Set<String>();
        String recId = '';
        for(Adhoc_Campaign_Request__c rec : campaignDatasetReqList){
            ownerIdSet.add(rec.OwnerId);
        }
        
        Map<Id, User> mapOfUserManager = new Map<Id, User>([SELECT id, Name, ManagerId FROM user WHERE Id IN : ownerIdSet]);
        
        Map<Id, Set<String>> usersOfCRMExecution1 = new Map<Id, Set<String>>();
        Map<Id, String> recordIdAndMessageCRMExecutionMap1 = new Map<Id, String>();
        Map<Id, String> recordIdAndMessageCRMExecutionMap2 = new Map<Id, String>();
        Set<String> userIdSet1 = new Set<String>();
        
        for(Adhoc_Campaign_Request__c rec : campaignDatasetReqList){
            String emailTemplateMessage = '';
            Set<String> userIdSet = new Set<String>();
            
            if(rec.recordTypeId == onlineRecId && rec.Campaign_Stage__c == 'Pending Campaign Execution' && (trigger.isInsert ||
                                                                                                            (trigger.isUpdate && campaignDatasetReqOldMap.get(rec.Id).Campaign_Stage__c != rec.Campaign_Stage__c))){
                                                                                                                if(rec.CRM_1_Spoc_L1__c != null)
                                                                                                                    userIdSet.add(rec.CRM_1_Spoc_L1__c);
                                                                                                                if(rec.CRM_2_Spoc_L1__c != null)
                                                                                                                    userIdSet.add(rec.CRM_2_Spoc_L1__c);
                                                                                                                escalationUsers.put(rec.Id, userIdSet);
                                                                                                                
                                                                                                                recordIdVsMessageMap.put(rec.Id, 'Campaign Name : '+ rec.Name +' has been approved. Please assign Execution SPOC and change CRM Stage to "Execution SPOC Assigned"');
                                                                                                            }
            // Added by Najab Maghribi on 18 Nov 2020
            Set<String> crmExecutionUserIds = new Set<String>();
            if((rec.recordTypeId == onlineRecId && rec.Campaign_Stage__c == 'Pending Campaign Execution' && rec.CRM1_Status__c == 'Execution SPOC assigned' 
                && (trigger.isInsert ||
                (trigger.isUpdate && campaignDatasetReqOldMap.get(rec.Id).CRM1_Status__c != rec.CRM1_Status__c))) 
               || (rec.CRM2_Status__c == 'Execution SPOC assigned' && (trigger.isInsert ||
               (trigger.isUpdate && campaignDatasetReqOldMap.get(rec.Id).CRM2_Status__c != rec.CRM2_Status__c)))){
                   if(rec.CRM1_Execution_SPOC__c != null){
                       crmExecutionUserIds.add(rec.CRM1_Execution_SPOC__c);
                       adhocCampaignReqShareRecords.addAll(createSharingRecord(rec, rec.CRM1_Execution_SPOC__c));
                   }
                   if(rec.CRM2_Execution_SPOC__c != null){
                       crmExecutionUserIds.add(rec.CRM2_Execution_SPOC__c);
                       adhocCampaignReqShareRecords.addAll(createSharingRecord(rec, rec.CRM2_Execution_SPOC__c));
                   }
                   usersOfCRMExecution.put(rec.id, crmExecutionUserIds);
                   String brand = String.isNotBlank(rec.Brand__c)? rec.Brand__c : '';
                   recordIdAndMessageCRMExecutionMap.put(rec.id, 'Campaign Name '+ rec.Name + ' for ' + brand + ' is assigned to you for Execution. Please review the same.');
            }
        
            // Added by Najab Maghribi on 12 Nov 2020
            if(rec.recordTypeId == onlineRecId &&  (trigger.isInsert || trigger.isUpdate)){
                
                userIdSet1.add(rec.OwnerId);
                userIdSet1.add(mapOfUserManager.get(rec.OwnerId).ManagerId);
                
                if(rec.CRM1_Status__c == 'Pending Campaign Acknowledgement' && campaignDatasetReqOldMap.get(rec.Id).CRM1_Status__c != rec.CRM1_Status__c){
                    userIdSet1.add(rec.CRM_1_Spoc_L1__c);
                    recordIdAndMessageCRMExecutionMap1.put(rec.id, 'The campaign execution for the Campaign request '+ rec.Name + ' has been completed by CRM1. Please review the same.');
                    
                }
                if(rec.CRM2_Status__c == 'Pending Campaign Acknowledgement' && campaignDatasetReqOldMap.get(rec.Id).CRM2_Status__c != rec.CRM2_Status__c){
                    userIdSet1.add(rec.CRM_2_Spoc_L1__c);
                    recordIdAndMessageCRMExecutionMap2.put(rec.id, 'The campaign execution for the Campaign request '+ rec.Name + ' has been completed by CRM2. Please review the same.');
                }
                usersOfCRMExecution1.put(rec.id, userIdSet1);
            }
            //Added by Najab Maghribi on 25 Nov 2020
            system.debug('trigger is updated for approval status' + rec.Approval_Status__c + '== > ' + rec.recordTypeId + '==> ' + trigger.isUpdate);
            if((trigger.isInsert || trigger.isUpdate) &&  (rec.recordTypeId == onlineRecId || rec.recordTypeId == offLineRecId || rec.recordTypeId == creativeApprovalRecTypeId) && (rec.Approval_Status__c == 'Approved' || rec.Approval_Status__c == 'Rejected')){
                
                Set<String> recipientUserIdSet = new Set<String>();
                recipientUserIdSet.add(mapOfUserManager.get(rec.OwnerId).Id);
                recipientUserIdSet.add(mapOfUserManager.get(rec.OwnerId).ManagerId);
                if(rec.CRM_1_Spoc_L1__c != null){
                    recipientUserIdSet.add(rec.CRM_1_Spoc_L1__c);
                }
                if(rec.CRM_2_Spoc_L1__c != null){
                    recipientUserIdSet.add(rec.CRM_2_Spoc_L1__c);
                }
                if(rec.Research_SPOC__c != null){
                    recipientUserIdSet.add(rec.Research_SPOC__c);
                }
                recordIdVsActionMessage.put(rec.Id, 'Approval for the Campaign Request '+ rec.Name + ' is '+ rec.Approval_Status__c);
                if(recipientUserIdSet.size() > 0){
                    recipientUserIdMap.put(rec.Id, recipientUserIdSet);
                }
            }
            //=======================End Here=========================//
        }
        if(!recordIdVsMessageMap.isEmpty()){
            ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
        }
        if(!recordIdAndMessageCRMExecutionMap.isEmpty()){
            ChatterNotificationUtil.sendChatterNotification(usersOfCRMExecution, recordIdAndMessageCRMExecutionMap);
        }
        if(!recordIdAndMessageCRMExecutionMap1.isEmpty()){
            ChatterNotificationUtil.sendChatterNotification(usersOfCRMExecution1, recordIdAndMessageCRMExecutionMap1);
        }
        if(!recordIdAndMessageCRMExecutionMap2.isEmpty()){
            ChatterNotificationUtil.sendChatterNotification(usersOfCRMExecution1, recordIdAndMessageCRMExecutionMap2);
        }
        if(adhocCampaignReqShareRecords.size() > 0){
            insert adhocCampaignReqShareRecords;
        }
        //Added by Najab on 25/11/2020
        if(recipientUserIdMap.size() > 0 && recordIdVsActionMessage.size() > 0){
            system.debug('recipientUserIdMap == > ' + recipientUserIdMap +  'recordIdVsActionMessage ==> ' + recordIdVsActionMessage);
            ChatterNotificationUtil.sendChatterNotification(recipientUserIdMap, recordIdVsActionMessage);
        }
        //=======================End Here=========================//
    }
    
    public void notificationSendToApprover(){
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Set<String> userIdSet = new Set<String>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        Set<Id> ownerIds = new Set<Id>();
        for(Adhoc_Campaign_Request__c adhocCampaignObj : campaignDatasetReqList){
            ownerIds.add(adhocCampaignObj.ownerId);
        }
        Map<String, User> managerIdMap = new Map<String, User>([SELECT Id, ManagerId FROM User WHERE Id IN : ownerIds]);
        
        for(Adhoc_Campaign_Request__c adhocCampaignObj : campaignDatasetReqList ){
            if(adhocCampaignObj.Campaign_Stage__c == 'Executed'){
                userIdSet.add(adhocCampaignObj.ownerId);
                if(managerIdMap.containsKey(adhocCampaignObj.ownerId)){
                    userIdSet.add(managerIdMap.get(adhocCampaignObj.ownerId).ManagerId);
                }
                escalationUsers.put(adhocCampaignObj.id, userIdSet);
                String emailTemplateMessage = 'Campaign Name : ' + adhocCampaignObj.Name;
                emailTemplateMessage += ' has been executed';
                recordIdVsMessageMap.put(adhocCampaignObj.Id, emailTemplateMessage);  
            }
        }
        if(escalationUsers.size() > 0 && recordIdVsMessageMap.size() > 0){
            ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
        }
    }
    //Added by Shaikh Mufiz on 03.11.2020
    //Start Here
    private void createDatasetRequestRecords(){
        Id aCrmChildRecordTypeId = adhocCampaignDescribe.getRecordTypeInfosByDeveloperName().get('aCRM_Child_Record').getRecordTypeId();
        List<Campaign> campaignRecList = [SELECT Id, Call_Center__c FROM Campaign WHERE Type = 'aCRM' AND isActive = true];
        List<Adhoc_Campaign_Request__c> adhocCampaignReqList = new List<Adhoc_Campaign_Request__c>();
        
        for(Adhoc_Campaign_Request__c adhocReqObj : campaignDatasetReqList){
            String recordTypeName = adhocCampaignDescribe.getRecordTypeInfosById().get(adhocReqObj.RecordTypeId).getDeveloperName();
            //Access the "old" record by its ID in Trigger.oldMap
            Adhoc_Campaign_Request__c oldAdhocReqObj = campaignDatasetReqOldMap.get(adhocReqObj.Id);
            if(recordTypeName == 'aCRM_Dataset' && adhocReqObj.Status__c != oldAdhocReqObj.Status__c && oldAdhocReqObj.Status__c == 'Pending Marketing Head' && adhocReqObj.Status__c == 'Pending Data Preparation'){
                for(Campaign campObj : campaignRecList){
                    Adhoc_Campaign_Request__c adhocCRObj = new Adhoc_Campaign_Request__c();
                    adhocCRObj.RecordTypeId = aCrmChildRecordTypeId;
                    adhocCRObj.Expected_Delivery_Date__c = adhocReqObj.Expected_Delivery_Date__c;
                    adhocCRObj.Omni_Channel_Comm__c = adhocReqObj.Omni_Channel_Comm__c;
                    adhocCRObj.Data_Filter_Requirements__c = adhocReqObj.Data_Filter_Requirements__c;
                    adhocCRObj.Expected_Business_Outcome__c = adhocReqObj.Expected_Business_Outcome__c;
                    adhocCRObj.Expected_Delivery_Timeline__c = adhocReqObj.Expected_Delivery_Timeline__c;
                    adhocCRObj.Data_Count_for_Model__c = adhocReqObj.Data_Count_for_Model__c;
                    adhocCRObj.Model_Details__c = adhocReqObj.Model_Details__c;
                    adhocCRObj.Expected_Campaign_Delivery_Baseline__c = adhocReqObj.Expected_Campaign_Delivery_Baseline__c;
                    adhocCRObj.Parent_Dataset_Request__c = adhocReqObj.Id;
                    adhocCRObj.Campaign_ID__c = campObj.Id;
                    adhocCRObj.DPS_Sync__c = 'Pending';
                    adhocCRObj.Status__c = 'Pending Data Submission to DPS';
                    adhocCRObj.Target_Model__c = adhocReqObj.Target_Model__c;
                    adhocCRObj.CRM_1_Spoc_L1__c = adhocReqObj.CRM_1_Spoc_L1__c;
                    adhocCRObj.Objective__c = adhocReqObj.Objective__c;
                    adhocCRObj.Call_Center__c = campObj.Call_Center__c;
                    adhocCampaignReqList.add(adhocCRObj);
                }
            }
        }
        if(adhocCampaignReqList.size() > 0){
            insert adhocCampaignReqList;
            System.debug('Child created Successfully...');
        }else{
            System.debug('Failed to create a child records');
        }
    }
    private void makeStatusExecuted(){
        Set<Id> parentIds = new Set<Id>();
        for(Adhoc_Campaign_Request__c adhocReqObj : campaignDatasetReqList){
            //Access the "old" record by its ID in Trigger.oldMap
            Adhoc_Campaign_Request__c oldAdhocReqObj = campaignDatasetReqOldMap.get(adhocReqObj.Id);
			String recordTypeName = adhocCampaignDescribe.getRecordTypeInfosById().get(adhocReqObj.RecordTypeId).getDeveloperName();
            if(recordTypeName == 'aCRM_Child_Record' && adhocReqObj.Parent_Dataset_Request__c != null){
                if(adhocReqObj.Close_Date__c != oldAdhocReqObj.Close_Date__c && adhocReqObj.Close_Date__c != null){
                    adhocReqObj.Status__c = 'Executed';
                    parentIds.add(adhocReqObj.Parent_Dataset_Request__c);
                }/*else if(adhocReqObj.DPS_Sync__c != oldAdhocReqObj.DPS_Sync__c && adhocReqObj.DPS_Sync__c.toLowercase() == 'success'){
                    adhocReqObj.Status__c = 'Data Submitted to DPS';
                }
                else if(oldAdhocReqObj.Data_Submitted_to_DPS__c != adhocReqObj.Data_Submitted_to_DPS__c && adhocReqObj.Data_Submitted_to_DPS__c == true){
                    adhocReqObj.Status__c = 'Data Submitted to DPS';
                }*/
            }
        }
        if(parentIds.size() > 0){
            makeParentStatusExecuted(parentIds);
        }
    }
    private void makeParentStatusExecuted(Set<Id> parentIds){
        List<Adhoc_Campaign_Request__c> datasetRequests = new List<Adhoc_Campaign_Request__c>();
        for(Adhoc_Campaign_Request__c dataset : [SELECT Id, (select Id, Status__c from Dataset_Requests__r WHERE Status__c != 'Executed' AND RecordType.Name = 'aCRM Child Record') 
                                                 FROM Adhoc_Campaign_Request__c Where Id IN: parentIds and Status__c != 'Executed' and Parent_Dataset_Request__c = null]){
                                                     if(dataset.Dataset_Requests__r.size() == 1 && dataset.Dataset_Requests__r[0].Status__c.toLowercase() == 'pending data submission to dps'){
                                                         dataset.Status__c = 'Executed';
                                                         datasetRequests.add(dataset);
                                                     }
                                                 }
        if(datasetRequests.size() > 0){
            TriggerHandler.bypass('CampaignDatasetRequestTriggerHandler');
            update datasetRequests;
            TriggerHandler.clearBypass('CampaignDatasetRequestTriggerHandler');
        }
    }
    //End Here
    //Added by Shaikh Mufiz on 03.11.2020
    
    //Modified by Shaikh Mufiz on 10.11.2020
    public void updateBusinessHoursField(){
        List<BusinessHours> businessHoursList = [SELECT Id FROM BusinessHours where name = 'MSIL Business Hours'];
        if(businessHoursList.size() > 0){
            for(Adhoc_Campaign_Request__c campaignReqObj : campaignDatasetReqList){
                String recordTypeName = adhocCampaignDescribe.getRecordTypeInfosById().get(campaignReqObj.RecordTypeId).getDeveloperName();
                if(recordTypeName == 'aCRM_Dataset'){
                    campaignReqObj.Business_Hours__c = businessHoursList[0].Id;
                }
            }
        }
    }
    //========End Here============//
    
    //Validate "Data submitted to DPS" added by Shaikh Mufiz on 17.11.2020
    private void validationForDataSubmittedToDPS(){
        for(Adhoc_Campaign_Request__c campaignReqObj : campaignDatasetReqList){
            //Access the "old" record by its ID in Trigger.oldMap
            Adhoc_Campaign_Request__c oldAdhocReqObj = campaignDatasetReqOldMap.get(campaignReqObj.Id);
            if(campaignReqObj.Status__c == 'Data Submitted to DPS' && campaignReqObj.Status__c == oldAdhocReqObj.Status__c && campaignReqObj.Data_Submitted_to_DPS__c == false && oldAdhocReqObj.Data_Submitted_to_DPS__c){
                campaignReqObj.addError('"Data submitted to DPS" can\'t be unchecked.');
            }
        }
    }
    //========End Here============//
    // Update child record status
    private void updateChildRecordsStatus(Set<Id> parentIds){
        List<Adhoc_Campaign_Request__c> datasetRequests = new List<Adhoc_Campaign_Request__c>();
        for(Adhoc_Campaign_Request__c dataset : [Select Id, Status__c from Adhoc_Campaign_Request__c 
                                                 WHERE Parent_Dataset_Request__c IN: parentIds AND 
                                                 RecordType.Name = 'aCRM Child Record']){
                                                     dataset.Status__c = 'Data Submitted to DPS';
                                                     datasetRequests.add(dataset);
                                                 }
        if(datasetRequests.size() > 0){
            TriggerHandler.bypass('CampaignDatasetRequestTriggerHandler');
            update datasetRequests;
            TriggerHandler.clearBypass('CampaignDatasetRequestTriggerHandler');
        }
    }
}