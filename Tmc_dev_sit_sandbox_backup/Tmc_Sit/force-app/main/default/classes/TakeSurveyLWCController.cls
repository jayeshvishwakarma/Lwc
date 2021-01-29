/**
 * @File Name          : TakeSurveyLWCController.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 5/27/2020, 10:13:47 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/26/2020   Rajesh Ramachandran     Initial Version
**/
public without sharing class TakeSurveyLWCController {

    @AuraEnabled
    public static List<Survey_Question__c> fetchQuestions(String surveyId){
        if (surveyId != null){ 
            // Retrieve all necessary information to be displayed on the page
            List<Survey_Question__c> allQuests = new List<Survey_Question__c>();
            allQuests = setupQuestionList(surveyId);
            return allQuests;
        }
        else {
            return null;            
        }
    }

    private static List<Survey_Question__c> setupQuestionList(String surveyid){
        
        List<Survey_Question__c> allQuestionsObject = 
                                        [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                                        s.OrderNumber__c, s.Name, s.Choices__c, s.Question_Type__c
                                        From Survey_Question__c s 
                                        WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];
        return(allQuestionsObject);
    }
    
    @AuraEnabled
    public static String saveSurvey(List<Map<String, String>> allQS, String surveyId, String caseId, String enquiryId, String contactId){
        System.debug(allQS);
        System.debug(surveyId);
        System.debug(caseId);
        System.debug(enquiryId);
        System.debug(contactId);                                
        if (surveyId != null && surveyId != ''){
            Id stId = addSurveyTaker(surveyId,caseId,enquiryId,contactId);
            addSurveyAnswers(stId,allQS);
            return 'Success';    
        }
        else {
            return 'Error';
        }
    }

    private static Id addSurveyTaker(String surveyId, String caseId, String enquiryId, String contactId){
        
        if(caseId != null && (caseId.toUpperCase() =='NONE'|| caseId.length()<5))
          caseId = null;
        if(enquiryId != null && (enquiryId.toUpperCase() =='NONE'|| enquiryId.length()<5))
          enquiryId = null;
        if(contactId != null && (contactId.toUpperCase() =='NONE'|| contactId.length()<5))
          contactId = null; 

          SurveyTaker__c st = new SurveyTaker__c();
          st.Customer__c = contactId;
          st.Survey__c = surveyId;
          st.Taken__c = 'true';
          st.EnquiryID__c=enquiryId;
          st.Case__c = caseId;
          st.User__c = UserInfo.getUserId();
          insert st;
          return st.Id;      

    }

    private static void addSurveyAnswers(Id stId, List<Map<String, String>> allQS){

        try {
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
            for (Map<String, String> q : allQS) {
                SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
                sqr.Survey_Question__c = q.get('qid');
                String responseVal = q.get('answer');
                if(responseVal != null && responseVal != ''){
                    responseVal = responseVal.replace('"', '');
                    responseVal = responseVal.replace('[','');
                    responseVal = responseVal.replace(']','');
                }
                sqr.response__c = responseVal;
                sqr.SurveyTaker__c = stId;
                sqrList.add(sqr);
            }
            if (sqrList != null && sqrList.size() > 0)
                insert sqrList;
        }
        catch(Exception e){
            System.debug('Hi'+e.getLineNumber()+'>>>'+e.getStackTraceString()+'>>>'+e.getMessage());
        }


    }


}