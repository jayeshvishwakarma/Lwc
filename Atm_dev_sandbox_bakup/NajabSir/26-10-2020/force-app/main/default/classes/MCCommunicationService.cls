public class MCCommunicationService {
  /**
  Author: Gitika 
  Company: Techmatrix
  Description: Class is used to create MC COMMUNICATION Records for notifications
  History:
  * Ver         Date                     Author                    Modification
  *==============================================================================
  * 1.0        29/07/2020               Gitika              Initial Version
  **/
  public static void createMCRecordsForATM(List<case> triggerNewList,map<id,case> triggerOldMap) {
  try{
  
  map<string, List<MC_Communication_SOQLs__mdt>> createEventMcCommunicationMap = new map<string, List<MC_Communication_SOQLs__mdt>>();
  map<string, String> mapOfDealerIdWithName = new map<string, String>();
  map<string, String> mapOfVaraintIdWithName = new map<string, String>();
  
  for(Case cs : triggerNewList){
      if(cs.Dealer_Name__c!=null){
          mapOfDealerIdWithName.put(cs.Dealer_Name__c,null);
      }if(cs.Variant__c!=null){
          mapOfVaraintIdWithName.put(cs.Variant__c,null);
      }
  }
  if(mapOfDealerIdWithName.size()>0){
      for(Account acc : [Select Name,Id from Account where id in :mapOfDealerIdWithName.keyset()]){
          mapOfDealerIdWithName.put(acc.id,acc.name); 
      }
  }
  if(mapOfVaraintIdWithName.size()>0){
      for(Product2 prod : [Select Name,Id from Product2 where id in :mapOfVaraintIdWithName.keyset()]){
          mapOfVaraintIdWithName.put(prod.id,prod.name); 
      }
  }
  // Caling Respective Methods
   if(Trigger.IsInsert) {
      createEventMcCommunicationMap= MCCommunicationService.getmcCommunicationMatrices(ConstantsUtility.CREATE);
      MCCommunicationService.insertEvent(triggerNewList,createEventMcCommunicationMap,mapOfDealerIdWithName,mapOfVaraintIdWithName);
    }else if (Trigger.Isupdate && triggerOldMap!=null){
      createEventMcCommunicationMap= MCCommunicationService.getmcCommunicationMatrices('Update');
     MCCommunicationService.updateEvent(triggerNewList,triggerOldMap,mapOfDealerIdWithName,mapOfVaraintIdWithName,createEventMcCommunicationMap);
  }
  }catch(Exception e){
    
  ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'createMCRecordsForATM', '', null);  
  }
  }
  /**
  Author: Gitika 
  Company: Techmatrix
  Description: method is used to Insert MC Communication for SMS Notifications
  History:
  * Ver         Date                     Author                    Modification
  *==============================================================================
  * 1.0        29/07/2020               Gitika              Initial Version
  **/
  public static void insertEvent(List<case> triggerNewList,map<string,List<MC_Communication_SOQLs__mdt>> createEventMcCommunicationMap
                                 ,map<string, String> mapOfDealerIdWithName,map<string, String> mapOfVaraintIdWithName){
  // List to store MC Communication Records
  //List<MC_Communication__c> mcComList = new List<MC_Communication__c>();
  // Map to store stakeHolder Mapping With Respect to Case Id, CaseID As key
  try{
  Map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders = MCCommunicationService.mapOfcaseIdWithMapOfStakeHolders(triggerNewList,ConstantsUtility.STAKEHOLDER);
  // Map to store stakeHolder Mapping With Respect to Case Id, CaseID As key and StakeholderHierarchy key as RefName
  Map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHoldersWithRefNameAsKey = MCCommunicationService.mapOfcaseIdWithMapOfStakeHolders(triggerNewList,ConstantsUtility.REFNAME);
 
  map<string,user> mapOfUserIdWithUser = new map<string,user>();
  List<MC_Communication__c> mcComList = new List<MC_Communication__c>();
  for(Id ids : mapOfCaseIdWithStakeHolders.keyset()){
      for(string str : mapOfCaseIdWithStakeHolders.get(ids).keyset()){
          mapOfUserIdWithUser.put(mapOfCaseIdWithStakeHolders.get(ids).get(str).recordId,null);
      }
  }
  // iteration Starts
  for(Case cs : triggerNewList){
      mapOfUserIdWithUser.put(cs.Ownerid,null);
  }
  if(mapOfUserIdWithUser.size()>0){
      for(user usr :[Select firstname,lastname,id,MobilePhone,Manager.MobilePhone from user where id in :mapOfUserIdWithUser.keyset()]){
          String Id = String.valueof(usr.id).left(15);
          mapOfUserIdWithUser.put(Id,usr); 
      }
  }
  // iteration Starts
  for(Case cs : triggerNewList){
      
      if(createEventMcCommunicationMap.containskey(cs.case_type__c) && cs.Customer_Satisfied_With_FCR__c!='Yes'){
             mcComList.addALL(MCCommunicationService.getMCComSMS(cs,createEventMcCommunicationMap.get(cs.case_type__c),mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));
          }else if(cs.case_type__c==ConstantsUtility.DEALER_QUERY_CASE_TYPE && cs.Customer_Satisfied_With_FCR__c=='Yes'){
              List<MC_Communication_SOQLs__mdt> mcMdtList = new List<MC_Communication_SOQLs__mdt>();
              MC_Communication_SOQLs__mdt mcMdtRecord = new MC_Communication_SOQLs__mdt();
              mcMdtRecord.MasterLabel=ConstantsUtility.QUERY_CLOSURE_CUSTOMER;
              mcMdtRecord.Communication_Type__c='SMS';
              mcMdtRecord.Recipients__c=ConstantsUtility.CUSTOMER;
              mcMdtList.add(mcMdtRecord);
              mcComList.addALL(MCCommunicationService.getMCComSMS(cs,mcMdtList,mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));
          } 
  }
  if(mcComList.size()>0){
      insert mcComList;
  }
  }
  catch (Exception e) {
  
  ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'insertEvent', '', null);
  }
  }
 
/**
Author: Gitika 
Company: Techmatrix
Description: method is used to Insert MC Communication for Email
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        29/07/2020               Gitika              Initial Version
**/
public static void updateEvent(List<case> triggerNewList,map<id,Case> triggerOldMap,map<string, String> mapOfDealerIdWithName,
map<string, String> mapOfVaraintIdWithName,map<string,List<MC_Communication_SOQLs__mdt>> createEventMcCommunicationMap){
 try{
   Map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders = MCCommunicationService.mapOfcaseIdWithMapOfStakeHolders(triggerNewList,ConstantsUtility.STAKEHOLDER);
   // Map to store stakeHolder Mapping With Respect to Case Id, CaseID As key and StakeholderHierarchy key as RefName
   Map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHoldersWithRefNameAsKey = MCCommunicationService.mapOfcaseIdWithMapOfStakeHolders(triggerNewList,ConstantsUtility.REFNAME);
   // List to store MC Communication Records
   List<MC_Communication__c> mcComList = new List<MC_Communication__c>();
   map<string,user> mapOfUserIdWithUser = new map<string,user>();
   for(Id ids : mapOfCaseIdWithStakeHolders.keyset()){
      for(string str : mapOfCaseIdWithStakeHolders.get(ids).keyset()){
          mapOfUserIdWithUser.put(mapOfCaseIdWithStakeHolders.get(ids).get(str).recordId,null);
        }
    }
    if(mapOfUserIdWithUser.size()>0){
        for(user usr :[Select firstname,lastname,id,MobilePhone,Manager.MobilePhone from user where id in :mapOfUserIdWithUser.keyset()]){
         String Id = String.valueof(usr.id).left(15);
         mapOfUserIdWithUser.put(Id,usr); 
        }
    }
// iteration Starts
    for(Case cs : triggerNewList){ 
      if(cs.Additional_Information__c != triggerOldMap.get(cs.id).Additional_Information__c){
         if(createEventMcCommunicationMap.containsKey(ConstantsUtility.VOC_NOTIFICATION_DEALER)){
            mcComList.addALL(MCCommunicationService.getMCComSMS(cs,createEventMcCommunicationMap.get(ConstantsUtility.VOC_NOTIFICATION_DEALER),mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));  
            }
      }else if(cs.status==ConstantsUtility.CASE_CLOSED && triggerOldMap.get(cs.id).Status != cs.status && cs.recordtypeId==ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID){
         if(createEventMcCommunicationMap.containsKey(ConstantsUtility.COMPLAINT_CLOSURE_DEALER)){
           mcComList.addALL(MCCommunicationService.getMCComSMS(cs,createEventMcCommunicationMap.get(ConstantsUtility.COMPLAINT_CLOSURE_DEALER),mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));  
         }

         if(createEventMcCommunicationMap.containsKey(ConstantsUtility.COMPLAINT_CLOSURE_CUSTOMER)){
           mcComList.addALL(MCCommunicationService.getMCComSMS(cs,createEventMcCommunicationMap.get(ConstantsUtility.COMPLAINT_CLOSURE_CUSTOMER),mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));  
         }
      }else if(cs.status==ConstantsUtility.CASE_CLOSED && triggerOldMap.get(cs.id).Status != cs.status && cs.recordtypeId==ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID){
         if(createEventMcCommunicationMap.containsKey(ConstantsUtility.QUERY_CLOSURE_CUSTOMER)){
          mcComList.addALL(MCCommunicationService.getMCComSMS(cs,createEventMcCommunicationMap.get(ConstantsUtility.QUERY_CLOSURE_CUSTOMER),mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));  
         }
      }else if(cs.status==ConstantsUtility.On_Hold && triggerOldMap.get(cs.id).Status != cs.status && cs.recordtypeId==ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID){
         if(createEventMcCommunicationMap.containsKey(ConstantsUtility.COMPLAINT_ON_HOLD_DEALER)){
          mcComList.addALL(MCCommunicationService.getMCComSMS(cs,createEventMcCommunicationMap.get(ConstantsUtility.COMPLAINT_ON_HOLD_DEALER),mapOfCaseIdWithStakeHolders,mapOfCaseIdWithStakeHoldersWithRefNameAsKey,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser));  
      }
    }
  } 
 if(mcComList.size()>0){
   insert mcComList;
 }
}
catch (Exception e) {

   ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'updateEvent', '', null);
}

}

/**
Author: Gitika
Company: Techmatrix
Description: Method for SMS mapping
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/

public static list<MC_Communication__c> getMCComSMS(case caseObj,List<MC_Communication_SOQLs__mdt> MCCommunicationSOQLsmdtlist,Map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders,Map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHoldersWithRefNameAsKey,
              map<string, String> mapOfDealerIdWithName,map<string, String> mapOfVaraintIdWithName,map<string,user> mapOfUserIdWithUser) {
// Map to store stakeholder details
map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails = new map<string, StakeholderHierarchy.Sales>();
map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetailsForTsm = new map<string, StakeholderHierarchy.Sales>();
// List to store Stakeholders to be notified
List<String> notifiers = new List<String>();
// map  of case recordid with set of Notifiers
map<Id, Set<String>> recordIdVdNotifiersMap = new map<Id, Set<String>>();
// map  of id with message
map<Id, string> recordIdVsMessageMap = new map<Id, string>();
// set to store ids for chatter Notification
set<String> recordId= new set<String>();
list<MC_Communication__c> MCCommunicationlist = new list<MC_Communication__c>();

              for(MC_Communication_SOQLs__mdt mcComMetadata:MCCommunicationSOQLsmdtlist){
                MC_Communication__c mcRecordStakeholder = new MC_Communication__c();
                if(mcComMetadata.MasterLabel.contains('Customer') && mcComMetadata.Communication_Type__c=='Email'){
                  mcRecordStakeholder= MCCommunicationService.getMCComForCustomer(caseObj,mcRecordStakeholder,mapOFStakeholderWithdetails,mapOfUserIdWithUser);
                }
                else{
                  mcRecordStakeholder= MCCommunicationService.getMCComCaseMapping(caseObj,mcRecordStakeholder,null,null,mapOfDealerIdWithName,mapOfVaraintIdWithName);
                }
              
              mcRecordStakeholder.case__c=caseObj.id;
              mcRecordStakeholder.Type__c=mcComMetadata.MasterLabel;
              mcRecordStakeholder.date_1__c=caseObj.On_Hold_End_date__c!=null?caseObj.On_Hold_End_date__c:null;
              mcRecordStakeholder.Status__c='Queued';
              mcRecordStakeholder.Communication_Type__c = mcComMetadata.Communication_Type__c!=null?mcComMetadata.Communication_Type__c:'';
  // TSM Population
  if (mapOfCaseIdWithStakeHoldersWithRefNameAsKey.containskey(caseObj.id) && mapOfCaseIdWithStakeHoldersWithRefNameAsKey.get(caseObj.id).size() > 0){
      mapOFStakeholderWithdetailsForTsm=mapOfCaseIdWithStakeHoldersWithRefNameAsKey.get(caseObj.id);
           for(string str : mapOFStakeholderWithdetailsForTsm.keyset()){
              if(str.contains(ConstantsUtility.TSM)){
                 mcRecordStakeholder.Internal_User__c= mapOFStakeholderWithdetailsForTsm.get(str).recordId; 
               }
        }
    }
  // Notification To Customer
 if(mcComMetadata.Recipients__c==ConstantsUtility.CUSTOMER){
   // For Phone Notification 
  if(mcComMetadata.Communication_Type__c=='SMS'){
    mcRecordStakeholder.Recipient_Phone_Numbers__c=caseObj.Mobile_Number__c; 
   }
   // For Email Notification 
   else if(mcComMetadata.Communication_Type__c=='Email'){
    mcRecordStakeholder.To_Address__c=caseObj.Email__c != null ? caseObj.Email__c:'';
   }
}
 // Notification To Case Owner 
 else if(mcComMetadata.Recipients__c==ConstantsUtility.CASE_OWNER){ 
   string ownerid =string.valueof(caseObj.Ownerid).length()>15?string.valueof(caseObj.Ownerid).left(15):caseObj.Ownerid;
   if(mapOfUserIdWithUser.containsKey(ownerid)){
     // For Phone Notification 
    if(mcComMetadata.Communication_Type__c=='SMS'){
     mcRecordStakeholder.Recipient_Phone_Numbers__c=mapOfUserIdWithUser.get(ownerid).MobilePhone!=null? mapOfUserIdWithUser.get(ownerid).MobilePhone:''; 
    } 
     // For Email Notification
     else if(mcComMetadata.Communication_Type__c=='Email'){
      mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(ownerid).Email!=null? mapOfUserIdWithUser.get(ownerid).Email:'';   
    }
  }
}
 // Notification To Call Center Manager
 else if(mcComMetadata.Recipients__c==ConstantsUtility.CALL_CENTER_MANAGER){
  string ownerid =string.valueof(caseObj.Ownerid).length()>15?string.valueof(caseObj.Ownerid).left(15):caseObj.Ownerid;
  if(mapOfUserIdWithUser.containsKey(ownerid)){
   // For Phone Notification 
   if(mcComMetadata.Communication_Type__c=='SMS'){
    mcRecordStakeholder.Recipient_Phone_Numbers__c=mapOfUserIdWithUser.get(ownerid).Manager.MobilePhone!=null? mapOfUserIdWithUser.get(ownerid).Manager.MobilePhone:''; 
   } 
   // For Email Notification
   else if(mcComMetadata.Communication_Type__c=='Email'){
   mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(ownerid).Manager.Email!=null? mapOfUserIdWithUser.get(ownerid).Manager.Email:'';    
   }
  }   
}
 // Notification To NON SF Stakeholders
 else if(mcComMetadata.Recipients__c==ConstantsUtility.MSIL_NON_SF_STAKEHOLDER){
   // For Phone Notification 
   if(mcComMetadata.Communication_Type__c=='SMS'){
    mcRecordStakeholder.Recipient_Phone_Numbers__c=caseObj.MSIL_Non_SF_Stakeholder_Phone__c!=null?caseObj.MSIL_Non_SF_Stakeholder_Phone__c:'';
   }
   // For Email Notification
   else if(mcComMetadata.Communication_Type__c=='Email'){
    mcRecordStakeholder.To_Address__c=caseObj.MSIL_Non_SF_Stakeholder_Email__c!=null?caseObj.MSIL_Non_SF_Stakeholder_Email__c:'';
   }
 }
// Notification To  Stakeholders L1A,L2A...
else{

   if (mapOfCaseIdWithStakeHolders.containskey(caseObj.id) && mapOfCaseIdWithStakeHolders.get(caseObj.id).size() > 0){
       notifiers = String.isNotBlank(mcComMetadata.Recipients__c) ? mcComMetadata.Recipients__c.split('\\,') : notifiers;
       mapOFStakeholderWithdetails = mapOfCaseIdWithStakeHolders.get(caseObj.id); }

    if (notifiers.size() > 0 && mapOFStakeholderWithdetails.size() > 0){
       string mobile='';
       string email='';

     // For Phone Notification 
     if(mcComMetadata.Communication_Type__c=='SMS'){
       for (string str : notifiers) {
        if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).phone)) {
          mobile = mobile+mapOFStakeholderWithdetails.get(str).phone+','; }
        // for sending chatter Notification for VOC update 
        if(mapOFStakeholderWithdetails.containskey(str) && mcComMetadata.MasterLabel==ConstantsUtility.VOC_NOTIFICATION_DEALER && string.isNotBlank(mapOFStakeholderWithdetails.get(str).recordId)){
          recordId.add(mapOFStakeholderWithdetails.get(str).recordId); 
         }
     }
    mobile=mobile.removeEnd(','); 
    mcRecordStakeholder.Recipient_Phone_Numbers__c=mobile; 
    }
    // For Email Notification
    else if(mcComMetadata.Communication_Type__c=='Email'){
     for (string str : notifiers) {
       if (mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)) {
         email = email+mapOFStakeholderWithdetails.get(str).email+','; }
        }
    email=email.removeEnd(','); 
    mcRecordStakeholder.To_Address__c=email; 
    }  
 }

}
 // Specific checks 
  if(mcComMetadata.MasterLabel != ConstantsUtility.MSIL_QUERY_SPAM_CCM && mcComMetadata.MasterLabel != ConstantsUtility.MSIL_QUERY_REGISTRATION_SF_STAKEHOLDER 
     && mcComMetadata.MasterLabel != ConstantsUtility.MSIL_QUERY_REGISTRATION_NON_SF_STAKEHOLDER){
    MCCommunicationlist.add(mcRecordStakeholder);
  }else if (mcComMetadata.MasterLabel == ConstantsUtility.MSIL_QUERY_SPAM_CCM && caseObj.case_type__c==ConstantsUtility.INTERNAL_CASE_TYPE && caseObj.Channel__c==ConstantsUtility.MS_CORPORATE_CASE_CHANNEL 
    && caseObj.Primary_Category__c==ConstantsUtility.SPAM_PRIMARY_CATEGORY){
    MCCommunicationlist.add(mcRecordStakeholder); 
  }else if (mcComMetadata.MasterLabel == ConstantsUtility.MSIL_QUERY_REGISTRATION_SF_STAKEHOLDER && caseObj.MSIL_Non_SF_Stakeholder_Phone__c==null){
    MCCommunicationlist.add(mcRecordStakeholder); 
  }else if (mcComMetadata.MasterLabel == ConstantsUtility.MSIL_QUERY_REGISTRATION_NON_SF_STAKEHOLDER &&  caseObj.MSIL_Non_SF_Stakeholder_Phone__c!=null){
    MCCommunicationlist.add(mcRecordStakeholder); 
}
// chatter Notification For VOC uPDATE
if(recordId.size()>0){  
    Approval_Notification_Setting__c myCS1 = Approval_Notification_Setting__c.getValues(ConstantsUtility.VOC_NOTIFICATION_DEALER);
    if(myCS1.Approved_Template__c!=null){
        string message = myCS1.Approved_Template__c;
        recordIdVdNotifiersMap.put(caseObj.Id, recordId);
        message = message.contains(ConstantsUtility.CASE_NUMBER_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_NUMBER_REPLACEMENT, caseObj.CaseNumber) : message;
        if(caseObj.Case_Type__c != null)
        message = message.contains(ConstantsUtility.CASE_TYPE_REPLACEMENT) ? message.replace(ConstantsUtility.CASE_TYPE_REPLACEMENT, caseObj.Case_Type__c) : message;
        recordIdVsMessageMap.put(caseObj.Id, message);
    }
    if (!recordIdVdNotifiersMap.isEmpty() && !recordIdVsMessageMap.isEmpty()) {
        ChatterNotificationUtil.sendChatterNotification(recordIdVdNotifiersMap, recordIdVsMessageMap);
    }
}
}   
          
return MCCommunicationlist;
}
 /**
  Author: Gitika 
  Company: Techmatrix
  Description: Class is used to create MC COMMUNICATION Records for notifications
  History:
  * Ver         Date                     Author                    Modification
  *==============================================================================
  * 1.0        29/07/2020               Gitika              Initial Version
  **/
  public static void createMCRecordsForCaseAction(List<Case_actions__C> triggerNewList,map<id,Case_actions__C> triggerOldMap) {
    try{
    map<string,String> mapOfDealerIdWithName = new map<string, String>();
    map<string,String> mapOfVaraintIdWithName = new map<string, String>();
    map<string,Case> mapOfCaseIdWithCase = new map<string,Case>();
    map<string,user> mapOfUserIdWithUser = new map<string,user>();


    for(Case_actions__c cs : triggerNewList){
        if(cs.case_number__c != null){
            mapOfCaseIdWithCase.put(cs.case_number__c,null);
            if(cs.Approved_Rejection_Notifiers__c!=null){
                for(string str : cs.Approved_Rejection_Notifiers__c.split(',')){
                    if(str.length()>15)
                    str = str.left(15);
                    mapOfUserIdWithUser.put(str,null);
                }
                
            }
            if(cs.L1_Stakeholder__c !=null){
                string L1_Stakeholder = string.valueof(cs.L1_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L1_Stakeholder,null);
            }
            if(cs.L2A_Stakeholder__c !=null){
                string L2A_Stakeholder = string.valueof(cs.L2A_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L2A_Stakeholder,null);
            }
            if(cs.L3A_Stakeholder__c !=null){
                string L3A_Stakeholder = string.valueof(cs.L3A_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L3A_Stakeholder,null);
            }
            if(cs.L4_Stakeholder__c !=null){
                string L4_Stakeholder = string.valueof(cs.L4_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L4_Stakeholder,null);
            }
            if(cs.L5_Stakeholder__c !=null){
                string L5_Stakeholder = string.valueof(cs.L5_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L5_Stakeholder,null);
            }
            if(cs.L6A_Stakeholder__c !=null){
                string L6A_Stakeholder = string.valueof(cs.L6A_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L6A_Stakeholder,null);
            }
            if(cs.L7A_Stakeholder__c !=null){
                string L7A_Stakeholder = string.valueof(cs.L7A_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L7A_Stakeholder,null);
            }
            if(cs.L8A_Stakeholder__c !=null){
                string L8A_Stakeholder = string.valueof(cs.L8A_Stakeholder__c).left(15);
                mapOfUserIdWithUser.put(L8A_Stakeholder,null);
            }
        }
    }
    
    if(mapOfUserIdWithUser.size()>0){
        for(user us :[select id,email,MobilePhone from user where id in :mapOfUserIdWithUser.keyset()]){
            string userid = string.valueof((us.id)).left(15);
            mapOfUserIdWithUser.put(userid,us); 
        }
    }
    if(mapOfCaseIdWithCase.size()>0){
        for(case cs : [select id,Mobile_Number__c,Email__c,Case_Sub_Type__c,Channel__c,Business_Area__c,Model__c,Variant__c,Primary_Category__c,Secondary_Category__c,Tertiary_Category__c
                     ,Case_Stage__c,Case_Type__c,Region_Code__c,First_Name__c,Middle_name__c,last_Name__c,Dealer_Address__c,Dealer_Name__c,Dealer_Code__c,Zone__c,Description,Additional_Information__c,
                     FCR_Conducted__c,Customer_Satisfied_With_FCR__c,Origin,Mode__c,createdDate,Next_Escalation_Date__c,CCP_Status__c,MSIL_Remarks__c from Case where id in : mapOfCaseIdWithCase.keyset()]){
                        mapOfCaseIdWithCase.put(cs.id,cs); 
                        if(cs.Dealer_Name__c!=null){
                            mapOfDealerIdWithName.put(cs.Dealer_Name__c,null);
                        }if(cs.Variant__c!=null){
                            mapOfVaraintIdWithName.put(cs.Variant__c,null);
                        }
                     }
    }
    
    
    if(mapOfDealerIdWithName.size()>0){
        for(Account acc : [Select Name,Id from Account where id in :mapOfDealerIdWithName.keyset()]){
            mapOfDealerIdWithName.put(acc.id,acc.name); 
        }
    }
    if(mapOfVaraintIdWithName.size()>0){
        for(Product2 prod : [Select Name,Id from Product2 where id in :mapOfVaraintIdWithName.keyset()]){
            mapOfVaraintIdWithName.put(prod.id,prod.name); 
        }
    }
    if(trigger.isInsert){
        system.debug('called2');
        MCCommunicationService.insertCaseAction(triggerNewList,mapOfCaseIdWithCase,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser);
    }else if(trigger.isUpdate){
        MCCommunicationService.updateCaseAction(triggerNewList,triggerOldMap,mapOfCaseIdWithCase,mapOfDealerIdWithName,mapOfVaraintIdWithName,mapOfUserIdWithUser);
    }
    }
    catch(Exception e){
      
    ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'createMCRecordsForCaseAction', '', null);  
    }
    }
     /**
  Author: Gitika 
  Company: Techmatrix
  Description: Class is used to create MC COMMUNICATION Records for caseAction Insert
  History:
  * Ver         Date                     Author                    Modification
  *==============================================================================
  * 1.0        29/07/2020               Gitika              Initial Version
  **/
  
  public static void insertCaseAction(List<Case_actions__C> triggerNewList,map<string,Case> mapOfCaseIdWithCase,map<string,String> mapOfDealerIdWithName,map<string,String> mapOfVaraintIdWithName,map<string,user> mapOfUserIdWithUser) {
    try{
        
        list<MC_Communication__c> MCCommunicationlist = new list<MC_Communication__c>();
        map<string,recordtype> mapofIdWithRecordtype = new map<string,recordtype>();
        for(Case_actions__c cs : triggerNewList){
            if(cs.case_number__c!=null){
                mapofIdWithRecordtype.put(cs.recordtypeId,null);
            }
        }
      if(mapofIdWithRecordtype.size()>0){
          for(recordtype recd : [select developername,id from recordtype where id in:mapofIdWithRecordtype.keyset()]){
            mapofIdWithRecordtype.put(recd.id,recd);
          }
      }
        for(Case_actions__c cs : triggerNewList){
            if(cs.case_number__c!=null){
            MC_Communication__c mcRecordStakeholder = new MC_Communication__c();
            mcRecordStakeholder= MCCommunicationService.getMCComCaseMapping(mapOfCaseIdWithCase.get(cs.case_number__c),mcRecordStakeholder,null,null,mapOfDealerIdWithName,mapOfVaraintIdWithName);
            mcRecordStakeholder.To_Address__c=null;
            mcRecordStakeholder.CC_Address__c=null;
            mcRecordStakeholder.case__c=cs.case_number__c;
            mcRecordStakeholder.Case_Action__c=cs.id;
            if(mapofIdWithRecordtype.containskey(cs.recordtypeId)){
                if(ConstantsUtility.recordtypeNameWithMCtYPE.containsKey(mapofIdWithRecordtype.get(cs.recordtypeId).developername)){
                    mcRecordStakeholder.Type__c=ConstantsUtility.recordtypeNameWithMCtYPE.get(mapofIdWithRecordtype.get(cs.recordtypeId).developername);
                }
            }
          
            mcRecordStakeholder.Status__c='Queued';
            mcRecordStakeholder.Communication_Type__c ='Email';
            if(cs.L2A_Stakeholder__c != null && cs.L3A_Stakeholder__c != null && cs.L2A_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L2A_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L3A_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L3A_Stakeholder__c).left(15)).email;  
                }

            }else if(cs.L3A_Stakeholder__c != null && cs.L4_Stakeholder__c != null && cs.L3A_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L3A_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L4_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L4_Stakeholder__c).left(15)).email;  
                }
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L3A_Stakeholder__c).left(15))){
                    mcRecordStakeholder.CC_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L3A_Stakeholder__c).left(15)).email;  
                }
            }else if(cs.L4_Stakeholder__c != null && cs.L5_Stakeholder__c != null && cs.L4_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L4_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L5_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L5_Stakeholder__c).left(15)).email;  
                }
                string ccEmail='';
                for(string str : ConstantsUtility.ccMap.get('L4_Stakeholder__c').split(',')){
                    
                    if(cs.get(str)!=null && mapOfUserIdWithUser.containsKey(string.valueof(cs.get(str)).left(15))){
                       ccEmail=ccEmail+mapOfUserIdWithUser.get(string.valueof(cs.get(str)).left(15)).email+',';     
                    }
                    mcRecordStakeholder.CC_Address__c=ccEmail.removeEnd(',');
                }
            }else if(cs.L5_Stakeholder__c != null && cs.L6A_Stakeholder__c != null && cs.L5_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L5_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L6A_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L6A_Stakeholder__c).left(15)).email;  
                } 
                string ccEmail='';
                for(string str : ConstantsUtility.ccMap.get('L5_Stakeholder__c').split(',')){
                    
                    if(cs.get(str)!=null && mapOfUserIdWithUser.containsKey(string.valueof(cs.get(str)).left(15))){
                       ccEmail=ccEmail+mapOfUserIdWithUser.get(string.valueof(cs.get(str)).left(15)).email+',';     
                    }
                    mcRecordStakeholder.CC_Address__c=ccEmail.removeEnd(',');
                }
            }else if(cs.L6A_Stakeholder__c != null && cs.L7A_Stakeholder__c != null && cs.L6A_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L6A_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L7A_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L7A_Stakeholder__c).left(15)).email;  
                }
                string ccEmail='';
                for(string str : ConstantsUtility.ccMap.get('L6A_Stakeholder__c').split(',')){
                    
                    if(cs.get(str)!=null && mapOfUserIdWithUser.containsKey(string.valueof(cs.get(str)).left(15))){
                       ccEmail=ccEmail+mapOfUserIdWithUser.get(string.valueof(cs.get(str)).left(15)).email+',';     
                    }
                    mcRecordStakeholder.CC_Address__c=ccEmail.removeEnd(',');
                }
            }else if(cs.L7A_Stakeholder__c != null &&  cs.L8A_Stakeholder__c != null && cs.L7A_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L7A_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L8A_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L8A_Stakeholder__c).left(15)).email;  
                }
                string ccEmail='';
                for(string str : ConstantsUtility.ccMap.get('L7A_Stakeholder__c').split(',')){
                    
                    if(cs.get(str)!=null && mapOfUserIdWithUser.containsKey(string.valueof(cs.get(str)).left(15))){
                       ccEmail=ccEmail+mapOfUserIdWithUser.get(string.valueof(cs.get(str)).left(15)).email+',';     
                    }
                    mcRecordStakeholder.CC_Address__c=ccEmail.removeEnd(',');
                }
            }else if(cs.L8A_Stakeholder__c != null && cs.L9_Stakeholder__c != null && cs.L8A_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L8A_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L9_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L9_Stakeholder__c).left(15)).email;  
                }
                string ccEmail='';
                for(string str : ConstantsUtility.ccMap.get('L8A_Stakeholder__c').split(',')){
                    
                    if(cs.get(str)!=null && mapOfUserIdWithUser.containsKey(string.valueof(cs.get(str)).left(15))){
                       ccEmail=ccEmail+mapOfUserIdWithUser.get(string.valueof(cs.get(str)).left(15)).email+',';     
                    }
                    mcRecordStakeholder.CC_Address__c=ccEmail.removeEnd(',');
                }
            }else if(cs.L9_Stakeholder__c != null && cs.L10_Stakeholder__c != null && cs.L9_Stakeholder__c==userinfo.getUserId() && cs.ownerid == cs.L9_Stakeholder__c){
                if(mapOfUserIdWithUser.containsKey(string.valueof(cs.L10_Stakeholder__c).left(15))){
                    mcRecordStakeholder.To_Address__c=mapOfUserIdWithUser.get(string.valueof(cs.L10_Stakeholder__c).left(15)).email;  
                }
                string ccEmail='';
                for(string str : ConstantsUtility.ccMap.get('L9_Stakeholder__c').split(',')){
                    
                    if(cs.get(str)!=null && mapOfUserIdWithUser.containsKey(string.valueof(cs.get(str)).left(15))){
                       ccEmail=ccEmail+mapOfUserIdWithUser.get(string.valueof(cs.get(str)).left(15)).email+',';     
                    }
                    mcRecordStakeholder.CC_Address__c=ccEmail.removeEnd(',');
                }
            }
            MCCommunicationlist.add(mcRecordStakeholder);
        }
    }
    if(MCCommunicationlist.size()>0){
        insert MCCommunicationlist;
    }
    }
    catch(Exception e){
      
        ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'insertCaseAction', '', null);  
        }
  }
      /**
  Author: Gitika 
  Company: Techmatrix
  Description: Class is used to create MC COMMUNICATION Records for caseAction update
  History:
  * Ver         Date                     Author                    Modification
  *==============================================================================
  * 1.0        29/07/2020               Gitika              Initial Version
  **/
  public static void updateCaseAction(List<Case_actions__C> triggerNewList,map<id,Case_actions__C> triggerOldMap,map<string,Case> mapOfCaseIdWithCase,map<string,String> mapOfDealerIdWithName,map<string,String> mapOfVaraintIdWithName,map<string,user> mapOfUserIdWithUser) {
    try{
        
    map<string,string> mapOfCaseAccIdWithMCEmailType = new map<string,string>();
    list<MC_Communication__c> MCCommunicationlist = new list<MC_Communication__c>();
    list<Case_actions__C> caseActionslist = new list<Case_actions__C>();
    set<string> approvalRecordIds = new set<string>();
    approvalRecordIds.add(ConstantsUtility.DUPLICATE_CASE_ACTION_RECORD_TYPE_ID);
    approvalRecordIds.add(ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID);
    approvalRecordIds.add(ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID);
    approvalRecordIds.add(ConstantsUtility.DEALER_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID);

    for(Case_actions__c cs : triggerNewList){
        if(cs.case_number__c != null && string.isNotBlank(cs.MC_Email_Communication_Type__c) && cs.MC_Email_Communication_Type__c!=triggerOldMap.get(cs.id).MC_Email_Communication_Type__c){
               string email='';
               MC_Communication__c mcRecordStakeholder = new MC_Communication__c();
               if(mapOfCaseIdWithCase.containsKey(cs.case_number__c))
               mcRecordStakeholder= MCCommunicationService.getMCComCaseMapping(mapOfCaseIdWithCase.get(cs.case_number__c),mcRecordStakeholder,null,null,mapOfDealerIdWithName,mapOfVaraintIdWithName);
               mcRecordStakeholder.To_Address__c=null;
               mcRecordStakeholder.CC_Address__c=null;
               mcRecordStakeholder.case__c=cs.case_number__c;
               mcRecordStakeholder.Case_Action__c=cs.id;
               mcRecordStakeholder.Type__c=cs.MC_Email_Communication_Type__c;
               mcRecordStakeholder.Status__c='Queued';
               mcRecordStakeholder.Communication_Type__c ='Email';
               if(approvalRecordIds.contains(cs.recordtypeId) && cs.Approved_Rejection_Notifiers__c!=null){
                   for(string str : cs.Approved_Rejection_Notifiers__c.split(',')){
                       if(str.length()>15)
                       str = str.left(15);
                       if(mapOfUserIdWithUser.containsKey(str)){
                           email=email+mapOfUserIdWithUser.get(str).email+',';
                       }
                   } 
                   email=email.removeEnd(',');
                   mcRecordStakeholder.To_Address__c=email;
               }
               MCCommunicationlist.add(mcRecordStakeholder);
               caseActionslist.add(new Case_actions__c(id=cs.id,MC_Email_Communication_Type__c=null));
            }
        }
        if(MCCommunicationlist.size()>0){
            insert MCCommunicationlist;
            TriggerHandler.bypass('CaseActionsTriggerHandler');
               System.debug(caseActionslist);
               update caseActionslist;
            TriggerHandler.clearBypass('CaseActionsTriggerHandler');
        }
     

    }
    catch(Exception e){
      
        ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'updateCaseAction', '', null);  
        }
  }
    
/**
Author: Gitika
Company: Techmatrix
Description: Method to get MC Communication mapping with Case
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
public static MC_Communication__c getMCComCaseMapping(Case caseObj,MC_Communication__c mcRecordStakeholder,
                                                     String Type,map<String,MC_Communication__c> mapOfMCTypeWithmcComRecord,
                                                     map<string, String> mapOfDealerIdWithName,map<string, String> mapOfVaraintIdWithName){

mcRecordStakeholder.Phone_2__c=String.isNotBlank(caseObj.Mobile_Number__c) ? caseObj.Mobile_Number__c : NULL;
mcRecordStakeholder.Email_2__c = String.isNotBlank(caseObj.Email__c) ? caseObj.Email__c : NULL;
mcRecordStakeholder.General_Field_1__c=String.isNotBlank(caseObj.Case_Sub_Type__c) ? caseObj.Case_Sub_Type__c : NULL;
mcRecordStakeholder.CC_Address__c= String.isNotBlank(caseObj.Channel__c) ? caseObj.Channel__c : NULL;
mcRecordStakeholder.General_Field_3__c= String.isNotBlank(caseObj.Business_Area__c) ? caseObj.Business_Area__c : NULL;
if(String.isNotBlank(caseObj.Model__c) || String.isNotBlank(caseObj.Variant__c) ){
string customerVehicle = '';
customerVehicle = String.isNotBlank(caseObj.Model__c) ? caseObj.Model__c : '';
customerVehicle = customerVehicle + (String.isNotBlank(caseObj.Variant__c) ? (mapOfVaraintIdWithName.containskey(caseObj.Variant__c)? ' '+mapOfVaraintIdWithName.get(caseObj.Variant__c) :'') : '');
mcRecordStakeholder.General_Field_7__c= customerVehicle;
}

mcRecordStakeholder.General_Field_5__c= String.isNotBlank(caseObj.Primary_Category__c) ? caseObj.Primary_Category__c : NULL;
mcRecordStakeholder.General_Field_10__c= String.isNotBlank(caseObj.Secondary_Category__c) ? caseObj.Secondary_Category__c : NULL;
mcRecordStakeholder.General_Field_4__c= String.isNotBlank(caseObj.Tertiary_Category__c) ? caseObj.Tertiary_Category__c : NULL;
mcRecordStakeholder.General_Field_8__c= String.isNotBlank(caseObj.Case_Stage__c) ? caseObj.Case_Stage__c : NULL;
mcRecordStakeholder.General_Field_9__c= String.isNotBlank(caseObj.Case_Type__c) ? caseObj.Case_Type__c : NULL;
mcRecordStakeholder.General_Field_6__c= String.isNotBlank(caseObj.Region_Code__c) ? caseObj.Region_Code__c : NULL;
mcRecordStakeholder.Customer_Field_1__c= String.isNotBlank(caseObj.First_Name__c) ? caseObj.First_Name__c : NULL;
mcRecordStakeholder.Customer_Field_2__c= String.isNotBlank(caseObj.Middle_name__c) ? caseObj.Middle_name__c : NULL;
mcRecordStakeholder.Customer_Field_3__c=String.isNotBlank(caseObj.last_Name__c) ? caseObj.last_Name__c : NULL;
mcRecordStakeholder.Dealer_Field_2__c=String.isNotBlank(caseObj.Dealer_Address__c) ? caseObj.Dealer_Address__c : NULL;
mcRecordStakeholder.Dealer_Field_1__c= String.isNotBlank(caseObj.Dealer_Name__c) ? (mapOfDealerIdWithName.containskey(caseObj.Dealer_Name__c) ? mapOfDealerIdWithName.get(caseObj.Dealer_Name__c) : Null) : NULL;
mcRecordStakeholder.Dealer_Field_3__c= String.isNotBlank(caseObj.Dealer_Code__c) ? caseObj.Dealer_Code__c : NULL;
mcRecordStakeholder.Dealer_Field_4__c= String.isNotBlank(caseObj.Zone__c) ? caseObj.Zone__c : NULL;
mcRecordStakeholder.Internal_User_1__c=String.isNotBlank(caseObj.Description) ? caseObj.Description : NULL;
mcRecordStakeholder.Internal_User_2__c=String.isNotBlank(caseObj.Additional_Information__c) ? caseObj.Additional_Information__c : NULL;
mcRecordStakeholder.Internal_User_3__c=String.isNotBlank(caseObj.FCR_Conducted__c) ? caseObj.FCR_Conducted__c : NULL;
mcRecordStakeholder.Internal_User_4__c=String.isNotBlank(caseObj.Customer_Satisfied_With_FCR__c) ? caseObj.Customer_Satisfied_With_FCR__c : NULL;
mcRecordStakeholder.To_Address__c=String.isNotBlank(caseObj.Origin) ? caseObj.Origin : NULL;
mcRecordStakeholder.Customer_Field_4__c=String.isNotBlank(caseObj.Mode__c) ? caseObj.Mode__c : NULL;
mcRecordStakeholder.Date_2__c=caseObj.createdDate!=null ? date.valueof(caseObj.createdDate) : NULL;
mcRecordStakeholder.Escalation_Date_Time__c=caseObj.Next_Escalation_Date__c!=null ? caseObj.Next_Escalation_Date__c : NULL;
mcRecordStakeholder.General_Field_11__c= String.isNotBlank(caseObj.CCP_Status__c) ? caseObj.CCP_Status__c : NULL;
mcRecordStakeholder.General_Field_12__c= String.isNotBlank(caseObj.MSIL_Remarks__c) ? caseObj.MSIL_Remarks__c : NULL;


return mcRecordStakeholder;  
}
/**
Author: Gitika
Company: Techmatrix
Description: Method to get MC Communication mapping with Case
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
public static MC_Communication__c getMCComForCustomer(case caseObj,MC_Communication__c mcRecordCustomer, Map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails
              ,map<string,user> mapOfUserIdWithUser) {

mcRecordCustomer.General_Field_9__c= String.isNotBlank(caseObj.Case_Type__c) ? caseObj.Case_Type__c : NULL;
mcRecordCustomer.Customer_Field_1__c= String.isNotBlank(caseObj.Customer__c) ? caseObj.Customer__c : NULL;
mcRecordCustomer.Customer_Field_2__c= String.isNotBlank(caseObj.SVOC_ID__c) ? caseObj.SVOC_ID__c : NULL;
mcRecordCustomer.Email_1__c = String.isNotBlank(caseObj.Email__c) ? caseObj.Email__c : NULL;
for(String str : mapOFStakeholderWithdetails.keyset()){

// L2A Stakeholder
if(str==ConstantsUtility.L2A){
if(mapOFStakeholderWithdetails.get(str).phone != null){
mcRecordCustomer.put(ConstantsUtility.PHONE_2_FIELD,mapOFStakeholderWithdetails.get(str).phone);
}
if(mapOFStakeholderWithdetails.get(str).recordId.length()>15){
mapOFStakeholderWithdetails.get(str).recordId=mapOFStakeholderWithdetails.get(str).recordId.left(15); 
}
if(mapOfUserIdWithUser.containsKey(mapOFStakeholderWithdetails.get(str).recordId)){
string namel2a = mapOfUserIdWithUser.get(mapOFStakeholderWithdetails.get(str).recordId).firstname+' '+mapOfUserIdWithUser.get(mapOFStakeholderWithdetails.get(str).recordId).lastname;
mcRecordCustomer.put(ConstantsUtility.DEALER_1_FIELD,namel2a);
}
}
// L2b Stakeholder
if(str==ConstantsUtility.L2B){
if(mapOFStakeholderWithdetails.get(str).phone != null){
mcRecordCustomer.put(ConstantsUtility.PHONE_3_FIELD,mapOFStakeholderWithdetails.get(str).phone);
}
if(mapOFStakeholderWithdetails.get(str).recordId.length()>15){
mapOFStakeholderWithdetails.get(str).recordId=mapOFStakeholderWithdetails.get(str).recordId.left(15); 
}
if(mapOfUserIdWithUser.containsKey(mapOFStakeholderWithdetails.get(str).recordId)){
string namel2b = mapOfUserIdWithUser.get(mapOFStakeholderWithdetails.get(str).recordId).firstname+' '+mapOfUserIdWithUser.get(mapOFStakeholderWithdetails.get(str).recordId).lastname;
mcRecordCustomer.put(ConstantsUtility.DEALER_2_FIELD,namel2b);
}
}
// L3A Stakeholder
if(str==ConstantsUtility.L3A){
if(mapOFStakeholderWithdetails.get(str).phone != null){
mcRecordCustomer.put(ConstantsUtility.PHONE_4_FIELD,mapOFStakeholderWithdetails.get(str).phone);
}
if(mapOFStakeholderWithdetails.get(str).email != null){
  mcRecordCustomer.L3A_Email__c=mapOFStakeholderWithdetails.get(str).email;
  }
if(mapOFStakeholderWithdetails.get(str).recordId.length()>15){
mapOFStakeholderWithdetails.get(str).recordId=mapOFStakeholderWithdetails.get(str).recordId.left(15); 
}
if(mapOfUserIdWithUser.containsKey(mapOFStakeholderWithdetails.get(str).recordId)){
string name = mapOfUserIdWithUser.get(mapOFStakeholderWithdetails.get(str).recordId).firstname+' '+mapOfUserIdWithUser.get(mapOFStakeholderWithdetails.get(str).recordId).lastname;
mcRecordCustomer.put(ConstantsUtility.DEALER_3_FIELD,name);
}
}
}
return mcRecordCustomer;
}
 /**
    Author: Gitika
    Company: Techmatrix
    Description: Method to get stakeholder Mapping with respect to CaseID
    Returns: void
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0                                                           Initial Version
    **/
    
    public static map<Id, map<string, StakeholderHierarchy.Sales>> mapOfcaseIdWithMapOfStakeHolders(list<case> caselist,String mapKeyField) {
      // map of case id with stakeholder map with Field name and recordid
      map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeholdermap = new map<Id, map<string, StakeholderHierarchy.Sales>>();
      
      for (case cs : caselist) {
      if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null) {
          // calling helper method to get stakeholder mapping with respect to each case id
          mapOfCaseIdWithStakeholdermap.put(cs.id, MCCommunicationService.getStakeHolderMapping(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c,mapKeyField));
      }
      }
      
      return mapOfCaseIdWithStakeholdermap;
      
      }
      /**
      Author: Gitika
      Company: Techmatrix
      Description: Helper  Method to get stakeholder Mapping
      Returns: void
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
      * 1.0                                                           Initial Version
      **/
      public static map<string, StakeholderHierarchy.Sales> getStakeHolderMapping(String stakeholderHierarchyString, String selectedHierarchyType,String mapKeyField) {
      // map of stakeHolder Field name and recordid
      map<string, StakeholderHierarchy.Sales> mapOfStakeholders = new map<string, StakeholderHierarchy.Sales>();
      // parsing JSON with help of parseStakeholderHierarchyJson method
      List<StakeholderHierarchy.Sales> hierarchyList = StakeholderUtility.getSelectedHierarchyList(stakeholderHierarchyString, selectedHierarchyType);
      
      for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {
      if(mapKeyField==ConstantsUtility.STAKEHOLDER){
          if (string.isNotBlank(stakeholders.recordId) && string.isNotBlank(stakeholders.stakeHolder)) {
              mapOfStakeholders.put(stakeholders.stakeHolder, stakeholders);
              
          }
      }else if(mapKeyField==ConstantsUtility.REFNAME){
          if (string.isNotBlank(stakeholders.recordId) && string.isNotBlank(stakeholders.refName)) {
              mapOfStakeholders.put(stakeholders.refName, stakeholders); 
          }
          
      }
      
      }
      return mapOfStakeholders;
      } 
      /**
      Author: Gitika 
      Company: Techmatrix
      Description: method is used to get MC_Communication_SOQLs__mdt
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
      * 1.0        29/07/2020               Gitika              Initial Version
      **/
      public static map<string, List<MC_Communication_SOQLs__mdt>> getmcCommunicationMatrices(String eventType) {
      
      map<string, List<MC_Communication_SOQLs__mdt>> mcCommunicationMap = new map<string, List<MC_Communication_SOQLs__mdt>>();
      
      for (MC_Communication_SOQLs__mdt mcCommunicationMatrices : [SELECT Id,Event_Type__c,MC_Communication_Fields__c,Process_Type__c,Recipients__c,
                                                                  Source_Fields__c,Source_SOQL__c	,MasterLabel,Communication_Type__c
                                                                  FROM MC_Communication_SOQLs__mdt
                                                                  where Event_Type__c = :eventType]) {
          string Key;
          if(eventType=='Create'){
            Key=string.isNotBlank(mcCommunicationMatrices.Process_Type__c)?mcCommunicationMatrices.Process_Type__c:'';
        }else{
            Key=string.isNotBlank(mcCommunicationMatrices.MasterLabel)?mcCommunicationMatrices.MasterLabel:'';  
        }
          if(Key.length()>0){
              if(mcCommunicationMap.containsKey(Key)){
                  mcCommunicationMap.get(Key).add(mcCommunicationMatrices);
              }else{
                  List<MC_Communication_SOQLs__mdt> mcList = new List<MC_Communication_SOQLs__mdt>();
                  mcList.add(mcCommunicationMatrices);
                  mcCommunicationMap.put(Key,mcList);
              }
          }
         
          
      }
      return mcCommunicationMap;
      }
      /**
      Author: Gitika
      Company: Techmatrix
      Description: Method to get stakeholder Mapping with respect to CaseID For MSIL Query
      Returns: void
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
      * 1.0                                                           Initial Version
      **/
      
      public static map<Id, map<string, string>> mapOfcaseIdWithMapOfStakeHoldersMSILQuery(list<case> caselist) {
      // map of case id with stakeholder map with Field name and recordid
      map<Id, map<string, string>> mapOfCaseIdWithStakeholdermap = new map<Id, map<string, string>>();
      Set<Id> categoryIdSet = new Set<Id>();
      Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();
      
      for (case cs : caselist) {
      if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null && cs.RecordtypeId==ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID) {
      categoryIdSet.add(MCCommunicationService.getCategoryId(cs));
      }
      }
      if(categoryIdSet.size()>0){
      categoryIdVsMapOfRegionAndRecipientMasterMap = CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(categoryIdSet);
      for (case cs : caselist) {
      map<string,string> mapOfStakeholderMapping = new map<string,string>();
      Map<String, Recipient_Master__c> regionWithRecipientMaster = new Map<String, Recipient_Master__c>();
      if (string.isNotBlank(cs.Stakeholders_JSON__c) && cs.Selected_Hierarchy_Type__c != null && cs.RecordtypeId==ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID) {
          String categoryId=MCCommunicationService.getCategoryId(cs)!=null?getCategoryId(cs):'';
          if(categoryId.length()>0 && categoryIdVsMapOfRegionAndRecipientMasterMap.containskey(categoryId)){
              regionWithRecipientMaster = categoryIdVsMapOfRegionAndRecipientMasterMap.get(categoryId);
              Recipient_Master__c recipientMasterRecord = regionWithRecipientMaster.containsKey(cs.Region_Code__c) ? regionWithRecipientMaster.get(cs.Region_Code__c) : (regionWithRecipientMaster.containsKey(ConstantsUtility.REGION_ALL) ? regionWithRecipientMaster.get(ConstantsUtility.REGION_ALL) : null);
              if(recipientMasterRecord.Level_1_To__c!=null && MCCommunicationService.getStakeHolderMappingForMSILQuery(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c).containsKey((recipientMasterRecord.Level_1_To__c).split(';')[0])){
              
              mapOfStakeholderMapping.put(ConstantsUtility.L3A_Email_FIELD,MCCommunicationService.getStakeHolderMappingForMSILQuery(cs.Stakeholders_JSON__c, cs.Selected_Hierarchy_Type__c).get((recipientMasterRecord.Level_1_To__c).split(';')[0]));
              }
          }
          // calling helper method to get stakeholder mapping with respect to each case id
          mapOfCaseIdWithStakeholdermap.put(cs.id,mapOfStakeholderMapping);
      }
      }
      }
      return mapOfCaseIdWithStakeholdermap;
      
      }
      /**
      Author: Gitika
      Company: Techmatrix
      Description: Method to get CategoryId
      Returns: void
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
      * 1.0                                                           Initial Version
      **/
      private static Id getCategoryId(Case caseObj) {
      String categoryId;
      if (caseObj.Tertiary_Category_ID__c != null) {
      categoryId = caseObj.Tertiary_Category_ID__c;
      } else if (caseObj.Secondary_Category_ID__c != null) {
      categoryId = caseObj.Secondary_Category_ID__c;
      } else if (caseObj.Primary_Category_ID__c != null) {
      categoryId = caseObj.Primary_Category_ID__c;
      }
      return categoryId;
      }
      /**
      Author: Gitika
      Company: Techmatrix
      Description: Helper  Method to get stakeholder Mapping For MSIL Query
      Returns: void
      History:
      * Ver         Date                     Author                    Modification
      *==============================================================================
      * 1.0                                                           Initial Version
      **/
      
      public static map<string, string> getStakeHolderMappingForMSILQuery(String stakeholderHierarchyString, String selectedHierarchyType) {
      // map of stakeHolder Field name and recordid
      map<string, string> mapOfStakeholders = new map<string, string>();
      // parsing JSON with help of parseStakeholderHierarchyJson method
      List<StakeholderHierarchy.Sales> hierarchyList = new List<StakeholderHierarchy.Sales>(); // LIst to iterate the list of the stake holders
      hierarchyList =  StakeholderUtility.getSelectedHierarchyList(stakeholderHierarchyString,selectedHierarchyType);
      for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {
      
      if (string.isNotBlank(stakeholders.recordId) && string.isNotBlank(stakeholders.stakeHolder) && string.isNotBlank(stakeholders.email)) {
          mapOfStakeholders.put(stakeholders.stakeHolder, stakeholders.email);
      }
      }
      return mapOfStakeholders;
      }
      }