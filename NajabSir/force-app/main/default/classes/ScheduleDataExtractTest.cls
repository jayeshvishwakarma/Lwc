@isTest
private class ScheduleDataExtractTest{

    static testMethod void testschedule() {
    
        Test.StartTest();
            ScheduleDataExtract sh1 = new ScheduleDataExtract();
        
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    
    }
}