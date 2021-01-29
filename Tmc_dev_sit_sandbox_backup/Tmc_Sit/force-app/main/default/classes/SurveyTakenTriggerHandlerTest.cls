@isTest
public class SurveyTakenTriggerHandlerTest {
    @testSetup
    static void createRecord(){
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
        
        Survey__c surv = new Survey__c(Name = 'Showroom Feedback Survey');
        insert surv;
        
        list<SurveyTaker__c> surveyTakenlist = TestDataFactory.createSurveyTaken(1);
        for(SurveyTaker__c st : surveyTakenlist){
            st.EnquiryID__c = opplist[0].Id;
        }
        insert surveyTakenlist;
    }
    
    @isTest
    static void testLookupFields(){
        list<SurveyTaker__c> surveyTakenList = new list<SurveyTaker__c>([SELECT id,Enquiry__c,Customer__c,Dealer__c from SurveyTaker__c]);
        list<opportunity> opplist = new list<opportunity>([SELECT id,Customer__c,Dealership__c from opportunity]);
        System.assertEquals(surveyTakenList[0].Enquiry__c, opplist[0].id);
        System.assertEquals(surveyTakenList[0].Customer__c, opplist[0].Customer__c);
        System.assertEquals(surveyTakenList[0].Dealer__c, opplist[0].Dealership__c);
    }
}