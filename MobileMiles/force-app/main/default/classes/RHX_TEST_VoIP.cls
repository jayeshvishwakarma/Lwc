@isTest(SeeAllData=true)
public class RHX_TEST_VoIP {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM VoIP__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new VoIP__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}