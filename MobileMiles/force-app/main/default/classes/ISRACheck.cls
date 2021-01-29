/*
Class Name  :     ISRACheck
Date        :     5th October 2018    
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/
public class ISRACheck{
    static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    
   // @future(callout=true)
    public static void getAccountDetails(Set<String> accIds)
    {   
        system.debug('getAccountDetails called...'+accIds);
        List<Account> listofAccount = new List<Account>();
        Http http;
        HttpRequest request;
        String requestBody;
                        
        List<Infra_informatie__c> infraInformaties = new List<Infra_informatie__c>();
        
        for(Account account : [SELECT Id, Producttype_ISRA_check__c, ShippingPostalCode, Huisnummer__c, Huisnummer_toevoeging__c, 
                               Cleaned_phone__c, IsraSpecification__c, ISRA_CurrentTeleponeType__c, ISRA_FTTH_CurrentTypeOfConnection__c, 
                               ISRA_XDSL_CurrentTypeOfConnection__c, ISRA_ErrorMessage__c FROM Account WHERE Id IN: accIds]){
                                   
                                   String FResponse = '';
                                   bool = true;
                                   requestBody='';
                                   mapOfFields = new Map<String,String>();
                                   requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
                                   requestBody += '<soapenv:Header/>';
                                   requestBody += '<soapenv:Body>';
                                   requestBody += '<con:grexxRequest>';
                                   requestBody += '<con:header>';
                                   requestBody += '<con:reference>'+account.Id+'</con:reference>';
                                   requestBody += '</con:header>';
                                   requestBody += '<con:requestData>';
                                   requestBody += '<con:CarrierInfoRequest_V1>';
                                   requestBody += '<con:ProductType>FttH</con:ProductType>';
                                   requestBody += '<con:ZipCode>'+(account.ShippingPostalCode != null ? account.ShippingPostalCode : '')+'</con:ZipCode>';
                                   requestBody += '<con:HouseNumber>'+(account.Huisnummer__c != null ? account.Huisnummer__c : '')+'</con:HouseNumber>';
                                   requestBody += '<con:HouseNumberExt>'+(account.Huisnummer_toevoeging__c != null ? account.Huisnummer_toevoeging__c : '')+'</con:HouseNumberExt>';
                                   //requestBody += '<con:PhoneNumber>'+account.Cleaned_phone__c+'</con:PhoneNumber>';
                                   //requestBody += '<con:IsraSpecification>'+account.IsraSpecification__c+'</con:IsraSpecification>';
                                   requestBody += '</con:CarrierInfoRequest_V1>';
                                   requestBody += '</con:requestData>';
                                   requestBody += '</con:grexxRequest>';
                                   requestBody += '</soapenv:Body>';
                                   requestBody += '</soapenv:Envelope>';
                                   
                                   http = new Http();   
                                   request = new HttpRequest();
                                   request.setEndPoint('callout:Grexx/isracheck');
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
                                               system.debug('@Response : ' + FResponse );
                                           }
                                       }catch(Exception ex){
                                           System.debug('Exception Found !!' + ex.getMessage());
                                       }
                                       
                                   }else{
                                       FResponse += '<?xml version="1.0" encoding="utf-8"?>';
                                       FResponse += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                                       FResponse += '<soap:Body>';
                                       FResponse += '<grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect">';
                                       FResponse += '<header><transactionID>1:5490:3857207</transactionID><reference>1234</reference></header>';
                                       FResponse += '<status><code>0</code><message>Succes</message></status>';
                                       FResponse += '<responseData><CarrierInfoResponse_V1 xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                                       FResponse += '<ProductType>xDSL</ProductType><ErrorMessage>Validation Error Found</ErrorMessage><ZipCode>5371MJ</ZipCode><HouseNumber>4</HouseNumber><HouseNumberExt/><Street>DE HEINEN</Street><City>RAVENSTEIN</City><MainPhoneNumber>0486414395</MainPhoneNumber><CurrentTeleponeType>ISDN</CurrentTeleponeType><PhoneHasDifferentAddress>true</PhoneHasDifferentAddress><DistributionPoint>CO (Central Office)</DistributionPoint><FtthNlsType>6</FtthNlsType><PossibleAddresses/>';
                                       FResponse += '<XdslConnectionPoints/>';
                                       FResponse += '<FtthConnectionPoints><FtthConnectionPoint_V1><FiberTerminationPointId/><FtuType>FTU_GN02</FtuType><FtthConnections>';
                                       FResponse += '<FtthConnection_V1><CurrentTypeOfConnection>FTTH Broadband service</CurrentTypeOfConnection><CurrentConnectionId>REF0009543236</CurrentConnectionId><FutureTypeOfConnection>No change</FutureTypeOfConnection><FutureConnectionId/></FtthConnection_V1>';                                       
                                       FResponse += '</FtthConnections><FtthNlsType>6</FtthNlsType><PlanDate>2010-09-03T00:00:00</PlanDate></FtthConnectionPoint_V1></FtthConnectionPoints><Comments/><WeasFiberConnections/></CarrierInfoResponse_V1></responseData></grexxResponse></soap:Body></soap:Envelope>';
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
                                           Infra_informatie__c infraMatie = new Infra_informatie__c();
                                           infraMatie.account__c = account.id;
                                           for(String key : MapOfFields.keySet()){ 
                                               if(key == 'FtuType'){
                                                   infraMatie.FtuType__c = mapOfFields.get(key);
                                               }
                                               if(key == 'FtthNlsType'){
                                                   infraMatie.FtthNlsType__c = mapOfFields.get(key);
                                               }
                                               if(key == 'PlanDate'){
                                                   try{
                                                       infraMatie.PlanDate__c = mapOfFields.get(key) != null ? Date.valueOf(mapOfFields.get(key)) : null;
                                                   }catch(Exception ex){
                                                       system.debug('Invalid Plan Date #' + infraMatie.PlanDate__c);
                                                   }
                                                   
                                               }
                                               if(key == 'CurrentTypeOfConnection'){
                                                   infraMatie.CurrentTypeOfConnection__c = mapOfFields.get(key);
                                               }
                                               if(key == 'CurrentConnectionId'){
                                                   infraMatie.CurrentConnectionId__c = mapOfFields.get(key);
                                               }
                                               if(key == 'FutureTypeOfConnection'){
                                                   infraMatie.FutureTypeOfConnection__c = mapOfFields.get(key);
                                               }
                                               if(key == 'FutureConnectionId'){
                                                   infraMatie.FutureConnectionId__c = mapOfFields.get(key);
                                               }else if(key == 'ErrorMessage'){
                                                   account.ISRA_ErrorMessage__c = mapOfFields.get(key);
                                               }                                               
                                           }
                                           infraInformaties.add(infraMatie);
                                           account.isra_status__C = statusCode;
                                           listofAccount.add(account);                                         
                                       }
                                       
                                       
                                   }
                                   
                               }
        
        //delete existing records if exists.
        if(listOfAccount.size() > 0)
            delete [select id from Infra_informatie__c where account__C IN : listOfAccount];
        
        //insert new one.
        if(infraInformaties.size() > 0){
            Database.SaveResult[] srInfraList = Database.insert(infraInformaties, false);
        }
        //update account
        if(listOfAccount.size() > 0){
            Database.SaveResult[] srList = Database.update(listOfAccount, false);
            // Iterate through each returned result
        
            for (Database.SaveResult sr : srList) {
                
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Updated account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }                
            }
        }
        
    }
    
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            //system.debug(node.getName()); 
            if(node.getName() == 'CurrentTeleponeType'){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'XdslConnection_V1'){
                for(Dom.XmlNode connection_node : node.getChildElements()){
                    
                    if(connection_node.getName() == 'CurrentTypeOfConnection'){
                        mapOfFields.put('XdslConnection_V1-'+connection_node.getName(), connection_node.getText());
                    }               
                } 
                
                for(Dom.XmlNode fconnection_node :node.getParent().getParent().getParent().getParent().getChildElements()){
                    
                    if(fconnection_node.getName() == 'FtthConnectionPoints'){
                        node = fconnection_node;
                        
                    }
                }
                
                
            }
            if(node.getName() == 'FtthConnectionPoints'){
                for(Dom.XmlNode connection_node : node.getChildElements()){
                    if(connection_node.getName() == 'FtthConnectionPoint_V1'){
                        for(Dom.XmlNode connection_node_child : connection_node.getChildElements()){
                            if(connection_node_child.getName() == 'FtuType'){
                                mapOfFields.put(connection_node_child.getName(), connection_node_child.getText());
                            }
                            if(connection_node_child.getName() == 'FtthConnections'){
                                for(Dom.XmlNode connection_node_child_2 : connection_node_child.getChildElements()){
                                    if(connection_node_child_2.getName() == 'FtthConnection_V1'){
                                        for(Dom.XmlNode connection_node_child_3 : connection_node_child_2.getChildElements()){
                                            mapOfFields.put(connection_node_child_3.getName(), connection_node_child_3.getText());
                                        }
                                    }
                                }
                            }
                            if(connection_node_child.getName() == 'FtthNlsType'){
                                mapOfFields.put(connection_node_child.getName(), connection_node_child.getText());
                            }
                            if(connection_node_child.getName() == 'PlanDate'){
                                mapOfFields.put(connection_node_child.getName(), connection_node_child.getText());
                            }
                        }
                    }
                }
            }
            /*if(node.getName() == 'FtthConnection_V1'){
                for(Dom.XmlNode connection_node : node.getChildElements()){
                    if(connection_node.getName() == 'CurrentTypeOfConnection'){
                        mapOfFields.put('FtthConnection_V1-'+connection_node.getName(), connection_node.getText());
                        bool = false;
                    }
                    if(connection_node.getName() == 'CurrentConnectionId'){
                        mapOfFields.put('FtthConnection_V1-'+connection_node.getName(), connection_node.getText());
                        bool = false;
                    } 
                    if(connection_node.getName() == 'FutureTypeOfConnection'){
                        mapOfFields.put('FtthConnection_V1-'+connection_node.getName(), connection_node.getText());
                        bool = false;
                    } 
                    if(connection_node.getName() == 'FutureConnectionId'){
                        mapOfFields.put('FtthConnection_V1-'+connection_node.getName(), connection_node.getText());
                        bool = false;
                    }                
                } 
            }*/
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }
    
}