/*------------------------------------------------------------------------------------
 Author:        Mahith Madwesh
 Description:   Account Data Visibility Service

 History
 Date            Author                Comments
 ---------------------------------------------------------------------------------------
 02-12-2019      Mahith Madwesh        Initial Release
 -------------------------------------------------------------------------------------*/
public without sharing class AccountDataVisibilityService {
	/**
	 Author: Mahith Madwesh
	 Company: Salesforce
	 Description: Method to temporary share account record with current user
	 Inputs: phoneNumber - phone number which is used to search person account
	 Returns: Account Id
	 Note: 1) User should be redirected to account page post retrieving a valid account id
	 2) Method will return null if no account match found, in this case user should be redirected to lead creation page
	 **/
	@AuraEnabled
	public static Id processAccountAccess(string phoneNumber) {
		Id accountId;
		try {
			String soslAccountQuery = 'Find {' + phoneNumber + '*} IN ALL FIELDS RETURNING Account(Id, Name, PersonMobilePhone WHERE PersonMobilePhone LIKE \'%' + phoneNumber + '\')';
			List<Account> accounts = (List<Account>) Search.query(soslAccountQuery).get(0);

			if(!accounts.isEmpty()) {
				accountId = accounts.get(0).Id;

				Set<Id> accountIds = new Set<Id>();
				accountIds.add(accountId);

				Map<Id, Boolean> accountAccessMap = CustomerRecordVisibilityUtility.checkIfCustomerRecordAccessExsists(accountIds);

				if(!accountAccessMap.get(accountId)) {
					Account userAccount = [SELECT Id, Account.Parent_Group__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Account;

					insert new Customer_Visibility__c(Dealer_Public_Group_Name__c = userAccount != null ? userAccount.Parent_Group__c :null,
												      Related_User__c = UserInfo.getUserId(),
												      Transaction_Type__c = System.label.Transaction_Type_DATA,
												      Transaction_Date__c = System.now(),
												      Start_Datetime__c = System.now(),
												      End_Datetime__c = System.now().addDays(3),
												      Customer_Account__c = accountId,
												      Access_Processing_Status__c = System.label.Access_Process_Status_Success,
												      Do_Not_Sync__c = true);
				}
			}
		} catch(exception e) {
			system.debug('DataVisibilityService.processAccountAccess: The following exception has happened: ' + e.getMessage());
		}
		//Note: Method will return null if no account match found, in this case user should be redirected to lead creation page
		return accountId;
	}

    //This method Check if the current Account Id passed as a parameter has customer visibility access shared else displays debug message "Customer Record Shared"
	public static Id createCustomerVisibilityRecord(string currentAccountId) {
        if(String.isNotBlank(currentAccountId)){
		Set<Id> accountIds = new Set<Id>();
		accountIds.add(currentAccountId);
		Map<Id, Boolean> accountAccessMap = CustomerRecordVisibilityUtility.checkIfCustomerRecordAccessExsists(accountIds);
		if(!accountAccessMap.get(currentAccountId)) {
			Account userAccount = [SELECT Id, Account.Parent_Group__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Account;

			insert new Customer_Visibility__c(Dealer_Public_Group_Name__c = userAccount != null ? userAccount.Parent_Group__c :null,
												      Related_User__c = UserInfo.getUserId(),
												      Transaction_Type__c = System.label.Transaction_Type_DATA,
												      Transaction_Date__c = System.now(),
												      Start_Datetime__c = System.now(),
												      End_Datetime__c = System.now().addDays(3),
												      Customer_Account__c = currentAccountId,
												      Access_Processing_Status__c = System.label.Access_Process_Status_Success,
												      Do_Not_Sync__c = true);
			System.debug('Customer Record Shared');
		}else{
            system.debug('Customer Record Already Shared');
        }
        }
        return currentAccountId;
	}


    //This method takes TaskId and AccountId
    //If customerId is present then AccountDataVisibilityService.createCustomerVisibilityRecord(currentAccountId) is called to share access
    //Else if TaskId alone is shared then, with SOQL, current Contact_ID__c is fetched and then shared access with AccountDataVisibilityService.createCustomerVisibilityRecord(currentAccountId)
	@AuraEnabled
	public static Id grantCustomerAccountAccess(String customerTaskId, String customerAccountId) {
		Id accountId;
		try {
			if(String.isNotBlank(customerAccountId)) {
                accountId  = AccountDataVisibilityService.createCustomerVisibilityRecord(customerAccountId);
			} else {
				if(String.isNotBlank(customerTaskId)) {
					Task currentCustomer = [SELECT Id, Contact_ID__c, WhatId FROM Task WHERE Id = :customerTaskId LIMIT 1].get(0);
					accountId = AccountDataVisibilityService.createCustomerVisibilityRecord(currentCustomer.Contact_ID__c);
				}
			}


		} catch(Exception ex) {
			system.debug('DataVisibilityService.grantCustomerAccountAccess: The following exception has happened: ' + ex.getMessage());
		}
		return accountId;

	}
}