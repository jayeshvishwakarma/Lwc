/**
* @File Name          : CallDetailsController.cls
* @Description        : This class is used to fetch the data for Service Calculator
* @Author             : Nishant
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 7/1/2020, 9:58:19 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0   09/03/2020, 05:29:00 PM        Nishant                 Initial Version
* 1.1   06/05/2020, 03:37:30 PM        Nitin Ghai              Modified CallDetailsController method
* 1.2   28/05/2020, 05:37:30 PM        Nitin Ghai              If Dialling Record ID is blank then we are populating Task ID
* 1.3   08/06/2020, 03:37:30 PM        Nitin Ghai              Updated fetchTaskDetails method and Passed campaignType param 
* 1.4   13/06/2020, 03:37:30 PM        Nitin Ghai              Removed Last Follow Up Remark Update
* 1.5   30/06/2020, 04:37:30 PM        Nitin Ghai              For Service if Task is getting completed we will mark related Case as Closed
**/
public with sharing class CallDetailsController {
    
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will fetch the Picklist values and query the Metadata records
Inputs: Task Id, Record Id(Account or Case) & Task Record Type Name
Returns: Wrapper
History:
================
1.1A     09/03/2020      Nitin Ghai    Initial Version
*/
    @AuraEnabled
    public static taskRecDetails fetchTaskDetails(Id recordId,String recordTypeName,String campaignType){
        taskRecDetails tskData = new taskRecDetails();
        tskData.objectName =String.isNotBlank(recordId) ? recordId.getSObjectType().getDescribe().getName() : '';
        Schema.DescribeFieldResult feedbackOutcome = Task.Feedback_Outcome__c.getDescribe();
        List<Schema.PicklistEntry> pickfeedbackOutcome = feedbackOutcome.getPicklistValues();
        for( Schema.PicklistEntry pickVal : pickfeedbackOutcome){
            if (pickVal.isActive()) {
                tskData.taskFeedbackOutcome.put(pickVal.getLabel(),pickVal.getValue());
            }
        } 
        Schema.DescribeFieldResult taskRating = Task.Rating__c.getDescribe();
        List<Schema.PicklistEntry> picktaskRating = taskRating.getPicklistValues();
        for( Schema.PicklistEntry pickVal : picktaskRating){
            if (pickVal.isActive()) {
                tskData.taskRating.put(pickVal.getLabel(),pickVal.getValue());
            }
        } 
        campaignType = String.isNotBlank(campaignType) &&  (campaignType=='Appointment Reminder' || campaignType=='Appointment Confirmation') ? campaignType : NULL;
        
        if(String.isNotBlank(recordTypeName)){
            tskData.callDispoitions=[Select Call_Details_Label__c,Call_Details_Value__c,Task_Record_Type__c,Follow_up_Date_Required__c,Lost_Case_Feedback__c FROM 
                                     Call_Details_Disposition__mdt WHERE Task_Record_Type__c=:recordTypeName AND Campaign_Type__c=:campaignType
                                     ORDER BY Call_Details_Label__c ASC];
        }
        
        return tskData;
    }
    
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will update the Task Record and it will update the Case also when it is MI Related Task.
Inputs: Task JSON, Record Id(Case) & Task Record Type Name
Returns: String
History:
================
1.1A     28/05/2020      Nitin Ghai    Initial Version
*/
    @AuraEnabled
    public static String saveTaskData(String taskJSON,String caseRecId, String taskRecordTypeName){
        String response;
        Savepoint sp = Database.setSavepoint();
        try{
            Task tskData =String.isNotBlank(taskJSON) ? (Task) JSON.deserialize(taskJSON, Task.class) : NULL;
            if(tskData!=NULL){
                String tskRecTypName = String.isNotBlank(tskData.RecordTypeId) ? Schema.SObjectType.Task.getRecordTypeInfosById().get(tskData.RecordTypeId).getDeveloperName() :'';
                if(String.isNotBlank(tskRecTypName) && tskRecTypName!='MI_Renewal_Call' && tskData.Status=='Completed' 
                   && String.isNotBlank(tskData.Case__c)){
                       Case vehCase = new Case();
                       vehCase.Status='Closed';
                       vehCase.Id=tskData.Case__c;
                       update vehCase;
                   }
                tskData.ReminderDateTime= tskData.Call_back_Date_Time__c!=NULL ? (tskData.Call_back_Date_Time__c).addMinutes(-1): NULL;
                update tskData;
                
            }
            
            List<Call_Details_Disposition__mdt> callDisp = new List<Call_Details_Disposition__mdt>();
            if(tskData!=NULL && String.isNotBlank(tskData.Disposition__c) && String.isNotBlank(taskRecordTypeName) && taskRecordTypeName=='MI_Renewal_Call'){
                callDisp=[Select Equivalent_Case_Status__c FROM Call_Details_Disposition__mdt 
                          WHERE Call_Details_Value__c=:tskData.Disposition__c AND Task_Record_Type__c=:taskRecordTypeName LIMIT 1];
            }
            if(tskData!=NULL && callDisp.size()>0 && String.isNotBlank(caseRecId) && Id.valueOf(caseRecId).getSobjectType() == Case.getSObjectType() 
               && String.isNotBlank(callDisp[0].Equivalent_Case_Status__c) && callDisp[0].Equivalent_Case_Status__c!='Lost'){
                Case csDisp = new Case();
                csDisp.Status=callDisp[0].Equivalent_Case_Status__c;
                csDisp.Last_Follow_Up_Remarks__c=String.isNotBlank(tskData.Disposition__c) ? tskData.Disposition__c :'';
                csDisp.Pickup_Date__c = callDisp[0].Equivalent_Case_Status__c=='Appointment' ? tskData.Call_back_Date_Time__c : NULL;
                csDisp.Id=caseRecId;
                update csDisp;
            }
            response='SUCCESS';
        }catch(exception e){
            response='ERROR';Database.rollback(sp);ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='CallDetails - LWC';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('CallDetailsController - Class','taskJSON---->'+taskJSON +'/n'+e.getMessage()+' - Line Number: '+e.getLineNumber(), 'saveTaskData : Method','', ehst);
        }
        return response;
    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: Wrapper Class to contain Task Feedback Outcome & Rating Picklist values.
    Wrapper Class to contain Metadata record
    Wrapper Class to contain Object Name
    ================
    1.1A     09/03/2020      Nitin Ghai    Initial Version
    */
    public class taskRecDetails{
        @AuraEnabled public Map<String,String> taskFeedbackOutcome {get;set;}
        @AuraEnabled public Map<String,String> taskRating {get;set;}
        @AuraEnabled public List<Call_Details_Disposition__mdt> callDispoitions {get;set;}
        @AuraEnabled public String objectName {get;set;}
        public taskRecDetails(){
            taskFeedbackOutcome = new Map<String,String>();
            callDispoitions= new List<Call_Details_Disposition__mdt>();
            taskRating = new Map<String,String>();
            objectName='';
        }
    }
}