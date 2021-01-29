/**
    Name           :   TestOrderResponseHandler
    Author         :   
    Date           :   13 March, 2018
    Description    :   This is a test class of OrderResponseHandler Controller.
**/
@isTest
public class TestOrderResponseHandler {
    @isTest 
    public static void runTest() {
        //@21 Account record Insertion
        Account acc = new Account(Name='test');
        insert acc;
        //@21 Opportunity record Insertion
        Opportunity o = new Opportunity(AccountId = acc.Id,name = acc.name,closedate = system.today(),stagename='Prospecting');
        insert o;
        //@21 Quote record Insertion         
        Quote newQuote = new Quote(opportunityId=o.Id, GREXX_status_update__c = 'test1', name='quote test');
        insert newQuote;
        //@21 Porteringen mobiel record insertion
        Porteringen_mobiel__c pmRec = new Porteringen_mobiel__c(Name = 'Nieuw', GREXX_status_update__c = 'test1', 
                                                                    Type_aanvraag__c = 'Nieuw nummer',Offerte__c = newQuote.Id);
        insert pmRec;
        //<PhoneNumber>0620507104</PhoneNumber><DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate>
        OrderResponseHandler controller = new OrderResponseHandler('<OrderControl><StatusUpdate><ExternalOrderId>'+newQuote.Id+'</ExternalOrderId><Client><IrmaClientId></IrmaClientId><ClientStatusCode>0</ClientStatusCode></Client><Product><ExternalProductId>'+pmRec.Id+'</ExternalProductId><IrmaOrderId></IrmaOrderId><OrderStatusCode>0</OrderStatusCode><PhoneNumber>0620507104</PhoneNumber><DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate></Product></StatusUpdate></OrderControl>');
        //System.debug('##'+controller.ord);
        controller.processResponse();
    }
    @isTest 
    public static void runTest1() {
        OrderResponseHandler controller = new OrderResponseHandler('test');
    }
    @isTest 
    public static void runTest2() {
        //@21 Account record Insertion
        Account acc = new Account(Name='test');
        insert acc;
        //@21 Opportunity record Insertion
        Opportunity o = new Opportunity(AccountId = acc.Id,name = acc.name,closedate = system.today(),stagename='Prospecting');
        insert o;
        //@21 Quote record Insertion         
        Quote newQuote = new Quote(opportunityId=o.Id, GREXX_status_update__c = 'test1', name='quote test');
        insert newQuote;
        //@21 Porteringen mobiel record insertion
        Porteringen_mobiel__c pmRec = new Porteringen_mobiel__c(Name = 'Nieuw', GREXX_status_update__c = 'test1', 
                                                                    Type_aanvraag__c = 'Nieuw nummer',Offerte__c = newQuote.Id);
        insert pmRec;
        
        Mobiel_module__c mobModule = new Mobiel_module__c();
        mobModule.Portering_mobiel__c = pmRec.Id;
        mobModule.IRMA_Id__c = 'xxy123';
        mobModule.Module__c = 'Vast IP adres';
        insert mobModule;
        //<PhoneNumber>0620507104</PhoneNumber><DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate>
        OrderResponseHandler controller = new OrderResponseHandler('<OrderControl><StatusUpdate><ExternalOrderId>'+pmRec.Id+'</ExternalOrderId><Client><IrmaClientId></IrmaClientId><ClientStatusCode>0</ClientStatusCode></Client><Product><ExternalProductId>'+pmRec.Id+'</ExternalProductId><IrmaOrderId></IrmaOrderId><OrderStatusCode>0</OrderStatusCode><PhoneNumber>0620507104</PhoneNumber><DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate></Product></StatusUpdate></OrderControl>');
        //System.debug('##'+controller.ord);
        controller.processResponse();
        controller = new OrderResponseHandler('<OrderControl><StatusUpdate><ExternalOrderId>'+mobModule.Id+'</ExternalOrderId><Client><IrmaClientId></IrmaClientId><ClientStatusCode>0</ClientStatusCode></Client><Product><ExternalProductId>'+pmRec.Id+'</ExternalProductId><IrmaOrderId></IrmaOrderId><OrderStatusCode>0</OrderStatusCode><PhoneNumber>0620507104</PhoneNumber><DesiredDeliveryDate>2018-09-12</DesiredDeliveryDate><PlannedPortingDate>2018-09-12T09:00:00.000+02:00</PlannedPortingDate></Product></StatusUpdate></OrderControl>');
        //System.debug('##'+controller.ord);
        controller.processResponse();
    }
}