@isTest
public class UpgradePorteringOrderControllerTest{
    @isTest
    public static void testUnit(){
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
        //PorteringenmobielRecord.Datum_actief__c = System.Today();
        insert PorteringenmobielRecord;
        ApexPages.StandardController standardControllerRecord= new ApexPages.StandardController(quoteRecord); //create StandardController Record for call KlantkaartController's Constructor
        UpgradePorteringOrderController testUPOC = new UpgradePorteringOrderController(standardControllerRecord);
        testUPOC.UpgradePorteringOrder();
    }
}