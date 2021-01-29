/*********************************************************************************
* Test Class: {TestCustomerPricing}
* Created by   {DateCreated 12/04/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of CustomerPricing.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/04/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestCustomerPricing {

    static testMethod void myUnitTest() {
        CustomerPricing cp = new CustomerPricing();
        cp.part = 'test';
        cp.idc = 'test';
        cp.payer = 'test';
        cp.shipto = 'test';
        cp.soldto = 'test';
        cp.division = 'test';
        cp.material = 'test';
        cp.message = 'test';
        cp.ivdate = 'test';
        cp.plant = 'test';    
        cp.searchProducts();
        CustomerResponse cr = new CustomerResponse();
        cr.Plant = 'test';
        cr.SalesOrg = 'test';
        cr.District = 'test';
        cr.ItemClass = 'test';
        cr.Material = 'test';
        cr.Idc = 'test';
        cr.UnitAreaPrice = 10.0;
        cr.UnitCurrency = 'test';
        cr.UnitPriceUom = 'test';
        cr.SapSelPrice = 10.0;
        cr.SapSelCurr = 'test';
        cr.SapSelUom = 'test';
        cr.Message = 'test';
        cr.Number_x = 'test'; 
        cr.Type = 'test'; 
        cr.LogMsgNo = 'test';
    }
}