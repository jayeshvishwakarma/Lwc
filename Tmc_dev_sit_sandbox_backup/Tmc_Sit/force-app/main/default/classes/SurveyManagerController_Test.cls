@isTest
private class SurveyManagerController_Test {
    @isTest(seeAllData=True)
    private static void doTest(){
        PageReference pageRef = Page.SurveyManagerPage;
        Test.setCurrentPage(pageRef);

        Survey__c s = new Survey__c();
        s.Name = 'test survey';
        insert s;
        ApexPages.StandardController sc = new ApexPages.StandardController(s);

        SurveyManagerController con = new SurveyManagerController(sc);
        con.save();
        message msg = con.pageMessage;
        System.assertEquals(con.surveyId, s.Id);
        
    }
    
}