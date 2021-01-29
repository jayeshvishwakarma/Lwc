@istest
public class Msil_FpmIntegrationMock implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        string resultData = '{"status":"Success","message":"loan fetched","loan_status":[{"status":"applied"}]}';
        res.setBody(resultData);
        res.setStatusCode(200);
        return res;
    }
}