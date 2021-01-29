/*
        Name        :   MobileSettingsTest
        Date        :   26th June 2019
        Author      :   IBirds Software Services.
        Description :   This Class is use to cover the MobileSettings Class.
*/

@isTest
public class MobileSettingsTest {
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
        PorteringenmobielRecord.IRMA_Id__c = '123411';
        PorteringenmobielRecord.Mobiele_settings_ophalen__c = false;
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
        MobileSettings mobile = new MobileSettings(new ApexPages.StandardController(PorteringenmobielRecord));
        PorteringenmobielRecord.Mobiele_settings_ophalen__c = true;
        PorteringenmobielRecord1.Mobiele_settings_ophalen__c = true;
        Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'Mobile Setting', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 1);
        insert lastBatch;
        list<Porteringen_mobiel__c> portList = new list<Porteringen_mobiel__c>{PorteringenmobielRecord, PorteringenmobielRecord1};
        update portList;
        MobileSettings.callMobileSettingAPI();
        Test.stopTest();
    }
}