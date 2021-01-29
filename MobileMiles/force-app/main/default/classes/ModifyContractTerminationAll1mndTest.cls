/*
        Name        :   ModifyContractTerminationTest
        Date        :   26th June 2019
        Author      :   IBirds Software Services.
        Description :   This Class is use to cover the ModifyContractTermination Class.
*/

@isTest
public class ModifyContractTerminationAll1mndTest {
    public static Account createAccount(){
        Account accTestRecord = new Account();
        accTestRecord.Name = 'Test';
        return accTestRecord; //insert Account to Fill Account Field of Opportunity
    }
    public static Opportunity createOpportunity(Id accId){
        Opportunity oppTestRecord = new Opportunity();
        oppTestRecord.Name = 'Test';
        oppTestRecord.StageName = 'Lopend';
        oppTestRecord.CloseDate = System.today();
        oppTestRecord.Accountid = accId;
        return oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
    }
    public static Quote createQuote(Id oppId){
        Quote quoteRecord = new Quote();
        //quoteRecord.Opportunity = oppTestRecord;
        quoteRecord.OpportunityId = oppId;
        quoteRecord.Name = 'Test';
        return  quoteRecord; //insert Quote Record 
    }
    public static Porteringen_mobiel__c createPortMobile(Id quoteId){
        Porteringen_mobiel__c PorteringenmobielRecord = new Porteringen_mobiel__c();
        PorteringenmobielRecord.Name='Nieuw';
        PorteringenmobielRecord.Offerte__c = quoteId;
        PorteringenmobielRecord.Type_aanvraag__c = 'Portering';
        PorteringenmobielRecord.IRMA_Id__c = '1234';
        PorteringenmobielRecord.Contract_duur_afloopdatum_wijzigen__c = false;
        PorteringenmobielRecord.Afwijkende_contract_einddatum__c = system.today();
        PorteringenmobielRecord.Opzegtermijn_maanden__c = 10;
        PorteringenmobielRecord.Datum_actief__c  = system.today();
        return PorteringenmobielRecord;
    }
    
    @isTest
    public Static void doTest1(){
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);
        insert PorteringenmobielRecord;
        
        Test.startTest();
          ModifyContractTerminationAll1mnd mobile = new ModifyContractTerminationAll1mnd(new ApexPages.StandardController(accTestRecord));
          PorteringenmobielRecord.Contract_duur_afloopdatum_wijzigen__c = true;
          ModifyContractTerminationAll1mnd.callModifyContractTerminationAPI();
        
        Test.stopTest();
    }
}