/*
   Name : CloneTasksBatch
  Author :
  Description : This is used to clone task records to recordTask records.
  Date : 15th Oct 2020
*/
global class CloneTasksBatch implements Database.Batchable<sObject>,Database.Stateful{
    Set<Id> reportTaskSet = new Set<Id>();
    Set<Id> taskOwnerIds = new Set<Id>();
    Map<String,String> taskOwnerManagerMap = new Map<String,String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        // collect the batches of records or objects to be passed to execute
        String taskId = '00T7F00002RW40D';
        String ownerId = '0057F0000080QmjQAE';
        String whatType = 'Case';
        // WHERE what.type=: whatType
        //Service_Request_ID__c,IVR_Exit_Menu__c,Dialed_Mode__c,Feedback_Reason__c,Call_Priority__c,
        String query = 'SELECT Id, RecordTypeId, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate, Status, Priority,'; 
        query+='IsHighPriority, OwnerId, Description, Type, IsDeleted, AccountId, IsClosed, CreatedDate, CreatedById,';
        query+='LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, IsVisibleInSelfService, CallDurationInSeconds,';
        query+='CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, RecurrenceActivityId,'; 
        query+='IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType,'; 
        query+='RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear,';
        query+='RecurrenceRegeneratedType, TaskSubtype, CompletedDateTime, Schedule__c, DMS_Id__c, Reason__c, SubReason__c,';
        query+='X_Sell_Opty__c, DMS_Sync_Error__c, DMS_Sync_Error_Details__c, Model__c, Sending_Option__c, Customer_Email_ID__c,';
        query+='Customer_Mobile__c, Bank_Address__c, Time__c, Record_Type_Name__c, Financier__c, LOB__c, Enquiry_Stage__c,'; 
        query+=' Call_Start__c, Call_End__c, Call_Recording_URL__c, Service_Type__c, DNIS__c, IVR_Language__c,'; 
        query+=' Call_back_Phone_Number__c, Call_back_Date_Time__c, Dialling_Record_ID__c,'; 
        query+='Contact_ID__c, Call_Notes__c, Case__c, Disposition__c, Enquiry__c, Owner_s_Manager__c, Asset__c, Dealer_Name__c,'; 
        query+='Dealer_Public_Group_Name__c, CampaignId__c, Vehicle_Registration_Number__c, Mobile_Number_4__c, Vehicle_Sale_Date__c,';
        query+=' Enquiry_Scoring__c, Appointment_No__c, Do_Not_Call_Numbers__c, Odometer__c, Feedback_Outcome__c,'; 
        query+=' Mobile_Number_2__c, Mobile_Number_3__c, Veh_Service_Due_Dt__c, Last_Follow_Up_Remarks__c,'; 
        query+='Appointment_Date__c, Workshop__c, Rating__c, Expiry_Date__c, Vehicle_Model__c, EW_Expiry_Date__c, MCP_Expiry_Date__c,'; 
        query+='Campaign_Status__c, Appointment_Workshop__c, Complaint_No__c, Appointment_Type__c, Appointment_Pickup_Type__c,'; 
        query+='Campaign_Sub_Type__c, Service_Advisor__c FROM Task WHERE what.type =:whatType';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Task> scope){
        // process each batch of records
        List<ReportTask__c> reportTaskList = new List<ReportTask__c>();
        Database.SaveResult[] saveResultsList;
        System.debug('scope size'+scope.size());
        for(Task taskObj : scope){
            ReportTask__c reportTaskObj = new ReportTask__c();
            //Assign owner of task to report task record to show the records to CCE by sakib on 18/12/2020
            reportTaskObj.OwnerId = taskObj.OwnerId;
            //Assign To
            reportTaskObj.Assigned_To__c = taskObj.OwnerId;
            reportTaskObj.Status__c = taskObj.Status;
            reportTaskObj.Owner_s_Manager__c = taskObj.Owner_s_Manager__c;
            reportTaskObj.Priority__c = taskObj.Priority;
            //Customer
            reportTaskObj.Contact_ID__c = taskObj.Contact_ID__c;
            reportTaskObj.Complaint_No__c = taskObj.Complaint_No__c;
            reportTaskObj.Subject__c = taskObj.Subject;
            reportTaskObj.Asset__c = taskObj.Asset__c;
            //Due Date
            reportTaskObj.Due_Date__c = taskObj.ActivityDate;
            reportTaskObj.Campaign__c = taskObj.CampaignId__c;
            reportTaskObj.Customer_Email_ID__c = taskObj.Customer_Email_ID__c;
            //Campaign Type
            reportTaskObj.Campaign_Type__c = taskObj.Service_Type__c;
            reportTaskObj.Type__c =  taskObj.Type;
            reportTaskObj.Vehicle_Model__c = taskObj.Vehicle_Model__c;
            reportTaskObj.Campaign_Status__c = taskObj.Campaign_Status__c;
            reportTaskObj.Workshop__c = taskObj.Workshop__c;
            reportTaskObj.Cross_Sell_Opportunity__c = taskObj.X_Sell_Opty__c;
            reportTaskObj.Service_Advisor__c = taskObj.Service_Advisor__c;
            reportTaskObj.Vehicle_Sale_Date__c = String.ValueOf(taskObj.Vehicle_Sale_Date__c);
            reportTaskObj.Call_Start__c = taskObj.Call_Start__c;
            reportTaskObj.Call_End__c = taskObj.Call_End__c;
            //Customer Voice
            reportTaskObj.Call_Notes__c = taskObj.Call_Notes__c;
            //Response
            reportTaskObj.Response__c = taskObj.Disposition__c;
            //Follow up Date
            reportTaskObj.Call_back_Date_Time__c = taskObj.Call_back_Date_Time__c;
            //Call Back Number
            reportTaskObj.Call_Back_Number__c = taskObj.Call_back_Phone_Number__c;
            reportTaskObj.Customer_Mobile__c = taskObj.Customer_Mobile__c;
            reportTaskObj.Mobile_Number_2__c = taskObj.Mobile_Number_2__c;
            reportTaskObj.Mobile_Number_3__c = taskObj.Mobile_Number_3__c;
            reportTaskObj.Mobile_Number_4__c = taskObj.Mobile_Number_4__c;
            reportTaskObj.Rating__c = taskObj.Rating__c;
            reportTaskObj.Do_Not_Call_Numbers__c = taskObj.Do_Not_Call_Numbers__c;
            reportTaskObj.Call_Type__c = taskObj.CallType;
            //Dissatisfied Reason
            reportTaskObj.Feedback_Outcome__c = taskObj.Feedback_Outcome__c;
            //Comments
            reportTaskObj.Comments__c = taskObj.Description;
            reportTaskObj.Created_By__c = taskObj.CreatedById;
            reportTaskObj.Last_Modified_By__c = taskObj.LastModifiedById;
            //Name
            reportTaskObj.WhoId__c = taskObj.WhoId;
            //Related to
            reportTaskObj.WhatId__c = taskObj.WhatId;
            reportTaskObj.Reminder_Set__c = taskObj.IsReminderSet;
            //Unique identifier
            reportTaskObj.TaskId__c = taskObj.id;
            taskOwnerIds.add(taskObj.OwnerId);
            reportTaskList.add(reportTaskObj);
        }
        if(reportTaskList.size() > 0){
            System.debug('reportTaskList size'+reportTaskList.size());            
            saveResultsList = Database.insert(reportTaskList,false); 
        }
        //Fetch Task Owner Manager for record sharing
        System.debug('taskOwnerIds = '+taskOwnerIds);
        if(taskOwnerIds.size() > 0){
        	for(User u : [Select id,manager.id from user where id IN : taskOwnerIds]){
            	taskOwnerManagerMap.put(u.id,u.manager.id);
        	}    
        }
        //loop through the report task list for record sharing to its manager
        if(saveResultsList.size() > 0){
            for(Database.SaveResult sr : saveResultsList){
                if (sr.isSuccess()){
                    System.debug('insert record id = '+sr.getId());
                    reportTaskSet.add(sr.getId());
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Report Task records error: ' + err.getFields());
                    }
                }                
            }      
        }
        
    }
    global void finish(Database.BatchableContext BC){
        // execute any post-processing operations
        System.debug('report task ids = '+reportTaskSet);
        System.debug('taskOwnerManagerMap = '+taskOwnerManagerMap);
        List<ReportTask__share> reportTaskShareList = new List<ReportTask__share>();
        //fetch all insert report task records
        if(reportTaskSet.size() > 0){
            for(ReportTask__c rpObj : [SELECT id,OwnerId FROM ReportTask__c where Id IN : reportTaskSet]){
                System.debug('parentId = '+rpObj.Id);
                if(taskOwnerManagerMap.ContainsKey(rpObj.OwnerId)){
                    System.debug('Contains share record');
                    ReportTask__share reportTaskshare = new ReportTask__share();
                    reportTaskshare.accesslevel = 'Read';
                    reportTaskshare.parentId = rpObj.Id;
                    reportTaskshare.UserOrGroupId = taskOwnerManagerMap.get(rpObj.OwnerId);
                    reportTaskShareList.add(reportTaskshare);
                }
            }  
            if(reportTaskShareList.size() > 0){
                insert reportTaskShareList;
            }
        }        
    }
}