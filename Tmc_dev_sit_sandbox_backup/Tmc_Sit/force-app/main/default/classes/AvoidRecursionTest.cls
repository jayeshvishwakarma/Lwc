@istest
public class AvoidRecursionTest{
    
    public testmethod static void testcase(){
        AvoidRecursion.isBeforeRun();
        AvoidRecursion.isAfterRun();
        AvoidRecursion.isPreBookingInsertRun();
        AvoidRecursion.isSVOCAfterRun();
        
    }
    public testmethod static void testcase1(){
        AvoidRecursion.isPreBookingInsert = false;
        AvoidRecursion.isAfter = false;
        AvoidRecursion.isbefore = false;
        AvoidRecursion.isSVOCAfter = false;
        AvoidRecursion.isBeforeRun();
        AvoidRecursion.isAfterRun();
        AvoidRecursion.isPreBookingInsertRun();
        AvoidRecursion.isSVOCAfterRun();
        
    }
    
    
}