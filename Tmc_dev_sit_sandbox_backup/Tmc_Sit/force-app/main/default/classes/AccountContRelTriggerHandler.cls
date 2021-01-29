/**
* @Autho:- Avaneesh Singh
* @Description-: Handler class for AccountContactRelation Trigger
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.2       09/4/2020     Avaneesh Singh     Intial Version
**/

public class AccountContRelTriggerHandler extends TriggerHandler {


  private Map<Id, AccountContactRelation> newAccConMap ;
  private List<AccountContactRelation> newAccConList ;
  private Map<Id,AccountContactRelation> oldAccConMap ;

  public AccountContRelTriggerHandler() {
      this.newAccConMap = (Map<Id, AccountContactRelation>) Trigger.newMap;
      this.newAccConList = (list<AccountContactRelation>) Trigger.New;
      this.oldAccConMap = (Map<Id,AccountContactRelation>) Trigger.oldMap;

  }

  public override void beforeInsert(){

  }

  public override void afterInsert(){
     System.debug('------------After Insert----------------');
       shareRFCRecord();

  }
   public override void afterUpdate(){
     System.debug('------------After update----------------');
       shareRFCRecord();
  }

  public override void afterDelete(){
    System.debug('---------------After Delete---------------------');
  removeShareRfcRecord();
  }


  /**
      Author: Avaneesh Singh
      Company: Techmatrix
      Description: helper method for the sharing object
      User Story:
      Inputs: Map<Id,Id> conUserGroupMap
      Returns: List<opportunity>
      History:
      ====================================================
      1.2     17 April 2020  Avaneesh Singh RFC Approvals
  **/

  public List<opportunity> getRelateAccountRFC(Map<Id,Id> conUserGroupMap,Map<Id, AccountContactRelation> accMap){
      Map<Id,Id> conAccountMap = new Map<Id,Id>();
      Set<String> rolesAllSet = new Set<String>{
                                              ConstantsUtility.True_Value_Manager,
                                              ConstantsUtility.ACR_FINANCE_MANAGER,
                                              ConstantsUtility.Accounts_Manager,
                                              ConstantsUtility.Allotment_Manager,
                                              ConstantsUtility.QCM,
                      ConstantsUtility.SHOWROOM_MANAGER
                                            };
        List<opportunity> oppInfoList = new  List<opportunity>();
       for(AccountContactRelation accCon : accMap.values()){
         if(accCon.accountId != null && accCon.contactId != null && accCon.roles != null){
            List<String> rolesList = accCon.roles.split(';');
            if(rolesAllSet.containsAll(rolesList)){
               conAccountMap.put(accCon.ContactId,accCon.accountid);
            }
         }
       }
       System.debug('=========conAccountMap ====='+conAccountMap );
       List<User> userinfoList = [select id , accountid,contactid from user where contactId In :conAccountMap.keyset()
                                       and isActive = true];
       if(userinfoList.size() > 0){
         for(user user : userinfoList){
                    conUserGroupMap.put(conAccountMap.get(user.contactid),user.id);
         }

       System.debug('============conUserGroupMap============'+conUserGroupMap);
        oppInfoList = [select id,Dealership__c from opportunity where Dealership__c In :conAccountMap.values()];
       }

       return oppInfoList ;

  }
  /**
      Author: Avaneesh Singh
      Company: Techmatrix
      Description: When an accountContactRelation record is removed the need to remove share with the rfc user record
      User Story:
      Inputs: None
      Returns: void
      History:
      ====================================================
      1.2     17 April 2020  Avaneesh Singh RFC Approvals
  **/
  public void removeShareRfcRecord(){

      Map<Id,Id> oppAccountMap= new Map<Id,Id>();
      Map<Id,Id> conUserGroupMap = new Map<Id,Id>();

         List<opportunity> oppInfoList = getRelateAccountRFC(conUserGroupMap,this.oldAccConMap);
         if(oppInfoList.size() > 0){
            for(opportunity opp : oppInfoList){
              oppAccountMap.put(opp.Id,opp.Dealership__c);
           }
         }

         Map<Id,Rfc__c> rfcRecordMap = new Map<Id,RFC__c>([select id,Enquiry__c  from rfc__c
                                                             where Enquiry__c In:oppAccountMap.keySet()
                                                             and Active__c =True
                              And (rfc_status__c!='alloted' or rfc_status__c!= 'Canceled')]);
         List<RFC__share> rfcShareList = [select id from RFC__Share where ParentID IN :rfcRecordMap.keySet() AND
                                                     UserOrGroupId IN : conUserGroupMap.values() ];
         delete rfcShareList;

  }
   /**
      Author: Avaneesh Singh
      Company: Techmatrix
      Description: When an accountContactRole added share the existing RFC Record with it user
      User Story:
      Inputs: None
      Returns: void
      History:
      ====================================================
      1.2     17 April 2020  Avaneesh Singh RFC Approvals
  **/

  public void shareRFCRecord(){
      Map<Id,Id> oppAccountMap= new Map<Id,Id>();
      Map<Id,List<Id>> conUserGroupMap = new Map<Id,List<Id>>(); // account id and user id as a key
      List<RFC__Share> rfcShareList = new List<RFC__share>();
      List<OpportunityShare> oppShareList = new List<OpportunityShare>();

         List<opportunity> oppInfoList = getRelateOpportunty(conUserGroupMap,this.newAccConMap); // List of opporutnity
         System.debug('==========oppInfoList ============='+oppInfoList );
         if(oppInfoList.size() > 0){
           // share the opportunity with the associated user
            for(opportunity opp : oppInfoList){
              oppAccountMap.put(opp.Id,opp.Dealership__c);

              if(conUserGroupMap.containsKey(opp.Dealership__c)){
                  for(Id userId : conUserGroupMap.get(opp.Dealership__c)){
                    if(opp.OwnerId != userId){
                      OpportunityShare oppShare = new OpportunityShare();
                      oppShare.OpportunityId = opp.id;
                      oppShare.OpportunityAccessLevel = ConstantsUtility.OPPSHARE_CONST;
                      oppShare.UserOrGroupId = userId;
                      oppShareList.add(oppShare);
                    }
                  }
              }
            }

           if(oppShareList.size() >0){
             insert oppShareList;
           }

           System.debug('===='+oppAccountMap);

          for(rfc__c rfc : [select id,OwnerId,Enquiry__c  from rfc__c where Enquiry__c In:oppAccountMap.keySet() and Active__c =True
                              And (rfc_status__c!='alloted' or rfc_status__c!= 'Canceled')]){
                if(oppAccountMap.containsKey(rfc.Enquiry__c)){
                  for(Id userId : conUserGroupMap.get(oppAccountMap.get(rfc.Enquiry__c))){
                    if(rfc.OwnerId != userId){

                      RFC__Share rfcShare = new RFC__Share();
                      rfcShare.ParentID = rfc.id;
                      rfcShare.AccessLevel ='Edit';
                      rfcShare.UserOrGroupId = userId;
                      rfcShareList.add(rfcShare);
                    }
                  }
                }
          }

          System.debug('===================='+rfcShareList);
          if(rfcShareList.size() > 0)
            insert rfcShareList;

       }

  }

  /**
      Author: Saloni Gupta
      Company: Techmatrix
      Description: Get all the related opportunity to the dealer Account which are open
      User Story:
      Inputs: None
      Returns: void
      History:
      ====================================================
      1.0     20 Aug 2020  Saloni Gupta
  **/

  public List<opportunity> getRelateOpportunty(Map<Id,List<Id>> conUserGroupMap,Map<Id, AccountContactRelation> accMap){
      Map<Id,Id> conAccountMap = new Map<Id,Id>();
      Set<String> rolesAllSet = new Set<String>{
                                              ConstantsUtility.True_Value_Manager,
                                              ConstantsUtility.ACR_FINANCE_MANAGER,
                                              ConstantsUtility.Accounts_Manager,
                                              ConstantsUtility.Allotment_Manager,
                                              ConstantsUtility.QCM,
												                      ConstantsUtility.SHOWROOM_MANAGER
                                            };
        List<opportunity> oppInfoList = new  List<opportunity>();
       for(AccountContactRelation accCon : accMap.values()){
         if(accCon.accountId != null && accCon.contactId != null && accCon.roles != null){
            List<String> rolesList = accCon.roles.split(';');
            for(String role :rolesList){
              if(rolesAllSet.contains(role)){
                conAccountMap.put(accCon.ContactId,accCon.accountid);
              }
            }

         }
       }
       System.debug('=========conAccountMap ====='+conAccountMap );
       List<User> userinfoList = [select id , accountid,contactid from user where contactId In :conAccountMap.keyset()
                                       and isActive = true];
       if(userinfoList.size() > 0){
         for(user user : userinfoList){
           if(!(conAccountMap.containsKey(user.contactid) && conUserGroupMap.containsKey(conAccountMap.get(user.contactid)))){
                    conUserGroupMap.put(conAccountMap.get(user.contactid),new List<ID>());

           }
                    conUserGroupMap.get(conAccountMap.get(user.contactid)).add(user.id);
         }
       System.debug('============conUserGroupMap============'+conUserGroupMap);

       String excludeStages = System.Label.Allotmentt_Not_Shared_Opportunity_Stage;
       List<String> excludeStagesList = excludeStages.split(',');
       system.debug('excludeStagesList==='+excludeStagesList);
        oppInfoList = [select id,OwnerId,Dealership__c from opportunity where Dealership__c In :conAccountMap.values() AND StageName Not IN:excludeStagesList];
       }

       return oppInfoList ;

  }
}