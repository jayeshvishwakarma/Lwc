@isTest
public class CustomActivityControllerTest {
    @isTest
    public static void test1(){
    	//List<Custom_Activity__c> listCA = TestDataFactory.createCustomActivity(1,'MOS Task');
    	List<Custom_Activity__c> listCA = new List<Custom_Activity__c>();
        Id customActivityRecordTypeId = Schema.SObjectType.Custom_Activity__c.getRecordTypeInfosByName().get('MOS Task').getRecordTypeId();
        Custom_Activity__c ca = new Custom_Activity__c(Name = 'TestAccount', RecordTypeId = customActivityRecordTypeId);
        listCA.add(ca);
        insert listCA;
        
        //List<Task> listTask = TestDataFactory.createTaskMOS(1,'MOS Task');
        //listTask[0].Custom_Activity__c = listCA[0].Id;
        
        List<Task> taskList =new List<Task>();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MOS Task').getRecordTypeId();
        
        task tsk = new Task(OwnerId=UserInfo.getUserId(), RecordTypeId = taskRecordTypeId);
        tsk.Custom_Activity__c = listCA[0].Id;
        taskList.add(tsk);
        insert taskList;
        
        CustomActivityController.getCustomActivity(taskList[0].Id);
    }
    
}