/**
* @File Name          : GenerateOTPMockClass.cls
* @Description        : Mock class for generating fake API response for SFMC API.
* @Author             : Nishant Prajapati
*==============================================================================
* Ver             Author                   Modification
*==============================================================================
* 1.0             Nishant Prajapati           Initial Version
**/
@istest
public class GenerateOTPMockClass implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        List<SFMC_API_Detail__mdt> lsSFMCAPIDet = [select id,Endpoint__c,DeveloperName, account_id__c, client_id__c, client_secret__c, scope_requested__c from SFMC_API_Detail__mdt limit 10];
        SFMC_API_Detail__mdt sfmcAccessToken = new SFMC_API_Detail__mdt();
        SFMC_API_Detail__mdt sfmcSMSAPI = new SFMC_API_Detail__mdt();
        
        for (SFMC_API_Detail__mdt apiMC : lsSFMCAPIDet){
            if (apiMC.developername == 'SFMCAccessTokenRequest'){
                sfmcAccessToken = apiMC;
            }
            else if (apiMC.developername == 'SFMCSMSAPIForOTP'){
                sfmcSMSAPI = apiMC;
            }
        }
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(sfmcAccessToken <> null){
            res.setBody('{"grant_type": "client_credentials","client_id": "' + sfmcAccessToken.client_id__c +'","client_secret": "'+ sfmcAccessToken.client_secret__c + '","scope": "' + sfmcAccessToken.scope_requested__c + '","account_id": "' + sfmcAccessToken.account_id__c + '"}');
            res.setStatusCode(200);
        }
        /*if(sfmcSMSAPI.Endpoint__c){
            res.setBody('{"Subscribers": [{"MobileNumber": "919002344567","SubscriberKey": "TEST-SUB-001","Attributes":{"OTP":"123456"}}],"Subscribe":true,"Resubscribe":true,"keyword":"MARUTI","Override": false}');
            res.setStatusCode(202);
        }*/
        return res;
    }

}