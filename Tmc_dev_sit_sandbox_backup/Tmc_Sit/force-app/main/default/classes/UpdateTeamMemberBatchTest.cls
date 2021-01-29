@isTest
public class UpdateTeamMemberBatchTest {
    static list<user> spocUser0 = new list <user>();
    static set<id> setuserId = new set<id>();
    static list<User> dseUsers = new list<User>();
    static testmethod void test1() {        
        Test.startTest();
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
            
            spocUser0 = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', conList);
            insert spocUser0;
            
            List<Contact> dseconList = TestDataFactory.createTestContact(2, accList[0].Id);
            insert dseconList;
            
            dseUsers = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', dseconList);
            dseUsers[0].ManagerId = spocUser0[0].Id;
            insert dseUsers;
             
            list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
            objList[0].user__c = spocUser0[0].id;
            insert objList;
            
            list<Account> objList2 = TestDataFactory.createBusinessAccount(1,'User Account');
            objList2[0].user__c = dseUsers[0].id;
            insert objList2;
            
            list<AccountTeamMember> createAccountTeamMember = TestDataFactory.createAccountTeamMember(1,spocUser0[0].id);
            createAccountTeamMember[0].AccountId = objList[0].Id;
            //insert createAccountTeamMember; 
            
            list<AccountTeamMember> createAccountTeamMember1 = TestDataFactory.createAccountTeamMember(1,dseUsers[0].id);
            createAccountTeamMember1[0].AccountId = objList2[0].Id;
            insert createAccountTeamMember1;        
        
            UpdateTeamMember__c obj1 = new UpdateTeamMember__c();
            obj1.Name = '1';
            obj1.UserId__c = dseUsers[0].id;
            obj1.HierarchyUser__c = '0057F0000070TYu';
            Insert obj1;
            
            UpdateTeamMember__c obj2 = new UpdateTeamMember__c();
            obj2.Name = '1';
            obj2.UserId__c = dseUsers[0].id;
            obj2.HierarchyUser__c = spocUser0[0].Id;
            Insert obj2;
            
            UpdateTeamMemberBatch obj = new UpdateTeamMemberBatch();
            Database.executeBatch(obj ,100);
            
        Test.stopTest();
    }       
    
    static testmethod void test2() {        
        Test.startTest();
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
            
            spocUser0 = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', conList);
            insert spocUser0;
            
            List<Contact> dseconList = TestDataFactory.createTestContact(2, accList[0].Id);
            insert dseconList;
            
            dseUsers = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', dseconList);
            dseUsers[0].ManagerId = spocUser0[0].Id;
            insert dseUsers;
             
            list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
            objList[0].user__c = spocUser0[0].id;
            insert objList;
            
            list<Account> objList2 = TestDataFactory.createBusinessAccount(1,'User Account');
            objList2[0].user__c = dseUsers[0].id;
            insert objList2;
            
            list<AccountTeamMember> createAccountTeamMember = TestDataFactory.createAccountTeamMember(1,spocUser0[0].id);
            createAccountTeamMember[0].AccountId = objList[0].Id;
            //insert createAccountTeamMember; 
            
            list<AccountTeamMember> createAccountTeamMember1 = TestDataFactory.createAccountTeamMember(1,dseUsers[0].id);
            createAccountTeamMember1[0].AccountId = objList2[0].Id;
            //insert createAccountTeamMember1;        
        
            UpdateTeamMember__c obj1 = new UpdateTeamMember__c();
            obj1.Name = '1';
            obj1.UserId__c = dseUsers[0].id;
            obj1.HierarchyUser__c = '0057F0000070TYu';
            Insert obj1;
            
            UpdateTeamMember__c obj2 = new UpdateTeamMember__c();
            obj2.Name = '1';
            obj2.UserId__c = dseUsers[0].id;
            obj2.HierarchyUser__c = spocUser0[0].Id;
            Insert obj2;
            
            UpdateTeamMemberBatch obj = new UpdateTeamMemberBatch();
            Database.executeBatch(obj ,100);
            
        Test.stopTest();
    }  
}