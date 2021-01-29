/*------------------------------------------------------------------------------------
 Author:        Mahith Madwesh
 Description:   Current Accunt Related Cases Controller

 History
 Date            Author                Comments
 --------------------------------------------------------------------------------------
 11-02-2020      Mahith Madwesh            Initial Release
 17-06-2020      Nitin Ghai                Added Status field
 ------------------------------------------------------------------------------------*/
public without sharing class CurrentAccuntRelatedCasesCtrl {
	@AuraEnabled(cacheable = true) public static List<Case> fetchData(Id recordId) {
		case currentCase = [Select Id, Customer__c FROM Case WHERE Id = :recordId LIMIT 1];
		List<Case> relatedCases = new List<Case>();
		if (currentCase != null && currentCase.customer__c != null){
		 relatedCases = [SELECT Id, AccountId, Account.Name, CaseNumber, Type, CreatedDate, ClosedDate, Expiry_Date__c,
                         Policy_No__c,Vehicle_Registration_Number__c,Status
								   FROM Case WHERE Customer__c = :currentCase.Customer__c AND RecordType.Name = 'MI renewal' and Id != :recordId];
		}
		return relatedCases;
	}
}