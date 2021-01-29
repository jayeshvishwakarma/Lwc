/**
            Name        :        MobileTotalUsage
            Date        :        19th May 2020
            Author      :        Ranu Bari
            Description :        To call web service for account and porterin mobile
**/
public class MobileTotalUsage{

    public static List<Map<String,String>> mapOfFields = new List<Map<String,String>>();
    static Map<String,String> mapOfParentFields = new Map<String,String>();
    Static Boolean bool;
    private static Set<Id> mobUsagetoDelete = new Set<Id>();
    //call from vf page for an account through "Refresh Mobile Usage" button.
    
    public static void refreshMobileUsage(Set<Id> accountIds){
        List<Mobile_Usage__c> mobTotalUsages = new List<Mobile_Usage__c>();
        //get mobile total usage using account ids
        mobTotalUsages = fetchMobileTotalUsage(accountIds);
                
        //upsert seperate mobile usage
        if(mobTotalUsages.size() > 0){
            delete [select id from Mobile_Usage__C where account__C IN : mobUsagetoDelete];
            Database.SaveResult[] srList = Database.insert(mobTotalUsages, false);
            
        }                    
    }
    
    //call from scheduler
    @future(callout=true)
    public static void fetchMobileUsageFromBatch(Set<Id> accountIds){                   
        List<Mobile_Usage__c> mobTotalUsages = new List<Mobile_Usage__c>();
        mobTotalUsages = fetchMobileTotalUsage(accountIds);
        if(mobTotalUsages.size() > 0){
            delete [select id from Mobile_Usage__C where account__C IN : mobUSagetoDelete];
            Database.SaveResult[] srList = Database.insert(mobTotalUsages, false);
            
        }
    }

    //common method to call http request
    private static List<Mobile_Usage__c> fetchMobileTotalUsage(Set<Id> accountIds){
        Http http;
        HttpRequest request;
        String requestBody;
        
        String FResponse = '';        
        List<Mobile_Usage__c> mobTotalUsages = new List<Mobile_Usage__c>();

        Id accountMobRecId = Schema.SObjectType.Mobile_Usage__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        for(Account account : [select id, IRMA_MKB_Office__c, iRMA_id__c from Account where id IN : accountIds]){
                                   bool = true;
                                   requestBody='';
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
                                   requestBody += '<con:GetMobileSubscriptionTotalUsageRequest_V1>';                                   
                                   requestBody += '<con:CustomerId>'+account.iRMA_id__c+'</con:CustomerId>';
                                   requestBody += '</con:GetMobileSubscriptionTotalUsageRequest_V1>';
                                   requestBody += '</con:requestData>';
                                   requestBody += '</con:grexxRequest>';
                                   requestBody += '</soapenv:Body>';
                                   requestBody += '</soapenv:Envelope>';
                                   
                                   http = new Http();   
                                   request = new HttpRequest();
                                   if(account.IRMA_MKB_Office__c) {
                                        request.setEndPoint('callout:MKB_Grexx/mobiletotalusage');
                                   }else {
                                        request.setEndPoint('callout:Grexx/mobiletotalusage');
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
                                        FResponse += '<transactionID>1:5490:48668751</transactionID>';
                                        FResponse += '<reference></reference>';
                                        FResponse += '</header>';
                                        FResponse += '<status>';
                                        FResponse += '<code>0</code>';
                                        FResponse += '<message>Succes</message>';
                                        FResponse += '</status>';
                                        FResponse += '<responseData>';
                                        FResponse += '<GetMobileSubscriptionTotalUsageResponse_V1>';
                                        FResponse += '<Status>';
                                        FResponse += '<Code>Success</Code>';
                                        FResponse += '<Messages/>';
                                        FResponse += '</Status>';
                                        FResponse += '<CustomerId>327707</CustomerId>';
                                        FResponse += '<MobileBundleInfoUsage>';
                                        FResponse += '<MobileBundleInfoUsage_V1>';
                                        FResponse += '<Amount>100</Amount>';
                                        FResponse += '<UomAmount>Euro</UomAmount>';
                                        FResponse += '<DataBundleValue xsi:nil="true"/>';
                                        FResponse += '<DataCurrentValue xsi:nil="true"/>';
                                        FResponse += '<UomData xsi:nil="true"/>';
                                        FResponse += '<VoiceBundleValue xsi:nil="true"/>';
                                        FResponse += '<VoiceCurrentValue xsi:nil="true"/>';
                                        FResponse += '<UomVoice xsi:nil="true"/>';
                                        FResponse += '<ProductName/>';
                                        FResponse += '</MobileBundleInfoUsage_V1>';
                                        FResponse += '<MobileBundleInfoUsage_V1>';
                                        FResponse += '<Amount xsi:nil="true"/>';
                                        FResponse += '<UomAmount xsi:nil="true"/>';
                                        FResponse += '<DataBundleValue>20000</DataBundleValue>';
                                        FResponse += '<DataCurrentValue>32</DataCurrentValue>';
                                        FResponse += '<UomData>MB</UomData>';
                                        FResponse += '<VoiceBundleValue xsi:nil="true"/>';
                                        FResponse += '<VoiceCurrentValue xsi:nil="true"/>';
                                        FResponse += '<UomVoice xsi:nil="true"/>';
                                        FResponse += '<ProductName>Zakelijk Mobiel Onbeperkt 2016</ProductName>';
                                        FResponse += '</MobileBundleInfoUsage_V1>';
                                        FResponse += '</MobileBundleInfoUsage>';
                                        FResponse += '</GetMobileSubscriptionTotalUsageResponse_V1>';
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
                                           if(!(mapOfParentFields.containsKey('Code') && mapOfParentFields.get('Code') == 'ValidationError')){
                                               Decimal amount = null;
                                               String uomAmount = '';
                                               for(Map<String, String> child : MapOfFields){
                                                   if(child.get('Amount') != null){
                                                       amount = Decimal.valueOf(child.get('Amount'));
                                                       uomAmount = child.get('UomAmount');
                                                   }else{
                                                       Mobile_Usage__c mobUsage = new Mobile_Usage__c();
                                                       mobUsage.recordtypeid = accountMobRecId;
                                                       mobUsage.Account__c = account.Id;
                                                       mobUsage.Customer_Id__c = mapOfParentFields.get('CustomerId');
                                                       mobUsage.Amount__c = amount;
                                                       mobUsage.Uom_Amount__c = uomAmount;
                                                       mobUsage.Data_Bundle_Value__c = child.get('DataBundleValue') != null ? Decimal.valueOf(child.get('DataBundleValue')) : null;
                                                       mobUsage.Data_Current_Value__c = child.get('DataCurrentValue') != null ? Decimal.valueOf(child.get('DataCurrentValue')) : null;
                                                       mobUsage.Uom_Data__c = child.get('UomData');
                                                       mobUsage.Voice_Bundle_Value__c = child.get('VoiceBundleValue') != null ? Decimal.valueOf(child.get('VoiceBundleValue')) : null;
                                                       mobUsage.Voice_Current_Value__c = child.get('VoiceCurrentValue') != null ? Decimal.valueOf(child.get('VoiceCurrentValue')) : null;
                                                       mobUsage.Uom_Voice__c = child.get('UomVoice');
                                                       mobUsage.Product_Name__c = child.get('ProductName');
                                                       //mobUsage.Legacy_Id__c = account.id;
                                                       mobTotalUsages.add(mobUsage);   
                                                   }                                                   
                                               }    
                                               mobUsagetoDelete.add(account.id);
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
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            //system.debug(node.getName()); 
            
            if(node.getName() == 'Code'){
               mapOfParentFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'CustomerId'){
               mapOfParentFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'MobileBundleInfoUsage'){
                for(Dom.XmlNode connection_node : node.getChildElements()){
                    system.debug('@@@@ childs ' +     connection_node.getName());   
                    Map<String, String> record = new Map<String, String>();
                    //child records in a map
                    for(Dom.XmlNode rnode : connection_node.getChildElements()){
                        if(rnode.getName() == 'Amount' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'UomAmount' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'DataBundleValue' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'DataCurrentValue' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'UomData' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'VoiceBundleValue' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'VoiceCurrentValue' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'UomVoice' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                        if(rnode.getName() == 'ProductName' && rnode.getAttributeCount() == 0){
                            record.put(rnode.getName(), rnode.getText());
                        }
                    }    
                    mapOfFields.add(record);                 
                }
            }                        
            
            if(node.getName() == 'ErrorMessage'){
                mapOfParentFields.put(node.getName(), node.getText());
            }            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }
    
}