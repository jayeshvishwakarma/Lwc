/**
 * @File Name          : ClosedFollowUpsCtrl.cls
 * @Description        : This class is used to check the Closed FollowUps from DMS.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 05/09/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    05/09/2019 05:30 PM          Anuj Kumar            Initial Version
**/

public with sharing class ClosedFollowUpsCtrl {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity retriveEnquiryInfo(String recordId){
    
        List<Opportunity> opportunityList = new List<Opportunity>();
        if(string.IsNotBlank(recordId) && isOpportunityAccessPermission()){
            opportunityList = [SELECT Id, DMS_Enquiry_Name__c, Dealership__c, Dealership__r.Parent_Group__c, 
                               Closed_General_FollowUp_Details__c, 
                               Dealership__r.Dealer_Map_Code__c, Dealership__r.Dealer_Location__c, Current_Follow_Up_Type__c, 
                               Booking_Number__c, Invoice_Number__c, VIN__c
                               FROM Opportunity 
                               Where Id =: recordId ];
                               // AND Recordtype.Name=:ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE
            if(opportunityList != null && opportunityList.size() > 0){
                return opportunityList[0];
            }
        }
        return null;
    }
    
    
     /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will return based on the passed in argument.
        Inputs: Search string
        Returns: List of wrapper class including details of field label and value
        History:
        ================
        1.0     06/09/2019      Anuj Kumar       Initial Version
    */
    @AuraEnabled(continuation=true cacheable=true)
    public static Object fetchCloseFollowUpDetails(string apiType, string parentGroup, string dealerMapCode, string locationCode,  string enquiryNumber, string generalFollowUpDetail) {
        
        //Custom metadata developer name
        apiType = apiType.replaceAll(' ','_');
        
        Map<string, MuleSoft_API_Details__mdt> apiDetailMap = new Map<string, MuleSoft_API_Details__mdt>();
        for(MuleSoft_API_Details__mdt apiDetail : [SELECT DeveloperName,DealerMapCode__c,Endpoint__c, LocationCode__c, 
                                                    UserType__c,TimeOut_Value__c,x_channel_id__c,x_channel_token__c,
                                                   Authorization__c,x_transaction_id__c
                                                    FROM MuleSoft_API_Details__mdt 
                                                    WHERE DeveloperName=: apiType]){
            apiDetailMap.put(apiDetail.DeveloperName, apiDetail);                                                    
        }
        
        //This will have the end point of the request for mock
        //string apiEndPoint = apiDetailMap.get(apiType).Endpoint__c+'?parentGroup='+parentGroup+'&DealerMapCode='+dealerMapCode+'&LocationCode='+locationCode+'&EnquiryNumber='+enquiryNumber+'&BookingNumber='+bookingNumber+'&InvoiceNumber='+invoiceNumber+'&VIN='+vin+'&PSF='+psf;
        
        //This will have the end point of the request for live
        string apiEndPoint = apiDetailMap.get(apiType).Endpoint__c+'?parentGroup='+parentGroup+'&DealerMapCode='+dealerMapCode+'&LocationCode='+locationCode+'&EnquiryNumber='+enquiryNumber;
        
        if(String.isNotBlank(apiEndPoint) && apiDetailMap.containsKey(apiType)){
            //Timeout for Continuation object
            Integer timeOut = apiDetailMap.get(apiType).TimeOut_Value__c!=null ? Integer.valueOf(apiDetailMap.get(apiType).TimeOut_Value__c) : ConstantsUtility.DEFAULT_TIMEOUT_CONST;
            
            //Initializing continuation object
            Continuation con= new Continuation(timeOut);
            //Callback function
            con.continuationMethod='processResponse';
            //API Request
            HttpRequest request= new HttpRequest();
            request.setEndpoint(apiEndPoint);
            request.setMethod('GET');
            request.setHeader(ConstantsUtility.CHANNEL_ID_CONST, apiDetailMap.get(apiType).x_channel_id__c);
            request.setHeader(ConstantsUtility.CHANNEL_TOKEN_CONST, apiDetailMap.get(apiType).x_channel_token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', apiDetailMap.get(apiType).Authorization__c);
            request.setHeader(ConstantsUtility.CHANNEL_TRANSACTION_ID_CONST, apiDetailMap.get(apiType).x_transaction_id__c);
            System.debug('API Start Time'+ DateTime.now().millisecond());
            //Add api request to continuation object
            con.addHttpRequest(request);
            con.state = apiType + '#####' + generalFollowUpDetail;
            System.debug('API End Time'+ DateTime.now().millisecond());
            //Return continuation object
            return con;
        }
        return null;
    }


    /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will receive the API response as a callback function
        Inputs: List of string and Object defining continuation state
        Returns: A wrapper object
        History:
        ====================================================
        1.0     06/09/2019      Anuj Kumar     Initial Version
    */
    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state){
        String generalFollowUpDetail = '';
        String selectedDetail = (String)state;
        generalFollowUpDetail = (selectedDetail.split('#####')!=null && selectedDetail.split('#####').size() > 1) ? selectedDetail.split('#####')[1] : '';
        selectedDetail = selectedDetail.split('#####')[0].replaceAll(' ','_');
        
        // Get the API response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);
        
        //Master wrapper to hold the labels and the list of values
        ResponseWrapper wrapper = new ResponseWrapper();
        
        Map<String, Object> resultMap;
        
        if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
           
            //   Parse the response as an untyped JSON object
            
            string tempResponse = '{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","EnquirynumberFollowupsList":[{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"},{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"},{"ReminderDateTime":"2019-08-23T16:41:41.090Z","DueDate":"2019-08-23","Remarks":"abcde","EnquiryNumber":"abcde","EnquiryStage":"abcde","Type":"abcde","FollowupStatus":"abcde","AssignedTo":"abcde"}]}';
            
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody().trim());
            
        }else{
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='ClosedFollowUps'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('ClosedFollowUps', system.label.UI_Error_Message, 'ClosedFollowUps', '', ehst);
            return (object) system.label.UI_Error_Message;
        }
        
        //   Check if the mulesoft response is success
        if(resultMap != Null && resultMap.size() > 0 && resultMap.containskey(ConstantsUtility.API_STATUS_CONST) && resultMap.get(ConstantsUtility.API_STATUS_CONST)==ConstantsUtility.API_RESPONSE_CONST){
            
            List<Object> resultObjList = (List<Object>)resultmap.get(ConstantsUtility.CLOSED_FOLLOWUP_APIKEY);
            
            system.debug('== resultObjList '+resultObjList);
            
            if(generalFollowUpDetail != Null && generalFollowUpDetail != '' && generalFollowUpDetail.contains('&quot;')){
                generalFollowUpDetail = generalFollowUpDetail.replace('&quot;', '"');
            }
            
            List<object> generalFollowUpList;
            if(generalFollowUpDetail != Null && generalFollowUpDetail != ''){
                generalFollowUpList = (List<Object>) JSON.deserializeUntyped(generalFollowUpDetail);
            }
            system.debug('== generalFollowUpList '+generalFollowUpList);
            
            if(generalFollowUpList != Null && generalFollowUpList.size() > 0){
                resultObjList.addAll(generalFollowUpList);
            }
            
            Set<String> keyFieldsFromResponseSet = new Set<String>();
            if(resultObjList != Null && resultObjList.size() > 0){
                keyFieldsFromResponseSet = ((map<string, object>) resultObjList[0]).keySet();
            }
            
            Map<Decimal, String> orderWithLabelMap = new Map<Decimal, String>();
            Map<Decimal, String> orderWithKeyMap = new Map<Decimal, String>();
            Map<String, String> keyWithLabelMap = new Map<String, String>();
            
            for(Closed_Follow_Up_Detail__mdt details : [SELECT Field_Label__c, Field_Key__c, DeveloperName, Order__c
                                        FROM Closed_Follow_Up_Detail__mdt
                                        WHERE Field_Key__c IN : keyFieldsFromResponseSet
                                        Order By Order__c]){
                
                orderWithLabelmap.put(details.Order__c, details.Field_Label__c);
                keyWithLabelmap.put(details.Field_Key__c.toLowerCase(), details.Field_Label__c);
                orderWithKeyMap.put(details.Order__c, details.Field_Key__c);
            }
            
            List<List<DataWrapper>> dataList = new List<List<DataWrapper>>();
            
            for(Object record : resultObjList){
                List<DataWrapper> singleRecordDataList = new List<DataWrapper>();
                Map<String, Object> singleRecordMap = new Map<String, Object>();
                
                Map<String, Object> tempSingleRecordMap = (Map<String, Object>) record;
                for(string recordKeys : tempSingleRecordMap.keySet()){
                    singleRecordMap.put(recordKeys.toLowerCase(), tempSingleRecordMap.get(recordKeys));
                }
                
                for(String field : keyWithLabelmap.keySet()){
                    DataWrapper dw = new DataWrapper();
                    
                    if(singleRecordMap.containsKey(field)){
                        dw.fieldData = string.valueOf(singleRecordMap.get(field)) != null ? string.valueOf(singleRecordMap.get(field)) : '';
                        dw.isTextField = True;
                        dw.isDateField = False;
                        dw.isDateTimeField = False;
                        
                        singleRecordDataList.add(dw);
                    }
                }
                dataList.add(singleRecordDataList);
            }
            
            wrapper.fieldLabelList = keyWithLabelmap.values();
            wrapper.fieldValueList = dataList;
            
            return wrapper;
        }else{
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='ClosedFollowUps'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('ClosedFollowUps', system.label.Closed_Follow_Ups_Error_Message, 'ClosedFollowUps', '', ehst);
            return (object) system.label.UI_Error_Message;
        }
        
    }
    
    //Master wrapper class
    public class ResponseWrapper{
        @AuraEnabled public List<String> fieldLabelList;
        @AuraEnabled public List<List<DataWrapper>> fieldValueList;
    }
    
    public class DataWrapper{
        @AuraEnabled public String  fieldData;
        @AuraEnabled public Boolean isTextField;
        @AuraEnabled public Boolean isDateField;
        @AuraEnabled public Boolean isDateTimeField;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/09/2019
        @Discription:             Wrapper class used to return the Closed Follow Ups Details.
        @Date Of Modification :   06/09/2019
    */
    public class FollowUpInfo{
        @AuraEnabled public List<String> labelData;
        @AuraEnabled public Opportunity opp;
    }
    
    
    /*******       TO Handle The Object And Field Permissions    ********/
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/09/2019
        @Discription:             To Check the access permissions for Opportunity.
        @Date Of Modification :   06/09/2019
    */
    public static Boolean isOpportunityAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Opportunity', ConstantsUtility.IsAccessible) && 
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'DMS_Enquiry_Name__c') &&
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'Dealership__c') &&
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'Current_Follow_Up_Type__c') &&
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'Booking_Number__c') &&
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'Invoice_Number__c') &&
           CheckObjectAndField.fieldCURDPermission('Opportunity', ConstantsUtility.IsAccessible, 'VIN__c') &&
           
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Parent_Group__c') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Dealer_Map_Code__c') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Dealer_Location__c')){
            return True;
        }else{
            return false;
        }
    }
    
}