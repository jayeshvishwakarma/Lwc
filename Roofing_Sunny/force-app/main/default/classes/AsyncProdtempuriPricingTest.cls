@isTest
public class AsyncProdtempuriPricingTest{
    static testmethod void testmethodAsyncProdtempuriPricing(){
        AsyncProdtempuriPricing app = new AsyncProdtempuriPricing(); 
        AsyncProdtempuriPricing.responsesResponse_elementFuture   rre = new AsyncProdtempuriPricing.responsesResponse_elementFuture();
        //rre.getValue();
        AsyncProdtempuriPricing.AsyncPriceAreaPricingImplSoap appi = new AsyncProdtempuriPricing.AsyncPriceAreaPricingImplSoap();
        Continuation con = new Continuation(120);
        try{
        appi.beginResponses(con,'','','','','','','');
        rre.getValue();
        }catch (exception e){}
    }
}