@RestResource(urlMapping='/orderstatusendpoint/*')
global without sharing class OrderStatusEndpoint { 
  
  @HttpPost
    global static void doPost() {
        system.debug('@@@@ ' + RestContext.request.requestBody.toString());
        
        OrderResponseHandler orh = new OrderResponseHandler(RestContext.request.requestBody.toString());
        try{
            orh.processResponse();
        }catch(exception e){
            system.debug(e.getMessage());
        }
    }
}