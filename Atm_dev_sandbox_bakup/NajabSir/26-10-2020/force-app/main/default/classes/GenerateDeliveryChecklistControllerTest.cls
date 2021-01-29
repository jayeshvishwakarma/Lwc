@isTest
public class GenerateDeliveryChecklistControllerTest{
    static String labelName = 'Delivery Checklist';
    @isTest
    static void testDeliveryCheckListQuestions(){
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList1 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList1[0].accountId = userAccountList[0].id;
        oppList1[0].StageName = 'New';
        oppList1[0].Customer__c= personAccountList[0].Id;
        oppList1[0].ownerId = label.Integration_user;
        
        insert opplist1;
        
        list<Survey__c> surveyList = TestdataFactory.createSurvey(1);
        for(Survey__c s :surveyList){
            s.name = label.DeliveryChecklistSurvey;
        }
        insert surveyList;
        
        list<SurveyTaker__c> surveyTakenList = TestDataFactory.createSurveyTaken(1);
        for(SurveyTaker__c st:surveyTakenList){
            st.EnquiryID__c = opplist1[0].id;
            st.Survey__c = surveyList[0].id;
        }
        insert surveyTakenList;
        
        list<SurveyTaker__c> CheckExistingSurvey = TestDataFactory.createSurveyTaken(1);
        for(SurveyTaker__c st:CheckExistingSurvey){
            st.EnquiryID__c = opplist1[0].id;
            st.Survey__c = surveyList[0].id;
        }
        insert CheckExistingSurvey;
        
        
        list<Survey_Question__c> sclist = TestDataFactory.createSurveyQuestion(1);
        for(Survey_Question__c sc : sclist){
            sc.survey__c = surveyList[0].id;
            sc.Choices__c = 'Yes No';
        }
        insert sclist;
        SurveyQuestionResponse__c sc = new SurveyQuestionResponse__c();
            sc.Remarks__c = 'test';
            sc.Date_Expected__c = System.today();
            sc.Response__c = 'yes';
            sc.Survey_Question__c = sclist[0].id;
            sc.SurveyTaker__c = surveyTakenList[0].id;
        insert sc;
        list<SurveyTaker__c> surveyTakenListView = new list<SurveyTaker__c>([SELECT id from SurveyTaker__c where id in:surveyTakenList]);
        GenerateDeliveryChecklistController.deliveryCheckListQuestions(opplist1[0].Id);
    }
    
    @istest
    static void saveSurveyResponse(){
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList1 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList1[0].accountId = userAccountList[0].id;
        oppList1[0].StageName = 'New';
        oppList1[0].Customer__c= personAccountList[0].Id;
        oppList1[0].ownerId = label.Integration_user;
        
        insert opplist1; 
        
        list<Survey__c> surveyList = TestdataFactory.createSurvey(1);
        for(Survey__c s :surveyList){
            s.name = label.DeliveryChecklistSurvey;
        }
        insert surveyList;
        
        list<SurveyTaker__c> surveyTakenList = TestDataFactory.createSurveyTaken(1);
        for(SurveyTaker__c st:surveyTakenList){
            st.EnquiryID__c = opplist1[0].id;
            st.Survey__c = surveyList[0].id;
        }
        insert surveyTakenList;
        
        for(SurveyTaker__c st:surveyTakenList){
            st.EnquiryID__c = opplist1[0].id;
            st.Survey__c = surveyList[0].id;
        }
        update surveyTakenList;
       
        list<Survey_Question__c> sclist = TestDataFactory.createSurveyQuestion(1);
        for(Survey_Question__c sc : sclist){
            sc.survey__c = surveyList[0].id;
            sc.Choices__c = 'Yes No';
        }
        insert sclist;
        list<SurveyTaker__c> surveyTakenListView = new list<SurveyTaker__c>([SELECT id from SurveyTaker__c where id in:surveyTakenList]);
        SurveyQuestionResponse__c sc = new SurveyQuestionResponse__c();
            sc.Remarks__c = 'test';
            sc.Date_Expected__c = System.today();
            sc.Response__c = 'yes';
            sc.Survey_Question__c = sclist[0].id;
            sc.SurveyTaker__c = surveyTakenList[0].id;
        insert sc;
        GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper data = new GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper();
        data.answer ='yes';
        data.dateExpected = date.valueOf(System.now());
        data.surveyResponseId = sc.ID;
        data.questionId =sclist[0].id;
        data.questionName = 'Why';
        data.remarks = 'good';
        data.srno = 1;
        GenerateDeliveryChecklistController.saveSurveyResponse(opplist1[0].Id,json.serialize(new list<GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper>{data}),ConstantsUtility.BTN_LABEL_CONST);
     }
}