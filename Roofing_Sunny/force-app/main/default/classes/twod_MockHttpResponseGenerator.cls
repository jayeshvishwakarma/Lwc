@isTest
global class twod_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Records":[{"AddressExtras":" ","AddressKey":"12345000199","AddressLine1":"Street","AddressLine2":" ","City":"Schenectady","CompanyName":" ","EmailAddress":"i.santhosh94@gmail.com","MelissaAddressKey":"4691137080","NameFull":" ","PhoneNumber":" ","PostalCode":"12345-0001","RecordExtras":" ","RecordID":"1","Reserved":" ","Results":"AC02,AC03,AS01,ES01","State":"NY"}],"TotalRecords":"1","TransmissionReference":" ","TransmissionResults":" ","Version":"4.0.25"}');
        res.setStatusCode(200);
        return res;
    }
}