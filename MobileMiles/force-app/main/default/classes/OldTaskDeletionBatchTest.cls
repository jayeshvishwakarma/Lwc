/*
    Name        : OldTaskDeletionBatchTest
    Date        : 21 May, 2020
    Author      : Mufiz
    Description : This test class is using for code coverage of OldTaskDeletionBatch.
*/
@isTest
private class OldTaskDeletionBatchTest {
	@isTest private static void TestUnit(){
        // Create test quote record Start
		// Account record Create
        Account accountObj = new Account(Name = 'Test');
		insert accountObj;
        System.assertNotEquals(null, accountObj.Id);
        
        // Opportunity Record Create
        Opportunity opportunityObj = new Opportunity(Name = 'Test Opportunity', AccountId = accountObj.Id, StageName = 'Lopend', 
                                                     CloseDate = Date.today()+1);
        insert opportunityObj;
        System.assertNotEquals(null, opportunityObj.Id);
        
        // Opportunity Record Create
        String pricebook2Id = Test.getStandardPricebookId();
        Quote quoteObj = new Quote(OpportunityId = opportunityObj.Id, Name = 'Test Quote', Pricebook2Id = pricebook2Id, 
                                   Status = 'Concept');
        insert quoteObj;
        System.assertNotEquals(null, quoteObj.Id);
        // Create test quote record End
        // ============================
        // Create test task record
        Task taskObj = new Task();
        taskObj.OwnerId = UserInfo.getUserId();
        taskObj.Subject = 'Test';
        taskObj.Status = 'Not Started';
        taskObj.Priority = 'Normal';
        taskObj.WhatId = quoteObj.Id;
        insert taskObj;    
 		Datetime tenDayOlderDate = Datetime.now().addDays(-11); // Update CreatedDate to 10 days older
		Test.setCreatedDate(taskObj.Id, tenDayOlderDate);
        Test.startTest();
        	Database.executeBatch(new OldTaskDeletionBatch(UserInfo.getUserId()));
        	//Scheduler class code coverage
        	OldTaskDeletionBatchScheduler schedulerObj = new OldTaskDeletionBatchScheduler();
            String schedulerTime = '0 0 23 * * ?';
            system.schedule('Testing', schedulerTime, schedulerObj);
        Test.stopTest();
        List<Task> tasks = [Select Id from task];
        System.assertEquals(0, tasks.size());
    }
}