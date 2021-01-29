/*
    Descriton: Updating iBAN 
    Its one time project to update iRMA_id__c records. 
*/
global with sharing class CustomerModifyIBANScheduler implements Schedulable, Database.AllowsCallouts {
    
    global void execute(SchedulableContext SC) {
        CustomerModifyIBANScheduler.process();    
    }
    @future(Callout = true)
    global static void process(){
        system.debug('Run' + date.today());
        List<Account> accountList = database.query(Label.CustomerModifyIBANSchedulerQuery);
        List<Account> newAccountList = new List<Account>();
        Http http;
        HttpRequest request;
        String requestBody;
        String FResponse = '';
            for(Account accObj : accountList){
                //if(accObj.iRMA_id__c != '384763'){
                requestBody='';
                requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
                requestBody += '<soapenv:Header/>';
                requestBody += '<soapenv:Body>';
                requestBody += '<con:grexxRequest>';
                requestBody += '<con:header></con:header>';
                requestBody += '<con:requestData>';
                requestBody += '<con:ModifyCustomerRequest_V3>';
                requestBody += '<con:CustomerId>CID'+accObj.iRMA_id__c+'</con:CustomerId>';
                requestBody += '<con:Name>'+accObj.Name+'</con:Name>';
                requestBody += '<con:Street>'+(accObj.Straat__c != null ? accObj.Straat__c :'')+'</con:Street>';
                if(accObj.Huisnummer__c != null){
                    requestBody += '<con:HouseNr>'+accObj.Huisnummer__c+'</con:HouseNr>';    
                }
                requestBody += '<con:HouseNrExtension>'+(accObj.Huisnummer_toevoeging__c != null ? accObj.Huisnummer_toevoeging__c : '')+'</con:HouseNrExtension>';
                requestBody += '<con:ZipCode>'+(accObj.Postcode__c != null ? accObj.Postcode__c : '')+'</con:ZipCode>';
                requestBody += '<con:City>'+(accObj.ShippingCity != null ? accObj.ShippingCity : '')+'</con:City>';
                requestBody += '<con:CountryCode>NLD</con:CountryCode>';
                requestBody += '<con:Phone1>'+(accObj.Phone != null ? accObj.Phone : '')+'</con:Phone1>';
                requestBody += '<con:ExternalId>'+(accObj.ExternalId__c != null ? accObj.ExternalId__c : '')+'</con:ExternalId>';
                requestBody += '<con:Email>'+(accObj.E_mailadres_bedrijf__c != null ? accObj.E_mailadres_bedrijf__c : '')+'</con:Email>';
                requestBody += '<con:ChamberOfCommerceNr>'+(accObj.KvK_nummer__c != null ? accObj.KvK_nummer__c : '')+'</con:ChamberOfCommerceNr>';
                requestBody += '<con:LegalStatus>'+(accObj.Rechtsvorm__c != null ? accObj.Rechtsvorm__c : '')+'</con:LegalStatus>';
                requestBody += '<con:IBAN>NL19ABNA0593740904</con:IBAN>';
                requestBody += '</con:ModifyCustomerRequest_V3>';
                requestBody += '</con:requestData>';
                requestBody += '</con:grexxRequest>';
                requestBody += '</soapenv:Body>';
                requestBody += '</soapenv:Envelope>';
                
                http = new Http();   
                request = new HttpRequest();
                request.setEndPoint('callout:MKB_Grexx/customermodify');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'text/xml');    
                request.setBody(requestBody);
                system.debug('Request Body =>' + requestBody);
                String statusCode = '';
                try{
                    HttpResponse response = http.send(request);
                    system.debug('Response Body =>' + response.getBody());
                    statusCode = String.valueOf(response.getStatusCode()); 
                    if(response.getStatusCode() == 200){
                        FResponse = response.getBody();
                            if(FResponse.contains('<IsSuccess>true</IsSuccess>')){
                            accObj.Check_Temp_Status__c = true;
                        }else{
                            String responseMessage = FResponse.substringBetween('<message>','</message>');
                            accObj.Temp_Status_Msg__c = responseMessage;
                        }
                        newAccountList.add(accObj);
                    }
                }catch(Exception ex){
                    System.debug('Exception Found !!' + ex.getMessage());
                }
                //}
            }
        if(!newAccountList.isEmpty()){
            Update newAccountList;
        }
        Datetime sysTime = System.now().addHours(1);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'CustomerModify IBANScheduler_' + sysTime, chronExpression, new CustomerModifyIBANScheduler());
    }
}