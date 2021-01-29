/****************************************************************************************
* @Author       Dru Luce-Edwards
* @Date         November 13, 2016
* @Description  Test coverage for WS
* ***************************************************************************************/
@isTest
public class WSTest{
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Load the initial test data in setup method
    * ***************************************************************************************/
    @testSetup
    static void loadTestData() {
        //No setup needed
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Test coverage for WS siding price call
    *    Assert valid and invalid returns on a single call
    * ***************************************************************************************/
    public static testMethod void testSidingPriceCall(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Customer_Price_Endpoint__c='http://sap-wddev.certainteed.com/sap/EQR100/SFDCPricingRequest'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.SIDINGPRICECALL));
            
            //Create the test request
            try{
                WS.PricingRequest request = new WS.PricingRequest();
                request.lstMaterials = new List<Integer>{955,403675,403676,403677,403678,403679,403680,403681,633623,966}; //Matnr
                request.strShipTo = '1002453'; //IvShipto
                request.strSoldTo = '2007485'; //IvSoldto
                request.strDistChannel = '01'; //IvVtweg
                request.strSalesOrg = '1502'; //IvSorg
                request.strDivision = '16'; //IvSpart
                request.isRoofing = false;
                WS.PricingResponse r = WS.doPriceCall(request);
                if(r.mapSuccesses.containsKey(403675)){
                    WS.PricingSuccess ps = r.mapSuccesses.get(403675);
                    System.assertEquals(ps.intMaterial, 403675); //403675 //Matnr
                    System.assertEquals(ps.strType, 'ZP01'); //ZP01 //Kschl
                    System.assertEquals(ps.decPrice, 88.77); //88.77 //CondValue
                    System.assertEquals(ps.strCurrency, 'USD'); //USD //Currency
                    System.assertEquals(ps.strUOM, 'CAR'); //CAR //CondUnit
                    System.assertEquals(ps.intAccessSeq, 15); //15 //AccessSeq
                    System.assertEquals(ps.dtBi, Date.newInstance(2018,12,31)); //2018-12-31 //Datbi
                    System.assertEquals(ps.strDText, 'Sales org./Division/Sold-to pt/Ship-to/Material'); //Sales org./Division/Sold-to pt/Ship-to/Material //DdText
                    System.assertEquals(ps.strMessage, null); //null //Message
                }
                for(Integer i = 0; i < r.lstErrors.size(); i++){
                    WS.PricingError pe = r.lstErrors[i];
                    if(i == 0){
                        System.assertEquals(pe.strType, 'W'); //W //Type
                        System.assertEquals(pe.strMessage, 'Invalid Material  Number. 955'); //Invalid Material  Number. 955 //Message + MessageV1 through MessageV5
                    } else if(i == 1){
                        System.assertEquals(pe.strType, 'W'); //W //Type
                        System.assertEquals(pe.strMessage, 'Invalid Material  Number. 966'); //Invalid Material  Number. 966 //Message + MessageV1 through MessageV5
                    }
                }
            } catch (WS.WSException e){
                System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Test coverage for WS roofing customer price call success
    *    Assert valid return
    * ***************************************************************************************/
    public static testMethod void testRoofingCustomerPriceCallSuccess(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Customer_Price_Endpoint__c='http://sap-wddev.certainteed.com/sap/qa/RPGSFDCPricingRequest',
            Area_Price_Endpoint__c='http://sap-wddev.certainteed.com/Prod_Price_Area_Pricing/PriceAreaPricing.asmx'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ROOFINGCUSTOMERPRICECALLSUCCESS));
            
            //Create the test request
            try{
                WS.PricingRequest request = new WS.PricingRequest();
                request.lstMaterials = new List<Integer>{410763}; //IvMat //Material
                request.strShipTo = '1002988'; //IvShipto //
                request.strSoldTo = '1002988'; //IvSoldto //
                request.strPlant = '0262'; //IvPlant //IPlant
                request.strIdc = 'RV1'; //IvIdc //Idc
                request.strDivision = '30'; //IvSpart //ItemClass
                request.strDistChannel = '01'; //IvSdist //
                request.strDistrict = '405';  // //ISdist
                request.strSalesOrg = '1501'; //IvSorg //ISorg
                request.isRoofing = true;
                WS.PricingResponse r = WS.doPriceCall(request);
                if(r.mapSuccesses.containsKey(410763)){
                    WS.PricingSuccess ps = r.mapSuccesses.get(410763);
                    System.assertEquals(ps.intMaterial, 410763); //410763 //Material
                    System.assertEquals(ps.decPrice, 65.0); //65.0 //SAP_SEL_PRICE
                    System.assertEquals(ps.strCurrency, 'USD'); //USD //SAP_SEL_CURR
                    System.assertEquals(ps.strUOM, 'KAR'); //KAR //SAP_SEL_UOM
                    System.assertEquals(ps.dtBi, Date.newInstance(2016,11,14)); //2016-11-14 //EFF_DATE
                }
            } catch (WS.WSException e){
                System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Test coverage for WS roofing customer price call error
    *    Assert invalid return
    * ***************************************************************************************/
    public static testMethod void testRoofingCustomerPriceCallError(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Customer_Price_Endpoint__c='http://sap-wddev.certainteed.com/sap/qa/RPGSFDCPricingRequest',
            Area_Price_Endpoint__c='http://sap-wddev.certainteed.com/Prod_Price_Area_Pricing/PriceAreaPricing.asmx'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ROOFINGCUSTOMERPRICECALLERROR));
            
            //Create the test request
            try{
                WS.PricingRequest request = new WS.PricingRequest();
                request.lstMaterials = new List<Integer>{410763}; //IvMat //Material
                request.strShipTo = '1002988'; //IvShipto //
                request.strSoldTo = '1002988'; //IvSoldto //
                request.strPlant = '0262'; //IvPlant //IPlant
                request.strIdc = 'RV1'; //IvIdc //Idc
                request.strDivision = '30'; //IvSpart //ItemClass
                request.strDistChannel = '01'; //IvSdist //
                request.strDistrict = '405';  // //ISdist
                request.strSalesOrg = '1501'; //IvSorg //ISorg
                request.isRoofing = true;
                WS.PricingResponse r = WS.doPriceCall(request);
                for(Integer i = 0; i < r.lstErrors.size(); i++){
                    WS.PricingError pe = r.lstErrors[i];
                    if(i == 0){
                        System.assertEquals(pe.strType, 'E'); //E //Type
                        System.assertEquals(pe.strMessage, 'Invalid Material/IDC.'); //Invalid Material/IDC. //Message + MessageV1 through MessageV5
                    } else if(i == 1){
                        System.assertEquals(pe.strType, 'E'); //E //Type
                        System.assertEquals(pe.strMessage, 'Invalid Material/Plan/Division'); //Invalid Material/Plan/Division //Message + MessageV1 through MessageV5
                    }
                }
            } catch (WS.WSException e){
                System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Test coverage for WS roofing area price call success, area price call does not return errors no test method for area price error
    *    Assert valid return
    * ***************************************************************************************/
    public static testMethod void testRoofingAreaPriceCallSuccess(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Customer_Price_Endpoint__c='http://sap-wddev.certainteed.com/sap/qa/RPGSFDCPricingRequest',
            Area_Price_Endpoint__c='http://sap-wddev.certainteed.com/Prod_Price_Area_Pricing/PriceAreaPricing.asmx'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ROOFINGAREAPRICECALLSUCCESS));
            
            //Create the test request
            try{
                WS.PricingRequest request = new WS.PricingRequest();
                request.lstMaterials = new List<Integer>{619565}; //IvMat //Material
                request.strPlant = '0262'; //IvPlant //IPlant
                request.strIdc = 'R3M'; //IvIdc //Idc
                request.strDivision = '40'; //IvSpart //ItemClass
                request.strDistrict = '405';  // //ISdist
                request.strSalesOrg = '1501'; //IvSorg //ISorg
                request.isRoofing = true;
                WS.PricingResponse r = WS.doRoofingAreaPriceCall(request);
                if(r.mapSuccesses.containsKey(619565)){
                    WS.PricingSuccess ps = r.mapSuccesses.get(619565);
                    System.assertEquals(ps.intMaterial, 619565); //619565 //Material
                    System.assertEquals(ps.decPrice, 69.0); //69.0 //SAP_SEL_PRICE
                    System.assertEquals(ps.strCurrency, 'USD'); //USD //SAP_SEL_CURR
                    System.assertEquals(ps.strUOM, 'ROL'); //ROL //SAP_SEL_UOM
                    System.assertEquals(ps.dtBi, Date.newInstance(2016,11,14)); //2016-11-14 //EFF_DATE
                }
            } catch (WS.WSException e){
                System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Test coverage for WS order call Success
    *    Assert valid return
    * ***************************************************************************************/
    public static testMethod void testOrderCallSuccess(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Order_Endpoint__c='http://sap-wddev.certainteed.com/qa/WarrantyOrder'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ORDERCALLSUCCESS));
            
            //Create the test request
            try{
                WS.OrderRequest request = new WS.OrderRequest();
                WS.OrderLine oli = new WS.OrderLine();
                oli.strMaterial = 'WARRANTY  - VINYL'; //Matnr
                oli.decQuantity = 11; //Kwmeng
                oli.decPrice = 13.55; //Kbetr
                oli.strUOM = null; //Vrkme
                request.lstOrdLines = new List<WS.OrderLine>{oli};
                WS.OrderNote oNote = new WS.OrderNote();
                oNote.strId = 'Z006'; //TDID
                oNote.strText = 'TEST Z006-1'; //TDLINE
                request.lstOrdNotes = new List<WS.OrderNote>{oNote};
                request.strType = 'ZCR'; //Auart
                request.strShipTo = '1002453'; //KunnrSh
                request.strSoldTo = '2007485'; //KunnrSp
                request.strOrdReason = 'Z49'; //Augru
                request.strPONumber = 'TEST PO-101'; //Bstkd
                request.strName = 'My Name'; //Bname
                request.strShipCondition = 'Z2'; //Vsbed
                request.strSalesOrg = '1502'; //Vkorg
                request.strDistChannel = '01'; //Vtweg
                request.strDivision = '01'; //Spart
                WS.OrderResponse r = WS.doOrderCall(request);
                System.assertEquals(r.intOrderNumber, 60052734); //60052734 //GvVbeln
            } catch (WS.WSException e){
               // System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Test coverage for WS order call error
    *    Assert invalid return
    * ***************************************************************************************/
    public static testMethod void testOrderCallError(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Order_Endpoint__c='http://sap-wddev.certainteed.com/qa/WarrantyOrder'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ORDERCALLERROR));
            
            //Create the test request
            try{
                WS.OrderRequest request = new WS.OrderRequest();
                WS.OrderLine oli = new WS.OrderLine();
                oli.strMaterial = 'WARRANTY - VINYL'; //Matnr //This is the error there are actually 2 spaces between WARRANTY and -
                oli.decQuantity = 11; //Kwmeng
                oli.decPrice = 13.55; //Kbetr
                oli.strUOM = null; //Vrkme
                request.lstOrdLines = new List<WS.OrderLine>{oli};
                WS.OrderNote oNote = new WS.OrderNote();
                oNote.strId = 'Z006'; //TDID
                oNote.strText = 'TEST Z006-1'; //TDLINE
                request.lstOrdNotes = new List<WS.OrderNote>{oNote};
                request.strType = 'ZCR'; //Auart
                request.strShipTo = '1002453'; //KunnrSh
                request.strSoldTo = '2007485'; //KunnrSp
                request.strOrdReason = 'Z49'; //Augru
                request.strPONumber = 'TEST PO-101'; //Bstkd
                request.strName = 'My Name'; //Bname
                request.strShipCondition = 'Z2'; //Vsbed
                request.strSalesOrg = '1502'; //Vkorg
                request.strDistChannel = '01'; //Vtweg
                request.strDivision = '01'; //Spart
                WS.OrderResponse r = WS.doOrderCall(request);
                for(Integer i = 0; i < r.lstErrors.size(); i++){
                    WS.OrderError oe = r.lstErrors[i];
                    if(i == 0){
                        System.assertEquals(oe.strType, 'E'); //E //Type
                        System.assertEquals(oe.strMessage, 'Material WARRANTY - VINYL is not defined for sales org.1502,  distr.chan.01,  language EN'); //Material WARRANTY - VINYL is not defined for sales org.1502,  distr.chan.01,  language EN //Message
                    } else if(i == 1){
                        System.assertEquals(oe.strType, 'E'); //E //Type
                        System.assertEquals(oe.strMessage, 'Error in SALES_ITEM_IN 000010'); //Error in SALES_ITEM_IN 000010 //Message
                    } else if(i == 2){
                        System.assertEquals(oe.strType, 'E'); //E //Type
                        System.assertEquals(oe.strMessage, 'Sales document  was not changed'); //Sales document  was not changed //Message
                    }
                }
            } catch (WS.WSException e){
                System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    
    /****************************************************************************************
    * @Author       Vaibhav Srivastava
    * @Date         December 23, 2016
    * @Description  Test coverage for Stock Availability call
    *    Assert valid return
    * ***************************************************************************************/
    public static testMethod void StockAvailabilityCallSuccess(){
        //Initialize the custom setting
        insert new WSDefaults__c(
            Stock_Availability_Endpoint__c = 'http://sap-wddev.certainteed.com/qa/StockAvailability/StockAvailability.asmx'
        );
        Test.startTest();
            //Set the mock response for a siding price call
            Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.STOCKAVAILSUCCESS));
            
            //Create the test request
            try{
                WS.StockAvailRequest request = new WS.StockAvailRequest();
                request.lstMaterials = new List<String>{'620990'}; //IvMat //Material
                request.strPlant = '277'; //IvPlant //IPlant
                WS.StockAvailabiltyResponse r = WS.stockAvailabilityCall(request);
                System.assert(r.lstSuccesses.size() > 0); 
            } catch (WS.WSException e){
                System.assert(false,'An error should not have occured. ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    
}