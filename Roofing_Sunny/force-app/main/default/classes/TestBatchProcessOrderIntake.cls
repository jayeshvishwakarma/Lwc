/*********************************************************************************
* Test Class: {TestBatchProcessOrderIntake}
* Updated by {Abhishek Pareek}, Navivo, {DateCreated 12/24/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of BatchProcessOrderIntake.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/24/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestBatchProcessOrderIntake {

    static testMethod void methodA() {
       
        
        BatchProcessOrderIntake bpoi = new BatchProcessOrderIntake();
        User TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm@user.com', 'TM USER', 'testTm@user.com', 'TM', true);
        User RVPUser = TestClassUtility.createTestUser('System Administrator Integration', 'RVPUSR', 'testRvp@user.com', 'RVP USER', 'testRvp@user.com', 'RVP', true);
        
        List<Region__c> regions = new List<Region__c>();
        regions.add(TestClassUtility.createRegion('TestClass1','TC1',false));
        regions.add(TestClassUtility.createRegion('TestClass2','TC2',false));
        insert regions;
        
        List<Territory__c> territories = new List<Territory__c>();
        territories.add(TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial', regions.get(0).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR2', 'TRR2','Residential', regions.get(0).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR3', 'TRR3','Commercial', regions.get(1).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR4', 'TRR4','Residential', regions.get(1).Id, false));
        insert territories;
        
        //bpoi.soql = 'Select t.Type__c, t.Territory_Code__c, t.Region__c, t.Name, t.Id From Territory__c t';
        Database.executeBatch(bpoi,5);
    }
    
    static testMethod void methodB() {
       
        
        BatchProcessOrderIntake bpoi = new BatchProcessOrderIntake();
        User TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm@user.com', 'TM USER', 'testTm@user.com', 'TM', true);
        User RVPUser = TestClassUtility.createTestUser('System Administrator Integration', 'RVPUSR', 'testRvp@user.com', 'RVP USER', 'testRvp@user.com', 'RVP', true);
        
        List<Region__c> regions = new List<Region__c>();
        regions.add(TestClassUtility.createRegion('TestClass1','TC1',false));
        regions.add(TestClassUtility.createRegion('TestClass2','TC2',false));
        insert regions;
        
        List<Territory__c> territories = new List<Territory__c>();
        territories.add(TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial', regions.get(0).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR2', 'TRR2','Residential', regions.get(0).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR3', 'TRR3','Commercial', regions.get(1).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR4', 'TRR4','Residential', regions.get(1).Id, false));
        insert territories;
        
      /*  List<Hierarchy_Matrix__c> hierarchy = new List<Hierarchy_Matrix__c>();
        for(Integer i=0; i<4; i++){
            hierarchy.add(TestClassUtility.createHierarchyMatrix(territories.get(i).Id, TMUser.Id, null, null, null, RVPUser.Id, false));
        }
        insert hierarchy;
    */
        //bpoi.soql = 'Select t.Type__c, t.Territory_Code__c, t.Region__c, t.Name, t.Id From Territory__c t';
        Database.executeBatch(bpoi,5);
    }
}