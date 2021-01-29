/**
 * @File Name          : SFMCRealTimeAPIIntegration.cls
 * @Description        : APEX Callout to send OTP Message on customer mobile phone.
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/2/2019, 11:14:03 PM
 * @Modification Log   : 
 * Ver       Date         Author                 Modification
 * ------------------------------------------------------------------------------------------------------------
 * 1.0       11/18/2019   Rajesh Ramachandran    Temporary class for POC. Needs to be updated further in future.
 * 1.1		 11/22/2019	  Nishant Prajapati	     Integrate this class into the Generate OTP code passing required inputs from the enquiry
 * 1.2		 12/02/2019	  Subhojit Chakraborty	 Integrate this class into the Generate OTP code passing required inputs for customer visibility also
**/
public with sharing class SFMCRealTimeAPIIntegration {

    public static void otpCall(String otp, String mobile, Id contactid, String channel,map<String,Object> mapParam){
        try {
            boolean bIsCustomTextBody=false;
            if(mapParam!=null && mapParam.size()>0 && mapParam.containsKey('CUSOTOMER_VISIBILITY_OTP'))
              bIsCustomTextBody=true;
            List<SFMC_API_Detail__mdt> lsSFMCAPIDet = [select id,Endpoint__c,DeveloperName, account_id__c, client_id__c, client_secret__c, scope_requested__c, Keyword__c from SFMC_API_Detail__mdt limit 10];
            SFMC_API_Detail__mdt sfmcAccessToken = new SFMC_API_Detail__mdt();
            SFMC_API_Detail__mdt sfmcSMSAPI = new SFMC_API_Detail__mdt();
            String keyword = '';
            if (lsSFMCAPIDet == null || lsSFMCAPIDet.size() == 0){return;}
            for (SFMC_API_Detail__mdt apiMC : lsSFMCAPIDet){
                if (apiMC.developername == 'SFMCAccessTokenRequest'){
                    sfmcAccessToken = apiMC;
                }
                else if (apiMC.developername == (channel + 'SFMCSMSAPIForOTP')){
                    sfmcSMSAPI = apiMC;
                }
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(sfmcAccessToken.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody('{"grant_type": "client_credentials","client_id": "' + sfmcAccessToken.client_id__c +'","client_secret": "'+ sfmcAccessToken.client_secret__c + '","scope": "' + sfmcAccessToken.scope_requested__c + '","account_id": "' + sfmcAccessToken.account_id__c + '"}');
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                system.debug(response.getBody());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String token = (String) results.get('access_token');
                System.debug('Received the following token:' + token);
                //Added by subhojit- for customer visibility changes
                String Subscriber_Key= String.isNotBlank(String.valueOf(contactid)) ? String.valueOf(contactid) : ConstantsUtility.SUBSCRIBER_KEY;
                String sReqBody='{"Subscribers": [{"MobileNumber": "' + mobile + '","SubscriberKey": "' + Subscriber_Key + '" ,"Attributes":{"OTP":"' + otp + '"}}],"Subscribe":true,"Resubscribe":true,"keyword":"' + sfmcSMSAPI.Keyword__c+'",' ;
                if(!bIsCustomTextBody)
                    sReqBody+= '"Override": false';
                else{
                    String sMessageBody=String.format(System.label.CUSTOMER_VISIBILITY_OTP_TEXT,new List<Object>{otp});
                     sReqBody+= '"Override": true,"messageText": "'+sMessageBody+'"';
                }
                sreqBody+='}';
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                request1.setEndpoint(sfmcSMSAPI.endpoint__c);
                request1.setMethod('POST');
                request1.setHeader('Content-Type', 'application/json');
                request1.setHeader('Authorization', 'Bearer ' + token);
                
                
                request1.setBody(sReqBody);
                system.debug(sReqBody);
                HttpResponse response1 = http1.send(request1);
                if (response1.getStatusCode() == 202){
                    system.debug(response1.getBody());
                }
            }
        }
        catch (Exception ex){
            ExceptionHandler.LogError('SFMCRealTimeAPIIntegration', ex.getMessage(),'SFMC OTP Call',contactid, null);
        }
    }
}