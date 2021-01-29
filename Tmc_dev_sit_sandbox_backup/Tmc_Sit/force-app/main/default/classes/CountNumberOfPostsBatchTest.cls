@isTest
public class CountNumberOfPostsBatchTest {
    static testMethod void testMethod1(){
        
        List<Profile> profileList= [select id, name from Profile WHERE Name = 'Dealer Sales Executive' OR Name = 'Dealer CEO/Owner'];
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        forCodeList[0].Name = 'Delhi';
        insert forCodeList;
        
        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(2, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Parent_Group__c = 'abc';        
        accList[0].Region_Code__c= 'E1'; 
        accList[0].Dealer_Code__c= 'Ert';
        accList[0].Channel__c = 'NRM';
        accList[1].For_Code__c = forCodeList[0].Id;
        accList[1].Parent_Group__c = 'abc';        
        accList[1].Region_Code__c= 'E1'; 
        accList[1].Dealer_Code__c= 'Erre';
        accList[1].Channel__c = 'EXC';
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(2, accList[0].Id);
        conList[0].FirstName = 'abc';
        conList[0].LastName = 'abc';
        conList[0].MiddleName = 'abc';
        conList[0].Title = 'Mr.';        
        conList[0].MobilePhone = '9747453765';
        conList[1].FirstName = 'abc';
        conList[1].LastName = 'abc';
        conList[1].MiddleName = 'abc';
        conList[1].Title = 'Mr.';        
        conList[1].MobilePhone = '9747453765';
        insert conList;
        
        List<Contact> conList1 = TestDataFactory.createTestContact(1, accList[1].Id);
        conList1[0].FirstName = 'abc';
        conList1[0].LastName = 'abc';
        conList1[0].MiddleName = 'abc';
        conList1[0].Title = 'Mr.';        
        conList1[0].MobilePhone = '9747453765';
        
        insert conList1;
        if(profileList.size() > 0){
            Test.startTest();
            List<User> userList = new List<User>();
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList[0].Id, 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = profileList[0].Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));
            
            User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList[1].Id, 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileList[1].Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));
            
            User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList1[0].Id, 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileList[1].Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));
            userList.add(u);
            userList.add(u1);
            userList.add(u2);
            TriggerHandler.bypass('UserTriggerHandler');
            insert userList; 
            TriggerHandler.clearBypass('UserTriggerHandler');
            
            Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('User Account').getRecordTypeId();
            List<Account> userAccountList = new List<Account>();
            Account ac = new Account();
            ac.Name = 'TestuserAccount';
            ac.User__c = userList[0].Id;
            ac.RecordTypeId = AccRecTypeId;
            userAccountList.add(ac);
            
            Account ac1 = new Account();
            ac1.Name = 'TestuserAccount';
            ac1.User__c = userList[1].Id;
            ac1.RecordTypeId = AccRecTypeId;
            userAccountList.add(ac1);
            
            insert userAccountList;
            
            
            
            Network nk = [select id from Network where Name like 'Dealer%' limit 1];
            CollaborationGroup cGroup = new CollaborationGroup();
            cGroup.NetworkId = nk.Id;
            cGroup.Name = 'testGroup';
            cGroup.CollaborationType = 'Unlisted';
            insert cGroup;
            List<FeedItem> feedItemList = new List<FeedItem>();
            FeedItem FI = new FeedItem(Body = 'Test', ParentId = cGroup.Id,NetworkScope = nk.id, createdbyId = userList[0].Id );
            feedItemList.add(FI);
            FeedItem FII = new FeedItem(Body = 'Test daf', ParentId = cGroup.Id,NetworkScope = nk.id, createdbyId = userList[1].Id );
            feedItemList.add(FII);
            insert feedItemList;
            
            //CountNumberOfPostsBatch b = new CountNumberOfPostsBatch();
            //Database.executeBatch(b)
            //
            String CRON_EXP = '0 0 0 15 3 ? *';
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new CountNumberOfPostsBatchScheduler());
            Test.stopTest();
        }
    }
    
}