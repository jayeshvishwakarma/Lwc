/**
    Name           :   ZipCodeCheckControllerTest
    Author         :   iBirds Services
    Date           :   26 April, 2019
    Description    :   This is a test class of ZipCodeCheckController Class.
**/
@isTest
public class ZipCodeCheckControllerTest{
    //Created on 26 april 2019 by shikha
    @IsTest
    public static void runTest() {
        Account acc = new Account(Name = 'Test Co.', ShippingPostalCode = '1314cb', Connectivity_portfolio__c = 'Business', Huisnummer__c = '33', 
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId());
        insert acc;
        
        Test.startTest();
            ZipCodeCheckController zipCheck = new ZipCodeCheckController(new ApexPages.StandardController(acc));
            ZipCodeCheckController.doPost();
            acc.Huisnummer__c = null;
            update acc;
            ZipCodeCheckController.doPost();
            
            list<Available_Supplier__c> supplierList = [select id, Account__c from Available_Supplier__c where Account__c =: acc.id];
            system.assertEquals(supplierList.size()>0, true);
            system.assertEquals(supplierList[0].account__c, acc.id);
            
            if(supplierList.size() > 0){
                list<Available_Speed__c> speedList = [select id, Available_Supplier__c from Available_Speed__c where Available_Supplier__c =: supplierList[0].id];    
                if(speedList.size() > 0){
                    system.assertEquals(speedList[0].Available_Supplier__c, supplierList[0].id);
                }
            }
            
        Test.stopTest();

    }
}