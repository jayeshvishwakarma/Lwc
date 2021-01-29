@isTest
public class JITMuleSoftIntegrationTest {
@isTest
    static void genericJITCall(){
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Continuation res = (Continuation)JITMuleSoftIntegration.genericJITCall('Job_Card','','{"regNumber":"1234","limit":5}','');
        Map<String, HttpRequest> requests = res.getRequests();
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');
        
        response.setStatusCode(200);   
        Test.setContinuationResponse('Continuation-1', response);
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        //Object neObj = (Object)'FetchTimeSlot';
        JITMuleSoftIntegration.processResponse(strList);
		
    }
    @isTest
    static void genericJITCall1(){
        Continuation res = (Continuation)JITMuleSoftIntegration.genericJITCall('Cancel_Appointment','','','1234');
        Map<String, HttpRequest> requests = res.getRequests();
        HttpResponse response = new HttpResponse();
        response.setBody('{"errorCode":401,"correlationId":"12345"}');
        
        response.setStatusCode(401);   
        Test.setContinuationResponse('Continuation-1', response);
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        //Object neObj = (Object)'FetchTimeSlot';
        JITMuleSoftIntegration.processResponse(strList);
    }
}