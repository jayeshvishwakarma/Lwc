/****************************************************************************************
* @Author       Dru Luce-Edwards
* @Date         October 10, 2016
* @Description  For each callout: takes a request object, performs the callout and returns a result object or throws an exception
*****************************************************************************************/
public class WS {
    //Class variables
    private static WSDefaults__c wsDefaults = WSDefaults__c.getOrgDefaults();
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Custom exception class, used to throw connection specific errors
    *****************************************************************************************/
    public class WSException extends Exception {}
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Pricing call request object
    *****************************************************************************************/
    public class PricingRequest{
        public List<Integer> lstMaterials {get;set;} //Matnr //IvMat //Material
        public Date dtDate {get;set;} //IvDate //IvDate //IDate
        public String strShipTo {get;set;} //IvShipto //IvShipto //
        public String strSoldTo {get;set;} //IvSoldto //IvSoldto //
        public String strDivision {get;set;} //IvSpart //IvSpart //ItemClass
        public String strDistChannel {get;set;} //IvVtweg //IvSdist //
        public String strDistrict {get;set;} // // //ISdist
        public String strAreaPriceEndpoint {get;set;}
        public String strCustPriceEndpoint {get;set;}
        public String strSalesOrg {get;set;} //IvSorg //IvSorg //ISorg
        public String strIdc {get;set;} // //IvIdc //Idc
        public String strPayer {get;set;} // //IvPayer //
        public String strPlant {get;set;} // //IvPlant //IPlant
        public Boolean isRoofing {get;set;}
        public Integer intTimeout {get;set;}
        
        public PricingRequest(){
            //Set the defaults when a pricing request is created
            strAreaPriceEndpoint = wsDefaults.Area_Price_Endpoint__c;
            strCustPriceEndpoint = wsDefaults.Customer_Price_Endpoint__c;
            dtDate = Date.today();
            intTimeout = 5000; //If not set default timeout to 5 seconds
            if(wsDefaults.Timeout__c != null) intTimeout = Integer.valueOf(wsDefaults.Timeout__c); 
        }
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Pricing call response object
    *****************************************************************************************/
    public class PricingResponse{
        public Map<Integer,PricingSuccess> mapSuccesses {get;set;}
        public List<PricingError> lstErrors {get;set;}
        public ResponseType type {get;set;}
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         January 26, 2017
    * @Description  Response types
    *****************************************************************************************/
    public enum ResponseType {AREAPRICE,CUSTOMERPRICE}
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Pricing call response success object
    *****************************************************************************************/
    public class PricingSuccess{
        public Integer intMaterial {get;set;} //Matnr //Material
        public String strType {get;set;} //Kschl //
        public Decimal decPrice {get;set;} //CondValue //SAP_SEL_PRICE
        public String strCurrency {get;set;} //Currency //SAP_SEL_CURR
        public String strUOM {get;set;} //CondUnit //SAP_SEL_UOM
        public Integer intAccessSeq {get;set;} //AccessSeq //
        public Date dtBi {get;set;} //Datbi //EFF_DATE
        public String strDText {get;set;} //Ddtext //
        public String strMessage {get;set;} //Message //
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Pricing call response error object
    *****************************************************************************************/
    public class PricingError{
        public String strType {get;set;} //Type //Type
        public String strMessage {get;set;} //Message + MessageV1 + MessageV2 + MessageV3 + MessageV4 + MessageV5 //Message + MessageV1 + MessageV2 + MessageV3 + MessageV4 + MessageV5
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Perform the price call
    *****************************************************************************************/
    public static PricingResponse doPriceCall(PricingRequest request){
        //Validation
        if(request.isRoofing == null) throw new WSException('The request must specify isRoofing to use this method. Set isRoofing in the request or call the doRoofingPriceCall or doSidingPriceCall method.');
        if(request.isRoofing){
            return doRoofingPriceCall(request);
        } else {
            return doSidingPriceCall(request);
        }
    }
     
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Perform the siding price call
    *****************************************************************************************/
    public static PricingResponse doSidingPriceCall(PricingRequest request){
        //Validation
        if(request.strCustPriceEndpoint == null) throw new WSException('Customer Price Endpoint is required. Set strCustPriceEndpoint or WSDefaults Customer Price Endpoint setting.');
        //2-15-2017 Dru: Escape the XML in all non null string variables
        if(request.strShipTo != null) request.strShipTo = request.strShipTo.escapeXml();
        if(request.strSoldTo != null) request.strSoldTo = request.strSoldTo.escapeXml();
        if(request.strDivision != null) request.strDivision = request.strDivision.escapeXml();
        if(request.strDistChannel != null) request.strDistChannel = request.strDistChannel.escapeXml();
        if(request.strDistrict != null) request.strDistrict = request.strDistrict.split(' ').get(0).escapeXml();
        if(request.strSalesOrg != null) request.strSalesOrg = request.strSalesOrg.escapeXml();
        if(request.strIdc != null) request.strIdc = request.strIdc.escapeXml();
        if(request.strPayer != null) request.strPayer = request.strPayer.escapeXml();
        if(request.strPlant != null) request.strPlant = request.strPlant.escapeXml();
        //The siding price call accepts a maximum of 10 materials
        if(request.lstMaterials.size() > 10) throw new WSException('The Siding price call only accepts up to 10 materials number per callout.');
        //Create the callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(request.strCustPriceEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('soapAction','urn:sap-com:document:sap:soap:functions:mc-style:ZSDI_9002_OUT_WSDL_PRICING_WS:Zsdi9002OutWsdlPricingRequest');
        req.setHeader('Authorization','Basic U0ZEQzpQQHNzMjAwIQ==');
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">'
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
                + '<urn:Zsdi9002OutWsdlPricing>'
                    + '<GtInputMatnr>';
                        if(request.lstMaterials != null){ //Add the materials list
                            for(Integer intMat : request.lstMaterials){
                                body += 
                                + '<item>'
                                   + '<Matnr>' + intMat + '</Matnr>'             
                                + '</item>';
                            }
                        }
                        body += //Add the rest of the xml body
                    + '</GtInputMatnr>'
                    + '<IvDate>' + DateTime.newInstance(request.dtDate.year(),request.dtDate.month(),request.dtDate.day()).format('YYYY-MM-dd') + '</IvDate>'
                    + '<IvShipto>' + request.strShipTo + '</IvShipto>'
                    + '<IvSoldto>' + request.strSoldTo + '</IvSoldto>'
                    + '<IvSorg>' + request.strSalesOrg + '</IvSorg>'
                    + '<IvSpart>' + request.strDivision + '</IvSpart>'
                    + '<IvVtweg>' + request.strDistChannel + '</IvVtweg>'
                + '</urn:Zsdi9002OutWsdlPricing>'
            + '</soapenv:Body>'
        + '</soapenv:Envelope>';
        //Remove null entries
        body = body.replaceAll('>null<','><');
        req.setBody(body);
        
        //Set the timeout
        req.setTimeout(request.intTimeout);
        
        //Send the request
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //Process the response
        String strResponse = res.getBody();
        if(res.getStatusCode() != 200) throw new WSException('Callout failed. Status: ' + res.getStatusCode() + ' - ' + res.getStatus() + ' Response: ' + strResponse);
        Map<Integer,PricingSuccess> mapSuccesses = new Map<Integer,PricingSuccess>();
        if(strResponse.contains('<GtOutput>')){
            String strOutput = strResponse.subString(strResponse.indexOf('<GtOutput>'),strResponse.indexOf('</GtOutput>')+11);
            XmlStreamReader reader = new XmlStreamReader(strOutput);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    PricingSuccess ps = new PricingSuccess();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('Matnr' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.intMaterial = Integer.valueOf(reader.getText());
                        } else if('Kschl' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strType = reader.getText();
                        } else if('CondValue' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.decPrice = Decimal.valueOf(reader.getText());
                        } else if('Currency' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strCurrency = reader.getText();
                        } else if('CondUnit' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strUOM = reader.getText();
                        } else if('AccessSeq' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.intAccessSeq = Integer.valueOf(reader.getText());
                        } else if('Datbi' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS){
                                //1-18-2017 Dru: Updated to handle invalid date returns of 0000-00-00
                                ps.dtBi = null;
                                try{
                                    ps.dtBi = Date.valueOf(reader.getText());
                                }catch(Exception e){}
                            }
                        } else if('DdText' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strDText = reader.getText();
                        } else if('Message' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strMessage = reader.getText();
                        } else {
                            reader.next();
                        }
                    }
                    //If ZIDC and ZP01 types both exist, add them together and use ZP01 as the base
                    //Else If ZP01 type exists, this is the price
                    //Else IF ZP00 type exists, this is the price
                    if(mapSuccesses.containsKey(ps.intMaterial)){
                        PricingSuccess psExist = mapSuccesses.get(ps.intMaterial);
                        if(ps.strType == 'ZP01'){
                            if(psExist.strType == 'ZIDC') ps.decPrice += psExist.decPrice;
                            mapSuccesses.put(ps.intMaterial,ps);
                        } else if(ps.strType == 'ZP00'){
                            if(psExist.strType == 'ZIDC') mapSuccesses.put(ps.intMaterial,ps);
                        } else if(ps.strType == 'ZIDC'){
                            if(psExist.strType == 'ZP01') psExist.decPrice += ps.decPrice;
                        } 
                    } else {
                        mapSuccesses.put(ps.intMaterial,ps);
                    }
                }
                reader.next();
            }
        }
        List<PricingError> lstErrors = new List<PricingError>();
        if(strResponse.contains('<Messages>')){
            String strMessages = strResponse.subString(strResponse.indexOf('<Messages>'),strResponse.indexOf('</Messages>') + 11);
            XmlStreamReader reader = new XmlStreamReader(strMessages);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    PricingError pe = new PricingError();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('Type' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strType = reader.getText();
                        } else if('Message' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage = reader.getText().replaceAll('^0+', '');
                        } else if('MessageV1' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV2' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV3' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV4' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV5' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else {
                            reader.next();
                        }
                    }
                    lstErrors.add(pe);
                }
                reader.next();
            }
        }
        //Throw the response as an error if it isn't in the expected format of a valid response
        if(
            !((strResponse.contains('<Messages>') || strResponse.contains('<Messages/>'))
            && 
            (strResponse.contains('<GtOutput>') || strResponse.contains('<GtOutput/>')))
        ) throw new WSException('Invalid response: ' + strResponse);
        PricingResponse r = new PricingResponse();
        r.mapSuccesses = mapSuccesses;
        r.lstErrors = lstErrors;
        return r;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Perform the roofing price call
    *****************************************************************************************/
    public static PricingResponse doRoofingPriceCall(PricingRequest request){
        //Do the roofing customer price call
        PricingResponse r = doRoofingCustomerPriceCall(request);
        if(r.mapSuccesses.isEmpty()){
            //If no results are found, do the roofing area price call
            //The area price call does not return errors, if the area price call did not have a success then return the customer price call response
            PricingResponse apr = doRoofingAreaPriceCall(request);
            if(!apr.mapSuccesses.isEmpty()) r = apr;
        }
        return r;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Perform the roofing customer price call
    *****************************************************************************************/
    public static PricingResponse doRoofingCustomerPriceCall(PricingRequest request){
        //Validation
        if(request.strCustPriceEndpoint == null) throw new WSException('Customer Price Endpoint is required. Set strCustPriceEndpoint or WSDefaults Customer Price Endpoint setting.');
        //2-15-2017 Dru: Escape the XML in all non null string variables
        if(request.strShipTo != null) request.strShipTo = request.strShipTo.escapeXml();
        if(request.strSoldTo != null) request.strSoldTo = request.strSoldTo.escapeXml();
        if(request.strDivision != null) request.strDivision = request.strDivision.escapeXml();
        if(request.strDistChannel != null) request.strDistChannel = request.strDistChannel.escapeXml();
        if(request.strDistrict != null) request.strDistrict = request.strDistrict.split(' ').get(0).escapeXml();
        if(request.strSalesOrg != null) request.strSalesOrg = request.strSalesOrg.escapeXml();
        if(request.strIdc != null) request.strIdc = request.strIdc.escapeXml();
        if(request.strPayer != null) request.strPayer = request.strPayer.escapeXml();
        if(request.strPlant != null) request.strPlant = request.strPlant.escapeXml();
        //The roofing price call only accepts one material number per call
        if(request.lstMaterials.size() != 1) throw new WSException('The Roofing price call must have exactly one material number per callout.');
        Integer mat = request.lstMaterials.get(0);
        //Create the callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(request.strCustPriceEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('soapAction','urn:sap-com:document:sap:soap:functions:mc-style:ZSD_WSDL_CUST_SPRICE_WS:ZsdWsdlCustSpriceRequest');
        Blob headerValue = Blob.valueOf('SFDC:P@ss200!');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization',authorizationHeader);
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">'
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
                + '<urn:ZsdWsdlCustSprice>'
                    + '<IvDate>' + DateTime.newInstance(request.dtDate.year(),request.dtDate.month(),request.dtDate.day()).format('YYYY-MM-dd') + '</IvDate>'
                    + '<IvIdc>' + request.strIdc + '</IvIdc>'
                    + '<IvMat>' + mat + '</IvMat>'
                    + '<IvPayer>' + request.strPayer + '</IvPayer>'
                    + '<IvPlant>' + request.strPlant + '</IvPlant>'
                    + '<IvSdist>' + request.strDistChannel + '</IvSdist>'
                    + '<IvShipto>' + request.strShipTo + '</IvShipto>'
                    + '<IvSoldto>' + request.strSoldTo + '</IvSoldto>'
                    + '<IvSorg>' + request.strSalesOrg + '</IvSorg>'
                    + '<IvSpart>' + request.strDivision + '</IvSpart>'
                + '</urn:ZsdWsdlCustSprice>'
            + '</soapenv:Body>'
        + '</soapenv:Envelope>';
        //Remove null entries
        body = body.replaceAll('>null<','><');
        req.setBody(body);
        
        //Set the timeout
        req.setTimeout(request.intTimeout);
        
        //Send the request
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //Process the response
        String strResponse = res.getBody();
        System.debug(body);
        System.debug(strResponse);
        if(res.getStatusCode() != 200) throw new WSException('Callout failed. Status: ' + res.getStatusCode() + ' - ' + res.getStatus() + ' Response: ' + strResponse);
        Map<Integer,PricingSuccess> mapSuccesses = new Map<Integer,PricingSuccess>();
        List<PricingError> lstErrors = new List<PricingError>();
        if(strResponse.contains('<GtOutput>')){
            String strOutput = strResponse.subString(strResponse.indexOf('<GtOutput>'),strResponse.indexOf('</GtOutput>')+11);
            XmlStreamReader reader = new XmlStreamReader(strOutput);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    PricingSuccess ps = new PricingSuccess();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('MATERIAL' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.intMaterial = Integer.valueOf(reader.getText());
                        } else if('SAP_SEL_PRICE' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.decPrice = Decimal.valueOf(reader.getText());
                        } else if('SAP_SEL_CURR' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strCurrency = reader.getText();
                        } else if('SAP_SEL_UOM' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strUOM = reader.getText();
                        } else if('EFF_DATE' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.dtBi = Date.valueOf(reader.getText());
                        } else {
                            reader.next();
                        }
                    }
                    mapSuccesses.put(ps.intMaterial,ps);
                }
                reader.next();
            }
        }else if(strResponse.contains('<Messages>')){
            String strMessages = strResponse.subString(strResponse.indexOf('<Messages>'),strResponse.indexOf('</Messages>') + 11);
            XmlStreamReader reader = new XmlStreamReader(strMessages);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    PricingError pe = new PricingError();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('Type' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strType = reader.getText();
                        } else if('Message' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage = reader.getText().replaceAll('^0+', '');
                        } else if('MessageV1' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV2' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV3' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV4' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else if('MessageV5' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) pe.strMessage += ' ' + reader.getText().replaceAll('^0+', '');
                        } else {
                            reader.next();
                        }
                    }
                    lstErrors.add(pe);
                }
                reader.next();
            }
        } else {
            //Throw the response as an error if it isn't in the expected format of a valid response
            throw new WSException('Invalid response: ' + strResponse);
        }
        PricingResponse r = new PricingResponse();
        r.mapSuccesses = mapSuccesses;
        r.lstErrors = lstErrors;
        r.type = ResponseType.CUSTOMERPRICE;
        return r;
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Perform the roofing area price call
    *****************************************************************************************/
    public static PricingResponse doRoofingAreaPriceCall(PricingRequest request){
        //Validation
        if(request.strAreaPriceEndpoint == null) throw new WSException('Area Price Endpoint is required. Set strAreaPriceEndpoint or WSDefaults Area Price Endpoint setting.');
        //2-15-2017 Dru: Escape the XML in all non null string variables
        if(request.strShipTo != null) request.strShipTo = request.strShipTo.escapeXml();
        if(request.strSoldTo != null) request.strSoldTo = request.strSoldTo.escapeXml();
        if(request.strDivision != null) request.strDivision = request.strDivision.escapeXml();
        if(request.strDistChannel != null) request.strDistChannel = request.strDistChannel.escapeXml();
        if(request.strDistrict != null) request.strDistrict = request.strDistrict.split(' ').get(0).escapeXml();
        if(request.strSalesOrg != null) request.strSalesOrg = request.strSalesOrg.escapeXml();
        if(request.strIdc != null) request.strIdc = request.strIdc.escapeXml();
        if(request.strPayer != null) request.strPayer = request.strPayer.escapeXml();
        if(request.strPlant != null) request.strPlant = request.strPlant.escapeXml();
        //The roofing price call only accepts one material number per call
        //if(request.lstMaterials.size() != 1) throw new WSException('The Roofing price call must have exactly one material number per callout.');
        Integer mat = request.lstMaterials.get(0);
        //Create the callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(request.strAreaPriceEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('soapAction','urn:sap-com:document:sap:soap:functions:mc-style:ZSD_WSDL_PRICE_AREA_PRICE_FM:ZSdWsdlPriceAreaPriceFmRequest');
        //Blob headerValue = Blob.valueOf('SFDC:P@ss200!');
        //String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        //req.setHeader('Authorization',authorizationHeader);
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">'
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
                + '<urn:ZSdWsdlPriceAreaPriceFm>'
                    + '<GtInput>';
                        if(request.lstMaterials != null){ //Add the materials list
                            for(Integer intMat : request.lstMaterials){
                                body += 
                                + '<item>'
                                   + '<Material>' + intMat + '</Material>' 
                                   + '<ItemClass>' + request.strDivision + '</ItemClass>'
                                   + '<Idc>' + request.strIdc + '</Idc>' 
                                + '</item>';
                            }
                        }
                        body += //Add the rest of the xml body
                    + '</GtInput>'
                    + '<IDate>' + DateTime.newInstance(request.dtDate.year(),request.dtDate.month(),request.dtDate.day()).format('YYYY-MM-dd') + '</IDate>'
                    + '<IPlant>' + request.strPlant + '</IPlant>'
                    + '<ISdist>' + request.strDistrict + '</ISdist>'
                    + '<ISorg>' + request.strSalesOrg + '</ISorg>'
                + '</urn:ZSdWsdlPriceAreaPriceFm>'
            + '</soapenv:Body>'
        + '</soapenv:Envelope>';
        //Remove null entries
        body = body.replaceAll('>null<','><');
        req.setBody(body);
        
        
        //Set the timeout
        req.setTimeout(request.intTimeout);
        
        //Send the request
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //Process the response
        String strResponse = res.getBody();
        System.debug(body);
        System.debug(strResponse);
        if(res.getStatusCode() != 200) throw new WSException('Callout failed. Status: ' + res.getStatusCode() + ' - ' + res.getStatus() + ' Response: ' + strResponse);
        Map<Integer,PricingSuccess> mapSuccesses = new Map<Integer,PricingSuccess>();
        List<PricingError> lstErrors = new List<PricingError>();
        if(strResponse.contains('<GtOutput>')){
            String strOutput = strResponse.subString(strResponse.indexOf('<GtOutput>'),strResponse.indexOf('</GtOutput>')+11);
            XmlStreamReader reader = new XmlStreamReader(strOutput);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    PricingSuccess ps = new PricingSuccess();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('MATERIAL' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.intMaterial = Integer.valueOf(reader.getText());
                        } else if('SAP_SEL_PRICE' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.decPrice = Decimal.valueOf(reader.getText());
                        } else if('SAP_SEL_CURR' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strCurrency = reader.getText();
                        } else if('SAP_SEL_UOM' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strUOM = reader.getText();
                        } else if('EFF_DATE' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.dtBi = Date.valueOf(reader.getText());
                        } else {
                            reader.next();
                        }
                    }
                    mapSuccesses.put(ps.intMaterial,ps);
                }
                reader.next();
            }
        }
        //The area price call does not return errors, do not throw an invalid response exception
        PricingResponse r = new PricingResponse();
        r.mapSuccesses = mapSuccesses;
        r.lstErrors = lstErrors;
        r.type = ResponseType.AREAPRICE;
        return r;
    }
        
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Order call request object
    *****************************************************************************************/
    public class OrderRequest{
        public List<OrderLine> lstOrdLines {get;set;}
        public List<OrderNote> lstOrdNotes {get;set;}
        public String strType {get;set;} //auart
        public String strSalesOrg {get;set;} //vkorg
        public String strDivision {get;set;} //spart
        public String strDistChannel {get;set;} //vtweg
        public String strShipTo {get;set;} //kunnr_sh
        public String strSoldTo {get;set;} //hunnr_sp
        public String strOrdReason {get;set;} //augru
        public String strPONumber {get;set;} //bstkd
        public String strName {get;set;} //bname
        public String strShipCondition {get;set;} //vsbed
        public String strEndpoint {get;set;}
        public Boolean isRoofing {get;set;}
        public Integer intTimeout {get;set;}
        
        public OrderRequest(){
            //Set the defaults when a pricing request is created
            if(wsDefaults.Order_Endpoint__c == null) throw new WSException('Order Endpoint in WSDefault cannot be blank.');
            strEndpoint = wsDefaults.Order_Endpoint__c;
            intTimeout = 5000; //If not set default timeout to 5 seconds
            if(wsDefaults.Timeout__c != null) intTimeout = Integer.valueOf(wsDefaults.Timeout__c); 
        }
    }
    
    /****************************************************************************************
    * @Author       Vaibhav Srivastava
    * @Date         December 20, 2016
    * @Description  Stock Availability call request object
    *****************************************************************************************/
    public class StockAvailRequest{
        public List<string> lstMaterials {get;set;} //Matnr //IvMat //Material
        public String strStockAvailEndpoint {get;set;}
        public String strPlant {get;set;} // //IvPlant //IPlant
        public Integer intTimeout {get;set;}
        
        public StockAvailRequest(){
            //Set the defaults when a pricing request is created
            strStockAvailEndpoint = wsDefaults.Stock_Availability_Endpoint__c;
            intTimeout = 5000; //If not set default timeout to 5 seconds 
        }
    }
    
    public class StockAvailabiltyResponse{
        public List<StockAvailSuccess> lstSuccesses;
        public List<StockAvailabilityError> lstErrors;
    }
    
    /****************************************************************************************
    * @Author       Vaibhav Srivastava
    * @Date         December 20, 2016
    * @Description  Stock Availability call response success object
    *****************************************************************************************/
    public class StockAvailSuccess{
        public String strPlant {get;set;} // //IvPlant //IPlant
        public string strMaterial {get;set;} //Matnr //Material
        public String strUOM {get;set;} //CondUnit //SAP_SEL_UOM
        public Date dtBi {get;set;}
        public Decimal availQuantity {get;set;} //Message //
    }
    
    /****************************************************************************************
    * @Author       Vaibhav Srivastava
    * @Date         December 20, 2016
    * @Description  Stock Availability call response error object
    *****************************************************************************************/
    public class StockAvailabilityError{
        public String strType {get;set;} //Type //Type
        public String strMessage {get;set;} //Message + MessageV1 + MessageV2 + MessageV3 + MessageV4 + MessageV5 //Message + MessageV1 + MessageV2 + MessageV3 + MessageV4 + MessageV5
    } 
    
    public static StockAvailabiltyResponse stockAvailabilityCall(StockAvailRequest request){    
        //2-15-2017 Dru: Escape the XML in all non null string variables
        if(request.strPlant != null) request.strPlant = request.strPlant.escapeXml();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(request.strStockAvailEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setHeader('soapAction','urn:sap-com:document:sap:soap:functions:mc-style:ZSD_WSDL_STOCKAVAIL:ZSdWsdlStockAvailRequest');
        req.setHeader('Authorization','Basic U0ZEQzpQQHNzMjAwIQ==');
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">'
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
                + '<urn:ZSdWsdlStockAvail>'
                                   + '<IMaterial>'+ request.lstMaterials[0] +'</IMaterial>'
                                   + '<IPlant>'+ request.strPlant +'</IPlant>'                                   
                + '</urn:ZSdWsdlStockAvail>'
            + '</soapenv:Body>'
        + '</soapenv:Envelope>';

        //Remove null entries
        body = body.replaceAll('>null<','><');
        req.setBody(body);
        
        //Set the timeout
        req.setTimeout(5000);
                
        //Send the request
        Http h = new Http();
        String strRequest = req.getBody();
        system.debug('Request is' +strRequest);
        HttpResponse res = h.send(req);
        
        //Process the response
        String strResponse = res.getBody();
        system.debug('Response is' +strResponse);
        List<StockAvailSuccess> lstSuccesses = new List<StockAvailSuccess>();
        List<StockAvailabilityError> lstErrors = new List<StockAvailabilityError>();
        if(strResponse.contains('<GtOutput>')){
            String strOutput = strResponse.subString(strResponse.indexOf('<GtOutput>'),strResponse.indexOf('</GtOutput>')+11);
            XmlStreamReader reader = new XmlStreamReader(strOutput);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    StockAvailSuccess ps = new StockAvailSuccess();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('PLANT' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strPlant = String.valueOf(reader.getText());
                        } else if('MATERIAL' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strMaterial = string.valueOf(reader.getText());
                        } else if('UOM' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.strUOM = reader.getText();
                        } else if('DATE' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.dtBi = Date.valueOf(reader.getText());
                        } else if('AVAIL_QTY' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) ps.availQuantity = Decimal.valueOf(reader.getText()); 
                        } else {
                            reader.next();
                        }
                    }
                    lstSuccesses.add(ps);
                }
                reader.next();
            }
        }
        else {
            //Throw the response as an error if it isn't in the expected format of a valid response
            throw new WSException('Invalid response: ' + strResponse);
        }
        StockAvailabiltyResponse r = new StockAvailabiltyResponse();
        r.lstErrors = lstErrors;
        r.lstSuccesses = lstSuccesses;
        return r;
    }
    
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Order Line object used in order call
    *****************************************************************************************/
    public class OrderLine{
        public String strMaterial {get;set;} //matnr
        public Decimal decQuantity {get;set;} //kwmeng
        public String strUOM {get;set;} //vrkme
        public Decimal decPrice {get;set;} //kbetr
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Order Note object used in order call
    *****************************************************************************************/
    public class OrderNote{
        public String strId {get;set;} //tdid
        public String strText {get;set;} //tdline
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Order call response object
    *****************************************************************************************/
    public class OrderResponse{
        public Integer intOrderNumber {get;set;} //GvVbeln
        public List<OrderError> lstErrors {get;set;}
    }
    
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Order Error object
    *****************************************************************************************/
    public class OrderError{
        public String strType {get;set;} //Type
        public String strMessage {get;set;} //Message
    }
     
    /****************************************************************************************
    * @Author       Dru Luce-Edwards
    * @Date         October 10, 2016
    * @Description  Perform the order call
    *****************************************************************************************/
    public static OrderResponse doOrderCall(OrderRequest request){
        //2-15-2017 Dru: Escape the XML in all non null string variables
        if(request.strType != null) request.strType = request.strType.escapeXml();
        if(request.strSalesOrg != null) request.strSalesOrg = request.strSalesOrg.escapeXml();
        if(request.strDivision != null) request.strDivision = request.strDivision.escapeXml();
        if(request.strDistChannel != null) request.strDistChannel = request.strDistChannel.escapeXml();
        if(request.strShipTo != null) request.strShipTo = request.strShipTo.escapeXml();
        if(request.strSoldTo != null) request.strSoldTo = request.strSoldTo.escapeXml();
        if(request.strOrdReason != null) request.strOrdReason = request.strOrdReason.escapeXml();
        if(request.strSalesOrg != null) request.strSalesOrg = request.strSalesOrg.escapeXml();
        if(request.strPONumber != null) request.strPONumber = request.strPONumber.escapeXml();
        if(request.strName != null) request.strName = request.strName.escapeXml();
        if(request.strShipCondition != null) request.strShipCondition = request.strShipCondition.escapeXml();
        for(OrderLine ol : request.lstOrdLines){
            if(ol.strMaterial != null) ol.strMaterial = ol.strMaterial.escapeXml();
            if(ol.strUOM != null) ol.strUOM = ol.strUOM.escapeXml();
        }
        for(OrderNote oNote : request.lstOrdNotes){
            if(oNote.strId != null) oNote.strId = oNote.strId.escapeXml();
            if(oNote.strText != null) oNote.strText = oNote.strText.escapeXml();
        }
        //Create the callout
        HttpRequest req = new HttpRequest();
        req.setTimeout(10000);
        req.setEndpoint(request.strEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('Check', 'VjFkV2VnPT0=');
        req.setHeader('soapAction','urn:sap-com:document:sap:soap:functions:mc-style:ZSDI_9004_SALESORDER_CREATE_WC:ZDd9004SalesorderCreateWcRequest');
        String body = 
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">'
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
                + '<urn:ZSd9004SalesorderCreateWc>'
                    + '<GtOrddtl>';
                        if(request.lstOrdLines != null){ //Add the order lines list
                            for(Integer i = 0; i < request.lstOrdLines.size(); i++){//OrderLine ol : request.lstOrdLines){
                                OrderLine ol = request.lstOrdLines.get(i);
                                body += 
                                + '<item>'
                                   + '<Posnr>' + i + '</Posnr>' 
                                   + '<Matnr>' + ol.strMaterial + '</Matnr>'   
                                   + '<Vrkme>' + ol.strUOM + '</Vrkme>' 
                                   + '<Kwmeng>' + ol.decQuantity + '</Kwmeng>'
                                   + '<Kbetr>' + ol.decPrice + '</Kbetr>'           
                                + '</item>';
                            }
                        }
                        body += //Add the rest of the xml body
                    + '</GtOrddtl>'
                    + '<GtText>';
                        if(request.lstOrdLines != null){ //Add the notes list
                            for(Integer i = 0; i < request.lstOrdNotes.size(); i++){ //OrderNote oNote : request.lstOrdNotes){
                                OrderNote oNote = request.lstOrdNotes.get(i);
                                body += 
                                + '<item>'
                                   + '<POSNR>'+/* + i + */'</POSNR>' //2-6-2017 Dru: Removed POSNR due to issue where SAP will only use the first one if POSNR is NOT blank
                                   + '<TDID>' + oNote.strId + '</TDID>'   
                                   + '<TDLINE>' + oNote.strText + '</TDLINE>'          
                                + '</item>';
                            }
                        }
                        body += //Add the rest of the xml body
                    + '</GtText>'
                    + '<IOrdhdr>'
                        + '<Auart>' + request.strType + '</Auart>'
                        + '<Vkorg>' + request.strSalesOrg + '</Vkorg>'
                        + '<Vtweg>' + request.strDistChannel + '</Vtweg>'
                        + '<Spart>' + request.strDivision + '</Spart>'
                        + '<KunnrSp>' + request.strSoldTo + '</KunnrSp>'
                        + '<KunnrSh>' + request.strShipTo + '</KunnrSh>'
                        + '<Bstkd>' + request.strPONumber + '</Bstkd>'
                        + '<Augru>' + request.strOrdReason + '</Augru>'
                        + '<Vsbed>' + request.strShipCondition + '</Vsbed>'
                        + '<Bname>' + request.strName + '</Bname>'
                    + '</IOrdhdr>'
                + '</urn:ZSd9004SalesorderCreateWc>'
            + '</soapenv:Body>'
        + '</soapenv:Envelope>';
        //Remove null entries
        body = body.replaceAll('>null<','><');
        req.setBody(body);
        //Set the timeout
        req.setTimeout(request.intTimeout);
        //Send the request
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug(body);
        //Process the response
        String strResponse = res.getBody();
        if(res.getStatusCode() != 200) throw new WSException('Callout failed. Status: ' + res.getStatusCode() + ' - ' + res.getStatus() + ' Response: ' + strResponse);
        Integer intOrderNumber = null;
        List<OrderError> lstErrors = new List<OrderError>();
        if(strResponse.contains('<GvVbeln>')){
            String strOutput = strResponse.subString(strResponse.indexOf('<GvVbeln>'),strResponse.indexOf('</GvVbeln>') + 10);
            XmlStreamReader reader = new XmlStreamReader(strOutput);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'GvVbeln' == reader.getLocalName()) {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS) intOrderNumber = Integer.valueOf(reader.getText());
                }
                reader.next();
            }
        } else if(strResponse.contains('<GtReturn>')){
            String strReturn = strResponse.subString(strResponse.indexOf('<GtReturn>'),strResponse.indexOf('</GtReturn>') + 11);
            XmlStreamReader reader = new XmlStreamReader(strReturn);
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && 'item' == reader.getLocalName()) {
                    OrderError oe = new OrderError();
                    while(!(reader.getEventType() == XmlTag.END_ELEMENT && 'item' == reader.getLocalName())){
                        if('Type' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) oe.strType = reader.getText();
                        } else if('Message' == reader.getLocalName()){
                            reader.next();
                            if(reader.getEventType() == XmlTag.CHARACTERS) oe.strMessage = reader.getText().replaceAll('^0+', '');
                        } else {
                            reader.next();
                        }
                    }
                    lstErrors.add(oe);
                }
                reader.next();
            }
        } else {
            //Throw the response as an error if it isn't in the expected format of a valid response
            throw new WSException('Invalid response: ' + strResponse);
        }
        OrderResponse r = new OrderResponse();
        r.intOrderNumber = intOrderNumber;
        r.lstErrors = lstErrors;
        return r;
    }
}