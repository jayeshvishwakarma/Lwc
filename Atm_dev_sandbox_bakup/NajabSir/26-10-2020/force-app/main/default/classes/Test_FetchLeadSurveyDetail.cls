/*
 * Name  : Test_FetchLeadSurveyDetail.cls
 * Author: 
 * Description: Test_FetchLeadSurveyDetail test class is created to test FetchLeadSurveyDetail apex class.

Date		Author		Comments
------------------------------------------
13/10/2020				Initial Release
*/
@isTest
private class Test_FetchLeadSurveyDetail {
    @isTest static void test_getDetails(){
        Lead leadObj = new Lead();
        leadObj.FirstName = 'Test';
        leadObj.lastName = 'Lead';
        leadObj.Salutation = 'Mr.';
        leadObj.Buyer_Type__c = '';
        //leadObj.ti
        insert leadObj;
    }
}