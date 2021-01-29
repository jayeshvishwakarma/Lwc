/*
        Name            :    TestPorteringenMobielTrigger
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used in PorteringenMobielTrigger
*/
@isTest
public class TestPorteringenMobielTrigger{
    
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
        return PorteringenmobielRecord;
    }
    @isTest
    public Static void doTest1(){
        
           Trigger_Settings__c settings = new Trigger_Settings__c();
           settings.Name='Default';
           settings.Account_Trigger__c=true;
           settings.AvailableSpeed_Trigger__c=true;
           settings.Bestelling_MM_Trigger__c=true;
           settings.Bestellingproduct_Trigger__c=true;
           settings.Opportunity_Trigger__c=true;
           settings.Porteringen_mobiel_Trigger__c=true;
           settings.Quote_Trigger__c=true;
           settings.VolP_Trigger__c=true;
           insert settings;
        
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);        
        insert PorteringenmobielRecord;
        
        delete accTestRecord;
    }
    @isTest
    public Static void doTest2(){
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);        
        insert PorteringenmobielRecord;
        
        delete oppTestRecord;
    }
    @isTest
    public Static void doTest3(){
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);        
        insert PorteringenmobielRecord;
        
        delete quoteRecord;
    }
    @isTest
    public Static void doTest4(){
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);        
        insert PorteringenmobielRecord;
        
        delete PorteringenmobielRecord ;
        
    }
    
    
    @isTest
    public Static void doTest5(){
        Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'Modify Mobile Settings', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 1000);
        insert lastBatch;
        
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);   
        insert PorteringenmobielRecord;
        
        PorteringenmobielRecord.Simwissel_uitvoeren__c = true;
        PorteringenmobielRecord.BlockCallerId__c = true;
        PorteringenmobielRecord.Verzend_wijziging_mobiele_instelling__c  = true;
        update PorteringenmobielRecord ;
        
        PorteringenmobielRecord = [select id, name, Sim_Swap_Status__c, Simwissel_uitvoeren__c, SimCardSwapReason__c from Porteringen_mobiel__c where id =: PorteringenmobielRecord.id];
        //System.assertEquals(PorteringenmobielRecord.Simwissel_uitvoeren__c, true);
        //System.assertNotEquals(PorteringenmobielRecord.SimCardSwapReason__c, null);
    }
    
    //to test Updating Activelookup/Inactivelookup edited on 24/5/2019 by shikha
    @isTest
    public Static void doTest6(){
        List<Last_Batch_Run__c> lastBatchList = new List<Last_Batch_Run__c>();
        lastBatchList.add(new Last_Batch_Run__c(name = 'Mobile Setting', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 10));
        lastBatchList.add(new Last_Batch_Run__c(name = 'Contract Termination', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 10));
        insert lastBatchList;
        
        
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);   
        insert PorteringenmobielRecord;
        PorteringenmobielRecord.Datum_actief__c = system.TODAY()-5;
        update PorteringenmobielRecord;
        
        PorteringenmobielRecord = [select id, actief__c from Porteringen_mobiel__c where id =: PorteringenmobielRecord.id];
        //system.assertEquals(PorteringenmobielRecord.actief__c, true);
        //system.assertNotEquals(PorteringenmobielRecord.active_lookup__c, null);
        
        PorteringenMobielTriggerHelper.MobileSettingsGREXX(new Set<Id>{PorteringenmobielRecord.Id});
        PorteringenMobielTriggerHelper.ModifyContractTerminationGREXX(new Set<Id>{PorteringenmobielRecord.Id});
    }
}