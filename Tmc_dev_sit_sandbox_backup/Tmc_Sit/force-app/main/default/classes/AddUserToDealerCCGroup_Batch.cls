/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 09-03-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   09-03-2020   Rajesh Ramachandran   Initial Version
**/
public without sharing class AddUserToDealerCCGroup_Batch implements Database.Batchable<SObject>{
    String sQuery;

    public Database.QueryLocator start(Database.BatchableContext BC){
        sQuery='select id,account.parent_group__c from user where contactid != null and id not in (select userid from UserShare where rowcause = \'Manual\' and UserOrGroup.name like \'DCC__%\')';
        return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed){
        try {
            Set<String> setGroupNames = new Set<String>();
            Map<String,List<User>> mapGroupToUsers = new Map<String,List<User>>();
            for (User oUserVar : (List<User>)lstRecordsToBeProcessed){
                if (oUserVar.account.parent_group__c != null){
                    String dccGroupName = 'DCC_' + oUserVar.account.parent_group__c;
                    setGroupNames.add(dccGroupName);
                    if (!mapGroupToUsers.containsKey(dccGroupName)){
                        List<User> lsUsers = new List<User>();
                        lsUsers.add(oUserVar);
                        mapGroupToUsers.put(dccGroupName, lsUsers);
                    }
                    else{
                        mapGroupToUsers.get(dccGroupName).add(oUserVar);
                    }
                }
            }

            List<Group> lsAllGroups = [select id,name from group where type = 'Regular' and name in :setGroupNames];
            Map<String,Id> mapGroupNameToGroupId = new Map<String,Id>();
            for (Group grp : lsAllGroups){
                mapGroupNameToGroupId.put(grp.name,grp.Id);
            }
            
            List<UserShare> lstGroupMember = new List<UserShare>();
            for (String groupName : mapGroupToUsers.keySet()){
                if (mapGroupNameToGroupId.get(groupName) != null){
                    for (User memberUser : mapGroupToUsers.get(groupName)){
                        UserShare userShareVar =new UserShare();
                        userShareVar.UserOrGroupId=mapGroupNameToGroupId.get(groupName);
                        userShareVar.userid=memberUser.Id;
                        userShareVar.rowcause='Manual';
                        userShareVar.UserAccessLevel='Read';
                        lstGroupMember.add(userShareVar);
                    }
                }
            }
            if (lstGroupMember.size()>0){
                Database.insert(lstGroupMember,false);
            }

        } catch(Exception ex){
            ExceptionHandler.LogError('AddUserToDealerCCGroup_Batch', ex.getMessage(),null,null, null); 
        } 
    }

    public void finish(Database.BatchableContext BC){
        system.debug('Completed Add user to dealer CC user group');
    }


}