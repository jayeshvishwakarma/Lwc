@isTest
public class PerformanceBatchSchedulerTest {

    public static testMethod void testMethod1(){
        PerformanceBatchScheduler sh1 = new PerformanceBatchScheduler();      
     String sch = '0  00 1 3 * ?';
       system.schedule('Test', sch, sh1);
    }
   
}