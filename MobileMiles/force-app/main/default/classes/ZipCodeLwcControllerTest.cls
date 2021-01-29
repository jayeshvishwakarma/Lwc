/**
Name           :   ZipCodeLwcControllerTest
Author         :   iBirds Services
Date           :   15 July, 2019
Description    :   This is a test class of ZipCodeLwcController Class.
**/
@isTest
public class ZipCodeLwcControllerTest {
    @isTest
    static void methodTest1(){
        Account newAcc = new Account(Name = 'Test Co.', ShippingPostalCode = '1314cb', Connectivity_portfolio__c = 'Business', Huisnummer__c = '33', 
                                     RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId());
        insert newAcc;
        ZipCodeLwcController.getZipCode(null,'Business','1314CB','33','56764352');
    }
}