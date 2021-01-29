/**
 * @File Name          : CustomerRecordVisibilityUtility.cls
 * @Description        : This utility class is used to grant/revoke access to customer account records
 * @Author             : Subhojit Chakraborty
 * @Group              : 
 * @Last Modified By   : Subhojit Chakraborty
 * @Last Modified On   : 12/03/2019, 03:37:23 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    12/03/2019, 03:37:23 PM   Subhojit Chakraborty     Initial Version
 * 
 */ 
public without sharing class CustomerRecordVisibilityUtility {
      public virtual class CustomerVisibilityException extends Exception {}
      /*
        @Author:                  Subhojit Chakraborty
        @Created Date :           12/03/2019
        @Discription:             To grant access to customer account records
        @Date Of Modification :   12/03/2019
    */
      public static Map<String,List<Customer_Visibility__c>> grantAccessToCustomerAccount(List<Customer_Visibility__c> lstCustomerVisibilityRecords,
                                                                                          boolean bIsUpdateCVrecords,boolean bIsSkipExsistingAccessCheck,
                                                                                          boolean bIsThrowErrorOnShareFailure)
      {
          // method variable initialization block
          Map<String,boolean> mapAccountAccess=new Map<String,boolean>();
          Map<String,List<Customer_Visibility__c>> mapResponse=new Map<String,List<Customer_Visibility__c>>();
          Map<String,String> mapPublicGroupNameToId=new Map<String,String>();
          Set<Id> setAccountIds=new Set<Id>();
          Set<String> setDealerPublicGroupName=new Set<String>();
          Set<Id> setAccessUserGroup=new Set<Id>();
          Set<Id> setMSILInternalUserId=new Set<Id>();
          Set<String> setMSILInternalUserName=new Set<String>();
          List<Customer_Visibility__c> lstExsistingAccessPresent=new List<Customer_Visibility__c>();
          List<Customer_Visibility__c> lstFailedRecord=new List<Customer_Visibility__c>();
          List<Customer_Visibility__c> lstSuccessfulNewRecord=new List<Customer_Visibility__c>();
          Map<Integer,Customer_Visibility__c> mapSuccessfulNewRecord=new map<Integer,Customer_Visibility__c>();
          List<AccountShare> lstNewShareRecord=new List<AccountShare>();
          Integer iIndex=0;
          //Populate Related User field in case MSIL user id is populated
          populateSFUserIds(lstCustomerVisibilityRecords);
          //Creating unique record set for query
          for(Customer_Visibility__c oCVVar: lstCustomerVisibilityRecords){

             if(oCVVar.Dealer_Public_Group_Name__c!=null)
              setDealerPublicGroupName.add(oCVVar.Dealer_Public_Group_Name__c);
             if(oCVVar.Related_User__c!=null)
               setMSILInternalUserId.add(oCVVar.Related_User__c);
              
              setAccountIds.add(oCVVar.Customer_Account__c);



          }
          //Get related public group
          Map<Id,Group> mapPublicGroup=new Map<Id,Group>([select Id,Developername,name from Group where 
                                                                        Type='Regular' and 
                                                                        Name IN : setDealerPublicGroupName]);
          if(mapPublicGroup!=null && mapPublicGroup.size()>0){
              for(Group oGroupVar:mapPublicGroup.values()){
                 mapPublicGroupNameToId.put(oGroupVar.Name,oGroupVar.Id);
                 setAccessUserGroup.add(oGroupVar.Id);
              }  
          }
          if(!bIsSkipExsistingAccessCheck){
              //In case , exsisting record visibility check is  required by calling class
            List<AccountShare> lstAccountShare=new List<AccountShare>();
            setAccessUserGroup.addAll(setMSILInternalUserId);
            lstAccountShare=[select Id, AccountId,UserOrGroupId from AccountShare where AccountId IN :setAccountIds and 
                                                                UserOrGroupId IN :setAccessUserGroup
                                                                ];

            for(AccountShare oAccShareVar: lstAccountShare){
                mapAccountAccess.put(oAccShareVar.AccountId+'-'+oAccShareVar.UserOrGroupId,true);
            }
          }
          for(Customer_Visibility__c oCVVar: lstCustomerVisibilityRecords){
              String sUserGroupId=null;
              String sCombinationKey='';
             if(mapPublicGroupNameToId!=null && oCVVar.Dealer_Public_Group_Name__c!=null 
                && mapPublicGroupNameToId.containsKey(oCVVar.Dealer_Public_Group_Name__c)) 
               sUserGroupId=mapPublicGroupNameToId.get(oCVVar.Dealer_Public_Group_Name__c); // For dealer public group
             else if(mapPublicGroupNameToId!=null && oCVVar.Related_User__c!=null )
                sUserGroupId=oCVVar.Related_User__c;                                    // For internal user
                sCombinationKey=oCVVar.Customer_Account__c+'-'+sUserGroupId;
             if(mapAccountAccess!=null && mapAccountAccess.containsKey(sCombinationKey)){
                 // If there is exsisting share record for dealer and customer combination
                oCVVar.Access_Processing_Status__c=system.label.Access_Process_Status_Invalidated; 
               lstExsistingAccessPresent.add(oCVVar);

             }
             else if(sUserGroupId!=null){
                 // For new share records to be created for dealer and customer combination
                 AccountShare oAccShare=new AccountShare();
                 oAccShare.AccountId=oCVVar.Customer_Account__c;
                 oAccShare.UserOrGroupId=sUserGroupId;
                 oAccShare.AccountAccessLevel=System.label.Default_Customer_Access_Level;
                 oAccShare.OpportunityAccessLevel=System.label.Default_Opportunity_Access_Level;
                 oAccShare.CaseAccessLevel=System.label.Default_Case_Access_Level;
                 oAccShare.RowCause=Schema.AccountShare.RowCause.Manual;
                 lstNewShareRecord.add(oAccShare);
                 oCVVar.Access_Processing_Status__c=System.label.Access_Process_Status_Success;
                 mapAccountAccess.put(sCombinationKey,true);
                 mapSuccessfulNewRecord.put(iIndex,oCVVar);
                 iIndex++;
             }
             else{
                 // If not group record found- Exceptional scenario
               oCVVar.Access_processing_Failure_Reason__c=System.label.Access_Grant_Failure_Reason;
               oCVVar.Access_Processing_Status__c=System.label.Access_Process_Status_Failure;
               lstFailedRecord.add(oCVVar);
             }
                


          }
          if(lstNewShareRecord.size()>0){
              List<Database.Saveresult> lstShareRecordResult=new List<Database.Saveresult>();
              lstShareRecordResult=Database.insert(lstNewShareRecord,false);
              for (Integer iCounter=0;iCounter<iIndex;iCounter++ ) {
                if (lstShareRecordResult[iCounter].isSuccess()) {
                    
                    lstSuccessfulNewRecord.add(mapSuccessfulNewRecord.get(iCounter));
                }
                else {
                    // Operation failed, so get all errors 
                    if(bIsThrowErrorOnShareFailure){
                      // In case the entire transaction to be failed- mainly for trigger scenario-OTP/inbound,outbound
                      throw  new CustomerVisibilityException(JSON.serialize(lstShareRecordResult[iCounter].getErrors()));
                    }
                    else{ 
                     Customer_Visibility__c oCVVar=mapSuccessfulNewRecord.get(iCounter);
                     oCVVar.Access_Processing_Status__c=System.label.Access_Process_Status_Failure;             
                    for(Database.Error err : lstShareRecordResult[iCounter].getErrors()) {
                       
                        oCVVar.Access_processing_Failure_Reason__c+='\n'+err.getMessage();
                        
                        
                    }
                     lstFailedRecord.add(oCVVar);
                    } 
                }
              } 
          }
          
          mapResponse.put('SUCCESS',lstSuccessfulNewRecord);
          mapResponse.put('FAILED',lstFailedRecord);
          mapResponse.put('IGNORED',lstExsistingAccessPresent);
          system.debug(mapResponse);
          // If customer visibility records to be updated- For batch calling class
          if(bIsUpdateCVrecords){
            if(lstSuccessfulNewRecord.size()>0)  
              update lstSuccessfulNewRecord;
            if(lstFailedRecord.size()>0)  
              update lstFailedRecord;
            if(lstExsistingAccessPresent.size()>0)  
              update lstExsistingAccessPresent;
            
           }
        return mapResponse;
      }
       /*
        @Author:                  Subhojit Chakraborty
        @Created Date :           12/03/2019
        @Discription:             To revoke access to customer account records
        @Date Of Modification :   12/03/2019
    */
      public static Map<String,List<Customer_Visibility__c>> revokeAccessToCustomerAccount(List<Customer_Visibility__c> lstCustomerVisibilityRecords,
                                                                                          boolean bIsUpdateCVrecords,
                                                                                          boolean bIsThrowErrorOnShareFailure,
                                                                                          datetime dtRefTime){

          // method variable initialization block                                                                                 
          Map<String,AccountShare> mapAccountAccess=new Map<String,AccountShare>();
          Map<String,List<Customer_Visibility__c>> mapResponse=new Map<String,List<Customer_Visibility__c>>();
          Map<String,String> mapPublicGroupNameToId=new Map<String,String>();
          Set<Id> setAccountIds=new Set<Id>();
          Set<String> setDealerPublicGroupName=new Set<String>();
          Set<Id> setAccessUserGroup=new Set<Id>();
          Set<Id> setMSILInternalUserId=new Set<Id>();
          List<Customer_Visibility__c> lstExsistingRevokeRequest=new List<Customer_Visibility__c>();
          List<Customer_Visibility__c> lstFailedRecord=new List<Customer_Visibility__c>();
          List<Customer_Visibility__c> lstSuccessfulRevokeRecord=new List<Customer_Visibility__c>();
          Map<Integer,Customer_Visibility__c> mapSuccessfulRevokeRecord=new map<Integer,Customer_Visibility__c>();
          List<AccountShare> lstShareRecordToBeDeleted=new List<AccountShare>();
          List<Customer_Visibility__c> lstDuplicateCSRecordCheck=new List<Customer_Visibility__c>();
          Map<String,Customer_Visibility__c> mapDuplicateCSRecordCheck=new map<String,Customer_Visibility__c>();
          Map<String ,Map<String,Customer_Visibility__c>> mapExsistingRec=new Map<String ,Map<String,Customer_Visibility__c>>();
          Set<Id> setAlreadyIdentifiedShareRecords=new Set<Id>();
          Integer iIndex=0;
          //Creating unique record set for query
          for(Customer_Visibility__c oCVVar: lstCustomerVisibilityRecords){

             if(oCVVar.Dealer_Public_Group_Name__c!=null)
              setDealerPublicGroupName.add(oCVVar.Dealer_Public_Group_Name__c);
             if(oCVVar.Related_User__c!=null)
              setMSILInternalUserId.add(oCVVar.Related_User__c);
              setAccountIds.add(oCVVar.Customer_Account__c);


          }
          //Get related public group                     
          Map<Id,Group> mapPublicGroup=new Map<Id,Group>([select Id,Developername,name from Group where 
                                                                        Type='Regular' and 
                                                                       name IN : setDealerPublicGroupName]);
           
          if(mapPublicGroup!=null && mapPublicGroup.size()>0){
              for(Group oGroupVar:mapPublicGroup.values()){
                 mapPublicGroupNameToId.put(oGroupVar.name,oGroupVar.Id);
                 setAccessUserGroup.add(oGroupVar.Id);
              } 

          }
           if(setMSILInternalUserId.size()>0)
            setAccessUserGroup.addAll(setMSILInternalUserId);
            List<AccountShare> lstAccountShare=new List<AccountShare>();
            lstAccountShare=[select Id,AccountId,UserOrGroupId from AccountShare where AccountId IN :setAccountIds and 
                                                                UserOrGroupId IN :setAccessUserGroup and RowCause=:system.label.Account_Share_Row_Cause_Manual];

            for(AccountShare oAccShareVar: lstAccountShare){
                mapAccountAccess.put(oAccShareVar.AccountId+'-'+oAccShareVar.UserOrGroupId,oAccShareVar);
            }
            // Checking if there is other customer visibility record which demands for extended access- In case of duplicate record set for same dealer and customer
           lstDuplicateCSRecordCheck=[select Id,End_Datetime__c,Dealer_Public_Group_Name__c,Customer_Account__c,Access_Processing_Status__c
                                        from Customer_Visibility__c where Customer_Account__c IN :setAccountIds /*and End_Datetime__c=null
                                        and Access_Processing_Status__c=:system.label.Access_Process_Status_Success*/
                                        and Dealer_Public_Group_Name__c IN :setDealerPublicGroupName];
          for(Customer_Visibility__c oCVVar: lstDuplicateCSRecordCheck){
             if(mapPublicGroupNameToId.containsKey(oCVVar.Dealer_Public_Group_Name__c)) {
               String sKey=oCVVar.Customer_Account__c+'-'+mapPublicGroupNameToId.get(oCVVar.Dealer_Public_Group_Name__c);
               
                Map<String,Customer_Visibility__c> mapTemp=new Map<String,Customer_Visibility__c> ();
                if(mapExsistingRec.containsKey(sKey)){
                  mapTemp=mapExsistingRec.get(sKey);
                }
                
               if(oCVVar.End_Datetime__c==null || (oCVVar.End_Datetime__c!=null && oCVVar.End_Datetime__c>dtRefTime)){
                  mapTemp.put(oCVVar.Access_Processing_Status__c,oCVVar);
                  mapDuplicateCSRecordCheck.put(sKey,oCVVar);
                  mapExsistingRec.put(sKey,mapTemp);
               }

             }
          }  
             system.debug('>>>>>'+mapDuplicateCSRecordCheck);
          for(Customer_Visibility__c oCVVar: lstCustomerVisibilityRecords){
               String sUserGroupId=null;
               String sCombinationKey='';
             if(mapPublicGroupNameToId!=null && oCVVar.Dealer_Public_Group_Name__c!=null 
                && mapPublicGroupNameToId.containsKey(oCVVar.Dealer_Public_Group_Name__c))
               sUserGroupId=mapPublicGroupNameToId.get(oCVVar.Dealer_Public_Group_Name__c); // For Dealer oublic group
             else if(mapPublicGroupNameToId!=null && oCVVar.Related_User__c!=null )
                sUserGroupId=oCVVar.Related_User__c;                                        // For internal user
                sCombinationKey=oCVVar.Customer_Account__c+'-'+sUserGroupId;
                system.debug('>>>>>'+sCombinationKey);
             if(mapAccountAccess!=null && mapAccountAccess.containsKey(sCombinationKey)){
               // Account share records that needs to be revoked
               AccountShare oAccountShareVar=mapAccountAccess.get(sCombinationKey);
              if(!setAlreadyIdentifiedShareRecords.contains(oAccountShareVar.Id)
                 && ! mapDuplicateCSRecordCheck.containsKey(sCombinationKey)){
                oCVVar.Access_Processing_Status__c=System.label.Access_Process_Status_Revoked; 
                lstShareRecordToBeDeleted.add(oAccountShareVar);
                setAlreadyIdentifiedShareRecords.add(oAccountShareVar.Id);
                mapSuccessfulRevokeRecord.put(iIndex,oCVVar);
                iIndex++;
              }
              else{
                  // In case other  customer visibility record which demands for extended access
                  oCVVar.Access_Processing_Status__c=system.label.Access_Process_Status_Invalidated; 
                  lstExsistingRevokeRequest.add(oCVVar);
                  //For Conflicting Scenario
                  if(mapExsistingRec.containsKey(sCombinationKey)){
                    Map<String,Customer_Visibility__c> mapTempvar=mapExsistingRec.get(sCombinationKey);
                     Customer_Visibility__c oCVExtVar=new Customer_Visibility__c();
                     if(mapTempvar.containsKey(System.label.Access_Process_Status_Success))
                        continue; 
                    if(mapTempvar.containsKey(System.label.Access_Process_Status_Failure))
                        oCVExtVar=mapTempvar.get(System.label.Access_Process_Status_Failure);
                    else if(mapTempvar.containsKey(System.label.Access_Process_Status_Pending))
                         oCVExtVar=mapTempvar.get(System.label.Access_Process_Status_Pending);
                    else if(mapTempvar.containsKey(System.label.Access_Process_Status_Invalidated))
                        oCVExtVar=mapTempvar.get(System.label.Access_Process_Status_Invalidated);
                    oCVExtVar.Access_Processing_Status__c=System.label.Access_Process_Status_Success;
                    if(oCVExtVar.Id!=null)
                     lstExsistingRevokeRequest.add(oCVExtVar);
                  }
              }
             }
             
             else{
               // If not group found or no account share record present  
               oCVVar.Access_processing_Failure_Reason__c=system.label.Access_Grant_Failure_Reason_2;
               oCVVar.Access_Processing_Status__c=system.label.Access_Process_Status_Failure;
               lstFailedRecord.add(oCVVar);
             }
                


          }
          if(lstShareRecordToBeDeleted.size()>0){
              List<Database.Deleteresult> lstShareRecordResult=new List<Database.Deleteresult>();
              lstShareRecordResult=Database.delete(lstShareRecordToBeDeleted,false);
              for (Integer iCounter=0;iCounter<iIndex;iCounter++ ) {
                if (lstShareRecordResult[iCounter].isSuccess()) {
                    
                    lstSuccessfulRevokeRecord.add(mapSuccessfulRevokeRecord.get(iCounter));
                }
                else {
                    // Operation failed, so get all errors 
                    if(bIsThrowErrorOnShareFailure){
                      throw  new CustomerVisibilityException(JSON.serialize(lstShareRecordResult[iCounter].getErrors()));
                    }
                    Customer_Visibility__c oCVVar=mapSuccessfulRevokeRecord.get(iCounter);
                            
                    for(Database.Error err : lstShareRecordResult[iCounter].getErrors()) {
                           
                            oCVVar.Access_processing_Failure_Reason__c+='\n'+err.getMessage();
                            
                            
                        }
                     lstFailedRecord.add(oCVVar);
                    } 
                }
             } 
          
          mapResponse.put('SUCCESS',lstSuccessfulRevokeRecord);
          mapResponse.put('FAILED',lstFailedRecord);
          mapResponse.put('IGNORED',lstExsistingRevokeRequest);
           // If customer visibility records to be updated- For batch calling class
          if(bIsUpdateCVrecords){
            if(lstSuccessfulRevokeRecord.size()>0)  
              update lstSuccessfulRevokeRecord;
            if(lstFailedRecord.size()>0)  
              update lstFailedRecord;
            if(lstExsistingRevokeRequest.size()>0)  
              update lstExsistingRevokeRequest;
            
           }
        return mapResponse;
    
        }
     /*
        @Author:                  Subhojit Chakraborty
        @Created Date :           12/03/2019
        @Discription:             To check if logged user has access to customer account records
        @Date Of Modification :   12/03/2019
    */   
     public static Map<Id,boolean> checkIfCustomerRecordAccessExsists(Set<Id> setAccountId){

      Id loggedInUserId=UserInfo.getUserId();
      Map<Id,boolean> mapAccessMatrix=new Map<Id,boolean>();
      boolean bIsExternalUser=false;
      String sUserOrGroupId=null;
      List<Group> lstGroup=new List<Group>();
      User oUser=[select Id,AccountId from User where Id=:loggedInUserId];
      if(oUser.AccountId!=null)
        bIsExternalUser=true;   // If logged in user is partner community user
      if(bIsExternalUser)  {
         Account oDealerAccount=[select Parent_Group__c from Account where Id=:oUser.AccountId];
         lstGroup=[select Id,name from Group where Type='Regular' and name = : (oDealerAccount.Parent_Group__c)];
      }
       
       
        if(lstGroup.size()>0 && bIsExternalUser){
         sUserOrGroupId=lstGroup[0].Id;                                            
      }
      else if(!bIsExternalUser){
          sUserOrGroupId=oUser.Id; // For internal user
      }
     List<AccountShare> lstAccountShare=new List<AccountShare>();
     lstAccountShare=[select Id,AccountId from AccountShare where AccountId IN :setAccountId and UserOrGroupId=:sUserOrGroupId ];
     for(AccountShare oAccShareVar: lstAccountShare){
          mapAccessMatrix.put(oAccShareVar.AccountId,true); // Those user/group who already have access to target customer account set
      }
      for(Id accoountIdVar:setAccountId){
          if(!mapAccessMatrix.containsKey(accoountIdVar))
            mapAccessMatrix.put(accoountIdVar,false);     // Those user/group who dont have access to target customer account set
      }
      return mapAccessMatrix;
     }   
      /*
        @Author:                  Subhojit Chakraborty
        @Created Date :           12/03/2019
        @Discription:             To add external Users to related public group
        @Date Of Modification :   12/03/2019
    */   
    public static void addUserToParentPublicGroup(List<User> lstUser){
        Set<Id> setContactId=new Set<Id>();
        List<Contact> lstRelatedContact=new List<Contact>();
        Set<String> setPublicGroupName=new Set<String>();
        map<String,String> mapContactIdPublicGroupName=new map<String,String>();
        map<String,String> mapPublicGroupNameId=new map<String,String>();
        List<Group> lstPublicGroup=new List<Group>();
        
        List<GroupMember> lstGroupMember=new List<GroupMember>();
        for(User oUserVar: lstUser){
            if(oUserVar.ContactId!=null)
              setContactId.add(oUserVar.ContactId);
        }
       // Run the logic only for internal user 
       if(setContactId.size()>0){ 
        lstRelatedContact=[select Id,Account.Parent_Group__c from Contact where Id IN :setContactId];
        for(Contact oContactVar: lstRelatedContact){
            setPublicGroupName.add(oContactVar.Account.Parent_Group__c);
            mapContactIdPublicGroupName.put(oContactVar.Id,oContactVar.Account.Parent_Group__c);
        }
        // Get related public group
        lstPublicGroup=[select Id,DeveloperName,name from Group where Type='Regular' and name IN :setPublicGroupName];
        for(Group grVar: lstPublicGroup){
           mapPublicGroupNameId.put(grVar.name,grVar.Id);
        }
        for(User oUser : lstUser){
            String sContactId=oUser.ContactId;
            String sPublicGroupName;
            String sPublicGroupId;
            if(mapContactIdPublicGroupName.containsKey(sContactId)){
             sPublicGroupName=mapContactIdPublicGroupName.get(sContactId);
             // Add User to public group
             if(mapPublicGroupNameId.containsKey(sPublicGroupName)){
                 sPublicGroupId=mapPublicGroupNameId.get(sPublicGroupName);
                 GroupMember grMemberVar=new GroupMember();
                 grMemberVar.GroupId=sPublicGroupId;
                 grMemberVar.UserOrGroupId=oUser.Id;
                 lstGroupMember.add(grMemberVar);
             }
            }
             
        }
         if(lstGroupMember.size()>0)
         {
         
         database.insert( lstGroupMember, false);
         }
         // insert lstGroupMember;
       }
    }
     /*
        @Author:                  Subhojit Chakraborty
        @Created Date :           12/03/2019
        @Discription:             To populate SF user Ids in case only MSIL user Id is present in customer account records
        @Date Of Modification :   12/03/2019
    */ 
    private static void populateSFUserIds(List<Customer_Visibility__c> lstCustomerVisibilityRecords){

      Set<String> setMSILInternalUserName=new Set<String>();
      Map<String,Id> mapMSILUserSFId=new map<String,Id>();
      List<Customer_Visibility__c> lstCSTemp=new List<Customer_Visibility__c>();
      List<User> lstUser=new List<User>();
      for(Customer_Visibility__c oCVVar: lstCustomerVisibilityRecords){
        if(oCVVar.Related_User__c==null && oCVVar.MSIL_User_ID__c!=null){
          setMSILInternalUserName.add(oCVVar.MSIL_User_ID__c);
          lstCSTemp.add(oCVVar);
        }

      }
      lstUser=[select Id,DMS_Username__c from user where DMS_Username__c IN :setMSILInternalUserName];
      for(User oUserVar: lstUser){
        mapMSILUserSFId.put(oUserVar.DMS_Username__c,oUserVar.Id);
      }  
      for(Customer_Visibility__c oCVVar: lstCSTemp){
        if(mapMSILUserSFId.containsKey(oCVVar.MSIL_User_ID__c)){
          oCVVar.Related_User__c=mapMSILUserSFId.get(oCVVar.MSIL_User_ID__c);
        }
      }  
    }
    /*
        @Author:                  Subhojit Chakraborty
        @Created Date :           12/03/2019
        @Discription:             Subscriber logic to insert audit row in custom setting and fire related batch
        @Date Of Modification :   12/03/2019
    */
    public static void processBatchInitiateNotification(List<Notification__e> lstNotification){
        List<Notification_Event_Log__c> lstNotificationLog=new List<Notification_Event_Log__c>();
        lstNotificationLog=[select Id,Notification_Type__c,Process_Completed_On__c,Total_Record_Processed__c,
                                Total_Record_Processed_Failed__c,Total_Record_Processed_Successful__c 
                                from Notification_Event_Log__c where 
                                Notification_Type__c=:system.label.Customer_visibility_Grant_Access_Batch
                                order by Process_Completed_On__c asc];
        if(lstNotificationLog.size()==Integer.valueOf(System.label.Customer_visibility_Grant_Access_Batch_Retention_Duration)){
            //Regular flow
            lstNotificationLog[0].Notification_Type__c=lstNotification[0].Notification_Type__c;
            
            lstNotificationLog[0].Process_Completed_On__c=lstNotification[0].Process_Completed_On__c;
            lstNotificationLog[0].Total_Record_Processed__c=lstNotification[0].Total_Record_Processed__c;
            lstNotificationLog[0].Total_Record_Processed_Failed__c=lstNotification[0].Total_Record_Processed_Failed__c;
            lstNotificationLog[0].Total_Record_Processed_Successful__c=lstNotification[0].Total_Record_Processed_Successful__c;
           
        } 
        else{
            // For initial loading period
           Notification_Event_Log__c notificationCSVar=new Notification_Event_Log__c();
            notificationCSVar.Name=lstNotification[0].Notification_Type__c+'-'+lstNotificationLog.size();
            notificationCSVar.Notification_Type__c=lstNotification[0].Notification_Type__c;
            notificationCSVar.Process_Completed_On__c=lstNotification[0].Process_Completed_On__c;
            notificationCSVar.Total_Record_Processed__c=lstNotification[0].Total_Record_Processed__c;
            notificationCSVar.Total_Record_Processed_Failed__c=lstNotification[0].Total_Record_Processed_Failed__c;
            notificationCSVar.Total_Record_Processed_Successful__c=lstNotification[0].Total_Record_Processed_Successful__c;
            lstNotificationLog.add(notificationCSVar);
        } 
         upsert lstNotificationLog;
         If(!Test.isRunningTest())
          Database.executeBatch(new ProcessCustomerVisibilityAccess_batch(),Integer.valueOf(System.label.ProcessCustomerVisibilityAccess_batch_Chunk_Size));                      
    }
}