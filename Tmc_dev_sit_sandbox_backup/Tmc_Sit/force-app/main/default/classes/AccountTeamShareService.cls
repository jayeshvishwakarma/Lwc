/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Account Team Share Service

History
Date            Author             Comments
--------------------------------------------------------------------------------------
25-09-2019      Sumit Gupta        Event and Campaign Sharing
------------------------------------------------------------------------------------*/
public without sharing class AccountTeamShareService {
    
    /*------------------------------------------------------------------------------------
        Description     provide record(s) access to owner's account team
        params          recordIds - object record ids
    ------------------------------------------------------------------------------------*/
    public static void createShareRecords(Set<Id> recordIds){
        if(recordIds != null && !recordIds.isEmpty()){
            //map of object name and object record ids
            Map<String, Set<Id>> recordIdsMap = new Map<String, Set<Id>>();
            for(Id recordId : recordIds){
                //get object name from record id
                String objectType = getObjectType(recordId);
                if(recordIdsMap.containsKey(objectType)){
                    recordIdsMap.get(objectType).add(recordId);
                } else {
                    recordIdsMap.put(objectType, new Set<Id>{ recordId });
                }
            }
            for(String objectType : recordIdsMap.keySet()){
                createShareRecords(objectType, recordIdsMap.get(objectType));
            }
        }
    }

    /*------------------------------------------------------------------------------------
        Description     provide record(s) access to owner's account team
        params          objectType - object name 
                        recordIds - object record ids
    ------------------------------------------------------------------------------------*/
    public static void createShareRecords(String objectType, Set<Id> recordIds){
        try{
            if(String.isNotBlank(objectType) != null && recordIds != null && !recordIds.isEmpty()){
                List<SObject> records = Database.query('SELECT Id, OwnerId FROM ' + objectType + ' WHERE Id IN :recordIds');
                if(!records.isEmpty()){
                    //map of user id and account id
                    Map<Id, User> usersMap = getUsersMap(getOwnerIds(records));
                    if(!usersMap.isEmpty()){
                        //map of user id and user account
                        Map<Id, Account> userAccountsMap = getUserAccountsMap(usersMap.keySet());
                        //map of account id and partner account
                        Map<Id, Account> partnerAccountsMap = getPartnerAccountsMap(getAccountIds(usersMap.values()));
                        List<SObject> shareRecordsToCreate = new List<SObject>();
                        for(SObject record : records){
                            Id userId = getOwnerId(record);
                            User userRecord = usersMap.get(userId);
                            Account userAccount = userAccountsMap.get(userId);
                            Account partnerAccount = partnerAccountsMap.get(userRecord.Contact.AccountId);
                            //applicable users which require record sharing
                            Set<Id> userIds = getApplicableUserIds(userRecord, userAccount, partnerAccount);
                            if(!userIds.isEmpty()){
                                List<SObject> shareRecords = getShareRecords(objectType, record.Id, userIds);
                                shareRecordsToCreate.addAll(shareRecords);
                            }
                        }
                        //final step - create share records
                        if(!shareRecordsToCreate.isEmpty()){
                            Database.insert(shareRecordsToCreate, false);
                        }
                    }
                }
            }
        } catch(Exception ex) {
            ExceptionHandler.stackTrace trace = new ExceptionHandler.stackTrace();
            trace.componentName = 'Create share records';
            trace.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('AccountTeamShareService', ex.getMessage(), objectType, '', trace);
        }
    }

    /*------------------------------------------------------------------------------------
        Description     To get user details
        params          userIds - user ids
    ------------------------------------------------------------------------------------*/
    private static Map<Id, User> getUsersMap(Set<Id> userIds){
        Map<Id, User> userAccountIdsMap = new Map<Id, User>();
        for(User user : [
            SELECT Id, Contact.AccountId, Designation__c 
            FROM User 
            WHERE Id =: userIds
            AND UserType = 'PowerPartner'
        ]){
            if(user.Contact != null && user.Contact.AccountId != null){
                userAccountIdsMap.put(user.Id, user);
            }
        }
        return userAccountIdsMap;
    }

    /*------------------------------------------------------------------------------------
        Description     To get user account details
        params          userIds - user ids
    ------------------------------------------------------------------------------------*/
    private static Map<Id, Account> getUserAccountsMap(Set<Id> userIds){
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        for(Account acc: [
            SELECT Id, User__c, (SELECT Id, UserId, AccountAccessLevel FROM AccountTeamMembers) 
            FROM Account 
            WHERE User__c IN : userIds
            AND RecordType.DeveloperName = 'User_Account'
        ]){
            accountsMap.put(acc.User__c, acc);
        }
        return accountsMap;
    }

    /*------------------------------------------------------------------------------------
        Description     To get partner account details
        params          accountIds - account ids
    ------------------------------------------------------------------------------------*/
    private static Map<Id, Account> getPartnerAccountsMap(Set<Id> accountIds){
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        for(Account acc: [
            SELECT Id, Territory_Sales_Manager__c , TSM_ISL__c, TSM_MGA__c, TSM_Rural__c
            FROM Account 
            WHERE Id IN : accountIds
        ]){
            accountsMap.put(acc.Id, acc);
        }
        return accountsMap;
    }

    /*------------------------------------------------------------------------------------
        Description     To get owner ids
        params          records
    ------------------------------------------------------------------------------------*/
    private static Set<Id> getOwnerIds(List<SObject> records){
        Set<Id> ownerIds = new Set<Id>();
        for(SObject record : records){
            Id ownerId = getOwnerId(record);
            ownerIds.add(ownerId);
        }
        return ownerIds;
    }

    /*------------------------------------------------------------------------------------
        Description     To get owner id
        params          record
    ------------------------------------------------------------------------------------*/
    private static Id getOwnerId(SObject record){
        return (Id) record.get('OwnerId');
    }

    /*------------------------------------------------------------------------------------
        Description     To user account ids
        params          records
    ------------------------------------------------------------------------------------*/
    private static Set<Id> getAccountIds(List<User> users){
        Set<Id> accountIds = new Set<Id>();
        for(User user : users){
            Id accountId = user.Contact.AccountId;
            accountIds.add(accountId);
        }
        return accountIds;
    }

    /*------------------------------------------------------------------------------------
        Description     To get applicable user ids which require record access
        params          userAccount - user account details
                        partnerAccount - partner account details
    ------------------------------------------------------------------------------------*/
    private static Set<Id> getApplicableUserIds(User userRecord, Account userAccount, Account partnerAccount){
        Set<Id> userIds = new Set<Id>();
        if(userAccount != null){
            for(AccountTeamMember member : userAccount.AccountTeamMembers){
                userIds.add(member.UserId);
            }
        }
        if(partnerAccount != null){
            userIds.add(partnerAccount.Territory_Sales_Manager__c);
            //if user designation is tsm rural
            if(ConstantsUtility.TSM_RURAL_DESIGNATION.contains(userRecord.Designation__c)){
                userIds.add(partnerAccount.TSM_Rural__c);
            }
            //if user designation is tsm mga
            if(ConstantsUtility.TSM_MGA_DESIGNATION.contains(userRecord.Designation__c)){
                userIds.add(partnerAccount.TSM_MGA__c);
            }
             //if user designation is tsm isl
            if(ConstantsUtility.TSM_ISL_DESIGNATION.contains(userRecord.Designation__c)){
                userIds.add(partnerAccount.TSM_ISL__c);
            }
        }
        return userIds;
    }

    /*------------------------------------------------------------------------------------
        Description     To get new share records
        params          objectType - object name
                        parentId - record id 
                        userIds - user ids
    ------------------------------------------------------------------------------------*/
    public static List<SObject> getShareRecords(String objectType, Id parentId, Set<Id> userIds){
        List<SObject> shareRecords = new List<SObject>();
        for(Id userId : userIds){
            Boolean isCustomObjectType = isCustomObjectType(objectType);
            SObject shareRecord = getNewShareRecord(objectType, isCustomObjectType);
            shareRecord.put('UserOrGroupId', userId);
            shareRecord.put(isCustomObjectType ? 'ParentId' : objectType + 'Id', parentId);
            shareRecord.put(isCustomObjectType ? 'AccessLevel' : objectType + 'AccessLevel', 'edit');
            shareRecords.add(shareRecord);
        }
        return shareRecords;
    }

    /*------------------------------------------------------------------------------------
        Description     Custom object type check
        params          objectType - object name
    ------------------------------------------------------------------------------------*/
    private static Boolean isCustomObjectType(String objectType){
        return Schema.getGlobalDescribe().get(objectType).getDescribe().isCustom();
    }

    /*------------------------------------------------------------------------------------
        Description     To get new share record
        params          objectType - object name
    ------------------------------------------------------------------------------------*/
    private static SObject getNewShareRecord(String objectType, Boolean isCustomObjectType){
        String shareObjectType = getShareObjectType(objectType, isCustomObjectType);
        return Schema.getGlobalDescribe().get(shareObjectType).getDescribe().getSObjectType().newSObject();
    }

    /*------------------------------------------------------------------------------------
        Description     To get object name from record id
        params          recordId - record id
    ------------------------------------------------------------------------------------*/
    private static String getObjectType(Id recordId){
        return recordId.getSobjectType().getDescribe().getName();
    }

    /*------------------------------------------------------------------------------------
        Description     To get share object name from object name
        params          objectType - object name
    ------------------------------------------------------------------------------------*/
    private static String getShareObjectType(String objectType, Boolean isCustomObjectType){
        return isCustomObjectType ? objectType.replace('__c', '__share') : objectType + 'Share';
    }
}