@isTest
public class TestCallMeNowController{

      @isTest
      static void testUnit1(){   
        Test.startTest();
            CallMeNowController.callNow('3015551212');
            
        Test.stopTest();

    }
}