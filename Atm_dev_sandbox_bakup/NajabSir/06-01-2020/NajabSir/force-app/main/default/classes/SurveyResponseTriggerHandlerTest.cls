@isTest
public class SurveyResponseTriggerHandlerTest {
    @testSetup
    static void createRecords(){
      list<Account> BusinessAccountlist = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert BusinessAccountlist;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        for(opportunity opp :opplist){
            opp.Dealership__c = BusinessAccountlist[0].id;
        }
        insert opplist;
        
        list<Survey__c> svlist = Testdatafactory.createSurveyPerformance(1,'Test Drive Feedback');
        insert svlist;
        
        List<Product2> productList = TestDataFactory.createProducts('Variants', 1);
        
        List<Asset> assetsList = new List<Asset>(); 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productList)){
            ast.accountId  = BusinessAccountlist[0].Id;
            
            assetsList.add(ast);
        }
        
        insert assetsList;
        
        list<test_drive__c> testDriveList = TestDataFactory.createTestDriveRecords(1);
        for(test_drive__c td : testDriveList){
            td.enquiry__c = opplist[0].Id;
            td.Test_Drive_Vehicle__c = assetsList[0].id;
        }
        insert testDriveList;
        
        
        list<SurveyTaker__c> surveyTakenlist = TestDataFactory.createSurveyTaken(1);
        for(SurveyTaker__c st : surveyTakenlist){
            st.EnquiryID__c = opplist[0].Id;
            st.Survey__c = svlist[0].id;
            st.Test_Drive__c = testDriveList[0].Id;
        }
        insert surveyTakenlist;
        
        
        list<Survey_Question__c> surveyQuesList = Testdatafactory.createSurveyQuestion(1);
        for(Survey_Question__c sq : surveyQuesList){
            sq.Survey__c = svlist[0].id;
        }
        insert surveyQuesList;
        
        
        Test_Drive_Survey_SFMC__c tdsmc = new Test_Drive_Survey_SFMC__c();
        tdsmc.Name = 'Test Drive';
        tdsmc.Question__c = 'How was your experience of Test Drive';
        tdsmc.Response__c = 'No';
        tdsmc.Survey_Name__c = 'Test Drive Feedback';
        insert tdsmc;
        
        list<SurveyQuestionResponse__c> sclist2 = new list<SurveyQuestionResponse__c>();
        
        for(integer i =0;i<200;i++){
            SurveyQuestionResponse__c sc = new SurveyQuestionResponse__c();
            sc.Remarks__c = 'test';
            sc.Date_Expected__c = System.today();
            sc.Response__c = 'No';
            sc.Survey_Question__c = surveyQuesList[0].id;
            sc.SurveyTaker__c = surveyTakenList[0].id;
            sclist2.add(sc);
        }
        insert sclist2;  
    }
    
    @isTest
    static void TestMcRecordCreation(){
        List<mc_communication__c> McRecordList = new list<mc_communication__c>([SELECT id from mc_communication__c]);
        System.assertEquals(1,McRecordList.size());
    }
}