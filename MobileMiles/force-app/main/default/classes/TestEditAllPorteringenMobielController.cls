/*
    Name         :   TestEditAllPorteringenMobielController
    Description  :   used to cover EditAllPorteringenMobielController
    Created Date :   14 April 2017
*/
@isTest
public class TestEditAllPorteringenMobielController{
    public static testmethod void test1(){
        //record insertions
        Account accTestRecord = new Account(Name = 'Test Acc');
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = new Opportunity(Name = 'Test', StageName = 'Lopend', CloseDate = System.today(), Account = accTestRecord);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote qtObj = new Quote(name='Test Quote', opportunityid = oppTestRecord.id);
        insert qtObj;
        
        Porteringen_mobiel__c pmObj = new Porteringen_mobiel__c(name='Nieuw', Offerte__c = qtObj.id,Type_aanvraag__c = 'Nieuw nummer');
        insert pmObj;
        
        //apex coverage
        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        EditAllPorteringenMobielController ctrlObj = new EditAllPorteringenMobielController(sc);
        
        ctrlObj.save();
        ctrlObj.cancel();
    }
}