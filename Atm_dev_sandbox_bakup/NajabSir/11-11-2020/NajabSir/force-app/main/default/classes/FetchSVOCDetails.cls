/**
 * @File Name          : FetchSVOCDetails.cls
 * @Description        : This class fetches details from SVOC Maruti DB and displays in Salesforce in multiple components.
 * @Author             :
 * @Group              :
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 3/16/2020, 12:17:09 PM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
* 1.0    7/05/2019, 9:14:54 PM      Prabhat Sharma                Initial Version
  1.1    9/09/2019, 4:14:54 PM      Sunit Kumar Chand             getCustomerDetails method added
**/

public with sharing class FetchSVOCDetails {
   
    private static final List<String> CAR_SVOC_DETAILS = new List<String>{
        //'Car_Details',
        'Ownership_History', //Updated as per 1.1A requirement ( 09/03/2020 by Sunit )
        'Insurance_History',
        'Service_History',
        'EW',
        'MCP'
    };    

    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will return based on the passed in argument (e.g. Loyalty, Referral etc.)
        Inputs: Search string
        Returns: List of wrapper class including details of field label and value
        History:
        ================
        1.0     05 Jul 2019      Prabhat     Initial Version
    */
    @AuraEnabled(continuation=true cacheable=true)
    public static Object fetchSelectedSVOCDetails(String svocDetail,String svocId,String vin) {
        //Custom metadata developer name
        BasicReturn br=new BasicReturn();
        try{
            String svocDetailName = svocDetail.replaceAll(' ','_');
            svocDetail = CAR_SVOC_DETAILS.contains(svocDetailName) ? 'Car_Details' : svocDetailName;
            //Map to store the Mulesoft API details
            Map<string, MuleSoft_API_Details__mdt> svocApiDetailMap= new Map<string, MuleSoft_API_Details__mdt>();
            for(MuleSoft_API_Details__mdt apiDetail : [SELECT DeveloperName,DealerMapCode__c,Endpoint__c, LocationCode__c,UserType__c,TimeOut_Value__c,x_channel_id__c,x_channel_token__c,Parameters__c,Parameter_API_Keys__c,Authorization__c,x_transaction_id__c,Api_Name__c FROM MuleSoft_API_Details__mdt WHERE DeveloperName=:svocDetail]){
                svocApiDetailMap.put(apiDetail.DeveloperName.toLowerCase(), apiDetail);                                                    
            }
            //This will have the end point of the request
            String apiEndPoint;
            svocDetail = svocDetail.toLowerCase();
            //If the map has end point details, construct the end point
            if(svocApiDetailMap.containsKey(svocDetail) && String.isNotBlank(svocApiDetailMap.get(svocDetail).Endpoint__c)){
               String[] reqParametersAPIKey=svocApiDetailMap.get(svocDetail).Parameter_API_Keys__c.split(',');
               BasicReturn apiRequestData=getCustomerDetails(svocApiDetailMap.get(svocDetail).Parameters__c,reqParametersAPIKey);
               //System.debug(svocDetail);
               apiEndPoint = svocApiDetailMap.get(svocDetail).Endpoint__c+'/'+svocId+'/'+svocApiDetailMap.get(svocDetail).Api_Name__c;
               if(svocDetail==ConstantsUtility.CUSTOMER_VEHICLE_HISTORY && svocId!=null && svocId!='')
               {
                   apiEndPoint = svocApiDetailMap.get(svocDetail).Endpoint__c+'='+svocId;
                   
               }
                else if(svocDetail==ConstantsUtility.CUSTOMER_VEHICLE_HISTORY && vin!=null && vin!='')
                {
                    apiEndPoint = svocApiDetailMap.get(svocDetail).Endpoint__c+'='+vin;
                    apiEndPoint=apiEndPoint.replace('customerId','vin');
                }
               
                br=apiRequestData;
                if(apiRequestData.status=='Success'){
                    for(String apiKey: apiRequestData.getStringMap.keySet()){
                        if(apiEndPoint.contains('?')){
                            apiEndPoint += '&'+apiKey+'='+apiRequestData.getStringMap.get(apiKey);
                        }
                        else{
                            apiEndPoint += '?'+apiKey+'='+apiRequestData.getStringMap.get(apiKey);
                        }
                    }
                }
            }
            system.debug('== apiEndPoint '+apiEndPoint);
            
            if(String.isNotBlank(apiEndPoint) && svocApiDetailMap.containsKey(svocDetail)){
                
                //Timeout for Continuation object
                Integer timeOut = svocApiDetailMap.get(svocDetail).TimeOut_Value__c!=null ? Integer.valueOf(svocApiDetailMap.get(svocDetail).TimeOut_Value__c) : ConstantsUtility.DEFAULT_TIMEOUT_CONST;
                //Initializing continuation object
                Continuation con= new Continuation(timeOut);
                //Callback function
                con.continuationMethod='processResponse';
                //API Request
                HttpRequest request= new HttpRequest();
                request.setEndpoint(apiEndPoint);
                request.setMethod('GET');
                request.setHeader(ConstantsUtility.CHANNEL_TRANSACTION_ID_CONST, svocApiDetailMap.get(svocDetail).x_transaction_id__c);
                request.setHeader(ConstantsUtility.CHANNEL_TOKEN_CONST, svocApiDetailMap.get(svocDetail).x_channel_token__c);
                request.setHeader(ConstantsUtility.CHANNEL_ID_CONST, svocApiDetailMap.get(svocDetail).x_channel_id__c);
                request.setHeader('Content-Type', 'application/json');            
                request.setHeader('Authorization', svocApiDetailMap.get(svocDetail).Authorization__c);
                request.setHeader('Accept', 'application/json');
                System.debug('API Start Time'+ DateTime.now().millisecond());
                //Add api request to continuation object
                con.addHttpRequest(request);
                con.state = svocDetailName;
                System.debug('API End Time'+ DateTime.now().millisecond());
                //Return continuation object
                return con;
                //br.data=con;
            }
        }
        catch(Exception e)
        {
            br.code=1;
            br.message=e.getMessage();
            br.status='error';
        }
        System.debug(br);
        return br;
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will receive the API response as a callback function
        Inputs: List of string and Object defining continuation state
        Returns: A wrapper object
        History:
        ====================================================
        1.0     30 Jul 2019      Prabhat     Initial Version
    */
    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels, Object state){
       
        System.debug('Inside processResponse');
        boolean serviceOrInsuranceProfile=false;
        String profileName=StockCheckCtrl.isHostessProfile(); // This method will return current user's profile
        System.debug(profileName);
        for(String prof:system.label.Service_and_Insurance_Profiles.split(';')){
            if(prof==profileName){
                serviceOrInsuranceProfile=true;
            }
        }
        //Get the selected svoc from Continuation state attribute
        String selectedSvocDetail = (String)state;
       
        //Create metadata developer name
        selectedSvocDetail = selectedSvocDetail.replaceAll(' ','_');
        // Added this line as we have updated the label to Ownership History ( 09/03/2020 by Sunit )
        selectedSvocDetail=selectedSvocDetail=='Ownership_History'?'Car_Details':selectedSvocDetail;
        System.debug(selectedSvocDetail);
       
        //This will contain the tabel headers
        list<string> fieldlist = new list<string>();
        //This will contain the response keys
        list<string> keyslist = new list<string>();
        //svoc type of data and the keu map
        map<string,string> svocDetailmap = new map<string,string>();
       
        //Loop through SVOC detail metadata type
        for(SVOC_Details__mdt svocdetailss : [SELECT Fields__c,keys__c,DeveloperName,API_Data_Key__c,
                                               Service_Fields__c,Service_Keys__c 
                                              FROM SVOC_Details__mdt WHERE DeveloperName=: selectedSvocDetail]){
            if(serviceOrInsuranceProfile){
                keyslist.addAll(svocdetailss.Service_Keys__c.split(';'));
                fieldlist.addAll(svocdetailss.Service_Fields__c.split(';'));
            }
            else{
            keyslist.addAll(svocdetailss.keys__c.split(';'));
            fieldlist.addAll(svocdetailss.Fields__c.split(';'));
            }
            svocDetailmap.put(svocdetailss.DeveloperName,svocdetailss.API_Data_Key__c);
        }


        //Map for putting the response key headers to be replaced with actual headers
        map<string,string> responseHeaderLabelmap = new map<string,string>();

        //Fill the map to hold API response keys and actual labels as headers
        if(keyslist.size()>0 && fieldlist.size()>0){
            for(integer i=0;i<fieldlist.size();i++){
                responseHeaderLabelmap.put(keyslist[i],fieldlist[i]);
            }
        }

        System.debug('API Start Time'+ DateTime.now().millisecond());
        // Get the API response by using the unique label
        HttpResponse response= Continuation.getResponse(labels[0]);
        System.debug('API End Time'+ DateTime.now().millisecond());
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        //Master wrapper to hold the labels and the list of values
        FetchSVOCDetails.SVOCMasterWrapper masterWrap = new FetchSVOCDetails.SVOCMasterWrapper();
        //Parse the response as an untyped JSON object
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
            //Check if the mulesoft response is success
            if(resultMap.get('status')=='Success' && resultMap.containskey(ConstantsUtility.API_STATUS_CONST) && resultMap.get(ConstantsUtility.API_STATUS_CONST)==ConstantsUtility.API_RESPONSE_CONST){
                //Unique key for each API response recieved
                String dataKey = svocDetailmap.containsKey(selectedSvocDetail) ? svocDetailmap.get(selectedSvocDetail) : '';
                //Get all the details in list of object
                List<Object> resultObjlist = (List<Object>)resultmap.get(dataKey);
               
               
                //To store all keys as recived in the response
                set<String> tableHeaders = new set<String>();
                list<FetchSVOCDetails.FieldValueWrapper> fwrapList = new list<FetchSVOCDetails.FieldValueWrapper>();
                //Loop through the list of object to get the
                for(Object obj : resultObjlist){
                    //Create a map of key attributes and their values
                    Map<String, Object> objectAttributes = (Map<String, Object>)obj;

                    //Add all te keys to get the actual headers
                    tableHeaders.addAll(objectAttributes.keySet());
                    //Create a wrapper instance to add all response values in a list of object
                    FetchSVOCDetails.FieldValueWrapper fwrap = new FetchSVOCDetails.FieldValueWrapper();
                    fwrap.svocFieldValue = new list<Object>();
              //Commented by Sunit on 2019-09-27 for dynamic label fixing
                    /*for(Object newObj : objectAttributes.values()){
                        fwrap.svocFieldValue.add(newObj);
                    }*/
              //Added by Sunit on 2019-09-27 for dynamic label fixing
                    for(String key : keyslist){
                        fwrap.svocFieldValue.add(getValue(objectAttributes, key));
                    }
                    fwrapList.add(fwrap);
                }
               // System.debug(fwrapList);
              //Added by Sunit on 2019-09-27 for dynamic label fixing
              if(!fwrapList.isEmpty()){
                  masterWrap.svocFielLabelList=fieldlist;
              }
               
             //Commented by Sunit on 2019-09-27 for dynamic label fixing
                //Loop through
                /*for(String headers : tableHeaders){
                    if(responseHeaderLabelmap.containsKey(headers)){
                        String columnLabel = responseHeaderLabelmap.get(headers);
                        masterWrap.svocFielLabelList.add(columnLabel);
                    }
                }*/

                //Add all the values to master wrapper
                masterWrap.fieldValueWrapList = fwrapList;
                masterWrap.rawResponse=response.getBody();
                masterWrap.keys=keyslist;
                }
            }
        else
        {
          ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();
          ehst.componentName='FetchSVOCDetails';
          ehst.userId=UserInfo.getUserId();
          ExceptionHandler.LogError('FetchSVOCDetails',response.getStatusCode()+':'+System.label.UI_Error_Message , selectedSvocDetail, '', ehst);
        }
        
        
        System.debug(response.getStatus());
        BasicReturn br=new BasicReturn();
        br.code=response.getStatusCode();
       
        if(response.getStatusCode()==200)
        {
            br.status=String.valueof(resultMap.get('status'));
        }
        else
        {
            br.status='error';
        }
       
        br.data=masterWrap;
        //br.message=response.g
        System.debug(masterWrap);
        return br;
    }
    
     /**
        Author: Anuj Kumar
        Company: TechMatrix
        Description: 
        History:
        ====================================================
        1.0     02 Apr 2020      Anuj     Initial Version
    */
    @AuraEnabled(cacheable=true)
    public static BasicReturn fetchMGAHistoryDetails(String recordId, String svocId, String vin, String customerId) {
        BasicReturn br = new BasicReturn();
        
        if(recordId.startsWith('02i')){
            br = callSericeForMGAHistory(svocId, new List<String> {vin});
        }else{
            List<String> vinNoList = new List<String>();
            customerId = customerId !=null ? customerId : recordId;
            String assetVehicleRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
            for(Asset ast : [SELECT id, Name, VIN__c from asset where recordTypeId =: assetVehicleRecTypId 
                        AND AccountId =: customerId]){
                vinNoList.add(ast.VIN__c);
            }
            if(vinNoList != Null && vinNoList.size() > 0){
                br = callSericeForMGAHistory(svocId, vinNoList);
            }
        }
        
        return br;
    }
    
    public static BasicReturn callSericeForMGAHistory(string customerId, List<String> vinNoList){
        BasicReturn br = new BasicReturn();
        FetchSVOCDetails.SVOCMasterWrapper masterWrap = new FetchSVOCDetails.SVOCMasterWrapper();
        
        List<MuleSoft_API_Details__mdt> apiDetailList = [SELECT DeveloperName,DealerMapCode__c,Endpoint__c, LocationCode__c,UserType__c,TimeOut_Value__c,x_channel_id__c,x_channel_token__c,Parameters__c,Parameter_API_Keys__c,Authorization__c,x_transaction_id__c,Api_Name__c FROM MuleSoft_API_Details__mdt WHERE DeveloperName= 'MGA_History'];
        
        //This will contain the tabel headers
        List<string> fieldlist = new list<string>();
        
        //This will contain the response keys
        List<string> keyslist = new list<string>();
        
        //Loop through SVOC detail metadata type
        for(SVOC_Details__mdt svocdetailss : [SELECT Fields__c,keys__c,DeveloperName,API_Data_Key__c FROM SVOC_Details__mdt WHERE DeveloperName= 'MGA_History']){
            keyslist.addAll(svocdetailss.keys__c.split(';'));
            fieldlist.addAll(svocdetailss.Fields__c.split(';'));
        }
        
        if(apiDetailList != null && apiDetailList.size() > 0){
        
            string apiEndPoint = '';
            
            apiEndPoint = apiDetailList[0].Endpoint__c + '='+customerId;
            
            List<Object> resultObjlist = new List<Object>();
            
            HttpRequest request= new HttpRequest();
            
            request.setMethod('GET');
            request.setHeader(ConstantsUtility.CHANNEL_TRANSACTION_ID_CONST, apiDetailList[0].x_transaction_id__c);
            request.setHeader(ConstantsUtility.CHANNEL_TOKEN_CONST, apiDetailList[0].x_channel_token__c);
            request.setHeader(ConstantsUtility.CHANNEL_ID_CONST, apiDetailList[0].x_channel_id__c);
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('Authorization', apiDetailList[0].Authorization__c);
            request.setHeader('Accept', 'application/json');
            
            
            for(Integer i=0; i< vinNoList.size(); i++){
                
                string endPoint = apiEndPoint + '&vin='+vinNoList[i] + '&transType=A';
                system.debug('== endPoint '+endPoint);

                request.setEndpoint(endPoint);
                
                HttpResponse response = new Http().send(request);
                system.debug('== response.getBody() '+response.getBody());
                
                if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
                    
                    br.code = response.getStatusCode();
        
                    Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    
                    if(resultMap != null){
                        br.status=String.valueof(resultMap.get('status'));
                        
                        List<Object> tempDataList = (List<Object>)resultMap.get('customerVehiclesList');
                        if(tempDataList != null){
                            Map<String, Object> customerVehicleMap = (Map<String, Object>) tempDataList[0];
                            if(customerVehicleMap != Null){
                                system.debug('== tempDataList '+tempDataList);
                                List<Object> tempResultObjlist = (List<Object>) customerVehicleMap.get('MGAHistoryList');
                                system.debug('== tempResultObjlist '+tempResultObjlist);
                                if(tempResultObjlist != null)
                                    resultObjlist.addAll(tempResultObjlist);
                            }
                        }
                    }
                }else{
                    br.status='error';
                }
            }
            
            system.debug('== resultObjlist '+resultObjlist);
            
            set<String> tableHeaders = new set<String>();
            list<FetchSVOCDetails.FieldValueWrapper> fwrapList = new list<FetchSVOCDetails.FieldValueWrapper>();
            
            //Loop through the list of object to get the 
            for(Object obj : resultObjlist){
            
                //Create a map of key attributes and their values
                Map<String, Object> objectAttributes = (Map<String, Object>)obj;

                //Add all te keys to get the actual headers
                tableHeaders.addAll(objectAttributes.keySet());
                
                //Create a wrapper instance to add all response values in a list of object
                FetchSVOCDetails.FieldValueWrapper fwrap = new FetchSVOCDetails.FieldValueWrapper();
                
                fwrap.svocFieldValue = new list<Object>();
          
                //Added by Sunit on 2019-09-27 for dynamic label fixing
                for(String key : keyslist){
                    fwrap.svocFieldValue.add(getValue(objectAttributes, key));
                }
                fwrapList.add(fwrap);
            }
            
            //Added by Sunit on 2019-09-27 for dynamic label fixing
            if(!fwrapList.isEmpty()){
                masterWrap.svocFielLabelList=fieldlist;
            }
            
            //Add all the values to master wrapper
            masterWrap.fieldValueWrapList = fwrapList; 
            //masterWrap.rawResponse = response.getBody();
            
            masterWrap.keys = keyslist;
        }
        
     //   br.code = 200;
     //   br.status = 'Success';
        br.data = masterWrap;
        
        return br;
    }
    
    
    /**
        Author: Sumit Gupta
        Company: Salesforce
        Description: parse response value
        History:
        ====================================================
        1.0     09 Sep 2019      Sunit     Initial Version
    */
    private static String getValue(Map<String, Object> data, String key){
        String value = '';
        try{
            if(key.contains('.')){
                List<String> keys = key.split('\\.');
                key = keys.get(0);
                if(data.containsKey(key)){
                    keys.remove(0);
                    value = getValue((Map<String, Object>) data.get(key), String.join(keys, '.'));
                }
            } else if(key.contains('+')){
                List<String> keys = key.split('\\+');
                List<String> values = new List<String>();
                for(String key2 : keys){
                    if(data.containsKey(key2)){
                        values.add(String.valueOf(data.get(key2)));
                    }
                }
                value = String.join(values, ' ');
            } else if(data.containsKey(key)){
                value = String.valueOf(data.get(key));
            }
        } catch(Exception ex){
            System.debug('Could not parse value');
        }
        return value==null?'':value;
    }

    /**
        Author: Sunit Kumar Chand
        Company: Techmatrix
        Description: This method is used to get Account detail of delear for API request
        Inputs:
        Returns:
        History:
        ====================================================
        1.0     09 Sep 2019      Sunit     Initial Version
    */
    public static BasicReturn getCustomerDetails(String parameters,String[] apiKeys)
    {
        //System.debug('Inside getCustomerDetails');
        User user;
        BasicReturn br= new BasicReturn();
        Map<String,String> apiRequestData= new Map<String,String>();
        try
        {
          //System.debug('Inside getCustomerDetails 1');
          String query='Select ';
          String userId=UserInfo.getUserId();
          userId=String.escapeSingleQuotes(userId);
          Map<String, Object> parametersMap=(Map<String, Object>)JSON.deserializeUntyped(parameters);
          if(apiKeys.size()>0){
               for(integer i=0;i<apiKeys.size();i++)
              {
                  if(String.valueOf(parametersMap.get(apiKeys[i])).contains('$user')){
                      query+=String.escapeSingleQuotes(String.valueOf(parametersMap.get(apiKeys[i])).split('user.')[1])+', ';  
                  }
              }
              query=query.substring(0,query.length()-2)+' from User where Id=\''+userId+'\'';
          }
            //System.debug(query);
            user=Database.query(query);
          //user=[Select AccountId,ContactId,contact.account.Dealer_Map_Code__c from User where Id=:UserInfo.getUserId()];
             if(user !=null ){
                Map<String, Object> userData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(user));
                //System.debug(userData);
                for(String apiKey: apiKeys)
                {
                    if(apiKey=='UserType' && String.valueOf(userData.get(apiKey))=='PowerPartner'){
                         apiRequestData.put(apiKey,'E');
                    }
                    else if(apiKey=='UserType' && String.valueOf(userData.get(apiKey))!='PowerPartner'){
                        //System.debug('Inside else IF');
                        apiRequestData.put(apiKey,'I');
                    }
                    if(apiKey!='UserType' && apiKey!='SVOCID' && String.valueOf(userData.get('UserType'))=='PowerPartner'){
                        String tempApiKey=String.valueOf(parametersMap.get(apiKey)).split('user.')[1];
                        String[] tempApiKeyArray=tempApiKey.split('.');
                        Map<String, Object> finalVal= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(userData.get('Contact'))) ;
                        System.debug(finalVal.get('Account'));
                        Map<String, Object> finalMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(finalVal.get('Account'))) ;
                        apiRequestData.put(apiKey,String.valueOf(finalMap.get(String.valueOf(parametersMap.get(apiKey)).split('user.contact.account.')[1]))==null?'':String.valueOf(finalMap.get(String.valueOf(parametersMap.get(apiKey)).split('user.contact.account.')[1])));
                    }
                   
                }
               
               
            }
            br.code=200;
            br.message='';
            br.status='Success';
            br.getStringMap=apiRequestData;
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
          //e.getStackTraceString();
          //ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();
          //ehst.componentName='FetchSVOCDetails';
          //ehst.userId=UserInfo.getUserId();
          //ExceptionHandler.LogError('FetchSVOCDetails', e.getMessage(), 'getCustomerDetails', '', ehst);
          br.code=1;
          br.message=e.getMessage();
          br.status='error';
         
        }
        //System.debug(apiRequestData);
        return br;
    }


    //Master wrapper class
    public class SVOCMasterWrapper{
        //This will store all the values
        @AuraEnabled public List<FetchSVOCDetails.FieldValueWrapper> fieldValueWrapList;
        //This will store all the labels
        @AuraEnabled public List<String> svocFielLabelList;
        //This will store raw response of API
        @AuraEnabled public String rawResponse;
        @AuraEnabled public List<String> keys;
        //This will store all the values
        @AuraEnabled public List<FetchSVOCDetails.filterWrapper> filterWrapperList;
        public SVOCMasterWrapper(){
            fieldValueWrapList = new list<FetchSVOCDetails.FieldValueWrapper>();
            filterWrapperList = new list<FetchSVOCDetails.filterWrapper>();
            svocFielLabelList = new list<String>();
        }
    }
    //Wrapper Class for holding the field values
    public class FieldValueWrapper{
        //Variable to store field value
        @AuraEnabled public List<Object> svocFieldValue;
    }
    public class filterWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String name;   
        @AuraEnabled public String datatype;   
        @AuraEnabled public boolean showOR;    
    }
    
       @AuraEnabled
    public static void updateDSEAccountForSVOCCounter()
    {
        //Updating cunter of SVOC accessed by DSE on its account
        List<Profile> p = [Select Id from profile where Name =: 'Dealer Sales Executive'];
        List<User> u = [select Id from user where id=:userinfo.getuserid() and ProfileId =: p[0].Id Limit 1];
        if(u.size() > 0)
        {   
            System.debug('u[0].Id'+u[0].Id);
            List<Account> acc = [Select Id,No_of_Times_SVOC_Accessed__c,SVOC_Accessed_Today__c,SVOC_accessed_this_month__c
                            from Account 
                            where User__c =: u[0].Id limit 1];
            if(acc.size() > 0)
            {   
                Integer num;
                Integer tdNum;
                Integer mNum;
                List<DSE_Report_RUn__c> dseRun =DSE_Report_RUn__c.getAll().values();  
                DateTime dt4 = system.now();
                DateTime dt3 = dseRun[0].Daily_End_Time_SVOC__c;
                DateTime dt5 = DateTime.newinstance(dt3.Year(), dt3.month(), dt3.day(),23,59,59);
                //convert above GMT datetime to local datetime
                dt3 = dt5.Date();
                dt3 = dt3.addHours(dt5.hour());
                dt3 = dt3.addMinutes(dt5.minute());
                dt3 = dt3.addSeconds(dt5.second());
                DateTime dt6 = dseRun[0].Month_End_Time_SVOC__c;
                DateTime dt7 = DateTime.newinstance(dt6.Year(), dt6.month(), dt6.day(),23,59,59);
                //convert above GMT datetime to local datetime
                dt6 = dt7.Date();
                dt6 = dt6.addHours(dt7.hour());
                dt6 = dt6.addMinutes(dt7.minute());
                dt6 = dt6.addSeconds(dt7.second());
                
                system.debug('246 %%$ '+dt4 + '' + dt3 + '' + dt6);
                if(acc[0].No_of_Times_SVOC_Accessed__c == null)
                       num =0;
                else
                    num = Integer.valueOf(acc[0].No_of_Times_SVOC_Accessed__c);
                           
                num +=1;      
                acc[0].No_of_Times_SVOC_Accessed__c = String.valueOf(num);
                
                //Calculate Daily Count
                if(acc[0].SVOC_Accessed_Today__c == null) 
                    tdnum =0;
                else
                    tdnum = Integer.valueOf(acc[0].SVOC_Accessed_Today__c);
                    
                if(dt4>dt3)
                {
                    List<DSE_Adoption__c> dse = [SELECT Id,CreatedDate,Count_of_SVOC_Accessed_Daily__c,DSEAccount__c
                                            FROM DSE_Adoption__c 
                                            Where DSEAccount__c =: acc[0].Id and IsMonthly__c = false
                                            ORDER BY CreatedDate DESC Limit 1];
                    dse[0].Count_of_SVOC_Accessed_Daily__c = tdnum;
                    tdnum = 1;
                    system.debug('618 %% '+dt3.addHours(24));
                    dseRun[0].Daily_End_Time_SVOC__c= (dseRun[0].Daily_End_Time_SVOC__c).addHours(24);
                    update dse[0];
                    update dseRun[0];
                }
                else
                {
                    tdnum +=1;       
                }
                acc[0].SVOC_Accessed_Today__c = tdnum;
                
                //Calculate MOnthly Count
                if(acc[0].SVOC_accessed_this_month__c == null) 
                    mNum =0;
                else
                    mNum = Integer.valueOf(acc[0].SVOC_accessed_this_month__c);
                    
                if(dt4>dt6)
                {
                    List<DSE_Adoption__c> dse = [SELECT Id,CreatedDate,Count_of_SVOC_Accesed_Month__c,DSEAccount__c
                                            FROM DSE_Adoption__c 
                                            Where DSEAccount__c =: acc[0].Id and IsMonthly__c = true
                                            ORDER BY CreatedDate DESC Limit 1];
                    dse[0].Count_of_SVOC_Accesed_Month__c = mNum;
                    mNum = 1;
                    dseRun[0].Month_End_Time_SVOC__c= (dseRun[0].Month_End_Time_SVOC__c).addMonths(1);
                    update dse[0];
                    update dseRun[0];
                }
                else
                {
                    mNum +=1;       
                }
                acc[0].SVOC_accessed_this_month__c = mNum;
        
                update acc[0];
            }
        }
    }
    @AuraEnabled
    public static BasicReturn tempmethod(string svocDetail){
      
        System.debug('Inside processResponse');
        System.debug(svocDetail);
        boolean serviceOrInsuranceProfile=false;
        String profileName=StockCheckCtrl.isHostessProfile(); // This method will return current user's profile
        System.debug(profileName);
        for(String prof:system.label.Service_and_Insurance_Profiles.split(';')){
            if(prof==profileName){
                serviceOrInsuranceProfile=true;
            }
        }
        //Get the selected svoc from Continuation state attribute
        String selectedSvocDetail = svocDetail;
       
        //Create metadata developer name
        selectedSvocDetail = selectedSvocDetail.replaceAll(' ','_');
        // Added this line as we have updated the label to Ownership History ( 09/03/2020 by Sunit )
        selectedSvocDetail=selectedSvocDetail=='Ownership_History'?'Car_Details':selectedSvocDetail;
        System.debug(selectedSvocDetail);
       
        //This will contain the tabel headers
        list<string> fieldlist = new list<string>();
        //This will contain the response keys
        list<string> keyslist = new list<string>();
        //svoc type of data and the keu map
        map<string,string> svocDetailmap = new map<string,string>();
        list<FetchSVOCDetails.filterWrapper> filterwrapList = new list<FetchSVOCDetails.filterWrapper>();
        //Loop through SVOC detail metadata type
        for(SVOC_Details__mdt svocdetailss : [SELECT Fields__c,keys__c,DeveloperName,API_Data_Key__c,
                                               Service_Fields__c,Service_Keys__c ,Filter_datatype__c,Filter_name__c,Filter_label__c
                                              FROM SVOC_Details__mdt WHERE DeveloperName=: selectedSvocDetail]){
            if(serviceOrInsuranceProfile){
                keyslist.addAll(svocdetailss.Service_Keys__c.split(';'));
                fieldlist.addAll(svocdetailss.Service_Fields__c.split(';'));
            }
            else{
            keyslist.addAll(svocdetailss.keys__c.split(';'));
            fieldlist.addAll(svocdetailss.Fields__c.split(';'));
            }
            svocDetailmap.put(svocdetailss.DeveloperName,svocdetailss.API_Data_Key__c);
            if(svocdetailss.Filter_datatype__c!=null && svocdetailss.Filter_name__c!=null && svocdetailss.Filter_label__c!=null){
                string[] filterName=svocdetailss.Filter_name__c.split(',');
                string[] filterlabel=svocdetailss.Filter_label__c.split(',');
                string[] filterdatatype=svocdetailss.Filter_datatype__c.split(',');
                if(filterName.size() == filterlabel.size()
                && filterdatatype.size() == filterlabel.size()){
                    for(integer i=0;i<filterName.size();i++){
                        FetchSVOCDetails.filterWrapper filterwrap = new FetchSVOCDetails.filterWrapper(); 
                        filterwrap.label=filterlabel[i];
                        filterwrap.name=filterName[i];
                        filterwrap.datatype=filterdatatype[i];
                        if(i!=filterName.size()-1){
                            filterwrap.showOR=true;
                        }
                        filterwrapList.add(filterwrap);  
                    }
                }
            }
        }


        //Map for putting the response key headers to be replaced with actual headers
        map<string,string> responseHeaderLabelmap = new map<string,string>();

        //Fill the map to hold API response keys and actual labels as headers
        if(keyslist.size()>0 && fieldlist.size()>0){
            for(integer i=0;i<fieldlist.size();i++){
                responseHeaderLabelmap.put(keyslist[i],fieldlist[i]);
            }
        }

        System.debug('API Start Time'+ DateTime.now().millisecond());
        // Get the API response by using the unique label
      /*  HttpResponse response= Continuation.getResponse(labels[0]);
        System.debug('API End Time'+ DateTime.now().millisecond());
        System.debug(response.getStatusCode());
        System.debug(response.getBody());*/
      string response ='{"messageId":"13376670-0227-11eb-99bb-06ce6f75f532","status":"Success","customerEnquiriesList":[{"Stage":"Evaluation for Exch","Model":"MARUTI ALTO LXI","Source":"Web Enquiry","TestDrive":false,"Exchange":false,"variant":"MARUTI ALTO LXI","dealerName":"PEGASUS (A UNIT OF VISUAL AUTOLINK PVT LTD)","dateOfTransaction":"2019-12-07T12:01:24","dealerAddress":"PLOT NO. 116 AND 118 2, NEAR RELIANCE PETROL PUMP, SARDAR PATEL RING ROAD,VASTRAL","outletType":"Outlet","booking":"","invoice":"","parentGroup":"PEVAL","dealerMapCode":13207,"dealerLocationCode":"AHB","status":null,"enquiryType":null,"purchasedVehicle":null,"soldVehicle":null,"programType":null,"enrollmentDate":null,"enrollmentId":null,"invoiceTv":null,"variantCode":"ANR4AL1","colorCode":"26U","enquiryNumber":null,"invoiceGp":null,"dealerCode":null},{"Stage":"Negotiation","Model":"MARUTI ALTO 800 LXI (O)","Source":"References","TestDrive":false,"Exchange":false,"variant":"MARUTI ALTO 800 LXI (O)","dealerName":"DREAM VEHICLES PVT LTD","dateOfTransaction":"2019-12-07T18:19:54","dealerAddress":"KHODIYAR TRACTORS,OPP.MARKETING YARD GIDC AREA,WADHWAN CITY SURENDERNAGAR,GUJARAT","outletType":"Outlet","booking":"","invoice":"","parentGroup":"DREAM","dealerMapCode":11010,"dealerLocationCode":"SGS","status":null,"enquiryType":null,"purchasedVehicle":null,"soldVehicle":null,"programType":null,"enrollmentDate":null,"enrollmentId":null,"invoiceTv":null,"variantCode":"ANR4CS9","colorCode":"26U","enquiryNumber":null,"invoiceGp":null,"dealerCode":null},{"Stage":"Negotiation","Model":"MARUTI ALTO LXI","Source":"Inbound Calls","TestDrive":false,"Exchange":false,"variant":"MARUTI ALTO LXI","dealerName":"ATUL MOTORS PVT LTD","dateOfTransaction":"2020-03-07T12:06:19","dealerAddress":"RAJKOT WANKANER HIGHWAY NEAR INTERNATIONAL CERAMIC DIST.RAJKOT","outletType":"E-Outlet","booking":"","invoice":"","parentGroup":"ATUL","dealerMapCode":11970,"dealerLocationCode":"WAE","status":null,"enquiryType":null,"purchasedVehicle":null,"soldVehicle":null,"programType":null,"enrollmentDate":null,"enrollmentId":null,"invoiceTv":null,"variantCode":"ANR4AL1","colorCode":"26U","enquiryNumber":null,"invoiceGp":null,"dealerCode":null},{"Stage":"Negotiation","Model":"MARUTI ALTO LXI","Source":"Web Enquiry","TestDrive":false,"Exchange":false,"variant":"MARUTI ALTO LXI","dealerName":"DREAM VEHICLES PVT LTD","dateOfTransaction":"2019-10-02T16:06:28","dealerAddress":"KHODIYAR TRACTORS,OPP.MARKETING YARD GIDC AREA,WADHWAN CITY SURENDERNAGAR,GUJARAT","outletType":"Outlet","booking":"","invoice":"","parentGroup":"DREAM","dealerMapCode":11010,"dealerLocationCode":"SGS","status":null,"enquiryType":null,"purchasedVehicle":null,"soldVehicle":null,"programType":null,"enrollmentDate":null,"enrollmentId":null,"invoiceTv":null,"variantCode":"ANR4AL1","colorCode":"26U","enquiryNumber":null,"invoiceGp":null,"dealerCode":null},{"Stage":"Invoiced ","Model":"MARUTI ALTO LXI","Source":"References","TestDrive":false,"Exchange":false,"variant":"MARUTI ALTO LXI","dealerName":"ATUL MOTORS PVT. LIMITED","dateOfTransaction":"2020-03-12T16:00:32","dealerAddress":"PLOT NO.49 1 & 2, GIDC, BHAKTI NAGAR INDUSTRIAL ESTATE RAJKOT","outletType":"Outlet","booking":"SOB19002594","invoice":"VSL 9001736","parentGroup":"ATUL","dealerMapCode":10720,"dealerLocationCode":"RAJ","status":null,"enquiryType":null,"purchasedVehicle":null,"soldVehicle":null,"programType":null,"enrollmentDate":null,"enrollmentId":null,"invoiceTv":null,"variantCode":"ANR4AL1","colorCode":"26U","enquiryNumber":null,"invoiceGp":null,"dealerCode":null}]}';
        //Master wrapper to hold the labels and the list of values
        FetchSVOCDetails.SVOCMasterWrapper masterWrap = new FetchSVOCDetails.SVOCMasterWrapper();
        //Parse the response as an untyped JSON object
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(response);
       // if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
            //Check if the mulesoft response is success
            if(resultMap.get('status')=='Success' && resultMap.containskey(ConstantsUtility.API_STATUS_CONST) && resultMap.get(ConstantsUtility.API_STATUS_CONST)==ConstantsUtility.API_RESPONSE_CONST){
                //Unique key for each API response recieved
                String dataKey = svocDetailmap.containsKey(selectedSvocDetail) ? svocDetailmap.get(selectedSvocDetail) : '';
                //Get all the details in list of object
                List<Object> resultObjlist = (List<Object>)resultmap.get(dataKey);
               
               
                //To store all keys as recived in the response
                set<String> tableHeaders = new set<String>();
                list<FetchSVOCDetails.FieldValueWrapper> fwrapList = new list<FetchSVOCDetails.FieldValueWrapper>();
                //Loop through the list of object to get the
                for(Object obj : resultObjlist){
                    //Create a map of key attributes and their values
                    Map<String, Object> objectAttributes = (Map<String, Object>)obj;

                    //Add all te keys to get the actual headers
                    tableHeaders.addAll(objectAttributes.keySet());
                    //Create a wrapper instance to add all response values in a list of object
                    FetchSVOCDetails.FieldValueWrapper fwrap = new FetchSVOCDetails.FieldValueWrapper();
                    fwrap.svocFieldValue = new list<Object>();
              //Commented by Sunit on 2019-09-27 for dynamic label fixing
                    /*for(Object newObj : objectAttributes.values()){
                        fwrap.svocFieldValue.add(newObj);
                    }*/
              //Added by Sunit on 2019-09-27 for dynamic label fixing
                    for(String key : keyslist){
                        fwrap.svocFieldValue.add(getValue(objectAttributes, key));
                    }
                    fwrapList.add(fwrap);
                }
               // System.debug(fwrapList);
              //Added by Sunit on 2019-09-27 for dynamic label fixing
              if(!fwrapList.isEmpty()){
                  masterWrap.svocFielLabelList=fieldlist;
              }
               
             //Commented by Sunit on 2019-09-27 for dynamic label fixing
                //Loop through
                /*for(String headers : tableHeaders){
                    if(responseHeaderLabelmap.containsKey(headers)){
                        String columnLabel = responseHeaderLabelmap.get(headers);
                        masterWrap.svocFielLabelList.add(columnLabel);
                    }
                }*/

                //Add all the values to master wrapper
                
                
              
            /*    FetchSVOCDetails.filterWrapper filterwrap1 = new FetchSVOCDetails.filterWrapper();
                FetchSVOCDetails.filterWrapper filterwrap2 = new FetchSVOCDetails.filterWrapper();
                FetchSVOCDetails.filterWrapper filterwrap3 = new FetchSVOCDetails.filterWrapper();
                filterwrap1.label='Booking #';
                filterwrap1.name='Stage';
                filterwrap1.datatype='text';
                filterwrapList.add(filterwrap1);
                filterwrap2.label='Invoice #';
                filterwrap2.name='Stage';
                filterwrap2.datatype='text';
                filterwrapList.add(filterwrap2);
                filterwrap3.label='Date of Transaction';
                filterwrap3.name='dateOfTransaction';
                filterwrap3.datatype='date';
                filterwrapList.add(filterwrap3);*/

                masterWrap.filterWrapperList = filterwrapList;
                masterWrap.fieldValueWrapList = fwrapList;
                masterWrap.rawResponse=response;
                masterWrap.keys=keyslist;
                }
         //   }
       /* else
        {
          ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();
          ehst.componentName='FetchSVOCDetails';
          ehst.userId=UserInfo.getUserId();
          ExceptionHandler.LogError('FetchSVOCDetails',response.getStatusCode()+':'+System.label.UI_Error_Message , selectedSvocDetail, '', ehst);
        }*/
        
        
       // System.debug(response.getStatus());
        BasicReturn br=new BasicReturn();
        br.code=200;
            br.status='Success';
        
       
        br.data=masterWrap;
        //br.message=response.g
        System.debug(masterWrap);
        return br;  

    }
}