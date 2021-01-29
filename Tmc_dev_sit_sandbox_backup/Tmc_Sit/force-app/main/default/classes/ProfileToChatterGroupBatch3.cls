/**
    * @Autho:- Rohit Gupta
    * @Company-: Techmatrix Consulting
    * @Description-: Batch class to add Dealer TSMs and RM to Region wise Chatter Group like 'All RO C1 Sales Users' or 'All RO C2 Sales Users' 
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       10 Jun 2020    Rohit     Intial Version
    **/
global without sharing class ProfileToChatterGroupBatch3 implements Database.Batchable<sObject>, Database.Stateful{
    global String salesProfile; 
    global String rMProfile; 
    
    global ProfileToChatterGroupBatch3(String salesProfile, String rMProfile){       
        this.salesProfile = salesProfile;
        this.rMProfile = rMProfile;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
         String query;
        if(!Test.isRunningTest()){
            query = 'Select id, Profile.Name, Previous_Profile_Name__c, Profile_Updated__c, '+
                'UserRole.Name,User_Role_Text__c,Channel__c,Dealer_Channel__c,Dealer_Region__c, ' +
                'contact.account.Region_code__c From User WHERE isActive= true and '+
                '(profile.name = \''+salesProfile+'\' or profile.name = \''+rMProfile+'\')'; 
           
        }else {
            query = 'Select id, Profile.Name, Previous_Profile_Name__c, Profile_Updated__c, '+
                'UserRole.Name,User_Role_Text__c,Channel__c,Dealer_Channel__c,Dealer_Region__c, ' +
                'contact.account.Region_code__c From User WHERE isActive= true and '+
                '(profile.name = \''+salesProfile+'\' or profile.name = \''+rMProfile+'\') limit 100'; 
        }
        return Database.getQueryLocator(query);
        
    }
     global void execute(Database.BatchableContext bc, List<User> scope){        
        List<CollaborationGroupMember> cGroupMemberList = new List<CollaborationGroupMember>();
        Set<String> groupSet = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        Map<string, string> cGroupMap= new Map<string, string>();
        List<String> groupNames = System.label.All_RO_Sales_User_Group != null ? System.label.All_RO_Sales_User_Group.split(','): new List<String>();
        Map<String, Set<String>> map3 = new Map<String, Set<String>>();
        
        for(User usr: scope){
            userIdSet.add(usr.Id);
        }
        for(String str: groupNames){
            groupSet.add(str);
        }        
        System.debug('groupSet '+groupSet);
        
         for(CollaborationGroup gr : [SELECT Id, Name FROM CollaborationGroup  WHERE  Name IN: groupSet]){
             cGroupMap.put(gr.Name, gr.Id);
         }
         System.debug('cGroupMap '+cGroupMap);
        
        for(CollaborationGroupMember cgm: [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId IN :userIdSet ]){
            if(map3.containsKey(cgm.CollaborationGroupId)){
                Set<String> localSet = map3.get(cgm.CollaborationGroupId);
                localSet.add(cgm.MemberId);
                map3.put(cgm.CollaborationGroupId, localSet);
            }else {
                map3.put(cgm.CollaborationGroupId, new Set<String> {cgm.MemberId});
            }
            
        }
        
        for(User user: scope){
            String key;
             if(user.Dealer_Region__c != null && user.Channel__c == 'Maruti'){
            	key = 'All RO '+ user.Dealer_Region__c + ' Sales Users';
            } 
            
            System.debug('key '+key);
           /* if(cGroupMap.containsKey(key)){
                CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                cGroupMember.MemberId = user.Id;
                cGroupMember.CollaborationGroupId = cGroupMap.get(key);
                cGroupMemberList.add(cGroupMember);
            }*/
            if(cGroupMap.containsKey(key)){
                    if((!map3.containsKey(cGroupMap.get(key)))){                        
                        CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                        cGroupMember.MemberId = user.Id;                        
                        cGroupMember.CollaborationGroupId = cGroupMap.get(key);
                        cGroupMemberList.add(cGroupMember);                        
                    } else if(map3.containsKey(cGroupMap.get(key))){
                        if(!map3.get(cGroupMap.get(key)).contains(user.Id)){
                            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                            cGroupMember.MemberId = user.Id;                        
                            cGroupMember.CollaborationGroupId = cGroupMap.get(key);
                            cGroupMemberList.add(cGroupMember);
                        }
                    }
                }
            
        }
        System.debug('@@ '+ cGroupMemberList);
        if(cGroupMemberList.size() > 0){
            insert cGroupMemberList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}