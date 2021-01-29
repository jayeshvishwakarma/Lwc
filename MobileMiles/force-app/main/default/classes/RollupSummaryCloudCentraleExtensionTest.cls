/**
 * @Purpose       : Test class for "RollupSummaryOnCloudExtension" apex class
 * @Created Date  : 21-04-2014
 * @Modified Date : [21-04-2014]
**/
@isTest
public class RollupSummaryCloudCentraleExtensionTest {
    
    //--@Called From : 
    //--@Purpose     : Insert test data (records of Account, Cloud Centrale and Cloud Users)
    public static Cloud_Centrale__c insertTestData()
    {
        // Insert Account record
		Account testAccount = new Account(Name = 'Test Account #1');
        insert testAccount;
        
        // Insert Cloud Centrale record
        Cloud_Centrale__c testCloudCentralRec = new Cloud_Centrale__c(Name = 'Test Cloud Centrale #1');
        insert testCloudCentralRec;
        
        // Insert Cloud Users records
        List<Cloud_Gebruikers__c> testCloudUserList = new List<Cloud_Gebruikers__c>();
        
        testCloudUserList.add(new Cloud_Gebruikers__c(Name = 'Test User #1', Cloud_Centrale__c = testCloudCentralRec.Id, 
                                                      Account__c = testAccount.Id, Licenties__c = 'Knatoor',
                                                      Gebruikersopties__c = 'Receptionist Premium;Groepsgesprek; Software integratie outlook'));
        testCloudUserList.add(new Cloud_Gebruikers__c(Name = 'Test User #2', Cloud_Centrale__c = testCloudCentralRec.Id, 
                                                      Account__c = testAccount.Id, Licenties__c = 'Knatoor',
                                                      Gebruikersopties__c = 'Software integratie outlook'));
		testCloudUserList.add(new Cloud_Gebruikers__c(Name = 'Test User #3', Cloud_Centrale__c = testCloudCentralRec.Id, 
                                                      Account__c = testAccount.Id, Licenties__c = 'Knatoor',
                                                      Gebruikersopties__c = 'Groepsgesprek;4000 MB Data'));        

		insert testCloudUserList;   
        
        return testCloudCentralRec;
    } 
    
    public static testMethod void testRollupSummaryOnCloudCentraleExtesnion()
    {
        Cloud_Centrale__c testCloudCentraleRec = insertTestData();
        
        // Set page reference for testing
        PageReference pageRef = new PageReference('/apex/RollupSummaryOnCloudCentrale?id=' + testCloudCentraleRec.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        
        // Instantiate the extension
        Apexpages.StandardController stdController = new Apexpages.standardController(testCloudCentraleRec);         
        RollupSummaryOnCloudCentraleExtension extensionObj = new RollupSummaryOnCloudCentraleExtension(stdController);

        extensionObj.caluculateRollupSummaryFields(); 	
		
        // Build Map of expected values
        Map<String, Integer> expectedRollupField = new Map<String, Integer>();
        expectedRollupField.put('Receptionist Premium', 1);
        expectedRollupField.put('Groepsgesprek', 2);
        expectedRollupField.put('Software integratie outlook', 2);
		expectedRollupField.put('4000 MB Data', 1);        
                
        // Verify that rollup summary field are properly calculated or not   
		System.assertEquals(extensionObj.rollupFields[0].fieldValue, expectedRollupField.get(extensionObj.rollupFields[0].fieldName));
		System.assertEquals(extensionObj.rollupFields[1].fieldValue, expectedRollupField.get(extensionObj.rollupFields[1].fieldName));        
		System.assertEquals(extensionObj.rollupFields[2].fieldValue, expectedRollupField.get(extensionObj.rollupFields[2].fieldName));        
        System.assertEquals(extensionObj.rollupFields[3].fieldValue, expectedRollupField.get(extensionObj.rollupFields[3].fieldName));        
            
        Test.stopTest();
    }
}