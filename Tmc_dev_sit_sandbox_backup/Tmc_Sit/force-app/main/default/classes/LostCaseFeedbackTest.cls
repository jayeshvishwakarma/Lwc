/**
 * @File Name          : LostCaseFeedbackTest.cls
 * @Description        : It is utilized for LostCaseFeedback Apex code coverage
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * Apex Class       : LostCaseFeedback
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 10-17-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        21/06/2020               Nitin Ghai               Initial Version
**/
@isTest
public class LostCaseFeedbackTest {
    
    @isTest
    public static void method(){
        List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        Implementation_Strategy__c ImplementationStrategyRecord2 = TestDataFactory.createImplementation('CaseMIRenewalTriggerServiceImpl','MI_Renewal');
        Implementation_Strategy__c ImplementationStrategyRecord3 = TestDataFactory.createImplementation('CaseDoNoCallRequestsTriggerServiceImpl','Do_No_Call_Requests');
        Implementation_Strategy__c ImplementationStrategyRecord4 = TestDataFactory.createImplementation('CaseDICTriggerServiceImpl','Dealer_Internal_Complaint');
        Implementation_Strategy__c ImplementationStrategyRecord5 = TestDataFactory.createImplementation('CaseDIFTriggerServiceImpl','Dealer_Internal_Feedback');
        Implementation_Strategy__c ImplementationStrategyRecord6 = TestDataFactory.createImplementation('CaseDIRTriggerServiceImpl','Dealer_Internal_Request');
        Implementation_Strategy__c ImplementationStrategyRecord7 = TestDataFactory.createImplementation('CaseDIQTriggerServiceImpl','Dealer_Internal_Query');
        impList.add(ImplementationStrategyRecord1);
        impList.add(ImplementationStrategyRecord2);
        impList.add(ImplementationStrategyRecord3);
        impList.add(ImplementationStrategyRecord4);
        impList.add(ImplementationStrategyRecord5);
        impList.add(ImplementationStrategyRecord6);
        impList.add(ImplementationStrategyRecord7);
        Database.insert(impList,false); 
        Test.startTest();
        Id caseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
        Id taskRecordTypeId= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('MI_Renewal_Call').getRecordTypeId();
        //String taskJson ='{"Customer_Mobile__c":"9811821000","Disposition__c":"Converted","Call_Notes__c":"","Call_back_Date_Time__c":"","Call_back_Phone_Number__c":null,"Feedback_Outcome__c":"","Rating__c":"","Mobile_Number_2__c":"","Mobile_Number_3__c":"","Mobile_Number_4__c":"","Id":"00T0T000001ayA4UAI","Complaint_No__c":"","Dialling_Record_ID__c":"00T0T000001ayA4UAI","Call_End__c":"2020-06-04T15:19:44.066Z","Status":"Completed","IsReminderSet":false,"ReminderDateTime":""}';
        // To create Case records
        List<Case> css = TestDataFactory.createCase(1,caseRecordTypeId);
        css[0].Status='New';
        insert css[0];
        Task t1 = new Task (recordtypeid = taskRecordTypeId,subject = 'test',whatid= css[0].id,case__c=css[0].id);
        insert t1;
        String taskJson ='{"Customer_Mobile__c":"9811821000","Disposition__c":"Already Renewed","Call_Notes__c":"","Call_back_Date_Time__c":"","Call_back_Phone_Number__c":null,"Feedback_Outcome__c":"","Rating__c":"","Mobile_Number_2__c":"","Mobile_Number_3__c":"","Mobile_Number_4__c":"","Id":"' + t1.id + '","Complaint_No__c":"","Dialling_Record_ID__c":"00T0T000001ayA4UAI","Call_End__c":"2020-06-04T15:19:44.066Z","Status":"Completed","IsReminderSet":false,"ReminderDateTime":""}';
        LostCaseFeedback.updateCasetoLost(css[0].Id, taskJson,'');
        Test.stopTest();
    }

}