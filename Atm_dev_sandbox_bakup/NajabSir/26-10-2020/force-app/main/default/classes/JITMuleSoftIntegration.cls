/**
* @Author-: Sunit Kumar Chand
* @Company-: Techmatrix Consulting
* @Description-: Contains method for APEX Callout to fetch details from Mulesoft APIs for JIT.
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 18/02/2020, 12:36:33 PM
* @Modification Log   : Intial Version
* =============================================================
*  Version   Date            Author      Modification
* =============================================================
*  1.0       11 Jan 2020    Sunit     Intial Version
   1.0       18 Feb 2020    Sunit     Update error handling part
* 
**/
public without sharing class JITMuleSoftIntegration {
     public static String requestLabel;
    
    /**
        Author: Sunit Chand
        Company: Techmatrix
        Description: This method is used for JIT API calls, used for all JIT call for three parameters
        Inputs: 
        Returns: Continutation Object
        History:
        ====================================================
        1.0  16 Jan 20120  Sunit Chand  Initial Version
    **/
    @AuraEnabled(continuation=true)
    public static Object genericJITCall(String jitName, String jsonBody,String urlParam)
    {
        BasicReturn br= (BasicReturn)JITMuleSoftIntegration.genericJITCall(jitName, jsonBody, urlParam,'');
        return br;
    }
    /**
        Author: Sunit Chand
        Company: Techmatrix
        Description: This method is used for JIT API calls, used for all JIT call for four parameters
        Inputs: 
        Returns: Continutation Object
        History:
        ====================================================
        1.0  16 Jan 20120  Sunit Chand  Initial Version
    **/
    @AuraEnabled(cacheable=true continuation=true)
    public static Object genericJITCall(String jitName, String jsonBody,String urlParam,String urlPart)
    {
        BasicReturn br=new BasicReturn();
        Continuation con = new Continuation(40);
        try{
            MuleSoft_API_Details__mdt[] apiDetail= [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c,
                                                       x_channel_id__c, x_channel_token__c,Method_Type__c,Header_Parameter__c,
                                                       x_transaction_id__c,Authorization__c,Parameters__c,Content_Type__c,
                                                       client_id__c,client_secret__c 
                                                    FROM MuleSoft_API_Details__mdt WHERE DeveloperName =: jitName];
            
            system.debug('jitName___'+jitName);
            system.debug('jsonBody----->'+jsonBody);
            System.debug(apiDetail);
            if(apiDetail.size()>0){
                Map<String, Object> mulesoftAPIDetailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(apiDetail[0]));
                //Create API request
                HttpRequest req = new HttpRequest();
                //Set Request Method Type
                req.setMethod(apiDetail[0].Method_Type__c);
                //Set the Request body for API request type as POST or PUT
                if(apiDetail[0].Method_Type__c==ConstantsUtility.POST_REQUEST || apiDetail[0].Method_Type__c==ConstantsUtility.PUT_REQUEST
                  || apiDetail[0].Method_Type__c=='DELETE'){
                    //System.debug('jsonBody');
                    System.debug(jsonBody);
                    req.setBody(jsonBody);
                }
                String endPoint=apiDetail[0].Endpoint__c;
                if(apiDetail[0].Parameters__c!='' && apiDetail[0].Parameters__c!= null){
                    String[] getParamArray=apiDetail[0].Parameters__c.split(';');
                    Map<String, Object> urlParams = (Map<String, Object>)JSON.deserializeUntyped(urlParam);
                    System.debug('urlParams------->'+urlParams);
                    System.debug('getParamArray------->'+getParamArray);
                    for(Integer i=0;i<getParamArray.size();i++)
                    { 
                        if(i==0 && urlParams.containsKey(getParamArray[i]) && String.isNotBlank((String)urlParams.get(getParamArray[i])) ){
                             endPoint=endPoint+getParamArray[i]+'='+(String)urlParams.get(getParamArray[i]);
                        }
                        else if(urlParams.containsKey(getParamArray[i]) && String.isNotBlank((String)urlParams.get(getParamArray[i])))
                        {
                            endPoint=endPoint+'&'+getParamArray[i]+'='+(String)urlParams.get(getParamArray[i]);
                        }
                        
                    }
                }
                else if(urlPart!=null)
                {
                    endPoint=endPoint+urlPart;
                }
                System.debug('endPoint--->'+endPoint);
                req.setEndpoint(endPoint.replaceAll(' ', '%20'));
                //Set Header values from metadata
                String[] headerArray=apiDetail[0].Header_Parameter__c.split(';');
                for(String header:headerArray)
                {
                    String label=header;
                    header+='__c';
                    System.debug('label Check:- '+label);
                    System.debug('Header Check:- '+header.replaceFirst('-', '_'));
                    System.debug(mulesoftAPIDetailMap.get(header.replaceFirst('-', '_')));
                    System.debug(mulesoftAPIDetailMap.get('client_id__c'));
                    req.setHeader(label,(String)mulesoftAPIDetailMap.get(header.replaceFirst('-', '_')));
                }
                req.setHeader('Accept','application/json');
                System.debug('Before Continuation');
                
                // Set callback method
                con.continuationMethod='processResponse';
                
                con.addHttpRequest(req);
                System.debug('After Continuation');
            }
        }
        catch(Exception ex)
        {
            system.debug('errorResponse@@@@'+ex.getStackTraceString());
			System.enqueueJob(new AsyncExceptionHandler('JITName: '+jitName,'',ex.getMessage(), '',UserInfo.getUserId(), 'JITMuleSoftIntegration'));
            ex.getStackTraceString();
            br.code=0;
            br.message=ex.getMessage();
            br.status='Error';
            
        }
        system.debug('response@@@@'+br);
        system.debug('con------------->'+con);
        return con;

    }
    @AuraEnabled
    public static Object processResponse(List<String> labels) {  
      System.debug('Inside processResponse');
      BasicReturn br=new BasicReturn();
      // Get the response by using the unique label
      HttpResponse response = Continuation.getResponse(labels[0]);
        System.debug(response.getBody());
        
        
        if(response.getStatusCode()==200 || response.getStatusCode()==201){
                   br.code=response.getStatusCode();
                          br.message='Success';
                          br.status='Success';
                          br.data=response.getBody();      
          }
                else{
                    	System.debug(response.getBody());
                    	ErrorBody errbd=(ErrorBody)JSON.deserialize(response.getBody(),ErrorBody.class);
                        System.enqueueJob(new AsyncExceptionHandler('JITName: '+'JITName','',response.getStatusCode()+' : '+response.getBody(), '',UserInfo.getUserId(), 'JITMuleSoftIntegration'));
                        br.code=response.getStatusCode();
                        br.message=errbd.errorMessage;
                        br.status='Error';        
                    }
     
      return br;
    }
    /**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: This class is used for deserialization of error getting from ESB(Mulesoft)
   History:
   ================
   1.0     18 Feb 2019      Sunit     Initial Version
*/
    public class ErrorBody{
       public String correlationId;
       public String errorCode;
       public String errorMessage;
       public String timeStamp;
    }
    
}