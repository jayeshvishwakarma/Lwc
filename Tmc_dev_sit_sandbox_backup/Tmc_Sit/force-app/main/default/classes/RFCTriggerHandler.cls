/**
* @Autho:- Saloni Gupta
* @Description-: Handler class for RFC Trigger.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       09/4/2020    Saloni Gupta     Intial Version
**/
public without sharing class RFCTriggerHandler extends TriggerHandler {


    private Map<Id, RFC__c> newRFCMap;
    private List<RFC__c> newRFCList;
    private Map<Id,RFC__c> oldRFCMap;
    private RFCTriggerHelper rfcHelper;
    public RFCTriggerHandler() {
        this.newRFCMap = (Map<Id, RFC__c>) Trigger.newMap;
        this.newRFCList = (list<RFC__c>) Trigger.New;
        this.oldRFCMap = (Map<Id,RFC__c>) Trigger.oldMap;
        this.rfcHelper = new RFCTriggerHelper();
    }
    public override void beforeInsert(){
        popolateApproveStatus();
        activeRfcOnEnquiry();
        setActionTime();
    }
    public override void beforeUpdate(){
        System.debug('-------Before Update-------------');
        system.debug('@@@@@@@json'+Json.Serialize(Trigger.New));
        popolateFieldValues();
        deallotedStatus();
        setActionTime();
    }
     public override void afterUpdate() {
        System.debug('---------After Update---------------');
         sendChatterNotificationOnUpdate();
    }

    public override void afterInsert(){
        System.debug('-------AFTER Insert-------------');
        sharingRFCObject();
        sendChatterNotification();
    }

     /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: update json data in last modified details
        User Story:
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.2     26 june 2020  Avaneesh Singh RFC Approvals
    **/


    public void setActionTime(){
       System.debug('========Action Start====');
       OpportunityTriggerHelper oppHelper = new OpportunityTriggerHelper();
       Set<Id> allOpportunitySet = new Set<Id>();

       for(RFC__c rfc : newRFCList){
          allOpportunitySet.add(rfc.Enquiry__c);
       }

       Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select id,DMS_Enquiry_Name__c,Booking_Number__c from opportunity
                                                               where id IN : allOpportunitySet ]);
       for(RFC__c rfc : newRFCList){
         String data = ConstantsUtility.OPEN_CURLY_BRACES;
          // data record here

          if(rfc.Enquiry__c != null){
           data += oppHelper.createKeyValueStructure('DMS Enquiry Number', oppMap.get(rfc.Enquiry__c).DMS_Enquiry_Name__c);
           data += oppHelper.createKeyValueStructure('DMS Booking Number', oppMap.get(rfc.Enquiry__c).Booking_Number__c );
           data += oppHelper.createKeyValueStructure('Enquiry__c',rfc.Enquiry__c);

          }
          if(rfc.RFC_DMS_Number__c != null)
           data += oppHelper.createKeyValueStructure('RFC_DMS_Number__c',rfc.RFC_DMS_Number__c);
           data += oppHelper.createKeyValueStructure('LastModifiedDate',String.valueOf(System.now()));

          if(Trigger.isInsert){
             data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'CreateRFC');
          }

          if(Trigger.IsUpdate){
               data += oppHelper.createKeyValueStructure('LastModifiedById',newRFCMap.get(rfc.id).LastModifiedById);

           // approval action
               if(newRFCMap.get(rfc.id).Allotment_Status__c != oldRFCMap.get(rfc.id).Allotment_Status__c){
               data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'AMAction');

               }else if(newRFCMap.get(rfc.id).SM_Approval_Status__c != oldRFCMap.get(rfc.id).SM_Approval_Status__c){
                data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'SMAction');

               }else if(newRFCMap.get(rfc.id).Accounts_Approval_Status__c != oldRFCMap.get(rfc.id).Accounts_Approval_Status__c){
                data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'ACMAction');

               }else if(newRFCMap.get(rfc.id).True_Value_Approval_Status__c != oldRFCMap.get(rfc.id).True_Value_Approval_Status__c){
                data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'TVMAction');

               }else if(newRFCMap.get(rfc.id).FM_Approval_Status__c != oldRFCMap.get(rfc.id).FM_Approval_Status__c){
                data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'FMAction');
               }

               if(newRFCMap.get(rfc.id).Delivery_Request_Date__c!= oldRFCMap.get(rfc.id).Delivery_Request_Date__c){
                data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'PostponeRFC');
               }
               if(rfc.RFC_Cancellation_Reason__c != null){
                data += oppHelper.createKeyValueStructure(ConstantsUtility.Action,'CancelRFC');
               }

          }
          data = data.removeEnd(ConstantsUtility.COMMA);

          System.debug('=========>>>'+data);
          data+=ConstantsUtility.CLOSE_CURLY_BRACES;
         rfc.Last_Modified_Details__c = data;

       }

    }



    /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: When new rfc updated send Chatter Notifications Matrix: Quip Doc ==> RFC Approvals_14032020
        User Story:
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.2     17 April 2020  Avaneesh Singh RFC Approvals
    **/
      public void sendChatterNotificationOnUpdate(){
         System.debug('---------after update ----------');
        Map<Id,Id> OppTempMap = new Map<Id,Id>();
          for(Rfc__c rfc : newRFCList){
             if(rfc.Enquiry__c != null && ((rfc.RFC_Status__c != this.oldRFCMap.get(rfc.Id).RFC_Status__c) || (rfc.Delivery_Request_Date__c != this.oldRFCMap.get(rfc.Id).Delivery_Request_Date__c))){
                OppTempMap.put(rfc.id,rfc.Enquiry__c);
             }
          }
          System.debug('----------OppTempMap ----------'+OppTempMap);
          if(!OppTempMap.isEmpty()){
             rfcHelper.rfcChatterNotificationUpdate(OppTempMap ,newRFCList,oldRFCMap);
          }
      }


    /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: When new rfc created send Chatter Notifications Matrix: Quip Doc ==> RFC Approvals_14032020
        User Story:
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.2     12 April 2020  Avaneesh Singh RFC Approvals
    **/
      public void sendChatterNotification(){
        Map<Id,Id> OppTempMap = new Map<Id,Id>();
          for(Rfc__c rfc : newRFCList){
             if(rfc.RFC_Status__c != null && rfc.Enquiry__c != null){
                OppTempMap.put(rfc.id,rfc.Enquiry__c);
             }
          }

         rfcHelper.rfcChatterNotificationHelper(OppTempMap ,newRFCList);
      }


    /**
         Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to Pre-Populate Field Values on before update
        User Story: Maruti 1.2 Vehicle Allotment and De-Allotment
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     16 April 2020  Saloni Gupta  Initial Version
     **/
    public void popolateFieldValues(){
        Set<Id> oppIdSet = new Set<Id>();
        for (RFC__c rfcObj : this.newRFCList){
            if(rfc__c.enquiry__c != null){
              oppIdSet.add(rfcObj.Enquiry__c);
            }
            System.debug('old----'+oldRFCMap.get(rfcObj.Id).FM_Approval_Status__c );
            System.debug('new----'+rfcObj.FM_Approval_Status__c );

            if((oldRFCMap.get(rfcObj.Id).FM_Approval_Status__c != ConstantsUtility.STATUS_APPROVED && rfcObj.FM_Approval_Status__c == ConstantsUtility.STATUS_APPROVED)||
            (oldRFCMap.get(rfcObj.Id).FM_Approval_Status__c != ConstantsUtility.STATUS_REJECTED && rfcObj.FM_Approval_Status__c == ConstantsUtility.STATUS_REJECTED)){
                if(rfcObj.Exchange__c == ConstantsUtility.YES)
                rfcObj.True_Value_Approval_Status__c = ConstantsUtility.STATUS_PENDING;
                if(rfcObj.True_Value_Approval_Status__c == ConstantsUtility.STATUS_PENDING){
                    rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_TVM;
                    rfcObj.True_Value_Assigned_Date__c = System.now();
                }else{
                    rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_ACM;
                    rfcObj.Accounts_Assigned_Date__c = System.now();
                }

            }else if((oldRFCMap.get(rfcObj.Id).True_Value_Approval_Status__c != ConstantsUtility.STATUS_APPROVED && rfcObj.True_Value_Approval_Status__c == ConstantsUtility.STATUS_APPROVED)||
            (oldRFCMap.get(rfcObj.Id).True_Value_Approval_Status__c != ConstantsUtility.STATUS_REJECTED && rfcObj.True_Value_Approval_Status__c == ConstantsUtility.STATUS_REJECTED)){
                rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_ACM;
                rfcObj.Accounts_Assigned_Date__c = System.now();
                rfcObj.Accounts_Approval_Status__c = ConstantsUtility.STATUS_PENDING;

            }else if((oldRFCMap.get(rfcObj.Id).Accounts_Approval_Status__c != ConstantsUtility.STATUS_APPROVED && rfcObj.Accounts_Approval_Status__c == ConstantsUtility.STATUS_APPROVED)||
            (oldRFCMap.get(rfcObj.Id).Accounts_Approval_Status__c != ConstantsUtility.STATUS_REJECTED && rfcObj.Accounts_Approval_Status__c == ConstantsUtility.STATUS_REJECTED)){
                rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_SM;
                rfcObj.SM_Assigned_Date__c = System.now();
                rfcObj.SM_Approval_Status__c = ConstantsUtility.STATUS_PENDING;

            }else if(oldRFCMap.get(rfcObj.Id).SM_Approval_Status__c != ConstantsUtility.STATUS_APPROVED && rfcObj.SM_Approval_Status__c == ConstantsUtility.STATUS_APPROVED){
                rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_Allotment_Manager;
                rfcObj.Allotment_Manager_Assigned_Date__c = System.now();
                rfcObj.Allotment_Status__c = ConstantsUtility.STATUS_PENDING;

            }else if(oldRFCMap.get(rfcObj.Id).SM_Approval_Status__c != ConstantsUtility.STATUS_REJECTED && rfcObj.SM_Approval_Status__c == ConstantsUtility.STATUS_REJECTED){
                rfcObj.RFC_Status__c = ConstantsUtility.Rejected_by_SM;
                rfcObj.Active__c = false;
            }
        }

         Map<Id,Opportunity> oppMap = new Map<Id,opportunity>([select id ,Exchange_Offered_Price__c,VIN__c,Vehicle_Status__c,name,Expected_Price__c,Buying_Price__c,Amount_Received__c,Ex_Showroom_Price__c ,Old_Car_Model__c
        ,Old_Car_Variant__c from opportunity where id in : oppIdSet]);
        for (RFC__c rfcObj : this.newRFCList){
          if(rfc__c.enquiry__c != null){
           rfcObj.Ex_Showroom_Price__c = oppMap.get(rfcObj.enquiry__c).Ex_Showroom_Price__c ;
           //rfcObj.Amount_Received__c  = oppMap.get(rfcObj.enquiry__c).Amount_Received__c;
           rfcObj.Old_Car_Model__c = oppMap.get(rfcObj.enquiry__c).Old_Car_Model__c ;
           rfcObj.Old_Car_Variant__c= oppMap.get(rfcObj.enquiry__c).Old_Car_Variant__c;
           rfcObj.Buying_Price__c= oppMap.get(rfcObj.enquiry__c).Buying_Price__c;
           rfcObj.Offered_Price__c= oppMap.get(rfcObj.enquiry__c).Exchange_Offered_Price__c;
           rfcObj.VIN_Number__c= oppMap.get(rfcObj.enquiry__c).VIN__c;
           rfcObj.Vehicle_Status__c = oppMap.get(rfcObj.enquiry__c).Vehicle_Status__c;
          if(rfcObj.Vehicle_Receiving_Date__c == null && oppMap.get(rfcObj.enquiry__c).VIN__c != null)
           rfcObj.Vehicle_Receiving_Date__c = system.now();
          }
        }
    }
    /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: Method to share RFC record to User after insert trigger
        User Story:
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.2     14 April 2020  Avaneesh Singh  Initial Version
    **/

    public Set<Rfc__share> sharingAccountTeamMember(Map<Id,Opportunity> oppInfoMap,Map<Id,Id> oppRelatedAccountIdMap){
        Map<Id,Id> accountTeamRFCMap = new Map<Id,Id>(); // accountteam with rfc record here
        Set<Rfc__share> rfcShareTempSet = new Set<Rfc__share>();
        List<OpportunityShare> oppShareList = [select id,OpportunityId,OpportunityAccessLevel from opportunityshare
                                               where ( OpportunityAccessLevel ='Edit' Or OpportunityAccessLevel ='Read')
                                               And OpportunityId IN : oppRelatedAccountIdMap.keyset()];
        if(oppShareList.size() > 0){
            for(OpportunityShare opp : oppShareList){
                if(oppInfoMap.containsKey(opp.OpportunityId)){
                    accountTeamRFCMap.put(oppInfoMap.get(opp.OpportunityId).accountid,oppRelatedAccountIdMap.get(opp.OpportunityId));
                }
            }
        }


        List<AccountTeamMember> accountTeamMemberList = [select id ,AccountAccessLevel,AccountId,UserId  from AccountTeamMember
                                                         where AccountId In :accountTeamRFCMap.keyset()];

        if(accountTeamMemberList.size() > 0){
            for(accountTeamMember atm : accountTeamMemberList ){
                if(accountTeamRFCMap.containsKey(atm.accountId) && atm.userId != userInfo.getUserId()){
                    rfcShareTempSet.add(rfcHelper.rfcShareObj(accountTeamRFCMap.get(atm.accountId),atm.userId,'Edit'));
                }
            }
        }
        return rfcShareTempSet;
    }


    public void sharingRFCObject(){
        Id loginUser =  userinfo.getUserId();
        Map<Id,Id> oppRelatedAccountIdMap = new Map<Id,Id>(); // opp id with associate rfcShare object here
        Map<Id,Id> accountRelatedRFCShareMap = new Map<Id,Id>();
        Set<RFC__Share> rfcShareTempSet = new Set<RFC__Share>();

        for(RFC__c  rfcObj : this.newRFCList){
            if(rfcObj.Enquiry__c != null){
                oppRelatedAccountIdMap.put(rfcObj.Enquiry__c, rfcObj.id);
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

            rfcShareTempSet.addAll(sharingAccountTeamMember(oppInfoMap,oppRelatedAccountIdMap));


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
                        rfcShareTempSet.add(rfcHelper.rfcShareObj(accountRelatedRFCShareMap.get(user.accountid),user.id,'Edit'));
                    }
                }
                for(OpportunityTeamMember otm : [select id ,OpportunityId,UserId from OpportunityTeamMember
                                                 where OpportunityId In :oppRelatedAccountIdMap.keySet()]){
                                                     if(oppRelatedAccountIdMap.containsKey(otm.OpportunityId) && otm.userId != loginUser ){
                                                         rfcShareTempSet.add(rfcHelper.rfcShareObj(oppRelatedAccountIdMap.get(otm.OpportunityId),otm.userId,'Edit'));
                                                     }
                                                 }

                if(rfcShareTempSet.size() > 0){
                    insert new List<RFC__Share>(rfcShareTempSet);
                }

            }

        }
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to Pre-Populate FM & True Value Approval Status based on Payment and exchange
        User Story: US:792 Maruti 1.2 Vehicle Allotment and De-Allotment
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     09 April 2020  Saloni Gupta  Initial Version
    **/

    public void popolateApproveStatus(){
        for (RFC__c rfcObj : this.newRFCList){
            if (rfcObj.Payment__c != null && (rfcObj.Payment__c == ConstantsUtility.Payment_DealerFinance)){
                rfcObj.FM_Approval_Status__c = ConstantsUtility.STATUS_PENDING;
                rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_FM;
                rfcObj.Finance_Assigned_Date__c = System.now();
            } else if (rfcObj.Exchange__c != null && (rfcObj.Exchange__c == ConstantsUtility.YES)){
                rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_TVM;
                rfcObj.True_Value_Assigned_Date__c = System.now();
            }else{
                rfcObj.Accounts_Approval_Status__c = ConstantsUtility.STATUS_PENDING;
                rfcObj.RFC_Status__c = ConstantsUtility.Pending_with_ACM;
                rfcObj.Accounts_Assigned_Date__c = System.now();
            }
            if (rfcObj.Exchange__c != null && (rfcObj.Exchange__c == ConstantsUtility.YES) && (rfcObj.Payment__c != ConstantsUtility.Payment_DealerFinance)){
                rfcObj.True_Value_Approval_Status__c = ConstantsUtility.STATUS_PENDING;
            }
        }
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to Show Error If related Opportunity has any active RFC
        User Story: US:792 Maruti 1.2 Vehicle Allotment and De-Allotment
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     09 April 2020  Saloni Gupta  Initial Version
    **/

    public void activeRfcOnEnquiry(){
        Map<Id,List<RFC__c>> oppIdVsRfcList = new Map<Id,List<RFC__c>>();
        Set<Id> oppIdList = new Set<ID>();
        for(RFC__c rfcObj :this.newRFCList){
            oppIdList.add(rfcObj.Enquiry__c);
            if(!oppIdVsRfcList.containsKey(rfcObj.Enquiry__c)){
                oppIdVsRfcList.put(rfcObj.Enquiry__c,new List<RFC__c>());
            }
            oppIdVsRfcList.get(rfcObj.Enquiry__c).add(rfcObj);
        }
        for(Opportunity opp : [select Id,(select Id, Active__c from RFCs__r where Active__c = true) from Opportunity where Id IN:oppIdList]){
            if(opp.RFCs__r.size() > 0){
                oppIdVsRfcList.get(opp.Id)[0].addError(ConstantsUtility.RFC_Create_Error_Msg);
            }
        }
    }

     /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: If allotment status alloted and now vin remove then status dealloted
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     22 May 2020  Saloni Gupta  Initial Version
    **/

    public void deallotedStatus(){
        for(RFC__c rfcObj : newRFCList){
            if(rfcObj.Allotment_Status__c == ConstantsUtility.Allotted && rfcObj.VIN_Number__c == null && oldRFCMap.get(rfcObj.Id).VIN_Number__c != null){
                rfcObj.Allotment_Status__c = ConstantsUtility.DeAllotted;
                rfcObj.RFC_Status__c = ConstantsUtility.DeAllotted;
            }
        }
    }

}