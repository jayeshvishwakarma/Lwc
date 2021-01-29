@isTest
public class TakeSurveyLWCControllerTest {
    @isTest
    static void fetchQuestions(){
        
        Survey__c surv = new Survey__c(Name = 'Showroom Feedback Survey');
        insert surv;
    
        list<Survey_Question__c> surveyQuestionList = TestDataFactory.createSurveyQuestion(1);
        insert surveyQuestionList;
        TakeSurveyLWCController.fetchQuestions(surveyQuestionList[0].survey__c);
        List < Map < String, String >> allQS=new List < Map < String, String >>();
        Map < String, String > allQSMap= new Map < String, String >();
        allQSMap.put('answer','Test');
        allQS.add(allQSMap);
        TakeSurveyLWCController.saveSurvey(allQS, surveyQuestionList[0].survey__c,'' , '', '');
    }
    @isTest
    static void fetchQuestionsNull(){
        
        TakeSurveyLWCController.fetchQuestions(null);
        
    }
}