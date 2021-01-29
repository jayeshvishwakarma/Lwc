/**
* @Author:- Saloni Gupta
* @Description-: Handler class for Preliminary Checklist Trigger.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       19/5/2020    Saloni Gupta     Intial Version
**/
public without sharing class PreliminaryChecklistTriggerHandler extends TriggerHandler {

    private Map<Id, Preliminary_Checklist__c> newPreCheckMap;
    private List<Preliminary_Checklist__c> newPreCheckList;
    private Map<Id,Preliminary_Checklist__c> oldPreCheckMap;
    private PreliminaryChecklistTriggerHelper pcHelper;

    public PreliminaryChecklistTriggerHandler() {
        this.newPreCheckMap = (Map<Id, Preliminary_Checklist__c>) Trigger.newMap;
        this.newPreCheckList = (list<Preliminary_Checklist__c>) Trigger.New;
        this.oldPreCheckMap = (Map<Id,Preliminary_Checklist__c>) Trigger.oldMap;
        this.pcHelper = new PreliminaryChecklistTriggerHelper();
    }
    public override void afterInsert(){
        sharingChecklistObject();
        sendChatterNotification();
    }

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
    public void sharingChecklistObject(){
        Id loginUser =  userinfo.getUserId();
        Map<Id,Id> oppRelatedAccountIdMap = new Map<Id,Id>(); // opp id with associate rfcShare object here
        Map<Id,Id> accountRelatedRFCShareMap = new Map<Id,Id>();
        Set<Preliminary_Checklist__Share> pcShareTempSet = new Set<Preliminary_Checklist__Share>();



        for(Preliminary_Checklist__c  pcObj : [select id,RFC__c, RFC__r.Enquiry__c from Preliminary_Checklist__c where Id IN: this.newPreCheckList]){
            if(pcObj.RFC__c != null && pcObj.RFC__r.Enquiry__c != null){
                oppRelatedAccountIdMap.put(pcObj.RFC__r.Enquiry__c, pcObj.id);
            }
        }
        if(oppRelatedAccountIdMap.size() > 0){

            Map<Id,Opportunity> oppInfoMap = new Map<Id,Opportunity>([select id,Dealership__c,AccountId from opportunity
                                                                      where id IN : oppRelatedAccountIdMap.keySet()]);

            for(opportunity opp : oppInfoMap.values()){
                if(opp.Dealership__c != null && oppRelatedAccountIdMap.containsKey(opp.id)){
                    accountRelatedRFCShareMap.put(opp.dealership__c,oppRelatedAccountIdMap.get(opp.id));
                }
            }

            pcShareTempSet.addAll(pcHelper.sharingAccountTeamMember(oppInfoMap,oppRelatedAccountIdMap));


            List<AccountContactRelation> accountContactList = [select id , accountid,ContactId from AccountContactRelation
                                                               where accountid In :accountRelatedRFCShareMap.keyset()];

            if(accountContactList.size() > 0){

                Set<Id> contactIdSet = new Set<Id>();

                for(AccountContactRelation accCon : accountContactList){
                    if(accCon.contactid != null){
                        contactIdSet.add(accCon.contactid);
                    }
                }

                for(user user : [select id , contactid,accountid from user where contactid In :contactIdSet
									and isActive = true]){
                    if(accountRelatedRFCShareMap.containsKey(user.accountid) && user.id != loginUser ){
                        pcShareTempSet.add(pcHelper.pcShareObj(accountRelatedRFCShareMap.get(user.accountid),user.id,'Edit'));
                    }
                }
                for(OpportunityTeamMember otm : [select id ,OpportunityId,UserId from OpportunityTeamMember
                                                 where OpportunityId In :oppRelatedAccountIdMap.keySet()]){
                                                     if(oppRelatedAccountIdMap.containsKey(otm.OpportunityId) && otm.userId != loginUser ){
                                                         pcShareTempSet.add(pcHelper.pcShareObj(oppRelatedAccountIdMap.get(otm.OpportunityId),otm.userId,'Edit'));
                                                     }
                                                 }

                if(pcShareTempSet.size() > 0){
                    insert new List<Preliminary_Checklist__Share>(pcShareTempSet);
                }

            }

        }
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: When new Preliminary Checklist created send Chatter Notifications to FM and ACM
        User Story:
        Inputs: None
        Returns: void
        Version   Date            Author      Modification
         ======================================================
        1.0       20/5/2020    Saloni Gupta     Intial Version
    **/
      public void sendChatterNotification(){
        Map<Id,Id> OppTempMap = new Map<Id,Id>();
        List<Preliminary_Checklist__c> pcList = new List<Preliminary_Checklist__c>();
          for(Preliminary_Checklist__c pcObj :  [select id,RFC__c, RFC__r.Enquiry__c from Preliminary_Checklist__c where Id IN: this.newPreCheckList]){
             if(pcObj.RFC__c != null){
                OppTempMap.put(pcObj.id,pcObj.RFC__r.Enquiry__c);
                pcList.add(pcObj);
             }
          }
         if(!pcList.isEmpty()){
            pcHelper.pcChatterNotificationHelper(OppTempMap ,pcList);
         }
      }


}