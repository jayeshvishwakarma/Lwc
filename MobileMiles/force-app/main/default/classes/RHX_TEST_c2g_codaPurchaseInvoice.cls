@isTest(SeeAllData=true)
public class RHX_TEST_c2g_codaPurchaseInvoice {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM c2g__codaPurchaseInvoice__c order by lastmodifieddate desc LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new c2g__codaPurchaseInvoice__c()
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}