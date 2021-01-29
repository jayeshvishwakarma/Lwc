/**
* @Author-: Nishant Prajapati
* @Company-: Techmatrix Consulting
* @Description-: Contains method for APEX Callout to fetch details from Mulesoft APIs.
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 1/15/2020, 10:10:42 PM
* @Modification Log   : Updated the API name for metadata type
* =============================================================
*  Version   Date            Author      Modification
* =============================================================
*  1.0       10 July 2019    Nishant     Intial Version
*  1.1       22 July 2019    Nishant     SVOC API
*  1.2       26 July 2019    Nishant     Product Stock API
*  1.3       05 Sept 2019    Anuj        Closed Follow Ups API
*  1.4       03 Oct 2019     Sunit       Added createHttpRequest method
**/


public without sharing class  MSILMuleSoftIntegration {
    

    /**
        Author: Sunit Chand
        Company: Techmatrix
        Description: Method to fetch availabel time slots for test drive from MuleSoft
        Inputs: Strings(8)
        Returns: Continutation Object
        History:
        ====================================================
        1.0  10 Jul 2019  Sunit Chand  Initial Version
        1.1  10 Jan 2020  Prabhat  
    **/  
    @AuraEnabled(continuation=true cacheable=true)
    public static Object getTestDriveSlot(string apiType, string vin, string model, string variant, string dateRange, string enquiryId, string mspin, string orgId){
        
        
        try{
            MuleSoft_API_Details__mdt[] svocMappings= [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c, x_channel_id__c, x_channel_token__c,
                                                       x_transaction_id__c,Authorization__c FROM MuleSoft_API_Details__mdt WHERE MasterLabel =: apiType];
            
            if(svocMappings.size() > 0){
                
                //Reschedule Test drive fix - 10th Jan - Prabhat
                 if(string.isNotEmpty(vin) && vin.startsWithIgnoreCase('__TD__') ){
                     vin = vin.replace('__TD__','');
                 }
            
                //Do not delete this line
                //string longRunningServiceUrl= svocMappings[0].Endpoint__c+'?vin='+vin+'&model='+model+'&variant='+variant+'&dateRange='+dateRange+'&enquiryId='+enquiryId+'&mspin='+mspin+'&orgId='+orgId;
                String longRunningServiceUrl= svocMappings[0].Endpoint__c;
                longRunningServiceUrl+=ConstantsUtility.QUESTION_MARK+ConstantsUtility.VIN_NO+ConstantsUtility.EQUALS+vin;
                longRunningServiceUrl+=ConstantsUtility.AMPERSAND+ConstantsUtility.DATE_RANGE+ConstantsUtility.EQUALS+dateRange;
                longRunningServiceUrl+=ConstantsUtility.AMPERSAND+ConstantsUtility.ENQUIRY_ID+ConstantsUtility.EQUALS+enquiryId;
                longRunningServiceUrl+=ConstantsUtility.AMPERSAND+ConstantsUtility.MSPIN+ConstantsUtility.EQUALS+mspin;
                longRunningServiceUrl+=ConstantsUtility.AMPERSAND+ConstantsUtility.ORG_ID+ConstantsUtility.EQUALS+orgId;
                
                Continuation con = new Continuation(Integer.valueof(svocMappings[0].TimeOut_Value__c));
                con.state = ConstantsUtility.GET_TEST_DRIVE_SLOTS;
                
                // Set callback method
                //if(!Test.isRunningTest()){
                    con.continuationMethod=ConstantsUtility.PROCESS_CALLBACK;
                /*}else{
                    con.ContinuationMethod=ConstantsUtility.MOCK_CALLBACK;
                }*/
                
                // Create callout request
                HttpRequest request = new HttpRequest();
                System.debug(longRunningServiceUrl);
                //Create API request
                request=createHttpRequest(ConstantsUtility.GET_REQUEST,longRunningServiceUrl,svocMappings[0],'');
                System.debug('API Start Time'+ DateTime.now().millisecond());
                // Add callout request to continuation
                con.addHttpRequest(request);
                System.debug('API End Time'+ DateTime.now().millisecond());
                return con;
            }
            return null;
        }catch(Exception ex){
            return null;
        }
    }


    /**
        Author: Sunit Chand
        Company: Techmatrix
        Description: Method to API Callout to create, update or cancel test drive booking
        Inputs: Strings(4)
        Returns: Continutation Object
        History:
        ====================================================
        1.0  10 Jul 2019  Sunit Chand  Initial Version
    **/  
    @AuraEnabled(continuation=true cacheable=true)
    public static Object createOrUpdateOrCancelBooking(string apiType, string methodType,String testDriveRawData,String bookingID){
        try{
             //Reschedule Test drive fix - 15th Jan - Prabhat
             if(string.isNotBlank(testDriveRawData) && testDriveRawData.contains('__TD__') ){
                 testDriveRawData = testDriveRawData.remove('__TD__');
             }

            System.debug(testDriveRawData);
            MuleSoft_API_Details__mdt[] svocMappings= [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c, x_channel_id__c, x_channel_token__c,
                                                       x_transaction_id__c,Authorization__c FROM MuleSoft_API_Details__mdt WHERE MasterLabel =: apiType];
            
            if(svocMappings.size() > 0){
                Continuation con = new Continuation(Integer.valueof(svocMappings[0].TimeOut_Value__c));
                con.state = ConstantsUtility.CREATE_DRIVE_SLOTS;

                //Set the callback Method
                if(!Test.isRunningTest()){
                    con.continuationMethod=ConstantsUtility.PROCESS_CALLBACK;
                }else{
                    con.ContinuationMethod=ConstantsUtility.MOCK_CALLBACK;
                }

                //Get the end point and add the booking ID if it is a Cancel or Update test drive request
                String apiEndPoint=svocMappings[0].Endpoint__c;
                if(apiType!=ConstantsUtility.CREATE_BOOKING){
                    apiEndPoint=apiEndPoint+ConstantsUtility.FORWARD_SLASH+bookingID;
                } 

                HttpRequest request= new HttpRequest();
                //Create API request
                request=createHttpRequest(methodType,apiEndPoint,svocMappings[0],testDriveRawData);
                System.debug('API Start Time'+ DateTime.now().millisecond());
                //Add the request in the continuation object
                con.addHttpRequest(request);
                System.debug('API End Time'+ DateTime.now().millisecond());
                return con;
            }
            return null;
            
        }catch(Exception ex){
            return null;
        }
    }
    
    
    /**
        Author: Nishant
        Company: Techmatrix
        Description: Method to API Callout to fetch product stock list
        Inputs: Strings(6)
        Returns: Continutation Object
        History:
        ====================================================
        1.0  10 Jul 2019  Nishant  Initial Version
    **/  
    @AuraEnabled(continuation=true cacheable=true)
    //public static Object getProductStockList(string apiType, string variantCode, string colorCode, string dealerMapCode,  string locationCode, string parentCode,String productType, String consingneeCode){
    public static Object getProductStockList(String queryData){    
    try{
            Map<String,Object> jsonData= (Map<String,Object>)JSON.deserializeUntyped(queryData);
            String apiType=(String)jsonData.get('apiType');
            String variantCode=(String)jsonData.get('variantCode');
            String colorCode=(String)jsonData.get('colorCode');
            String dealerMapCode=(String)jsonData.get('dealerMapCode');
            String locationCode=(String)jsonData.get('locationCode');
            String parentCode=(String)jsonData.get('parentCode');
            String productType=(String)jsonData.get('productType');
            String consingneeCode=(String)jsonData.get('consingneeCode');
            String userType=(String)jsonData.get('userType');
        
            MuleSoft_API_Details__mdt[] muleSoftAPIDetailsMap = [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c, x_channel_id__c, x_channel_token__c,
                                                   Authorization__c, x_transaction_id__c FROM MuleSoft_API_Details__mdt WHERE MasterLabel=: apiType];
            
            if(muleSoftAPIDetailsMap.size() > 0){
                //string endpoint= MuleSoftAPIDetailsMap[0].Endpoint__c+'?VariantCode='+variantCode+'&ColorCode='+colorCode+'&DealerMapCode='+dealerMapCode+'&LocationCode='+locationCode+'&ParentCode='+parentCode;
                String endpoint = muleSoftAPIDetailsMap[0].Endpoint__c+'?parentGroup='+parentCode+'&DealerMapCode='+dealerMapCode+'&LocationCode='+locationCode+'&VariantCode='+variantCode+'&ColorCode='+colorCode+'&ProductType='+productType;
                if(productType=='A' && userType=='I')
                {
                    endpoint = muleSoftAPIDetailsMap[0].Endpoint__c+'?ProductType='+productType+'&UserType='+userType+'&ConsigneeCode='+consingneeCode+'&PartNumber='+variantCode;
                }
                else if(productType=='A' && userType=='E')
                {
                    endpoint = muleSoftAPIDetailsMap[0].Endpoint__c+'?ProductType='+productType+'&DealerMapCode='+dealerMapCode+'&LocationCode='+locationCode+'&PartNumber='+variantCode+'&UserType='+userType;
                }
                System.debug(endpoint);
                Continuation con = new Continuation(Integer.valueof(muleSoftAPIDetailsMap[0].TimeOut_Value__c));
                con.state = ConstantsUtility.STOCK_CHECK;
                
                // Set callback method
                if(!Test.isRunningTest()){
                    con.continuationMethod=ConstantsUtility.PROCESS_CALLBACK;
                }else{
                    con.ContinuationMethod=ConstantsUtility.MOCK_CALLBACK;
                }

                HttpRequest request = new HttpRequest();
                //Create API Request
                request=createHttpRequest(ConstantsUtility.GET_REQUEST,endpoint,muleSoftAPIDetailsMap[0],'');  
                System.debug('API Start Time'+ DateTime.now().millisecond());
                //Add the request to continuation object
                con.addHttpRequest(request);
                System.debug('API End Time'+ DateTime.now().millisecond());
                return con;
            }
            return null;
            
        }catch(Exception ex){
            return null;
        }
    }
    
   /**
        Author: Nishant
        Company: Techmatrix
        Description: Call back method for all continuation call outs
        Inputs: Strings(6)
        Returns: Object
        History:
        ====================================================
        1.0  10 Jul 2019  Nishant  Initial Version
    **/  
    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state){
        Object returnObj;
        String componentName = (String) state;
        // Get the response by using the unique label
        System.debug('API Start Time'+ DateTime.now().millisecond());
        HttpResponse response= Continuation.getResponse(labels[0]);
        System.debug(response.getBody());
        //System.debug(response.getStatusCode());
       // System.debug(response.getStatus());
        System.debug('API End Time'+ DateTime.now().millisecond()); 
        
        if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
            returnObj=response.getBody();
        }else{
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = componentName;
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('MSILMuleSoftIntegration', response.getStatusCode()+':'+system.label.UI_Error_Message, componentName, '', ehst);
            //Return Error Message to the component
            returnObj=(object) system.label.UI_Error_Message;
        }
        return returnObj;
    }
    
  
    /*
        * @Method-: mockResponse
        * @Description-: Callback method for returning mock response for action method
    */
    public static Object mockResponse() {
        return null;
    }
    

    /**
        Author: Sunit kumar chand
        Company: Techmatrix
        Description: This function is used to create HTTP request
        Inputs: Method Type,URL,MuleSoft_API_Details__mdt
        Returns: HttpRequest object
        History:
        ================
        1.0     03 Oct 2019      Sunit     Initial Version
    **/
    public static HttpRequest createHttpRequest(String methodType,String longRunningServiceUrl,MuleSoft_API_Details__mdt svocMappings,String bodyContent){
        HttpRequest req = new HttpRequest();
        
        //Set the Request body for API request type as POST or PUT
        if(methodType==ConstantsUtility.POST_REQUEST || methodType==ConstantsUtility.PUT_REQUEST){
            req.setBody(bodyContent);
        }
        
        system.debug('== request Body '+req.getBody());
        //Set Request Method Type
        req.setMethod(methodType);
        //Set Request End Point
        req.setEndpoint(longRunningServiceUrl);
        //Set Header values from metadata
        req.setHeader(ConstantsUtility.CHANNEL_ID_CONST, svocMappings.x_channel_id__c);
        req.setHeader(ConstantsUtility.CHANNEL_TOKEN_CONST, svocMappings.x_channel_token__c);
        req.setHeader(ConstantsUtility.CHANNEL_TRANSACTION_ID_CONST, svocMappings.x_transaction_id__c);
        req.setHeader(ConstantsUtility.ACCEPT_HEADER_LABEL, ConstantsUtility.ACCEPT_HEADER_VALUE);
        req.setHeader(ConstantsUtility.AUTH_HEADER_LABEL, svocMappings.Authorization__c);
        req.setHeader(ConstantsUtility.CONTENT_TYPE_HEADER_LABEL, ConstantsUtility.ACCEPT_HEADER_VALUE);

        //Return HTTP Request Instance
        return req;
    }
    
}