@isTest
public class ChangeOwnerFunctionalityTest {
    
    @testSetup
    static void CreateRecords(){
		// Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
		
        List<Account> accList1 = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert accList1;  
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = UserInfo.getUserId();
        
        
        insert oppList;
        
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        
        list<User> userList = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert userList;
    }
    
    
    @isTest
    static void test1(){
        test.startTest();
        
        List<Account> accList1 = new list<Account>([SELECT id from Account]);
        List<opportunity> oppList = new list<opportunity>([SELECT id from opportunity]);
        
        ChangeOwnerFunctionality.checkLoggedinUserType(oppList[0].Id);
        
        List<user> userList = new list<User>([SELECT id from user]);
        ChangeOwnerFunctionality.getUserList(accList1[0].Id,'Test');
        
        ChangeOwnerFunctionality.changeOwner(oppList[0].Id,userList[0].Id);
        
        test.stopTest();
    }
    
    @isTest
    static void test2(){
        test.startTest();
        
        List<Account> accList1 = new list<Account>([SELECT id from Account]);
        List<opportunity> oppList = new list<opportunity>([SELECT id from opportunity]);
        List<Contact> conList = TestDataFactory.createTestContact(1, accList1[0].Id);
        insert conList;
        
        list<User> userList = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert userList;
        system.runAs(userList[0]){
            ChangeOwnerFunctionality.checkLoggedinUserType(oppList[0].Id);
            
            
            ChangeOwnerFunctionality.getUserList(accList1[0].Id,'Test');
            
            try{
                oppList[0].id= null;
                ChangeOwnerFunctionality.changeOwner(oppList[0].Id,userList[0].Id);
            }catch(exception ex){
                system.debug('exception');
            }
        }
        test.stopTest();
    }
}