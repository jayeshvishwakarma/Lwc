@isTest
public class BatchMobileUsageTest {
    static testmethod void batchTest(){
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
        Set<String> setOfIds = new Set<String>();
        for(Porteringen_mobiel__c pm : pmList){
            setOfIds.add(pm.Id);
        }
        Test.startTest();
        BatchMobileUsage bmu = new BatchMobileUsage(setOfIds);
        Database.executeBatch(bmu);
        
        BatchMobileTotalUsage bmu2 = new BatchMobileTotalUsage (setOfIds);
        Database.executeBatch(bmu2);
        Test.stopTest();
    }
}