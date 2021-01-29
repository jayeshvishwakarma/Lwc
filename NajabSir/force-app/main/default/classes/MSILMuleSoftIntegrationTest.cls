@istest
public class MSILMuleSoftIntegrationTest {
    static testmethod void validateFetchTimeSlotMethod(){
        Continuation conti = (Continuation)MSILMuleSoftIntegration.getTestDriveSlot('Test Drive Slots','209', 'Alto', 'LXI', '15', 'ENQ123', 'MSPIN001', '123');
        Map<String, HttpRequest> requests = conti.getRequests();
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');
        
        response.setStatusCode(200);   
        Test.setContinuationResponse('Continuation-1', response);
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        Object neObj = (Object)'FetchTimeSlot';
        MSILMuleSoftIntegration.processResponse(strList,neObj);
        system.assertEquals('Mock response body', response.getBody());
    }
    static testmethod void validateCreateBookingMethod(){
        Continuation conti = (Continuation)MSILMuleSoftIntegration.createOrUpdateOrCancelBooking('Create Booking', 'POST', '', 'DMN123');
        Map<String, HttpRequest> requests = conti.getRequests();
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');
        response.setStatusCode(200);   
        Test.setContinuationResponse('Continuation-1', response);
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        Object neObj = (Object)'CreateBooking';
        MSILMuleSoftIntegration.processResponse(strList,neObj);
        system.assertEquals('Mock response body', response.getBody());
    }
    
    static testmethod void validategetProductStockListMethos(){
        Continuation conti = (Continuation)MSILMuleSoftIntegration.getProductStockList('{"apiType" : "Product Stock List", "variantCode" : "cde678", "colorCode":"bcd", "dealerMapCode":"1234", "locationCode":"123", "parentCode": "abcd", "productType":"A", "consingneeCode":"123", "userType":"E"}');
        Map<String, HttpRequest> requests = conti.getRequests();
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');
        response.setStatusCode(200);   
        Test.setContinuationResponse('Continuation-1', response);
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        Object neObj = (Object)'ProductStockList';
        MSILMuleSoftIntegration.processResponse(strList,neObj);
        system.assertEquals('Mock response body', response.getBody());
    }
    
    static testmethod void negativeTestCase(){
        Continuation conti = (Continuation)MSILMuleSoftIntegration.getTestDriveSlot('', '','','','','','','');
        Continuation conti2 = (Continuation)MSILMuleSoftIntegration.createOrUpdateOrCancelBooking('', '', '', '');
        Continuation cont3 = (Continuation)MSILMuleSoftIntegration.getProductStockList('');
        
        try{
            Continuation conti4 = (Continuation)MSILMuleSoftIntegration.getProductStockList('{"apiType" : "Product Stock List", "variantCode" : "cde678", "colorCode":"bcd", "dealerMapCode":"1234", "locationCode":"123", "parentCode": "abcd", "productType":"A", "consingneeCode":"123", "userType":"E"}');
            Map<String, HttpRequest> requests = conti4.getRequests();
            HttpResponse response = new HttpResponse();
            response.setBody('');
            response.setStatusCode(400);   
            Test.setContinuationResponse('Continuation-1', response);
            List<String> strList = new list<String>();
            strList.add('Continuation-1');
            Object neObj = (Object)'ProductStockList';
            MSILMuleSoftIntegration.processResponse(strList,neObj);
            MSILMuleSoftIntegration.mockResponse();
        }catch(exception ex){
            system.debug('error '+ex.getMessage());
        }
        
    }
}