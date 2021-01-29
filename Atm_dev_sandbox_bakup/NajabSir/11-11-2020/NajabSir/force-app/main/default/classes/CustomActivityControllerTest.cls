@isTest
public class CustomActivityControllerTest {
    @isTest
    public static void test1(){
    	List<Custom_Activity__c> listCA = TestDataFactory.createCustomActivity(1,'MOS Task');
        insert listCA;
        
        List<Task> listTask = TestDataFactory.createTaskMOS(1,'MOS Task');
        listTask[0].Custom_Activity__c = listCA[0].Id;
        
        insert listTask;
        
        CustomActivityController.getCustomActivity(listTask[0].Id);
    }
}