/*
Name        :   ModifyContractTerminationTest
Date        :   26th June 2019
Author      :   IBirds Software Services.
Description :   This Class is use to cover the ModifyContractTermination Class.
*/

@isTest
public class ModifyContractTerminationTest {
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
        PorteringenmobielRecord.IRMA_Einde_contractdatum__c = system.today();
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
        Porteringen_mobiel__c PorteringenmobielRecord1 = createPortMobile(quoteRecord.id);     
        PorteringenmobielRecord1.IRMA_Id__c = '123511';   
        insert PorteringenmobielRecord1;
        
        Test.startTest();
        ModifyContractTermination mobile = new ModifyContractTermination(new ApexPages.StandardController(PorteringenmobielRecord));
        PorteringenmobielRecord.Contract_duur_afloopdatum_wijzigen__c = true;
        PorteringenmobielRecord1.Contract_duur_afloopdatum_wijzigen__c = true;
        Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'Contract Termination', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 1);
        insert lastBatch;
        list<Porteringen_mobiel__c> portList = new list<Porteringen_mobiel__c>{PorteringenmobielRecord, PorteringenmobielRecord1};
            update portList;
        ModifyContractTermination.callModifyContractTerminationAPI();
        String FResponse = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
        FResponse += '<soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect">';
        FResponse += '<header><transactionID>1:5490:15784304</transactionID><reference>a6A57000000ChEM</reference></header>';
        FResponse += '<status><code>0</code><message>Succes</message></status>';
        FResponse += '<responseData><QueueResponse><IsSuccess>true</IsSuccess><ErrorCode>0</ErrorCode></QueueResponse></responseData>';
        FResponse += '</grexxResponse></soap:Body></soap:Envelope>';
        Dom.Document doc = new Dom.Document();
        doc.load(FResponse);
        Dom.XmlNode root = doc.getRootElement();
                   
        ModifyContractTermination.parseXML(root);
        
        Test.stopTest();
    }
}