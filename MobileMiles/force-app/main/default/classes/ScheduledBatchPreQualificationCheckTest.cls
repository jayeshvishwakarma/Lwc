@isTest
private class ScheduledBatchPreQualificationCheckTest{
    static testmethod void schedulerTest()  {
        Test.startTest();
        List<Account> accLIst= new List<Account>();
        for(integer i = 0; i<1;i++) {
            Account acc = new Account();
            acc.name= 'test'; 
            acc.Check_infra_informatie__c = true;
            accLIst.add(acc);
        }
         
        insert accLIst;
        Test.stopTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ScheduledBatchPreQualificationCheck());
        
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //System.assertEquals(CRON_EXP, ct.CronExpression);
        //System.assertEquals(0, ct.TimesTriggered);
        
    } 
}