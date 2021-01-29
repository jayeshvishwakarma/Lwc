@isTest(seeAllData = false)
public class ProfileToChatterGroupsTest {
    @isTest
    static void validateChatterGroup1(){
        ToCreateChatterGroups.createChatterGroup();
    }
    @isTest
    static void validateChatterGroup2(){
        //Create Test Data
        List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
        
        Network nk = [select id from Network where Name like 'Dealer%' limit 1];
        CollaborationGroup cGroup = new CollaborationGroup();
        cGroup.NetworkId = nk.Id;
        cGroup.Name = 'Ert_abe_abc_sales';
        cGroup.CollaborationType = 'Unlisted';
        cGroupList.add(cGroup);
        
        CollaborationGroup cGroup1 = new CollaborationGroup();        
        cGroup1.Name = 'All RO E1 Sales Users';
        cGroup1.CollaborationType = 'Unlisted';
        cGroupList.add(cGroup1);
        
        CollaborationGroup cGroup2 = new CollaborationGroup();        
        cGroup2.Name = 'All Regional Employees Nexa';
        cGroup2.CollaborationType = 'Unlisted';
        cGroupList.add(cGroup2);
        
        insert cGroupList;
        
        List<Profile> profileList= [select id, name from Profile WHERE Name = 'Dealer Sales Executive' OR Name = 'Dealer CEO/Owner'];
        
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        forCodeList[0].Name = 'Delhi';
        forCodeList[0].For_Code__c = 'abe';
        
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
           
            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
            cGroupMember.MemberId = userList[0].Id;                        
            cGroupMember.CollaborationGroupId = cGroupList[0].Id;
            insert cGroupMember;
            
            ProfileToChatterGroupBatch1 obj = new ProfileToChatterGroupBatch1();
            Database.executeBatch(obj);
            
            String a = 'Dealer CEO/Owner';
            String b = 'Maruti Sales User';
            String c = 'Maruti Regional Manager';
            
            ProfileToChatterGroupBatch2 d = new ProfileToChatterGroupBatch2(a,b ,c);
            Database.executeBatch(d); 
            
           
            test.stopTest();
        } 
        
        
    }
    
    
    @isTest
    static void validateChatterGroup33(){
        //Create Test Data
        List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
        
        Network nk = [select id from Network where Name like 'Dealer%' limit 1];
        CollaborationGroup cGroup = new CollaborationGroup();
        cGroup.NetworkId = nk.Id;
        cGroup.Name = 'All E1 Dealers Nexa';
        cGroup.CollaborationType = 'Unlisted';
        cGroupList.add(cGroup);
        
        CollaborationGroup cGroup2 = new CollaborationGroup();
        cGroup2.NetworkId = nk.Id;
        cGroup2.Name = 'All E1 Dealers Arena';
        cGroup2.CollaborationType = 'Unlisted';
        cGroupList.add(cGroup2);
        
        
        
            
        insert cGroupList;
        
        List<Profile> profileList= [select id, name from Profile WHERE Name = 'Dealer CEO/Owner'];
        
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        forCodeList[0].Name = 'Delhi';
        forCodeList[0].For_Code__c = 'abe';
        
        insert forCodeList;
        
        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(2, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Parent_Group__c = 'abcd';        
        accList[0].Region_Code__c= 'E1'; 
        accList[0].Dealer_Code__c= 'Ertt';
        accList[0].Channel__c = 'NRM';
        accList[1].For_Code__c = forCodeList[0].Id;
        accList[1].Parent_Group__c = 'abc1';        
        accList[1].Region_Code__c= 'E1'; 
        accList[1].Dealer_Code__c= 'Erre';
        accList[1].Channel__c = 'EXC';
        insert accList;
      
        Account acc = [Select id from Account where Channel__c = 'NRM' limit 1];
        //Contacts Creation 
        //List<Contact> conList = TestDataFactory.createTestContact(2, accList[0].Id);
        List<Contact> conList = TestDataFactory.createTestContact(2, acc.Id);
        
        conList[0].LastName = 'abc0';        
        conList[1].LastName = 'abc1';
        insert conList;
        Account acc1 = [Select id from Account where Channel__c = 'EXC' limit 1];
        
        List<Contact> conList1 = TestDataFactory.createTestContact(1, acc1.Id);
        conList1[0].LastName = 'abc2';
        
        insert conList1;
        
        
        if(profileList.size() > 0){
            Test.startTest();
            List<User> userList = new List<User>();
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList[0].Id, 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = profileList[0].Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='u1@u.d');
            
            User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList[1].Id, 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileList[0].Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='u2@u.d');
            
            User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList1[0].Id, 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileList[0].Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='u3@u.d');
           
            userList.add(u);
            userList.add(u1);
            userList.add(u2);
            TriggerHandler.bypass('UserTriggerHandler');
            insert userList; 
            TriggerHandler.clearBypass('UserTriggerHandler');
           	User usr = [select id from User where username = 'u1@u.d' limit 1];
            CollaborationGroup cg = [Select id from CollaborationGroup where Name = 'All E1 Dealers Arena' limit 1];
            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
            cGroupMember.MemberId = usr.Id;                        
            cGroupMember.CollaborationGroupId = cg.Id;
            insert cGroupMember;
            
            ProfileToChatterGroupBatch1 obj = new ProfileToChatterGroupBatch1();
            Database.executeBatch(obj);
            
            String a = 'Dealer CEO/Owner';
            String b = 'Maruti Sales User';
            String c = 'Maruti Regional Manager';
            
            ProfileToChatterGroupBatch2 d = new ProfileToChatterGroupBatch2(a,b ,c);
            Database.executeBatch(d); 
            
            
          
            test.stopTest();
        } 
        
        
    }
    @isTest
    static void validateChatterGroup4(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
            CollaborationGroup cGroup1 = new CollaborationGroup();        
            cGroup1.Name = 'All Regional Employees Arena';
            cGroup1.CollaborationType = 'Unlisted';
            cGroupList.add(cGroup1);
            
            CollaborationGroup cGroup2 = new CollaborationGroup();        
            cGroup2.Name = 'All Regional Employees Nexa';
            cGroup2.CollaborationType = 'Unlisted';
            cGroupList.add(cGroup2);
            
            insert cGroupList;
            
            Profile pf = [SELECT id from Profile where Name = 'Maruti Regional Manager' limit 1];
            UserRole ur = [Select id from UserRole where Name = 'Nexa_RM_S1'];
            UserRole ur1 = [Select id from UserRole where Name = 'Arena_RM_E1'];
            
            List<User> userList = new List<User>();
            User tuser = new User(firstname = 'fName',lastName = 'lName',email ='testmail@test.com',Username = 'testu@test.d',
                                  EmailEncodingKey='UTF-8',Alias = 'als',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', ProfileId = pf.id,UserRoleId = ur.Id);
            
            User tuser2 = new User(firstname = 'fName',lastName = 'lName',email ='testmail@test.com',Username = 'testu2@test.d',
                                  EmailEncodingKey='UTF-8',Alias = 'als',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', ProfileId = pf.id,UserRoleId = ur.Id);
                                                     
            User tuser3 = new User(firstname = 'fName',lastName = 'lName',email ='testmail@test.com',Username = 'testu3@test.d',
                                  EmailEncodingKey='UTF-8',Alias = 'als',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', ProfileId = pf.id,UserRoleId = ur1.Id);
                                 
            userList.add(tuser); 
            userList.add(tuser2);
            userList.add(tuser3);
             
            insert userList;
           
            List<User> ulst = [Select id from User where username IN ('testu@test.d','testu2@test.d')];
            CollaborationGroup cg = [Select id from Collaborationgroup where Name = 'All Regional Employees Nexa' limit 1];
            List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
            cGroupMember.MemberId = ulst[0].Id;                        
            cGroupMember.CollaborationGroupId = cg.Id;
            cgmList.add(cGroupMember);
            CollaborationGroupMember cGroupMember1 = new CollaborationGroupMember();
            cGroupMember1.MemberId = ulst[1].Id;                        
            cGroupMember1.CollaborationGroupId = cg.Id;
            cgmList.add(cGroupMember1);
            insert cgmList;
            
            test.startTest();
            String a = 'Maruti National Heads';
            String b = 'Maruti Zonal Heads';
            String c = 'Maruti Regional Manager';
            ProfileToChatterGroupBatch4 obj3 = new ProfileToChatterGroupBatch4(a, b, c);
            Database.executeBatch(obj3);           
           
            test.stopTest();
            
        }
        
    }    
    @isTest
    static void validateChatterGroup3(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
            CollaborationGroup cGroup1 = new CollaborationGroup();        
            cGroup1.Name = 'All RO S1 Sales Users';
            cGroup1.CollaborationType = 'Unlisted';
            cGroupList.add(cGroup1);
            
            CollaborationGroup cGroup2 = new CollaborationGroup();        
            cGroup2.Name = 'All RO E1 Sales Users';
            cGroup2.CollaborationType = 'Unlisted';
            cGroupList.add(cGroup2);
            
            insert cGroupList;
            
            Profile pf = [SELECT id from Profile where Name = 'Maruti Regional Manager' limit 1];
            UserRole ur = [Select id from UserRole where Name = 'Nexa_RM_S1'];
            UserRole ur1 = [Select id from UserRole where Name = 'Arena_RM_E1'];
            
            List<User> userList = new List<User>();
            User tuser = new User(firstname = 'fName',lastName = 'lName',email ='testmail@test.com',Username = 'testu@test.d',
                                  EmailEncodingKey='UTF-8',Alias = 'als',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', ProfileId = pf.id,UserRoleId = ur.Id);
            
            User tuser2 = new User(firstname = 'fName',lastName = 'lName',email ='testmail@test.com',Username = 'testu2@test.d',
                                  EmailEncodingKey='UTF-8',Alias = 'als',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', ProfileId = pf.id,UserRoleId = ur.Id);
                                                     
            User tuser3 = new User(firstname = 'fName',lastName = 'lName',email ='testmail@test.com',Username = 'testu3@test.d',
                                  EmailEncodingKey='UTF-8',Alias = 'als',TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', ProfileId = pf.id,UserRoleId = ur1.Id);
                                 
            userList.add(tuser); 
            userList.add(tuser2);
            userList.add(tuser3);
             
            insert userList;
           
            List<User> ulst = [Select id from User where username IN ('testu@test.d','testu2@test.d')];
            CollaborationGroup cg = [Select id from Collaborationgroup where Name = 'All RO S1 Sales Users' limit 1];
            List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
            CollaborationGroupMember cGroupMember = new CollaborationGroupMember();
            cGroupMember.MemberId = ulst[0].Id;                        
            cGroupMember.CollaborationGroupId = cg.Id;
            cgmList.add(cGroupMember);
            CollaborationGroupMember cGroupMember1 = new CollaborationGroupMember();
            cGroupMember1.MemberId = ulst[1].Id;                        
            cGroupMember1.CollaborationGroupId = cg.Id;
            cgmList.add(cGroupMember1);
            insert cgmList;
            
            test.startTest();
            
            String a2 = 'Maruti Sales User';
            String b2 = 'Maruti Regional Manager';
            
            ProfileToChatterGroupBatch3 obj = new ProfileToChatterGroupBatch3(a2, b2);
            Database.executeBatch(obj,200);
            test.stopTest();
            
        }
        
    }
}