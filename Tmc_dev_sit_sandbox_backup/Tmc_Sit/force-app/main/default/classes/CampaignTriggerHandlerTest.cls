@isTest
public class CampaignTriggerHandlerTest {
    
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
        
        list<AccountTeamMember> createAccountTeamMember = TestDataFactory.createAccountTeamMember(1,spocUser0[0].id);
        createAccountTeamMember[0].AccountId = objList[0].Id;
        insert createAccountTeamMember;
        
        list<Campaign> CampaignList = TestDataFactory.createCampaign(1);
        for(Campaign cp :CampaignList){
            cp.Ownerid = spocUser0[0].Id;
        }
        insert CampaignList;
    }
    
    
    @isTest
    static void testInsert(){
        list<AccountTeamMember> atmList = new list<AccountTeamMember>([SELECT id,UserId from AccountTeamMember]);
        list<CampaignShare> camshare = new list<CampaignShare>([SELECT id,UserOrGroupId from CampaignShare WHERE UserOrGroupId=:atmList[0].UserId]);
        for(CampaignShare cs : camshare){
            System.assertEquals(cs.UserOrGroupId, atmList[0].UserId);
        }
    }
    
    
    @isTest
    static void testUpdate(){
        Test.startTest();
        list<AccountTeamMember> atmList = new list<AccountTeamMember>([SELECT id,UserId from AccountTeamMember]);
        list<Campaign> CampaignList = new list<Campaign>([SELECT id,ownerId from Campaign]);
        list<user> runAsUser = new list<user>([SELECT id from user where Id =:CampaignList[0].OwnerId]);
        list<user> dseUser = new list<user>([SELECT id from user where ManagerId =:runAsUser[0].Id]); 
        
        System.runAs(runAsUser[0]){ 
            for(Campaign cp: CampaignList){
                cp.OwnerId = dseUser[0].Id;
            } 
            
            update CampaignList;
            
            list<CampaignShare> camshare = new list<CampaignShare>([SELECT id,UserOrGroupId from CampaignShare WHERE UserOrGroupId=:atmList[0].UserId]);
            for(CampaignShare cs : camshare){
                System.assertEquals(cs.UserOrGroupId, atmList[0].UserId);
            } 
        }
        Test.stopTest();
    }
}