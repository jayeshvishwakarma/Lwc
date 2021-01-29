@istest
public class Msil_retryEnquiryMock implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        string strEndPoint = req.getEndpoint(); 
        if(strEndPoint.contains('composite'))
        {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        string resultData = '{"status":"Success"}';
        res.setBody(resultData);
        res.setStatusCode(200);
        return res;
        }
        else
        {
        string sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
  'xmlns="urn:partner.soap.sforce.com"' +
  'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
  '<soapenv:Body>' +
     '<loginResponse>' +
        '<result>' +
           '<passwordExpired>false</passwordExpired>' +
           '<serverUrl>https://na1.salesforce.com/services/Soap/u/10.0</serverUrl>' +
           '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
           '<userId>005D0000000nVYVIA2</userId>' +
           '<userInfo>' +
              '<!-- ... -->' +
           '</userInfo>' +
        '</result>' +
     '</loginResponse>' +
  '</soapenv:Body>' +
'</soapenv:Envelope>';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        //string resultData = '{"status":"Success"}';
        res.setBody(sessionBody );
        res.setStatusCode(200);
        return res;
        }
    }
}