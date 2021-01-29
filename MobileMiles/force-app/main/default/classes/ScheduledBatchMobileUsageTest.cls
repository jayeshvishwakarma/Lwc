@isTest
private class ScheduledBatchMobileUsageTest {
    @isTest static void testScheduler() {
        List<Porteringen_mobiel__c> pmList = new List<Porteringen_mobiel__c>();
        for(Integer i=0; i<100; i++){
            Porteringen_mobiel__c pm = new Porteringen_mobiel__c();
            pm.Name = 'Nieuw';
            pm.Type_aanvraag__c = 'Nieuw nummer';
            pm.IRMA_Id__c = 'Test' + i;
            pm.Datum_actief__c = System.today();
            pmList.add(pm);
        }
        insert pmList;
        Test.StartTest();
        ScheduledBatchMobileUsage sh1 = new ScheduledBatchMobileUsage(0);
        String sch = '0 0 23 * * ?';
        system.schedule('Test Schedule ScheduledBatchMobileUsage', sch, sh1);
        Test.stopTest();
    }
}