/**
    * @Autho:- Rohit Gupta
    * @Company-: Techmatrix Consulting
    * @Description-: Batch class to add Dealer RMs, National Heads and Zonal Heads to Channel wise Chatter Group 
    * with name like 'All Regional Employees Nexa' or 'All Regional Employees Arena' 
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       10 Jun 2020    Rohit     Intial Version
    **/
global class ProfileToChatterGroupBatch4 implements Database.Batchable<sObject>, Database.Stateful{
    global String mZH; 
    global String mNH; 
    global String rMProfile; 
    
    global ProfileToChatterGroupBatch4(String mZH, String mNH, String rMProfile){
        this.mZH = mZH;
        this.mNH = mNH;
        this.rMProfile = rMProfile;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query;
        if(!Test.isRunningTest()){
            query = 'Select id, Profile.Name, Previous_Profile_Name__c, Profile_Updated__c, '+
                'UserRole.Name,User_Role_Text__c,Channel__c,Dealer_Channel__c,Dealer_Region__c, ' +
                'contact.account.Region_code__c From User WHERE isActive= true and '+
                '(profile.name = \''+mZH+'\' or profile.name = \''+mNH+'\' or profile.name = \''+rMProfile+'\')'; 
           
        }else {
            query = 'Select id, Profile.Name, Previous_Profile_Name__c, Profile_Updated__c, '+
                'UserRole.Name,User_Role_Text__c,Channel__c,Dealer_Channel__c,Dealer_Region__c, ' +
                'contact.account.Region_code__c From User WHERE isActive= true and '+
                '(profile.name = \''+mZH+'\' or profile.name = \''+mNH+'\' or profile.name = \''+rMProfile+'\') limit 100'; 
        }
        return Database.getQueryLocator(query);
       
        
    }
     global void execute(Database.BatchableContext bc, List<User> scope){        
        List<CollaborationGroupMember> cGroupMemberList = new List<CollaborationGroupMember>();
        Set<String> groupSet = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        Map<string, string> cGroupMap= new Map<string, string>();
        List<String> groupNames = System.label.All_Regional_Employees_Group != null ? System.label.All_Regional_Employees_Group.split(','): new List<String>();
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
        System.debug('map3 '+ map3);
        for(User user: scope){
            String key;
             if(user.Dealer_Channel__c != null && user.Channel__c == 'Maruti'){
            	key = 'All Regional Employees '+ user.Dealer_Channel__c ;
            }             
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