global class UpdateTeamMemberBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, UserId__c, HierarchyUser__c FROM UpdateTeamMember__c]);
    }
    global void execute(Database.BatchableContext bc, List<UpdateTeamMember__c> listOfUpdateTeamMember){
        List<String> listOfUserIds = new List<String>();
        List<String> listOfHierarchyUserIds = new List<String>();
        if(listOfUpdateTeamMember != null && listOfUpdateTeamMember.size() > 0){
            for(UpdateTeamMember__c objUTM : listOfUpdateTeamMember){
                listOfUserIds.add(objUTM.UserId__c);
                listOfHierarchyUserIds.add(objUTM.HierarchyUser__c);
            }
            if(listOfUserIds != null && listOfUserIds.size() > 0 && listOfHierarchyUserIds != null && listOfHierarchyUserIds.size() > 0){
                UpdateTeamMember(listOfUserIds, listOfHierarchyUserIds);
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }  

    public void UpdateTeamMember(List<String> listOfUserIds, List<String> listOfHierarchyUserIds){
        Map<String, List<String>> mapOfTeamLead = new Map<String, List<String>>();
        for(Integer i=0; i<listOfUserIds.size(); i++){
            if(!mapOfTeamLead.containsKey(listOfUserIds[i])){
                mapOfTeamLead.put(listOfUserIds[i], new List<String>{listOfHierarchyUserIds[i]});
            }else{            
                List<String> listOfTemp = mapOfTeamLead.get(listOfUserIds[i]);
                listOfTemp.add(listOfHierarchyUserIds[i]);
                mapOfTeamLead.put(listOfUserIds[i], listOfTemp);
            }
        }       
        Map<String, Account> mapOfAccount = new Map<String, Account>();
        System.debug('@@## mapOfTeamLead size '+mapOfTeamLead.size());
        System.debug('@@## mapOfTeamLead values '+mapOfTeamLead.values().size());
        
        if(mapOfTeamLead != null && mapOfTeamLead.size() > 0){
            For(Account objAcc : [Select Id, User__c, User__r.Profile.Name, (SELECT Id, UserId, User.Profile.Name, AccountId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel FROM AccountTeamMembers) from Account where user__c IN : mapOfTeamLead.keySet()]){
                mapOfAccount.put(objAcc.User__c, objAcc);
            }
            System.debug('@@## mapOfAccount size '+mapOfAccount.size());
            if(mapOfAccount != null && mapOfAccount.size() > 0){
                List<AccountTeamMember> listOfNewAccountTeamMember = new List<AccountTeamMember>();
                for(String userId : mapOfTeamLead.keySet()){
                    List<String> listOfNewHierarchyUser = mapOfTeamLead.get(userId);
                    Map<String, User> mapOfUsers = getUserInfo(listOfNewHierarchyUser);
                        
                    // If Account Team Exist.
                    Map<String, AccountTeamMember> mapOfExistingHierarchyUser = new Map<String, AccountTeamMember>();
                    if(mapOfAccount.containsKey(userId) && mapOfAccount.get(userId).AccountTeamMembers != null && mapOfAccount.get(userId).AccountTeamMembers.size() > 0){   
                        System.debug('@@## mapOfAccount.get(userId).AccountTeamMembers size '+mapOfAccount.get(userId).AccountTeamMembers.size());                     
                        for(AccountTeamMember objATM : mapOfAccount.get(userId).AccountTeamMembers){
                            mapOfExistingHierarchyUser.put(objATM.UserId, objATM);
                        }
                        System.debug('@@## listOfNewHierarchyUser size '+listOfNewHierarchyUser.size());
                        if(listOfNewHierarchyUser != null && listOfNewHierarchyUser.size() > 0){
                            for(String objNewUser : listOfNewHierarchyUser){
                                if(!mapOfExistingHierarchyUser.containsKey(objNewUser)){
                                    AccountTeamMember objTeam = new AccountTeamMember();
                                    objTeam.UserId = objNewUser;
                                    objTeam.AccountId = mapOfAccount.get(userId).Id;
                                    if(mapOfUsers.containsKey(objNewUser)){
                                        if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer CEO/Owner'){
                                            objTeam.OpportunityAccessLevel = 'Read';
                                            objTeam.TeamMemberRole = 'CEO';
                                        }else{
                                            objTeam.OpportunityAccessLevel = 'Edit';
                                        }
                                        if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer GM'){
                                            objTeam.TeamMemberRole = 'GM';
                                        }
                                        if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer Team Leads/Managers'){
                                            objTeam.TeamMemberRole = 'TL';
                                        }
                                        if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer Hostess'){
                                            objTeam.TeamMemberRole = 'Dealer Hostess';
                                        }
                                        if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer Finance Manager'){
                                            objTeam.TeamMemberRole = 'Finance Manager';
                                        }
                                    }
                                    objTeam.AccountAccessLevel = 'Read';
                                    objTeam.CaseAccessLevel = 'Read';
                                    objTeam.ContactAccessLevel = 'Read';
                                    listOfNewAccountTeamMember.add(objTeam);
                                }
                            }
                            system.debug('@@## listOfNewAccountTeamMember '+listOfNewAccountTeamMember);
                        }
                    }else{
                        // If Account Team Does not Exist.
                        if(listOfNewHierarchyUser != null && listOfNewHierarchyUser.size() > 0){
                            for(String objNewUser : listOfNewHierarchyUser){
                                AccountTeamMember objTeam = new AccountTeamMember();
                                objTeam.UserId = objNewUser;
                                objTeam.AccountId = mapOfAccount.get(userId).Id;
                                if(mapOfUsers.containsKey(objNewUser)){
                                    if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer CEO/Owner'){
                                        objTeam.OpportunityAccessLevel = 'Read';
                                        objTeam.TeamMemberRole = 'CEO';
                                    }else{
                                        objTeam.OpportunityAccessLevel = 'Edit';
                                    }
                                    if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer GM'){
                                        objTeam.TeamMemberRole = 'GM';
                                    }
                                    if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer Team Leads/Managers'){
                                        objTeam.TeamMemberRole = 'TL';
                                    }
                                    if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer Hostess'){
                                        objTeam.TeamMemberRole = 'Dealer Hostess';
                                    }
                                    if(mapOfUsers.get(objNewUser).Profile.Name == 'Dealer Finance Manager'){
                                        objTeam.TeamMemberRole = 'Finance Manager';
                                    }
                                }
                                objTeam.AccountAccessLevel = 'Read';
                                objTeam.CaseAccessLevel = 'Read';
                                objTeam.ContactAccessLevel = 'Read';
                                listOfNewAccountTeamMember.add(objTeam);
                            }
                            system.debug('@@## listOfNewAccountTeamMember '+listOfNewAccountTeamMember);
                        }
                    }                    
                }
                if(listOfNewAccountTeamMember != null && listOfNewAccountTeamMember.size() > 0)
                    Database.Insert(listOfNewAccountTeamMember, false);
            }
        }
    }
    public Map<String, User> getUserInfo(List<String> listOfUser){
        Map<String, User> mapOfUsers = new Map<String, User>();
        for(User objUser : [SELECT Id, Name, Profile.Name from User where Id IN : listOfUser]){
            mapOfUsers.put(objUser.Id, objUser);
        }
        return mapOfUsers ;
    }
    public List<String> getValueAsList(String strValue){
        List<String> listValue = strValue.split(',');
        return listValue ;
    }
}