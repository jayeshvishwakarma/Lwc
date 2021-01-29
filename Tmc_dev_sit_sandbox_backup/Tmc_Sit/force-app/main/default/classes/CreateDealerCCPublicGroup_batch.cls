/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 09-03-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   09-02-2020   Rajesh Ramachandran   Initial Version
**/
public without sharing class CreateDealerCCPublicGroup_batch  implements Database.Batchable<sObject>,Schedulable {
    String sQuery;
    Boolean addUsers = false;

    public CreateDealerCCPublicGroup_batch() {

    }
      

    public CreateDealerCCPublicGroup_batch(boolean addUsers) {
        this.addUsers=addUsers;
      }    

    public Database.QueryLocator start(Database.BatchableContext BC){
        sQuery='select id,profile.name,account.parent_group__c from user where profile.name in (\'CCE Insurance\',\'Call Center Executive Service\') and id not in (select UserOrGroupId from groupmember where Group.type = \'Regular\' and group.name like \'DCC_%\')';
        return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed){
        try{ 
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

            List<Group> lsGroups = [select id,name from group where type = 'Regular' and name in :setGroupNames];
            Set<String> setExistingGroups = new Set<String>();
            for (Group grp : lsGroups){
                setExistingGroups.add(grp.name);
            }
            list<Group> missingGroups = new List<Group>();
            for (String grpName : setGroupNames){
                if (!setExistingGroups.contains(grpName)){
                    Group newGroup = New Group(type = 'Regular');
                    newGroup.name = grpName;
                    newGroup.DeveloperName=processGroupAPIName(grpName);
                    missingGroups.add(newGroup);
                }
            }
            if (missingGroups.size()>0){
                database.insert(missingGroups,false);
            }

            List<Group> lsAllGroups = [select id,name from group where type = 'Regular' and name in :setGroupNames];
            Map<String,Id> mapGroupNameToGroupId = new Map<String,Id>();
            for (Group grp : lsAllGroups){
                mapGroupNameToGroupId.put(grp.name,grp.Id);
            }
            
            List<GroupMember> lstGroupMember = new List<GroupMember>();
            for (String groupName : mapGroupToUsers.keySet()){
                if (mapGroupNameToGroupId.get(groupName) != null){
                    for (User memberUser : mapGroupToUsers.get(groupName)){
                        GroupMember grMemberVar=new GroupMember();
                        grMemberVar.GroupId=mapGroupNameToGroupId.get(groupName);
                        grMemberVar.UserOrGroupId=memberUser.Id;
                        lstGroupMember.add(grMemberVar);
                    }
                }
            }
            if (lstGroupMember.size()>0){
                Database.insert(lstGroupMember,false);
            }
        }
       catch(Exception ex){
           ExceptionHandler.LogError('CreateDealerCCPublicGroup_batch', ex.getMessage(),null,null, null); 
       }    
      }
      
      private static string processGroupAPIName(String sGroupName){
        if(sGroupName!=null ){
          string sGroupFirstCharacter=sGroupName.subString(0,1);
          if(sGroupFirstCharacter.isNumeric())
            return 'X'+sGroupName;
           else {
             return sGroupName;
           }
        }
        return sGroupName;
      }
    
      public void finish(Database.BatchableContext BC){
        system.debug('Completed dealer CC user group additions');
        if(addUsers){
            database.executeBatch(new AddUserToDealerCCGroup_Batch());
        }
    }      


    public void execute(SchedulableContext SC) {
        database.executebatch(new CreateDealerCCPublicGroup_batch());
       }


}