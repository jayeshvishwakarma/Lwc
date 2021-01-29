/*
        Name        :   ISRACheckTest
        Date        :   6th October 2018
        Author      :   IBirds Software Services.
        Description :   This Class is use to cover the ISRACheck Class.
*/
@isTest
public class ISRACheckTest {
    @testSetup static void dataSetup(){
        Account acc = new Account(Name = 'Test Co.',
                                  RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId(),
                                  Rechtsvorm__c = 'BV', KvK_nummer__c = '25364837', Producttype_ISRA_check__c = 'xDSL', IsraSpecification__c = '001',
                                  Phone = '0486-414395', Voornaam_CP__c = 'Piet', Achternaam_CP__c = 'Pietersen', E_mailadres_bedrijf__c = 'piet@testco.co',
                                  Huisnummer__c = '4', ShippingPostalCode = '5371MJ', ShippingStreet = 'De Heinen 4', ShippingCity = 'Huisseling',
                                  Aantal_mobiele_profielen__c = 3, Huisnummer_toevoeging__c = 'a', Isra_Check__c = false);
        insert acc;
       
    }
    @isTest static void testUnit1(){
        List<Account> accountlist = [SELECT Id, ISRA_Check__c, Producttype_ISRA_check__c, ShippingPostalCode, Huisnummer__c, Huisnummer_toevoeging__c, Cleaned_phone__c, IsraSpecification__c FROM Account];
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class,new ISRACheckMockTest());
        
        accountlist[0].Isra_Check__c = true;
        Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'ISRA Check', Last_Scheduled_Batch__c = system.now());
        insert lastBatch;
        AccountTriggerHelper.isISRACheckCalled = false;
        update accountlist[0];
        //ISRACheck.getAccountDetails(account.Id, account.Producttype_ISRA_check__c, account.ShippingPostalCode, account.Huisnummer__c, account.Huisnummer_toevoeging__c, account.Cleaned_phone__c, account.IsraSpecification__c);        
        Test.stopTest();
    }
}