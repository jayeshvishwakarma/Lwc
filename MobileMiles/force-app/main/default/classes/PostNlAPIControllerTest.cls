/**
    Name           :   PostNlAPIControllerTest
    Author         :   iBirds Services
    Date           :   5 Aug, 2019
    Description    :   This is a test class of PostNlAPIController Class.
**/
@isTest
public class PostNlAPIControllerTest{
    //Created on 5 Aug 2019 by shikha
    @isTest
    public static void runTest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        acc = [select id from account where id =: acc.id];
        
        List<PostNl_Setting__c> PostNlList = new List<PostNl_Setting__c>();
        PostNlList.add(new PostNl_Setting__c(name ='AddressType1', value__c ='01'));
        PostNlList.add(new PostNl_Setting__c(name ='AddressType2', value__c ='02'));
        PostNlList.add(new PostNl_Setting__c(name ='City', value__c ='Almere'));
        PostNlList.add(new PostNl_Setting__c(name ='CompanyName', value__c ='Cloud ÉÉN'));
        PostNlList.add(new PostNl_Setting__c(name ='Countrycode', value__c ='NL'));
        PostNlList.add(new PostNl_Setting__c(name ='HouseNr', value__c ='33'));
        PostNlList.add(new PostNl_Setting__c(name ='Street', value__c ='Wisselweg'));
        PostNlList.add(new PostNl_Setting__c(name ='Zipcode', value__c ='1314CB'));
        PostNlList.add(new PostNl_Setting__c(name ='CollectionLocation', value__c ='100538'));
        PostNlList.add(new PostNl_Setting__c(name ='ContactPerson', value__c ='van Voorst'));
        PostNlList.add(new PostNl_Setting__c(name ='CustomerCode', value__c ='DEVC'));
        PostNlList.add(new PostNl_Setting__c(name ='CustomerNumber', value__c ='11223344'));
        PostNlList.add(new PostNl_Setting__c(name ='Email', value__c ='service@cloudeen.nl'));
        PostNlList.add(new PostNl_Setting__c(name ='Name', value__c ='van Voorst'));
        PostNlList.add(new PostNl_Setting__c(name ='MessageID', value__c ='1'));
        PostNlList.add(new PostNl_Setting__c(name ='Printertype', value__c ='Zebra|GK420d'));
        PostNlList.add(new PostNl_Setting__c(name ='ContactType', value__c ='01'));
        PostNlList.add(new PostNl_Setting__c(name ='DeliveryAddress', value__c ='01'));
        PostNlList.add(new PostNl_Setting__c(name ='Weight', value__c ='1000'));
        PostNlList.add(new PostNl_Setting__c(name ='PostNl_API_Key', value__c ='VJfjh5S25WzSAAM2fSATgGtvZSHgquRE'));
        PostNlList.add(new PostNl_Setting__c(name ='PostNl_Label_Endpoint', value__c ='https://api-sandbox.postnl.nl/shipment/v2_2/label'));
        insert PostNlList;
     
     
        Bestelling_MM__c Bestelling = new Bestelling_MM__c();
        Bestelling.Status__c = 'Lopend';
        Bestelling.Bedrijf__c = acc.id;
        Bestelling.MobileMiles__c = 20.00;
        insert Bestelling;
        
        Bestelling = [select id, Bedrijf__c from Bestelling_MM__c where id =: Bestelling.id];
        PostNlAPIController pncObj = new PostNlAPIController(new ApexPages.StandardController(Bestelling));
        PostNlAPIController.createBestellingData();
        PostNlAPIController.goBack();
        
        PostNl_Setting__c postNl = [select id, name from PostNl_Setting__c where name = 'CustomerNumber'];
        postNl.value__c = '10381229';
        update postNl;
        PostNlAPIController.createBestellingData();
        
        System.assertEquals([select id from Bestelling_MM__c].size(), 1);
        System.assertEquals([select id from PostNl_Setting__c].size() > 0, true);
    }
}