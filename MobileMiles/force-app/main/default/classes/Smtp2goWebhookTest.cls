/*

    Name    : Smtp2goWebhookTest
    Description: Test class for Smtp2goWebhook
*/

@istest
public class Smtp2goWebhookTest{
    
    @testsetup
    public static void testData(){
        Account account = new Account(name='test account');
        insert account;
        
        Opportunity opp = new Opportunity(name='Opp1', accountid=account.id, StageName='WON', CloseDate=Date.today());
        insert opp;
        
        Quote quote = new Quote(name='quote1 opp1', opportunityId=opp.id, Looptijd__c = '1 jaar',heeft_verbinding__c = true);
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        
    }
    
    public Static testMethod void testUnit(){
        
        Test.startTest();
        Quote qt = [SELECT id, QuoteNumber from Quote LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Smtp2goWebhook'; 
        req.params.put('Subject', '98765 ' + qt.QuoteNumber);
        req.params.put('read-secs', '3');
        req.params.put('time', '2019-01-28T07:34:34Z');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        Smtp2goWebhook.receivePOST();
        Test.stopTest(); 
        System.assert([Select id from Task where WhatId =: qt.Id].size() == 1);
        
    }
}