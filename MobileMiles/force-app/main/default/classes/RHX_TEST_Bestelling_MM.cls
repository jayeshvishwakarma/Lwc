@isTest(SeeAllData=true)
public class RHX_TEST_Bestelling_MM {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM Bestelling_MM__c ORDER BY lastmodifieddate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Bestelling_MM__c()
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}