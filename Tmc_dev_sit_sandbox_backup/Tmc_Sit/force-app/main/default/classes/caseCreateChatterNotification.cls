/**
* @File Name          : caseCreateChatterNotification.cls
* @Description        : 
* @Author             : Prashant Gahlaut
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-01-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    07/09/2020, 11:02:00 AM       Prashant Gahlaut             Initial Version
*1.0    30/09/2020, 4:44 PM            Prashant Gahlaut             place chatterNotificationUtil class instead of InboundChatterNotificationUtil
**/
public without sharing class caseCreateChatterNotification {
    // Method to send chatter notifications
    public static void chatterNotfication(List<Case> newCaseList,Map<Id,Case> oldCaseList){
        map<Id,set<string>>chatterNotificationMap = new map<Id,set<string>>();//map to store case Id with Users id
        map<Id,string> chatterMassageMap = new map<Id,string>();// map to store case Id with Message body
        map<string,string> metadataMessageMap = getMetadataMessage();//Metadata Map
        try{
            //loop through case 
            for(Case cs : newCaseList){
                //loop through metadata
                for(String key : metadataMessageMap.keySet()){
                    //when record is created or status changes
                    if(key != 'OwnerChange'){
                        //spliiting key
                        string splittedCaseType = key.split('@@')[0];
                        string splittedBusinessArea = key.split('@@')[1].split('##')[0];
                        string splittedStatus = key.split('##')[1];
                        //condition check 
                        if(String.isNotBlank(cs.Case_Type__c) && cs.Case_Type__c == splittedCaseType && String.isNotBlank(cs.Business_Area__c) && 
                           cs.Business_Area__c == splittedBusinessArea &&  String.isNotBlank(cs.Status) && cs.Status == splittedStatus){
                               //if DIQ, DIF and DIC without 'service-bodyshop' & 'service-workShop'
                               if(trigger.isInsert && cs.Status == 'New'){
                                   if(cs.Case_Type__c == 'Dealer Internal Query' || cs.Case_Type__c == 'Dealer Internal Feedback' || cs.Case_Type__c == 'Dealer Internal Request' || (cs.Case_Type__c == 'Dealer Internal Complaint' && (cs.Business_Area__c != 'Service-Workshop' && cs.Business_Area__c != 'Service-Bodyshop'))){
                                       //get chatter message accordingly 
                                       String plainMessage = metadataMessageMap.get(key);
                                       plainMessage = cs.Case_Type__c != null ? plainMessage.replace('Case_Type__c', cs.Case_Type__c) : plainMessage.replace('Case_Type__c', '-');
                                       plainMessage = cs.CaseNumber != null ? plainMessage.replace('CaseNumber', cs.CaseNumber) : plainMessage.replace('CaseNumber', '-');
                                       plainMessage = cs.Registration_No__c != null ? plainMessage.replace('Registration_No__c', cs.Registration_No__c) : plainMessage.replace('Registration_No__c', '-');
                                       if(cs.Business_Area__c != 'Sales' && cs.Business_Area__c != 'Finance')
                                           plainMessage = cs.CreatedById != null ? plainMessage.replace('CreatedByName', cs.CreatedBy_Name__c) : plainMessage.replace('CreatedByName', '-');
                                       plainMessage = cs.OwnerId != null ? plainMessage.replace('OwnerName', cs.Owner_Name__c) : plainMessage.replace('OwnerName', '-');
                                       //put values in map
                                       chatterMassageMap.put(cs.Id,plainMessage);
                                   }
                                   //If DIC with 'service-bodyshop' & 'service-workShop'
                                   if(cs.Case_Type__c == 'Dealer Internal Complaint' && (cs.Business_Area__c == 'Service-Workshop' || cs.Business_Area__c == 'Service-Bodyshop')){
                                       String plainMessage = metadataMessageMap.get(key);
                                       plainMessage = cs.Case_Type__c != null ? plainMessage.replace('Case_Type__c', cs.Case_Type__c) : plainMessage.replace('Case_Type__c', '-');
                                       plainMessage = cs.Case_Sub_Type__c != null ? plainMessage.replace('Case_Sub_Type', cs.Case_Sub_Type__c) : plainMessage.replace('Case_Sub_Type', '-');
                                       plainMessage = cs.CaseNumber != null ? plainMessage.replace('CaseNumber', cs.CaseNumber) : plainMessage.replace('CaseNumber', '-');
                                       plainMessage = cs.Registration_No__c != null ? plainMessage.replace('Registration_No__c', cs.Registration_No__c) : plainMessage.replace('Registration_No__c', '-');
                                       plainMessage = cs.CreatedById != null ? plainMessage.replace('CreatedByName', cs.CreatedBy_Name__c) : plainMessage.replace('CreatedByName', '-');
                                       plainMessage = cs.OwnerId != null ? plainMessage.replace('OwnerName', cs.Owner_Name__c) : plainMessage.replace('OwnerName', '-');
                                       plainMessage = cs.Channel__c != null ? plainMessage.replace('Channel__c', cs.Channel__c) : plainMessage.replace('Channel__c', '-');
                                       plainMessage = cs.Business_Area__c != null ? plainMessage.replace('Business_Area__c', cs.Business_Area__c) : plainMessage.replace('Business_Area__c', '-');
                                       plainMessage = cs.Case_Stage__c != null ? plainMessage.replace('Case_Stage__c', cs.Business_Area__c) : plainMessage.replace('Case_Stage__c', '-');
                                       chatterMassageMap.put(cs.Id,plainMessage);
                                   }
                               }
                               //condition check for owner and status update
                               if(trigger.isUpdate && (cs.Case_Type__c == 'Dealer Internal Query' || cs.Case_Type__c == 'Dealer Internal Feedback' || cs.Case_Type__c == 'Dealer Internal Complaint'
                                                       || cs.Case_Type__c == 'Dealer Internal Request') && oldCaseList.get(cs.Id).Status != cs.Status && cs.Status == 'Closed'){
                                                           if(cs.Case_Type__c == 'Dealer Internal Query' || cs.Case_Type__c == 'Dealer Internal Feedback' || cs.Case_Type__c == 'Dealer Internal Request'){
                                                               String plainMessage = metadataMessageMap.get(key);
                                                               plainMessage = cs.Case_Type__c != null ? plainMessage.replace('Case_Type__c', cs.Case_Type__c) : plainMessage.replace('Case_Type__c', '-');
                                                               plainMessage = cs.CaseNumber != null ? plainMessage.replace('CaseNumber', cs.CaseNumber) : plainMessage.replace('CaseNumber', '-');
                                                               plainMessage = cs.Registration_No__c != null ? plainMessage.replace('Registration_No__c', cs.Registration_No__c) : plainMessage.replace('Registration_No__c', '-');
                                                               plainMessage = cs.CreatedById != null ? plainMessage.replace('CreatedByName', cs.CreatedBy_Name__c) : plainMessage.replace('CreatedByName', '-');
                                                               plainMessage = cs.OwnerId != null ? plainMessage.replace('OwnerName', cs.Owner_Name__c) : plainMessage.replace('OwnerName', '-');
                                                               plainMessage = cs.LastModifiedById != null ? plainMessage.replace('lastModofiedBy', cs.LastModifiedBy_Name__c) : plainMessage.replace('lastModofiedBy', '-');
                                                               chatterMassageMap.put(cs.Id,plainMessage);
                                                           }
                                                           if(cs.Case_Type__c == 'Dealer Internal Complaint'){
                                                               String plainMessage = metadataMessageMap.get(key);
                                                               plainMessage = cs.Case_Type__c != null ? plainMessage.replace('Case_Type__c', cs.Case_Type__c) : plainMessage.replace('Case_Type__c', '-');
                                                               plainMessage = cs.Case_Sub_Type__c != null ? plainMessage.replace('Case_Sub_Type', cs.Case_Sub_Type__c) : plainMessage.replace('Case_Sub_Type', '-');
                                                               plainMessage = cs.CaseNumber != null ? plainMessage.replace('CaseNumber', cs.CaseNumber) : plainMessage.replace('CaseNumber', '-');
                                                               plainMessage = cs.Registration_No__c != null ? plainMessage.replace('Registration_No__c', cs.Registration_No__c) : plainMessage.replace('Registration_No__c', '-');
                                                               plainMessage = cs.CreatedById != null ? plainMessage.replace('CreatedByName', cs.CreatedBy_Name__c) : plainMessage.replace('CreatedByName', '-');
                                                               plainMessage = cs.OwnerId != null ? plainMessage.replace('OwnerName', cs.Owner_Name__c) : plainMessage.replace('OwnerName', '-');
                                                               plainMessage = cs.Channel__c != null ? plainMessage.replace('Channel__c', cs.Channel__c) : plainMessage.replace('Channel__c', '-');
                                                               plainMessage = cs.Business_Area__c != null ? plainMessage.replace('Business_Area__c', cs.Business_Area__c) : plainMessage.replace('Business_Area__c', '-');
                                                               plainMessage = cs.Case_Stage__c != null ? plainMessage.replace('Case_Stage__c', cs.Business_Area__c) : plainMessage.replace('Case_Stage__c', '-');
                                                               plainMessage = cs.LastModifiedById != null ? plainMessage.replace('lastModofiedBy', cs.LastModifiedBy_Name__c) : plainMessage.replace('lastModofiedBy', '-');
                                                               chatterMassageMap.put(cs.Id,plainMessage);
                                                           }
                                                       }
                           }
                    }
                    //when owner changes
                    if(key == 'OwnerChange'){
                        if(trigger.isUpdate && (cs.Case_Type__c == 'Dealer Internal Query' || cs.Case_Type__c == 'Dealer Internal Feedback' || cs.Case_Type__c == 'Dealer Internal Complaint'
                                                || cs.Case_Type__c == 'Dealer Internal Request') && oldCaseList.get(cs.Id).OwnerId != cs.OwnerId){
                                                    String plainMessage = metadataMessageMap.get(key);
                                                    plainMessage = cs.Case_Type__c != null ? plainMessage.replace('Case_Type__c', cs.Case_Type__c) : plainMessage.replace('Case_Type__c', '-');
                                                    plainMessage = cs.CaseNumber != null ? plainMessage.replace('CaseNumber', cs.CaseNumber) : plainMessage.replace('CaseNumber', '-');
                                                    plainMessage = cs.Registration_No__c != null ? plainMessage.replace('Registration_No__c', cs.Registration_No__c) : plainMessage.replace('Registration_No__c', '-');
                                                    plainMessage = cs.CreatedById != null ? plainMessage.replace('CreatedByName', cs.CreatedBy_Name__c) : plainMessage.replace('CreatedByName', '-');
                                                    plainMessage = cs.OwnerId != null ? plainMessage.replace('OwnerName', cs.Owner_Name__c) : plainMessage.replace('OwnerName', '-');
                                                    plainMessage = cs.LastModifiedById != null ? plainMessage.replace('lastModofiedBy', cs.LastModifiedBy_Name__c) : plainMessage.replace('lastModofiedBy', '-');
                                                    chatterMassageMap.put(cs.Id,plainMessage);
                                                }
                    }
                }
                //put values in map
                if(!chatterNotificationMap.containsKey(cs.Id))
                    chatterNotificationMap.put(cs.Id,new set<String>{cs.OwnerId});
                if(chatterNotificationMap.containsKey(cs.Id)){
                    if(cs.Business_Area__c != 'Sales' && cs.Business_Area__c != 'Finance')
                        chatterNotificationMap.get(cs.Id).add(cs.CreatedById);
                    else
                        chatterNotificationMap.get(cs.Id).add(cs.Primary_Dealer_QCM__c);
                }
            }
            system.debug('chatterNotificationMap-------------->'+chatterNotificationMap);
            system.debug('chatterMassageMap-------------->'+chatterMassageMap);
            //sizwe check
            if(chatterMassageMap.size()>0 && chatterNotificationMap.size()>0)
                //call chattter class
                ChatterNotificationUtil.sendChatterNotification(chatterNotificationMap,chatterMassageMap);
        }catch(exception e){
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('caseCreateChatterNotification - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : chatterNotfication - Method', '', ehst);
        }
    }

    //Method to fetch the all the Inbound chatter Notification metadata
    public static map<string,string> getMetadataMessage(){
        map<string,string> fetchMessageMetadataMap = new map<string,string>();
        for(inbound_chatter_notification__mdt inboundMessageObj : [SELECT Business_Area__c,Case_Type__c,Chatter_Content__c,Status__c
                                                                   FROM inbound_chatter_notification__mdt
                                                                   WHERE status__c !=: 'Escalated']){
                                                                       if(string.isNotBlank(inboundMessageObj.Business_Area__c) && string.isNotBlank(inboundMessageObj.Case_Type__c) && string.isNotBlank(inboundMessageObj.Status__c))
                                                                           fetchMessageMetadataMap.put(inboundMessageObj.Case_Type__c+'@@'+inboundMessageObj.Business_Area__c+'##'+inboundMessageObj.Status__c , inboundMessageObj.Chatter_Content__c);
                                                                       else
                                                                           fetchMessageMetadataMap.put('OwnerChange' , inboundMessageObj.Chatter_Content__c);
                                                                   }
        return fetchMessageMetadataMap ;
    }
}