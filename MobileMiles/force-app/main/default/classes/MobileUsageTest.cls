/**
            Name        :        MobileUsage
            Date        :        19th May 2020
            Author      :        Ranu Bari
            Description :        To call web service for account and porterin mobile
**/
@isTest
public class MobileUsageTest {  
    @isTest
    public Static void test1(){
        List<Porteringen_mobiel__c> pmList = new List<Porteringen_mobiel__c>();
        for(Integer i=0; i<10; i++){
            Porteringen_mobiel__c pm = new Porteringen_mobiel__c();
            pm.Name = 'Nieuw';
            pm.Type_aanvraag__c = 'Nieuw nummer';
            pm.IRMA_Id__c = 'Test' + i;
            pm.Datum_actief__c = System.today();
            pmList.add(pm);
        }
        insert pmList;
        Test.startTest();
        Set<Id> ids = (new Map<Id,Porteringen_mobiel__c >(pmList)).keySet();
        MobileUsage.getPorteringDetails(ids );
        Test.stopTest();
    }
}