@isTest
public class QuoteViewAgreementRedirectControllerTest {
private static testMethod void QuoteViewAgreementRedirectControllerTestMehord() {
    test.startTest();
    PageReference pageRef = Page.cloudeen_overeenkomst;

    Opportunity opp = new Opportunity(name='TestOpp',StageName='IsWon',CloseDate=system.today());
    insert opp;
    quote qt = new quote(Name='Quotes',OpportunityId=opp.id);
    insert qt;
    EZSign__Signature__c  esigObj = new EZSign__Signature__c(Legitimatienummer__c='1234', EZSign__Parent_Id__c = 'Test', EZSign__Signature_Key__c = 'test');
    insert esigObj;
    
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('id',esigObj.id);
    ApexPages.StandardController sc = new ApexPages.standardController(qt);
    QuoteViewAgreementRedirectController  controller = new QuoteViewAgreementRedirectController(sc);
//    System.assertNotEquals(null,controller.redirect());
	controller.redirect();
    
    test.stopTest();
}
    
}