@isTest
public class BulkHoldCasesTriggerHandlerTest {
    @testSetup static void createTestData() {
        
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Account> dealerList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        dealerList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        list<User> UserList = TestDataFactory.createUserData('Internal','System Administrator',null);
        UserList[0].MobilePhone='9997898789';
        insert UserList;
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            
        }
        insert casesList;
        
        List<Bulk_Hold_Cases__c> bulkHoldcasesList = TestDataFactory.createBulkHoldCase(1);
        bulkHoldcasesList[0].Current_Approver__c=userinfo.getUserId();
        bulkHoldcasesList[0].Initiation_Notification_Message__c='test';
        bulkHoldcasesList[0].Approved_Rejection_Notifiers__c=userinfo.getUserId()+';'+UserList[0].id;
        insert bulkHoldcasesList;
        
        casesList[0].Bulk_Hold_Till_Date__c=system.today()+1;
        casesList[0].Bulk_Hold_Status__c='In Progress';
        casesList[0].Bulk_Hold_Start_Date__c=system.today();
        casesList[0].Bulk_Hold_Case__c = bulkHoldcasesList[0].id;
        update casesList[0];
        
        
    }
    static testMethod void updateCallTest() {
        Test.startTest();
        List<User> UserList = [select id from user];
        List<Bulk_Hold_Cases__c> bulkHoldcasesList = [select id,Approval_Status__c,Current_Approver__c,Approved_Rejection_Notifiers__c from Bulk_Hold_Cases__c];
        bulkHoldcasesList[0].Approval_Status__c='Approved';
        bulkHoldcasesList[0].Current_Approver__c=UserList[0].id;
        bulkHoldcasesList[0].Approved_Rejection_Notifiers__c=UserList[0].id+';'+userinfo.getUserId();
        update bulkHoldcasesList;
        Test.stopTest();
    }
}