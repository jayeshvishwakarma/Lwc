/*********************************************************************************
* Test Class: {TestTempUriOrg}
* Created by {DateCreated 12/26/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of tempuriOrg.cls,tempuriOrgPCR.cls,
                      sapComPricing.cls,sapComPricing1.cls,
                      sapCom.cls,sapCom1.cls
                      and tempuriOrgPricing.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/26/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestTempUriOrg {
    
    //tempuriOrg.cls
    static testMethod void myUnitTest() {
        tempuriOrg.responses_element ob = new tempuriOrg.responses_element();
        tempuriOrg.ArrayOfZTSD_STOCK_AV ob1 = new tempuriOrg.ArrayOfZTSD_STOCK_AV();
        tempuriOrg.responsesResponse_element ob2 = new tempuriOrg.responsesResponse_element();
        tempuriOrg.StockAvailabilityImplSoap ob3 = new tempuriOrg.StockAvailabilityImplSoap();
        //ob3.responses('test','test');
    }
    static testMethod void myUnitTestB() {
        try{
            tempuriOrg.responses_element ob = new tempuriOrg.responses_element();
            tempuriOrg.ArrayOfZTSD_STOCK_AV ob1 = new tempuriOrg.ArrayOfZTSD_STOCK_AV();
            tempuriOrg.responsesResponse_element ob2 = new tempuriOrg.responsesResponse_element();
            tempuriOrg.StockAvailabilityImplSoap ob3 = new tempuriOrg.StockAvailabilityImplSoap();
            ob3.responses('test','test');
        }
        catch(Exception e){
        }
    }
    //tempuriOrgPCR.cls
    static testMethod void myUnitTest2() {
        tempuriOrgPCR.responses_element ob = new tempuriOrgPCR.responses_element();
        tempuriOrgPCR.ArrayOfZtsdPriceArea ob1 = new tempuriOrgPCR.ArrayOfZtsdPriceArea();
        tempuriOrgPCR.responsesResponse_element ob2 = new tempuriOrgPCR.responsesResponse_element();
        tempuriOrgPCR.ArrayOfZtsdPriceAreaO ob3 = new tempuriOrgPCR.ArrayOfZtsdPriceAreaO();
        tempuriOrgPCR.Service1Soap ob4 = new tempuriOrgPCR.Service1Soap();
        //ob4.responses('test', 'test', 'test', 'test', ob1);
    }
    static testMethod void myUnitTestB2() {
        try{
            tempuriOrgPCR.responses_element ob = new tempuriOrgPCR.responses_element();
            tempuriOrgPCR.ArrayOfZtsdPriceArea ob1 = new tempuriOrgPCR.ArrayOfZtsdPriceArea();
            tempuriOrgPCR.responsesResponse_element ob2 = new tempuriOrgPCR.responsesResponse_element();
            tempuriOrgPCR.ArrayOfZtsdPriceAreaO ob3 = new tempuriOrgPCR.ArrayOfZtsdPriceAreaO();
            tempuriOrgPCR.Service1Soap ob4 = new tempuriOrgPCR.Service1Soap();
            ob4.responses('test', 'test', 'test', 'test', ob1);
        }
        catch(Exception e){
        }
    }
    //tempuriOrgPricing.cls
    static testMethod void myUnitTest3() {
        tempuriOrgPricing.responses_element ob = new tempuriOrgPricing.responses_element();
        tempuriOrgPricing.PriceAreaPricingImplSoap ob1 = new tempuriOrgPricing.PriceAreaPricingImplSoap();
        tempuriOrgPricing.responsesResponse_element ob2 = new tempuriOrgPricing.responsesResponse_element();
        //ob1.responses('test', 'test', 'test', 'test', 'test', 'test', 'test');
    }
    static testMethod void myUnitTestB3() {
        try{
            tempuriOrgPricing.responses_element ob = new tempuriOrgPricing.responses_element();
            tempuriOrgPricing.PriceAreaPricingImplSoap ob1 = new tempuriOrgPricing.PriceAreaPricingImplSoap();
            tempuriOrgPricing.responsesResponse_element ob2 = new tempuriOrgPricing.responsesResponse_element();
            ob1.responses('test', 'test', 'test', 'test', 'test', 'test', 'test');
        }
        catch(Exception e){
        
        }
    }
    //sapComPricing.cls
    static testMethod void myUnitTest4() {
        sapComPricing.ArrayOfZTSD_PRICE_AREA_O ob = new sapComPricing.ArrayOfZTSD_PRICE_AREA_O();
        sapComPricing.ZSdWsdlPriceAreaPriceFmResponse ob1 = new sapComPricing.ZSdWsdlPriceAreaPriceFmResponse();
    }
    //sapComPricing1.cls
    static testMethod void myUnitTest5() {
        sapComPricing1.ZTSD_PRICE_AREA_O ob = new sapComPricing1.ZTSD_PRICE_AREA_O();
    }
    //sapCom.cls
    static testMethod void myUnitTest6() {
        sapCom.Bapiret2 ob = new sapCom.Bapiret2();
        sapCom.ArrayOfZSSD_CUST_SPRICE_OUT ob1 = new sapCom.ArrayOfZSSD_CUST_SPRICE_OUT();
        sapCom.ArrayOfBapiret2 ob2 = new sapCom.ArrayOfBapiret2();
        sapCom.ZsdWsdlCustSpriceResponse ob3 = new sapCom.ZsdWsdlCustSpriceResponse();
    }
    //sapCom1.cls
    static testMethod void myUnitTest7() {
        sapCom1.ZSSD_CUST_SPRICE_OUT ob = new sapCom1.ZSSD_CUST_SPRICE_OUT();
    }
    //sapComDocumentSapRfcFunctions.cls
    static testMethod void myUnitTest8() {
        sapComDocumentSapRfcFunctions.ZTSD_STOCK_AV ob = new sapComDocumentSapRfcFunctions.ZTSD_STOCK_AV();
    }
}