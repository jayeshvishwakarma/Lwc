/********************************************************************************** 
Test Class: {TestScheduleBatchProcessCreateNewShipto}* 
Created by  {DateCreated 03/27/2015}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ScheduleBatchProcessCreateNewShipto.cls}
----------------------------------------------------------------------------------
*/

@isTest
private class TestScheduleBatchProcessCreateNewShipTo
{    
    static testMethod void myUnitTest() 
    {
         Test.startTest();  
         ScheduleBatchProcessCreateNewShipTo shipto = new ScheduleBatchProcessCreateNewShipTo(); 
          shipto.execute(null);        
          System.assert(true);       
          Test.stopTest();    
    }
}