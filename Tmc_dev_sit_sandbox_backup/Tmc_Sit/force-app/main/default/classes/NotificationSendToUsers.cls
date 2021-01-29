/**
* @Autho:- Najab Maghribi
* @Company-: Techmatrix Consulting
* @Description-: NotificationSendToUsers class for Send Notification to users and manager with specific condition.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       30 Oct 2020    Najab     Intial Version
**/
public class NotificationSendToUsers{

    public static void notificationToUsers(){
        // These variables used for Add 11 Days conditions from campaign end date sent chatter notificaitons.
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Set<String> userIdSet = new Set<String>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        
        // These variables used for Substract 5 Days conditions from campaign end date sent chatter notificaitons.
        Map<Id, Set<String>> campaignEscalationUsers = new Map<Id, Set<String>>();
        Set<String> campaignUserIdSet = new Set<String>();
        Map<Id, String> campaignRecordIdAndMessageMap = new Map<Id, String>();
        List<Adhoc_Campaign_Request__c >  offlineAdhocCampaignRecords = [SELECT Id, Name, Form_Number__c, RecordType.Name, Campaign_End_Date__c, Campaign_Stage__c, 
                                                                          Campaign_Id__r.Name, Campaign_Id__r.ownerId, ownerId, Brand__c,
                                                                          CRM_1_Spoc_L1__c, CRM_2_Spoc_L1__c, Research_SPOC__c
                                                                          FROM Adhoc_Campaign_Request__c 
                                                                          WHERE RecordType.Name = 'Offline Campaigns' AND Campaign_Stage__c != 'Executed'
                                                                      ];
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> campaignOwnerIds = new Set<Id>();
        for(Adhoc_Campaign_Request__c adhocCampaignObj : offlineAdhocCampaignRecords){
             ownerIds.add(adhocCampaignObj.ownerId);
             campaignOwnerIds.add(adhocCampaignObj.Campaign_Id__r.ownerId);
        }
        Map<String, User> managerIdMap = new Map<String, User>([SELECT Id, ManagerId FROM User WHERE Id IN : ownerIds]);
        Map<String, User> campaignManagerIdMap = new Map<String, User>([SELECT Id, ManagerId FROM User WHERE Id IN : campaignOwnerIds]);
        
        for(Adhoc_Campaign_Request__c adhocCampaignObj : offlineAdhocCampaignRecords){
            
            if(adhocCampaignObj.Campaign_Stage__c == 'Pending Campaign Execution' && System.Today() > adhocCampaignObj.Campaign_End_Date__c 
                && System.Today() <  (adhocCampaignObj.Campaign_End_Date__c - 5)){
                if(adhocCampaignObj.Campaign_Id__r.ownerId != null){
                    campaignUserIdSet.add(adhocCampaignObj.Campaign_Id__r.ownerId);
                }
                if(adhocCampaignObj.CRM_1_Spoc_L1__c != null){
                    campaignUserIdSet.add(adhocCampaignObj.CRM_1_Spoc_L1__c);
                }
                if(adhocCampaignObj.CRM_2_Spoc_L1__c != null){
                    campaignUserIdSet.add(adhocCampaignObj.CRM_2_Spoc_L1__c);
                }
                if(adhocCampaignObj.Research_SPOC__c != null){
                    campaignUserIdSet.add(adhocCampaignObj.Research_SPOC__c);
                }
                if(campaignManagerIdMap.containsKey(adhocCampaignObj.Campaign_Id__r.ownerId)){
                    campaignUserIdSet.add(managerIdMap.get(adhocCampaignObj.Campaign_Id__r.ownerId).ManagerId);
                }
                campaignEscalationUsers.put(adhocCampaignObj.id, userIdSet);
                String emailTemplateMessage = 'Campaign Name : ' + adhocCampaignObj.Name;
                emailTemplateMessage += ', for' + adhocCampaignObj.Brand__c + ' closure date is ';
                emailTemplateMessage += adhocCampaignObj.Campaign_End_Date__c;
                emailTemplateMessage += '. Kindly start submiting the closure documents.';
                campaignRecordIdAndMessageMap.put(adhocCampaignObj.Id, emailTemplateMessage);  
            }
            
            if(System.Today() > adhocCampaignObj.Campaign_End_Date__c && System.Today() <  adhocCampaignObj.Campaign_End_Date__c.addDays(11)){
                userIdSet.add(adhocCampaignObj.ownerId);
                if(managerIdMap.containsKey(adhocCampaignObj.ownerId)){
                    userIdSet.add(managerIdMap.get(adhocCampaignObj.ownerId).ManagerId);
                }
                escalationUsers.put(adhocCampaignObj.id, userIdSet);
                String emailTemplateMessage = 'Campaign Name : ' + adhocCampaignObj.Name;
                emailTemplateMessage += ' is beyond its End Date - ';
                emailTemplateMessage += adhocCampaignObj.Campaign_End_Date__c;
                emailTemplateMessage += '. Please update the status to Executed.';
                
                recordIdVsMessageMap.put(adhocCampaignObj.Id, emailTemplateMessage);  
            }
        }
        if(escalationUsers.size() > 0 && recordIdVsMessageMap.size() > 0){
            ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
        }
        if(campaignEscalationUsers.size() > 0 && campaignRecordIdAndMessageMap.size() > 0){
            ChatterNotificationUtil.sendChatterNotification(campaignEscalationUsers, campaignRecordIdAndMessageMap);
        }
    }
    //Added by Shaikh Mufiz on 10.11.2020
    //=================Start Here====================//
    public static void aCRM_RemainderForDataPreparation(){
        Notification_Escalation_Day__c notificationDay = Notification_Escalation_Day__c.getOrgDefaults();
        
        List<Adhoc_Campaign_Request__c> campaignDatasetRequests = [SELECT Id, Name, MKTG_Head_Approved_Date__c, Business_Hours__c, CRM_2_Spoc_L1__c, CRM2_DPM__c FROM Adhoc_Campaign_Request__c WHERE 
                                                                   MKTG_Head_Approved_Date__c != null AND Business_Hours__c != null AND Status__c = 'Pending Data Preparation' AND RecordType.Name = 'aCRM Dataset'];
        
        Map<Id, Set<String>> escalationUsers = new Map<Id, Set<String>>();
        Map<Id, String> recordIdVsMessageMap = new Map<Id, String>();
        
        if(notificationDay != null && campaignDatasetRequests.size() > 0){
            for(Adhoc_Campaign_Request__c obj : campaignDatasetRequests){
                Datetime targetTime = obj.MKTG_Head_Approved_Date__c;
                Set<String> userIdSet = new Set<String>();
                for(Integer i = 1; i <= Integer.valueOf(notificationDay.Name); i++){
                    if(i > 1)  targetTime = targetTime.addDays(1);
                    DateTime nextValidDateTime = BusinessHours.nextStartDate(Obj.Business_Hours__c, targetTime);
                    system.debug('***' + nextValidDateTime);
                    targetTime = nextValidDateTime;
                }
                if(System.now() > targetTime){
                    System.debug('Dates : '+System.now() +' and '+ targetTime);
                    if(String.isNotBlank(obj.CRM_2_Spoc_L1__c)){
                        userIdSet.add(obj.CRM_2_Spoc_L1__c);
                    }
                    if(String.isNotBlank(obj.CRM2_DPM__c)){
                        userIdSet.add(obj.CRM2_DPM__c);
                    }
                }
                if(userIdSet.size() > 0 ){
                    System.debug('userIdSet.size() : '+userIdSet.size());
                    escalationUsers.put(obj.id, userIdSet);
                }
                String emailTemplateMessage = 'Hi \n';
                emailTemplateMessage += 'The data for aCRM campaign ' + obj.Name + ' has not been provided yet. The request has been approved 10 days ago. Kindly expedite the process\n';
                emailTemplateMessage += 'Thank you';
                
                recordIdVsMessageMap.put(obj.id, emailTemplateMessage);
            }
            if(escalationUsers.size() > 0 && recordIdVsMessageMap.size() > 0){
                ChatterNotificationUtil.sendChatterNotification(escalationUsers, recordIdVsMessageMap);
                System.debug('Email send to users');
            }
        }
    }
    //=================End Here====================//
}