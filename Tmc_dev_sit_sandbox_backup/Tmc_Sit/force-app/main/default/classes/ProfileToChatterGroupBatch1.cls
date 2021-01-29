/**
    * @Autho:- Rohit Gupta
    * @Company-: Techmatrix Consulting
    * @Description-: Batch class to add Dealer users to  Chatter Group with name like 'Dealer_code_Forcode_DealerName' 
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       10 Jun 2020    Rohit     Intial Version
    **/
global without sharing class ProfileToChatterGroupBatch1 implements Database.Batchable<sObject>, Database.Stateful{
    global String dealerTVEvaluator = 'Dealer TV Evaluator';
    global String driver = 'Driver' ;
    global String hostess = 'Dealer Hostess';
    global String dse = 'Dealer Sales Executive';
    global String tl = 'Dealer Team Leads/Managers';
    global String gm = 'Dealer GM';
    global String ceo =  'Dealer CEO/Owner';
    global String dFM = 'Dealer Finance Manager';
    global String dAU = 'Dealer Accessories User';    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query;
        if(!Test.isRunningTest()){
            query ='Select id, Profile.Name, Contact.Account.Parent_Group__c, Contact.Account.Dealer_code__c, Contact.Account.FOR_Code__r.For_Code__c, '+
                'UserRole.Name,User_Role_Text__c,Channel__c,Dealer_Channel__c,Dealer_Region__c, ' +                
                'contact.account.Region_code__c From User WHERE isActive= true and  contact.AccountId != null '+
                'and profile.name != \''+dealerTVEvaluator+'\' and profile.name != \''+driver+'\' and '+
                '( profile.name = \''+hostess+'\' or  profile.name = \''+dse+'\' or  profile.name = \''+tl+'\' or  profile.name = \''+gm+'\' or  profile.name = \''+ceo+'\' or  profile.name = \''+dAU+'\' or  profile.name = \''+dFM+'\')'; 
           
        }else {
            query ='Select id, Profile.Name, Contact.Account.Parent_Group__c, Contact.Account.Dealer_code__c, Contact.Account.FOR_Code__r.For_Code__c, '+
                'UserRole.Name,User_Role_Text__c,Channel__c,Dealer_Channel__c,Dealer_Region__c, ' +                
                'contact.account.Region_code__c From User WHERE isActive= true and  contact.AccountId != null '+
                'and profile.name != \''+dealerTVEvaluator+'\' and profile.name != \''+driver+'\' and '+
                '( profile.name = \''+hostess+'\' or  profile.name = \''+dse+'\' or  profile.name = \''+tl+'\' or  profile.name = \''+gm+'\' or  profile.name = \''+ceo+'\' or  profile.name = \''+dAU+'\' or  profile.name = \''+dFM+'\') limit 100'; 
        }
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<User> scope){
        Set<String> contactIdSet = new Set<String>();
        Set<String> cGroupSet = new Set<String>();
        Set<String> userIdSet = new Set<String>();
        List<Contact> contactList = new List<Contact>();
        List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();        
        List<CollaborationGroupMember> cGroupMemberList = new List<CollaborationGroupMember>();
        Map<String, String> cGroupMap = new Map<String, String>();
        Map<String, String> map1 = new Map<String, String>();
        Map<String, String> map2 = new Map<String, String>();  
        Map<String, Set<String>> map3 = new Map<String, Set<string>>();
        for(User user :scope){
            if(user.contactId != null){
                userIdSet.add(user.Id);
                contactIdSet.add(user.ContactId);
            }
        }
        if(contactIdSet.size() > 0){
            contactList = [SELECT Id, Account.Parent_Group__c, Account.Dealer_code__c, Account.FOR_Code__r.For_Code__c FROM Contact WHERE Id IN :contactIdSet];
            for(Contact contact : contactList){   
                if(contact.Account.Dealer_code__c != null && contact.Account.FOR_Code__r.For_Code__c != null && contact.Account.Parent_Group__c != null){
                    cGroupMap.put(contact.Id, contact.Account.Dealer_code__c +'_'+contact.Account.FOR_Code__r.For_Code__c + '_'+contact.Account.Parent_Group__c+'_'+'sales');
                    cGroupSet.add(contact.Account.Dealer_code__c +'_'+contact.Account.FOR_Code__r.For_Code__c + '_'+contact.Account.Parent_Group__c+'_'+'sales');
                }                
            }
            System.debug('cGroupMap '+cGroupMap);
            System.debug('cGroupSet '+cGroupSet);
            for(CollaborationGroup cGroup : [SELECT Id, Name FROM CollaborationGroup  WHERE Name IN :cGroupSet] ){
                map1.put(cGroup.Name, cGroup.Id);
            }
            System.debug('map1 '+map1);
            Network nk = [select id from Network where Name like 'Dealer%' limit 1];
            
            for(String str : cGroupSet){
                if(!map1.containsKey(str)){                    
                    CollaborationGroup cGroup = new CollaborationGroup();
                    cGroup.NetworkId = nk.Id;
                    cGroup.Name = str;
                    cGroup.CollaborationType = 'Unlisted';
                    cGroupList.add(cGroup);
                }                
            }
            System.debug('## '+cGroupList);
            if(cGroupList.size() > 0){
                System.debug('** inside');
                insert cGroupList;
            }
            for(CollaborationGroup cGroup : [SELECT Id, Name FROM CollaborationGroup  WHERE Name IN :cGroupSet] ){
                map2.put(cGroup.Name, cGroup.Id);
            }
            for(CollaborationGroupMember cgm: [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId IN :userIdSet ]){
                if(map3.containsKey(cgm.CollaborationGroupId)){
                    Set<String> localSet = map3.get(cgm.CollaborationGroupId);
                    localSet.add(cgm.MemberId);
                    map3.put(cgm.CollaborationGroupId, localSet);
                }else {
                    map3.put(cgm.CollaborationGroupId, new Set<String> {cgm.MemberId});
                }
                
            }
            system.debug('## '+ map3);
            for(User user: scope){
                System.debug('cGroupMap '+ cGroupMap.get(user.ContactId));
                System.debug('map2  '+ map2.get(cGroupMap.get(user.ContactId)));
                System.debug('mape contains '+map3.containsKey(map2.get(cGroupMap.get(user.ContactId))));
                System.debug('map3 '+ map3.get(map2.get(cGroupMap.get(user.ContactId))));
                
                System.debug('$$ ');
                if(cGroupMap.containsKey(user.ContactId) && map2.containsKey(cGroupMap.get(user.ContactId))){
                    if((!map3.containsKey(map2.get(cGroupMap.get(user.ContactId))))){                        
                        CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                        cGroupMember.MemberId = user.Id;                        
                        cGroupMember.CollaborationGroupId = map2.get(cGroupMap.get(user.ContactId));
                        cGroupMemberList.add(cGroupMember);                        
                    } else if(map3.containsKey(map2.get(cGroupMap.get(user.ContactId)))){
                        if(!map3.get(map2.get(cGroupMap.get(user.ContactId))).contains(user.Id)){
                            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
                            cGroupMember.MemberId = user.Id;                        
                            cGroupMember.CollaborationGroupId = map2.get(cGroupMap.get(user.ContactId));
                            cGroupMemberList.add(cGroupMember);
                        }
                    }
                }
            }
            System.debug('**** '+cGroupMemberList.size());
            if(cGroupMemberList.size() > 0){                    
                //insertChatterGroupMembersFuture(JSON.serialize(cGroupMemberList));
                System.debug('**** '+cGroupMemberList);
                insert cGroupMemberList;
            }
            
        }
        
        
    }
    global void finish(Database.BatchableContext bc){
        
    }
}