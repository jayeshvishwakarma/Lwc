/**
* @File Name          : CreateMcCommunicationRecord.cls
* @Description        : 
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-01-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    08/09/2020, 11:02:00 AM       Nitin Ghai             Initial Version
**/
public without sharing class CreateMcCommunicationRecord {
    
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will create MC Communication records that will be used for Case escaclation(Case Resolution)
Inputs: Case List and Case Old Map
Returns: 
History:
================
1.1A     24/08/2020, 11:02:00 AM      Nitin     Initial Version
*/
    public static void createInboundEscalationRecords(List<Case> newCaseList,Map<Id,Case> oldCaseList){

        //added to avoid raising escalation messages in sandboxes 
        Bypass_Setting__c bypassSetting = Bypass_Setting__c.getInstance(UserInfo.getUserId());
        if (bypassSetting.Skip_MC_Record_Creation__c == true)
            return;        

        List<MC_Communication__c> mcRecords = new List<MC_Communication__c>();
        Set<String> escalatedUserIDs= new Set<String>();
        Map<String, String> notificationMap = new Map<String, String>();
        Map<ID, String> caseUserIdMap = new Map<Id, String>();
        Map<Id,String> userIdPhoneMap = new Map<Id,String>();
        try{
            for (Dealer_Internal_Service_Escalation__c notificationSetting : [SELECT Name,Notification_Level__c FROM Dealer_Internal_Service_Escalation__c]) {
                notificationMap.put(notificationSetting.Name,notificationSetting.Notification_Level__c);
            }
            for(Case cs : newCaseList){
                if (String.isNotBlank(cs.Next_Escalation_Level__c) && cs.Next_Escalation_Date__c!=NULL && String.isNotBlank(cs.Inbound_Case_Hierarchy__c) && cs.IsClosed==False &&
                    (Trigger.isInsert|| (Trigger.isUpdate && oldCaseList.get(cs.Id).get('Next_Escalation_Date__c') != cs.Next_Escalation_Date__c))){
                        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(cs.Inbound_Case_Hierarchy__c);
                        if(result.size()>0 && result.containsKey(cs.Next_Escalation_Level__c)){
                            if(String.isNotBlank(cs.Business_Area__c) && (cs.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SERVICE_WORKSHOP || cs.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP) && notificationMap.size()>0 && String.isNotBlank(notificationMap.get(cs.Business_Area__c+'@@'+cs.Next_Escalation_Level__c))){
                                for(String lev : (notificationMap.get(cs.Business_Area__c+'@@'+cs.Next_Escalation_Level__c)).split(';')){
                                    if(String.isNotBlank((String.valueof(result.get((lev))).replaceAll('[()\\s+]','')))){
                                        escalatedUserIDs.addAll((String.valueof(result.get((lev))).replaceAll('[()\\s+]','')).split(','));
                                        if(!caseUserIdMap.containskey(cs.Id)){
                                            caseUserIdMap.put(cs.Id,String.valueof(result.get((lev))).replaceAll('[()\\s+]',''));
                                        }else{
                                            caseUserIdMap.put(cs.Id,caseUserIdMap.get(cs.Id)+','+String.valueof(result.get((lev))).replaceAll('[()\\s+]',''));
                                        }
                                    }
                                }
                            }
                            else if(String.isNotBlank((String.valueof(result.get((cs.Next_Escalation_Level__c))).replaceAll('[()\\s+]','')))){
                                escalatedUserIDs.addAll((String.valueof(result.get((cs.Next_Escalation_Level__c))).replaceAll('[()\\s+]','')).split(','));
                                caseUserIdMap.put(cs.Id,String.valueof(result.get((cs.Next_Escalation_Level__c))).replaceAll('[()\\s+]',''));
                            }
                        }
                    } 
            }
            if(escalatedUserIDs.size()>0){
                for(User us : [Select Id,Phone from User where Id IN: escalatedUserIDs AND isActive=True]){
                    userIdPhoneMap.put(us.Id,us.Phone);
                }
            }
            if(caseUserIdMap.size()>0){
                for(Case csRc : newCaseList){
                    if (caseUserIdMap.containsKey(csRc.Id) && String.isNotBlank(caseUserIdMap.get(csRc.Id))){
                        Set<String> escalatedUserRecIds= new Set<String>();
                        MC_Communication__c escalationRec = new MC_Communication__c();
                        escalationRec.Case__c=csRc.Id;
                        escalationRec.Type__c = ConstantsUtility.DEALER_INTERNAL_RESOLUTION_ESCALATION;
                        escalationRec.Escalation_Date_Time__c=csRc.Next_Escalation_Date__c;
                        escalationRec.Escalated_Level__c=csRc.Next_Escalation_Level__c;
                        escalationRec.Status__c=ConstantsUtility.DEALER_INTERNAL_MC_STATUS;
                        escalationRec.To_Address__c=caseUserIdMap.get(csRc.Id);
                        for(String usId : (escalationRec.To_Address__c).split(',')){
                            if(String.isNotBlank(escalationRec.Recipient_Phone_Numbers__c) && userIdPhoneMap.containsKey(usId) && String.isNotBlank(userIdPhoneMap.get(usId))){
                                escalationRec.Recipient_Phone_Numbers__c+=','+userIdPhoneMap.get(usId);
                            }else if(String.isBlank(escalationRec.Recipient_Phone_Numbers__c) && userIdPhoneMap.containsKey(usId) && String.isNotBlank(userIdPhoneMap.get(usId))){
                                escalationRec.Recipient_Phone_Numbers__c=userIdPhoneMap.get(usId);
                            }
                        }
                        mcRecords.add(escalationRec);
                    }
                }
                if(mcRecords.size()>0){
                    TriggerHandler.bypass('MCCommunicationTriggerHandler');
                    insert mcRecords;
                    TriggerHandler.clearbypass('MCCommunicationTriggerHandler');
                }
            }
        }catch(exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateMcCommunicationRecord';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateMcCommunicationRecord - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : createInboundEscalationRecords - Method', '', ehst);
        }
    }
    
    /**
Author: Prashant Gahlaut
Company: Techmatrix
Description: It will create MC Communication records that will be used for CCP Case escaclation
Inputs: Case Record, Outbound related record types
Returns: 
History:
===========================================================================================
1.1A     1/9/2020, 5:00:00PM      Prashant     Initial Version
1.1A     30/9/2020,11:00:00AM     Prashant     Modified Version
*/   
    public static void createCCPEscalationRecords(List<Case> newCaseList,Map<Id,Case> oldCaseList){

        //added to avoid raising escalation messages in sandboxes 
        Bypass_Setting__c bypassSetting = Bypass_Setting__c.getInstance(UserInfo.getUserId());        
        if (bypassSetting.Skip_MC_Record_Creation__c == true)
            return;        
        
        Map<Id,String> userIdPhoneMap = new Map<Id,String>();
        List<MC_Communication__c> mcRecords = new List<MC_Communication__c>();
        map<string,Case_Escalations_Matrix_MDT__c> ccpEscaltionMap = getEscalationsMatrices();
        String userIds;
        Map<ID, String> caseUserIdMap = new Map<Id, String>();
        Set<String> escalatedUserIDs= new Set<String>();
        try{
            for(Case cs : newCaseList){
                if (String.isNotBlank(cs.CCP_Next_Escalated_Level__c) && cs.CCP_Next_Escalation_Date_Time__c!=NULL &&
                    String.isNotBlank(cs.Inbound_Case_Hierarchy__c) && cs.IsClosed==False &&
                    (Trigger.isInsert == true || (Trigger.isUpdate == true && oldCaseList.get(cs.Id).CCP_Next_Escalation_Date_Time__c != cs.CCP_Next_Escalation_Date_Time__c))){
                        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(cs.Inbound_Case_Hierarchy__c);
                        if(result.size()>0 && result.containsKey(cs.CCP_Next_Escalated_Level__c)){
                            if(String.isNotBlank((String.valueof(result.get((cs.CCP_Next_Escalated_Level__c))).replaceAll('[()\\s+]','')))){
                                escalatedUserIDs.addAll((String.valueof(result.get((cs.CCP_Next_Escalated_Level__c))).replaceAll('[()\\s+]','')).split(','));
                                caseUserIdMap.put(cs.Id,String.valueof(result.get((cs.CCP_Next_Escalated_Level__c))).replaceAll('[()\\s+]',''));
                            }
                        }
                    } 
            }
            
            if(escalatedUserIDs.size()>0){
                for(User us : [Select Id,Phone from User where Id IN: escalatedUserIDs AND isActive=True]){
                    userIdPhoneMap.put(us.Id,us.Phone);
                }
             }
            if(caseUserIdMap.size()>0){
                for(Case csRec : newCaseList){
                    if (caseUserIdMap.containsKey(csRec.Id) && String.isNotBlank(caseUserIdMap.get(csRec.Id))){
                        String mainKey;
                        mainKey = (csRec.Channel__c!=null?csRec.Channel__c:'');
                        mainKey+= (csRec.Case_Type__c!=null?csRec.Case_Type__c:'');
                        mainKey+= (csRec.Business_Area__c!=null?csRec.Business_Area__c:'');
                        if(String.isNotBlank(mainKey) && ccpEscaltionMap.size()>0 && ccpEscaltionMap.containsKey(mainKey) 
                           && (trigger.isInsert || (trigger.isUpdate && oldCaseList.get(csRec.Id).CCP_Next_Escalation_Date_Time__c != csRec.CCP_Next_Escalation_Date_Time__c && oldCaseList.get(csRec.Id).CCP_Next_Escalated_Level__c != ccpEscaltionMap.get(mainKey).Highest_Level_Escalation__c)) 
                           && string.isNotBlank(csRec.Inbound_Case_Hierarchy__c) && String.isNotBlank(csRec.Channel__c) && String.isNotBlank(csRec.Case_Type__c) && String.isNotBlank(csRec.Business_Area__c) 
                           && csRec.Channel__c == ccpEscaltionMap.get(mainKey).Channel__c && csRec.Case_Type__c == ccpEscaltionMap.get(mainKey).Case_Type__c 
                           && csRec.Business_Area__c == ccpEscaltionMap.get(mainKey).Business_Area__c){
                               MC_Communication__c escalationRec = new MC_Communication__c();
                               escalationRec.Case__c=csRec.Id;
                               escalationRec.Type__c = ConstantsUtility.DEALER_INTERNAL_CCP_ESCALATION;
                               escalationRec.Escalation_Date_Time__c=csRec.CCP_Next_Escalation_Date_Time__c;
                               escalationRec.Escalated_Level__c=csRec.CCP_Next_Escalated_Level__c;
                               escalationRec.Status__c=ConstantsUtility.DEALER_INTERNAL_MC_STATUS;
                               escalationRec.To_Address__c=caseUserIdMap.get(csRec.Id);
                               for(String usId : (escalationRec.To_Address__c).split(',')){
                                   if(String.isNotBlank(escalationRec.Recipient_Phone_Numbers__c) && userIdPhoneMap.containsKey(usId) && String.isNotBlank(userIdPhoneMap.get(usId))){
                                       escalationRec.Recipient_Phone_Numbers__c+=','+userIdPhoneMap.get(usId);
                                   }else if(String.isBlank(escalationRec.Recipient_Phone_Numbers__c) && userIdPhoneMap.containsKey(usId) && String.isNotBlank(userIdPhoneMap.get(usId))){
                                       escalationRec.Recipient_Phone_Numbers__c=userIdPhoneMap.get(usId);
                                   }
                               }
                               mcRecords.add(escalationRec);
                           }
                    }
                }
            }
            if(mcRecords.size()>0){
                    TriggerHandler.bypass('MCCommunicationTriggerHandler');
                    insert mcRecords;
                    TriggerHandler.clearbypass('MCCommunicationTriggerHandler');
          }
        }catch(exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateMcCommunicationRecord';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateMcCommunicationRecord - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : createCCPEscalationRecords - Method', '', ehst);
        }
    } 
    /**
Author: Prashant Gahlaut
Company: Techmatrix
Description: method to fetch CCP escalation type metadata records
Inputs: 
Returns: 
History:
================
1.1A     1/9/2020, 5:30:00PM      Prashant     Initial Version
*/
    public  static map<string,Case_Escalations_Matrix_MDT__c> getEscalationsMatrices(){
        // map of Case Escalation matrix metadata with key as Channel__c+Case_Type__c+Business_Area__c+Escalation_Level__c
        map<string,Case_Escalations_Matrix_MDT__c> caseEscaltionMap = new map<string,Case_Escalations_Matrix_MDT__c>();
        
        List<Case_Escalations_Matrix_MDT__c> caseEscalationsMatricesList = [Select Channel__c,Case_Type__c,Business_Area__c,Highest_Level_Escalation__c
                from Case_Escalations_Matrix_MDT__c where Escalation_Type__c = 'CCP Escalation' ];
        
        for(Case_Escalations_Matrix_MDT__c caseEscalationsMatrices : caseEscalationsMatricesList){
                                                                        //for CCP Escalation type (added by Prashant Gahlaut - 1/9/2020)
                                                                        String noLevelkey = (caseEscalationsMatrices.Channel__c!=null?caseEscalationsMatrices.Channel__c:'');
                                                                        noLevelkey+= (caseEscalationsMatrices.Case_Type__c!=null?caseEscalationsMatrices.Case_Type__c:'');
                                                                        noLevelkey+= (caseEscalationsMatrices.Business_Area__c!=null?caseEscalationsMatrices.Business_Area__c:'');
                                                                        caseEscaltionMap.put(noLevelkey,caseEscalationsMatrices);                                                                       
                                                                    }
        return caseEscaltionMap;
    }

    /**
    Author: Rajesh Ramachandran
    Company: Salesforce
    Description: It will create MC Communication records for MI Cases which need to be sent via DMS
    Inputs: Type, CaseList, Communication to(internal/customer)
    Returns: 
    History:
    ================
    1.1A     24/08/2020, 11:02:00 AM      Rajesh     Initial Version
    */
    public static void createMIMCCommRecord(String commtype, List<Case> newCaseList, String commTo){

        //added to avoid raising escalation messages in sandboxes 
        Bypass_Setting__c bypassSetting = Bypass_Setting__c.getInstance(UserInfo.getUserId());        
        if (bypassSetting.Skip_MC_Record_Creation__c == true)
            return;        
  
        Map<Id,String> userIdPhoneMap = new Map<Id,String>();
        List<MC_Communication__c> mcRecords = new List<MC_Communication__c>();
        String userIds;
        Set<String> escalatedUserIDs= new Set<String>();
        try{
            for(Case cs : newCaseList){
                if (commTo == 'Customer' && cs.Mobile_Number__c != null){
                    MC_Communication__c escalationRec = new MC_Communication__c();
                    escalationRec.Recipient_Phone_Numbers__c = cs.Mobile_Number__c;
                    escalationRec.To_Address__c = cs.Customer__c;
                    escalationRec.Case__c=cs.Id;
                    escalationRec.Type__c = commtype;
                    escalationRec.Status__c=ConstantsUtility.DEALER_INTERNAL_MC_STATUS;
                    escalationRec.Escalation_Date_Time__c = Datetime.now();
                    mcRecords.add(escalationRec);
                }
                else if (commTo == 'Internal'){
                    escalatedUserIDs.add(cs.OwnerId);
                }
            }
            
            if(escalatedUserIDs.size()>0){
                for(User us : [Select Id,Phone from User where Id IN: escalatedUserIDs AND isActive=True]){
                    userIdPhoneMap.put(us.Id,us.Phone);
                }
            }
            if(userIdPhoneMap.size()>0){
                for(Case csRec : newCaseList){
                    if (userIdPhoneMap.get(csRec.OwnerId) != null){
                        MC_Communication__c escalationRec = new MC_Communication__c();
                        escalationRec.Recipient_Phone_Numbers__c = userIdPhoneMap.get(csRec.OwnerId);
                        escalationRec.To_Address__c = csRec.OwnerId;
                        escalationRec.Case__c=csRec.Id;
                        escalationRec.Type__c = commtype;
                        escalationRec.Status__c=ConstantsUtility.DEALER_INTERNAL_MC_STATUS;
                        escalationRec.Escalation_Date_Time__c = Datetime.now();
                        mcRecords.add(escalationRec);    
                    }
                }
            }
            if(mcRecords.size()>0){
                insert mcRecords;
            }
        }catch(exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateMcCommunicationRecord';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateMcCommunicationRecord - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : createInboundEscalationRecords - Method', '', ehst);
        }
    }    
}