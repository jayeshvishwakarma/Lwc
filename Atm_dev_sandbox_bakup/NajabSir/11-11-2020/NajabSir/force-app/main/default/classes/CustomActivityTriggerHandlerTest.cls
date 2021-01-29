@IsTest
public class CustomActivityTriggerHandlerTest {
    static testMethod void method1() {
        
        Implementation_Strategy__c impObj = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert impObj;
        
        Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        list<case> caseList = TestDataFactory.createCase(8,complaintRecordTypeId);
        caseList[0].Channel__c = 'Arena';
        caseList[0].Job_Type__c = 'Breakdown';
        caseList[0].MOS_Case_Stage__c = 'Pending for Allocation';
        caseList[0].MOS_Case_Source__c = 'M-Call';
        
        caseList[1].Channel__c = 'Arena';
        caseList[1].Job_Type__c = ConstantsUtility.JOB_TYPE_Accidental;
        caseList[1].MOS_Case_Stage__c = ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation;
        caseList[1].MOS_Case_Source__c = 'M-Call';
        
        caseList[2].Channel__c = 'Arena';
        caseList[2].Job_Type__c = 'Breakdown';
        caseList[2].MOS_Case_Stage__c = ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation;
        caseList[2].MOS_Case_Source__c = 'Salesforce';
        
        caseList[3].Channel__c = 'Arena';
        caseList[3].Job_Type__c = ConstantsUtility.JOB_TYPE_Accidental;
        caseList[3].MOS_Case_Stage__c = ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation;
        caseList[3].MOS_Case_Source__c = 'Nexa';
        
        caseList[4].Channel__c = 'Arena';
        caseList[4].Job_Type__c = ConstantsUtility.JOB_TYPE_Accidental;
        caseList[4].MOS_Case_Stage__c = 'Out for Service';
        caseList[4].MOS_Case_Source__c = 'Nexa';
        
        caseList[5].Channel__c = 'Arena';
        caseList[5].Job_Type__c = 'Breakdown';
        caseList[5].MOS_Case_Stage__c = 'Towing Required';
        caseList[5].MOS_Case_Source__c = 'Salesforce';
        
        caseList[6].Channel__c = 'Arena';
        caseList[6].Job_Type__c = 'Breakdown';
        caseList[6].MOS_Case_Stage__c = 'Towing Required';
        caseList[6].MOS_Case_Source__c = 'M-Call';
        
        caseList[7].Channel__c = 'Arena';
        caseList[7].Job_Type__c = ConstantsUtility.JOB_TYPE_Accidental;
        caseList[7].MOS_Case_Stage__c = 'Out for Service';
        caseList[7].MOS_Case_Source__c = 'M-Call';
        
        insert caseList;  
        
        
        list<Custom_Activity__c> customTaskList = testDataFactory.createCustomTask(9);
        customTaskList[0].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[0].Case__c = caseList[0].id;
        customTaskList[0].Send_SMS__c = 'Yes';
        customTaskList[0].Mobile__c = '9878765643';
        
        customTaskList[1].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[1].Case__c = caseList[1].id;
        customTaskList[1].Send_SMS__c = 'Yes';
        customTaskList[1].Mobile__c = '9878765643';
        
        customTaskList[2].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[2].Case__c = caseList[2].id;
        customTaskList[2].Send_SMS__c = 'Yes';
        customTaskList[2].Mobile__c = '9878765643';
        
        customTaskList[3].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[3].Case__c = caseList[3].id;
        customTaskList[3].Send_SMS__c = 'Yes';
        customTaskList[3].Mobile__c = '9878765643';
        
        customTaskList[4].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[4].Case__c = caseList[4].id;
        customTaskList[4].Send_SMS__c = 'Yes';
        customTaskList[4].Mobile__c = '9878765643';
        
        customTaskList[5].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[5].Case__c = caseList[5].id;
        customTaskList[5].Send_SMS__c = 'Yes';
        customTaskList[5].Mobile__c = '9878765643';
        
        customTaskList[6].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[6].Case__c = caseList[6].id;
        customTaskList[6].Send_SMS__c = 'Yes';
        customTaskList[6].Mobile__c = '9878765643';
        
        customTaskList[7].RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
        customTaskList[7].Case__c = caseList[7].id;
        customTaskList[7].Send_SMS__c = 'Yes';
        customTaskList[7].Mobile__c = '9878765643';
            
        customTaskList[8].RecordTypeId = ConstantsUtility.CustomActivityMOSTaskRecordTypeId;
        customTaskList[8].Case__c = caseList[0].id;
        customTaskList[8].Send_SMS__c = 'Yes';
        customTaskList[8].Mobile__c = '9878765643';
        
        insert customTaskList;
        
        List<Task> listTask = TestDataFactory.createTaskMOS(1,'MOS Follow-Ups');
        listTask[0].Status = ConstantsUtility.MOS_TASK_Status_Open;
        listTask[0].Custom_Activity__c = customTaskList[0].Id;
        insert listTask; 
        
        //customTaskList[0].RecordTypeId = ConstantsUtility.CustomActivityMOSTaskRecordTypeId;
        customTaskList[0].Status__c = ConstantsUtility.MOS_Task_Status_Completed;
        customTaskList[8].Status__c = ConstantsUtility.MOS_Task_Status_Completed;
        update customTaskList;
    }
    
    
}