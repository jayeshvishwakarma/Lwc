/*********************************************************************************
* Test Class: {TestProductAvailability}
* Created by {DateCreated 12/03/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ProductAvailability.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/03/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest 
private class TestProductAvailability {

    static testMethod void methodA() {
       
        ProductAvailability ps = new ProductAvailability();
        Region__c rnc = TestClassUtility.createRegion('test region name','test region code', true);
        Territory__c tc = TestClassUtility.createTerritory('jackson', '2656', 'land', rnc.Id, true);
        //Large_Job_Quote__c lq = TestClassUtility.createLargeJobQuote(tc.Id,null,null,null,null,null,null,null,null,null,null,null,null, true);
        User us=  TestClassUtility.createTestUser('Contract Manager','Danthony','rbommareddy@thresholdcs.com','Anthony','rbommareddy@thresholdcs.com','Pricing Manager',true);
        Plants__c wh =  TestClassUtility.createWarehouse('TEST',us.id, true);
        //Market_Class__c mc= TestClassUtility.createMarketClass('test', true);
        //Product_Stocked_Plant__c psp = TestClassUtility.createProductStockedPlant(wh.id, true);
        Product2 product = TestClassUtility.createProduct2('test', true);
       // Product_Type__c pt= TestClassUtility.createProductType('test','test','test',mc.id, true );
        //product.Product_Type__c = pt.Id;
        update product;
        //psp.Product__c = product.Id;
        //update psp;
       // ps.productTypeId = pt.Id;
        ps.plantId = wh.id;
        ps.itemDescriptionId = product.Id;
       // ps.marketClassId = mc.Id;
        ApexPages.currentPage().getParameters().put('territoryId',tc.id);
        ps.onPageLoad();
        ps.showSearchResultView();
        ps.searchProducts();
        ps.reset();
        ps.refreshSelectOptions();
        ps.refreshPage();
        ps.searchProducts();
        ps.plantId = wh.id;
        ps.searchProducts();
        System.assertEquals(rnc.Name, 'test region name');
    }
    static testMethod void methodB() {
       
        ProductAvailabilityResponse paRes = new ProductAvailabilityResponse();
        paRes.Plant = 'test';
        paRes.Material = 'test';
        paRes.UOM = 'test';
        paRes.Date_x = 'test';
        paRes.AvailQty = 10.0;
        
        PA_tempuriOrg.responsesResponse_element resObj = new PA_tempuriOrg.responsesResponse_element(); 
        PA_tempuriOrg.ArrayOfZTSD_STOCK_AV arrayOfZTSDObj = new PA_tempuriOrg.ArrayOfZTSD_STOCK_AV();
    }
}