public class CallMeNowController{
    @AuraEnabled(cacheable=true)
    public static Boolean callNow(String telNumber){
        
        String requestBody = 'transactionId=&address='+telNumber;
        
        Http  http = new Http();   
        HttpRequest request = new HttpRequest();
           request.setEndPoint(System.Label.callmenow_endpoint+telNumber);
           request.setMethod('POST');
           request.setHeader('Content-Type', 'text/xml');    
           request.setBody(requestBody);
           
        try{
            Integer status = 0;
            
           if(!Test.isRunningTest()){
               HttpResponse response = http.send(request);
               status = response.getStatusCode();
           }else{
               status = 200;
           }
           if(status == 200){         
               return true;
           }
         }catch(Exception ex){
             System.debug('Exception Found !!' + ex.getMessage());
         }                   
        return false;
    }
}