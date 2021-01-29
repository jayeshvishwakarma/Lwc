@isTest
public class GetTaskInfoApiControllerTest {
    @testSetup
    static void createMethod(){
      list<Custom_Activity__c> customTaskList = testDataFactory.createCustomTask(1);
      insert customTaskList;  
    }
    @isTest
    static void testMethd(){
        test.startTest();
        list<Custom_Activity__c> customTaskList = [SELECT id from Custom_Activity__c];
        GetTaskInfoApiController.getTaskInfoFunction(customTaskList[0].Id);
        GetTaskInfoApiController.getTaskInfoFunction(''); 
        test.stopTest();
    }
}