/*********************************************************************************
* Test Class: {TestCaseTriggerHandler}
* Created by {Abhishek Pareek}, Navivo, {DateCreated 12/26/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Covering Code of CaseTriggerHandler}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/26/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class TestCaseTriggerHandler {

    static testMethod void myUnitTest() {
        Region__c reg = TestClassUtility.createRegion('TestClass1','TC1',true);
        Territory__c terr = TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial', reg.Id, true);
        User us=  TestClassUtility.createTestUser('Contract Manager','Danthony','rbommareddy@thresholdcs.com','Anthony','rbommareddy@thresholdcs.com','Pricing Manager',true);
        Plants__c wh =  TestClassUtility.createWarehouse('TEST',us.id, true);
        Account soldToAccs = TestClassUtility.createAccount('Sold_To_Acc_',null, 'All_Other_Accounts', 'Other', 'Other', terr.Id, true);
        Account orderForAccs = TestClassUtility.createAccount('Order_For_Acc_', soldToAccs.Id, 'All_Other_Accounts', 'Other', 'Other', terr.Id, true);
        Account shipToAccs = TestClassUtility.createAccount('Ship_To_Acc_', orderForAccs.Id, 'All_Other_Accounts', 'Other', 'Other', terr.Id, true);
        Contact con = TestClassUtility.createcontact('test',orderForAccs.Id,'AL','test@test.com','9899898899',true);
        Region__c region = TestClassUtility.createReg('TestClass1','TST',con.id,us.id,true);
        Order order1 = TestClassUtility.createOrder('Order_1', System.Today().addDays(-1), orderForAccs.Id, 'PICKED', 800, shipToAccs.id, true);
        order1.Manufacturing_Plant__c = wh.Id;
        order1.region_rpg__c = region.Id;
        update order1;
        List<Case> csList = new List<Case>();
        csList.add(TestClassUtility.createCase('Order Change', 'test', 'Changed Request Date', 'Closed', con.Id, order1.Id, false));
        //csList.add(TestClassUtility.createCase('Order Change', 'test', 'Changed Request Date', 'Closed', con.Id, order1.Id, false));
        //csList.add(TestClassUtility.createCase('Order Change', 'test', 'Changed Request Date', 'Closed', con.Id, order1.Id, false));
        insert csList;
        caseTriggerHandler_rpg cth = new caseTriggerHandler_rpg();
        cth.updateBusinessHours(csList);
        cth.updateTM(csList, null);
        Order order2 = TestClassUtility.createOrder('Order_2', System.Today().addDays(-1), orderForAccs.Id, 'PICKED', 700, shipToAccs.id, true);
        //Case cs = TestClassUtility.createCase('Order Change', 'test', 'Changed Request Date', 'Closed', con.Id, order2.Id, true);
        csList[0].Order__c = order2.Id;
        update csList[0];
        Map<Id,Case> oldMap = new Map<Id,Case>();
        oldMap.put(csList[0].Id,csList[0]);
        cth.updateTM(csList, oldMap);
    }
}