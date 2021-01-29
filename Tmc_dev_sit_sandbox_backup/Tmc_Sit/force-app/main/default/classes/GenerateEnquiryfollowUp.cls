/**
* @File Name          : GenerateEnquiryfollowUp.cls
* @Description        : This Class is used to generate the Pre and Post booking enquiry followups.
* @Author             : Anuj Kumar
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/19/2020, 7:10:56 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    17/7/2019 11:17 AM          Anuj Kumar            Initial Version
**/

public without sharing class GenerateEnquiryfollowUp {


    /*
@Author:                  Anuj Kumar
@Created Date :           26-Nov-2019
@Discription:             Method To Fetch Related Enquiry details from Current Task Details.
@Date Of Modification :   26-Nov-2019
*/
    @AuraEnabled
    public static object retriveEnquiryInfo(String recordId){
        //If record id is not blank
        if(String.isNotBlank(recordId)){
            //Initializing Task list
            List<Task> tsk = new List<Task>([Select id, whatId from Task Where Id =: recordId]);
            if(tsk != Null && tsk.size() > 0 && tsk[0].whatId != Null && string.valueOf(tsk[0].whatId).startsWith(ConstantsUtility.OPPORTUNITY_KEY_PREFIX)){
                //assigning whatId
                string enquiryId = tsk[0].whatId;
                //store return enquiry record by calling
                Opportunity opportunityRec = retriveEnquiryDetail(enquiryId);
                if(opportunityRec != Null){
                    return opportunityRec;
                }
            }
        }
        return system.label.Server_Error;
    }

    @AuraEnabled
    public static Boolean checkUserPermissions(String recordId){

        Opportunity opp = new Opportunity();
        if(String.isNotBlank(recordId) && recordId.startsWith('006')){
            List<Opportunity> opportunityRec = new List<Opportunity>([Select id, Current_Open_Follow_up__c
                                                                      From Opportunity Where Id =: recordId]);
            if(opportunityRec != Null && opportunityRec.size() > 0){
                opp = opportunityRec[0];
            }
        }else if(String.isNotBlank(recordId) && recordId.startsWith('00T')){
            List<Task> taskList = new List<Task>([Select id, whatId from Task Where Id =: recordId]);
            if(taskList != Null && taskList.size() > 0 && taskList[0].whatId != Null
                    && string.valueOf(taskList[0].whatId).startsWith('006')){
                   List<Opportunity> opportunityRec = new List<Opportunity>([Select id, Current_Open_Follow_up__c
                                                                             From Opportunity Where Id =: taskList[0].whatId]);
                   if(opportunityRec != Null && opportunityRec.size() > 0){
                       opp = opportunityRec[0];
                   }
               }
        }


        List<Task> tsk = new  List<Task>();
        if(opp.Current_Open_Follow_up__c != null){
            tsk = new List<Task>([Select id, whatId, recordType.Name from Task Where Id =: opp.Current_Open_Follow_up__c]);
        }


        String userId = userInfo.getUserId();
        List<String> profileList = system.label.RestrictFollowUpFromProfile != null ?
            system.label.RestrictFollowUpFromProfile.split(';') : new List<String>();

        List<User> userData = new List<User>([Select id, profileId, profile.Name, IsPortalEnabled from User
                                              Where Id =: userId]);

        if(userData != null && userData.size() > 0){
            User usr = userData[0];
            if(usr.IsPortalEnabled && profileList.contains(usr.profile.Name)){

                if(usr.profile.Name == 'Dealer Accessories User'
                   && tsk != Null && tsk.size() > 0
                   && tsk[0].recordType.Name == ConstantsUtility.GENERAL_FOLLOW_UP_TASK_REC_TYPE){
                       return true;
                   }else{
                       return false;
                   }
            }
            else if(usr.IsPortalEnabled == false && usr.profile.Name == ConstantsUtility.PROFILE_SYSTEM_ADMIN){
                return true;
            }else if(usr.IsPortalEnabled){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }

    }

    @AuraEnabled
    public static Opportunity retriveEnquiryDetail(String recordId){
        Opportunity opp = new Opportunity();
        if(String.isNotBlank(recordId)){
            List<Opportunity> opportunityRec = new List<Opportunity>([Select id,Email__c, Name,Mobile__c,StageName, Current_Open_Follow_up__c,Customer__r.Name,
                                                                      Variant__r.Name, Enquiry_Scoring__c, Enquiry_Stage__c, RecordTypeId, RecordType.Name
                                                                      From Opportunity Where Id =: recordId]);
            if(opportunityRec != Null && opportunityRec.size() > 0){
                opp = opportunityRec[0];
            }
        }
        return opp;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             Method To Fetch Current Open Task Details With Enquiry Approval Status.
@Date Of Modification :   22/July/2019
*/
    @AuraEnabled(cacheable=true)
    public static EnquiryInfo retriveOpenTaskInfo(String enquiryId, String stageName, String taskId){

        EnquiryInfo enInfo = new EnquiryInfo();

        retriveTaskTypeFields(enInfo);
        system.debug('== enInfo '+enInfo);


        enInfo.tsk = new Task();
        enInfo.approvalStatus = '';
        checkEnquiryApprovalStatus(enquiryId, stageName, enInfo);

        if(taskId == Null){
            List<Task> taskList = new List<Task>();
            if(enInfo.approvalStatus == ''){

                taskList = [Select id, ActivityDate, Type, Enquiry_Stage__c, IsReminderSet, ReminderDateTime from Task Where
                            whatId =: enquiryId And status =: ConstantsUtility.STATUS_OPEN AND first_followup__c = True Limit 1 ];
            }
            if(!taskList.isEmpty()){
                enInfo.tsk = taskList[0];
                return enInfo;
            }else {
                return enInfo;
            }
        }else if(String.isNotBlank(taskId)){
            List<Task> taskList = new List<Task>();

            if(isTaskAccessPermission()){
                taskList = [Select id, ActivityDate, Type, Enquiry_Stage__c,IsReminderSet, ReminderDateTime from Task Where Id =: taskId Limit 1];
            }
            if(!taskList.isEmpty()){
                enInfo.tsk = taskList[0];

                return enInfo;
            }else {
                return enInfo;
            }
        }
        return enInfo;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           16-Oct-2019
@Discription:             To Retrive Task type Picklist value based on recordtype information.
@Date Of Modification :   16-Oct-2019
*/
    public static void retriveTaskTypeFields(EnquiryInfo enInfo){

        List<String> preBookingAvaialbleList = (SYSTEM.label.Pre_Booking_Follow_up_Type_Field != null &&
                                                SYSTEM.label.Pre_Booking_Follow_up_Type_Field != '' ) ?
            (SYSTEM.label.Pre_Booking_Follow_up_Type_Field).split(';') :
        Null;
        List<String> postBookingAvaialbleList = (SYSTEM.label.Post_Booking_Follow_up_Type_Field != null &&
                                                 SYSTEM.label.Post_Booking_Follow_up_Type_Field != '' ) ?
            (SYSTEM.label.Post_Booking_Follow_up_Type_Field).split(';') :
        Null;

        List<PreBookingTaskType> preBookingTaskTypeList = new List<PreBookingTaskType>();
        List<PostBookingTaskType> postBookingTaskTypeList = new List<PostBookingTaskType>();

        Schema.DescribeFieldResult typeFieldResult = Task.Type.getDescribe();
        List<Schema.PicklistEntry> typeFieldResultEntry = typeFieldResult.getPicklistValues();

        for( Schema.PicklistEntry field : typeFieldResultEntry){

            PreBookingTaskType pre = new PreBookingTaskType();
            pre.label = field.getLabel();
            pre.value = field.getValue();

            PostBookingTaskType post = new PostBookingTaskType();
            post.label = field.getLabel();
            post.value = field.getValue();

            if(preBookingAvaialbleList.contains(field.getValue())){
                preBookingTaskTypeList.add(pre);
            }
            if(postBookingAvaialbleList.contains(field.getValue())){
                postBookingTaskTypeList.add(post);
            }
        }


        enInfo.preBookingTaskTypeList = preBookingTaskTypeList;
        enInfo.postBookingTaskTypeList = postBookingTaskTypeList;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             To Check the Enquiry Approval Status.
@Date Of Modification :   22/July/2019
*/
    public static void checkEnquiryApprovalStatus(String enquiryId, String stageName, EnquiryInfo enInfo){
        string status = '';

        if(stageName == ConstantsUtility.STAGE_CLOSELOST){
            status = ConstantsUtility.STATUS_APPROVED;
        }else{
            List<ProcessInstanceWorkitem> enquiryInPendingState = new List<ProcessInstanceWorkitem>();

            if(isProcessInstanceAccessPermission()){
                enquiryInPendingState = [Select Id, ProcessInstance.TargetObjectId  from ProcessInstanceWorkitem
                                         where ProcessInstance.TargetObjectId =: enquiryId ];
            }

            List<Task> taskList = new List<Task>();

            if(enquiryInPendingState.size() > 0){
                status = ConstantsUtility.STATUS_PENDING;
            }else if(status == '' && isTaskAccessPermission()){
                taskList = [Select id, ActivityDate, CreatedDate, IsReminderSet, ReminderDateTime from task where
                            whatId =: enquiryId AND Subject =: ConstantsUtility.TASK_SUBJECT And
                            status =: ConstantsUtility.STATUS_OPEN Limit 1];
            }

            string taskRecordTypeId;
            if(stageName == ConstantsUtility.STATUS_APPROVED || stageName == ConstantsUtility.STATUS_PENDING){
                taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.PRE_BOOKING_FOLLOWUP).getRecordTypeId();
            }else{
                taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.POST_BOOKING_FOLLOWUP ).getRecordTypeId();
            }

            if(taskList.size() > 0 && taskList[0].CreatedDate < taskList[0].ActivityDate){
                taskList[0].recordTypeId = taskRecordTypeId;
                status = ConstantsUtility.STATUS_REJECTED;
                enInfo.tsk = taskList[0];
            }
        }

        enInfo.approvalStatus = status;
    }


    /*
@Author:                  Anuj Kumar
@Created Date :           06-Nov-2019
@Discription:             Method To Fetch Current Open general Task Details.
@Date Of Modification :   06-Nov-2019
*/
    @AuraEnabled(cacheable=true)
    public static GeneralTaskInfo retriveGeneralFollowUpDetail(String enquiryId, String taskId){

        GeneralTaskInfo general = new GeneralTaskInfo();
        List<Task> taskList = new List<Task>();
        if(taskId == Null){
            taskList = [Select id, ActivityDate, Type, Enquiry_Stage__c, IsReminderSet, ReminderDateTime from Task Where
                            whatId =: enquiryId And status =: ConstantsUtility.STATUS_OPEN AND first_followup__c = True Limit 1 ];
            if(taskList != Null && taskList.size() > 0){
                general.tsk = taskList[0];
            }
        }
        if(enquiryId != Null && enquiryId != ''){
            if(taskId != Null){
                taskList = new List<Task>([Select id, ActivityDate, Type, Enquiry_Stage__c, IsReminderSet,
                                                      ReminderDateTime from Task Where
                                                      Id =: taskId AND
                                                      whatId =: enquiryId And status =: ConstantsUtility.STATUS_OPEN Limit 1]);
                if(taskList != Null && taskList.size() > 0){
                    general.tsk = taskList[0];
                }
            }
            List<String> generalStatusAvaialbleList = (SYSTEM.label.General_Follow_up_Status_Field != null &&
                                                       SYSTEM.label.General_Follow_up_Status_Field != '' ) ?
                (SYSTEM.label.General_Follow_up_Status_Field).split(';') :
            Null;
            List<String> generalActionAvaialbleList = (SYSTEM.label.General_Follow_up_Type_Field != null &&
                                                       SYSTEM.label.General_Follow_up_Type_Field != '' ) ?
                (SYSTEM.label.General_Follow_up_Type_Field).split(';') :
            Null;

            List<String> genEnqStageAvaialbleList = (SYSTEM.label.General_Follow_up_Stage_Field != null &&
                                                     SYSTEM.label.General_Follow_up_Stage_Field != '' ) ?
                (SYSTEM.label.General_Follow_up_Stage_Field).split(';') :
            Null;

            // FOR GENERAL FOLLOW UP STATUS FIELD
            Schema.DescribeFieldResult oppEnqScoResult = Opportunity.Enquiry_Scoring__c.getDescribe();
            List<Schema.PicklistEntry> oppEnqScoResultEntry = oppEnqScoResult.getPicklistValues();

            List<GeneralStatus> generalStatusList = new List<GeneralStatus>();
            for( Schema.PicklistEntry field : oppEnqScoResultEntry){

                GeneralStatus status = new GeneralStatus();
                status.label = field.getLabel();
                status.value = field.getValue();
                if(generalStatusAvaialbleList.contains(field.getValue())){
                    generalStatusList.add(status);
                }
            }

            // FOR PARTS FOLLOW UP STATUS FIELD
            Schema.DescribeFieldResult oppPartEnqScoResult = Opportunity.Parts_Enquiry_Scoring__c.getDescribe();
            List<Schema.PicklistEntry> oppPartEnqScoResultEntry = oppPartEnqScoResult.getPicklistValues();

            List<PartStatus> partStatusList = new List<PartStatus>();
            for( Schema.PicklistEntry field : oppPartEnqScoResultEntry){

                PartStatus status = new PartStatus();
                status.label = field.getLabel();
                status.value = field.getValue();
                partStatusList.add(status);

            }

            // FOR GENERAL FOLLOW UP TYPE FIELD
            Schema.DescribeFieldResult taskTypeResult = Task.Type.getDescribe();
            List<Schema.PicklistEntry> taskTypeResultEntry = taskTypeResult.getPicklistValues();

            List<GeneralAction> generalActionList = new List<GeneralAction>();
            for( Schema.PicklistEntry field : taskTypeResultEntry){

                GeneralAction action = new GeneralAction();
                action.label = field.getLabel();
                action.value = field.getValue();
                if(generalActionAvaialbleList.contains(field.getValue())){
                    generalActionList.add(action);
                }
            }

            // FOR GENERAL FOLLOW UP STAGE FIELD
            Schema.DescribeFieldResult oppStageResult = Opportunity.Enquiry_Stage__c.getDescribe();
            List<Schema.PicklistEntry> oppStageResultEntry = oppStageResult.getPicklistValues();

            List<GeneralEnquiryStage> generalEnquiryStageList = new List<GeneralEnquiryStage>();
            for( Schema.PicklistEntry field : oppStageResultEntry){

                GeneralEnquiryStage stage = new GeneralEnquiryStage();
                stage.label = field.getLabel();
                stage.value = field.getValue();
                if(genEnqStageAvaialbleList.contains(field.getValue())){
                    generalEnquiryStageList.add(stage);
                }
            }

            general.generalStatusList = generalStatusList;
            general.partStatusList = partStatusList;
            general.generalActionList = generalActionList;
            general.generalEnquiryStageList = generalEnquiryStageList;
        }


        return  general;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             Method To Fetch Enquiry dependent Reason picklist value.
@Date Of Modification :   22/July/2019
*/
    @AuraEnabled(cacheable=true)
    public static List<String> retriveReasonList(String selectedEnquiryScoring){

        Map<String, List<String>> dependentReasonMap = new Map<String, List<String>>();

        if(String.isNotBlank(selectedEnquiryScoring)){
            Opportunity opp = new Opportunity();
            dependentReasonMap = RetriveDependentPicklistData.getDependentMap(opp, ConstantsUtility.FIELD_ENQUIRYSCORING, ConstantsUtility.FIELD_REASON);

            if(dependentReasonMap.containsKey(selectedEnquiryScoring)){
                return dependentReasonMap.get(selectedEnquiryScoring);
            }

        }

        return new List<String>();

    }

    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             Method To Fetch Sub Reason from Reason picklist value.
@Date Of Modification :   22/July/2019
*/
    @AuraEnabled(cacheable=true)
    public static List<String> retriveSubReasonList(String selectedReason){

        Map<String, List<String>> dependentSubReasonMap = new Map<String, List<String>>();

        if(String.isNotBlank(selectedReason)){
            Opportunity opp = new Opportunity();
            dependentSubReasonMap = RetriveDependentPicklistData.getDependentMap(opp, ConstantsUtility.FIELD_REASON, ConstantsUtility.FIELD_SUBREASON);

            if(dependentSubReasonMap.containsKey(selectedReason)){
                return dependentSubReasonMap.get(selectedReason);
            }
        }

        return new List<String>();

    }

    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             Method To Create Pre FollowUp with Status as Open.
@Date Of Modification :   22/July/2019
*/
    @AuraEnabled
    public static string createPreOrPostOpenFollowUp(String enquiryId, string newTaskData, string recordTypeName){
        Savepoint sp = Database.setSavepoint();

        string errorMessage = '';
        string taskRecordTypeId = '';
        Task tsk = new Task();
        try{
            String dealerEmployeeCode = retriveDealerEmployeeCode();

        if(recordTypeName != Null && recordTypeName != ''){
            tsk = (Task)JSON.deserialize(newTaskData, Task.class);

                taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                tsk.Subject = recordTypeName;
                tsk.IsReminderSet = true;
                tsk.ActivityDate = Date.valueOf(tsk.ReminderDateTime);
                    Time myTime = Time.newInstance(tsk.ReminderDateTime.hour(), tsk.ReminderDateTime.minute(), tsk.ReminderDateTime.second(), tsk.ReminderDateTime.millisecond());
                    tsk.Time__c = myTime;
                tsk.WhatId = enquiryId;

                List<Opportunity> ltOpp = new List<Opportunity>();

                if(isOpportunityAccessPermission()){
                    ltOpp = [select id,customer__r.personcontactId from Opportunity where id = :enquiryId limit 1];
                }
                if(ltOpp != null && ltOpp.size() > 0 && ltOpp[0].Customer__r.personcontactid != null){
                    tsk.Enquiry_Customer__c = ltOpp[0].Customer__r.personcontactid;
                }
                tsk.recordTypeId = taskRecordTypeId;
                tsk.Status = ConstantsUtility.STATUS_OPEN;
                tsk.IsVisibleInSelfService = true;

                if(isTaskCreatePermission()){
                    Insert tsk;
                }

            if(tsk.Id != Null && enquiryId != '' && isOpportunityUpdatePermission()){
                opportunity op = new opportunity();
                op.Id = enquiryId;
                op.Current_Open_Follow_up__c = tsk.Id;
                //Added By Prabhat - 23 August 2019 as Part of User Story #317
                op.Current_Follow_Up_Time__c = tsk.ReminderDateTime;
                op.Current_Follow_Up_Type__c = ConstantsUtility.PREBOOKING_FOLLOWUP_TYPE+ '##' + System.Now();

                // Added By Anuj - 24 Oct 2019 as suggested by Rahul for DMS use.
                op.FollowUp_Owner_EMPCode__c = dealerEmployeeCode + '##' + System.Now();

                    update op;
                }
            }

            errorMessage = 'SUCCESS';
        }catch(DMLException ex){
            Database.rollback(sp);
            for(Integer i=0;i<ex.getNumDml();i++) { errorMessage += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryfollowUp'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryfollowUp', ex.getMessage(), 'EnquiryfollowUp', '', ehst);
        }

        return tsk.Id != Null ? tsk.Id : errorMessage;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           24-10-2019
@Discription:             Retrive Dealer Map Code from Logged In User ==> Contact.
@Date Of Modification :   24-10-2019
*/
    public static string retriveDealerEmployeeCode(){

        String dealerEmployeeCode = '';
        String currentUserID = UserInfo.getUserId();
        List<User> userList = [Select id, Dealer_Employee_Code__c from User where Id =: currentUserID];

        if(userList != Null && userList.size() > 0){
            string dealerEmpCode = userList[0].Dealer_Employee_Code__c;
            dealerEmployeeCode = (dealerEmpCode != Null && dealerEmpCode.split('_').size() > 1) ? dealerEmpCode.split('_')[1] : '';
        }

        return dealerEmployeeCode;
    }


    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             Method To Create Post FollowUp with Status as Open And Update the Pre Follow up with Status as
Completed And Submit the Enquiry record to approval if Stage is Request to lost.
@Date Of Modification :   22/July/2019
@Updated by:              Navin Soni
@Date Of Modification :   26/Sep/2020
@Updated Discription:     Method updated for Close Multiple open Task.
*/
    @AuraEnabled
    public static string updatePreOpenFollowUp(String enquiryId, String enquiryStage, string taskId, string remarkValue, string updateTaskData, string newTaskData, string recordTypeName){
        string errorMessage = '';
        Savepoint sp = Database.setSavepoint();

        Task tskNew = new Task();
        Task tskUpdate = new Task();
        List<Task> listOfMultipleOpenTask = new List<Task>();
        try{
        string taskRecordTypeId = '';
        String dealerEmployeeCode = retriveDealerEmployeeCode();

        if(recordTypeName != Null && recordTypeName != ''){
            Opportunity opp = (Opportunity)JSON.deserialize(updateTaskData, opportunity.class);
            opp.Id = enquiryId;

                tskUpdate = (Task)JSON.deserialize(updateTaskData, Task.class);

            system.debug('== Complete Info tskUpdate '+tskUpdate);

            tskUpdate.Id = taskId;
            tskUpdate.Description = remarkValue != Null ? remarkValue : Null;
            tskUpdate.Status = ConstantsUtility.STATUS_COMPLETED;
            tskUpdate.IsVisibleInSelfService = True;

            // Get all multipule Open task.
            listOfMultipleOpenTask = [SELECT Id, Description, Status, IsVisibleInSelfService, whatId FROM Task WHERE whatId =: enquiryId AND Status =: ConstantsUtility.STATUS_OPEN AND Id != :taskId];
            system.debug('@@## listOfMultipleOpenTask size '+listOfMultipleOpenTask.size());
            system.debug('@@## listOfMultipleOpenTask '+listOfMultipleOpenTask);
            if(listOfMultipleOpenTask != null && listOfMultipleOpenTask.size() > 0){
                For(Task objTask : listOfMultipleOpenTask){
                    objTask.Description = remarkValue != Null ? remarkValue : Null;
                    objTask.Status = ConstantsUtility.STATUS_COMPLETED;
                    objTask.IsVisibleInSelfService = True;
                    objTask.enquiry_scoring__c = 'P';
                }                
            }
            

            if(tskUpdate.Enquiry_Scoring__c != ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
                tskNew = (Task)JSON.deserialize(newTaskData, Task.class);
            }

                taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

                tskNew.Subject = recordTypeName;

                tskNew.whatId = enquiryId;
                List<Opportunity> ltNewOpp = new List<Opportunity>();

                if(isOpportunityAccessPermission()){
                    ltNewOpp = [select id,customer__r.personcontactId from Opportunity where id = :enquiryId limit 1];
                }
                if(ltNewOpp != null && ltNewOpp.size() > 0 && ltNewOpp[0].Customer__r.personcontactid != null){
                    tskNew.Enquiry_Customer__c = ltNewOpp[0].Customer__r.personcontactid;
                }
                tskNew.recordTypeId = taskRecordTypeId;
                tskNew.IsReminderSet = true;
                tskNew.ActivityDate = Date.valueOf(tskNew.ReminderDateTime);
                    Time myTime;
                if(tskNew.ReminderDateTime != Null){
                        myTime = Time.newInstance(tskNew.ReminderDateTime.hour(), tskNew.ReminderDateTime.minute(), tskNew.ReminderDateTime.second(), tskNew.ReminderDateTime.millisecond());
                }
                    tskNew.Time__c = myTime;
                tskNew.Status = ConstantsUtility.STATUS_OPEN;
                tskNew.IsVisibleInSelfService = true;

                if(tskUpdate.Enquiry_Scoring__c != ConstantsUtility.FIELD_VALUE_REQUESTTOLOST && isTaskCreatePermission()){
                    Insert tskNew;
                }
                system.debug('@@## Update access '+isTaskUpdatePermission());
                if(isTaskUpdatePermission()){
                    Update tskUpdate;
                    system.debug('@@## listOfMultipleOpenTask  '+listOfMultipleOpenTask);
                    if(listOfMultipleOpenTask != null && listOfMultipleOpenTask.size() > 0){
                        system.debug('@@## Update Done'); 
                        Update listOfMultipleOpenTask;
                    }
                }

            if(tskUpdate.Enquiry_Scoring__c != ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
                opp.Current_Open_Follow_up__c = tskNew.Id;
                //Added By Prabhat - 23 August 2019 as Part of User Story #317
                opp.Current_Follow_Up_Time__c = tskNew.ReminderDateTime;
                opp.Current_Follow_Up_Type__c = ConstantsUtility.PREBOOKING_FOLLOWUP_TYPE+ '##' + System.Now();
            }else if(tskUpdate.Enquiry_Scoring__c == ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
                opp.Current_Open_Follow_up__c = Null;
            }

                opp.Last_Follow_Up_Update_Time__c = system.Now();

                // Added By Anuj - 14 Oct 2019 as suggested by rajesh for DMS use.
                opp.Previous_Follow_Up_Type__c = tskUpdate.Type + '##' +system.Now();
                opp.Previous_Follow_Up_Time__c = system.Now();

                // Added By Anuj - 24 Oct 2019 as suggested by Rahul for DMS use.
                opp.FollowUp_Owner_EMPCode__c = dealerEmployeeCode + '##' + System.Now();

                // Added By Anuj - 03 Dec 2019 as suggested by Rahul for DMS use.
                opp.FollowUp_Last_Modified_Details__c = tskUpdate.Reason__c + '##' + tskUpdate.SubReason__c + '##' + enquiryStage + '##' + System.Now() + '##' + tskNew.Enquiry_Stage__c + '##' + tskUpdate.Enquiry_Stage__c + '##' + tskUpdate.Enquiry_Scoring__c + '##' + tskUpdate.Description;

                if(tskUpdate.Enquiry_Scoring__c == ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
                    // Added By Anuj - 02 Dec 2019 as request by rajesh to show the Lost reason on enquiry.
                    opp.Loss_Reason__c = tskUpdate.Reason__c;
                }

                //Adding to allow request to lost on inactive varinat @Rahul Sharma
                if(tskUpdate.Enquiry_Scoring__c == 'F')
                    opp.Is_Request_To_Lost__c= true;

                if(isOpportunityUpdatePermission()){
                    update opp;
                }

            if(tskUpdate.Enquiry_Scoring__c == ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(ConstantsUtility.APPROVAR_COMMENTS);
                    req.setObjectId(opp.id);
                    Approval.ProcessResult result = Approval.process(req);
                }
            }
            errorMessage = 'SUCCESS';
        }catch(DMLException ex){
            Database.rollback(sp);
            for(Integer i=0;i<ex.getNumDml();i++) { errorMessage += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryfollowUp'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryfollowUp', ex.getMessage(), 'EnquiryfollowUp', '', ehst);
        }

        if(errorMessage == 'SUCCESS' && tskUpdate.Enquiry_Scoring__c == ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
            errorMessage = 'RequestToLost';
        }else if(errorMessage == 'SUCCESS' && tskUpdate.Enquiry_Scoring__c != ConstantsUtility.FIELD_VALUE_REQUESTTOLOST){
            errorMessage = 'SUCCESS#'+tskNew.Id;
        }

        return errorMessage;
    }


    /*
@Author:                  Anuj Kumar
@Created Date :           17/July/2019
@Discription:             Method To Create Post FollowUp with Status as Open And Update the Pre Follow up with Status as
Completed And Submit the Enquiry record to approval if Stage is Postponed and Request to lost.
@Date Of Modification :   22/July/2019
*/
    @AuraEnabled
    public static string updatePostOpenFollowUp(String enquiryId, String enquiryStage, string taskId, string updateTaskData, string newTaskData, string recordTypeName){
        string errorMessage = '';
        List<Task> listOfMultipleOpenTask = new List<Task>();
        if(recordTypeName != Null && recordTypeName != ''){

            Opportunity opp = new Opportunity();
            opp.Id = enquiryId;
            opp.stageName = enquiryStage;

            Task tskUpdate = (Task)JSON.deserialize(updateTaskData, Task.class);
            tskUpdate.Id = taskId;
            tskUpdate.Status = ConstantsUtility.STATUS_COMPLETED;
            tskUpdate.IsVisibleInSelfService = true;

            // Get all multipule Open task.
            listOfMultipleOpenTask = [SELECT Id, Description, Status, IsVisibleInSelfService, whatId FROM Task WHERE whatId =: enquiryId AND Status =: ConstantsUtility.STATUS_OPEN AND Id != :taskId];
            system.debug('@@## listOfMultipleOpenTask size '+listOfMultipleOpenTask.size());
            system.debug('@@## listOfMultipleOpenTask '+listOfMultipleOpenTask);
            if(listOfMultipleOpenTask != null && listOfMultipleOpenTask.size() > 0){
                For(Task objTask : listOfMultipleOpenTask){
                    objTask.Description = tskUpdate.Description != Null ? tskUpdate.Description : Null;
                    objTask.Status = ConstantsUtility.STATUS_COMPLETED;
                    objTask.IsVisibleInSelfService = True;
                    objTask.enquiry_scoring__c = 'P';
                }                
            }
            
            Task tskNew = new Task();

            tskNew = (Task)JSON.deserialize(newTaskData, Task.class);
            errorMessage = generateTaskAndOpportunityData(tskNew, opp, recordTypeName, enquiryId, tskUpdate, listOfMultipleOpenTask);
        }

        return errorMessage;
    }

    public static String generateTaskAndOpportunityData(Task tskNew, Opportunity opp, String recordTypeName, String enquiryId, Task tskUpdate, List<Task> listOfMultipleOpenTask){
        Savepoint sp = Database.setSavepoint();
        string errorMessage = '';
        string taskRecordTypeId = '';

        try{

        String dealerEmployeeCode = retriveDealerEmployeeCode();

            taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

            tskNew.Subject = recordTypeName;

            tskNew.whatId = enquiryId;
            List<Opportunity> ltNewOpp = [select id,customer__r.personcontactId from Opportunity where id = :enquiryId limit 1];
            if (ltNewOpp != null && ltNewOpp.size() > 0 && ltNewOpp[0].Customer__r.personcontactid != null){
                tskNew.Enquiry_Customer__c = ltNewOpp[0].Customer__r.personcontactid;
            }
            tskNew.recordTypeId = taskRecordTypeId;
            tskNew.IsReminderSet = True;
            tskNew.ActivityDate = Date.valueOf(tskNew.ReminderDateTime);
                Time myTime = Time.newInstance(tskNew.ReminderDateTime.hour(), tskNew.ReminderDateTime.minute(), tskNew.ReminderDateTime.second(), tskNew.ReminderDateTime.millisecond());
                tskNew.Time__c = myTime;
            tskNew.Status = ConstantsUtility.STATUS_OPEN;
            tskNew.IsVisibleInSelfService = True;

            if(isTaskCreatePermission()){
                Insert tskNew;
            }
            // In Case of new Post booking follow up updating the previous Pre booking followup
            updateRemainingOpenTask(tskUpdate, recordTypeName, enquiryId);
            if(isTaskUpdatePermission()){
                Update tskUpdate;
                system.debug('@@## listOfMultipleOpenTask  '+listOfMultipleOpenTask);
                if(listOfMultipleOpenTask != null && listOfMultipleOpenTask.size() > 0){
                    system.debug('@@## Update Done'); 
                    Update listOfMultipleOpenTask;
                }
            }

        opp.Current_Open_Follow_up__c = tskNew.Id;
        //Added By Prabhat - 23 August 2019 as Part of User Story #317
        opp.Current_Follow_Up_Time__c = tskNew.ReminderDateTime;
        opp.Current_Follow_Up_Type__c = ConstantsUtility.PREBOOKING_FOLLOWUP_TYPE+ '##' + System.Now();

        // Added By Anuj - 14 Oct 2019 as suggested by rajesh for DMS use.
        opp.Previous_Follow_Up_Type__c = tskUpdate.Type + '##' +system.Now();
        opp.Previous_Follow_Up_Time__c = system.Now();

        // Added By Anuj - 24 Oct 2019 as suggested by Rahul for DMS use.
        opp.FollowUp_Owner_EMPCode__c = dealerEmployeeCode + '##' + System.Now();
         //Updating stage names to get sync to DMS successfully @Rahul Sharma/MSIL
        if(tskNew.Enquiry_Stage__c == 'Full amount received')
            tskNew.Enquiry_Stage__c = 'F';
        if(tskUpdate.Enquiry_Stage__c == 'Full amount received')
            tskUpdate.Enquiry_Stage__c = 'F';
        if(tskNew.Enquiry_Stage__c == 'Customer contact')
            tskNew.Enquiry_Stage__c = 'Z';
        if(tskUpdate.Enquiry_Stage__c == 'Customer contact')
            tskUpdate.Enquiry_Stage__c = 'Z';
        if(tskNew.Enquiry_Stage__c == 'Partial amount received')
            tskNew.Enquiry_Stage__c = 'P';
        if(tskUpdate.Enquiry_Stage__c == 'Partial amount received')
            tskUpdate.Enquiry_Stage__c = 'P';
        // Added By Anuj - 03 Dec 2019 as suggested by Rahul for DMS use.
        opp.FollowUp_Last_Modified_Details__c = tskUpdate.Reason__c + '##' + tskUpdate.SubReason__c + '##' + opp.stageName + '##' + System.Now() + '##' + tskNew.Enquiry_Stage__c + '##' + tskUpdate.Enquiry_Stage__c +'##' + tskUpdate.Enquiry_Scoring__c;

            opp.Last_Follow_Up_Update_Time__c = system.Now();
            if(isOpportunityUpdatePermission()){
                update opp;
            }
            errorMessage = 'SUCCESS';
        }catch(DMLException ex){
            Database.rollback(sp);
            for(Integer i=0;i<ex.getNumDml();i++) { errorMessage += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryfollowUp'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryfollowUp', ex.getMessage(), 'EnquiryfollowUp', '', ehst);
        }
            if(errorMessage == 'SUCCESS'){
                errorMessage = 'SUCCESS#'+tskNew.Id;
            }
        return errorMessage;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           31/07/2019
@Discription:             In Case of new Post booking follow up updating the previous Pre booking followup.
@Date Of Modification :   31/07/2019
*/
    public static Task updateRemainingOpenTask(Task oldTask, String newTaskRecTyName, string enquiryId){

        if(newTaskRecTyName == ConstantsUtility.POST_BOOKING_FOLLOWUP && isTaskAccessPermission() && isTaskUpdatePermission()){
            string taskPreBookingRCTyId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.PRE_BOOKING_FOLLOWUP).getRecordTypeId();
            string taskPostBookingRCTyId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.POST_BOOKING_FOLLOWUP ).getRecordTypeId();

            List<Task> taskList = new List<Task>([Select id, subject from Task
                                                  where id =: oldTask.Id AND recordTypeId = : taskPreBookingRCTyId
                                                  AND whatId =: enquiryId]);
            if(taskList != Null && taskList.size() > 0){
                oldTask.Enquiry_Scoring__c = ConstantsUtility.FIELD_VALUE_ORDERBOOKING;
            }

            List<Task> openPreBookingTaskList = new List<Task>();

            for(Task tsk : [Select id, Status from Task where whatId =: enquiryId AND recordTypeId = : taskPreBookingRCTyId
                            AND Status =: 'Open' AND id !=: oldTask.Id]){

                                tsk.status = ConstantsUtility.STATUS_COMPLETED;
                                tsk.Enquiry_Scoring__c = ConstantsUtility.FIELD_VALUE_ORDERBOOKING;
                                openPreBookingTaskList.add(tsk);
                            }
            if(openPreBookingTaskList != Null && openPreBookingTaskList.size() > 0){
                dataBase.update(openPreBookingTaskList, false);
            }
        }

        return oldTask;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           06-Nov-2019
@Discription:             Method To Create General FollowUp with Status as Open And Update the Previous General Follow up with Status as
Completed.
@Date Of Modification :   06-Nov-2019
*/
    @AuraEnabled
    public static string updateGeneralFollowUpInfo(String enquiryId, String enquiryStage, string taskId, string updateTaskData, string newTaskData, String recordTypeName){
        string errorMessage = '';
        if(enquiryId != Null && enquiryId != ''){

            Opportunity opp = new Opportunity();
            opp.Id = enquiryId;
            opp.stageName = enquiryStage;

            Task tskUpdate = (Task)JSON.deserialize(updateTaskData, Task.class);
            tskUpdate.Id = taskId;
            tskUpdate.Status = ConstantsUtility.STATUS_COMPLETED;
            tskUpdate.IsVisibleInSelfService = true;

            // Get all multipule Open task.
            List<Task> listOfMultipleOpenTask = [SELECT Id, Description, Status, IsVisibleInSelfService, whatId FROM Task WHERE whatId =: enquiryId AND Status =: ConstantsUtility.STATUS_OPEN AND Id != :taskId];
            system.debug('@@## listOfMultipleOpenTask size '+listOfMultipleOpenTask.size());
            system.debug('@@## listOfMultipleOpenTask '+listOfMultipleOpenTask);
            if(listOfMultipleOpenTask != null && listOfMultipleOpenTask.size() > 0){
                For(Task objTask : listOfMultipleOpenTask){
                    objTask.Description = tskUpdate.Description != Null ? tskUpdate.Description : Null;
                    objTask.Status = ConstantsUtility.STATUS_COMPLETED;
                    objTask.IsVisibleInSelfService = True;
                    objTask.enquiry_scoring__c = 'P';
                }                
            }
            
            Task tskNew = new Task();

            if(recordTypeName == ConstantsUtility.PARTS && tskUpdate.Reason__c != ConstantsUtility.PARTS_STATUS_LOST){
                tskNew = (Task)JSON.deserialize(newTaskData, Task.class);
            }else if(recordTypeName != ConstantsUtility.PARTS){
                tskNew = (Task)JSON.deserialize(newTaskData, Task.class);
            }
            errorMessage = generateGeneralTaskAndOpportunityData(tskNew, opp, recordTypeName, enquiryId, tskUpdate, listOfMultipleOpenTask);
        }

        return errorMessage;
    }

    public static String generateGeneralTaskAndOpportunityData(Task tskNew, Opportunity opp, String recordTypeName, String enquiryId, Task tskUpdate, List<Task> listOfMultipleOpenTask){
        Savepoint sp = Database.setSavepoint();
        string errorMessage = '';
        string taskRecordTypeId = '';
        try{
        String dealerEmployeeCode = retriveDealerEmployeeCode();
        taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        if(recordTypeName != ConstantsUtility.PARTS || (recordTypeName == ConstantsUtility.PARTS && tskUpdate.Enquiry_Scoring__c != ConstantsUtility.PARTS_STATUS_LOST)){

            tskNew.Subject = (recordTypeName == ConstantsUtility.PARTS) ? recordTypeName + ' Follow-up' : recordTypeName;

            tskNew.whatId = enquiryId;
            List<Opportunity> ltNewOpp = [select id,customer__r.personcontactId from Opportunity where id = :enquiryId limit 1];
            if(ltNewOpp != null && ltNewOpp.size() > 0 && ltNewOpp[0].Customer__r.personcontactid != null){
                tskNew.Enquiry_Customer__c = ltNewOpp[0].Customer__r.personcontactid;
            }
            tskNew.recordTypeId = taskRecordTypeId;
            tskNew.IsReminderSet = True;
            tskNew.ActivityDate = Date.valueOf(tskNew.ReminderDateTime);
            if(tskNew.ReminderDateTime != null){
                Time myTime = Time.newInstance(tskNew.ReminderDateTime.hour(), tskNew.ReminderDateTime.minute(), tskNew.ReminderDateTime.second(), tskNew.ReminderDateTime.millisecond());
                tskNew.Time__c = myTime;
            }
            tskNew.Status = ConstantsUtility.STATUS_OPEN;
            tskNew.IsVisibleInSelfService = True;


            Insert tskNew;

            opp.Current_Open_Follow_up__c = tskNew.Id;
            opp.Current_Follow_Up_Time__c = tskNew.ReminderDateTime;
            opp.Current_Follow_Up_Type__c = recordTypeName+ '##' + System.Now();

        }else if(recordTypeName == ConstantsUtility.PARTS && tskUpdate.Enquiry_Scoring__c == ConstantsUtility.PARTS_STATUS_LOST){

            opp.Current_Open_Follow_up__c = Null;
            opp.Parts_Enquiry_Scoring__c = tskUpdate.Enquiry_Scoring__c;
            opp.Parts_Reason__c = tskUpdate.Reason__c;
            opp.StageName = ConstantsUtility.STAGE_CLOSELOST;
        }

        if(isTaskUpdatePermission()){
                Update tskUpdate;
                system.debug('@@## listOfMultipleOpenTask  '+listOfMultipleOpenTask);
                if(listOfMultipleOpenTask != null && listOfMultipleOpenTask.size() > 0){
                    system.debug('@@## Update Done'); 
                    Update listOfMultipleOpenTask;
                }
            }

        List<Task> taskList = [Select id, ownerId from task where Id =: tskUpdate.Id];
        String taskUpdateOwnerId = !taskList.isEmpty() ? taskList[0].ownerId : '';

        // Added By Anuj - 14 Oct 2019 as suggested by rajesh for DMS use.
        opp.Previous_Follow_Up_Type__c = tskUpdate.Type + '##' +system.Now();
        opp.Previous_Follow_Up_Time__c = system.Now();

        // Added By Anuj - 24 Oct 2019 as suggested by Rahul for DMS use.
        opp.FollowUp_Owner_EMPCode__c = dealerEmployeeCode + '##' + System.Now();

        // Added By Anuj - 03 Dec 2019 as suggested by Rahul for DMS use.
        opp.FollowUp_Last_Modified_Details__c = tskUpdate.Reason__c + '##' + tskUpdate.SubReason__c + '##' + opp.stageName + '##' + System.Now() + '##' + tskNew.Enquiry_Stage__c + '##' + tskUpdate.Enquiry_Stage__c +'##' + tskUpdate.Enquiry_Scoring__c + '##' + tskUpdate.Description;

        if(recordTypeName == ConstantsUtility.PARTS){
            opp.FollowUp_Last_Modified_Details__c += '##'+ taskUpdateOwnerId + '##' + tskUpdate.Type + '##' + tskNew.Type;
        }

            opp.Last_Follow_Up_Update_Time__c = system.Now();
            if(isOpportunityUpdatePermission()){
                update opp;
            }

            errorMessage = 'SUCCESS';
        }catch(DMLException ex){
            Database.rollback(sp);
            for(Integer i=0;i<ex.getNumDml();i++) { errorMessage += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryfollowUp'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryfollowUp', ex.getMessage(), 'EnquiryfollowUp', '', ehst);
        }

        if(recordTypeName == ConstantsUtility.PARTS && errorMessage == 'SUCCESS' && tskUpdate.Enquiry_Scoring__c == ConstantsUtility.PARTS_STATUS_LOST){
            errorMessage = 'RequestToLost';
        }else if(errorMessage == 'SUCCESS' && (recordTypeName != ConstantsUtility.PARTS || (recordTypeName == ConstantsUtility.PARTS && tskUpdate.Enquiry_Scoring__c != ConstantsUtility.PARTS_STATUS_LOST))){
            errorMessage = 'SUCCESS#'+tskNew.Id;
        }
        return errorMessage;
    }

    /*
@Author:                 Gitika Khandelwal
@Created Date :           17-04-2020
@Discription:             Method To Fetch Current Open Loyalty Task Details.
@Date Of Modification :   17-04-2020
*/
    @AuraEnabled(cacheable=true)
    public static LoyaltyTaskInfo retriveLoyaltyFollowUpDetail(String enquiryId, String taskId){

        LoyaltyTaskInfo Loyalty = new LoyaltyTaskInfo();
        List<Task> taskList = new List<Task>();
        if(taskId == Null){
            taskList = [Select id, ActivityDate, Subject, Type, Enquiry_Stage__c, IsReminderSet, ReminderDateTime from Task Where
                                whatId =: enquiryId And status =: ConstantsUtility.STATUS_OPEN AND first_followup__c = True Limit 1 ];
                if(taskList != Null && taskList.size() > 0){
                    Loyalty.tsk = taskList[0];
                }
        }
        if(enquiryId != Null && enquiryId != ''){
            if(taskId != Null){
                taskList = [Select id, ActivityDate,Subject,Type, Enquiry_Stage__c, IsReminderSet,
                                                      ReminderDateTime from Task Where
                                                      whatid =: enquiryId  And
                                                      status =: ConstantsUtility.STATUS_OPEN Limit 1];
                if(taskList != Null && taskList.size() > 0){
                    Loyalty.tsk = taskList[0];
                }
            }

            List<String> LoyaltyActionAvaialbleList = (SYSTEM.label.General_Follow_up_Type_Field != null &&
                                                       SYSTEM.label.General_Follow_up_Type_Field != '' ) ?
                (SYSTEM.label.General_Follow_up_Type_Field).split(';') :  Null;

            // FOR GENERAL FOLLOW UP TYPE FIELD
            Schema.DescribeFieldResult taskTypeResult = Task.Type.getDescribe();
            List<Schema.PicklistEntry> taskTypeResultEntry = taskTypeResult.getPicklistValues();

            List<GeneralAction> LoyaltyActionList = new List<GeneralAction>();
            for( Schema.PicklistEntry field : taskTypeResultEntry){

                GeneralAction action = new GeneralAction();
                action.label = field.getLabel();
                action.value = field.getValue();
                if(LoyaltyActionAvaialbleList.contains(field.getValue())){
                    LoyaltyActionList.add(action);
                }
            }

            Loyalty.LoyaltyActionList = LoyaltyActionList;

            // FOR Next Action FIELD
            Schema.DescribeFieldResult taskNextstepResult = Task.Next_Steps__c.getDescribe();
            List<Schema.PicklistEntry> taskNextstepResultEntry = taskNextstepResult.getPicklistValues();

            List<GeneralAction> LoyaltyNextActionList = new List<GeneralAction>();
            for( Schema.PicklistEntry field : taskNextstepResultEntry){

                GeneralAction action = new GeneralAction();
                action.label = field.getLabel();
                action.value = field.getValue();
                LoyaltyNextActionList.add(action);

            }

            Loyalty.LoyaltyNextActionList = LoyaltyNextActionList;

            Schema.DescribeFieldResult taskInterestedinLoyaltyResult = Task.Interested_in_Loyalty__c.getDescribe();
            List<Schema.PicklistEntry> taskInterestedinLoyaltyResultEntry = taskInterestedinLoyaltyResult.getPicklistValues();

            List<GeneralAction> LoyaltyInterstedInLoyalityList = new List<GeneralAction>();
            for( Schema.PicklistEntry field : taskInterestedinLoyaltyResultEntry){

                GeneralAction action = new GeneralAction();
                action.label = field.getLabel();
                action.value = field.getValue();
                LoyaltyInterstedInLoyalityList.add(action);
            }

            Loyalty.LoyaltyInterstedInLoyalityList = LoyaltyInterstedInLoyalityList;

            Schema.sObjectType objType = Task.getSObjectType();
            Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
            Schema.SObjectField theField = objFieldMap.get('Reason_not_Interested_in_Loyalty__c');
            Schema.SObjectField ctrlField = objFieldMap.get('Interested_in_Loyalty__c');

            List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
            List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
            List<String> controllingValues = new List<String>();

            for (Schema.PicklistEntry pled : contrEntries) {
                String label = pled.getLabel();
                Loyalty.objInsertedInLoyalitywithReason.put(label, new List<GeneralAction>());
                controllingValues.add(label);
            }

            for (PicklistEntryWrapper plew : depEntries) {
                GeneralAction action = new GeneralAction();
                action.label = plew.label;
                action.value = plew.value;
                String validForBits = base64ToBits(plew.validFor);
                for (Integer i = 0; i < validForBits.length(); i++) {
                    String bit = validForBits.mid(i, 1);
                    if (bit == '1') {
                        Loyalty.objInsertedInLoyalitywithReason.get(controllingValues.get(i)).add(action);
                    }
                }
            }
        }
        return  Loyalty;
    }
      /*
@Author:                 Gitika Khandelwal
@Created Date :           17-04-2020
@Discription:             Method To update Current Open and new Loyalty Task Details.
@Date Of Modification :   17-04-2020
*/
     @AuraEnabled
    public static string updateLoyaltyFollowUpInfo(String enquiryId, String email,string taskId, string updateTaskData, string newTaskData, String recordTypeName){
        string errorMessage = 'SUCCESS';
        if(enquiryId != Null && enquiryId != ''){

            Opportunity opp = new Opportunity();
            opp.Id = enquiryId;
            opp.Email__c = email;
            system.debug('email'+email);
            Task tskUpdate = (Task)JSON.deserialize(updateTaskData, Task.class);

            Task tskNew = (Task)JSON.deserialize(newTaskData, Task.class);

            errorMessage = generateLoyaltyTaskAndOpportunityData(tskNew, opp, recordTypeName, enquiryId, tskUpdate,taskId);

        }
        return errorMessage;
    }
       /*
    @Author:                 Gitika Khandelwal
    @Created Date :           17-04-2020
    @Discription:             helper method used by method updateLoyaltyFollowUpInfo.
    @Date Of Modification :   17-04-2020
    */
  public static String generateLoyaltyTaskAndOpportunityData(Task tskNew, Opportunity opp, String recordTypeName,
                                                                String enquiryId, Task tskUpdate,string taskId){
        Savepoint sp = Database.setSavepoint();
        string errorMessage = '';
        string taskRecordTypeId = '';

       try{
            //String dealerEmployeeCode = retriveDealerEmployeeCode();

           if(string.isNotBlank(tskNew.Next_Steps__c)){
               taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

               List<Opportunity> ltNewOpp = [select id,customer__r.personcontactId,customer__r.Name from Opportunity where id = :enquiryId limit 1];

               if(ltNewOpp != null && ltNewOpp.size() > 0 && ltNewOpp[0].Customer__r.personcontactid != null){
                   tskNew.Enquiry_Customer__c = ltNewOpp[0].Customer__r.personcontactid;
                   tskNew.Subject = recordTypeName;
                   tskNew.whatId = enquiryId;
               }

               tskNew.recordTypeId = taskRecordTypeId;
               tskNew.IsReminderSet = True;
               tskNew.ActivityDate = Date.valueOf(tskNew.ReminderDateTime);
               Time myTime = Time.newInstance(tskNew.ReminderDateTime.hour(), tskNew.ReminderDateTime.minute(), tskNew.ReminderDateTime.second(), tskNew.ReminderDateTime.millisecond());
               tskNew.Time__c = myTime;
               tskNew.Status = ConstantsUtility.STATUS_OPEN;
               tskNew.IsVisibleInSelfService = True;

               if(isTaskCreatePermission()){
                   Insert tskNew;
                   opp.Current_Open_Follow_up__c = tskNew.Id;
                   opp.Current_Follow_Up_Time__c = tskNew.ReminderDateTime;
                   opp.Current_Follow_Up_Type__c = recordTypeName+ '##' + System.Now();
               }
           }
          if(isTaskUpdatePermission()){
               tskUpdate.Id = taskId;
               tskUpdate.Status = ConstantsUtility.STATUS_COMPLETED;
               tskUpdate.IsVisibleInSelfService = true;
               Update tskUpdate;
           }


        // Added By Anuj - 14 Oct 2019 as suggested by rajesh for DMS use.
        opp.Previous_Follow_Up_Type__c = tskUpdate.Type + '##' +system.Now();
        opp.Previous_Follow_Up_Time__c = system.Now();

        // Added By Anuj - 24 Oct 2019 as suggested by Rahul for DMS use.
       // opp.FollowUp_Owner_EMPCode__c = dealerEmployeeCode + '##' + System.Now();

        // Added By Anuj - 03 Dec 2019 as suggested by Rahul for DMS use.
       // opp.FollowUp_Last_Modified_Details__c = tskUpdate.Reason__c + '##' + tskUpdate.SubReason__c + '##' + opp.stageName + '##' + System.Now() + '##' + tskNew.Enquiry_Stage__c + '##' + tskUpdate.Enquiry_Stage__c +'##' + tskUpdate.Enquiry_Scoring__c;

          opp.Last_Follow_Up_Update_Time__c = system.Now();

          if(string.isNotBlank(tskUpdate.Reason_not_Interested_in_Loyalty__c) && ConstantsUtility.NOT_INTERESTED_IN_LOYALTY.contains(tskUpdate.Reason_not_Interested_in_Loyalty__c))
          opp.StageName=ConstantsUtility.Enrollment_Unsuccessful;

            if(isOpportunityUpdatePermission()){
                update opp;
            }

          return 'SUCCESS#'+tskNew.Id;

        }catch(DMLException ex){
            Database.rollback(sp);
            for(Integer i=0;i<ex.getNumDml();i++) { errorMessage += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryfollowUp'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryfollowUp', ex.getMessage(), 'EnquiryfollowUp', '', ehst);

            return errorMessage;

        }

    }

        /*
    @Author:                  Anuj Kumar
    @Created Date :           17/July/2019
    @Discription:             Wrapper class used to return the Enquiry Approval Status and Task Details.
    @Date Of Modification :   22/July/2019
    */
        public class EnquiryInfo{

        @AuraEnabled public string approvalStatus;
        @AuraEnabled public Task tsk;
        @AuraEnabled public List<PreBookingTaskType> preBookingTaskTypeList;
        @AuraEnabled public List<PostBookingTaskType> postBookingTaskTypeList;
    }

    Public Class PreBookingTaskType {
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    Public Class PostBookingTaskType {
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           06-Nov-2019
@Discription:             Wrapper class used to return the genrakl Task Details.
@Date Of Modification :   06-Nov-2019
*/
    public class GeneralTaskInfo{

        @AuraEnabled public Task tsk;
        @AuraEnabled public List<GeneralStatus> generalStatusList;
        @AuraEnabled public List<PartStatus> partStatusList;
        @AuraEnabled public List<GeneralAction> generalActionList;
        @AuraEnabled public List<GeneralEnquiryStage> generalEnquiryStageList;
    }

    Public class PartStatus{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    Public class GeneralStatus{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    Public class GeneralAction{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    Public class GeneralEnquiryStage{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }


    /*
@Author:                  Gitika Khandelwal
@Created Date :           17-April-2020
@Discription:             Wrapper class used to return the Loyalty Task Details.
@Date Of Modification :   17-April-2020
*/
    public class LoyaltyTaskInfo{

        @AuraEnabled public Task tsk;
        @AuraEnabled public List<GeneralAction> LoyaltyNextActionList;
        @AuraEnabled public List<GeneralAction> LoyaltyActionList;
        @AuraEnabled public List<GeneralAction> LoyaltyInterstedInLoyalityList;
        @AuraEnabled public Map<String,List<GeneralAction>> objInsertedInLoyalitywithReason = new Map<String,List<GeneralAction>>();
    }

   public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }

    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';


    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){
        }
    }




    /*******       TO Handle The Object And Field Permissions    ********/

    /*
@Author:                  Anuj Kumar
@Created Date :           30/07/2019
@Discription:             To Check the access permissions for task.
@Date Of Modification :   30/07/2019
*/
    public static Boolean isTaskAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Task', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible, 'ActivityDate') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible, 'Type') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible, 'Enquiry_Stage__c') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible, 'IsReminderSet') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible, 'ReminderDateTime') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible, 'status') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsAccessible,'subject'))
        {
            return True;
        }else{
            return false;
        }
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           30/07/2019
@Discription:             To Check the create permissions for ProcessInstanceWorkitem.
@Date Of Modification :   30/07/2019
*/
    public static Boolean isProcessInstanceAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('ProcessInstanceWorkitem', ConstantsUtility.IsAccessible)){
            return True;
        }else{
            return false;
        }
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           30/07/2019
@Discription:             To Check the create permissions for ProcessInstanceWorkitem.
@Date Of Modification :   30/07/2019
*/
    public static Boolean isOpportunityAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Opportunity', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.objectCURDPermission('Account', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'Customer__c')){
               return True;
           }else{
               return false;
           }
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           30/07/2019
@Discription:             To Check the update permissions for opportunity.
@Date Of Modification :   30/07/2019
*/
    public static Boolean isOpportunityUpdatePermission(){
        if(CheckObjectAndField.objectCURDPermission('opportunity', ConstantsUtility.IsUpdateable) &&
           CheckObjectAndField.fieldCURDPermission('opportunity', ConstantsUtility.IsUpdateable, 'Current_Open_Follow_up__c') &&
           CheckObjectAndField.fieldCURDPermission('opportunity', ConstantsUtility.IsUpdateable, 'Last_Follow_Up_Update_Time__c'))
        {
            return True;
        }else{
            return false;
        }
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           30/07/2019
@Discription:             To Check the create permissions for task.
@Date Of Modification :   30/07/2019
*/
    public static Boolean isTaskCreatePermission(){
        if(CheckObjectAndField.objectCURDPermission('Task', ConstantsUtility.IsCreateable) &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'ActivityDate') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'Type') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'Enquiry_Stage__c') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'IsReminderSet') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'ReminderDateTime') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'status') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsCreateable, 'Subject'))
        {
            return True;
        }else{
            return false;
        }
    }

    /*
@Author:                  Anuj Kumar
@Created Date :           30/07/2019
@Discription:             To Check the update permissions for task.
@Date Of Modification :   30/07/2019
*/
    public static Boolean isTaskUpdatePermission(){
        if(CheckObjectAndField.objectCURDPermission('Task', ConstantsUtility.IsUpdateable) &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsUpdateable, 'Status') &&
           CheckObjectAndField.fieldCURDPermission('Task', ConstantsUtility.IsUpdateable, 'Description'))
        {
            return True;
        }else{
            return false;
        }
    }

    /*
    @Author:                  Saloni Gupta
    @Created Date :           05-June-2020
    @Discription:             Method To Create MSDDS FollowUp with Status as Open And Update the Previous MSDS Follow up with Status as Completed.
    @Date Of Modification :
    */
    @AuraEnabled
    public static string updateMSDSFollowUpInfo(String enquiryId, String enquiryStage, string taskId, string updateTaskData, string newTaskData, String recordTypeName){
        string errorMessage = '';
        if(enquiryId != Null && enquiryId != ''){

            Opportunity opp = new Opportunity();
            opp.Id = enquiryId;
            opp.stageName = enquiryStage;

            Task tskUpdate = (Task)JSON.deserialize(updateTaskData, Task.class);
            tskUpdate.Id = taskId;
            tskUpdate.Status = ConstantsUtility.STATUS_COMPLETED;
            tskUpdate.IsVisibleInSelfService = true;
            tskUpdate.First_FollowUp__c = false;

            Task tskNew = new Task();
            if (tskUpdate.MSDS_Enquiry_Status__c != ConstantsUtility.STATUS_LOST) {
                tskNew = (Task)JSON.deserialize(newTaskData, Task.class);
            }
            errorMessage = generateMSDSTaskAndOpportunityData(tskNew, opp, recordTypeName, enquiryId, tskUpdate);
        }

        return errorMessage;
    }
    public static String generateMSDSTaskAndOpportunityData(Task tskNew, Opportunity opp, String recordTypeName, String enquiryId, Task tskUpdate){
        Savepoint sp = Database.setSavepoint();
        string errorMessage = '';
        string taskRecordTypeId = '';
        try{
            String dealerEmployeeCode = retriveDealerEmployeeCode();
            taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            if (tskUpdate.MSDS_Enquiry_Status__c != ConstantsUtility.STATUS_LOST) {
                tskNew.Subject = recordTypeName;

                tskNew.whatId = enquiryId;
                List<Opportunity> ltNewOpp = [select id,customer__r.personcontactId from Opportunity where id = :enquiryId limit 1];
                if(ltNewOpp != null && ltNewOpp.size() > 0 && ltNewOpp[0].Customer__r.personcontactid != null){
                    tskNew.Enquiry_Customer__c = ltNewOpp[0].Customer__r.personcontactid;
                }
                tskNew.recordTypeId = taskRecordTypeId;
                tskNew.IsReminderSet = True;
                tskNew.ActivityDate = Date.valueOf(tskNew.ReminderDateTime);
                Time myTime = Time.newInstance(tskNew.ReminderDateTime.hour(), tskNew.ReminderDateTime.minute(), tskNew.ReminderDateTime.second(), tskNew.ReminderDateTime.millisecond());
                tskNew.Time__c = myTime;

                tskNew.Status = ConstantsUtility.STATUS_OPEN;
                tskNew.IsVisibleInSelfService = True;

                if(isTaskCreatePermission()){
                    Insert tskNew;
                }

                opp.Current_Open_Follow_up__c = tskNew.Id;
                opp.Current_Follow_Up_Time__c = tskNew.ReminderDateTime;
                opp.Current_Follow_Up_Enquiry_Action__c  = tskNew.MSDS_Enquiry_Stage__c;
                opp.Current_Follow_Up_Type__c = tskNew.Type + '##' + ConstantsUtility.MSDS_FOLLOW_UP_TASK_REC_TYPE+ '##' + System.Now();
                //opp.Current_Follow_Up_Type__c = ConstantsUtility.MSDS_FOLLOW_UP_TASK_REC_TYPE+ '##' + System.Now();
            }
            else if(tskUpdate.MSDS_Enquiry_Status__c == ConstantsUtility.STATUS_LOST){
                opp.Current_Open_Follow_up__c = Null;
                opp.Loss_Reason__c = tskUpdate.Reason__c;
                opp.StageName = ConstantsUtility.STAGE_CLOSELOST;
            }

            if(isTaskUpdatePermission()){
                Update tskUpdate;
            }

            opp.Current_Follow_Up_Enquiry_Status__c = tskUpdate.MSDS_Enquiry_Status__c;
            opp.Previous_Follow_Up_Type__c = tskUpdate.Type + '##' +system.Now();
            opp.Previous_Follow_Up_Time__c = system.Now();
            opp.FollowUp_Owner_EMPCode__c = dealerEmployeeCode + '##' + System.Now();
            opp.FollowUp_Last_Modified_Details__c = tskUpdate.Reason__c + '##' + tskUpdate.SubReason__c + '##' + opp.stageName + '##' + System.Now() + '##' + tskNew.MSDS_Enquiry_Stage__c + '##' + tskUpdate.MSDS_Enquiry_Stage__c +'##' + tskUpdate.MSDS_Enquiry_Status__c + '##' + tskUpdate.Description;

            opp.Last_Follow_Up_Update_Time__c = system.Now();
            if(isOpportunityUpdatePermission()){
                update opp;
            }

            errorMessage = 'SUCCESS';
        }catch(DMLException ex){
            Database.rollback(sp);
            for(Integer i=0;i<ex.getNumDml();i++) { errorMessage += ex.getDmlMessage(i); }
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryfollowUp'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryfollowUp', ex.getMessage(), 'EnquiryfollowUp', '', ehst);
        }

        if(errorMessage == 'SUCCESS' && tskUpdate.MSDS_Enquiry_Status__c == ConstantsUtility.STATUS_LOST){
            errorMessage = 'RequestToLost';
        }else if(errorMessage == 'SUCCESS' && tskUpdate.MSDS_Enquiry_Status__c != ConstantsUtility.STATUS_LOST){
            errorMessage = 'SUCCESS#'+tskNew.Id;
        }
        return errorMessage;
    }

    /*
    @Author:                  Saloni Gupta
    @Created Date :           04-June-2020
    @Discription:             Method To Fetch Current Open MSDS Task Details -R1.2
    @Date Of Modification :
    */

     @AuraEnabled(cacheable=true)
    public static GeneralTaskInfo retriveMSDSFollowUpDetail(String enquiryId, String taskId){

        GeneralTaskInfo general = new GeneralTaskInfo();

        List<Task> taskList = new List<Task>();
        if(taskId == Null){
            taskList = [Select id, ActivityDate, Subject, Type, Enquiry_Stage__c, IsReminderSet, ReminderDateTime from Task Where
                                whatId =: enquiryId And status =: ConstantsUtility.STATUS_OPEN AND first_followup__c = True Limit 1 ];
                if(taskList != Null && taskList.size() > 0){
                    general.tsk = taskList[0];
                }
        }

        if(enquiryId != Null && enquiryId != ''){
             if(taskId != Null){
                taskList = [Select Id, ActivityDate, Type, Enquiry_Stage__c, IsReminderSet,
                                                    ReminderDateTime, MSDS_Enquiry_Stage__c, MSDS_Enquiry_Status__c from Task Where
                                                    Id =: taskId AND
                                                    whatId =: enquiryId And status =: ConstantsUtility.STATUS_OPEN Limit 1];
                if(taskList != Null && taskList.size() > 0){
                    general.tsk = taskList[0];
                }
            }

            system.debug('taskList@@@2'+ general.tsk);
            system.debug('taskList@@@2222'+ taskList);
            List<String> msdsStatusAvaialbleList = (SYSTEM.label.MSDS_Follow_up_Status_Field != null &&
                                                       SYSTEM.label.MSDS_Follow_up_Status_Field != '' ) ?
                (SYSTEM.label.MSDS_Follow_up_Status_Field).split(';') :
            Null;
            List<String> msdsActionAvaialbleList = (SYSTEM.label.MSDS_Follow_up_Type_Field != null &&
                                                       SYSTEM.label.MSDS_Follow_up_Type_Field != '' ) ?
                (SYSTEM.label.MSDS_Follow_up_Type_Field).split(';') :
            Null;

            /* List<String> msdsEnqStageAvaialbleList = (SYSTEM.label.MSDS_Follow_up_Stage_Field != null &&
                                                     SYSTEM.label.MSDS_Follow_up_Stage_Field != '' ) ?
                (SYSTEM.label.MSDS_Follow_up_Stage_Field).split(';') :
            Null; */
               // System.debug('msdsEnqStageAvaialbleList----'+msdsEnqStageAvaialbleList);


            // FOR MSDS FOLLOW UP STATUS FIELD
            //Schema.DescribeFieldResult oppEnqScoResult = Opportunity.Enquiry_Scoring__c.getDescribe();
            Schema.DescribeFieldResult oppEnqScoResult = Opportunity.Current_Follow_Up_Enquiry_Status__c.getDescribe();
            List<Schema.PicklistEntry> oppEnqScoResultEntry = oppEnqScoResult.getPicklistValues();

            List<GeneralStatus> msdsStatusList = new List<GeneralStatus>();
            for( Schema.PicklistEntry field : oppEnqScoResultEntry){

                GeneralStatus status = new GeneralStatus();
                status.label = field.getLabel();
                status.value = field.getValue();
                if(msdsStatusAvaialbleList.contains(field.getValue())){
                    msdsStatusList.add(status);
                }
            }

            // FOR MSDS FOLLOW UP TYPE FIELD
            Schema.DescribeFieldResult taskTypeResult = Task.Type.getDescribe();
            List<Schema.PicklistEntry> taskTypeResultEntry = taskTypeResult.getPicklistValues();

            List<GeneralAction> msdsActionList = new List<GeneralAction>();
            for( Schema.PicklistEntry field : taskTypeResultEntry){

                GeneralAction action = new GeneralAction();
                action.label = field.getLabel();
                action.value = field.getValue();
                if(msdsActionAvaialbleList.contains(field.getValue())){
                    msdsActionList.add(action);
                }
            }

            // FOR MSDS FOLLOW UP STAGE FIELD
            //Schema.DescribeFieldResult oppStageResult = Opportunity.Enquiry_Stage__c.getDescribe();
            Schema.DescribeFieldResult oppStageResult = Opportunity.Current_Follow_Up_Enquiry_Action__c.getDescribe();
            List<Schema.PicklistEntry> oppStageResultEntry = oppStageResult.getPicklistValues();

            List<GeneralEnquiryStage> msdsEnquiryStageList = new List<GeneralEnquiryStage>();
            for( Schema.PicklistEntry field : oppStageResultEntry){

                GeneralEnquiryStage stage = new GeneralEnquiryStage();
                stage.label = field.getLabel();
                stage.value = field.getValue();
                //if(msdsEnqStageAvaialbleList.contains(field.getValue())){
                    msdsEnquiryStageList.add(stage);
                //}
                System.debug('msdsEnquiryStageList----'+msdsEnquiryStageList);
            }

            general.generalStatusList = msdsStatusList;
            general.generalActionList = msdsActionList;
            general.generalEnquiryStageList = msdsEnquiryStageList;
        }


        return  general;
    }

}