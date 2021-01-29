/**
* @Autho:- Nishant Prajapati
* @Company-: Techmatrix Consulting
* @Description-: Test class for User Trigger Handler.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       10 Oct 2019    Nishant     Intial Version
**/
@istest
public class UserTriggerHandlerTest {

    @future()
    static void makeSetupObjectData(List<Id> lstConId, List<Id> lstConId2, List<Id> lstConId3, List<Id> lstConId4, List<Id> lstConId5) {
        List<Contact> lstCon = new List<Contact>();
        List<Contact> lstCon2 = new List<Contact>();
        List<Contact> lstCon3 = new List<Contact>();
        List<Contact> lstCon4 = new List<Contact>();
        List<Contact> lstCon5 = new List<Contact>();
        
        List<Id> lstAllId = new List<Id>();
        lstAllId.addAll(lstConId);
        lstAllId.addAll(lstConId2);
        lstAllId.addAll(lstConId3);
        lstAllId.addAll(lstConId4);
        lstAllId.addAll(lstConId5);
      //  lstAllId.addAll(lstConId);
        
        System.debug('lstAllId::'+lstAllId);
        List<Contact> lstConAll = [SELECT Id, LastName FROM Contact WHERE Id IN: lstAllId];//new List<Contact>();
        for(Contact con : lstConAll) {
            if(lstConId.contains(con.Id)) {
                lstCon.add(con);
            }
            if(lstConId2.contains(con.Id)) {
                lstCon2.add(con);
            }
            if(lstConId3.contains(con.Id)) {
                lstCon3.add(con);
            }
            if(lstConId4.contains(con.Id)) {
                lstCon4.add(con);
            }
            if(lstConId5.contains(con.Id)) {
                lstCon5.add(con);
            }
        }
        System.debug('lstConAll::'+lstConAll);
        System.debug('lstCon::'+lstCon);
        
        List<Profile> profileList= new list<Profile>([select id, name from Profile WHERE Name IN ('Dealer Accessories User', 'Dealer GM')]);
        List<User> user2create = TestDataFactory.createUserData('Portal', profileList[0].Name, lstCon2);
        user2create[0].Dealer_Employee_Code__c = 'DEFX8876';
        user2create[0].MSPIN__c = 'DSE8899';
        
        UserRole userRole_1 = [SELECT Id FROM UserRole LIMIT 1];
        for(User usr : user2create) {
            usr.UserRoleId = userRole_1.Id;
        }
        
        insert user2create;

        List<User> user2create2 = TestDataFactory.createUserData('Portal', profileList[0].Name, lstCon);
        user2create2[0].Dealer_Employee_Code__c = 'DEFX8870';
        user2create2[0].MSPIN__c = 'DSE8890';
        for(User usr : user2create2) {
            usr.UserRoleId = userRole_1.Id;
        }
        insert user2create2;
        
        List<User> user2create4 = TestDataFactory.createUserData('Portal', profileList[0].Name, lstCon3);
        for(Integer i=0;i<user2create4.size();i++)
        {
            user2create4[i].Dealer_Employee_Code__c = 'DEFX889'+i;
            user2create4[i].MSPIN__c = 'DSE886'+i;
            user2create4[i].Designation__c= 'NSM';
        }
        insert user2create4;
        
        List<User> user2create5 = TestDataFactory.createUserData('Portal', profileList[0].Name, lstCon4);
        for(Integer i=0;i<user2create5.size();i++)
        {
            user2create5[i].Dealer_Employee_Code__c = 'DEFX885'+i;
            user2create5[i].MSPIN__c = 'DSE884'+i;
            user2create5[i].Designation__c= 'GM';
        }
        insert user2create5;
    }
    
    @testSetup
    static void CreateMethod(){
        List<Id> lstConIdAll = new List<Id>();
        List<User> lstUsr = new List<User>();
        List<User> lstUsr1 = new List<User>();
        List<User> lstUsr2 = new List<User>();
        List<User> lstUsr3 = new List<User>();
        List<User> lstUsr4 = new List<User>();
        
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(4, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Parent_Group__c = 'abc';
        accList[1].Parent_Group__c = 'abc';
        accList[0].Region_Code__c= 'E1';
        accList[1].Region_Code__c= 'E1';
        accList[0].Dealer_Code__c = '0812';
        accList[1].Dealer_Code__c = '0810';
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[1].Id);
        conList[0].FirstName = 'abc';
        conList[0].LastName = 'abc';
        conList[0].MiddleName = 'abc';
        conList[0].Title = 'Mr.';
        conList[0].IsEvaluator__c = true;
        conList[0].MobilePhone = '9747453765';
        insert conList;
		List<Id> lstConId = new List<Id>();
        for(Contact con : conList) {
            lstConId.add(con.Id);
            lstConIdAll.add(con.Id);
        }
        
        //Contacts Creation
        List<Contact> conList1 = TestDataFactory.createTestContact(1, accList[0].Id);
        conList1[0].FirstName = 'abc';
        conList1[0].LastName = 'abc';
        conList1[0].MiddleName = 'abc';
        conList1[0].Title = 'Mr.';
        conList1[0].IsEvaluator__c = true;
        conList1[0].MobilePhone = '9747453765';
        insert conList1;
		List<Id> lstConId1 = new List<Id>();
        for(Contact con : conList1) {
            lstConId1.add(con.Id);
            lstConIdAll.add(con.Id);
        }
		//Contacts Creation 
        List<Contact> conList7 = TestDataFactory.createTestContact(1, accList[1].Id);
        conList7[0].FirstName = 'abc';
        conList7[0].LastName = 'abc';
        conList7[0].MiddleName = 'abc';
        conList7[0].Title = 'Mr.';
        conList7[0].IsEvaluator__c = true;
        conList7[0].MobilePhone = '8747453765';
        insert conList7;
        List<Id> lstConId7 = new List<Id>();
        for(Contact con : conList7) {
            lstConId7.add(con.Id);
            lstConIdAll.add(con.Id);
        }
     /*   
        List<Profile> profileList= new list<Profile>([select id, name from Profile WHERE Name IN ('Dealer Accessories User', 'Dealer GM')]);
        List<User> user2create = TestDataFactory.createUserData('Portal', profileList[0].Name, conList);
        user2create[0].Dealer_Employee_Code__c = 'DEFX8876';
        user2create[0].MSPIN__c = 'DSE8899';
        
        UserRole userRole_1 = [SELECT Id FROM UserRole LIMIT 1];
        for(User usr : user2create) {
            usr.UserRoleId = userRole_1.Id;
        }
        
        insert user2create;

        List<User> user2create2 = TestDataFactory.createUserData('Portal', profileList[0].Name, conList1);
        user2create2[0].Dealer_Employee_Code__c = 'DEFX8870';
        user2create2[0].MSPIN__c = 'DSE8890';
        for(User usr : user2create2) {
            usr.UserRoleId = userRole_1.Id;
        }
        insert user2create2;
*/
        UserEvaluatorFlag__c  mcs=new UserEvaluatorFlag__c();
        mcs.Name='Test';
        mcs.Inactive_Batch_Run__c=false;
        mcs.isInsert__c=true;
        insert mcs;

        //Contacts Creation
        List<Contact> conList4 = TestDataFactory.createTestContact(8, accList[2].Id);
        for(Integer i=0;i<conList4.size();i++)
        {
            conList4[i].FirstName = 'abc';
            conList4[i].LastName = 'abc';
            conList4[i].MiddleName = 'abc';
            conList4[i].Title = 'Mr.';
            conList4[i].IsEvaluator__c = true;
            conList4[i].MobilePhone = '9747453765';
        }
        insert conList4;
        List<Id> lstConId4 = new List<Id>();
        for(Contact con : conList4) {
            lstConId4.add(con.Id);
            lstConIdAll.add(con.Id);
        }
/*
        List<User> user2create4 = TestDataFactory.createUserData('Portal', profileList[0].Name, conList4);
        for(Integer i=0;i<user2create4.size();i++)
        {
            user2create4[i].Dealer_Employee_Code__c = 'DEFX889'+i;
            user2create4[i].MSPIN__c = 'DSE886'+i;
            user2create4[i].Designation__c= 'NSM';
        }
        insert user2create4;
*/

        //Contacts Creation
        List<Contact> conList5 = TestDataFactory.createTestContact(8, accList[3].Id);
        for(Integer i=0;i<conList5.size();i++)
        {
            conList5[i].FirstName = 'abc';
            conList5[i].LastName = 'abc';
            conList5[i].MiddleName = 'abc';
            conList5[i].Title = 'Mr.';
            conList5[i].IsEvaluator__c = true;
            conList5[i].MobilePhone = '9747453765';
        }
        insert conList5;
        List<Id> lstConId5 = new List<Id>();
        for(Contact con : conList5) {
            lstConId5.add(con.Id);
            lstConIdAll.add(con.Id);
        }

        //create setup object data in separate transaction
        
       // makeSetupObjectData(lstConId, lstConId1, lstConId7, lstConId4, lstConId5);
        
        List<User> lstUserAll = [SELECT Id, ContactId FROM User ]; //WHERE ContactId IN:lstConIdAll
        for(User usr : lstUserAll) {
            if(lstConId.contains(usr.ContactId)) {
                lstUsr.add(usr);
            }
            if(lstConId1.contains(usr.ContactId)) {
                lstUsr1.add(usr);
            }
            if(lstConId7.contains(usr.ContactId)) {
                lstUsr2.add(usr);
            }
            if(lstConId4.contains(usr.ContactId)) {
                lstUsr3.add(usr);
            }
            if(lstConId5.contains(usr.ContactId)) {
                lstUsr4.add(usr);
            }
        }
        
        //Account acc = new Account(id = accList[2].Id);
        /*acc.Sales_SPOC_1__c= user2create4[0].Id;
        acc.Sales_SPOC_2__c= user2create4[1].Id;
        acc.Sales_SPOC_3__c= user2create4[2].Id;
        acc.Sales_SPOC_4__c= user2create4[3].Id;
        acc.Sales_SPOC_5__c= user2create4[4].Id;*/
        /*added by shubham
         * acc.Sales_SPOC_1__c= lstUsr3[0].Id;
        acc.Sales_SPOC_2__c= lstUsr3[1].Id;
        acc.Sales_SPOC_3__c= lstUsr3[2].Id;
        acc.Sales_SPOC_4__c= lstUsr3[3].Id;
        acc.Sales_SPOC_5__c= lstUsr3[4].Id;
        update acc;*/

       
/*
        List<User> user2create5 = TestDataFactory.createUserData('Portal', profileList[0].Name, conList5);
        for(Integer i=0;i<user2create5.size();i++)
        {
            user2create5[i].Dealer_Employee_Code__c = 'DEFX885'+i;
            user2create5[i].MSPIN__c = 'DSE884'+i;
            user2create5[i].Designation__c= 'GM';
        }
        insert user2create5;
*/
        //Account acc1 = new Account(id = accList[3].Id);
/*added by shubham
 *         acc1.Sales_SPOC_1__c= user2create5[0].Id;
        acc1.Sales_SPOC_2__c= user2create5[1].Id;
        acc1.Sales_SPOC_3__c= user2create5[2].Id;
        acc1.Sales_SPOC_4__c= user2create5[3].Id;
        acc1.Sales_SPOC_5__c= user2create5[4].Id;*/
        /*acc1.Sales_SPOC_1__c= lstUsr4[0].Id;
        acc1.Sales_SPOC_2__c= lstUsr4[1].Id;
        acc1.Sales_SPOC_3__c= lstUsr4[2].Id;
        acc1.Sales_SPOC_4__c= lstUsr4[3].Id;
        acc1.Sales_SPOC_5__c= lstUsr4[4].Id;
        update acc1;*/
    }

    @isTest
    static void validateUserTrigger(){
        List<Profile> profileList= [select id, name from Profile WHERE Name IN ('Dealer Accessories User', 'Dealer GM')];

        if(profileList.size() > 0){
            List<User> user2create = new list<User>([SELECT id from user where profile.name='Dealer Accessories User' and isActive = true]);
            system.runAs(user2create[0]){
                Test.startTest();
                insert new Custom_Validation_Exception_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c=true);
                insert new Schedule_Apex_Job_Time__c(SetupOwnerId=UserInfo.getOrganizationId(), Time_in_minutes__c= 2);
                user2create[0].Profile = profileList[1];
                update user2create[0];
                MapProfileToGroupBatch BatchObj = new MapProfileToGroupBatch();
                database.executeBatch(BatchObj);
                Test.stopTest();
            }

        }
    }



    @isTest
    static void assignSalesSPOCTest(){
        list<User>Ulist = new list<user>();
        for(User u : [SELECT id, designation__c from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8876']){
            u.designation__c = 'NSM';
            Ulist.add(u);
        }
        System.debug('Ulist---------------'+Ulist.size());
        update Ulist;

        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8876']){
            u.designation__c = 'GM';
            Ulist2.add(u);
        }
        update Ulist2;

        list<User>Ulist3 = new list<user>();
        for(User u : [SELECT id, designation__c from user where contactId !=null and (Dealer_Employee_Code__c = 'DEFX8876' or Dealer_Employee_Code__c = 'DEFX8870')]){
            Ulist3.add(u);
        }
        Ulist3[0].designation__c = 'NSM';
        Ulist3[1].designation__c = 'GM';
        update Ulist3;

    }

    @isTest
    static void validateInactiveEvaluatorBatch(){
        List<Profile> profileList= [select id, name from Profile WHERE Name =: 'Dealer TV Evaluator'];
        set<string> uid = new set<string>();
        if(profileList.size() > 0){
            List<User> user2create = new list<User>([SELECT id,contactId,contact.IsEvaluator__c from user where profile.name='Dealer Accessories User' and isActive = true and DMS_Active__c = true]);
            Test.startTest();
            user2create[0].ProfileId = profileList[0].Id;
            update user2create[0];
            uid.add(user2create[0].Id);
            inActiveTVEvaluatorSchedule myClass = new inActiveTVEvaluatorSchedule(uid);
            String chron = '0 0 23 * * ?';
            system.schedule('Test Sched', chron, myClass);
            test.stopTest();
        }
    }

    @isTest
    static void validateInactiveEvaluatorBatch1(){
        List<Profile> profileList= [select id, name from Profile WHERE Name =: 'Dealer TV Evaluator'];
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(2, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Parent_Group__c = 'abc';
        accList[1].Parent_Group__c = 'abc';
        accList[0].Region_Code__c= 'E1';
        accList[1].Region_Code__c= 'E1';
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[1].Id);
        conList[0].FirstName = 'abc';
        conList[0].LastName = 'abc';
        conList[0].MiddleName = 'abc';
        conList[0].Title = 'Mr.';
        conList[0].IsEvaluator__c = true;
        conList[0].MobilePhone = '9747453765';
        insert conList;
        if(profileList.size() > 0){
            Test.startTest();
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = conList[0].Id,
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = profileList[0].Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));

            insert u;
            //    inActiveTVEvaluatorSchedule myClass = new inActiveTVEvaluatorSchedule();
            //  String chron = '0 0 23 * * ?';
            // system.schedule('Test Sched', chron, myClass);
            test.stopTest();
        }
    }

    @isTest
    static void assignSalesSPOCInActiveTestNSM(){
        list<User>Ulist = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Contact.AccountId,Dealer_Account__c from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8890']){
            u.designation__c = 'NSM';
            u.IsActive = false;
            system.debug('297 %% '+ u.Dealer_Account__c );
            Ulist.add(u);
        }
        System.debug('Ulist---------------'+Ulist.size());
        update Ulist;


    }

    @isTest
    static void assignSalesSPOCInActiveTestNSM2(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8891']){
            u.designation__c = 'NSM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestNSM3(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8892']){
            u.designation__c = 'NSM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestNSM4(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8893']){
            u.designation__c = 'NSM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestNSM5(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8894']){
            u.designation__c = 'NSM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestGM(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8850']){
            u.designation__c = 'GM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestGM1(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8851']){
            u.designation__c = 'GM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestGM2(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8852']){
            u.designation__c = 'GM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestGM3(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8853']){
            u.designation__c = 'GM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }

    @isTest
    static void assignSalesSPOCInActiveTestGM4(){
        list<User>Ulist2 = new list<user>();
        for(User u : [SELECT id, designation__c,IsActive,Dealer_Account__c  from user where contactId !=null and Dealer_Employee_Code__c = 'DEFX8854']){
            u.designation__c = 'GM';
            u.IsActive = false;
            system.debug('320 %% '+ u.Dealer_Account__c );
            Ulist2.add(u);
        }
        update Ulist2;

    }
    @isTest
    static void testAdditionOfChatterGroup(){

        Network nk = [select id from Network where Name like 'Dealer%' limit 1];
        CollaborationGroup cGroup = new CollaborationGroup();
        cGroup.NetworkId = nk.Id;
        cGroup.Name = 'All E1 Dealers Arena';
        cGroup.CollaborationType = 'Unlisted';
        insert cGroup;
        List<Profile> profileList= [select id, name from Profile WHERE Name = 'Dealer Sales Executive' OR Name = 'Dealer CEO/Owner'];

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Parent_Group__c = 'abc';
        accList[0].Region_Code__c= 'E1';
        accList[0].Dealer_Code__c= 'Ert';
        accList[0].Channel__c = 'NRM';
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
            userList.add(u);
            userList.add(u1);
            insert userList;
            test.stopTest();
        }
    }
	@isTest
    static void validatePasswordServiceBatch(){
        List<Profile> profileList= [select id, name from Profile WHERE Name =: 'Dealer Sales Executive'];
        set<string> uid = new set<string>();
        if(profileList.size() > 0){
            List<User> user2create = new list<User>([SELECT id,Partner_User_Pwd__c from user where profile.name='Dealer Accessories User' and isActive = true and DMS_Active__c = true and Contact.Account.Dealer_Code__c != null]);
            Test.startTest();
            user2create[0].ProfileId = profileList[0].Id;
            user2create[0].IsActive = false;
            update user2create[0];
            user2create[0].IsActive = true;
            user2create[0].InActive_To_Active_Date__c = system.now();
            user2create[0].MSPIN__c= '66564';
            update user2create[0];
            PassWordServiceSchedule myClass = new PassWordServiceSchedule();
            String chron = '0 0 23 * * ?';
            system.schedule('Test Sched', chron, myClass);
            test.stopTest();
        }
    }
	
	@isTest
    static void validateCheckForExistingUserName(){
            List<User> user2create = new list<User>([SELECT id,Partner_User_Pwd__c,ProfileId,Profile.Name from user where profile.name='Dealer Accessories User' and isActive = true and DMS_Active__c = true and Contact.Account.Dealer_Code__c != null]);
            Test.startTest();
            user2create[0].IsActive = false;
            user2create[0].Username = 'abc1234426356@username.com';
            user2create[0].CommunityNickname = 'nickname1435243534';
            user2create[0].Dealer_Employee_Code__c = '5634';
            update user2create[0];
            
            List<Contact> con = new List<Contact>([Select id,LastName from contact where MobilePhone = '8747453765' limit 1]);
            
            List<User> user2create4 = TestDataFactory.createUserData('Portal', user2create[0].Profile.Name , con);
            user2create4[0].Username = 'abc1234426356@username.com';
            user2create4[0].CommunityNickname = 'nickname1435243534';
            user2create4[0].Dealer_Employee_Code__c = '5632';
            insert user2create4[0];
            test.stopTest();
    }

}