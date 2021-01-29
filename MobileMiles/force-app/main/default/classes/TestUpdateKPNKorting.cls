@isTest
public class TestUpdateKPNKorting {
    @isTest
    public static void testKPNKorting(){
        
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
        Account objAccount = new Account(Name='test Account');
        insert objAccount;
        Opportunity opp = (Opportunity) opportunity.sObjectType.newSObject(null, true);
        opp.AccountId = objAccount.Id;
        opp.Name = 'TestOpp';
        opp.StageName = 'Won';
        opp.CloseDate = System.today().addDays(2);
        opp.PVO_aanmaken__c = true;       
        insert opp;
        
        Quote objQuote = new Quote();
        objQuote.Name='test';
        objQuote.Looptijd__c = '2 jaar';
        objQuote.OpportunityId = opp.Id;
        insert objQuote;       
        Test.startTest();
       
     
          objQuote.Looptijd__c = '3 jaar';
            update objQuote;
       
        Test.stopTest();
    }
}