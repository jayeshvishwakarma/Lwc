/*------------------------------------------------------------------------------------
 Author:        Mahith Madwesh
 Description:   Account Data Visibility Service Test

 History
 Date            Author                Comments
 --------------------------------------------------------------------------------------
 02-12-2019      Mahith Madwesh        Initial Release
 ------------------------------------------------------------------------------------*/
@isTest
private class AccountDataVisibilityServiceTest {
	@isTest static void processAccountAccessTest() {
		Test.startTest();

    Bypass_Setting__c bs = new Bypass_Setting__c();
        bs.Bypass_Triggers__c = 'UserTriggerHandler';
        insert bs;


		 User spocUser = createUsers('Dealer Hostess').get(0);
		 insert spocUser;

        Account dealerUser = AccountDataVisibilityServiceTest.createBusinessAccount(1).get(0);
        insert dealerUser;



		Account customerAccounts;

		System.runAs(spocUser) {

            customerAccounts = AccountDataVisibilityServiceTest.createPersonAccount(1).get(0);
            insert customerAccounts;
			// insert newAccount;
		}

		List<Id> fixedSearchResults = new List<Id>();
		fixedSearchResults.add(customerAccounts.Id);
		Test.setFixedSearchResults(fixedSearchResults);

		Id accId = AccountDataVisibilityService.processAccountAccess(customerAccounts.PersonMobilePhone);
		System.assertEquals(customerAccounts.Id, accId);

		accId = AccountDataVisibilityService.processAccountAccess(null);
		System.assertEquals(null, accId);

		Decimal recordsCount = [SELECT Count() FROM AccountShare WHERE AccountId = :customerAccounts.Id AND UserOrGroupId = :UserInfo.getUserId()];
		System.assertEquals(1, recordsCount);

		Test.stopTest();
	}

	@isTest static void createCustomerVisibilityRecordTest() {
		Test.startTest();

    Bypass_Setting__c bs = new Bypass_Setting__c();
        bs.Bypass_Triggers__c = 'UserTriggerHandler';
        insert bs;

		User spocUser = createUsers('Dealer Hostess').get(0);
		insert spocUser;

		Account customerAccounts;

		System.runAs(spocUser) {

				 customerAccounts = AccountDataVisibilityServiceTest.createPersonAccount(1).get(0);
            insert customerAccounts;
		}

		List<Id> fixedSearchResults = new List<Id>();
		fixedSearchResults.add(customerAccounts.Id);
		Test.setFixedSearchResults(fixedSearchResults);

		Id accId = AccountDataVisibilityService.createCustomerVisibilityRecord(customerAccounts.Id);
		System.assertEquals(customerAccounts.Id, accId);

		accId = AccountDataVisibilityService.createCustomerVisibilityRecord(null);
		System.assertEquals(null, accId);

		Decimal recordsCount = [SELECT Count() FROM AccountShare WHERE AccountId = :customerAccounts.Id AND UserOrGroupId = :UserInfo.getUserId()];
		System.assertEquals(1, recordsCount);

		Test.stopTest();
	}

	@isTest static void grantCustomerAccountAccessTest() {
		Test.startTest();
		Id TaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PSF_Follow_Up').getRecordTypeId();

    Bypass_Setting__c bs = new Bypass_Setting__c();
        bs.Bypass_Triggers__c = 'UserTriggerHandler';
        insert bs;


		User spocUser = createUsers('Dealer Hostess').get(0);
		insert spocUser;

		Account customerAccounts;
        Task newTask;

		System.runAs(spocUser) {
		 customerAccounts = AccountDataVisibilityServiceTest.createPersonAccount(1).get(0);
            insert customerAccounts;
				newTask = new Task(RecordTypeId = TaskRecordType,
							   OwnerId= spocUser.Id,
							   WhatId = customerAccounts.Id,
							   Status= 'Open',
							   Priority= 'Normal',
							   Disposition__c = 'Phone not available');

            insert newTask;
		}

		List<Id> fixedSearchResults = new List<Id>();
		fixedSearchResults.add(customerAccounts.Id);
		Test.setFixedSearchResults(fixedSearchResults);

        List<Id> fixedSearchResults1 = new List<Id>();
		fixedSearchResults1.add(newTask.Id);
		Test.setFixedSearchResults(fixedSearchResults1);

		Id accId = AccountDataVisibilityService.grantCustomerAccountAccess(newTask.Id,customerAccounts.Id);
		System.assertEquals(customerAccounts.Id, accId);

        // Id accId1 = AccountDataVisibilityService.grantCustomerAccountAccess(newTask.Id,null);
		// System.assertEquals(customerAccounts.Id, accId1);

        Id accId2 = AccountDataVisibilityService.grantCustomerAccountAccess(null,customerAccounts.Id);
		System.assertEquals(customerAccounts.Id, accId2);

		accId = AccountDataVisibilityService.grantCustomerAccountAccess(null,null);
		System.assertEquals(null, accId);

		Decimal recordsCount = [SELECT Count() FROM AccountShare WHERE AccountId = :customerAccounts.Id AND UserOrGroupId = :UserInfo.getUserId()];
		System.assertEquals(1, recordsCount);

		Test.stopTest();
	}


 // This method is used to create Customer /person Account(s) //
    public static List<Account> createPersonAccount(Integer numAccts){
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='TEST',LastName='ACCOUNT',PersonMobilePhone='6888585565');
            a.RecordTypeId=customerRecTypeId;
            accts.add(a);
        }
        //insert accts;
        return accts;
    }


    // This method is used to create Dealer /Business Account(s)
    public static List<Account> createBusinessAccount(Integer numAccts){
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();

        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='ACCOUNT');
            a.RecordTypeId=customerRecTypeId;
            accts.add(a);
        }
        //insert accts;
        return accts;
    }








	// This method is used create Users//
	public static List<User> createUsers(String ProfileName) {
		// Insert Users
		Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();

		List<For_Code__c> forCodeList = createTestForCode(1);
		Insert forCodeList;

		Account acc = new Account(Name = 'TestAccount', RecordTypeId = AccRecTypeId, For_Code__c = forCodeList [0].Id);
		insert acc;

		List<Contact> conlist = new list<Contact>();
		List<User> userlist = new list<User>();

		Profile p = [SELECT Id FROM Profile WHERE Name = :ProfileName];

		for(Integer i = 1; i <= 2; i ++) {
			Contact con = new Contact(LastName = 'TestAcc' + i, AccountId = acc.Id);
			conlist.add(con);
		}
		insert conlist;

		//Create another user for the managerId in other user.

		system.debug('== conlist ' + conlist);

		//Insert Portal user
		for(Contact cont :conlist) {
			User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
						      EmailEncodingKey= 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', Title = ProfileName == 'Dealer Sales Executive' ? label.Sales_Executive :'Team Lead',
						      LocaleSidKey= 'en_US', ProfileId = p.Id, ContactId = cont.Id,
						      TimeZoneSidKey= 'America/Los_Angeles', UserName = 'standarduser@testorg.com' + String.valueOf(Math.random()));

			userlist.add(u);
		}
		System.debug('== userlist ' + userlist);
		return userlist;
	}

	// This method is used to create For Code // (By: Anuj )
	public static List<For_Code__c> createTestForCode(Integer numOfRec) {
		List<For_Code__c> forCode = new List<For_Code__c>();

		for(Integer i = 0; i < numOfRec; i ++) {
			For_Code__c fcode = new For_Code__c(Name = 'Central For Code ' + i,
											    Zone_Code__c = 'Central',
											    Region_Code__c = 'C2',
											    For_Code__c = 'FC-1234' + string.valueOf(system.now()));
			forCode.add(fcode);
		}

		return forCode;
	}
}