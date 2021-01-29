@istest
public class DMSSysncFailAlertAsMailTest {
    @testSetup
    static void CreateRecord(){
        
        Datetime dt = system.now();
        Date d = date.newinstance(dt.year(), dt.month(), dt.day());
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(2, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = userinfo.getUserId();
        oppList[0].DMS_Sync_Error_Details__c  = 'abc';
        
        oppList[1].accountId = userAccountList[0].id;
        oppList[1].StageName = 'Pre-Booking';
        oppList[1].Customer__c= personAccountList[0].Id;
        oppList[1].ownerId = userinfo.getUserId();
        oppList[1].DMS_Sync_Error_Details__c  = 'abc';
        oppList[1].DMS_Enquiry_Name__c  = 'abc';
        oppList[1].Pre_booking_Submission_Date__c   = d;
        insert oppList;
        
    }
    
    @istest
    static void testing(){
        List<Opportunity> oppList = new list<opportunity>([SELECT id from opportunity]);
        System.debug('oppList'+oppList.size());
        DMSSysncFailAlertAsMailSchedule myClass = new DMSSysncFailAlertAsMailSchedule();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
    }
}