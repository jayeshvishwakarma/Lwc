/**
            Name        :        PreQualificationCheck
            Date        :        29th July 2020
            Author      :        Ranu Bari
            Description :        To call web service for account and porterin mobile
**/
public class PreQualificationCheck{
    public PreQualificationCheck(){}
   /* public static List<Map<String,String>> mapOfFields = new List<Map<String,String>>();
    static Map<String,String> mapOfParentFields = new Map<String,String>();
    Static Boolean bool;
    private static Set<Id> infraInformstoDelete = new Set<Id>();
    //call from vf page for an account through "Refresh Mobile Usage" button.
        
    //call from scheduler
    @future(callout=true)
    public static void fetchPreQuaCheckFromBatch(Set<Id> accountIds){                   
        List<Infra_informatie__c> infraInformaties = new List<Infra_informatie__c>();
        infraInformaties = fetchPreQualificationCheck(accountIds);
        if(infraInformaties.size() > 0){
            delete [select id from Infra_informatie__c where account__C IN : infraInformstoDelete];
            Database.SaveResult[] srList = Database.insert(infraInformaties, false);
            
        }
    }

    //common method to call http request
    private static List<Infra_informatie__c> fetchPreQualificationCheck(Set<Id> accountIds){
        Http http;
        HttpRequest request;
        String requestBody;
        
             
        List<Infra_informatie__c> infraInformaties = new List<Infra_informatie__c>();
        
        for(Account account : [select id, ZipCode__c, Huisnummer__c, IRMA_MKB_Office__c, Huisnummer_toevoeging__c from Account where id IN : accountIds]){
                                   bool = true;
                                   requestBody='';
                                   String FResponse = '';   
                                   mapOfFields = new List<Map<String,String>>();
                                   mapOfParentFields = new Map<String,String>();
                                   requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
                                   requestBody += '<soapenv:Header/>';
                                   requestBody += '<soapenv:Body>';
                                   requestBody += '<con:grexxRequest>';
                                   requestBody += '<con:header>';
                                   requestBody += '<con:reference>'+account.Id+'</con:reference>';
                                   requestBody += '</con:header>';
                                   requestBody += '<con:requestData>';
                                   requestBody += '<con:PrequalificationRequest>';                                   
                                   requestBody += '<con:ZipCode>'+ (account.ZipCode__c != null ? account.ZipCode__c : '') +'</con:ZipCode>';
                                   requestBody += '<con:HouseNr>'+ (account.Huisnummer__c != null ? account.Huisnummer__c : '') +'</con:HouseNr>';
                                   requestBody += '<con:HouseNrExtension>'+ (account.Huisnummer_toevoeging__c != null ? account.Huisnummer_toevoeging__c : '') +'</con:HouseNrExtension>';
                                   requestBody += '<con:HasBroadband>true</con:HasBroadband>';
                                   requestBody += '<con:HasPhone>false</con:HasPhone>';
                                   requestBody += '<con:ProductTypeCode>FTTHSMB</con:ProductTypeCode>';
                                   requestBody += '</con:PrequalificationRequest>';
                                   requestBody += '</con:requestData>';
                                   requestBody += '</con:grexxRequest>';
                                   requestBody += '</soapenv:Body>';
                                   requestBody += '</soapenv:Envelope>';
                                   
                                   http = new Http();   
                                   request = new HttpRequest();
                                   if(account.IRMA_MKB_Office__c) {
                                        request.setEndPoint('callout:MKB_Grexx/prequalificationcheck');
                                   }else {
                                        request.setEndPoint('callout:Grexx/prequalificationcheck');
                                   } 
                                   request.setEndPoint('callout:Grexx/prequalificationcheck');
                                   request.setMethod('POST');
                                   request.setHeader('Content-Type', 'text/xml');    
                                   request.setBody(requestBody);
                                   String statusCode = '';
                                   
                                   if(!Test.isRunningTest()){ 
                                       try{
                                           system.debug('@@@ Request ' + requestBody);
                                           HttpResponse response = http.send(request);
                                           statusCode = String.valueOf(response.getStatusCode()); 
                                           if(response.getStatusCode() == 200){
                                               FResponse = response.getBody();
                                               system.debug('@@@ FResponse  ' + FResponse );
                                           }
                                       }catch(Exception ex){
                                           System.debug('Exception Found !!' + ex.getMessage());
                                       }
                                       
                                   }else{
                                        FResponse = '<?xml version="1.0" encoding="utf-8"?>';
                                        FResponse += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                                        FResponse += '<soap:Body>';
                                        FResponse += '<grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect">';
                                        FResponse += '<header>';
                                        FResponse += '<transactionID>1:5490:57860089</transactionID>';
                                        FResponse += '<reference></reference>';
                                        FResponse += '</header>';
                                        FResponse += '<status>';
                                        FResponse += '<code>0</code>';
                                        FResponse += '<message>Succes</message>';
                                        FResponse += '</status>';
                                        FResponse += '<responseData>';
                                        FResponse += '<PrequalificationResponse>';
                                        FResponse += '<Extension/>';
                                        FResponse += '<HouseNumber>53</HouseNumber>';
                                        FResponse += '<ZipCode>6601DN</ZipCode>';
                                        FResponse += '<IsraSpecs/>';
                                        FResponse += '<FtuType>FTU_GN01</FtuType>';
                                        FResponse += '<NlsType>6</NlsType>';
                                        FResponse += '<LineType>GoF</LineType>';
                                        FResponse += '<Remarks/>';
                                        FResponse += '<ErrorClass>NoError</ErrorClass>';
                                        FResponse += '<Products>';
                                        FResponse += '<AvailabilityProduct>';
                                        FResponse += '<ProductCode>039A01073B</ProductCode>';
                                        FResponse += '<Name>FTTH | 200Mb / 200Mb | KPN | Entry | Zakelijk | 12 Mnd</Name>';
                                        FResponse += '<Availability>Green</Availability>';
                                        FResponse += '<IsVectoring>false</IsVectoring>';
                                        FResponse += '</AvailabilityProduct>';
                                        FResponse += '</Products>';
                                        FResponse += '</PrequalificationResponse>';
                                        FResponse += '</responseData>';
                                        FResponse += '</grexxResponse>';
                                        FResponse += '</soap:Body>';
                                        FResponse += '</soap:Envelope>';
                                       System.debug('Test Response');
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
                                           
                                           System.debug('Map Of Fields '+ mapOfParentFields);
                                           if(mapOfParentFields.get('code') == '0'){
                                               
                                               
                                                   Infra_informatie__c infraMatie = new Infra_informatie__c();
                                                       
                                                   infraMatie.Account__c = account.Id;
                                                   infraMatie.FtuType__c = mapOfParentFields.get('FtuType');
                                                   infraMatie.LineType__c = mapOfParentFields.get('LineType');
                                                   infraMatie.NlsType__c = mapOfParentFields.get('NlsType');
                                                   infraMatie.Remarks__c = mapOfParentFields.get('Remarks'); 
                                                   infraInformaties.add(infraMatie);                                               
                                                   
                                               infraInformstoDelete.add(account.id);
                                           }                                                                                                                
                                       }                                                                              
                                   }
                                   
                               }
                        
        return infraInformaties;
    }    
    
    public static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName() == 'code' || node.getName() == 'FtuType' || node.getName() == 'LineType' || node.getName() == 'NlsType' || node.getName() == 'Remarks')
                mapOfParentFields.put(node.getName(), node.getText());          
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }*/
    
}