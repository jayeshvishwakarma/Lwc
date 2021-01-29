@isTest
public class prodtempuriPricingTest{
    static testmethod void testmethodprodtempuriPricing(){
        prodtempuriPricing ptp = new prodtempuriPricing();
        prodtempuriPricing.responses_element rel = new prodtempuriPricing.responses_element();
        prodtempuriPricing.responsesResponse_element rre = new prodtempuriPricing.responsesResponse_element();
        prodtempuriPricing.PriceAreaPricingImplSoap ppi = new prodtempuriPricing.PriceAreaPricingImplSoap();
        try{
        ppi.responses('','','','','','','');
        } catch (Exception e){}
    }
}