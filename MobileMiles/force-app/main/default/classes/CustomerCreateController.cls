/*
Class Name  :     CustomerCreateController
Date        :     12th Feburary 2019    
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/
public class CustomerCreateController{
    Static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    Static Quote quotesRecord;
    public Static String errMsg{get;set;}
    
    public CustomerCreateController(ApexPages.StandardController stdController) {
        quotesRecord = (Quote)stdController.getRecord();
        errMsg = '';
        system.debug('quotesRecord.id-'+quotesRecord.id);
    }
    
    // @future(callout=true)
    public static PageReference getAccountDetails()
    {   
        List<Account> listofAccount = new List<Account>();
        Http http;
        HttpRequest request;
        String requestBody;
        
        String FResponse = '';    
        /*for(Quote quote : [SELECT account.Id, account.Name, account.BillingStreet, account.Huisnummer__c, 
                                     account.BillingCity, account.BillingPostalCode, account.BillingCountry, account.CKR_nummer__c, 
                                     account.KvK_nummer__c, account.Phone, account.E_mailadres_bedrijf__c, account.Rechtsvorm__c, account.iRMA_id__c
                                     FROM Quote WHERE Id =: quotesRecord.id]){*/
        for(Quote quote : [SELECT account.Id, account.name, Bedrijfsnaam__c, Straat__c, Huisnummer__c, 
                                     Plaats__c, Postcode__c, Landcode__c, Telefoonnummer_nummeriek__c, 
                                     account.KvK_nummer__c, E_mailadres__c, ExternalId__c, IBAN_MM__c, 
                                     Rechtsvorm__c, account.iRMA_id__c, Huisnummer_toevoeging__c 
                                     FROM Quote WHERE Id =: quotesRecord.id]){  
               bool = true;
               requestBody='';
               mapOfFields = new Map<String,String>();
               
               if(quote.account.iRMA_id__c != null ){
                   errMsg = 'Customer is already created: ' + quote.account.iRMA_id__c;
               }else if(quote.account.Id != null && quote.Bedrijfsnaam__c != null && quote.Straat__c != null && quote.Huisnummer__c != null && quote.Plaats__c != null && quote.Postcode__c != null && quote.ExternalId__c != null && quote.account.KvK_nummer__c != null && quote.E_mailadres__c != null && quote.Telefoonnummer_nummeriek__c != null && quote.Rechtsvorm__c != null){
                   
                   requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
                   requestBody += '<soapenv:Header/>';
                   requestBody += '<soapenv:Body>';
                   requestBody += '<con:grexxRequest>';
                   requestBody += '<con:header>';
                   requestBody += '<con:reference>'+quote.account.Id+'</con:reference>';  
                   requestBody += '</con:header>';
                   requestBody += '<con:requestData>';
                   requestBody += '<con:NewCustomerRequest_V3>';  
                   requestBody += '<con:Name>'+quote.Bedrijfsnaam__c+'</con:Name>';
                   requestBody += '<con:Street>'+quote.Straat__c+'</con:Street>';
                   requestBody += '<con:HouseNr>'+quote.Huisnummer__c+'</con:HouseNr>';
                   requestBody += '<con:ZipCode>'+quote.Postcode__c+'</con:ZipCode>';
                   requestBody += '<con:City>'+quote.Plaats__c+'</con:City>';
                   requestBody += '<con:CountryCode>'+'NLD'+'</con:CountryCode>';
                   requestBody += '<con:Phone1>'+quote.Telefoonnummer_nummeriek__c+'</con:Phone1>';
                   requestBody += '<con:Email>'+quote.E_mailadres__c+'</con:Email>';
                   requestBody += '<con:LegalStatus>'+quote.Rechtsvorm__c+'</con:LegalStatus>';
                   requestBody += '<con:ExternalId>'+quote.ExternalId__c+'</con:ExternalId>';
                   requestBody += '<con:IBAN>'+quote.IBAN_MM__c+'</con:IBAN>';
                   requestBody += '<con:ChamberOfCommerceNr>'+quote.account.KvK_nummer__c+'</con:ChamberOfCommerceNr>';
                   requestBody += '</con:NewCustomerRequest_V3>';
                   requestBody += '</con:requestData>';
                   requestBody += '</con:grexxRequest>';
                   requestBody += '</soapenv:Body>';
                   requestBody += '</soapenv:Envelope>';
                   
                   system.debug('requestBody -'+requestBody );
                   
                   http = new Http();   
                   request = new HttpRequest();
                   request.setEndPoint('callout:Grexx/customercreate');
                   request.setMethod('POST');
                   request.setHeader('Content-Type', 'text/xml');    
                   request.setBody(requestBody);
                   String statusCode = '';
                   
                   if(!Test.isRunningTest()){
                       try{
                           HttpResponse response = http.send(request);
                           system.debug('response.getStatus() -- ' + response.getStatus());
                           if(response.getStatusCode() == 200){
                               FResponse = response.getBody();
                               system.debug('fresponse-'+FResponse);
                           }
                         }catch(Exception ex){
                             System.debug('Exception Found !!' + ex.getMessage());
                             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                             ApexPages.addMessage(myMsg);
                             return null;
                         }
                     } else {
                         FResponse = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:6306:1125755</transactionID><reference>0Q00E000000PXJV</reference></header><status><code>0</code><message>Succes</message></status><responseData><QueueResult><IsSuccess>true</IsSuccess><ErrorCode>0</ErrorCode></QueueResult></responseData></grexxResponse></soap:Body></soap:Envelope>';
                     }
                     
                     if(String.isNotBlank(FResponse)){
                           Dom.Document doc = new Dom.Document();
                           try{
                               doc.load(FResponse);
                           }catch(Exception ee){
                               system.debug(ee.getMessage());
                           }
                          if(doc.getRootElement()!=NULL){
                               Dom.XmlNode root = doc.getRootElement();
                               parseXML(root);
                               System.debug('Map Of Fields '+ mapOfFields);
                               
                               for(String key : MapOfFields.keySet()){
                                   if(key == 'message'){
                                       if(mapOfFields.get(key) == 'Succes'){
                                           return new PageReference('/'+quotesRecord.id);
                                        } else {
                                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,mapOfFields.get(key));
                                            ApexPages.addMessage(myMsg);
                                            return null;
                                        }
                                   } //end if(key)  
                               }//end for(mapOfFields)  
                           }
                       }//endif(getRootElement)
               } else {
                  errMsg += 'Required Fields are missing-\n';
                  errMsg += (quote.account.Id != null)?'':'Account ID,'+'\n';
                  errMsg += (quote.Bedrijfsnaam__c != null)?'':'Name,\n';
                  errMsg += (quote.Straat__c != null)?'':'Street,\n';
                  errMsg += (quote.Huisnummer__c != null)?'':'House Number,\n';
                  errMsg += (quote.Postcode__c != null)?'':'Postal Code,\n';
                  errMsg += (quote.Plaats__c != null)?'':'City,\n';
                  errMsg += (quote.Landcode__c != null)?'':'Country,\n';
                  errMsg += (quote.Telefoonnummer_nummeriek__c != null)?'':'Phone,\n';
                  errMsg += (quote.E_mailadres__c != null)?'':'Email,\n';
                  errMsg += (quote.Rechtsvorm__c != null)?'':'Legal Status,\n';
                  errMsg += (quote.ExternalId__c != null)?'':'External Id,\n';
                  errMsg += (quote.IBAN_MM__c != null)?'':'IBAN,\n';
                  errMsg += (quote.account.KvK_nummer__c != null)?'':'ChamberOfCommerceNr\n';
                  
               }//end if (validation)
        }//end for(Quote query)
        
        system.debug('err msg-'+errMsg);
        if(errMsg != ''){
            errMsg = errMsg.substringBeforeLast(',');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
            ApexPages.addMessage(myMsg);
            return null;
        } else {
            return new PageReference('/'+quotesRecord.id);
        }
    }
    
     private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug(node.getName()); 
            if(node.getName() == 'message'){
                system.debug(node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                bool = false;
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }
}