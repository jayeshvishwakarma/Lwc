/*
Class Name  :     modifymobilesettings
Date        :     20th May 2019
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/
public class ModifyMobileSettings{
    Static Porteringen_mobiel__c pmRecord;
    public Static String errMsg{get;set;}
    Static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;        
    
    //to call ModifyMobileSettings API from VFpage made on 27 june 2019 by shikha
    public ModifyMobileSettings(ApexPages.StandardController stdController) {
        pmRecord = (Porteringen_mobiel__c)stdController.getRecord();
        errMsg = '';
    }    
        
    public static PageReference callModifyMobileSettingAPI(){   
        Set<Id> pmIdSet = new Set<Id>{pmRecord.id};
        getPorteringMobile(pmIdSet);
        if(errMsg != ''){
            errMsg = errMsg.substringBeforeLast(',');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
            ApexPages.addMessage(myMsg);
            return null;
        } else {
            return new PageReference('/'+pmRecord.id);
        }
    }
       
    //updated for batch process on 27 june 2019 (shikha)
    //@future(callout=true)
    public static void getPorteringMobile(Set<Id> portMobs){           
        Http http;
        HttpRequest request;
        String requestBody;
        
        String FResponse = '';    
        List<Porteringen_mobiel__c> updatePorteringMob = new List<Porteringen_mobiel__c>();
        
        for(Porteringen_mobiel__c portMob : [SELECT Id, BlockCallerId__c, BlockCallsToInternationalNumbers__c, BlockCallWaiting__c, 
                                             BlockDataRoaming__c, BlockIncomingCallsWhenRoaming__c, BlockOutgoingCalls__c, 
                                             BlockOutgoingCallsExceptDomestic__c, BlockPremiumSms__c, BlockRoaming__c, 
                                             BlockServiceNumbers__c, BlockSim__c, DataRoamingLimitEnabled__c, IRMA_Id__c,
                                             BlockVoLte__c ,account__r.IRMA_MKB_Office__c //24 Jan
                                             FROM Porteringen_mobiel__c WHERE Id IN : portMobs]){  
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
               requestBody += '<con:ModifyMobileSettingsRequest_V1>';  
               requestBody += '<con:OrderId>'+ portMob.IRMA_ID__C + '</con:OrderId>';
               requestBody += '<con:Settings>';
               requestBody += '<con:BlockSim>'+portMob.BlockSim__c+'</con:BlockSim>';
               requestBody += '<con:BlockOutgoingCalls>'+portMob.BlockOutgoingCalls__c+'</con:BlockOutgoingCalls>';
               requestBody += '<con:BlockCallsToInternationalNumbers>'+portMob.BlockCallsToInternationalNumbers__c+'</con:BlockCallsToInternationalNumbers>';
               requestBody += '<con:BlockOutgoingCallsExceptDomestic>'+portMob.BlockOutgoingCallsExceptDomestic__c+'</con:BlockOutgoingCallsExceptDomestic>';
               requestBody += '<con:BlockRoaming>'+portMob.BlockRoaming__c+'</con:BlockRoaming>';
               requestBody += '<con:BlockIncomingCallsWhenRoaming>'+portMob.BlockIncomingCallsWhenRoaming__c+'</con:BlockIncomingCallsWhenRoaming>';
               requestBody += '<con:BlockDataRoaming>'+portMob.BlockDataRoaming__c+'</con:BlockDataRoaming>';
               requestBody += '<con:BlockServiceNumbers>'+portMob.BlockServiceNumbers__c+'</con:BlockServiceNumbers>';
               requestBody += '<con:BlockCallerId>'+portMob.BlockCallerId__c+'</con:BlockCallerId>';
               requestBody += '<con:BlockCallWaiting>'+portMob.BlockCallWaiting__c+'</con:BlockCallWaiting>';
               requestBody += '<con:BlockPremiumSms>'+portMob.BlockPremiumSms__c+'</con:BlockPremiumSms>';
               requestBody += '<con:BlockVoLte>'+portMob.BlockVoLte__c+'</con:BlockVoLte>';
               requestBody += '<con:DataRoamingLimitEnabled>'+portMob.DataRoamingLimitEnabled__c+'</con:DataRoamingLimitEnabled>';               
               requestBody += '</con:Settings>';
               requestBody += '</con:ModifyMobileSettingsRequest_V1>';
               requestBody += '</con:requestData>';
               requestBody += '</con:grexxRequest>';
               requestBody += '</soapenv:Body>';
               requestBody += '</soapenv:Envelope>';
               
               system.debug('requestBody -'+requestBody );
               
               http = new Http();   
               request = new HttpRequest();
               if(portMob.account__r.IRMA_MKB_Office__c) {
                   request.setEndPoint('callout:MKB_Grexx/modifymobilesettings');
               }else {
                   request.setEndPoint('callout:Grexx/modifymobilesettings');
               } 
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
                               if(key == 'IsSuccess'){
                                   if(mapOfFields.get(key) == 'true'){
                                       system.debug('come in');
                                       portMob.Modify_Mobile_Settings_Response__c = 'Success';
                                       updatePorteringMob.add(portMob);
                                    } else {
                                       portMob.Modify_Mobile_Settings_Response__c = mapOfFields.get('ErrorMessage') != null ? mapOfFields.get('ErrorMessage') : mapOfFields.get('message');
                                       updatePorteringMob.add(portMob);
                                    }
                               } //end if(key)  
                               else{
                                   portMob.Modify_Mobile_Settings_Response__c = mapOfFields.get('message');
                                   updatePorteringMob.add(portMob);
                               }
                           }//end for(mapOfFields)  
                       }
                   }//endif(getRootElement)               
        }//end for(Quote query)     
        if(updatePorteringMob.size() > 0)
            update updatePorteringMob;          
    }
    
     private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug(node.getName()); 
            if(node.getName() == 'IsSuccess'){
                system.debug(node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                bool = false;
            }
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