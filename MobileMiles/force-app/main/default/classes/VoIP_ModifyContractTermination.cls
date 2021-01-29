/*
Class Name  :     VoIP_ModifyContractTermination
Date        :     13 August 2019
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/

public class VoIP_ModifyContractTermination{
    Static VoIP__c voipRecord;
    public Static String errMsg{get;set;}
    static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    
     //to call VoIP_ModifyContractTermination API made on 13 august 2019 by shikha
    public VoIP_ModifyContractTermination(ApexPages.StandardController stdController) {
        voipRecord = (VoIP__c)stdController.getRecord();
        errMsg = '';
    }    
    
    
    //To be called by VF Page on button click 
    public static PageReference callVoIP_ModifyContractTerminationAPI(){   
        Set<String> voipIdSet = new Set<String>{voipRecord.id};
        voipmodifyContract(voipIdSet);
        if(errMsg != ''){
            errMsg = errMsg.substringBeforeLast(',');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
            ApexPages.addMessage(myMsg);
            return null;
        } else {
            return new PageReference('/'+voipRecord.id);
        }
    }
    
    // @future(callout=true)
    public static void voipmodifyContract(Set<String> voipIds)
    {   
        system.debug('voipmodifyContract called...'+voipIds);
        List<VoIP__c> listofVOIP = new List<VoIP__c>();
        Http http;
        HttpRequest request;
        String requestBody='';
        String FResponse = '';
                
        for(VoIP__c voip : [Select name, id, IRMA_Id__c, ContractTerminationDate__c, Modify_Contract_Response__c, 
                                        ContractTerminationDuration__c, Contract_duur_afloopdatum_wijzigen__c, account__r.IRMA_MKB_Office__c
                                        from VoIP__c Where id in :voipIds]){
             
          voip.Contract_duur_afloopdatum_wijzigen__c = false;                            
          requestBody='';
          bool = true;
          mapOfFields = new Map<String,String>();
            
          if(voip.Id != null && voip.IRMA_Id__c != null && voip.ContractTerminationDate__c != null && voip.ContractTerminationDuration__c != null){
            requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
            requestBody += '<soapenv:Header/>';
            requestBody += '<soapenv:Body>';
            requestBody += '<con:grexxRequest>';
            requestBody += '<con:header>';
            requestBody += '<con:reference>'+voip.Id+'</con:reference>';   
            requestBody += '</con:header>';
            requestBody += '<con:requestData>';
            requestBody += '<con:ModifyContractTerminationDetailsRequest_V1>';  
            requestBody += '<con:OrderId>'+voip.IRMA_Id__c +'</con:OrderId>';
            String contractMonth = voip.ContractTerminationDate__c.month() < 10 ? ('0' + voip.ContractTerminationDate__c.month()) : String.valueOf(voip.ContractTerminationDate__c.month());
            String contractDay = voip.ContractTerminationDate__c.day() < 10 ? ('0' + voip.ContractTerminationDate__c.day()) : String.valueOf(voip.ContractTerminationDate__c.day());
            requestBody += '<con:ContractTerminationDate>'+voip.ContractTerminationDate__c.year() + '-' + contractMonth + '-' + contractDay  +'</con:ContractTerminationDate>';
            requestBody += '<con:ContractTerminationDuration>'+voip.ContractTerminationDuration__c+'</con:ContractTerminationDuration>';
            requestBody += '</con:ModifyContractTerminationDetailsRequest_V1>';
            requestBody += '</con:requestData>';
            requestBody += '</con:grexxRequest>';
            requestBody += '</soapenv:Body>';
            requestBody += '</soapenv:Envelope>';

            system.debug('requestBody -'+requestBody );
    
            http = new Http();   
            request = new HttpRequest();
            if( voip.account__r.IRMA_MKB_Office__c ) {
                request.setEndPoint('callout:MKB_Grexx/modifycontracttermination');
            }else {
                request.setEndPoint('callout:Grexx/modifycontracttermination');
            } 
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml');    
            request.setBody(requestBody);
            
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
                FResponse = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                FResponse += '<soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect">';
                FResponse += '<header><transactionID>1:5490:15784304</transactionID><reference>a6A57000000ChEM</reference></header>';
                FResponse += '<status><code>0</code><message>Succes</message></status>';
                FResponse += '<responseData><QueueResponse><IsSuccess>true</IsSuccess><ErrorCode>0</ErrorCode></QueueResponse></responseData>';
                FResponse += '</grexxResponse></soap:Body></soap:Envelope>';
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
                   
                   if(mapOfFields.containsKey('IsSuccess') && mapOfFields.get('IsSuccess') == 'true'){
                       voip.Modify_Contract_Response__c = 'Success';
                   }else{
                       voip.Modify_Contract_Response__c = 'Failed';
                   } 
               }
             }//end if
             listofVOIP.add(voip);    
           } else {
              errMsg += 'Required Fields are missing-\n';
              errMsg += (voip.Id != null)?'':'VoIP ID,'+'\n';
              errMsg += (voip.IRMA_Id__c != null)?'':'VoIP IRMA ID,\n';
              errMsg += (voip.ContractTerminationDate__c != null)?'':'VoIP Contract Termination Date,\n';
              errMsg += (voip.ContractTerminationDuration__c != null)?'':'VoIP Contract Termination Duration,\n';
           }//end if (validation)                                     
         }//end outer for
         
         System.debug('Successfully Updated VOIPList: ' + listofVOIP);
         
         //save data in database
         Database.SaveResult[] srList = Database.update(listofVOIP, false);
         // Iterate through each returned result
        
         for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Updated VOIP. VoIP ID: ' + sr.getId());
            } else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('VoIP fields that affected this error: ' + err.getFields());
                }
            }
          }
      }


    private static void parseXML(DOM.XMLNode node) {    
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            //system.debug(node.getName()); 
            if(node.getName() == 'IsSuccess'){
                system.debug(node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                bool = false;
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'message'){
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