@isTest
public class AccountTriggerHandlerTest {
    
    @testsetup
    static void CreateRecord(){
	
		// Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
		
        list<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        personAccountList[0].SVOC_ID__c = '12463526';
        insert personAccountList;
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        String ProfileName = 'Dealer Sales Executive';
        String profileId = '00e7F000002L37u';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                  Title=ProfileName=='Dealer Sales Executive' ? label.Sales_Executive : 'Team Lead',
                  LocaleSidKey='en_US', ProfileId = profileId, 
                  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));
        insert u;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(3, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Territory_Sales_Manager__c = u.Id;
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(2, accList[0].Id);
        insert conList;
        
        list<User> spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;
        
        for(Account acc : accList){
            acc.Dealer_Administrator__c = spocUser[0].id;
            acc.Territory_Sales_Manager__c = spocUser[0].id;
        }
        update accList;
		
			accList[2].Territory_Sales_Manager__c  = null;
        update accList[2];
        //Create Vehicle Enquiry
        String recortype = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].StageName = 'New';
        oppList[0].ownerId = label.Integration_user;
        for(Opportunity opp : opplist){
            opp.Dealership__c = accList[0].Id;
            opp.Accessories_DSE1__c = spocUser[0].id;
            opp.Type_of_Escalation__c = 'DSE Allocation Time';
            opp.Time_for_Next_Escalation__c = DateTime.newInstance(2019, 11, 15, 11, 25, 33);
            opp.RecordTypeId = recortype;
        }
        insert opplist;
        
        OpportunityTeamMember oppteamMember = new OpportunityTeamMember();
        oppteamMember.OpportunityId = opplist[0].Id;
        oppteamMember.UserId = u.Id;
        insert oppteamMember;
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
    
    @isTest 
    static void checkSVOCUniquesnessUpdate(){
        Test.startTest();
        String error;
        try
        {
        list<Account> personAccountList = new list<Account>([SELECT id from Account where SVOC_Id__c != '12463526' limit 1]);
        personAccountList[0].SVOC_Id__c = '12463526';
        update personAccountList;
        }
        catch(Exception e){ 
        error =e.getMessage();
        }
       system.assertNotEquals(null,error); 
        Test.stopTest();
    }
    
    @isTest 
    static void checkSVOCUniquesnessInsert(){
        Test.startTest();
        String error;
        try
        {
        list<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        personAccountList[0].SVOC_ID__c = '12463526';
        insert personAccountList;
        }
        catch(Exception e){ 
        error =e.getMessage();
        }
       system.assertNotEquals(null,error); 
        Test.stopTest();
    }
	@isTest 
    static void addRemoveTSMToEnquiryBatchTest(){
        Test.startTest();
        addRemoveTSMToEnquirySchedule myClass = new addRemoveTSMToEnquirySchedule();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }
}