@isTest(SeeAllData=true)
public class TEST_RHX {
    
    static testMethod void Mobiele_aansluiting() {
        
        List<sObject> sourceList = [SELECT Id
                                FROM Mobiele_aansluiting__c
                                LIMIT 1];

        if(sourceList.size() == 0) {
            sourceList.add(
                    new Mobiele_aansluiting__c()
                );
        }
    Database.upsert(sourceList);        
    }

}