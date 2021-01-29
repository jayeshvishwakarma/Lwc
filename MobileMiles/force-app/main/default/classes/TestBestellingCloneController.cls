@istest
public class TestBestellingCloneController{
    @istest
    private static void testController(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        acc = [select id from account where id =: acc.id];
        
        Bestelling_MM__c Bestelling = new Bestelling_MM__c();
        Bestelling.Status__c = 'Lopend';
        Bestelling.Bedrijf__c = acc.id;
        Bestelling.MobileMiles__c = 20.00;
        insert Bestelling;
        
        Bestelling = [select id, Bedrijf__c from Bestelling_MM__c where id =: Bestelling.id];
        BestellingProduct__c bProduct1 = new BestellingProduct__c();
        bProduct1.Bestelling__c = Bestelling.id;
        bProduct1.Hoeveelheid__c = 1;
        bProduct1.Verkoopprijs__c = 36000;
        insert bProduct1;
        
        BestellingProduct__c bProduct2 = new BestellingProduct__c();
        bProduct2.Bestelling__c = Bestelling.id;
        bProduct2.Hoeveelheid__c = 2;
        bProduct2.Verkoopprijs__c = 37000;
        insert bProduct2;
        
        System.assertNotEquals(Bestelling.id, null);
        System.assertEquals(Bestelling.Bedrijf__c, acc.id);
        System.assertEquals([select id from Bestelling_MM__c].size(), 1);
        System.assertEquals([select id from BestellingProduct__c].size(), 2); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(Bestelling);
        ApexPages.currentPage().getParameters().put('id',Bestelling.id);
        BestellingCloneController bcc = new BestellingCloneController(sc);
        bcc.delIndex = 1;
        bcc.DeleteRow();
        bcc.save();
        
        System.assertEquals([select id from Bestelling_MM__c].size(), 2);
        System.assertEquals([select id from BestellingProduct__c].size(), 3);       
        
    }
    
}