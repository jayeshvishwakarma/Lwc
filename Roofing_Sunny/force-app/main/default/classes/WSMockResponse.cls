/****************************************************************************************
* @Author       Dru Luce-Edwards
* @Date         November 13, 2016
* @Description  Mock response for WS callouts
* ***************************************************************************************/
@isTest
public class WSMockResponse implements HttpCalloutMock{
    //Sub Classes
    public enum Type {SIDINGPRICECALL, ROOFINGCUSTOMERPRICECALLSUCCESS, ROOFINGCUSTOMERPRICECALLERROR, ROOFINGAREAPRICECALLSUCCESS, ORDERCALLSUCCESS, ORDERCALLERROR, STOCKAVAILSUCCESS,STOCKAVAILERROR}
    
    //Class Variables
    public Type callType;
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Constructor, each mock response must have a type
    * ***************************************************************************************/
    public WSMockResponse(Type type) {
        callType = type;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response
    * ***************************************************************************************/
    public HTTPResponse respond(HTTPRequest req) {
        //Return the mock response
        if(callType == Type.SIDINGPRICECALL){
            return sidingPriceCallResponse(req);
        } else if(callType == Type.ROOFINGCUSTOMERPRICECALLSUCCESS){
            return roofingCustomerPriceCallSuccessResponse(req);
        } else if(callType == Type.ROOFINGCUSTOMERPRICECALLERROR){
            return roofingCustomerPriceCallErrorResponse(req);
        } else if(callType == Type.ROOFINGAREAPRICECALLSUCCESS){
            return roofingAreaPriceCallSuccessResponse(req);
        } else if(callType == Type.ORDERCALLSUCCESS){
            return orderCallSuccessResponse(req);
        } else if(callType == Type.ORDERCALLERROR){
            return orderCallErrorResponse(req);
        } else if(callType == Type.STOCKAVAILSUCCESS){
            return stockAvailCallSuccessResponse(req);
        } else if(callType == Type.STOCKAVAILERROR){
            return stockAvailCallErrorResponse(req);
        } else {
            return null;
        }
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response for a siding price call
    * ***************************************************************************************/
    private HTTPResponse sidingPriceCallResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:Zsdi9002OutWsdlPricingResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput><item><Matnr>000000000000403675</Matnr><Kschl>ZP00</Kschl><CondValue>101.57</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403675</Matnr><Kschl>ZP01</Kschl><CondValue>88.77</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403676</Matnr><Kschl>ZP00</Kschl><CondValue>112.41</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403676</Matnr><Kschl>ZP01</Kschl><CondValue>98.25</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403677</Matnr><Kschl>ZP00</Kschl><CondValue>160.59</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403677</Matnr><Kschl>ZP01</Kschl><CondValue>140.36</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403678</Matnr><Kschl>ZP00</Kschl><CondValue>277.99</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403678</Matnr><Kschl>ZP01</Kschl><CondValue>242.96</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403679</Matnr><Kschl>ZP00</Kschl><CondValue>244.67</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403679</Matnr><Kschl>ZP01</Kschl><CondValue>213.84</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403680</Matnr><Kschl>ZP00</Kschl><CondValue>173.07</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403680</Matnr><Kschl>ZP01</Kschl><CondValue>151.27</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403681</Matnr><Kschl>ZP00</Kschl><CondValue>177.53</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403681</Matnr><Kschl>ZP01</Kschl><CondValue>155.16</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000633623</Matnr><Kschl>ZP00</Kschl><CondValue>2290.45</CondValue><Currency>USD</Currency><CondUnit>PAL</CondUnit><AccessSeq>10</AccessSeq><Datbi>2017-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000633623</Matnr><Kschl>ZP01</Kschl><CondValue>2001.86</CondValue><Currency>USD</Currency><CondUnit>PAL</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item></GtOutput><Messages><item><Type>W</Type><Id/><Number>001</Number><Message>Invalid Material  Number.</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1>000000000000000955</MessageV1><MessageV2/><MessageV3/><MessageV4/><Parameter/><Row>0</Row><Field/><System/></item><item><Type>W</Type><Id/><Number>002</Number><Message>Invalid Material  Number.</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1>000000000000000966</MessageV1><MessageV2/><MessageV3/><MessageV4/><Parameter/><Row>0</Row><Field/><System/></item></Messages></n0:Zsdi9002OutWsdlPricingResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response for a roofing customer price call success
    * ***************************************************************************************/
    private HTTPResponse roofingCustomerPriceCallSuccessResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZsdWsdlCustSpriceResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput><item><EFF_DATE>2016-11-14</EFF_DATE><PLANT>0262</PLANT><SALES_ORG>1501</SALES_ORG><DISTRICT>01</DISTRICT><ITEM_CLASS>30</ITEM_CLASS><MATERIAL>000000000000410763</MATERIAL><IDC>RV1</IDC><UNIT_AREA_PRICE>65.0</UNIT_AREA_PRICE><UNIT_CURRENCY>USD</UNIT_CURRENCY><UNIT_PRICE_UOM>KAR</UNIT_PRICE_UOM><SAP_SEL_PRICE>65.0</SAP_SEL_PRICE><SAP_SEL_CURR>USD</SAP_SEL_CURR><SAP_SEL_UOM>KAR</SAP_SEL_UOM></item></GtOutput><Messages/></n0:ZsdWsdlCustSpriceResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response for a roofing customer price call error
    * ***************************************************************************************/
    private HTTPResponse roofingCustomerPriceCallErrorResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZsdWsdlCustSpriceResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput/><Messages><item><Type>E</Type><Id/><Number>001</Number><Message>Invalid Material/IDC.</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1/><MessageV2/><MessageV3/><MessageV4/><Parameter/><Row>0</Row><Field/><System/></item><item><Type>E</Type><Id/><Number>002</Number><Message>Invalid Material/Plan/Division</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1/><MessageV2/><MessageV3/><MessageV4/><Parameter/><Row>0</Row><Field/><System/></item></Messages></n0:ZsdWsdlCustSpriceResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response for a roofing area price call success
    * ***************************************************************************************/
    private HTTPResponse roofingAreaPriceCallSuccessResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZSdWsdlPriceAreaPriceFmResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput><item><EFF_DATE>2016-11-14</EFF_DATE><PLANT>0262</PLANT><SALES_ORG>1501</SALES_ORG><DISTRICT>405</DISTRICT><ITEM_CLASS>40</ITEM_CLASS><MATERIAL>619565</MATERIAL><IDC>R3M</IDC><UNIT_AREA_PRICE>69.0</UNIT_AREA_PRICE><UNIT_CURRENCY>USD</UNIT_CURRENCY><UNIT_PRICE_UOM>ROL</UNIT_PRICE_UOM><SAP_SEL_PRICE>69.0</SAP_SEL_PRICE><SAP_SEL_CURR>USD</SAP_SEL_CURR><SAP_SEL_UOM>ROL</SAP_SEL_UOM></item></GtOutput></n0:ZSdWsdlPriceAreaPriceFmResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response for an order call success
    * ***************************************************************************************/
    private HTTPResponse orderCallSuccessResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:Zsdi9002OutWsdlPricingResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput><item><Matnr>000000000000403675</Matnr><Kschl>ZP00</Kschl><CondValue>101.57</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403675</Matnr><Kschl>ZP01</Kschl><CondValue>88.77</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403676</Matnr><Kschl>ZP00</Kschl><CondValue>112.41</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403676</Matnr><Kschl>ZP01</Kschl><CondValue>98.25</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403677</Matnr><Kschl>ZP00</Kschl><CondValue>160.59</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403677</Matnr><Kschl>ZP01</Kschl><CondValue>140.36</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403678</Matnr><Kschl>ZP00</Kschl><CondValue>277.99</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403678</Matnr><Kschl>ZP01</Kschl><CondValue>242.96</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403679</Matnr><Kschl>ZP00</Kschl><CondValue>244.67</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403679</Matnr><Kschl>ZP01</Kschl><CondValue>213.84</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403680</Matnr><Kschl>ZP00</Kschl><CondValue>173.07</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403680</Matnr><Kschl>ZP01</Kschl><CondValue>151.27</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000403681</Matnr><Kschl>ZP00</Kschl><CondValue>177.53</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>10</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000403681</Matnr><Kschl>ZP01</Kschl><CondValue>155.16</CondValue><Currency>USD</Currency><CondUnit>CAR</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item><item><Matnr>000000000000633623</Matnr><Kschl>ZP00</Kschl><CondValue>2290.45</CondValue><Currency>USD</Currency><CondUnit>PAL</CondUnit><AccessSeq>10</AccessSeq><Datbi>2017-12-31</Datbi><Ddtext>Sales org./Division/District/Material</Ddtext><Message/></item><item><Matnr>000000000000633623</Matnr><Kschl>ZP01</Kschl><CondValue>2001.86</CondValue><Currency>USD</Currency><CondUnit>PAL</CondUnit><AccessSeq>15</AccessSeq><Datbi>2018-12-31</Datbi><Ddtext>Sales org./Division/Sold-to pt/Ship-to/Material</Ddtext><Message/></item></GtOutput><Messages><item><Type>W</Type><Id/><Number>001</Number><Message>Invalid Material  Number.</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1>000000000000000955</MessageV1><MessageV2/><MessageV3/><MessageV4/><Parameter/><Row>0</Row><Field/><System/></item><item><Type>W</Type><Id/><Number>002</Number><Message>Invalid Material  Number.</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1>000000000000000966</MessageV1><MessageV2/><MessageV3/><MessageV4/><Parameter/><Row>0</Row><Field/><System/></item></Messages></n0:Zsdi9002OutWsdlPricingResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         November 13, 2016
    * @Description  Return the mock response for an order call error
    * ***************************************************************************************/
    private HTTPResponse orderCallErrorResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZSd9004SalesorderCreateWcResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtReturn><item><Type>E</Type><Id>V1</Id><Number>382</Number><Message>Material WARRANTY - VINYL is not defined for sales org.1502,  distr.chan.01,  language EN</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1>WARRANTY - VINYL</MessageV1><MessageV2>1502</MessageV2><MessageV3>01</MessageV3><MessageV4>EN</MessageV4><Parameter>SALES_ITEM_IN</Parameter><Row>1</Row><Field/><System>EQR100</System></item><item><Type>E</Type><Id>V4</Id><Number>248</Number><Message>Error in SALES_ITEM_IN 000010</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1>VBAPKOM</MessageV1><MessageV2>000010</MessageV2><MessageV3>01</MessageV3><MessageV4>EN</MessageV4><Parameter>SALES_ITEM_IN</Parameter><Row>1</Row><Field/><System>EQR100</System></item><item><Type>E</Type><Id>V4</Id><Number>219</Number><Message>Sales document  was not changed</Message><LogNo/><LogMsgNo>000000</LogMsgNo><MessageV1/><MessageV2>000010</MessageV2><MessageV3>01</MessageV3><MessageV4>EN</MessageV4><Parameter/><Row>0</Row><Field/><System>EQR100</System></item></GtReturn><GvVbeln/></n0:ZSd9004SalesorderCreateWcResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    
    /****************************************************************************************
    * @Author       Vaibhav Srivastava
    * @Date         December 21, 2016
    * @Description  Return the mock response for stock avail call success
    * ***************************************************************************************/
    private HTTPResponse stockAvailCallSuccessResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZSdWsdlStockAvailResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput><item><PLANT>277</PLANT><MATERIAL>620990 - LANDMARK AR WEATHERED WOOD  OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>359247.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2016-12-22</DATE><AVAIL_QTY>95038.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2016-12-24</DATE><AVAIL_QTY>446116.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-15</DATE><AVAIL_QTY>626116.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620966     - LANDMARK AR BURNT SIENNA    OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>6814.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-08</DATE><AVAIL_QTY>65002.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620968     - LANDMARK AR CHARCOAL BLACK  OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>17802.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620970     - LANDMARK AR COBBLESTONE GRY OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>2087.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620375     - LANDMARK AR COBBLESTONE GRY PT</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>0.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620972     - LANDMARK AR COLONIAL SLATE  OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>17662.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>621149     - LANDMARK AR COTTAGE RED     OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>7652.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>622420     - LANDMARK AR COTTAGE RED     PT</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>0.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620702     - LANDMARK AR DRIFTWOOD       AV</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>0.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620974     - LANDMARK AR DRIFTWOOD       OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>19610.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620976     - LANDMARK AR GEORGETOWN GRAY OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>16962.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620978     - LANDMARK AR HEATHER BLEND   OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>9493.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-03</DATE><AVAIL_QTY>26837.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620980     - LANDMARK AR HUNTER GREEN    OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>13769.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620385     - LANDMARK AR HUNTER GREEN    PT</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>0.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>627803     - LANDMARK AR MIST WHITE                PT</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>329.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620982     - LANDMARK AR MOIRE BLACK     OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>305081.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2016-12-22</DATE><AVAIL_QTY>85434.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-12</DATE><AVAIL_QTY>335349.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620674     - LANDMARK AR MOJAVE TAN      PT</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>4961.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-09</DATE><AVAIL_QTY>7073.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-13</DATE><AVAIL_QTY>7121.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-14</DATE><AVAIL_QTY>7169.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-15</DATE><AVAIL_QTY>7217.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-16</DATE><AVAIL_QTY>7361.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-17</DATE><AVAIL_QTY>7457.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-20</DATE><AVAIL_QTY>7601.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-21</DATE><AVAIL_QTY>7745.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-22</DATE><AVAIL_QTY>7793.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620984     - LANDMARK AR PEWTER          OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>11209.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620986     - LANDMARK AR RESAWN SHAKE    OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>10890.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>621117     - LANDMARK AR SILVER BIRCH    OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>13456.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-03</DATE><AVAIL_QTY>33340.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620988     - LANDMARK AR SPANISH TILE  E-OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>62.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>621121     - LANDMARK AR SUNRISE CEDAR   OX</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>19674.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2017-01-03</DATE><AVAIL_QTY>48627.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620714     - LANDMARK AR WEATHERED WOOD  AV</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>0.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620694     - LANDMARK AR WEATHERED WOOD  SP</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>0.0</AVAIL_QTY></item><item><PLANT>277</PLANT><MATERIAL>620963     - Test2</MATERIAL><UOM>BUN</UOM><DATE>2016-12-22</DATE><AVAIL_QTY>8522.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2016-12-22</DATE><AVAIL_QTY>17121.0</AVAIL_QTY></item><item><PLANT/><MATERIAL/><UOM/><DATE>2016-12-27</DATE><AVAIL_QTY>17121.0</AVAIL_QTY></item></GtOutput></n0:ZSdWsdlStockAvailResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
    
    /****************************************************************************************
    * @Author       Vaibhav Srivastava
    * @Date         December 21, 2016
    * @Description  Return the mock response for stock avail call error
    * ***************************************************************************************/
    private HTTPResponse stockAvailCallErrorResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZSdWsdlStockAvailResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><GtOutput/></n0:ZSdWsdlStockAvailResponse></soap-env:Body></soap-env:Envelope>');
        res.setStatusCode(200);
        return res;
    }
}