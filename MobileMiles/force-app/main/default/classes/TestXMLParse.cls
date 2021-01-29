/**
    Name           :   TestXMLParse
    Author         :   
    Date           :   13 March, 2018
    Description    :   This is a test class of XMLParse Controller.
**/
@isTest
public class TestXMLParse {
    @isTest 
    public static void runTest() {
        XMLParse controller = new XMLParse('<OrderControl><StatusUpdate><ExternalOrderId>0</ExternalOrderId><Client><IrmaClientId></IrmaClientId><ClientStatusCode>0</ClientStatusCode></Client><Product><ExternalProductId>null</ExternalProductId><IrmaOrderId></IrmaOrderId><OrderStatusCode>0</OrderStatusCode><PhoneNumber>0620507104</PhoneNumber><DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate></Product></StatusUpdate></OrderControl>');
    }
    @isTest 
    public static void runTest1() {
        XMLParse controller = new XMLParse('test');
    }
}