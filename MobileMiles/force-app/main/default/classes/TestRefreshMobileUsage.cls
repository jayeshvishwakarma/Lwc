/**
Name        :        TestRefreshMobileUsage 
Date        :        19th May 2020
Author      :       
Description :        Test Class for RefreshMobileUsage 
**/
@isTest 
public class TestRefreshMobileUsage {  
    @isTest
    public Static void test1(){

        Account acc = new Account();
        acc.Name ='Test Name';

        insert acc;
        
        List<Porteringen_mobiel__c> pmList = new List<Porteringen_mobiel__c>();
        for(Integer i=0; i<10; i++){
            Porteringen_mobiel__c pm = new Porteringen_mobiel__c();
            pm.Name = 'Nieuw';
            pm.Type_aanvraag__c = 'Nieuw nummer';
            pm.IRMA_Id__c = 'Test' + i;
            pm.Datum_actief__c = System.today();
            pm.account__C = acc.id; 
            pmList.add(pm);
        }
        insert pmList;
        test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);

        RefreshMobileUsage ref = new RefreshMobileUsage(sc);
        ref.refreshData();
        ref.refreshPortMobData();
        test.stopTest();  
    }
}