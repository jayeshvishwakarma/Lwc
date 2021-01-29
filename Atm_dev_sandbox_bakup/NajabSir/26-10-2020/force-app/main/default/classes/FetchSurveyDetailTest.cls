/**
* @File Name          : FetchSurveyDetailTest.cls
* @Description        :
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   : Najab Maghribi
* @Last Modified On   : 16/10/2020 12:10 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    16/10/2020 12:10 PM         Najab Maghribi            Initial Version
**/
@isTest
private class FetchSurveyDetailTest {
    @testsetup
    static void testRecordCreate(){
        //Create Account record for testing 
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        INSERT accountList;
        
        //Create Campaign record for testing  
        List<Campaign> campaignList = TestDataFactory.createCampaign(1);
        campaignList[0].Language_Type__c = 'English';
        INSERT campaignList;
        
        //Create survey taker record for testing        
        List<Survey_Taker_CTI__C> surveyTakerCTIList = TestDataFactory.createSurveyTaker(accountList[0].id,campaignList[0].id);
        INSERT surveyTakerCTIList;
        
        //Create survey parent question record for testing
        List<Survey_Question_CTI__c> parentSurveyQuestionCTIList = TestDataFactory.createSurveyQuestionCTI(campaignList[0].id);
        parentSurveyQuestionCTIList[0].Sequence_Number__c = 10;
        INSERT parentSurveyQuestionCTIList;
        
        //Create survey question record for testing
        List<Survey_Question_CTI__c> surveyQuestionCTIList = TestDataFactory.createSurveyQuestionCTI(campaignList[0].id);
        surveyQuestionCTIList[0].Sequence_Number__c = 20;
        surveyQuestionCTIList[0].Parent_Language_Question__c = parentSurveyQuestionCTIList[0].id;
        INSERT surveyQuestionCTIList;
        
        //Create survey answer record for testing
        List<Survey_Answer_CTI__c> listSurveyAnswers = TestDataFactory.createSurveyAnswerCTI(surveyQuestionCTIList[0].id);
        INSERT listSurveyAnswers;        
        
    }
    
    @isTest
    private static void unitTest(){
        List<String> userFields = new List<String>();
        userFields.add('Name');
        FetchSurveyDetail.objectWithAllFieldsMap.put('User', userFields);
        FetchSurveyDetail.objectWithAllFieldsMap.put('Survey_Taker_CTI__c', userFields);
        FetchSurveyDetail.mergeaFieldValuesMap.put('{{!User.Name}}', 'User.Name');
        FetchSurveyDetail.mergeaFieldValuesMap.put('{{!Survey_Taker_CTI__c.Name}}', 'User.Name');
        FetchSurveyDetail.mergeaFieldValuesMap.put('{{!Greeting}}', 'Good Morning');
        FetchSurveyDetail.mergeaFieldValuesMap.put('{{!User.Name}} {{!Greeting}} Test Pre Script', '{{!User.Name}} {{!Greeting}} Test Pre Script');
        FetchSurveyDetail.mergeaFieldValuesMap.put('{{!User.Name}} {{!Greeting}} Test Post Script', '{{!User.Name}} {{!Greeting}} Test Post Script');
        FetchSurveyDetail.mergeaFieldValuesMap.put('Test Record', 'Test Record');
        
        List<Campaign> campaignList = [Select id, 
                                       (Select id From Survey_Takers__r),
                                       (Select id From Survey_Questions__r)
                                       From Campaign 
                                       LIMIT 1 ];
        FetchSurveyDetail.getDetails(campaignList[0].Survey_Takers__r[0].id,'English');
        FetchSurveyDetail.getGreeting();
        String response = '[{"Response__c":"Yes","Survey_Question__c":"'+campaignList[0].Survey_Questions__r[0].id+'",';
        response += '"Survey_Taker__c":"'+campaignList[0].Survey_Takers__r[0].id+'","Unique_ID__c":"a1X1s0000004VXQEA2a1W1s000000BT5UEAW"}]';
        FetchSurveyDetail.submitSurveyResponse(response, true);
        
    }
}