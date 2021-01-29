@isTest(SeeAllData=true)
public class RHX_TEST_Mobile_Miles_Dienst {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM Mobile_Miles_Dienst__c order by lastmodifieddate desc LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Mobile_Miles_Dienst__c()
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}