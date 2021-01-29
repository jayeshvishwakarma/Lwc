@isTest
private class ScheduledBatchMobileTotalUsageTest {
    static testmethod void schedulerTest()  {
        Test.startTest();
        List<Account> accLIst= new List<Account>();
        for(integer i = 0; i<1;i++) {
            Account acc = new Account();
            acc.name= 'test'; 
            acc.Aantal_mobiele_profielen__c = 1;
            acc.iRMA_id__c = generateRandomString(15);
            accLIst.add(acc);
        }
         
        insert accLIst;
        Test.stopTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ScheduledBatchMobileTotalUsage(0));
        
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //System.assertEquals(CRON_EXP, ct.CronExpression);
        //System.assertEquals(0, ct.TimesTriggered);
        
    }
    
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}