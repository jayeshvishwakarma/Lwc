/*
    Name    : PnlPaymentHandler
    Date    : 07 Feb, 2018
    Author  :
    Description : This class is use to send the transaction request to PNL gatway and helps to the payment transactions.

*/
Public class PnlPaymentHandler{
    
    Public static String userIPAddress = '';
    
    // this is used to handle extra parameters to api if api called from apex trigger code
    Public static Boolean isTrigger = false;
    Public static Boolean isSalesTrigger = false;
    // This method use for get the login user ip address, Must be call this method and assign value into userIPAddress before if it is used in trigger or batch code. 
    public static string getLoginUserIPAddress(){
       list<LoginHistory> userHistoryList = [SELECT SourceIp from LoginHistory where UserId =:userinfo.getuserid() order by LoginTime desc limit 1];
       if(userHistoryList!=null && userHistoryList.size()>0){
           return userHistoryList[0].SourceIp;
       }
       return '';
    }
    // This method use for the Transaction request and return transaction result.
    Public static TransactionModal doTransactionRequest(decimal amount, string descr,
                                                        string ConsumerAddress, 
                                                        string ConsumerHouseNumber, 
                                                        string ConsumerCity, 
                                                        string ConsumerCountry){
        // get values from custom settings
        PaymentTransactionSetting__c setting = PaymentTransactionSetting__c.getValues('config')!=null ? PaymentTransactionSetting__c.getValues('config') : new PaymentTransactionSetting__c();
        //Map to hold current URL header parameters
        String ipAddress =''; 
        string finishURL = setting.Redirect_URL__c;// 'https://www.pay.nl/demo_ppt/finish_url';    
        string endURL = setting.End_URL__c;//'https://rest-api.pay.nl/v7/Transaction/start/json';
        string token = setting.Token__c;//'6eb4bb2f8b67d08a7cf9b3e9cdae31d62def1315';
        string serviceId= setting.Service_Id__c;//'SL-5516-2570';
        string userName = setting.Merchant_User_Name__c;// 'jvanvoorst@mobilemiles.nl';
        string password = setting.Password__c ;// '5Xn*B!5U$dt3Fm6';
        
        if(string.isNotBlank(userIPAddress)){
            ipAddress  = userIPAddress;  
        }else{
            Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();   
            //Proceed further only and only if map of header parameter have not null value with it
            if(mapHeaders != null){
                ipAddress = mapHeaders.get('True-Client-IP');
                system.debug('-------Client IP------'+ipAddress);
                if(ipAddress == null)
                    ipAddress = mapHeaders.get('X-Salesforce-SIP');
                system.debug('-------Salesforce IP------'+ipAddress); 
            }
        }
            
        if(string.isBlank(ipAddress)){
            ipAddress = '';    
        }
        
        string endPointURL = endURL;
        endPointURL+='?token='+EncodingUtil.URLENCODE(token,'UTF-8')+'&serviceId='+EncodingUtil.URLENCODE(serviceId,'UTF-8')+'&amount='+integer.valueOf(amount);
        endPointURL+='&description='+EncodingUtil.URLENCODE(descr,'UTF-8');
        endPointURL+='&transaction[description]='+EncodingUtil.URLENCODE(descr,'UTF-8');
        endPointURL+='&ipAddress='+EncodingUtil.URLENCODE(ipAddress,'UTF-8');
        endPointURL+='&ConsumerAddress='+EncodingUtil.URLENCODE(ConsumerAddress,'UTF-8');
        endPointURL+='&ConsumerHouseNumber='+EncodingUtil.URLENCODE(ConsumerHouseNumber,'UTF-8');
        endPointURL+='&ConsumerCity='+EncodingUtil.URLENCODE(ConsumerCity,'UTF-8');
        endPointURL+='&ConsumerCountry='+EncodingUtil.URLENCODE(ConsumerCountry,'UTF-8');
        if(isTrigger){
            datetime todayDt = System.now().addDays(21);
            String expireDt = todayDt.format('dd-MM-yyyy%20HH:mm:ss','GMT');
            
            //endPointURL+='&transaction[expireDate]=31-12-2020%2022:33:44';
            endPointURL+='&transaction[expireDate]='+expireDt;
            String extraname = isSalesTrigger ? 'Factuur' : 'Order';
            endPointURL+='&extra1Name='+EncodingUtil.URLENCODE(extraname,'UTF-8'); 
            endPointURL+='&extra2Value='+EncodingUtil.URLENCODE(descr,'UTF-8');  
        }else{
            endPointURL+='&paymentOptionId=10&paymentProfileId=4&paymentProfileName=iDEAL';
        }
        endPointURL+='&finishUrl='+EncodingUtil.URLENCODE(finishURL,'UTF-8');
        
        //endPointURL = EncodingUtil.URLENCODE(endPointURL,'UTF-8');
        system.debug('endpoint url'+endPointURL);        
        string jsonStrTemplateResult='';
        string strAccessToken=''; 
    
        HttpRequest reqObj = new HttpRequest();
        reqObj.setEndpoint(endPointURL);           
        reqObj.setMethod('POST');
        reqObj.setHeader('Content-Type','application/x-www-form-urlencoded');
        reqObj.setHeader('Accept', 'application/json');
        //reqObj.setHeader('authorization','Basic anZhbnZvb3JzdEBtb2JpbGVtaWxlcy5ubDo');
        reqObj.setHeader('username', userName);
        reqObj.setHeader('password', password);
        http htpObj=new http();
        string jsonString='';
        HttpResponse httpResponseRecord = new HttpResponse();
        if(!Test.isRunningTest()){
            httpResponseRecord = htpObj.send(reqObj);
            jsonString= httpResponseRecord.getBody();
            //system.debug('response'+jsonString);
            //system.debug('response code'+httpResponseRecord.getStatusCode());
            
        }else{
           jsonString = '{"request":{"result":"1","errorId":"","errorMessage":""},"endUser":{"blacklist":"0"},"transaction":{"transactionId":"927042439Xe0522b","paymentURL":"https://safe.pay.nl/payment/init/927042439Xe0522b/03ee710d3951883e0c322e99c24ceb60b8c57dac/1663/NL","popupAllowed":"0","paymentReference":"1000 0009 2704 2439"}}';     
        }
        
        if(Test.isRunningTest() || httpResponseRecord.getStatusCode()==200){
                return parseTransactionRequestResult(jsonString);
        }
        
        return new TransactionModal();
        
    }

    public static TransactionModal parseTransactionRequestResult(string jsonString){
        //*** checking to success response
        //jsonString = '{"request": {"result":"1","errorId":"","errorMessage":""}, "endUser":{"blacklist":"0"}, "transaction": {"transactionId":"922160230X4a1dc6", "paymentURL":"https:", "popupAllowed":"0", "paymentReference":"5000 0009 2216 0230"} }';
        //*** checking to error response
        //jsonString = '{"request":{"result":"0","errorId":"PAY-405","errorMessage":"Parameter paymentProfileId or amount is invalid: Could not find a matching product."},"endUser":{"blacklist":"0"},"transaction":{"paymentReference":""}}';
        TransactionModal tmObj = new TransactionModal();
        if(string.isNotBlank(jsonString)){
            jsonString = jsonString.replaceAll('\'','');
            jsonString  = jsonString.replaceAll('\'', '\\\\\'');
            jsonString = jsonString.replaceAll('transaction"','transaction_x"');
            tmObj = (TransactionModal)System.JSON.deserialize(jsonString,TransactionModal.class);
        }
        return tmObj;
    }  
    
    Public class TransactionModal{
        public TransactionRequestModal request;
        public TransactionDetailModal transaction_x;
    }
    
    Public class TransactionRequestModal{
        public string result;
        public string errorId;
        public string errorMessage;
    }
    
    Public class TransactionDetailModal{
        public string paymentURL;
        public string popupAllowed;
        public string paymentReference;
        public string transactionId;
    }
}