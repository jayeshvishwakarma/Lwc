@isTest(seeAlldata=False)
public class FetchSVOCDetailsTest {

    static testmethod void test(){
    
        System.debug('Inside Test');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Car_Details','TESTSVOCID','TESTSVOCID');
        //BasicReturn conti1 = (BasicReturn)FetchSVOCDetails.fetchSelectedSVOCDetails(' Car_Details','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
         
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerVehiclesList":[{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}'); 
        response.setStatusCode(200);   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        
        Object neObj = (Object)'Car_Details';
        
        FetchSVOCDetails.processResponse(strList,neObj);
         
        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
         
    }
    static testmethod void test1(){
    
        System.debug('Inside Test1');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Enquiries','TESTSVOCID','');
        //Continuation conti1 = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Enquiries','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
         
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerEnquiriesList":[{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}'); 
        response.setStatusCode(200);   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        
        Object neObj = (Object)'Enquiries';
        
        FetchSVOCDetails.processResponse(strList,neObj);
         
        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
         
    }
    static testmethod void test2(){
    
        System.debug('Inside Test2');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Car_Details','','TESTSVOCID');
        //Continuation conti1 = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Enquiries','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
         
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerEnquiriesList":[{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}'); 
        response.setStatusCode(20);   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        
        Object neObj = (Object)'Enquiries';
        
        FetchSVOCDetails.processResponse(strList,neObj);
         
        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
         
    }
    static testmethod void test3(){
    
        System.debug('Inside Test3');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('EW','TESTSVOCID','TESTSVOCID');
        //BasicReturn conti1 = (BasicReturn)FetchSVOCDetails.fetchSelectedSVOCDetails(' Car_Details','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
         
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerVehiclesList":[{"VIN":"abcde","Penetration":{"EWPenetration":{"3rdYear":false, "4thYear":false, "5thYear":false}},"Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}'); 
        response.setStatusCode(200);   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        
        List<String> strList = new list<String>();
        strList.add('Continuation-1');
        
        Object neObj = (Object)'EW';
        
        FetchSVOCDetails.processResponse(strList,neObj);
         
        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
         
    }
}