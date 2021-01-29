/*
    Aauthor : 
    Description : 
*/
@isTest
private class TestSimSwapComponentController {
    
    @testSetup static void setup() {
        Id profile = [select id from profile where name = 'Cloud ÉÉN Community'].id;
        
        Account accountRecord = new Account(name ='testAccount') ;
        insert accountRecord; 
        
        Contact conRecord = new Contact(LastName ='testCon',AccountId = accountRecord.Id);
        insert conRecord;  
        
        User user = new User(alias = 'test1234', email='test12653@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profile, country='United States',IsActive =true,
                             ContactId = conRecord.Id,
                             timezonesidkey = 'America/Los_Angeles', username='te1232ster@noemail.com');
        
        insert user;
        
        Porteringen_mobiel__c porteringenRecord = new Porteringen_mobiel__c();
        porteringenRecord.Name='Nieuw';
        porteringenRecord.Type_aanvraag__c = 'Portering';
        porteringenRecord.IRMA_Id__c = '1234';
        porteringenRecord.Datum_actief__c = date.today() - 10;
        porteringenRecord.Account__c = accountRecord.Id;
        porteringenRecord.recordtypeid = 
            Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd KPN ÉÉN').getRecordTypeId();
        insert porteringenRecord;
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
    }
    
    @isTest
    private static void testMethod1() {
        List<Porteringen_mobiel__c> porterMobiels = [SELECT Id, Account__c FROM Porteringen_mobiel__c LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];
        String configDataJSON;
        
        SimSwapComponentController.fetchAllAccounts();
        SimSwapComponentController.fetchActivePMRecords(porterMobiels[0].Account__c);
        SimSwapComponentController.fetchHuidigeProviders();
        
        // ActivateSim
        configDataJSON = '{ "pmId" : "'+porterMobiels[0].Id+'", "selectionType" : "ActivateSim", "simKaartNumber" : "11111112",';
        configDataJSON += '"name" : "", "product" : "", "vamo": ""}';
        SimSwapComponentController.saveRecords(configDataJSON);
        
        
        // NewNumber
        configDataJSON = '{ "pmId" : "'+porterMobiels[0].Id+'", "selectionType" : "NewNumber", "simKaartNumber" : "11111112",';
        configDataJSON += '"name" : "", "product" : "'+ products[0].Id +'", "vamo": "true"}';
        SimSwapComponentController.saveRecords(configDataJSON);
        
        
        //PorteringName
        configDataJSON = '{ "pmId" : "'+porterMobiels[0].Id+'", "selectionType" : "PorteringName", "simKaartNumber" : "",';
        configDataJSON += '"name" : "test", "product" : "'+ products[0].Id +'", "vamo": "true"}';
        SimSwapComponentController.saveRecords(configDataJSON);
        
        
        //PorteringNumber
        configDataJSON = '{ "pmId" : "'+porterMobiels[0].Id+'", "selectionType" : "PorteringNumber", "simKaartNumber" : "12345677",';
        configDataJSON += '"name" : "test", "product" : "'+ products[0].Id +'", "vamo": "true"}';
        SimSwapComponentController.saveRecords(configDataJSON);
    }
    
}