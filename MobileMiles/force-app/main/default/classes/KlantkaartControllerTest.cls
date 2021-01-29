/*
    Name        :    KlantkaartControllerTest
    Date        :    14 April 2017
    Auther      :    
    Description :    This is a Test class for KlantkaartController Class  

*/
@isTest
public class KlantkaartControllerTest{
    @isTest
    public Static void doTest(){
        Account accTestRecord = new Account();
        accTestRecord.Name = 'Test';
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        Opportunity oppTestRecord = new Opportunity();
        oppTestRecord.Name = 'Test';
        oppTestRecord.StageName = 'Lopend';
        oppTestRecord.CloseDate = System.today();
        oppTestRecord.Account = accTestRecord;
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        Quote quoteRecord = new Quote();
        quoteRecord.Opportunity = oppTestRecord;
        quoteRecord.OpportunityId = oppTestRecord.id;
        quoteRecord.Name = 'Test';
        insert quoteRecord; //insert Quote Record 
        Porteringen_mobiel__c PorteringenmobielRecord = new Porteringen_mobiel__c();
        PorteringenmobielRecord.Name='Nieuw';
        PorteringenmobielRecord.Offerte__c = quoteRecord.Id;
        PorteringenmobielRecord.Type_aanvraag__c = 'Nieuw nummer';
        insert PorteringenmobielRecord;
        ApexPages.StandardController standardControllerRecord= new ApexPages.StandardController(quoteRecord); //create StandardController Record for call KlantkaartController's Constructor
        KlantkaartController testKlantkaartRecord = new KlantkaartController(standardControllerRecord);
    }
}