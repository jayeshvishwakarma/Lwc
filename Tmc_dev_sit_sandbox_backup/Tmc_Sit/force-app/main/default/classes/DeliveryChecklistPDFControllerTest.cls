@isTest
public class DeliveryChecklistPDFControllerTest {
    @testSetup
    static void recordCreation(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
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
        
        list<Survey__c> sclist = TestDataFactory.createSurvey(2);
        sclist[1].Name = 'Showroom Feedback Survey';
        insert sclist;
        
        list<SurveyTaker__c> surveyTakenlist = TestDataFactory.createSurveyTaken(1);
        for(SurveyTaker__c st : surveyTakenlist){
            st.EnquiryID__c = opplist[0].Id;
        }
        insert surveyTakenlist;
        
        list<Survey_Question__c> squestionlist = TestDataFactory.createSurveyQuestion(1);
        for(Survey_Question__c sc : squestionlist){
            sc.Survey__c = sclist[0].id;
        }
        insert squestionlist;
        list<SurveyQuestionResponse__c> surveyResponseList = TestDataFactory.createSurveyQuestionAnswer(1);
        for(SurveyQuestionResponse__c sc : surveyResponseList){
            sc.Survey_Question__c = squestionlist[0].id;
            sc.SurveyTaker__c = surveyTakenlist[0].id;
        }
    }
    @isTest
    static void testFields(){
        list<opportunity> opplist = new list<opportunity>([SELECT ID from opportunity]);
        list<Survey_Question__c> squestionlist = new list<Survey_Question__c>([SELECT id,Survey__c from Survey_Question__c]);
        list<SurveyTaker__c> surveytakerlist = new list<SurveyTaker__c>([Select Enquiry__c,Enquiry__r.Customer__r.name,
                                                                         Enquiry__r.Owner.Name,Enquiry__r.Owner.Phone,
                                                                         Enquiry__r.Owner.email,Enquiry__r.Invoice_Number__c,
                                                                         Enquiry__r.Invoice_Date__c,Enquiry__r.Dealership__r.name,
                                                                         (select Remarks__c,Date_Expected__c,response__c,Survey_Question__r.Question__c,
                                                                          Survey_Question__r.OrderNumber__c 
                                                                          from Survey_Question_Answers__r
                                                                          where Survey_Question__r.Survey__c =: squestionlist[0].id
                                                                          ORDER BY Survey_Question__r.OrderNumber__c ASC)
                                                                          from SurveyTaker__c
                                                                          where Enquiry__c=:opplist[0].ID]);
        ApexPages.currentPage().getParameters().put('id',opplist[0].id);
        DeliveryChecklistPDFController del = new DeliveryChecklistPDFController();
        System.assertEquals(surveytakerlist.size(), 1);
    }
}