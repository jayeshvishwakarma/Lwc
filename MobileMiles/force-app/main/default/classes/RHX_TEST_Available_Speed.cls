@isTest(SeeAllData=true)
public class RHX_TEST_Available_Speed {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Available_Speed__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Available_Speed__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}