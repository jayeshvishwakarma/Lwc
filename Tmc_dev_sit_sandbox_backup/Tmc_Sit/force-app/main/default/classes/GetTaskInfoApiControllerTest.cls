@isTest
public class GetTaskInfoApiControllerTest {
    @testSetup
    static void createMethod(){
        list<Custom_Activity__c> customTaskList = testDataFactory.createCustomTask(1);
        insert customTaskList; 
        Task tsk = new Task();
        tsk.ActivityDate = Date.today();
        insert tsk;
    }
    @isTest
    static void testMethd(){
        test.startTest();
        list<Custom_Activity__c> customTaskList = [SELECT id from Custom_Activity__c];
        list<task> listTask = [SELECT id,Status from Task];
        GetTaskInfoApiController.getTaskInfoFunction(customTaskList[0].Id);
        GetTaskInfoApiController.getTaskInfoFunction('11222');
        GetTaskInfoApiController.getTaskInfoFunction(''); 
        GetTaskInfoApiController.getTaskInfoFunction(listTask[0].ID); 
        listTask[0].Status = 'Closed';
        update listTask;
        GetTaskInfoApiController.getTaskInfoFunction(listTask[0].ID); 
        test.stopTest();
    }
}