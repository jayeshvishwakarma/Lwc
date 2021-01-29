@isTest
public class AccountTest {
	@testSetup
    private static void setupMockData()
    {
        List<Account> lstAccounts=Test.loadData(Account.sobjectType,'AccountsMockData');
    }
    
    @isTest
    private static void createContactByContactInformation()
    {
        List<Account> lstAccounts=[SELECT id,Contact_information__C 
                                   FROM Account
                                  ];
        Database.update(lstAccounts);
    }
}