/*
        Name        :    TestSimkaartController
        Date        :
        Author      :
        Descriptio  :    This Test class is used for SimkaartController
*/
@isTest
public class TestSimkaartController{
    
    //Commented as case is not created now in controller - on 16 march 2019 By Shikha(iBirds)
    /*@isTest
    public static void test1(){
        Case c = new Case();
        c.SuppliedName = 'TestName';
        c.SuppliedEmail = 'Test@gmail.com';
        c.Mobiel_nummer_06_097__c = '8985';
        c.PUK_code__c = '234';
        c.SIM_kaartnummer__c = '245';
        c.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Simwissel').getRecordTypeId();
        insert c;
        simkaartController sc = new simkaartController();
        sc.mobilenumber = '12345678912';
        sc.pukcode = '12345678';
        sc.simcardnumber = '12345678';
        sc.saveCase();
        
    }
    @isTest
    public static void test2(){
        Case c = new Case();
        c.SuppliedName = 'TestName';
        c.SuppliedEmail = 'Test@gmail.com';
        c.Mobiel_nummer_06_097__c = '8985';
        c.PUK_code__c = '234';
        c.SIM_kaartnummer__c = '245';
        c.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Simwissel').getRecordTypeId();
        insert c;
        simkaartController sc = new simkaartController();
        sc.mobilenumber = '123678';
        sc.pukcode = '123478';
        sc.simcardnumber = '123678';
        sc.saveCase();
        
    }*/
    
    //To test updating of Porteringen_mobiel__c and calling simswap  on 16 march 2019 By Shikha(iBirds)
    public static Account createAccount(){
        Account accTestRecord = new Account();
        accTestRecord.Name = 'Test';
        return accTestRecord; //insert Account to Fill Account Field of Opportunity
    }
    public static Opportunity createOpportunity(Id accId){
        Opportunity oppTestRecord = new Opportunity();
        oppTestRecord.Name = 'Test';
        oppTestRecord.StageName = 'Actief';
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
        PorteringenmobielRecord.Datum_actief__c = date.today() - 10;
        PorteringenmobielRecord.recordtypeid = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd KPN ÉÉN').getRecordTypeId();
        return PorteringenmobielRecord;
    }

    
    @isTest
    public static void test1(){  
        Account accTestRecord = createAccount();
        insert accTestRecord; //insert Account to Fill Account Field of Opportunity
        
        Opportunity oppTestRecord = createOpportunity(accTestRecord.id);
        insert oppTestRecord; // insert Opportunity to fill Opportunity And OpportunityId Fields Of Quote
        
        Quote quoteRecord = createQuote(oppTestRecord.id);        
        insert quoteRecord; //insert Quote Record 
        
        Porteringen_mobiel__c PorteringenmobielRecord = createPortMobile(quoteRecord.id);        
        insert PorteringenmobielRecord;
        
        Contact con = new Contact(LastName ='testCon',AccountId = accTestRecord.Id, email = 'ab@test.com');
        insert con;  
        
        Id p = [select id from profile where name='Cloud ÉÉN Community'].id;       
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        system.runAs(user) {
            simkaartController sc = new simkaartController();
            
            sc.mobilenumber = PorteringenmobielRecord.id;
            sc.simcardnumber = '12345678';
            sc.saveCase();
            sc.simcardnumber = '1234';
            sc.saveCase();
            PorteringenmobielRecord = [select id, name, Naam_simwissel__c, E_mailadres_SIM_activatie__c, Simwissel_uitvoeren__c
                                         from Porteringen_mobiel__c Where id =: PorteringenmobielRecord.id];
            user = [select id, contact.name, contact.email from user where id =: user.id];
            /*system.AssertEquals(PorteringenmobielRecord.Naam_simwissel__c, user.contact.name);
            system.AssertEquals(PorteringenmobielRecord.E_mailadres_SIM_activatie__c, user.contact.email);
            system.AssertEquals(PorteringenmobielRecord.Simwissel_uitvoeren__c, true);*/
        }
    }
}