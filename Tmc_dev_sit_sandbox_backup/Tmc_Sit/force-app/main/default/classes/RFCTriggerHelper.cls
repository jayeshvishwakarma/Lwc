/**
* @Autho:- Avaneesh Singh
* @Description-: Helper class for RFC Trigger.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       14/4/2020      Avaneesh Singh     Intial Version
**/
public without sharing class RFCTriggerHelper{

    /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: Method to genrate rfcshare object record
        User Story:
        Inputs: userId or GroupId || rfcShare Id || acess level
        Returns: instance of rfcshare object
        History:
        ====================================================
        1.2     14 April 2020  Avaneesh Singh  Initial Version
    **/

        public Rfc__Share rfcShareObj(Id ObjId ,Id UserOrGroupId ,String accessLevel){
            Rfc__share rfc = new Rfc__share();
            rfc.ParentId = ObjId ;
            rfc.UserOrGroupId = UserOrGroupId;
            rfc.AccessLevel = accessLevel;
            return rfc;
        }

      /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: Method to help the rfcchatternotification group of account role to post chatter assoicated user
        User Story:
        Inputs: Set<Id> OppTempSet || List<RFC__c> newRFCList
        Returns:
        History:
        ====================================================
        1.2     17 April 2020  Avaneesh Singh  Initial Version
    **/
      public void getAccountContactDetailHelper(List<Id> OppTempSet ,List<RFC__c> newRFCList,
                                                      Map<Id,List<user>> accWithUserIdMap,Map<Id,Id> opportunityDealerMap,
                                                                      Map<Id,String> contactWithRoleMap,
                                                                      Map<id,Opportunity> oppInfoMap){

         if(OppTempSet.size() > 0){
              System.debug('OppTempSet===='+OppTempSet);
              List<Opportunity> oopsList = [select id , Dealership__c,Dealership__r.Outlet_Code__c, name,DMS_Enquiry_Name__c,Booking_Number__c,SVOC_Customer_Name__c from opportunity where id In :OppTempSet];
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
                                                                         :ConstantsUtility.ACR_FINANCE_MANAGER,:ConstantsUtility.True_Value_Manager,
                                                                            :ConstantsUtility.Accounts_Manager,:ConstantsUtility.QCM
                                                                            ,:ConstantsUtility.SHOWROOM_MANAGER,:ConstantsUtility.Allotment_Manager )];

                     if(accountContactList.size() > 0){

                            System.debug('==============accountContactList=============='+accountContactList);

                            for(AccountContactRelation accCon : accountContactList){
                                if(accCon.contactid != null && !contactWithRoleMap.containsKey(accCon.contactid)){
                                   contactWithRoleMap.put(accCon.contactId,accCon.roles);
                                }
                            }
                             System.debug('==============contactWithRoleMap=============='+contactWithRoleMap);

                            for(user user : [select id , contactid,accountid from user where contactid In :contactWithRoleMap.keySet()
                                                and isActive = true]){
                                if(!accWithUserIdMap.containsKey(user.accountid))
                                accWithUserIdMap.put(user.accountid, new List<User>());
                                accWithUserIdMap.get(user.accountid).add(user);
                            }
                             System.debug('==============accWithUserIdMap=============='+accWithUserIdMap);

                      }
                 }


      }
     }

     /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: Method to help the rfcchatternotification group of account role to post chatter assoicated user
        User Story:
        Inputs: Set<Id> OppTempSet || List<RFC__c> newRFCList
        Returns:
        History:
        ====================================================
        1.2     17 April 2020  Avaneesh Singh  Initial Version
    **/

        public void rfcChatterNotificationHelper(Map<Id,Id> OppTempMap ,List<RFC__c> newRFCList){
            Map<Id,Id> opportunityDealerMap = new Map<Id,Id>();
            Map<Id,String> contactWithRoleMap = new Map<Id,String>();
            Map<Id,List<user>> accWithUserIdMap = new Map<Id,List<User>>();
            Map<id,Opportunity> oppInfoMap = new Map<Id,Opportunity>();
                  getAccountContactDetailHelper(OppTempMap.values(),newRFCList,accWithUserIdMap,opportunityDealerMap,contactWithRoleMap,oppInfoMap);
                           Map<Id , Set<Id>> rfcRelatedUserMap = new Map<Id,Set<Id>>();
                           Map<Id,String> rfcIdVsName = new Map<Id,String>();
                            for(Rfc__c rfc : newRFCList){
                                System.debug('=================='+rfc);
                                rfcIdVsName.put(rfc.Id,rfc.Name);
                                if(rfc.RFC_Status__c != null && rfc.Enquiry__c != null){
                                   if(opportunityDealerMap.containsKey(rfc.Enquiry__c) && accWithUserIdMap.containsKey(opportunityDealerMap.get(rfc.Enquiry__c))){
                                          Set<Id> tempUserId = new Set<Id>();
                                          for(User u : accWithUserIdMap.get(opportunityDealerMap.get(rfc.Enquiry__c))){
                                             System.debug('================'+u);
                                             String roles = contactWithRoleMap.get(u.contactid);
                                              if(rfc.RFC_Status__c=='Pending with FM' && (roles.contains(ConstantsUtility.ACR_FINANCE_MANAGER)
                                                                      || roles.contains(ConstantsUtility.QCM))){
                                                 tempUserId.add(u.id);
                                              }else if(rfc.RFC_Status__c=='Pending with TVM' && (roles.contains(ConstantsUtility.True_Value_Manager)
                                                                      || roles.contains(ConstantsUtility.QCM))){
                                                 tempUserId.add(u.id);
                                              }else if(rfc.RFC_Status__c=='Pending with ACM' && (roles.contains(ConstantsUtility.Accounts_Manager)
                                                                      || roles.contains(ConstantsUtility.QCM))){
                                                 tempUserId.add(u.id);
                                              }
                                          }
                                        rfcRelatedUserMap.put(rfc.id,tempUserId);
                                   }
                                }
                            }
                            System.debug('=========================='+rfcRelatedUserMap);
                          for(Id ids : rfcRelatedUserMap.keySet()){
                                String oppName = OppTempMap.containsKey(ids) ?  (oppInfoMap.containsKey(OppTempMap.get(ids)) ? oppInfoMap.get(OppTempMap.get(ids)).name : '' ): '';
                                String oppEnqNumber = OppTempMap.containsKey(ids) ?  (oppInfoMap.containsKey(OppTempMap.get(ids)) ? (oppInfoMap.get(OppTempMap.get(ids)).DMS_Enquiry_Name__c != null ? oppInfoMap.get(OppTempMap.get(ids)).DMS_Enquiry_Name__c : '' ):''): '';
                                String oppBookingNumber = OppTempMap.containsKey(ids) ?  (oppInfoMap.containsKey(OppTempMap.get(ids)) ? (oppInfoMap.get(OppTempMap.get(ids)).Booking_Number__c != null ? oppInfoMap.get(OppTempMap.get(ids)).Booking_Number__c : '' ):''): '';
                                String oppCustName = OppTempMap.containsKey(ids) ?  (oppInfoMap.containsKey(OppTempMap.get(ids)) ?( oppInfoMap.get(OppTempMap.get(ids)).SVOC_Customer_Name__c!= null ? oppInfoMap.get(OppTempMap.get(ids)).SVOC_Customer_Name__c : '' ) :''): '';
                                String oppDealerOutletCode = OppTempMap.containsKey(ids) ?  (oppInfoMap.containsKey(OppTempMap.get(ids)) ? (oppInfoMap.get(OppTempMap.get(ids)).Dealership__c != null ? oppInfoMap.get(OppTempMap.get(ids)).Dealership__r.Outlet_Code__c : '' ): '' ):'';
                                String otherInfoMsg = 'Enquiry Number: '+oppEnqNumber +', ' +
                                                                'Booking Number: ' +oppBookingNumber +', '+
                                                                'Customer Name: ' +oppCustName +', '+
                                                                'Outlet Code: ' +oppDealerOutletCode;
                                 String chatterMessage = ' A '+ rfcIdVsName.get(ids) +' for '+oppName +' has been Submitted for your Approval. '+otherInfoMsg;
							  if(!test.isRunningTest())
								ChatterNotification.createChatterPostForUsers(rfcRelatedUserMap.get(ids),ids,chatterMessage,'');
                          }

        }
        /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: Method to help the rfcchatternotification group of account role to post chatter assoicated user
        User Story:
        Inputs: Set<Id> OppTempSet || List<RFC__c> newRFCList
        Returns:
        History:
        ====================================================
        1.2     17 April 2020  Avaneesh Singh  Initial Version
        1.3     02 Sep 2020    Saloni Gupta    Fix the chatter Notification conditions
    **/
       public void rfcChatterNotificationUpdate(Map<Id,Id> OppTempMap ,List<RFC__c> newRFCList, Map<Id,RFC__c> oldRFCMap){

            Map<Id,Id> opportunityDealerMap = new Map<Id,Id>();
            Map<Id,String> contactWithRoleMap = new Map<Id,String>();
            Map<Id,List<user>> accWithUserIdMap = new Map<Id,List<User>>();
            Map<id,Opportunity> oppInfoMap = new Map<Id,opportunity>();
            Map<Id,String> rfcMapWithRoleChatterMap = new Map<Id,String>();

            System.debug('============rfcChatterNotificationUpdate method==');

            getAccountContactDetailHelper(OppTempMap.values(),newRFCList,accWithUserIdMap,opportunityDealerMap,contactWithRoleMap,oppInfoMap);
                         Map<String,Set<Id>> messageWithUserSetMap = new Map<String,Set<Id>>();

                         System.debug('==========OppTempMap========='+OppTempMap);
                         System.debug('==========accWithUserIdMap========='+accWithUserIdMap);
                         System.debug('==========opportunityDealerMap========='+opportunityDealerMap);
                         System.debug('==========contactWithRoleMap========='+contactWithRoleMap);
                          System.debug('==========oppInfoMap========='+oppInfoMap);


                            for(Rfc__c rfc : newRFCList){
                              System.debug('=======rfc========'+rfc);
                                if(rfc.Enquiry__c != null){

                                     if(opportunityDealerMap.containsKey(rfc.Enquiry__c) && accWithUserIdMap.containsKey(opportunityDealerMap.get(rfc.Enquiry__c))){

                                          String oppName = OppTempMap.containsKey(rfc.id) ?  (oppInfoMap.containsKey(OppTempMap.get(rfc.id)) ? oppInfoMap.get(OppTempMap.get(rfc.id)).name : '' ): '';
                                          String oppEnqNumber = OppTempMap.containsKey(rfc.id) ?  (oppInfoMap.containsKey(OppTempMap.get(rfc.id)) ? (oppInfoMap.get(OppTempMap.get(rfc.id)).DMS_Enquiry_Name__c != null ? oppInfoMap.get(OppTempMap.get(rfc.id)).DMS_Enquiry_Name__c : '' ):''): '';
                                          String oppBookingNumber = OppTempMap.containsKey(rfc.id) ?  (oppInfoMap.containsKey(OppTempMap.get(rfc.id)) ? (oppInfoMap.get(OppTempMap.get(rfc.id)).Booking_Number__c != null ? oppInfoMap.get(OppTempMap.get(rfc.id)).Booking_Number__c : '' ):''): '';
                                          String oppCustName = OppTempMap.containsKey(rfc.id) ?  (oppInfoMap.containsKey(OppTempMap.get(rfc.id)) ?( oppInfoMap.get(OppTempMap.get(rfc.id)).SVOC_Customer_Name__c!= null ? oppInfoMap.get(OppTempMap.get(rfc.id)).SVOC_Customer_Name__c : '' ) :''): '';
                                          String oppDealerOutletCode = OppTempMap.containsKey(rfc.id) ?  (oppInfoMap.containsKey(OppTempMap.get(rfc.id)) ? (oppInfoMap.get(OppTempMap.get(rfc.id)).Dealership__c != null ? oppInfoMap.get(OppTempMap.get(rfc.id)).Dealership__r.Outlet_Code__c : '' ): '' ):'';
                                          String otherInfoMsg = 'Enquiry Number: '+oppEnqNumber +', ' +
                                                                         'Booking Number: ' +oppBookingNumber +', '+
                                                                         'Customer Name: ' +oppCustName +', '+
                                                                         'Outlet Code: ' +oppDealerOutletCode;
                                          for(User u : accWithUserIdMap.get(opportunityDealerMap.get(rfc.Enquiry__c))){
                                             System.debug('==========user=========='+u);
                                             List<String> roles = contactWithRoleMap.containsKey(u.contactid) ? contactWithRoleMap.get(u.contactid).split(';') : new List<String>();
                                              System.debug('********************'+roles);
                                              if(rfc.RFC_Status__c!= null){
                                                if( rfc.RFC_Status__c == ConstantsUtility.RFC_Canceled){
                                                  String chatterMessage = 'The '+ rfc.Name + ' has been Canceled for '+ oppName+'. '+ otherInfoMsg+ '#'+rfc.id;

                                                  if(roles.contains(ConstantsUtility.SHOWROOM_MANAGER) || roles.contains(ConstantsUtility.QCM)){
                                                    if(!messageWithUserSetMap.containsKey(chatterMessage))
                                                      messageWithUserSetMap.put(chatterMessage,new Set<Id>());
                                                    messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                  }
                                                }
                                                else if(rfc.RFC_Status__c == ConstantsUtility.Pending_with_FM ||
                                                          rfc.RFC_Status__c == ConstantsUtility.Pending_with_TVM ||
                                                          rfc.RFC_Status__c == ConstantsUtility.Pending_with_ACM ||
                                                          rfc.RFC_Status__c == ConstantsUtility.Pending_with_SM ||
                                                          rfc.RFC_Status__c == ConstantsUtility.Pending_with_Allotment_Manager ){

                                                  String chatterMessage ='A '+ rfc.Name + ' for '+ oppName +' has been submitted for your approval. '+ otherInfoMsg +'#'+rfc.id;
                                                  if(!messageWithUserSetMap.containsKey(chatterMessage))
                                                    messageWithUserSetMap.put(chatterMessage,new Set<Id>());
                                                  if( rfc.RFC_Status__c == ConstantsUtility.Pending_with_FM){
                                                      if(roles.contains(ConstantsUtility.ACR_FINANCE_MANAGER)){
                                                        messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                      }
                                                  }else if( rfc.RFC_Status__c == ConstantsUtility.Pending_with_TVM){
                                                      if(roles.contains(ConstantsUtility.True_Value_Manager)){
                                                        messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                      }
                                                  }else if( rfc.RFC_Status__c == ConstantsUtility.Pending_with_ACM){
                                                      if(roles.contains(ConstantsUtility.Accounts_Manager)){
                                                        messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                      }
                                                  }else if( rfc.RFC_Status__c == ConstantsUtility.Pending_with_SM){
                                                      if(roles.contains(ConstantsUtility.SHOWROOM_MANAGER)){
                                                        messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                      }
                                                  }else if( rfc.RFC_Status__c == ConstantsUtility.Pending_with_Allotment_Manager){
                                                      if(roles.contains(ConstantsUtility.Allotment_Manager)){
                                                        messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                      }
                                                  }



                                                }
                                              }

                                              if(rfc.FM_Approval_Status__c != oldRFCMap.get(rfc.Id).FM_Approval_Status__c ||
                                                 rfc.True_Value_Approval_Status__c != oldRFCMap.get(rfc.Id).True_Value_Approval_Status__c ||
                                                 rfc.Accounts_Approval_Status__c != oldRFCMap.get(rfc.Id).Accounts_Approval_Status__c ||
                                                 rfc.SM_Approval_Status__c != oldRFCMap.get(rfc.Id).SM_Approval_Status__c ||
                                                 rfc.Allotment_Status__c != oldRFCMap.get(rfc.Id).Allotment_Status__c ||
                                                 rfc.Delivery_Request_Date__c != oldRFCMap.get(rfc.Id).Delivery_Request_Date__c
                                              ){
                                                String msgStart = rfc.Name +' for '+ oppName +' has been ';
                                                String chatterMessage ='';

                                                if(rfc.FM_Approval_Status__c != oldRFCMap.get(rfc.Id).FM_Approval_Status__c &&
                                                   (rfc.FM_Approval_Status__c == ConstantsUtility.Approved ||
                                                    rfc.FM_Approval_Status__c == ConstantsUtility.Rejected)){
                                                  chatterMessage = msgStart + rfc.FM_Approval_Status__c.toLowerCase() +' by Finance Manager. '+ otherInfoMsg +'#'+rfc.id;
                                                }
                                                else if(rfc.True_Value_Approval_Status__c != oldRFCMap.get(rfc.Id).True_Value_Approval_Status__c &&
                                                   (rfc.True_Value_Approval_Status__c == ConstantsUtility.Approved ||
                                                      rfc.True_Value_Approval_Status__c == ConstantsUtility.Rejected)){
                                                  chatterMessage = msgStart+ rfc.True_Value_Approval_Status__c.toLowerCase() +' by True Value Manager. '+ otherInfoMsg+'#'+rfc.id;
                                                }
                                                else if(rfc.Accounts_Approval_Status__c != oldRFCMap.get(rfc.Id).Accounts_Approval_Status__c &&
                                                    (rfc.Accounts_Approval_Status__c == ConstantsUtility.Approved ||
                                                      rfc.Accounts_Approval_Status__c == ConstantsUtility.Rejected)){
                                                  chatterMessage = msgStart +rfc.Accounts_Approval_Status__c.toLowerCase()+' by Account Manager. '+ otherInfoMsg+'#'+rfc.id;
                                                }
                                                else if(rfc.SM_Approval_Status__c != oldRFCMap.get(rfc.Id).SM_Approval_Status__c &&
                                                    (rfc.SM_Approval_Status__c == ConstantsUtility.Approved ||
                                                      rfc.SM_Approval_Status__c == ConstantsUtility.Rejected)){
                                                  chatterMessage= msgStart +rfc.SM_Approval_Status__c.toLowerCase()+' by Showroom Manager. '+ otherInfoMsg+'#'+rfc.id;
                                                }
                                                else if(rfc.Allotment_Status__c != oldRFCMap.get(rfc.Id).Allotment_Status__c &&
                                                     (rfc.Allotment_Status__c == ConstantsUtility.Allotted ||
                                                      rfc.Allotment_Status__c == ConstantsUtility.DeAllotted)){
                                                  chatterMessage= 'The vehicle has been '+ rfc.Allotment_Status__c.toLowerCase() +' for '+oppName + '. '+ otherInfoMsg+'#'+rfc.id;
                                                }
                                                else if(rfc.Delivery_Request_Date__c != oldRFCMap.get(rfc.Id).Delivery_Request_Date__c){
                                                  chatterMessage= msgStart +' postponed. '+ otherInfoMsg+'#'+rfc.id;
                                               }

                                                if(chatterMessage!='' && !messageWithUserSetMap.containsKey(chatterMessage))
                                                    messageWithUserSetMap.put(chatterMessage,new Set<Id>());
                                                  messageWithUserSetMap.get(chatterMessage).add(rfc.ownerid);
                                                  if(roles.contains(ConstantsUtility.QCM)){
                                                    messageWithUserSetMap.get(chatterMessage).add(u.id);
                                                  }
                                              }
                                          }

                                     }

                                }
                            }

                        System.debug('=============messageWithUserSetMap =========='+messageWithUserSetMap);
                            // for loop ends here
                       if(messageWithUserSetMap.size() > 0){
                           for(String chatterMessage : messageWithUserSetMap.keyset()){
                              List<String> chatterMessages = chatterMessage.split('#');
                              if(!test.isRunningTest())
                                ChatterNotification.createChatterPostForUsers(messageWithUserSetMap.get(chatterMessage),chatterMessages[1],chatterMessages[0],'');
                           }
                       }


     }


}