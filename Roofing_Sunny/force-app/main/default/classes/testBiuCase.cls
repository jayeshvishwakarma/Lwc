/*
Author : Mukesh Bhardwaj(Threshold Consulting)
Company : Certainteed
Description : Test class for biuCase Trigger.
Date On : 3rd May 2013.
Initial Version
*/
@isTest(seeAllData = false)
private class testBiuCase 
{ 
    static testMethod void Unittest() 
    {
        test.starttest();
        List<Profile> profileList = [Select Id From Profile Where Name = 'system administrator'];
        List<UserRole> uRoleList = [Select Id From UserRole Where Name like 'Director of Sales'];
        User testUser = new User();
        testUser.UserName = 'testuser11@ctroofing.com';
        testUser.LastName = 'Test';
        testUser.email = 'test@testuser.com';
        testUser.alias = 'testusr1';
        testUser.communitynickname = 'tstusr';
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileList[0].Id;
        testUser.LanguageLocaleKey = 'en_US';           
        insert testUser;
        
        System.runAs(testUser) 
        {   

        Id accRtId = TestClassUtility.recordTypeMap.get('Account').get('Customer_BPCS_Read_Only');
        Id caseRtId = TestClassUtility.recordTypeMap.get('Case').get('General_Case');
        
        //Test.startTest();
        Account a = new Account();
        a.Name = 'Test Acc';
        a.Type = 'Customer';
        a.Account_Sub_Type__c = 'Customer';
        a.RecordTypeId = accRtId;
       // a.Com_TM__c = 
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'test';
        c.LastName = 'Mukesh';
        c.Email = 'a@gmail.com';
        c.MailingState = 'CA';
        c.MailingStreet = 'Mailing Street';
        insert c;
        
        
        Account a1 = new Account();
        a1.Name = 'Test Acc';
        a1.Type = 'Customer';
        a1.Account_Sub_Type__c = 'Customer';
        a1.RecordTypeId = accRtId;
        //a1.Com_TM__c = c.id;
        
        insert a1;

        Case ca = new Case();
        ca.ContactId = c.Id;
        ca.Type = 'Account Maintenance';
        ca.SubType__c = 'Change Quantity';
        ca.Resolution__c = 'General Case';
        ca.Origin = 'Email';
        ca.Status = 'Re-Opened';
        ca.Order_Number__c = '123456';
        insert ca;
        
        Order o = new Order();
        o.Name = '123456';
        insert o;
        
        Plants__c w = new Plants__c();
        w.SAP_Plant__c = '15';
        w.Logistics_Coordinator__c = testuser.id;
        
        insert w;
        
        batchOrderNumbers  bc = new batchOrderNumbers();
        Database.executeBatch(bc, 200);
        Test.stopTest();
    }
   
}
}