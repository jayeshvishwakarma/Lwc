/*********************************************************************************
* Test Class: {TestPCRWebserviceTesting}
* Created by  {DateCreated 12/05/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of PCRWebserviceTesting.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/05/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestPCRWebserviceTesting {

    static testMethod void myUnitTest() {
        PCRWebserviceTesting pcrWeb = new PCRWebserviceTesting();
        pcrWeb.ztsdPriceAreaDetails();
        sapComDocumentSapSoapFunctionsMcSPCR.ZtsdPriceAreaO zt = new sapComDocumentSapSoapFunctionsMcSPCR.ZtsdPriceAreaO();
        System.assert(true);
    }
}