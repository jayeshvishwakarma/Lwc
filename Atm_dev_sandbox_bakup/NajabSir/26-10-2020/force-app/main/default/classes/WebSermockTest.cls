@isTest
global class WebSermockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request)
    {
        HttpResponse response=new HttpResponse();
        response.setHeader('content-type', 'application/json');
        String tdate =String.ValueOf(System.today().addDays(1));
            
      //  'availableslots=({bookingDate=2019-10-14, timeSlots=({fromTime=17:30, toTime=18:00}, {fromTime=18:00, toTime=18:30}, {fromTime=18:30, toTime=19:00}, {fromTime=19:00, toTime=19:30}, {fromTime=19:30, toTime=20:00}, {fromTime=20:00, toTime=20:30}, {fromTime=20:30, toTime=21:00}, {fromTime=21:00, toTime=21:30}, {fromTime=21:30, toTime=22:00}, {fromTime=22:00, toTime=22:30})}'
        String str ='{ "messageId": "dsvsdvsvsdvsdvsdvsdv", "status": "Success", "availableslots": [ { "bookingDate": "'+tdate+'", "timeSlots": [ { "fromTime": "19:00", "toTime": "19:30" }, { "fromTime": "21:00", "toTime": "21:30" } ] } ] }';
        response.setBody(str);
        response.setStatusCode(200);
        return response;
        
    }
    

}