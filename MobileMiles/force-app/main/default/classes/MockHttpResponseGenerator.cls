/**
    Name           :   MockHttpResponseGenerator 
    Author         :   
    Date           :   13 March, 2018
    Description    :   This is a mock class for TestOrderStatusEndpoint  test class.
**/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<OrderControl> <StatusUpdate> <ExternalOrderId>12345</ExternalOrderId> <Client> <IrmaClientId></IrmaClientId> <ClientStatusCode>0</ClientStatusCode> </Client> <Product> <ExternalProductId>CustomerID</ExternalProductId> <IrmaOrderId></IrmaOrderId> <OrderStatusCode>0</OrderStatusCode><PhoneNumber>0612345678</PhoneNumber> <DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate></Product> </StatusUpdate> </OrderControl>');
        res.setStatusCode(200);
        return res;
    }    
}