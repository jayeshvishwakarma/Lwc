@isTest
public class AccountTriggerHandlerTest {
    
    @testsetup
    static void CreateRecord(){
        list<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(2, accList[0].Id);
        insert conList;
        
        list<User> spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;
        
        for(Account acc : accList){
            acc.Dealer_Administrator__c = spocUser[0].id;
        }
        update accList;
    }

    @isTest 
    static void checkUpperCaseInsertMethod(){
        list<Account> personAccountList = new list<Account>([SELECT id from Account where isPersonAccount = true]);
        String Last_Name = [SELECT lastName FROM Account WHERE Id=:personAccountList[0].Id].lastName;
        System.assertEquals('ACCOUNT', Last_Name);
        for(Account acc : personAccountList){
            acc.LastName = 'lead';
        }
        update personAccountList;
        String Last_Name2 = [SELECT lastName FROM Account WHERE Id=:personAccountList[0].Id].lastName;
        System.assertEquals('LEAD',Last_Name2);
    }
    
    @isTest
    static void enableDealerAdminPermissionTest(){
        list<user> spocUser = new list<user>([SELECT id from user]);
        list<Account> DealerAccountList = new list<Account>([SELECT id from Account where isPersonAccount =false]);

        System.runAs(spocUser[0]){
            for(Account acc : DealerAccountList){
                acc.lastmodified_svoc_time_stamp__c = 'test';
            }
            update DealerAccountList;
        }       
    }
}