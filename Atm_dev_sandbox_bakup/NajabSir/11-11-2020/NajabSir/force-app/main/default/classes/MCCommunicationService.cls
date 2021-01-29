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
    Author: Nitin 
    Company: Techmatrix
    Description: Method to get date on the basis of working hours
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        10/11/2020               Nitin              Initial Version
**/
    public static DateTime getNextEscalatedDateTime(Id businessHourId,Datetime startDate,integer minutes){
        Long milisec=60000*minutes;
        return BusinessHours.add(businessHourId,startDate,milisec);
    }
    
    
    /**
    Author: Nitin 
    Company: Techmatrix
    Description: Method to create MC record When Case is pending for Cuystomer Respinse & post 4 hr of Case creation(Suzuki Connect)
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        10/11/2020               Nitin              Initial Version
**/

    public static void suzukiConnectMcRecCreation(List<case> triggerNewList,map<id,Case> triggerOldMap){
        try{
            List<MC_Communication__c> mcComList = new List<MC_Communication__c>();
            List<String> panaCrmStatus=(label.Pana_Status).split(';');
            Map<Id,Case> IdCaseMap= new Map<Id,Case>();
            for(Case cs: triggerNewList){
                if(cs.RecordtypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && cs.Primary_Category__c==ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT 
                   && cs.BusinessHoursId!=null && cs.IsClosed==false){
                       IdCaseMap.put(cs.Id,cs);
                   }
            }
            if(IdCaseMap.size()>0){
                Constant_Value__c cv = ProjectUtility.getConstantValue('Suzuki Connect'); //Added on 18/12/2020
                for(MC_Communication__c mc : [Select Id,Status__c,Type__c,Case__c From MC_Communication__c where Status__c=:ConstantsUtility.MC_Communication_Status_Queued
                                              AND Case__c IN:IdCaseMap.keyset()]){
                                                  if(IdCaseMap.get(mc.Case__c).status!=ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE && 
                                                     mc.Type__c ==ConstantsUtility.SUZUKI_CONNECT_ADDITIONAL_INFO){
                                                         MC_Communication__c communication = new MC_Communication__c();
                                                         communication.Id=mc.Id;
                                                         communication.Status__c=ConstantsUtility.CANCELLED;
                                                         mcComList.add(communication);
                                                     }
                                                  if(IdCaseMap.get(mc.Case__c).status!=ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE &&
                                                     mc.Type__c ==ConstantsUtility.SUZUKI_CONNECT_CASE_AUTO_CLOSURE){
                                                         MC_Communication__c communication = new MC_Communication__c();
                                                         communication.Id=mc.Id;
                                                         communication.Status__c=ConstantsUtility.CANCELLED;
                                                         mcComList.add(communication);
                                                     }
                                                  else if(!panaCrmStatus.contains(IdCaseMap.get(mc.Case__c).Job_Status__c) && mc.Type__c ==ConstantsUtility.SUZUKI_CONNECT_IN_PROGRESS_CASE){
                                                      MC_Communication__c communication = new MC_Communication__c();
                                                      communication.Id=mc.Id;
                                                      communication.Status__c=ConstantsUtility.CANCELLED;
                                                      mcComList.add(communication);
                                                  }
                                              }
                
                for(Case cs: triggerNewList){
                    if(cs.RecordtypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && cs.Primary_Category__c==ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT
                       && cs.BusinessHoursId!=null && cs.IsClosed==false 
                      ){
                          if(triggerOldMap.get(cs.Id).Status!=cs.Status && cs.Status==ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE){
                              //When the Case is Pending Customer Response user needs to be notified after 3 & 7 days
                              MC_Communication__c mc = new MC_Communication__c(Status__c=ConstantsUtility.MC_Communication_Status_Queued,Communication_Type__c='SMS',Type__c=ConstantsUtility.SUZUKI_CONNECT_ADDITIONAL_INFO,Case__c = cs.Id,Recipient_Phone_Numbers__c=cs.Mobile_Number__c,Phone_2__c=cs.Mobile_Number__c,Escalation_Date_Time__c=getNextEscalatedDateTime(cv.Business_Hour__c,DateTime.valueOf(cs.LastModifiedDate),Integer.valueOf(label.X3_days_Minutes)));
                              MC_Communication__c mc1 = new MC_Communication__c(Status__c=ConstantsUtility.MC_Communication_Status_Queued,Communication_Type__c='SMS',Type__c=ConstantsUtility.SUZUKI_CONNECT_CASE_AUTO_CLOSURE,Case__c = cs.Id,Recipient_Phone_Numbers__c=cs.Mobile_Number__c,Phone_2__c=cs.Mobile_Number__c,Escalation_Date_Time__c=getNextEscalatedDateTime(cv.Business_Hour__c,DateTime.valueOf(cs.LastModifiedDate),Integer.valueOf(label.X7_days_Minutes)));
                              MC_Communication__c mc2 = new MC_Communication__c(Status__c=ConstantsUtility.MC_Communication_Status_Queued,Communication_Type__c='SMS',Type__c=ConstantsUtility.SUZUKI_CONNECT_ADDITIONAL_INFO,Case__c = cs.Id,Recipient_Phone_Numbers__c=cs.Mobile_Number__c,Phone_2__c=cs.Mobile_Number__c,Escalation_Date_Time__c=System.now());
                              mcComList.add(mc);mcComList.add(mc1);mcComList.add(mc2);
                          }
                          else if(cs.Status=='Work in Progress' && String.isNotBlank(cs.Job_Status__c) && triggerOldMap.get(cs.Id).Job_Status__c!=cs.Job_Status__c
                                  && panaCrmStatus.contains(cs.Job_Status__c) && !panaCrmStatus.contains(triggerOldMap.get(cs.Id).Job_Status__c)){
                                      /**Post 4 hours of case creation if the Pana status is one of the below
                                       1. Assigned, 2. Acknowledged, 3. Allocated, 4. Pending, 5. Pending for replacement approval, 
                                       6. Re-assigned/Book-in**/ 
                                      MC_Communication__c communication = new MC_Communication__c();
                                      communication.Status__c=ConstantsUtility.MC_Communication_Status_Queued;
                                      communication.Escalation_Date_Time__c=getNextEscalatedDateTime(cv.Business_Hour__c,DateTime.valueOf(cs.CreatedDate),Integer.valueOf(label.Post_4_Hr_MC_Record)*60);
                                      communication.Type__c = ConstantsUtility.SUZUKI_CONNECT_IN_PROGRESS_CASE;
                                      communication.Communication_Type__c='SMS';
                                      communication.Case__c = cs.Id;
                                      communication.Recipient_Phone_Numbers__c=cs.Mobile_Number__c;
                                      communication.Phone_2__c=cs.Mobile_Number__c;
                                      mcComList.add(communication);
                                  }
                          
                      }
                }
                if(mcComList.size()>0){
                    upsert mcComList;
                }
            }
        }
        catch (Exception e) {
            
            ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'suzukiConnectMcRecCreation', '', null);
        }
    }
    /**
Author: Sunit 
Company: Techmatrix
Description: Method to create MC record for SMS & Email to be send at the time of case creation(Suzuki Connect)
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        16/11/2020               Sunit              Initial Version
**/
    public static void suzukiConnectCaseCreationMcRecCreation(List<case> triggerNewList){
        /*try{
map<string, List<MC_Communication_SOQLs__mdt>> createEventMcCommunicationMap = new map<string, List<MC_Communication_SOQLs__mdt>>();
map<string, String> mapOfDealerIdWithName = new map<string, String>();
map<string, String> mapOfVaraintIdWithName = new map<string, String>();
// Caling Respective Methods
if(Trigger.IsInsert) {
createEventMcCommunicationMap= MCCommunicationService.getmcCommunicationMatrices(ConstantsUtility.CREATE);
MCCommunicationService.insertEvent(triggerNewList,createEventMcCommunicationMap,mapOfDealerIdWithName,mapOfVaraintIdWithName);
}
}
catch(Exception e){

ExceptionHandler.LogError('MCCommunicationService', e.getMessage() + e.getLineNumber(), 'suzukiConnectCaseCreationMcRecCreation', '', null);  
}*/
        try{
            List<MC_Communication__c> mcComList = new List<MC_Communication__c>();
            Set<Id> categoryIds = new Set<Id>(); // Set to store the lower most category id from the case
            List<Case> caseList=new List<Case>();
            Map<String, Map<String, Recipient_Master__c>> categoryIdVsMapOfRegionAndRecipientMasterMap = new Map<String, Map<String, Recipient_Master__c>>();
            for(Case cs: triggerNewList){
                if(cs.RecordtypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && cs.Primary_Category__c==ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT)
                {
                    categoryIds.add(CaseAssignmentService.getCategoryId(cs));
                    caseList.add(cs);
                }
            }
            if(categoryIds.size()>0){
                categoryIdVsMapOfRegionAndRecipientMasterMap = CaseAssignmentServiceHelper.getCategoryRecipientMasterMap(categoryIds);
                // stakeholder mapping
                map<Id, map<string, StakeholderHierarchy.Sales>> mapOfCaseIdWithStakeHolders = CaseEscalationService.mapOfcaseIdWithMapOfStakeHolders(caseList);
                
                for(Case cs: triggerNewList){
                    if(cs.RecordtypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && cs.Primary_Category__c==ConstantsUtility.SUZUKI_CONNECT_PRODUCT_COMPLAINT)
                    {
                        List<String> toNotifiers = new List<String>();
                        List<String> ccNotifiers = new List<String>();
                        List<String> toAddress = new List<String>();
                        List<String> ccAddres = new List<String>();
                        map<string, StakeholderHierarchy.Sales> mapOFStakeholderWithdetails = new map<string, StakeholderHierarchy.Sales>();
                        if( mapOfCaseIdWithStakeHolders.containskey(cs.Id) && mapOfCaseIdWithStakeHolders.get(cs.Id).size() > 0){
                            mapOFStakeholderWithdetails = mapOfCaseIdWithStakeHolders.get(cs.Id);
                        }
                        if(mapOFStakeholderWithdetails.size()>0){
                            toNotifiers=(categoryIdVsMapOfRegionAndRecipientMasterMap.get(cs.Secondary_Category_ID__c).get('All').Level_0_To__c).split('\\;');
                            ccNotifiers=(categoryIdVsMapOfRegionAndRecipientMasterMap.get(cs.Secondary_Category_ID__c).get('All').Level_0_Cc__c).split('\\;');
                        }
                        //Fetching TO Address for MC Record
                        if(toNotifiers.size()>0){
                            for (string str : toNotifiers) {
                                if(mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)){
                                    toAddress.add(mapOFStakeholderWithdetails.get(str).email);
                                }
                            }  
                        }//Fetching CC Address for MC Record
                        if(ccNotifiers.size()>0){
                            for (string str : ccNotifiers) {
                                if(mapOFStakeholderWithdetails.containskey(str) && string.isnotBlank(mapOFStakeholderWithdetails.get(str).email)){
                                    ccAddres.add(mapOFStakeholderWithdetails.get(str).email);
                                }
                            }
                        }
                        //Initial Case Assignment Notification Email
                        if(toAddress.size()>0 || ccAddres.size()>0){
                            MC_Communication__c mc = new MC_Communication__c();
                            mc.Case__c=cs.Id;
                            mc.To_Address__c=(String.valueOf(toAddress)).replaceAll('[()\\s+]','');
                            mc.CC_Address__c=(String.valueOf(ccAddres)).replaceAll('[()\\s+]','');
                            mc.Type__c=ConstantsUtility.COMPLAINT_REGISTRATION_DEALER;
                            mc.Escalation_Date_Time__c=System.Now();
                            mc.Status__c=ConstantsUtility.MC_Communication_Status_Queued;
                            mc.Communication_Type__c=ConstantsUtility.EMAIL;
                            mcComList.add(mc);
                        }
                        MC_Communication__c mc1 = new MC_Communication__c(Status__c=ConstantsUtility.MC_Communication_Status_Queued,Communication_Type__c='SMS',Type__c=ConstantsUtility.COMPLAINT_REGISTRATION_CUSTOMER,Case__c = cs.Id,Recipient_Phone_Numbers__c=cs.Mobile_Number__c,Phone_2__c=cs.Mobile_Number__c,Escalation_Date_Time__c=System.now());
                        mcComList.add(mc1);
                    }
                }
            }
            if(mcComList.size()>0){
                insert mcComList;
            }
            
        }
        catch(Exception ex){
            System.debug(ex.getStackTraceString());
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
                                        List<String> panaCrmStatus=(label.Pana_Status).split(';'); //Added by Nitin on 10th Nov
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
                                            system.debug('cs.case_type__c-->'+cs.case_type__c);
                                            system.debug('cs.Customer_Satisfied_With_FCR__c-->'+cs.Customer_Satisfied_With_FCR__c);
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
                                                                 if(string.isnotblank(caseObj.email__c)){
                                                                    mcRecordStakeholder= MCCommunicationService.getMCComForCustomer(caseObj,mcRecordStakeholder,mapOFStakeholderWithdetails,mapOfUserIdWithUser);
                                                                    mcRecordStakeholder.Communication_Type__c = mcComMetadata.Communication_Type__c!=null?mcComMetadata.Communication_Type__c:'';
                                                               }
                                                            }
                                                            else{
                                                                mcRecordStakeholder= MCCommunicationService.getMCComCaseMapping(caseObj,mcRecordStakeholder,null,null,mapOfDealerIdWithName,mapOfVaraintIdWithName);
                                                                mcRecordStakeholder.Communication_Type__c = mcComMetadata.Communication_Type__c!=null?mcComMetadata.Communication_Type__c:'';
                                                            }
                                                            
                                                            mcRecordStakeholder.case__c=caseObj.id;
                                                            mcRecordStakeholder.Type__c=mcComMetadata.MasterLabel;
                                                            /**** Added to update SMS triggering date for Case creation applicable for Suzuki connect only 
                                                             * (Added by Sunit) ****/
                                                            if(mcRecordStakeholder.Type__c==ConstantsUtility.COMPLAINT_REGISTRATION_CUSTOMER && 
                                                               caseObj.RecordTypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && 
                                                               mcComMetadata.Communication_Type__c=='SMS'){
                                                               System.debug('Inside if');
                                                               mcRecordStakeholder.Escalation_Date_Time__c=System.now();
                                                            }
                                                            /********************************************************************************************/
                                                            mcRecordStakeholder.date_1__c=caseObj.On_Hold_End_date__c!=null?caseObj.On_Hold_End_date__c:null;
                                                            mcRecordStakeholder.Status__c='Queued';
                                                            
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
                                                            mcRecordCustomer.Email_1__c = String.isNotBlank(caseObj.Email__c) ? caseObj.Email__c :' ';
                                                            system.debug('caseObj.Email__c-->'+caseObj.Email__c);
                                                            system.debug('mcRecordCustomer.Email_1__c-->'+mcRecordCustomer.Email_1__c);
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
                                                                Source_Fields__c,Source_SOQL__c   ,MasterLabel,Communication_Type__c
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