/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   Work Order Trigger Handler

History
Date            Author             Comments
--------------------------------------------------------------------------------------
13-02-2020      Nitin Ghai        Initial Release
28-02-2020      Nitin Ghai		  Added beforeUpdate Method 
04-02-2020		Sunit			  Added beforeUpdate() and updateStatus()
------------------------------------------------------------------------------------*/
public with sharing class WorkOrderTriggerHandler extends TriggerHandler {
    
    private List<WorkOrder> newWorkOrders;
    private Map<Id, WorkOrder> oldWorkOrdersMap;
    
    public WorkOrderTriggerHandler(){
        this.newWorkOrders = (List<WorkOrder>) Trigger.new;
        this.oldWorkOrdersMap = (Map<Id, WorkOrder>) Trigger.oldMap;
    }
    
    public override void beforeUpdate() {
        updateStatus();
    }

    public override void afterInsert() {
        //add work order share records to make appointment visible to dealer group       
        if(newWorkOrders.size()>0){
            WorkOrderGroupShareService.createShareRecords(newWorkOrders);
        }
    }
    
    public override void afterUpdate() {
        Set<Id> recordIds = new Set<Id>();
        set<Id> updateAppointmentRecordIds= new Set<Id>(); 
        for(WorkOrder newWrkOrd : newWorkOrders){
            WorkOrder oldWrkOrd = oldWorkOrdersMap.get(newWrkOrd.Id);
            //if owner is changed
            if(newWrkOrd.OwnerId != oldWrkOrd.OwnerId ){
                recordIds.add(newWrkOrd.Id);
            }
            //if Service Advisor or Slot Time or Appointment Datetime is changed we need to create record in MC Communication object so SFMC can pick the records and 
            //send an SMS to Customer and Service Advisor about the Update
            if(newWrkOrd.SA_Id__c != oldWrkOrd.SA_Id__c || newWrkOrd.Slot_Time__c != oldWrkOrd.Slot_Time__c || newWrkOrd.Appointment_Datetime__c != oldWrkOrd.Appointment_Datetime__c){
                updateAppointmentRecordIds.add(newWrkOrd.Id);
            }
        }
        //add share if work order owner group changes
        if(newWorkOrders.size()>0){
            WorkOrderGroupShareService.createShareRecords(newWorkOrders);
        }
        //generate MC record to send sms
        if(!updateAppointmentRecordIds.isEmpty()){
            GenerateFilePublicURL.CreateMCRecord('Update Appointment',updateAppointmentRecordIds,'WorkOrder','');
        }
        
    }

    //Set workorder status as rescheduled if time is changed
    public void updateStatus(){
        for(WorkOrder wo:newWorkOrders)
        {
            if(wo.Appointment_Datetime__c !=oldWorkOrdersMap.get(wo.Id).Appointment_Datetime__c ||wo.Slot_Time__c !=oldWorkOrdersMap.get(wo.Id).Slot_Time__c){
                wo.Status=ConstantsUtility.APPOINTMENT_RESCHEDULED;
                
            }
        }
    }
}