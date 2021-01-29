/**
 * @File Name          : CallStartControllerTest.cls
 * @Description        : It is utilized for CallStartController Apex code coverage
 * @Author             : Sunit Kumar Chand
 * @Group              : 
 * Apex Class		   : CallStartController
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 10-17-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0        03/01/2020               Sunit Chand   		    	  Initial Version
 * 1.0        18/06/2020               Nitin Ghai   		    	  Added system.assert
**/
@isTest
public class CallStartControllerTest {
    public static String taskRecordId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PSF_Follow_Up').getRecordTypeId();
	public static Id caseRecordId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    @isTest
    static void fetchData(){
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
        impList.add(ImplementationStrategyRecord);
        insert impList;
        List<Account> accList=TestDataFactory.createPersonAccount(1);
        insert accList;
        List<Task> taskList = TestDataFactory.createTask(1,taskRecordId);
        taskList[0].Type='T';
        taskList[0].Contact_ID__c=accList[0].Id;
        test.startTest();
        insert taskList;
        BasicReturn result= CallStartController.fetchData(taskList[0].Id);
        System.assertEquals('Success', result.status) ;
        test.stopTest();
    }
    @isTest
    static void fetchDataCase(){
       /* List<Account> accList=TestDataFactory.createPersonAccount(1);
        insert accList;
        List<Task> taskList = TestDataFactory.createTask(1,'0120T000000081tQAA');
        taskList[0].Type='T';
        taskList[0].Contact_ID__c=accList[0].Id;
        
        insert taskList;*/
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

        test.startTest();
        List<Case> caseList = TestDataFactory.createCase(1,caseRecordId);
        caseList[0].Status='New';
        insert caseList; 
        BasicReturn result= CallStartController.fetchData(caseList[0].Id);
        System.assertEquals('Error', result.status) ;
        test.stopTest();
    }
    @isTest
    static void fetchDataInProgressValidation(){
        List<Account> accList=TestDataFactory.createPersonAccount(1);
        insert accList;
        List<Task> taskList = TestDataFactory.createTask(1,taskRecordId);
        taskList[0].Status='In Progress';
        taskList[0].Type='T';
        taskList[0].Contact_ID__c=accList[0].Id;
        test.startTest();
        insert taskList;
        BasicReturn result= CallStartController.fetchData(taskList[0].Id);
        System.assertEquals('Success', result.status) ;
        test.stopTest();
    }
    @isTest
    static void fetchDataCompletedValidation(){
        List<Account> accList=TestDataFactory.createPersonAccount(1);
        insert accList;
        List<Task> taskList = TestDataFactory.createTask(1,taskRecordId);
        taskList[0].Status='Completed';
        taskList[0].Type='T';
        taskList[0].Contact_ID__c=accList[0].Id;
        test.startTest();
        insert taskList;
        BasicReturn result= CallStartController.fetchData(taskList[0].Id);
        System.assertEquals('Error', result.status) ;
        test.stopTest();
    }
    @isTest
    static void updateTaskStatus(){
        List<Account> accList=TestDataFactory.createPersonAccount(1);
        insert accList;
        List<Task> taskList = TestDataFactory.createTask(1,taskRecordId);
        taskList[0].Status='open';
        taskList[0].Type='T';
        taskList[0].Contact_ID__c=accList[0].Id;
        test.startTest();
        insert taskList;
        CallStartController.updateTaskStatus(taskList[0].Id,'237828737');
        test.stopTest();
    }
}