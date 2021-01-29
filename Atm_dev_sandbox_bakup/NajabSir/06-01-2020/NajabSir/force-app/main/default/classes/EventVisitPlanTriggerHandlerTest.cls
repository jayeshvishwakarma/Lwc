@isTest
public class EventVisitPlanTriggerHandlerTest {

    static list<user> spocUser0 = new list <user>();
    static set<id> setuserId = new set<id>();
    static list<User> dseUsers = new list<User>();



    @testSetup
    static void createMethod(){
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(3, accList[0].Id);
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
        
        
        list<AccountTeamMember> createAccountTeamMember = TestDataFactory.createAccountTeamMember(1,spocUser0[0].id);
        for(AccountTeamMember atm : createAccountTeamMember){
            atm.AccountId = objList[0].Id;
        } 
        insert createAccountTeamMember;
        
        
        list<Event_Visit_Plan__c> eventList = TestDataFactory.createEventsPlans(200);
        for(Event_Visit_Plan__c evp : eventList){
                evp.OwnerId = spocUser0[0].Id;
                evp.Assigned_Sales_Exec__c = spocUser0[0].Id;
        }
        insert eventList;
        
    }
    
    @isTest
    static void testInsert(){
        list<AccountTeamMember> atmList = new list<AccountTeamMember>([SELECT id,UserId from AccountTeamMember]);
        list<Event_Visit_Plan__share> eventList = new list<Event_Visit_Plan__share>([SELECT id,UserOrGroupId from Event_Visit_Plan__share WHERE UserOrGroupId=:atmList[0].UserId]);
        for(Event_Visit_Plan__share evp : eventList){
            System.assertEquals(evp.UserOrGroupId, atmList[0].UserId);
        }
    }
    
    @isTest
    static void testUpdate(){
        
        list<Event_Visit_Plan__c> eventList = new list<Event_Visit_Plan__c>([SELECT id,ownerId from Event_Visit_Plan__c]);
        list<user> runAsUser = new list<user>([SELECT id from user where Id =:eventList[0].OwnerId]);
        list<user> dseUser = new list<user>([SELECT id from user where ManagerId =:runAsUser[0].Id]);
        
        System.runAs(runAsUser[0]){
        
            for(Event_Visit_Plan__c ev : eventList){
                ev.OwnerId = dseUser[0].Id;
            }
        
        
            update eventList;
        }
        
        list<AccountTeamMember> atmList = new list<AccountTeamMember>([SELECT id,UserId from AccountTeamMember]);
        list<Event_Visit_Plan__share> eventshare = new list<Event_Visit_Plan__share>([SELECT id,UserOrGroupId from Event_Visit_Plan__share WHERE UserOrGroupId=:atmList[0].UserId]);
        for(Event_Visit_Plan__share evp : eventshare){
            System.assertEquals(evp.UserOrGroupId, atmList[0].UserId);
        }
     }
}