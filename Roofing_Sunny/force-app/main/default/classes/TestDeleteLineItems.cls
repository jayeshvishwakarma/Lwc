/*********************************************************************************
* Test Class: {TestDeleteLineItems}
* Created by   {DateCreated 12/04/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of DeleteLineItems.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/04/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestDeleteLineItems {

    static testMethod void myUnitTest() {
        Test.startTest();
        Region__c reg = TestClassUtility.createRegion('TestClass1','TC1',true);
        Territory__c terr = TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial', reg.Id, true);
        Account soldToAccs = TestClassUtility.createAccount('Sold_To_Acc_',null, 'All_Other_Accounts', 'Other', 'Other', terr.Id, true);
        Account orderForAccs = TestClassUtility.createAccount('Order_For_Acc_', soldToAccs.Id, 'All_Other_Accounts', 'Other', 'Other', terr.Id, true);
        Account shipToAccs = TestClassUtility.createAccount('Ship_To_Acc_', orderForAccs.Id, 'All_Other_Accounts', 'Other', 'Other', terr.Id, true);
        Set<Id> ids = new Set<Id>();
        Order order1 = TestClassUtility.createOrder('Order_1', System.Today().addDays(-1), orderForAccs.Id, 'PICKED', 800, shipToAccs.id, true);
        Order order2 = TestClassUtility.createOrder('Order_2', System.Today().addDays(-10), orderForAccs.Id, 'PICKED', 800, shipToAccs.id, true);
        Order order3 = TestClassUtility.createOrder('Order_3', System.Today().addDays(-30), orderForAccs.Id, 'PICKED', 800, shipToAccs.id, true);
        Order order4 = TestClassUtility.createOrder('Order_4', System.Today().addDays(-45), orderForAccs.Id, 'PICKED', 800, shipToAccs.id, true);
        ids.add(order1.id);
        ids.add(order2.id);
        ids.add(order3.id);
        ids.add(order4.id);
        
        DeleteLineItems delLineItem = new DeleteLineItems();
        DeleteLineItems.process(ids);
        Test.stopTest();
        System.assertEquals(reg.Name,'TestClass1');
        
    }
}