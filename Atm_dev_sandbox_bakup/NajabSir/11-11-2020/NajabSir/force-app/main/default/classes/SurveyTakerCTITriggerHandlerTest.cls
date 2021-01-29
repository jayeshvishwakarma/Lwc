@isTest
public class SurveyTakerCTITriggerHandlerTest {
	
    @testSetup
    public static void createData(){
        Survey_Taker_CTI__c surveyTaker = new Survey_Taker_CTI__c();
        surveyTaker.Title__c = 'Testing Record';
        insert surveyTaker;
    }
    
    @isTest
    public static void unitTest(){
        Test.startTest();
        Test.stopTest();
    }
}