@isTest(seeAlldata=False)
public class GenerateFilePublicURLTest {
    @testSetup
    static void CreateRecords(){
    Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('OpportunityVehicleTriggerServiceImpl', 'Vehicle_Sales');
        ImplementationStrategyRecord1.Use_Case__c = 'OpportunityTriggers';
        insert ImplementationStrategyRecord1;
        
        list<ContentVersion> ContentVersionlist = TestDataFactory.createContentversion(1);
        insert ContentVersionlist;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        insert opplist;
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        
        list<User> spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;
    }
    
    
    
    @isTest
    static void CreateMCRecordTestMethod(){
        Set<id> oppSet = new set<id>();
        list<opportunity> opplistt = new list<opportunity>([SELECT id,Customer__c from opportunity]);
        for(opportunity opp : opplistt){
            oppset.add(opp.id);
        }
        
        list<User> spocUser = new list<user>([SELECT id from user]);
        System.runAs(spocUser[0]){
           GenerateFilePublicURL.baseURL(); 
        }
        list<ContentVersion> ContentVersionlist = new list<ContentVersion>([SELECT id from ContentVersion]);
        GenerateFilePublicURL.CreateAttachmentPublicLink(ContentVersionlist[0].id);
        list<contentDistribution> contentDistributionList = new list<contentDistribution>([SELECT id,DistributionPublicUrl from contentDistribution]);
        
        GenerateFilePublicURL.CreateMCRecord('BCR', oppSet,'Opportunity', contentDistributionList[0].DistributionPublicUrl);
        list<mc_communication__c> mcList = new list<mc_communication__c>([SELECT id from mc_communication__c]);
        System.assertEquals(mcList.size(), 1);
        GenerateFilePublicURL.CreateMCRecord('Send Brochure', oppSet,'Opportunity', contentDistributionList[0].DistributionPublicUrl);
        list<mc_communication__c> mcList2 = new list<mc_communication__c>([SELECT id from mc_communication__c]);
       // System.assertEquals(mcList2.size(), 2);
       // GenerateFilePublicURL.CreateMCRecord('Escalation', oppSet,'Opportunity', contentDistributionList[0].DistributionPublicUrl);
    }
    
   
}