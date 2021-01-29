/*
        Name            :    TestKwtTrigger
        Author          :    Jayesh Vishwakarma
        Date            :    01/09/2020
        Description     :    Used in KWT PorteringenMobielTrigger
*/
@isTest
public class TestKwtTrigger {
    
    @isTest
    public static void test(){
        
        
        Account accTestRecord = new Account();
        accTestRecord.Name = 'Test';
        insert accTestRecord;
        
        
        Product2 product = new Product2(Name = 'Testing Product', Family = 'Profielen', IRMA_Productcode__c = '082H00016B', ProductCode = 'KPN Mobiel');
        insert product;
        
        Opportunity oppTestRecord = new Opportunity();
        oppTestRecord.Name = 'Test';
        oppTestRecord.StageName = 'Lopend';
        oppTestRecord.CloseDate = System.today();
        oppTestRecord.Accountid = accTestRecord.id;
        insert oppTestRecord;
        
        
        Quote quoteRecord = new Quote();
        //quoteRecord.Opportunity = oppTestRecord;
        quoteRecord.OpportunityId = oppTestRecord.id;
        quoteRecord.Name = 'Test';
        insert  quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = new Porteringen_mobiel__c();
        PorteringenmobielRecord.Name='Nieuw';
        PorteringenmobielRecord.Offerte__c = quoteRecord.id;
        PorteringenmobielRecord.Type_aanvraag__c = 'Portering';
        PorteringenmobielRecord.IRMA_Id__c = '1234';
        PorteringenmobielRecord.Account__c = accTestRecord.Id;
        PorteringenmobielRecord.Product__c = product.Id;
        insert PorteringenmobielRecord;
        
        Account objAccount = new Account(Name = 'Test2');
        insert objAccount;
        
        Kwt__c kwt1 = new Kwt__c(Bedrijf__c = objAccount.Id, Product__c = product.Id, Korting_per_aansluiting_p_mnd__c = 1000 );
        insert kwt1;
        test.startTest();               
               
        Kwt__c kwt = new Kwt__c(Bedrijf__c = accTestRecord.Id, Product__c = product.Id, Korting_per_aansluiting_p_mnd__c = 200 );
        insert kwt;
        kwt.Korting_per_aansluiting_p_mnd__c = 100;
        update kwt;
        
       	 PorteringenmobielRecord.Account__c = objAccount.Id;
         update PorteringenmobielRecord;
        
        test.stopTest();
        
    }
    
}