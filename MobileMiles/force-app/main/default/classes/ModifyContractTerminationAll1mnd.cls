/*
Class Name  :     ModifyContractTermination
Date        :     27th June 2019
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/

public class ModifyContractTerminationAll1mnd{
    Static Account pmRecord;
    public Static String errMsg{get;set;}
    static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    
     //to call ModifyContractTermination API made on 28 june 2019 by shikha
    public ModifyContractTerminationAll1mnd(ApexPages.StandardController stdController) {
        pmRecord = (Account)stdController.getRecord();
        errMsg = '';
    }    
        
    public static PageReference callModifyContractTerminationAPI(){   
        Set<String> pmIdSet = new Set<String>{pmRecord.id};
        modifyContract(pmIdSet);
        if(errMsg != ''){
            errMsg = errMsg.substringBeforeLast(',');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
            ApexPages.addMessage(myMsg);
            return null;
        } else {
            return new PageReference('/'+pmRecord.id);
        }
    }
    
    // @future(callout=true)
    public static void modifyContract(Set<String> pmIds)
    {   
        system.debug('modifyContract called...'+pmIds);
        List<Porteringen_mobiel__c> listofPM = new List<Porteringen_mobiel__c>();
        Http http;
        HttpRequest request;
        String requestBody='';
        String FResponse = '';
                
        for(Porteringen_mobiel__c porteringen : [Select name, id, IRMA_Id__c, Contract_einddatum__c, Modify_Contract_Response__c, 
                                        Opzegtermijn_maanden__c, Contract_duur_afloopdatum_wijzigen__c 
                                        from Porteringen_mobiel__c Where Account__c in :pmIds and Actief__c = true and IRMA_Id__c != null]){
             
          porteringen.Contract_duur_afloopdatum_wijzigen__c = false;                            
          requestBody='';
          bool = true;
          mapOfFields = new Map<String,String>();
            
          //if(porteringen.Id != null && porteringen.IRMA_Id__c != null && porteringen.Contract_einddatum__c != null && porteringen.Opzegtermijn_maanden__c != null){
            requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
            requestBody += '<soapenv:Header/>';
            requestBody += '<soapenv:Body>';
            requestBody += '<con:grexxRequest>';
            requestBody += '<con:header>';
            requestBody += '<con:reference>'+porteringen.Id+'</con:reference>';   
            requestBody += '</con:header>';
            requestBody += '<con:requestData>';
            requestBody += '<con:ModifyContractTerminationDetailsRequest_V1>';  
            requestBody += '<con:OrderId>'+porteringen.IRMA_Id__c +'</con:OrderId>';
            String contractMonth = system.today().month() < 10 ? ('0' + system.today().month()) : String.valueOf(system.today().month());
            String contractDay = system.today().day() < 10 ? ('0' + system.today().day()) : String.valueOf(system.today().day());
            requestBody += '<con:ContractTerminationDate>'+system.today().year() + '-' + contractMonth + '-' + contractDay  +'</con:ContractTerminationDate>';
            requestBody += '<con:ContractTerminationDuration>1</con:ContractTerminationDuration>';
            requestBody += '</con:ModifyContractTerminationDetailsRequest_V1>';
            requestBody += '</con:requestData>';
            requestBody += '</con:grexxRequest>';
            requestBody += '</soapenv:Body>';
            requestBody += '</soapenv:Envelope>';

            system.debug('requestBody -'+requestBody );
    
            http = new Http();   
            request = new HttpRequest();
            request.setEndPoint('callout:Grexx/modifycontracttermination');
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
                       porteringen.Modify_Contract_Response__c = 'Success';
                   }else{
                       porteringen.Modify_Contract_Response__c = 'Failed';
                   } 
               }
             }//end if
             listofPM.add(porteringen);    
           /*} else {
              errMsg += 'Required Fields are missing-\n';
              errMsg += (porteringen.Id != null)?'':'Portering Mobile ID,'+'\n';
              errMsg += (porteringen.IRMA_Id__c != null)?'':'Porteing Mobile IRMA ID,\n';
              errMsg += (porteringen.Contract_einddatum__c != null)?'':'Porteing Mobile Contract Termination Date,\n';
              errMsg += (porteringen.Opzegtermijn_maanden__c != null)?'':'Porteing Mobile Contract Termination Duration,\n';
           }//end if (validation)    */                                 
         }//end outer for
         
         System.debug('Successfully Updated PMList: ' + listofPM);
         
         //save data in database
         Database.SaveResult[] srList = Database.update(listOfPM, false);
         // Iterate through each returned result
        
         for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Updated PM. PM ID: ' + sr.getId());
            } else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('PM fields that affected this error: ' + err.getFields());
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