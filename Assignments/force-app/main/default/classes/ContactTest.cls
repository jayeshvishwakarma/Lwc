@isTest
public class ContactTest {
    
    @testSetup
    private static void setup()
    {
        List<Account> lstAccountsMockData=Test.loadData(Account.sObjectType,'AccountsMockData');
        List<Contact> lstContactsMockData=Test.loadData(Contact.sobjectType,'ContactsMockData');
    }
    @isTest
    private static void sumOFAmounts(){
        Test.startTest();
        List<Contact> lstContacts=[SELECT id,Amount_x__c,Amount_y__C,Type__C
                                   FROM Contact
                                  ];
        Database.update(lstContacts);
        Test.stopTest();
    }
    
   @istest
    private static void needIntel()
    {
        Test.startTest();
        List<Contact> lstContacts=[SELECT id,AccountId,Dead__C
                                   FROM Contact
                                  ];
        
        List<Account> lstAccounts=[SELECT id,Need_Intel__C
                                   FROM Account
                                  ];
        
        Database.update(lstContacts);
    }
}