/**
    Name           :   SuppliersViewControllerTest
    Author         :   iBirds Services
    Date           :   30 April, 2019
    Description    :   This is a test class of SuppliersViewController Class.
**/
@isTest
public class SuppliersViewControllerTest{
    //Created on 30 april 2019 by shikha
    @IsTest
    public static void runTest() {
        Account acc = new Account(Name = 'Test Co.', ShippingPostalCode = '1314cb', Connectivity_portfolio__c = 'Business', Huisnummer__c = '33', 
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId());
        insert acc;
        
        Test.startTest();
            acc = [select id, Connectivity_portfolio__c from Account where id =: acc.id];
            SuppliersViewController suppView = new SuppliersViewController(new ApexPages.StandardController(acc));
            List<Available_Supplier__c> suppList = suppView.getSuppliers();
            suppView.connTypeParam = 'Business';
            suppView.setBusinessType();
            suppView.getConnectivityType();
            suppView.callZipcodeApi();
        Test.stopTest();
    }
}