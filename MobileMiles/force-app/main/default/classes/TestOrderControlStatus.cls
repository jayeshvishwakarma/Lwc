/**
    Name           :   TestOrderControlStatus 
    Author         :   
    Date           :   13 March, 2018
    Description    :   This is a test class of OrderControlStatus Controller.
**/
@isTest
public class TestOrderControlStatus {
    @isTest 
    public static void runTest() { 
        OrderControlStatus controller = new OrderControlStatus('test','test','test','test','test','test',System.now(),system.now(),'test','test');
    }
}