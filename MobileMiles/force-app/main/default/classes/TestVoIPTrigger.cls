/*
        Name            :    TestVoIPTrigger
        Author          :    iBirds Services
        Date            :    13-August-2019
        Description     :    Used in VoIPTrigger
*/

@isTest
public class TestVoIPTrigger{
    //created on 13 august 2019 by shikha
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
    //Create product
    public static Product2 createProduct(){
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        return prod;
    }
    public static VoIP__c createVoIP(){
        VoIP__c VoIPRecord = new VoIP__c();
        VoIPRecord.Name='Nieuw';
        VoIPRecord.ContractTerminationDuration__c = 10;
        VoIPRecord.ContractTerminationDate__c = System.today();
        VoIPRecord.IRMA_Id__c = '1234';
        VoIPRecord.Contract_duur_afloopdatum_wijzigen__c = false;
        return VoIPRecord;
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
        
        //insert Account to Fill Account Field of Opportunity
        Account accTestRecord = createAccount();
        insert accTestRecord; 
        // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; 
        //insert Quote Record 
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; 
        //insert Porteringen Mobiel Record 
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);        
        insert PorteringenmobielRecord;
        //insert Product 
        Product2 productRecord = createProduct();        
        insert productRecord;


        VoIP__c VoIPRecord = createVoIP();  
        VoIPRecord.Account__c = accTestRecord.id;
        VoIPRecord.Vamo_ID__c = PorteringenmobielRecord.id;
        VoIPRecord.Offerte__c = quoteRecord.id;
        VoIPRecord.Dienst__c = productRecord.id;
        insert VoIPRecord; //insert VoIP
        
        Test.startTest();
          VoIP_ModifyContractTermination voip = new VoIP_ModifyContractTermination(new ApexPages.StandardController(VoIPRecord));
          VoIPRecord.Contract_duur_afloopdatum_wijzigen__c = true;
          Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'VoIP Contract Termination', Last_Scheduled_Batch__c = system.now(), Batch_Size__c = 1000);
          insert lastBatch;
          update VoIPRecord;
          VoIP_ModifyContractTermination.callVoIP_ModifyContractTerminationAPI();
          
          //assertions
          system.assertEquals(lastBatch.id != null, true);
          system.assertEquals(VoIPRecord.Contract_duur_afloopdatum_wijzigen__c == true, true);
        Test.stopTest();
    }
}