/**
    * @Autho:- Nishant Prajapati
    * @Company-: Techmatrix Consulting
    * @Description-: Batch class to add users to public groups 
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       08 Nov 2019    Nishant     Intial Version
    **/
public without sharing class MapProfileToGroupBatch implements Database.Batchable<sObject>, Database.Stateful{
   
   Set<Id> users2UpdateIdSet= new Set<Id>(); 
   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([Select id, Profile.Name, Previous_Profile_Name__c, Profile_Updated__c, UserRole.Name,User_Role_Text__c From User WHERE Profile_Updated__c= true AND isActive= true]);
   }

   public void execute(Database.BatchableContext BC, List<User> scope){
         Map<String, List<String>> profile2GroupMap= new Map<String, List<String>>();
         Map<String, List<String>> profile2RoleMap= new Map<String, List<String>>();
         List<GroupMember> grpMember2Create= new List<GroupMember>();
         set<String> groupSet= new set<String>();
         Profile_To_Group_Mapping__mdt[] custMeta= [SELECT MasterLabel, Group_Name__c, Role__c FROM Profile_To_Group_Mapping__mdt];
         
         for(Profile_To_Group_Mapping__mdt md : custMeta){
             if(!profile2GroupMap.containskey(md.MasterLabel)){
                 profile2GroupMap.put(md.MasterLabel, new List<String>());
             }
             profile2GroupMap.get(md.MasterLabel).addAll((md.Group_Name__c).split(','));
             
             if(String.isNotBlank(md.Role__c)){
                 if(!profile2RoleMap.containskey(md.MasterLabel)){
                     profile2RoleMap.put(md.MasterLabel, new List<String>());
                 }
                 profile2RoleMap.get(md.MasterLabel).addAll((md.Role__c).split(','));
             }
             groupSet.addAll((md.Group_Name__c).split(','));
         }
         
         Map<string, string> groupMap= new Map<string, string>();
         for(Group gr : [SELECT Id, Name, DeveloperName from Group WHERE DeveloperName IN: groupSet]){
             groupMap.put(gr.DeveloperName, gr.Id);
         }
         
         Set<ID> setGroupId= new Set<Id>();
         Set<ID> setUserOrGroupId= new Set<Id>();
         Set<String> roleSet = new set<String>( label.Maruti_Management_User_Roles != Null ? label.Maruti_Management_User_Roles.split(',') : new List<string>());
             
         for(User ur : scope){
             //Boolean isMarutiManagementUser= (ur.Profile.Name == ConstantsUtility.MARUTI_MANAGEMENT) ? true : false;
             Boolean isMarutiManagementUser= roleSet.contains(ur.User_Role_Text__c) ? true : false;
             //delete user from old group 
             if(String.isNotBlank(ur.Previous_Profile_Name__c)){
                 if(profile2GroupMap.containsKey(ur.Previous_Profile_Name__c)){
                     List<String> groups2Exclude= profile2GroupMap.get(ur.Previous_Profile_Name__c);
                     for(String grp : groups2Exclude){
                         if(groupMap.containsKey(grp)){
                             setGroupId.add(groupMap.get(grp));
                         }
                     }
                 }
                 setUserOrGroupId.add(ur.Id);
             }
             
             
             //add user to new group
             if(isMarutiManagementUser && (profile2RoleMap.size() > 0 && profile2RoleMap.containsKey(ur.profile.Name))){
                 List<String> userRoles2Check = profile2RoleMap.get(ur.profile.Name);
                 
                 if(userRoles2Check.size() > 0){
                     for(Integer i=0; i< userRoles2Check.size(); i++){
                         if((ur.User_Role_Text__c).Contains(userRoles2Check[i])){
                             List<String> grps2Include= profile2GroupMap.get(ur.profile.Name);
                             
                             GroupMember gm = new GroupMember();
                             gm.GroupId = groupMap.get(grps2Include[i]);
                             gm.UserOrGroupId = ur.Id;
                             grpMember2Create.add(gm);
                             break;
                         }
                     }
                     users2UpdateIdSet.add(ur.Id);
                 }
                 
             }else if(profile2GroupMap.containsKey(ur.profile.Name)){
                 List<String> grps2Include = profile2GroupMap.get(ur.profile.Name);
                 
                 for(String grp : grps2Include){
                     if(groupMap.containsKey(grp)){
                         GroupMember gm = new GroupMember();
                         gm.GroupId = groupMap.get(grp);
                         gm.UserOrGroupId = ur.Id;
                         grpMember2Create.add(gm);
                     }
                     
                 }
                 users2UpdateIdSet.add(ur.Id);
             }
         }
         
         if(setUserOrGroupId.size() > 0 && setGroupId.size() > 0){
             List<GroupMember> grpMember2Delete= [Select Id from GroupMember where UserOrGroupID IN: setUserOrGroupId AND GroupId IN: setGroupId ];
             if(grpMember2Delete.size() > 0){
                 delete grpMember2Delete;
             }
         }
         if(grpMember2Create.size() > 0){
             insert grpMember2Create;
         }
         
   }

   public void finish(Database.BatchableContext BC){
       if(users2UpdateIdSet.size() > 0){
           List<User> users2Update= new List<User>();
           for(Id userId : users2UpdateIdSet){
               User ur= new User(Id= userId);
               ur.Profile_Updated__c= false;
               ur.Previous_Profile_Name__c= '';
               users2Update.add(ur);
           }
           
           if(users2Update.size() > 0 && !Test.isRunningTest()){
               update users2Update;
           }
       }
   }
}