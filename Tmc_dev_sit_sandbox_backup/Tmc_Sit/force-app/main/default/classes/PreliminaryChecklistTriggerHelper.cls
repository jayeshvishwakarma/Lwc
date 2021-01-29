/**
* @Author:- Saloni Gupta
* @Description-: Helper class for Preliminary Checklist TriggerHandler.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       19/5/2020    Saloni Gupta     Intial Version
**/
public with sharing class PreliminaryChecklistTriggerHelper {

       /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to share Preliminary Checklist record to User after insert trigger
        Inputs: None
        Returns: void
        Version   Date            Author      Modification
         ======================================================
        1.0       19/5/2020    Saloni Gupta     Intial Version
    **/
    public Set<Preliminary_Checklist__Share> sharingAccountTeamMember(Map<Id,Opportunity> oppInfoMap,Map<Id,Id> oppRelatedAccountIdMap){
        Map<Id,Id> accountTeamPCMap = new Map<Id,Id>(); // accountteam with PC record here
        Set<Preliminary_Checklist__Share> pcShareTempSet = new Set<Preliminary_Checklist__Share>();
        List<OpportunityShare> oppShareList = [select id,OpportunityId,OpportunityAccessLevel from opportunityshare
                                               where ( OpportunityAccessLevel ='Edit' Or OpportunityAccessLevel ='Read')
                                               And OpportunityId IN : oppRelatedAccountIdMap.keyset()];
        if(oppShareList.size() > 0){
            for(OpportunityShare opp : oppShareList){
                if(oppInfoMap.containsKey(opp.OpportunityId)){
                    accountTeamPCMap.put(oppInfoMap.get(opp.OpportunityId).accountid,oppRelatedAccountIdMap.get(opp.OpportunityId));
                }
            }
        }


        List<AccountTeamMember> accountTeamMemberList = [select id ,AccountAccessLevel,AccountId,UserId  from AccountTeamMember
                                                         where AccountId In :accountTeamPCMap.keyset()];

        if(accountTeamMemberList.size() > 0){
            for(accountTeamMember atm : accountTeamMemberList ){
                if(accountTeamPCMap.containsKey(atm.accountId) && atm.userId != userInfo.getUserId()){
                    pcShareTempSet.add(pcShareObj(accountTeamPCMap.get(atm.accountId),atm.userId,'Edit'));
                }
            }
        }
        return pcShareTempSet;
    }
    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to genrate Preliminary_Checklist__Share object record
        Inputs: userId or GroupId || pcShare Id || acess level
        Returns: instance of preliminaryChecklistShare object
        Version   Date            Author      Modification
        ======================================================
        1.0       19/5/2020    Saloni Gupta     Intial Version
    **/
    public Preliminary_Checklist__Share pcShareObj(Id ObjId ,Id UserOrGroupId ,String accessLevel){
        Preliminary_Checklist__Share pcShare = new Preliminary_Checklist__Share();
        pcShare.ParentId = ObjId ;
        pcShare.UserOrGroupId = UserOrGroupId;
        pcShare.AccessLevel = accessLevel;
        return pcShare;
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to help the pcchatternotification group of account role to post chatter assoicated user
        User Story:
        Inputs: Set<Id> OppTempSet || List<Preliminary_Checklist__c> newPreCheckList
        Returns:
        Version   Date            Author      Modification
        ======================================================
        1.0       20/5/2020    Saloni Gupta     Intial Version
    **/

        public void pcChatterNotificationHelper(Map<Id,Id> OppTempMap ,List<Preliminary_Checklist__c> newPreCheckList){
            Map<Id,Id> opportunityDealerMap = new Map<Id,Id>();
            Map<Id,String> contactWithRoleMap = new Map<Id,String>();
            Map<Id,List<user>> accWithUserIdMap = new Map<Id,List<User>>();
            Map<id,Opportunity> oppInfoMap = new Map<Id,Opportunity>();
                  getAccountContactDetailHelper(OppTempMap.values(),newPreCheckList,accWithUserIdMap,opportunityDealerMap,contactWithRoleMap,oppInfoMap);
                           Map<Id , Set<Id>> pcRelatedUserMap = new Map<Id,Set<Id>>();
                            for(Preliminary_Checklist__c pcObj : newPreCheckList){
                                if(pcObj.RFC__c != null){
                                   if(opportunityDealerMap.containsKey(pcObj.RFC__r.Enquiry__c) && accWithUserIdMap.containsKey(opportunityDealerMap.get(pcObj.RFC__r.Enquiry__c))){
                                          Set<Id> tempUserId = new Set<Id>();
                                          for(User u : accWithUserIdMap.get(opportunityDealerMap.get(pcObj.RFC__r.Enquiry__c))){
                                             String roles = contactWithRoleMap.get(u.contactid);
                                             
                                              if(roles.contains(ConstantsUtility.ACR_FINANCE_MANAGER)
                                                  || roles.contains(ConstantsUtility.Accounts_Manager)
                                                  || roles.contains(ConstantsUtility.MGA_Manager)
                                                  || roles.contains(ConstantsUtility.PDI_Coordinator)
                                                  || roles.contains(ConstantsUtility.RTO_Coordinator)
                                                  || roles.contains(ConstantsUtility.DC))
                                              {
                                                 tempUserId.add(u.id);
                                              }
                                          }
                                        pcRelatedUserMap.put(pcObj.id,tempUserId);
                                   }
                                }
                            }
                          for(Id ids : pcRelatedUserMap.keySet()){
                                 String oppName = OppTempMap.containsKey(ids) ?  (oppInfoMap.containsKey(OppTempMap.get(ids)) ? oppInfoMap.get(OppTempMap.get(ids)).name : '' ): '';
                                String chatterMessage = ' A Checklist for '+oppName +' has been Submitted for your Approval';
							  if(!test.isRunningTest())
									ChatterNotification.createChatterPostForUsers(pcRelatedUserMap.get(ids),ids,chatterMessage,'');
                          }

     }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to help the pcchatternotification group of account role to post chatter assoicated user
        User Story:
        Inputs: Set<Id> OppTempSet || List<Preliminary_Checklist__c> newPreCheckList
        Returns:
        Version   Date            Author      Modification
        ======================================================
        1.0       20/5/2020    Saloni Gupta     Intial Version
    **/
    public void getAccountContactDetailHelper(List<Id> OppTempSet ,List<Preliminary_Checklist__c> newPreCheckList,
                                                      Map<Id,List<user>> accWithUserIdMap,Map<Id,Id> opportunityDealerMap,
                                                                      Map<Id,String> contactWithRoleMap,
                                                                      Map<id,Opportunity> oppInfoMap){

        if(OppTempSet.size() > 0){
              System.debug('OppTempSet===='+OppTempSet);
              List<Opportunity> oopsList = [select id , Dealership__c,name from opportunity where id In :OppTempSet];
              System.debug('====='+oopsList);
              oppInfoMap.putAll(oopsList);
              for(opportunity opp : oppInfoMap.values() ){
                 if(opp.Dealership__c != null){
                    opportunityDealerMap.put(opp.id ,opp.Dealership__c);
                 }
              }

              if(opportunityDealerMap.size() >0){
                   List<AccountContactRelation> accountContactList = [select id , accountid,ContactId,roles from AccountContactRelation
                                                                      where accountid In :opportunityDealerMap.values() AND roles includes (
                                                                         :ConstantsUtility.ACR_FINANCE_MANAGER,:ConstantsUtility.MGA_Manager,
                                                                            :ConstantsUtility.PDI_Coordinator,:ConstantsUtility.RTO_Coordinator 
                                                                            ,:ConstantsUtility.DC ,:ConstantsUtility.Accounts_Manager)];
                     
                     


                     if(accountContactList.size() > 0){



                            for(AccountContactRelation accCon : accountContactList){
                                if(accCon.contactid != null && !contactWithRoleMap.containsKey(accCon.contactid)){
                                   contactWithRoleMap.put(accCon.contactId,accCon.roles);
                                }
                            }

                            for(user user : [select id , contactid,accountid from user where contactid In :contactWithRoleMap.keySet()
                                                and isActive = true]){
                                if(!accWithUserIdMap.containsKey(user.accountid))
                                accWithUserIdMap.put(user.accountid, new List<User>());
                                accWithUserIdMap.get(user.accountid).add(user);
                            }
                      }
                 }


      }
    }
}