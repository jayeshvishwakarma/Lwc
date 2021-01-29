/***************************************************************************************************
Author : Mukesh Bhardwaj.
Company : Threshold Consulting
Description : Test class for biuCase Trigger.
Date On : 3rd May 2013.
Initial Version
****************************************************************************************************/
@isTest(seeAllData = false)
private class tesbiuCase 
{ 
    static testMethod void Unittest() 
    {
        Id accRtId = TestClassUtility.recordTypeMap.get('Account').get('Payer');
        Id caseRtId = TestClassUtility.recordTypeMap.get('Case').get('General_Case');
        
        Test.startTest();
        Account a = new Account();
        a.Name = 'Test Acc';
        a.Type = 'Customer';
        a.Account_Sub_Type__c = 'Customer';
        a.RecordTypeId = accRtId;
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Mukesh';
        c.Email = 'a@gmail.com';
        c.MailingState = 'CA';
        c.MailingStreet = 'Mailing Street';
        insert c;

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
        
        batchOrderNumbers  bc = new batchOrderNumbers();
        Database.executeBatch(bc, 200);
        Test.stopTest();
    }
   
}