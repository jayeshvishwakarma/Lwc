@isTest
public class SurveyResponseTriggerHelperTest {

    @testSetup
    public static void createRecord(){
        Survey_Response_CTI__c surveyResponse = new Survey_Response_CTI__c();
        surveyResponse.Response__c = 'This record is for testing purpose';
        insert surveyResponse;
        surveyResponse.Response__c = '';
        update surveyResponse;
    }
    @isTest
    public static void unitTest(){
        Test.startTest();
        Test.stopTest();
    }
}