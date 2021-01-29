/**
    Name           :   CustomerCreateControllerTest
    Author         :   
    Date           :   13 Feb, 2019
    Description    :   This is a test class of CustomerCreateController Class.
**/
@isTest
public class CustomerCreateControllerTest{
    @IsTest
    public static void runTest() {
        Account acc = new Account(Name = 'Test Co.', Rechtsvorm__c = 'BV', KvK_nummer__c = '25364837', Phone = '0486-414395', 
                  RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId(), 
                  E_mailadres_bedrijf__c = 'piet@testco.co', Huisnummer__c = '4', ShippingPostalCode = '5371MJ', 
                  ShippingCity = 'Huisseling', ShippingCountry = 'NLD', CKR_nummer__c = '12345');
        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.Id,name = acc.name,closedate = system.today(),stagename='Prospecting');
        insert opp;
        //Quote quote = [select id from Quote limit 1];
        Quote quote = new Quote(Name = 'Test Quote', opportunityId = opp.Id);
        insert quote;
        
        Test.startTest();
            CustomerCreateController custCreate = new CustomerCreateController(new ApexPages.StandardController(quote));
            //custCreate.quotesRecord = quote.id;
            CustomerCreateController.getAccountDetails();
            acc.Straat__c = 'De Heinen 4';
            update acc;
            CustomerCreateController.getAccountDetails();
        Test.stopTest();
    }
}