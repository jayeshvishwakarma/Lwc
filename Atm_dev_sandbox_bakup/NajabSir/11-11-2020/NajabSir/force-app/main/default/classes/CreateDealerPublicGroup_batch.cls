global with sharing class CreateDealerPublicGroup_batch implements Database.Batchable<sObject>{
    global  String sQuery;
    global boolean bIsCreateMember;
    global CreateDealerPublicGroup_batch(boolean bIsCreateMember) {
      this.bIsCreateMember=bIsCreateMember;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        sQuery='select Id,Parent_Group__c from Account where Recordtype.DeveloperName=\'Dealer\' and Parent_Group__c!=null';
        return Database.getQueryLocator(sQuery);
       }
    global void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed){
      try{ 
        Set<String> setPublicGroupName=new Set<String>();
        Map<Id,String> mapAccountIdPublicGroupDealer=new map<Id,String>();
        Map<String,Group> mapGroupPublicGroupDealerInstance=new map<String,Group>();
        List<GroupMember> lstGroupMember=new List<GroupMember>();
        for(Account oAccVar: (List<Account>)lstRecordsToBeProcessed){
          if(!setPublicGroupName.contains(oAccVar.Parent_Group__c)){
            Group grpVar=new Group(Type='Regular');
            grpVar.DeveloperName=processGroupAPIName(oAccVar.Parent_Group__c);
            grpVar.Name=oAccVar.Parent_Group__c;
            setPublicGroupName.add(oAccVar.Parent_Group__c);
            mapGroupPublicGroupDealerInstance.put(oAccVar.Parent_Group__c,grpVar);
           } 
          mapAccountIdPublicGroupDealer.put(oAccVar.Id,oAccVar.Parent_Group__c);
        }
        if(mapAccountIdPublicGroupDealer.size()>0)
         database.insert(mapGroupPublicGroupDealerInstance.values(),false);
         if(bIsCreateMember){
             List<Group> lstGroup=[select Id,Name from Group where type='Regular' and name IN : mapAccountIdPublicGroupDealer.values()];
             map<String,String> mapGroupNameId=new map<String,String>();
             for(Group grvar: lstGroup){
               mapGroupNameId.put(grVar.name,grvar.Id);
             }
             List<User> lstExtUser=new List<User>();
             lstExtUser=[select Id,AccountId from User where AccountId IN :mapAccountIdPublicGroupDealer.keySet()];
             for(User oUser: lstExtUser){
                 GroupMember grMemberVar=new GroupMember();
                 String sGroupDealerCode=mapAccountIdPublicGroupDealer.get(oUser.AccountId);
                 if(mapGroupNameId.containsKey(sGroupDealerCode)){
                 grMemberVar.GroupId=mapGroupNameId.get(sGroupDealerCode);
                 grMemberVar.UserOrGroupId=oUser.Id;
                 lstGroupMember.add(grMemberVar);
                 }
             }
            if(lstGroupMember.size()>0)
             insert lstGroupMember;
            
         }
      }
     catch(Exception ex){
         ExceptionHandler.LogError('CreateDealerPublicGroup_batch', ex.getMessage(),null,null, null); 
     }    
    }

   global void finish(Database.BatchableContext BC){
       
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
}