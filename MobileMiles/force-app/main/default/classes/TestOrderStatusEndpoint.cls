/**
    Name           :   TestOrderStatusEndpoint 
    Author         :   
    Date           :   13 March, 2018
    Description    :   This is a test class of OrderStatusEndpoint Controller.
**/
@isTest
public class TestOrderStatusEndpoint {
    @isTest 
    public static void runTest() {
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        list<Organization> lstOrganization = [select id ,isSandbox from Organization];
        string orgUrl = URL.getSalesforceBaseUrl() +'';
        request.requestUri = orgUrl+'/services/apexrest/orderstatusendpoint/';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('');
        RestContext.request = request;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();   
        OrderStatusEndpoint.doPost();
    }
}