/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   Work Order Group Share Service. When a CCE will create an Appointment. We will query the Parent group from 
               his Dealer Account. On that Parent Group	we will query and check if the user belong to that Group then we will share the record 
               with Group Members with Edit access.

History
Date            Author             Comments
--------------------------------------------------------------------------------------
13-02-2020      Nitin Ghai        Initial Release
19-02-2020      Nitin Ghai		  Added the RecordType Condition
------------------------------------------------------------------------------------*/
public without sharing class WorkOrderGroupShareService {
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: When a Executive will create an Appointment. We will query the Parent group from 
                 his Dealer Account. On that Parent Group, We will query and check if the user belong to that Group then we will share the record 
                 with Group Members with Edit access
    Inputs: List<WorkOrder>
    Returns:
    History:
    ================
    1.1A     19-02-2020      Nitin Ghai    Initial Version
    */
    public static void createShareRecords(List<WorkOrder> workOrderList){
        try{
            List<Id> recordIds = new List<Id>();
            Id serviceAppointmentRecID = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(ConstantsUtility.ServiceAppointmentRecTypeName).getRecordTypeId();
            if(workOrderList.size()>0){
                Map<Id,Id> ownerIdRecordId = new Map<Id,Id>(); // Map to Store WorkOrder Record Id and OwnerID
                Map<Id,String> ownerIdDealerParentGroupName = new Map<Id,String>(); // Map to store OWner Id and Parent Group Name on Dealer Record
                Map<Id,Id> ownerIdGroupId = new Map<Id,Id>(); // Map to store OwnerId and Group ID to which user belongs
                /*populate service TSM to worksorder*/
                  Set<Id> workShopIdSet = new Set<Id>();
                  Map<Id,String> workshopMap = new Map<Id,String>();
                for(WorkOrder wo : workOrderList){
                    if(String.valueOf(wo.OwnerId).substring(0,3)=='005' && wo.RecordTypeId==serviceAppointmentRecID){
                        recordIds.add(wo.Id);
                        ownerIdRecordId.put(wo.Id,wo.OwnerId);
                    }
                     if(wo.Workshop__c!=null){
                         workShopIdSet.add(wo.Id);
                         system.debug('46 workshop'+workShopIdSet);
                    }
                }
                
            for(WorkOrder workOrdre : [SELECT id, Workshop__c,Workshop__r.Service_TSM__c FROM WorkOrder WHERE Id IN : workShopIdSet]){           
                        if(workOrdre.Workshop__c!=null){
                           workshopMap.put(workOrdre.id,workOrdre.Workshop__r.Service_TSM__c);//storing service TSM
                           system.debug('52 workshop'+workOrdre);
                        }
                    }
                
                if(ownerIdRecordId.size()>0){
                    for(User us : [Select Id,Contact.Account.Parent_Group__c FROM User where ID IN: ownerIdRecordId.Values() AND Contact.Account.Parent_Group__c!=NULL AND isPortalEnabled=True]){
                        ownerIdDealerParentGroupName.put(us.Id,us.Contact.Account.Parent_Group__c);
                    }
                }
                
                if(ownerIdDealerParentGroupName.size()>0){
                    for(GroupMember grMem : [Select GroupId,UserorGroupId FROM GroupMember WHERE UserorGroupID IN: ownerIdDealerParentGroupName.keySet() AND Group.Name IN: ownerIdDealerParentGroupName.Values()]){
                        ownerIdGroupId.put(grMem.UserorGroupId,grMem.GroupId);
                    }
                }
                
                // This is used to Create Share records for work Order and assign the Ownership to Group
                system.debug('83 ownerIdGroupId'+ownerIdGroupId); 
                if(ownerIdGroupId.size()>0){
                    List<WorkOrderShare> workOrdShare = new List<WorkOrderShare>();
                    for(Id recId : recordIds){
                        //added if condition below to avoid errors during data load
                        if(ownerIdGroupId.get(String.valueOf(recId))!=null && ownerIdGroupId.get(ownerIdGroupId.get(String.valueOf(recId)))!=null){
                            WorkOrderShare workOrdShareRec = new WorkOrderShare();
                             workOrdShareRec.accesslevel=label.WorkOrder_Share_Access;
                             workOrdShareRec.parentId=String.valueof(recId);
                             workOrdShareRec.UserOrGroupId=ownerIdGroupId.get(ownerIdRecordId.get(String.valueof(recId)));
                             workOrdShare.add(workOrdShareRec);
                            system.debug('81 workOrdShare'+workOrdShare); 
                        }
                        system.debug('82 workshopMap'+workshopMap);  
                    }
                     system.debug('71 workshopMap'+workshopMap); 
                  if(workshopMap.size()>0){
                    system.debug('73 workshopMap'+workshopMap);
                    for(Id  workId:workshopMap.keySet()){
                             WorkOrderShare workOrdShareRec2 = new WorkOrderShare();
                             workOrdShareRec2.accesslevel='Read';
                             workOrdShareRec2.parentId=workId;
                             workOrdShareRec2.UserOrGroupId=workshopMap.get(workId);
                             workOrdShare.add(workOrdShareRec2);
                        system.debug('90 workOrdShare'+workOrdShareRec2);
                       }
                    } 
                system.debug('100 workOrdShare'+workOrdShare);
                    
                    if(workOrdShare.size()>0)
                    //modified to handle errors due to bad data during load
                        Database.insert(workOrdShare,false);
                        //insert workOrdShare;
                }
            }
        }catch(Exception e) {
            ExceptionHandler.stackTrace trace = new ExceptionHandler.stackTrace();trace.componentName = 'WorkOrder - Trigger';trace.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('WorkOrderGroupShareService - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'WorkOrder object : createShareRecords - Method', '', trace);
        }
    }
}