/**
            Name        :        MobileUsage
            Date        :        19th May 2020
            Author      :        Ranu Bari
            Description :        To call web service for account and porterin mobile
**/
public class MobileUsage{

    public static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    
    public static void refreshMobileUsage(Set<Id> portMobs){
        //call for portering mobiles and get mobile usage list
        List<Mobile_Usage__c> mobUsages = new List<Mobile_Usage__c>();        
       
        if(portMobs.size() > 0)
            mobUsages = fetchMobileUsage(portMobs);
        
        system.debug('@@@@ mobUsages  ' + mobUsages );    
        if(mobUsages.size() > 0)
            Database.UpsertResult[] srList = Database.upsert(mobUsages, Mobile_Usage__c.Legacy_Id__c, false);                 
    }
    
    @future(callout=true)
    public static void getPorteringDetails(Set<Id> portMobs){           
        List<Mobile_Usage__c> mobTotalUsages = new List<Mobile_Usage__c>();
        mobTotalUsages = fetchMobileUsage(portMobs);
        if(mobTotalUsages.size() > 0)
            Database.UpsertResult[] srList = Database.upsert(mobTotalUsages, Mobile_Usage__c.Legacy_Id__c, false);
    }
    private static List<Mobile_Usage__c> fetchMobileUsage(Set<Id> portMobs){
        Http http;
        HttpRequest request;
        String requestBody;
        
        String FResponse = '';        
        List<Mobile_Usage__c> mobTotalUsages = new List<Mobile_Usage__c>();
        Id portMobRecId = Schema.SObjectType.Mobile_Usage__c.getRecordTypeInfosByDeveloperName().get('Portering_Mobile').getRecordTypeId();
        for(Porteringen_mobiel__c portMob : [SELECT Id, account__r.IRMA_MKB_Office__c, iRMA_id__c from Porteringen_mobiel__c where id IN : portMobs]){
                                   bool = true;
                                   requestBody='';
                                   mapOfFields = new Map<String,String>();
                                   requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
                                   requestBody += '<soapenv:Header/>';
                                   requestBody += '<soapenv:Body>';
                                   requestBody += '<con:grexxRequest>';
                                   requestBody += '<con:header>';
                                   requestBody += '<con:reference>'+portMob.Id+'</con:reference>';
                                   requestBody += '</con:header>';
                                   requestBody += '<con:requestData>';
                                   requestBody += '<con:GetMobileSubscriptionUsageRequest_V1>';                                   
                                   requestBody += '<con:OrderId>'+portMob.iRMA_id__c+'</con:OrderId>';
                                   requestBody += '</con:GetMobileSubscriptionUsageRequest_V1>';
                                   requestBody += '</con:requestData>';
                                   requestBody += '</con:grexxRequest>';
                                   requestBody += '</soapenv:Body>';
                                   requestBody += '</soapenv:Envelope>';
                                   
                                   http = new Http();   
                                   request = new HttpRequest();
                                   if(portMob.Account__r.IRMA_MKB_Office__c) {
                                        request.setEndPoint('callout:MKB_Grexx/mobileusage');
                                   }else {
                                        request.setEndPoint('callout:Grexx/mobileusage');
                                   } 
                                   request.setMethod('POST');
                                   request.setHeader('Content-Type', 'text/xml');    
                                   request.setBody(requestBody);
                                   String statusCode = '';
                                   
                                   if(!Test.isRunningTest()){
                                       try{
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
                                        FResponse += '<transactionID>1:5490:48615222</transactionID>';
                                        FResponse += '<reference>cdd</reference>';
                                        FResponse += '</header>';
                                        FResponse += '<status>';
                                        FResponse += '<code>0</code>';
                                        FResponse += '<message>Succes</message>';
                                        FResponse += '</status>';
                                        FResponse += '<responseData>';
                                        FResponse += '<GetMobileSubscriptionUsageResponse_V1>';
                                        FResponse += '<Status>';
                                        FResponse += '<Code>Success</Code>';
                                        FResponse += '<Messages/>';
                                        FResponse += '</Status>';
                                        FResponse += '<OrderId>6086178</OrderId>';
                                        FResponse += '<MobileSubscriptionUsage>';
                                        FResponse += '<CustomerId>271860</CustomerId>';
                                        FResponse += '<PhoneNumber>+31620729729</PhoneNumber>';
                                        FResponse += '<DataBundleValue>20000</DataBundleValue>';
                                        FResponse += '<DataCurrentValue>2044</DataCurrentValue>';
                                        FResponse += '<UomData>MB</UomData>';
                                        FResponse += '<VoiceBundleValue xsi:nil="true"/>';
                                        FResponse += '<VoiceCurrentValue xsi:nil="true"/>';
                                        FResponse += '<UomVoice xsi:nil="true"/>';
                                        FResponse += '<SmsBundleValue xsi:nil="true"/>';
                                        FResponse += '<SmsCurrentValue xsi:nil="true"/>';
                                        FResponse += '<UomSms xsi:nil="true"/>';
                                        FResponse += '<Amount xsi:nil="true"/>';
                                        FResponse += '<UomAmount xsi:nil="true"/>';
                                        FResponse += '</MobileSubscriptionUsage>';
                                        FResponse += '</GetMobileSubscriptionUsageResponse_V1>';
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
                                           
                                           System.debug('Map Of Fields '+ mapOfFields);
                                           if(!(MapOfFields.containsKey('Code') && MapOfFields.get('Code') == 'ValidationError')){
                                               Mobile_Usage__c mobUsage = new Mobile_Usage__c();
                                               mobUsage.recordtypeid = portMobRecId;
                                               mobUsage.Portering_mobiel__c = portMob.Id;
                                               mobUsage.Customer_Id__c = MapOfFields.get('CustomerId');
                                               mobUsage.Order_Id__c = MapOfFields.get('OrderId');
                                               mobUsage.Phone_Number__c = MapOfFields.get('PhoneNumber');
                                               mobUsage.Amount__c = MapOfFields.get('Amount') != null ? Decimal.valueOf(MapOfFields.get('Amount')) : null;
                                               mobUsage.Uom_Amount__c = MapOfFields.get('UomAmount');
                                               mobUsage.Data_Bundle_Value__c = MapOfFields.get('DataBundleValue') != null ? Decimal.valueOf(MapOfFields.get('DataBundleValue')) : null;
                                               mobUsage.Data_Current_Value__c = MapOfFields.get('DataCurrentValue') != null ? Decimal.valueOf(MapOfFields.get('DataCurrentValue')) : null;
                                               mobUsage.Uom_Data__c = MapOfFields.get('UomData');
                                               mobUsage.Voice_Bundle_Value__c = MapOfFields.get('VoiceBundleValue') != null ? Decimal.valueOf(MapOfFields.get('VoiceBundleValue')) : null;
                                               mobUsage.Voice_Current_Value__c = MapOfFields.get('VoiceCurrentValue') != null ? Decimal.valueOf(MapOfFields.get('VoiceCurrentValue')) : null;
                                               mobUsage.Uom_Voice__c = MapOfFields.get('UomVoice');
                                               mobUsage.Sms_Bundle_Value__c = MapOfFields.get('SmsBundleValue') != null ? Decimal.valueOf(MapOfFields.get('SmsBundleValue')) : null;
                                               mobUsage.Sms_Current_Value__c = MapOfFields.get('SmsCurrentValue') != null ? Decimal.valueOf(MapOfFields.get('SmsCurrentValue')) : null;
                                               mobUsage.Uom_Sms__c = MapOfFields.get('UomSms');
                                               
                                               mobUsage.Legacy_Id__c = portMob.id;
                                               //mobUsage.currencyIsoCode = ;
                                               mobTotalUsages.add(mobUsage);         
                                           }                                                                         
                                       }                                                                              
                                   }
                                   
                               }
                
        return mobTotalUsages;
            
            
        //    upsert mobTotalUsages Mobile_Usage__c.Legacy_Id__c;
        // Iterate through each returned result
        
        /*for (Database.UpsertResult sr : srList) {
            
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Upserted Mobile Usage. Record ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Mobile Usage fields that affected this error: ' + err.getFields());
                }
            }
            
        }*/
        
    }
    
    
    public static void parseXML(DOM.XMLNode node) {
        Set<String> textFields = new Set<String>{'Code','OrderId','PhoneNumber','CustomerId','ErrorMessage'};
        Set<String> OtherFields = new Set<String>{'Amount','UomAmount','DataBundleValue','DataCurrentValue','UomData',
                                                  'VoiceBundleValue','VoiceCurrentValue','UomVoice','SmsBundleValue','SmsCurrentValue',
                                                  'UomSms'};
        
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            //system.debug(node.getName()); 
            
            if(textFields.contains(node.getName())){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(OtherFields.contains(node.getName()) && node.getAttributeCount() == 0){
                mapOfFields.put(node.getName(), node.getText());
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