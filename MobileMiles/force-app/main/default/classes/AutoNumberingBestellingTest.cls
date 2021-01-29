@isTest//(seeAllData=true)
public class AutoNumberingBestellingTest{
    static TestMethod void AutoNumberingBestellingTest(){
        
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
        
        Account a = new Account();
        a.Name = 'test';
        insert a;
        
        Product2 p = new Product2();
        p.Name='Test';
        insert p;
        
        Bestelling_MM__c   bs = new Bestelling_MM__c();
        bs.Hoeveelheid__c = 12.23;
        bs.Bedrijf__c = a.id;
        bs.Product__c = p.id;
        bs.Factuurnummer__c = '';
        insert bs;
        
        bs.Status__c ='Gefactureerd';
        update bs; 
        
        
        // inserting custom setting records
        PaymentTransactionSetting__c setting = new PaymentTransactionSetting__c(Name = 'config',
                                                                                End_URL__c = 'https://www.pay.nl/demo_ppt/finish_url',
                                                                                Merchant_User_Name__c='test@gmail.com',
                                                                                Password__c = '5Xn*B!5U$dt3234',
                                                                                Redirect_URL__c='https://rest-api.pay.nl/v7/Transaction/start/json',
                                                                                Service_Id__c = 'SL-5516-2570',
                                                                                Token__c = '6eb4bb2f8b67d08a7cf9b3e9cdae31d62def1315');
       insert setting;  
       test.startTest();
       bs.Paynl_Payment__c = true;
        update bs;      
       test.stopTest();                                                                 
    
    }
}