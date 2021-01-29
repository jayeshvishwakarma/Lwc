/**
 * @File Name          : ClosedFollowUpsCtrlTest.cls
 * @Description        : Test class for ClosedFollowUpsCtrl.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 16/09/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    16/09/2019 04:30 PM          Anuj Kumar            Initial Version
**/


@isTest(seeAlldata=False)
public class ClosedFollowUpsCtrlTest {
    
    @testsetup
    static void testrecordcreate(){
        
        // Create Corporate 
        List<Corporate__c> corList = TestDataFactory.createCorporate(1);
        insert corList;
        
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
        System.assertEquals(1, conList.size());
        
        //User Creation 
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = usr[0].Id;
        
        
        oppList[0].Sales_Type__c = 'IND';
        oppList[0].First_Name__c = 'Test Enquiry';
        oppList[0].Exchange_Model__c = 'BA';
        oppList[0].Employer_Name__c = corList[0].Id;
        insert oppList;
        
    }
    
    static testmethod void test(){
        
        Test.startTest();
            List<Opportunity> oppList = [SELECT Id, StageName, Sales_Type__c FROM Opportunity];
            Opportunity opp = oppList[0];
            ClosedFollowUpsCtrl.retriveEnquiryInfo(opp.Id);
        Test.stopTest();
        
        
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)ClosedFollowUpsCtrl.fetchCloseFollowUpDetails('Closed Follow Ups','12345', '12345', 'abc', 'abc','1234D');
        
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
         
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","EnquirynumberFollowupsList":[{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"},{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"},{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"}]}');
        response.setStatusCode(200);   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        
        String tempResponse = '{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","EnquirynumberFollowupsList":[{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"},{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"},{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"}]}';
        
        // Object neObj = (Object)'Closed Follow Ups#####'+tempResponse;
        Object neObj = (Object)'Closed Follow Ups#####';
        ClosedFollowUpsCtrl.processResponse(strList,neObj);
         
    }
}