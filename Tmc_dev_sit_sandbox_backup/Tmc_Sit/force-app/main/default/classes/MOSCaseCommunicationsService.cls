/*Author : Anas Yar Khan
* Company : Techmatrix Consulting
* Description : This class is used to create MC Communication records for MOS Case
*/ 

public class MOSCaseCommunicationsService {
    //This method calls from CaseTriggerStrategyHelper when particular condition got met
    public static void BreakdownPendingForOutForService(Case caseObj,List<MC_Communication__c> listMCCommunicationToInsert,
                                                        Map<String,String> mapTechnicianIdToPhoneNumbers,
                                                        Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers) {
                                                            try{
                                                                List<String> listPhoneNumbers = new List<String>();
                                                                MC_Communication__c mcRecord = getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Case_Allocated_Customer,caseObj.Mobile_Number__c);
                                                                if(caseObj.Technician_ID__c != NULL && mapTechnicianIdToPhoneNumbers != NULL && mapTechnicianIdToPhoneNumbers.keySet().size() > 0 
                                                                   && mapTechnicianIdToPhoneNumbers.containsKey(caseObj.Technician_ID__c)) {
                                                                       mcRecord.Phone_1__c = mapTechnicianIdToPhoneNumbers.get(caseObj.Technician_ID__c);
                                                                       listPhoneNumbers.add(mapTechnicianIdToPhoneNumbers.get(caseObj.Technician_ID__c));
                                                                   }
                                                                if(caseObj.Allocated_Dealer__c != NULL && mapAllocatedDealerToStakeHolderToPhoneNumbers != NULL 
                                                                   && mapAllocatedDealerToStakeHolderToPhoneNumbers.keySet().size() > 0 
                                                                   && mapAllocatedDealerToStakeHolderToPhoneNumbers.containsKey(caseObj.Allocated_Dealer__c)) {
                                                                       Map<String,String> mapStakeHolderToPhoneNumbers = mapAllocatedDealerToStakeHolderToPhoneNumbers.get(caseObj.Allocated_Dealer__c);
                                                                       if(mapStakeHolderToPhoneNumbers != NULL && mapStakeHolderToPhoneNumbers.keySet().size() > 0) {
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               mcRecord.Phone_2__c = mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c);
                                                                               listPhoneNumbers.add(mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c));
                                                                           }
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               mcRecord.Phone_3__c = mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c);
                                                                               listPhoneNumbers.add(mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c));
                                                                           }
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L3A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               listPhoneNumbers.add(mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L3A+ConstantsUtility.keySeparator+CaseObj.Channel__c));
                                                                           }
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L3A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               listPhoneNumbers.add(mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L3A+ConstantsUtility.keySeparator+CaseObj.Channel__c));
                                                                           }
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.MOSROC+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               listPhoneNumbers.add(mapStakeHolderToPhoneNumbers.get(ConstantsUtility.MOSROC+ConstantsUtility.keySeparator+CaseObj.Channel__c));
                                                                           }
                                                                           
                                                                       }
                                                                   }
                                                                listMCCommunicationToInsert.add(mcRecord);
                                                                if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                                                    listMCCommunicationToInsert.add(getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Case_Allocated_to_Technician_MCall_Dealer,String.join(listPhoneNumbers,',')));
                                                                }
                                                                else if(String.isNotBlank(caseObj.MOS_Case_Source__c)) {
                                                                    listMCCommunicationToInsert.add(getMCCommunicationRecord(caseObj,ConstantsUtility.Breakdown_Case_Allocated_to_Technician_Dealer,String.join(listPhoneNumbers,',')));
                                                                }    
                                                            }
                                                            catch(Exception e) {
                                                                ExceptionHandler.LogError('MOSCaseCommunicationsService', e.getMessage()+':'+e.getLineNumber(), 'BreakdownPendingForOutForService', '', null);      
                                                            }
                                                        }
    
    //This method calls from CaseTriggerStrategyHelper when particular condition got met
    public static void TowingDestinationDealerSelected(Case caseObj,List<MC_Communication__c> listMCCommunicationToInsert,
                                                       Map<String,MOS_Time_dependent_Communication__mdt> mapKeyToCommunicationRecordsNotTimeDependent,
                                                       List<Account> listMSAllianzRecords,Map<String,String> mapDesignationMSAllianzToPhoneNumbers,
                                                       Map<String,Set<String>> mapRoleToPhoneNumbers,Map<String,String> mapTechnicianIdToPhoneNumbers,
                                                       Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers) {
                                                           try{
                                                               if(caseObj.Mobile_Number__c != NULL) {
                                                                   MC_Communication__c mcRecord = getMCCommunicationRecord(caseObj,ConstantsUtility.Towing_Destination_Dealer_Customer,caseObj.Mobile_Number__c);
                                                                   if(caseObj.Towing_Destination_Dealer__c != NULL && mapAllocatedDealerToStakeHolderToPhoneNumbers != NULL 
                                                                      && mapAllocatedDealerToStakeHolderToPhoneNumbers.keySet().size() > 0 
                                                                      && mapAllocatedDealerToStakeHolderToPhoneNumbers.containsKey(caseObj.Towing_Destination_Dealer__c)) {
                                                                          Map<String,String> mapStakeHolderToPhoneNumbers = mapAllocatedDealerToStakeHolderToPhoneNumbers.get(caseObj.Towing_Destination_Dealer__c);
                                                                          if(mapStakeHolderToPhoneNumbers != NULL && mapStakeHolderToPhoneNumbers.keySet().size() > 0) {
                                                                              if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                                  mcRecord.Phone_5__c = mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c);
                                                                              }
                                                                              if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                                  mcRecord.Phone_4__c = mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c);
                                                                              }
                                                                          }
                                                                      }
                                                                   listMCCommunicationToInsert.add(mcRecord);
                                                               }
                                                               if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                                                   checkForCommunicationRecord(mapKeyToCommunicationRecordsNotTimeDependent,ConstantsUtility.Towing_Destination_Dealer_MCall_Dealer,
                                                                                               listMCCommunicationToInsert,caseObj,listMSAllianzRecords,mapDesignationMSAllianzToPhoneNumbers,mapRoleToPhoneNumbers,
                                                                                               mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,'Towing_Destination_Dealer__c');
                                                               }
                                                               else if(String.isNotBlank(caseObj.MOS_Case_Source__c)) {
                                                                   checkForCommunicationRecord(mapKeyToCommunicationRecordsNotTimeDependent,ConstantsUtility.Towing_Destination_Dealer_Dealer,
                                                                                               listMCCommunicationToInsert,caseObj,listMSAllianzRecords,mapDesignationMSAllianzToPhoneNumbers,
                                                                                               mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,'Towing_Destination_Dealer__c');
                                                               }     
                                                           }
                                                           catch(Exception e) {
                                                               ExceptionHandler.LogError('MOSCaseCommunicationsService', e.getMessage()+':'+e.getLineNumber(), 'TowingDestinationDealerSelected', '', null);    
                                                           }
                                                       }
    
    //This method calls from CaseTriggerStrategyHelper when particular condition got met
    public static void AllocatedDealerNotMSAllianz(Case caseObj,List<MC_Communication__c> listMCCommunicationToInsert,
                                                   Map<String,MOS_Time_dependent_Communication__mdt> mapKeyToCommunicationRecordsNotTimeDependent,
                                                   List<Account> listMSAllianzRecords,Map<String,String> mapDesignationMSAllianzToPhoneNumbers,
                                                   Map<String,Set<String>> mapRoleToPhoneNumbers,Map<String,String> mapTechnicianIdToPhoneNumbers,
                                                   Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers) {
                                                       try{
                                                           if(caseObj.Mobile_Number__c != NULL) {
                                                               MC_Communication__c mcRecord = getMCCommunicationRecord(caseObj,ConstantsUtility.Towing_Case_Allocated_to_Dealer_Customer,caseObj.Mobile_Number__c);
                                                               if(caseObj.Allocated_Dealer__c != NULL && mapAllocatedDealerToStakeHolderToPhoneNumbers != NULL 
                                                                   && mapAllocatedDealerToStakeHolderToPhoneNumbers.keySet().size() > 0 
                                                                   && mapAllocatedDealerToStakeHolderToPhoneNumbers.containsKey(caseObj.Allocated_Dealer__c)) {
                                                                       Map<String,String> mapStakeHolderToPhoneNumbers = mapAllocatedDealerToStakeHolderToPhoneNumbers.get(caseObj.Allocated_Dealer__c);
                                                                       if(mapStakeHolderToPhoneNumbers != NULL && mapStakeHolderToPhoneNumbers.keySet().size() > 0) {
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               mcRecord.Phone_2__c = mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L1A+ConstantsUtility.keySeparator+CaseObj.Channel__c);
                                                                           }
                                                                           if(mapStakeHolderToPhoneNumbers.containsKey(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c)) {
                                                                               mcRecord.Phone_3__c = mapStakeHolderToPhoneNumbers.get(ConstantsUtility.NOTIFIER_L2A+ConstantsUtility.keySeparator+CaseObj.Channel__c);
                                                                           }
                                                                       }
                                                                   }
                                                                listMCCommunicationToInsert.add(mcRecord);
                                                           }
                                                           
                                                           if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                                               checkForCommunicationRecord(mapKeyToCommunicationRecordsNotTimeDependent,ConstantsUtility.Towing_Case_Allocated_to_Dealer_MCall_Dealer,
                                                                                           listMCCommunicationToInsert,caseObj,listMSAllianzRecords,mapDesignationMSAllianzToPhoneNumbers,
                                                                                           mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,'Allocated_Dealer__c');
                                                           }
                                                           else if(String.isNotBlank(caseObj.MOS_Case_Source__c)) {
                                                               checkForCommunicationRecord(mapKeyToCommunicationRecordsNotTimeDependent,ConstantsUtility.Towing_Case_Allocated_to_Dealer_Dealer,
                                                                                           listMCCommunicationToInsert,caseObj,listMSAllianzRecords,mapDesignationMSAllianzToPhoneNumbers,
                                                                                           mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,'Allocated_Dealer__c');
                                                           }    
                                                       }
                                                       catch(Exception e) {
                                                           ExceptionHandler.LogError('MOSCaseCommunicationsService', e.getMessage()+':'+e.getLineNumber(), 'AllocatedDealerNotMSAllianz', '', null);    
                                                       }
                                                   }
    
    //This method calls from CaseTriggerStrategyHelper when particular condition got met and will create time dependent communication
    public static void OFSReminder(Case caseObj,List<MC_Communication__c> listMCCommunicationToInsert,Map<String,List<MOS_Time_dependent_Communication__mdt>> mapKeyToCommunicationRecords,
                                   List<Account> listMSAllianzRecord,Map<String,String> mapDesignationMSAllianzToPhoneNumbers,Map<String,Set<String>> mapRoleToPhoneNumbers,
                                   Map<String,String> mapTechnicianIdToPhoneNumbers,Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers) {
                                       try{
                                           String key = caseObj.Job_Type__c + ConstantsUtility.keySeparator + caseObj.MOS_Case_Stage__c +  ConstantsUtility.keySeparator;
                                           if(caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall) {
                                               key += ConstantsUtility.MOSCaseSourceMCall;    
                                           } 
                                           else {
                                               key += ConstantsUtility.MOSCaseSourceNOTMCall;     
                                           }
                                           
                                           if(mapKeyToCommunicationRecords != NULL && mapKeyToCommunicationRecords.keySet().size() > 0 && mapKeyToCommunicationRecords.containsKey(key) 
                                              && mapKeyToCommunicationRecords.get(key) != NULL) {
                                                  for(MOS_Time_dependent_Communication__mdt mosCommunication : mapKeyToCommunicationRecords.get(key)) {
                                                      if(String.isNotBlank(mosCommunication.Dealer_Not_Equal_To__c) && caseObj.Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                                                          continue;
                                                      }
                                                      else {
                                                          if(mosCommunication.Audience__c != NULL) {
                                                              String phoneNumbers = getPhoneNumbers(caseObj,mosCommunication.Audience__c,listMSAllianzRecord,mapDesignationMSAllianzToPhoneNumbers,
                                                                                                    mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,'Allocated_Dealer__c');
                                                              if(phoneNumbers != NULL) {
                                                                  MC_Communication__c mcCommunication =  getMCCommunicationRecord(caseObj,mosCommunication.Notification_Type__c,phoneNumbers);
                                                                  mcCommunication.Escalation_Date_Time__c = System.now().addSeconds(Integer.valueOf(mosCommunication.Time_Duration__c));
                                                                  mcCommunication.Counter__c = mosCommunication.Counter__c;
                                                                  listMCCommunicationToInsert.add(mcCommunication);  
                                                              }
                                                          }
                                                      }
                                                  }        
                                              }    
                                       }
                                       catch(Exception e) {
                                           ExceptionHandler.LogError('MOSCaseCommunicationsService', e.getMessage()+':'+e.getLineNumber(), 'OFSReminder', '', null);    
                                       }
                                   }
    
    
    //this method is used to get the MC record
    public static MC_Communication__c getMCCommunicationRecord(Case caseObj,String type,String mobileNumber) {
        MC_Communication__c mcRecord = new MC_Communication__c();
        mcRecord.Case__c = caseObj.Id;
        mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Queued;
        mcRecord.Type__c = type;
        mcRecord.Escalation_Date_Time__c = System.now().addMinutes(-ConstantsUtility.Five_Minutes);
        mcRecord.Recipient_Phone_Numbers__c = mobileNumber;
        return mcRecord;
    }
    
    //this method is used to get the phone numbers 
    public static String getPhoneNumbers(Case caseObj,String audience,List<Account> listMSAllianzRecord,Map<String,String> mapDesignationMSAllianzToPhoneNumbers,
                                         Map<String,Set<String>> mapRoleToPhoneNumbers,Map<String,String> mapTechnicianIdToPhoneNumbers,
                                         Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers,String fieldAPIName) {
                                             List<String> listPhoneNumbers = new List<String>();
                                             Integer count = 1;
                                             for(String individualAudience : audience.split(',')) {
                                                 if(individualAudience.contains(ConstantsUtility.Contact)) {
                                                     if(caseObj.Technician_Id__c != NULL && mapTechnicianIdToPhoneNumbers != NULL && mapTechnicianIdToPhoneNumbers.keySet().size() > 0 
                                                        && mapTechnicianIdToPhoneNumbers.containsKey(caseObj.Technician_Id__c)) {
                                                            listPhoneNumbers.add(mapTechnicianIdToPhoneNumbers.get(caseObj.Technician_Id__c));
                                                        }    
                                                 }
                                                 else if(individualAudience.contains(ConstantsUtility.Role)){
                                                     if(mapRoleToPhoneNumbers != NULL && mapRoleToPhoneNumbers.keySet().size() > 0 && mapRoleToPhoneNumbers.containsKey(individualAudience.split('#')[1])) {
                                                         String roleName = individualAudience.split('#')[1];
                                                         if(roleName.contains(ConstantsUtility.ChannelHead) && count == 1) {
                                                             String key = ConstantsUtility.ChannelHead+caseObj.Channel__c;
                                                             listPhoneNumbers.addAll(mapRoleToPhoneNumbers.get(key));
                                                             count++;
                                                         }
                                                         else {
                                                             listPhoneNumbers.addAll(mapRoleToPhoneNumbers.get(individualAudience.split('#')[1]));     
                                                         }
                                                     }
                                                 }
                                                 else if(individualAudience.contains(ConstantsUtility.Account)) {
                                                     if(listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseObj.Allocated_Dealer__c == listMSAllianzRecord[0].Id 
                                                        && mapDesignationMSAllianzToPhoneNumbers != NULL && mapDesignationMSAllianzToPhoneNumbers.keySet().size() > 0 
                                                        && mapDesignationMSAllianzToPhoneNumbers.containsKey(audience.split('#')[1])) {
                                                            listPhoneNumbers.add(mapDesignationMSAllianzToPhoneNumbers.get(individualAudience.split('#')[1]));
                                                        }
                                                 }
                                                 else if(individualAudience.contains(ConstantsUtility.Hierarchy)) {
                                                     if(mapAllocatedDealerToStakeHolderToPhoneNumbers != NULL && mapAllocatedDealerToStakeHolderToPhoneNumbers.keySet().size() > 0 
                                                        && (String)caseObj.get(fieldAPIName) != NULL && mapAllocatedDealerToStakeHolderToPhoneNumbers.containsKey((String)caseObj.get(fieldAPIName))) {
                                                            Map<String,String> mapPhoneNumbers =   mapAllocatedDealerToStakeHolderToPhoneNumbers.get((String)caseObj.get(fieldAPIName));
                                                            String key =  individualAudience.split('#')[1]+ConstantsUtility.keySeparator+caseObj.Channel__c;
                                                            if(mapPhoneNumbers != NULL && mapPhoneNumbers.keySet().size() > 0 && mapPhoneNumbers.containsKey(key)) {
                                                                listPhoneNumbers.add(mapPhoneNumbers.get(key));   
                                                            }
                                                        }
                                                 }
                                             }  
                                             return String.join(listPhoneNumbers,',');
                                         }
    
    
    //This method is used to check whether custom metadata records contains 'type' value and add mc communication records in list 
    public static void checkForCommunicationRecord(Map<String,MOS_Time_dependent_Communication__mdt> mapKeyToCommunicationRecordsNotTimeDependent,
                                                   String type,List<MC_Communication__c> listMCCommunicationToInsert,Case caseObj,List<Account> listMSAllianzRecords,
                                                   Map<String,String> mapDesignationMSAllianzToPhoneNumbers,Map<String,Set<String>> mapRoleToPhoneNumbers,
                                                   Map<String,String> mapTechnicianIdToPhoneNumbers,
                                                   Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers,String fieldAPIName) {
                                                       MC_Communication__c mcRecord = checkForCommunicationRecordReturn(mapKeyToCommunicationRecordsNotTimeDependent,type,caseObj,
                                                                                                                        listMSAllianzRecords,mapDesignationMSAllianzToPhoneNumbers,
                                                                                                                        mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,
                                                                                                                        mapAllocatedDealerToStakeHolderToPhoneNumbers,fieldAPIName);
                                                       if(mcRecord != NULL) {
                                                           listMCCommunicationToInsert.add(mcRecord);   
                                                       }
                                                   }
    
    public static MC_Communication__c checkForCommunicationRecordReturn(Map<String,MOS_Time_dependent_Communication__mdt> mapKeyToCommunicationRecordsNotTimeDependent,
                                                                        String type,Case caseObj,List<Account> listMSAllianzRecords,
                                                                        Map<String,String> mapDesignationMSAllianzToPhoneNumbers,Map<String,Set<String>> mapRoleToPhoneNumbers,
                                                                        Map<String,String> mapTechnicianIdToPhoneNumbers,
                                                                        Map<String,Map<String,String>> mapAllocatedDealerToStakeHolderToPhoneNumbers,String fieldAPIName) {
                                                                            if(mapKeyToCommunicationRecordsNotTimeDependent != NULL && mapKeyToCommunicationRecordsNotTimeDependent.keySet().size() > 0 
                                                                               && mapKeyToCommunicationRecordsNotTimeDependent.containsKey(type)) {
                                                                                   MOS_Time_dependent_Communication__mdt mosCommunication = mapKeyToCommunicationRecordsNotTimeDependent.get(type);
                                                                                   if(mosCommunication.Audience__c != NULL) {
                                                                                       //getting phone numbers
                                                                                       String phoneNumbers = getPhoneNumbers(caseObj,mosCommunication.Audience__c,listMSAllianzRecords,mapDesignationMSAllianzToPhoneNumbers,
                                                                                                                             mapRoleToPhoneNumbers,mapTechnicianIdToPhoneNumbers,mapAllocatedDealerToStakeHolderToPhoneNumbers,fieldAPIName);
                                                                                       if(phoneNumbers != NULL) {
                                                                                           //return MC record
                                                                                           return getMCCommunicationRecord(caseObj,type,phoneNumbers);
                                                                                       }
                                                                                   }
                                                                               }
                                                                            return NULL;
                                                                        }
    
    
    //Email for Cancelled Customer
    public static void sendCustomerCancelledEmail(Map<String,Map<String,String>> mapAllocatedDealerToStakeholderEmails,
                                                  List<MC_Communication__c> listMCCommunicationToInsert,Map<String,String> mapRoleUser,
                                                  Case caseObj,Map<Id,String> mapCityIdToName,Map<Id,Account> mapIdToAllocatedDealer) {
                                                      if(mapAllocatedDealerToStakeholderEmails != NULL && mapAllocatedDealerToStakeholderEmails.keySet().size() > 0 && mapAllocatedDealerToStakeholderEmails.containsKey(caseObj.Allocated_Dealer__c)) {
                                                          MC_Communication__c mcRecord = new MC_Communication__c();
                                                          mcRecord.Case__c = caseObj.Id;
                                                          mcRecord.Type__c = 'Email Customer Cancelled';
                                                          Map<String,String> mapHierarchyToEmails = mapAllocatedDealerToStakeholderEmails.get(caseObj.Allocated_Dealer__c);
                                                          if(mapHierarchyToEmails != NULL && mapHierarchyToEmails.keySet().size() > 0) {
                                                              //Email for WM
                                                              putEmails(mcRecord,ConstantsUtility.NOTIFIER_L1A,mapHierarchyToEmails,caseObj,'Email_1__c');
                                                              
                                                              //Email for GM
                                                              putEmails(mcRecord,ConstantsUtility.NOTIFIER_L2A,mapHierarchyToEmails,caseObj,'Email_2__c');
                                                              
                                                              //Email for RSM
                                                              putEmails(mcRecord,ConstantsUtility.NOTIFIER_L4,mapHierarchyToEmails,caseObj,'L9_Email__c');
                                                              
                                                              //Email for ROC
                                                              putEmails(mcRecord,ConstantsUtility.MOSROC,mapHierarchyToEmails,caseObj,'L8E_Email__c');
                                                              
                                                              //Emial for TSM
                                                              putEmails(mcRecord,ConstantsUtility.NOTIFIER_L3A,mapHierarchyToEmails,caseObj,'L8D_Email__c');
                                                              
                                                          }
                                                          //Email for HO
                                                          if(mapRoleUser != NULL && mapRoleUser.keySet().size() > 0 && mapRoleUser.containsKey(ConstantsUtility.RoleHOMOS)) {
                                                              mcRecord.L7B_Email__c  = mapRoleUser.get(ConstantsUtility.RoleHOMOS);
                                                          }
                                                          mcRecord.General_Field_1__c = caseObj.FE_CaseNumber__c;
                                                          if(caseObj.Allocation_Time__c != NULL) {
                                                              mcRecord.General_Field_2__c = String.valueOf(caseObj.Allocation_Time__c);
                                                          }
                                                          mcRecord.General_Field_3__c = caseObj.Case_Type__c;
                                                          mcRecord.General_Field_4__c = caseObj.Model_Txt__c;
                                                          mcRecord.General_Field_5__c = caseObj.Variant_Description__c;
                                                          mcRecord.General_Field_6__c = caseObj.Vehicle_Registration_Number__c;
                                                          mcRecord.Customer_Field_1__c = caseObj.Customer_Name__c;
                                                          mcRecord.Customer_Field_2__c = caseObj.Mobile_Number__c;
                                                          mcRecord.Customer_Field_3__c = caseObj.Registered_Contact_Number__c;
                                                          mcRecord.General_Field_7__c = caseObj.Job_Type__c;
                                                          mcRecord.General_Field_8__c = caseObj.Problem_Description__c;
                                                          mcRecord.General_Field_12__c = caseObj.Area__c;
                                                          if(mapCityIdToName != NULL && mapCityIdToName.keySet().size() > 0 && caseObj.City__c != NULL && mapCityIdToName.containsKey(caseObj.City__c)) {
                                                              mcRecord.General_Field_9__c = mapCityIdToName.get(caseObj.City__c);
                                                          }
                                                          mcRecord.General_Field_10__c = caseObj.Customer_Cancellation__c;
                                                          mcRecord.General_Field_11__c = caseObj.State__c;
                                                          if(mapIdToAllocatedDealer != NULL && mapIdToAllocatedDealer.keySet().size() > 0 && caseObj.Allocated_Dealer__c != NULL && mapIdToAllocatedDealer.containsKey(caseObj.Allocated_Dealer__c)) {
                                                              mcRecord.Dealer_Field_1__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).Name;
                                                              mcRecord.Dealer_Field_2__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).Dealer_Code__c;  
                                                              mcRecord.Dealer_Field_3__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).BillingCity; 
                                                              mcRecord.Dealer_Field_4__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).BillingState; 
                                                          } 
                                                          mcRecord.From_Name__c = caseObj.Region__c;
                                                          listMCCommunicationToInsert.add(mcRecord);
                                                      } 
                                                  }
    
    
    
    //Populate Emials in MC record
    public static void putEmails(MC_Communication__c mcRecord,String key,Map<String,String> mapHierarchyToEmails,Case caseObj,String fieldAPI) {
        if(mapHierarchyToEmails.containsKey(key+ConstantsUtility.keySeparator+caseObj.Channel__c) && mapHierarchyToEmails.get(key+ConstantsUtility.keySeparator+caseObj.Channel__c) != NULL) {
            mcRecord.put(fieldAPI,mapHierarchyToEmails.get(key+ConstantsUtility.keySeparator+caseObj.Channel__c));	    
        }    
    }
    
    //Email for Customer feedback
    public static void sendCustomerFeedbackEmail(Map<String,Map<String,String>> mapAllocatedDealerToStakeholderEmails,
                                                 List<MC_Communication__c> listMCCommunicationToInsert,
                                                 Map<String,String> mapRoleUser,Case caseObj
                                                 ,Map<Id,String> mapCityIdToName,Map<Id,Account> mapIdToAllocatedDealer) {
                                                     if(mapAllocatedDealerToStakeholderEmails != NULL && mapAllocatedDealerToStakeholderEmails.keySet().size() > 0 && mapAllocatedDealerToStakeholderEmails.containsKey(caseObj.Allocated_Dealer__c)) {
                                                         MC_Communication__c mcRecord = new MC_Communication__c();
                                                         mcRecord.Case__c = caseObj.Id;
                                                         mcRecord.Type__c = 'Email Customer Feedback';
                                                         Map<String,String> mapHierarchyToEmails = mapAllocatedDealerToStakeholderEmails.get(caseObj.Allocated_Dealer__c);
                                                         if(mapHierarchyToEmails != NULL && mapHierarchyToEmails.keySet().size() > 0) {
                                                             //Email for WM
                                                             putEmails(mcRecord,ConstantsUtility.NOTIFIER_L1A,mapHierarchyToEmails,caseObj,'Email_1__c');
                                                             
                                                             //Email for GM
                                                             putEmails(mcRecord,ConstantsUtility.NOTIFIER_L2A,mapHierarchyToEmails,caseObj,'Email_2__c');
                                                             
                                                             //Email for RSM
                                                             putEmails(mcRecord,ConstantsUtility.NOTIFIER_L4,mapHierarchyToEmails,caseObj,'L9_Email__c');
                                                             
                                                             //Email for ROC
                                                             putEmails(mcRecord,ConstantsUtility.MOSROC,mapHierarchyToEmails,caseObj,'L8E_Email__c');
                                                             
                                                             //Emial for TSM
                                                             putEmails(mcRecord,ConstantsUtility.NOTIFIER_L3A,mapHierarchyToEmails,caseObj,'L8D_Email__c');
                                                             
                                                             //Email for CEO
                                                             putEmails(mcRecord,ConstantsUtility.NOTIFIER_L2B,mapHierarchyToEmails,caseObj,'L8A_Email__c');
                                                             //Email for ZSH
                                                             putEmails(mcRecord,ConstantsUtility.NOTIFIER_L5,mapHierarchyToEmails,caseObj,'L5_Email__c');
                                                             //Email for TSM
                                                             putEmails(mcRecord,ConstantsUtility.L3A,mapHierarchyToEmails,caseObj,'L3A_Email__c');
                                                             
                                                         }
                                                         //Email for HO && DPM WPDCS
                                                         if(mapRoleUser != NULL && mapRoleUser.keySet().size() > 0) {
                                                             if(mapRoleUser.containsKey(ConstantsUtility.RoleHOMOS)) {
                                                                 mcRecord.L7B_Email__c = mapRoleUser.get(ConstantsUtility.RoleHOMOS);   
                                                             }
                                                             if(mapRoleUser.containsKey(ConstantsUtility.DPM_WPDCS_Role)) {
                                                                 mcRecord.L10_Email__c = mapRoleUser.get(ConstantsUtility.RoleHOMOS);   
                                                             }
                                                         }
                                                         mcRecord.General_Field_1__c = caseObj.FE_CaseNumber__c;
                                                         if(caseObj.Allocation_Time__c != NULL) {
                                                             mcRecord.General_Field_2__c = String.valueOf(caseObj.Allocation_Time__c);
                                                         }
                                                         mcRecord.General_Field_3__c = caseObj.Case_Type__c;
                                                         mcRecord.General_Field_4__c = caseObj.Model_Txt__c;
                                                         mcRecord.General_Field_5__c = caseObj.Variant_Description__c;
                                                         mcRecord.General_Field_6__c = caseObj.Vehicle_Registration_Number__c;
                                                         mcRecord.Customer_Field_1__c = caseObj.Customer_Name__c;
                                                         mcRecord.Customer_Field_2__c = caseObj.Mobile_Number__c;
                                                         mcRecord.Customer_Field_3__c = caseObj.Registered_Contact_Number__c;
                                                         mcRecord.General_Field_7__c = caseObj.Job_Type__c;
                                                         mcRecord.General_Field_8__c = caseObj.Problem_Description__c;
                                                         mcRecord.General_Field_12__c = caseObj.Area__c;
                                                         if(mapCityIdToName != NULL && mapCityIdToName.keySet().size() > 0 && caseObj.City__c != NULL && mapCityIdToName.containsKey(caseObj.City__c)) {
                                                             mcRecord.General_Field_10__c = mapCityIdToName.get(caseObj.City__c);
                                                         }	
                                                         mcRecord.General_Field_11__c = caseObj.State__c;
                                                         if(mapIdToAllocatedDealer != NULL && mapIdToAllocatedDealer.keySet().size() > 0 && caseObj.Allocated_Dealer__c != NULL && mapIdToAllocatedDealer.containsKey(caseObj.Allocated_Dealer__c)) {
                                                             mcRecord.Dealer_Field_1__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).Name;
                                                             mcRecord.Dealer_Field_2__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).Dealer_Code__c;  
                                                             mcRecord.Dealer_Field_3__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).BillingCity; 
                                                             mcRecord.Dealer_Field_4__c = mapIdToAllocatedDealer.get(caseObj.Allocated_Dealer__c).BillingState; 
                                                         } 
                                                         mcRecord.General_Field_9__c = caseObj.Customer_feedback__c;
                                                         mcRecord.Customer_Field_4__c = caseObj.Feedback_Reason__c;
                                                         mcRecord.From_Name__c = caseObj.Region__c;
                                                         listMCCommunicationToInsert.add(mcRecord);
                                                     }     
                                                 }
    
    //Send Emails to MS Allianz
    public static void sendEmailToMSAllianz(Case caseObj,List<MC_Communication__c> listMCCommunicationToInsert,Map<Id,String> mapCityIdToName) {
        MC_Communication__c mcRecord = new MC_Communication__c();
        mcRecord.Case__c = caseObj.Id;
        mcRecord.Type__c = 'Email To MSAllianz';
        mcrecord.Email_1__c = Label.MSAllianzEmail1;
        mcRecord.Email_2__c = Label.MSAllianzEmail2;
        mcRecord.L10_Email__c = Label.MSAllianzEmail3;
        mcRecord.L3A_Email__c = Label.MSAllianzEmail4;
        mcRecord.L3B_Email__c = Label.MSAllianzEmail5;
        mcRecord.L4_Email__c = Label.MSAllianzEmail6;
        mcRecord.General_Field_1__c = caseObj.FE_CaseNumber__c;
        mcRecord.General_Field_2__c = caseObj.CaseNumber;
        mcRecord.Customer_Field_1__c = caseObj.Customer_Name__c;
        mcRecord.Customer_Field_2__c = caseObj.Mobile_Number__c;
        mcRecord.General_Field_3__c = caseObj.Vehicle_Registration_Number__c;
        mcRecord.General_Field_4__c = caseObj.Variant_Description__c;
        mcRecord.General_Field_5__c = caseObj.Model_Txt__c;
        mcRecord.General_Field_6__c = caseObj.Color_Description__c;
        if(caseObj.Customer_Location__Latitude__s != NULL) {
            mcRecord.General_Field_7__c = String.valueOf(caseObj.Customer_Location__Latitude__s);    
        }
        if(caseObj.Customer_Location__Longitude__s != NULL) {
            mcRecord.General_Field_8__c = String.valueOf(caseObj.Customer_Location__Longitude__s);    
        }
        mcRecord.General_Field_12__c = caseObj.Area__c;
        mcRecord.General_Field_10__c = caseObj.State__c;
        if(mapCityIdToName != NULL && mapCityIdToName.keySet().size() > 0 && caseObj.City__c != NULL && mapCityIdToName.containsKey(caseObj.City__c)) {
            mcRecord.General_Field_11__c = mapCityIdToName.get(caseObj.City__c);
        }
        if(caseObj.Complaint_Registration_Time__c != NULL) {
            mcRecord.Dealer_Field_1__c = String.valueOf(caseObj.Complaint_Registration_Time__c);    
        }
        listMCCommunicationToInsert.add(mcRecord);
    }
}