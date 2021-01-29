/*
* Author : Anas Yar Khan
* Company : Techmatrix Consulting
* Description : This class is used to sync cases from Salesforce to FarEye
*/
public class FESyncServiceClass {
    public static void publishPlatformEvent(List<Case> triggerNew,Set<Id> setIntegrationUserId,
                                            Map<Id,Case> triggerOldMap,Boolean isUpdate,
                                            Map<Id,String> mapCityIdToCityCode,
                                            Map<Id,String> mapIdToTechnicianId) {
                                                try {
                                                    //list to store pltaform events to publish
                                                    List<FarEye_Sync__e> listFarEyeEventToPublish = new List<FarEye_Sync__e>();
                                                    //Map to store custom metadata records
                                                    Map<String,FE_Sync_Criterias__mdt> mapKeyToFESyncMetadata = new Map<String,FE_Sync_Criterias__mdt>();
                                                    for(FE_Sync_Criterias__mdt feSync : [SELECT DeveloperName ,Field_List__c,Sync_Type__c,Object__c  
                                                                                         FROM FE_Sync_Criterias__mdt
                                                                                         WHERE Object__c  = :ConstantsUtility.FarEyeObject]) {
                                                                                             mapKeyToFESyncMetadata.put(feSync.Sync_Type__c,feSync);
                                                                                         }
                                                   
                                                    Set<String> setFEConditions = new Set<String>();
                                                    for(Far_Eye_Condition__mdt  feCond : [SELECT MOS_Case_Source__c,Job_Type__c,MOS_Case_Stage__c,Status__c FROM Far_Eye_Condition__mdt]) {
                                                        setFEConditions.add(feCond.MOS_Case_Source__c+'#'+feCond.Job_Type__c+'#'+feCond.MOS_Case_Stage__c+'#'+feCond.Status__c);    
                                                    }
                                                    if(mapKeyToFESyncMetadata.keySet().size() > 0
                                                       && triggerNew != NULL && triggerNew.size() > 0
                                                       && setIntegrationUserId != NULL && setIntegrationUserId.size() > 0) {
                                                           for(Case caseObj : triggerNew) {
                                                               FarEye_Sync__e farEyeEvent = new FarEye_Sync__e();
                                                               //Scenario 1
                                                               if(!setIntegrationUserId.contains(caseObj.CreatedById)
                                                                  && caseObj.Origin == ConstantsUtility.OriginSalesforce
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                                                  && (!isUpdate || caseObj.FE_CaseNumber__c == NULL)
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 1')) {
                                                                      createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 1'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                  }
                                                               //Scenario 2
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 2')) {
                                                                      createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 2'),mapCityIdToCityCode,mapIdToTechnicianId);    
                                                                  }
                                                               //Scenario 3
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  /*&& caseObj.Technician_Force_Assigned__c*/
                                                                  && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 3')) {
                                                                      if(isUpdate && caseObj.Technician_ID__c  != triggerOldMap.get(caseObj.Id).Technician_ID__c && caseObj.FE_CaseNumber__c != NULL) {
                                                                          createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 3'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                          farEyeEvent.Technician_Force_Assigned__c = true;
                                                                      }
                                                                      if(!isUpdate && caseObj.Technician_ID__c != NULL) {
                                                                          createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 3'),mapCityIdToCityCode,mapIdToTechnicianId);    
                                                                      }
                                                                     
                                                                  }
                                                               //Scenario 4
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                                                  && String.isNotBlank(caseObj.MOS_Case_Stage__c)
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 4')) {
                                                                      String key = getKey(caseObj);
                                                                      if(setFEConditions.contains(key)) {
                                                                          if(isUpdate && caseObj.MOS_Case_Stage__c  != triggerOldMap.get(caseObj.Id).MOS_Case_Stage__c && caseObj.FE_CaseNumber__c != NULL) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 4'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                          }
                                                                          /*if(!isUpdate) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 4'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          } */  
                                                                      }
                                                                     
                                                                  }
                                                               //Scenario 5
                                                               if(!setIntegrationUserId.contains(caseObj.CreatedById)
                                                                  && caseObj.Origin == ConstantsUtility.OriginSalesforce
                                                                  && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && (!isUpdate || caseObj.FE_CaseNumber__c == NULL)
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 5')) {
                                                                      createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 5'),mapCityIdToCityCode,mapIdToTechnicianId);    
                                                                  }
                                                               //Scenario 6
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 6')) {
                                                                      createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 6'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                  }
                                                               //Scenario 7
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental
                                                                  && String.isNotBlank(caseObj.MOS_Case_Stage__c)
                                                                  && caseObj.MOS_Case_Source__c != ConstantsUtility.MOSCaseSourceMCall
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 7')) {
                                                                      String key = getKey(caseObj);
                                                                      if(setFEConditions.contains(key)) {
                                                                          if(isUpdate && caseObj.MOS_Case_Stage__c  != triggerOldMap.get(caseObj.Id).MOS_Case_Stage__c && caseObj.FE_CaseNumber__c != NULL) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 7'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                          }
                                                                          /*if(!isUpdate) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 7'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                          } */  
                                                                      }
                                                                     
                                                                  }
                                                               //Scenario 8
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 8')) {
                                                                      createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 8'),mapCityIdToCityCode,mapIdToTechnicianId);    
                                                                  }
                                                               //Scenario 9
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation
                                                                  /*&& caseObj.Technician_Force_Assigned__c*/
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 9')) {
                                                                      if(isUpdate && caseObj.Technician_ID__c  != triggerOldMap.get(caseObj.Id).Technician_ID__c && caseObj.FE_CaseNumber__c != NULL) {
                                                                          createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 9'),mapCityIdToCityCode,mapIdToTechnicianId);
                                                                          farEyeEvent.Technician_Force_Assigned__c = true;
                                                                      }
                                                                      if(!isUpdate && caseObj.Technician_ID__c != NULL) {
                                                                          createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 9'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                      }    
                                                                  }
                                                               //Scenario 10
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == ConstantsUtility.JOB_TYPE_Accidental
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 10')
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL) {
                                                                      String key = getKey(caseObj);
                                                                      if(setFEConditions.contains(key)) {
                                                                          if(caseObj.Customer_Consent__c  != triggerOldMap.get(caseObj.Id).Customer_Consent__c
                                                                            || caseObj.Job_Type__c != triggerOldMap.get(caseObj.Id).Job_Type__c
                                                                            || caseObj.MOS_Case_Source__c != triggerOldMap.get(caseObj.Id).MOS_Case_Source__c
                                                                            || caseObj.MOS_Case_Stage__c != triggerOldMap.get(caseObj.Id).MOS_Case_Stage__c
                                                                            || caseobj.Status != triggerOldMap.get(caseObj.Id).Status) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 10'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }
                                                                          /*if(!isUpdate) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 10'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }*/  
                                                                      }
                                                                     
                                                                     
                                                                  }
                                                               //Scenario 10
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                                                  && caseobj.MOS_Case_Stage__c == ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 10')
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL) {
                                                                      String key = getKey(caseObj);
                                                                      if(setFEConditions.contains(key)) {
                                                                          if(caseObj.Customer_Consent__c  != triggerOldMap.get(caseObj.Id).Customer_Consent__c
                                                                            || caseObj.Job_Type__c != triggerOldMap.get(caseObj.Id).Job_Type__c
                                                                            || caseObj.MOS_Case_Source__c != triggerOldMap.get(caseObj.Id).MOS_Case_Source__c
                                                                            || caseObj.MOS_Case_Stage__c != triggerOldMap.get(caseObj.Id).MOS_Case_Stage__c
                                                                            || caseobj.Status != triggerOldMap.get(caseObj.Id).Status) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 10'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }
                                                                          /*if(!isUpdate) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 10'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }*/  
                                                                      }
                                                                     
                                                                     
                                                                  }
                                                               //Scenario 10
                                                               
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == 'MCall-No Allocation'
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 10')
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL) {
                                                                      String key = getKey(caseObj);
                                                                      if(setFEConditions.contains(key)) {
                                                                          if(caseObj.Customer_Consent__c  != triggerOldMap.get(caseObj.Id).Customer_Consent__c
                                                                            || caseObj.Job_Type__c != triggerOldMap.get(caseObj.Id).Job_Type__c
                                                                            || caseObj.MOS_Case_Source__c != triggerOldMap.get(caseObj.Id).MOS_Case_Source__c
                                                                            || caseObj.MOS_Case_Stage__c != triggerOldMap.get(caseObj.Id).MOS_Case_Stage__c
                                                                            || caseobj.Status != triggerOldMap.get(caseObj.Id).Status) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 10'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }
                                                                          /*if(!isUpdate) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 10'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }*/  
                                                                      }
                                                                     
                                                                     
                                                                  }
                                                               //Scenario 11
                                                               if(!setIntegrationUserId.contains(caseObj.LastModifiedById)
                                                                  && caseObj.MOS_Case_Source__c == ConstantsUtility.MOSCaseSourceMCall
                                                                  && caseObj.Job_Type__c == ConstantsUtility.Job_Type_Breakdown
                                                                  && caseobj.MOS_Case_Stage__c != ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation
                                                                  && mapKeyToFESyncMetadata.containsKey('Scenario 11')
                                                                  && isUpdate
                                                                  && caseObj.FE_CaseNumber__c != NULL) {
                                                                      String key = getKey(caseObj);
                                                                      if(setFEConditions.contains(key)) {
                                                                          //if(isUpdate && caseObj.MOS_Case_Stage__c  != triggerOldMap.get(caseObj.Id).MOS_Case_Stage__c ) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 11'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          //}
                                                                         /* if(!isUpdate) {
                                                                              createFarEyeEvent(farEyeEvent,caseObj,mapKeyToFESyncMetadata.get('Scenario 11'),mapCityIdToCityCode,mapIdToTechnicianId);  
                                                                          }
*/
                                                                      }
                                                                     
                                                                     
                                                                  }
                                                               
                                                               
                                                               //Adding event to List  
                                                               farEyeEvent.Last_sync_source__c = 'Salesforce';
                                                               listFarEyeEventToPublish.add(farEyeEvent);
                                                           }
                                                       }
                                                   
                                                    if(listFarEyeEventToPublish.size() > 0) {
                                                        EventBus.publish(listFarEyeEventToPublish);
                                                    }    
                                                }
                                                catch(Exception e) {
                                                    ExceptionHandler.LogError('FESyncServiceClass', e.getMessage()+':'+e.getLineNumber(), 'Salesforce To FarEye Integration', '', null);
                                                }
                                            }
   
   
    //This method is used to map fields of FarEye Platform events with the Case Fields
    public static void createFarEyeEvent(FarEye_Sync__e farEyeEvent,Case caseObj,
                                         FE_Sync_Criterias__mdt feSync,
                                         Map<Id,String> mapCityIdToCityCode,
                                         Map<Id,String> mapIdToTechnicianId) {
                                             try {
                                                 Map<String,Object> fieldListToSync = (Map<String,Object>) JSON.deserializeUntyped(feSync.Field_List__c);
                                                 if(fieldListToSync != NULL && fieldListToSync.keySet().size() > 0) {
                                                     for(String eventField : fieldListToSync.keySet()) {
                                                         if(eventField == 'City__c' && mapCityIdToCityCode != NULL && mapCityIdToCityCode.containsKey(caseObj.City__c)) {
                                                             farEyeEvent.put(eventField,mapCityIdToCityCode.get((Id)caseObj.get((String)fieldListToSync.get(eventField))));    
                                                         }
                                                         else if(eventField == 'Technician_ID__c' && mapIdToTechnicianId != NULL && mapIdToTechnicianId.containsKey(caseObj.Technician_ID__c)) {
                                                             farEyeEvent.put(eventField,mapIdToTechnicianId.get((Id)caseObj.get((String)fieldListToSync.get(eventField))));    
                                                         }
                                                         else {
                                                             farEyeEvent.put(eventField,caseObj.get((String)fieldListToSync.get(eventField)));    
                                                         }
                                                     }
                                                 }
                                                 
                                                 if(String.isBlank(farEyeEvent.Event_Type__c)) {
                                                     farEyeEvent.Event_Type__c = feSync.Sync_Type__c;    
                                                 }
                                                 else {
                                                     farEyeEvent.Event_Type__c += ','+feSync.Sync_Type__c;  
                                                 }    
                                             }
                                             catch(Exception e) {
                                                 ExceptionHandler.LogError('FESyncServiceClass', e.getMessage()+':'+e.getLineNumber(), 'Salesforce To FarEye Integration Field Mapping', '', null);    
                                             }
                                         }
   
    public static String getKey(Case caseObj) {
        String key = '';
        if(caseObj.MOS_Case_Source__c == 'M-Call') {
        key = 'MCall';    
        }
        else {
        key = 'Not MCall';    
        }
        return key+'#'+caseObj.Job_Type__c+'#'+caseObj.MOS_Case_Stage__c+'#'+caseObj.Status;
    }
}