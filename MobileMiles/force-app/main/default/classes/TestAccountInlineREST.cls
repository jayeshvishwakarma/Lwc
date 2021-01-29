@isTest
public class TestAccountInlineREST{
    @IsTest(SeeAllData=true)
    static void test(){
        Account acc= [select id from Account limit 1];
        String resultData = '';
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = Label.service_url + '/services/apexrest/RestInvoiceService'; 
            req.params.put('id', acc.id);
            req.params.put('obj', 'SalesInvoice');
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req;
            RestContext.response = res;
            resultData = AccountInlineREST.getAccountChildList();
            
            req.params.put('obj', 'PayableInvoice');
            resultData = AccountInlineREST.getAccountChildList();
            
            req.params.put('obj', 'SalesCreditNote');
            resultData = AccountInlineREST.getAccountChildList();
            
            req.params.put('obj', 'PayableCreditNote');
            resultData = AccountInlineREST.getAccountChildList();
       Test.stopTest();   
   
    }
}