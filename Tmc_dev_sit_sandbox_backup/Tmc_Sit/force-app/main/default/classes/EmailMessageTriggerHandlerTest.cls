/**
* @File Name          : EmailMessageTriggerHandlerTest.cls
* @Description        : Test Class of the apex class 'EmailMessageTriggerHandler'
* @Author             : Gitika
**/
@IsTest
public class EmailMessageTriggerHandlerTest {
    
    @testSetup static void createTestData() {
       Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseMSILQueryInternalTriggerServiceImpl','MSIL_Query_Internal');
        insert ImplementationStrategyRecord;
        Id MSILQueryInternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, MSILQueryInternalRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Channel__c = 'MS Corporate';
            c.Case_Type__c ='MSIL Query';
            c.Business_Area__c='Domestic';
            c.Email__C='salesfrocetest@abc.org';
            c.FCR_Conducted__c='No';
            c.MSIL_Non_SF_Stakeholder_Email__c='salesfrocetestr@abc.org';
        }
        insert casesList;
        
        
    }
    static testMethod void populateDetailsOnOpenCaseTest() {
        Test.startTest();
        list<case> caseList = [Select Status,MSIL_Remarks__c,Additional_Information__c,No_of_Outbound_Emails__c,Email__c,Channel__c,Business_area__c,case_Type__c from case];
        list<EmailMessage> newEmail = new list<EmailMessage>();
        newEmail.add(TestDataFactory.createEmailMessage(caseList[0].Id,'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com','salesfrocetest@abc.org',true));
        newEmail.add(TestDataFactory.createEmailMessage(caseList[0].Id,'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com','salesfrocetestr@abc.org',true));
        newEmail.add(TestDataFactory.createEmailMessage(caseList[0].Id,'salesfrocetest@abc.org','test@abc.org',false)); 
        insert newEmail;
        
        Test.stopTest();
    }
    static testMethod void populateDetailsOnClosedCaseTest() {
        Test.startTest();
        list<case> caseList = [Select id,Status,MSIL_Remarks__c,Additional_Information__c,No_of_Outbound_Emails__c,Email__c,Channel__c,Business_area__c,case_Type__c from case];
        caseList[0].status=ConstantsUtility.CASE_CLOSED;
        update caseList[0];
        list<EmailMessage> newEmail = new list<EmailMessage>();
        newEmail.add(TestDataFactory.createEmailMessage(caseList[0].Id,'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com','test@abc.org',true));
        newEmail.add(TestDataFactory.createEmailMessage(caseList[0].Id,'salesfrocetest@abc.org','test@abc.org',false)); 
        newEmail.add(TestDataFactory.createEmailMessage(caseList[0].Id,'salesfrocetestr@abc.org1','test@abc.org',false));
        insert newEmail;
        
        Test.stopTest();
    }
}