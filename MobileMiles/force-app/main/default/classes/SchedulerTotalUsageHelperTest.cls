@isTest
public class SchedulerTotalUsageHelperTest {
    static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        // Create your test data
        Account acc = new Account();
        acc.iRMA_id__c = '123456';
        acc.Aantal_mobiele_profielen__c = 5244;
        acc.name= 'test';
        insert acc;
        Set<String> accIds = new Set<String>();
        accIds.add(acc.Id);
        Test.startTest();
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ScheduledBatchMobileTotalUsage(0));
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest(); 
    }
}