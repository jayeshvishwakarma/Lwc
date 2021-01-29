/*
Class Name  :     ZipCodeCheckController
Date        :     26th April 2019    
Author      :     Ibirds Software Services
Description :     This Class is Used to Make a HTTP Callout using SOAP API
*/

public class ZipCodeCheckController{
    Static Account accRecord;
    Static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    public Static String errMsg{get;set;}
    Static List<Available_Supplier__c> supplierList;
    Static List<Available_Speed__c> speedList;
    Static Map<string, List<Available_Speed__c>> mapOfBoth = new Map<string, List<Available_Speed__c>>();
    
    //to call ZipCodeCheck API made on 26 april 2019 by shikha
    public ZipCodeCheckController(ApexPages.StandardController stdController) {
        accRecord = (Account)stdController.getRecord();
        errMsg = '';
        supplierList = new List<Available_Supplier__c>();
        speedList = new List<Available_Speed__c>();
    }


    public static PageReference doPost(){
       Http http;
       HttpRequest request;
       String requestBody;
        
       String FResponse = '';    
       for(Account acc : [SELECT Id, Name, Huisnummer__c, Huisnummer_toevoeging__c, ZipCode__c, Connectivity_portfolio__c 
                             FROM Account WHERE Id =: accRecord.id]){
           bool = true;
           requestBody='';
           mapOfFields = new Map<String,String>();
           
           if(acc.Id != null && acc.Name != null && acc.Connectivity_portfolio__c != null && acc.Huisnummer__c != null && acc.ZipCode__c != null){
               requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
               requestBody += '<soapenv:Header/>';
               requestBody += '<soapenv:Body>';
               requestBody += '<con:grexxRequest>';
               requestBody += '<con:header>';
               requestBody += '<con:reference>'+accRecord.id+'</con:reference>';  
               requestBody += '</con:header>';
               requestBody += '<con:requestData>';
               requestBody += '<con:ZipCodeCheckRequest>';  
               requestBody += '<con:Portfolio>'+acc.Connectivity_portfolio__c+'</con:Portfolio>';
               requestBody += '<con:ZipCode>'+acc.ZipCode__c+'</con:ZipCode>';
               requestBody += '<con:HouseNr>'+acc.Huisnummer__c+'</con:HouseNr>';
               requestBody += '</con:ZipCodeCheckRequest>';  
               requestBody += '</con:requestData>';
               requestBody += '</con:grexxRequest>';
               requestBody += '</soapenv:Body>';
               requestBody += '</soapenv:Envelope>';
               
               system.debug('requestBody -'+requestBody );
               
               http = new Http();   
               request = new HttpRequest();
               request.setEndPoint('callout:Grexx/zipcodecheck');
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
                    //for testing purpose
                    FResponse = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:6306:1291375</transactionID><reference>'+accRecord.id+'</reference></header><status><code>0</code><message>Succes</message></status><responseData><ZipCodeCheckResponse><AvailableSuppliers><AvailableSupplier><Name>KPN</Name><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>960/5839 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>ADSL 2+</Technology></AvailableSpeed><AvailableSpeed><Availability>Yellow</Availability><Description>960/12595 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>ADSL 2+</Technology></AvailableSpeed><AvailableSpeed><Availability>Green</Availability><Description>1362/13943 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/> <Remarks/><Technology>VDSL</Technology></AvailableSpeed><AvailableSpeed><Availability>Yellow</Availability><Description>2047/17839 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>VDSL</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier><AvailableSupplier><Name>KPNWEAS</Name><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>Gebiedscode A On-net fiber NLS 2</Description><NlsType>2</NlsType><Remarks/><Technology>WEAS Fiber</Technology></AvailableSpeed><AvailableSpeed><Availability>Red</Availability><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>WEAS Koper</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier><AvailableSupplier><Name>Eurofiber</Name><ErrorMessage>Door onbekende oorzaak is er momenteel geen communicatie met Eurofiber mogelijk</ErrorMessage><AvailableSpeeds/></AvailableSupplier><AvailableSupplier><Name>Tele2</Name><LocationInfo>Wijkcentrale Almere (Alr-Sc), afstand tot centrale 1286 meter</LocationInfo><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>20480/20480 Kbit/sec (4 koper paren)</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>Extended Ethernet</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier><AvailableSupplier><Name>Tele2Fiber</Name><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>Gebiedscode A On-net</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>Fiber</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier></AvailableSuppliers></ZipCodeCheckResponse></responseData></grexxResponse></soap:Body></soap:Envelope>';
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
                       system.debug('MapOfFields.keySet() - '+MapOfFields.keySet());
                       for(String key : MapOfFields.keySet()){
                           if(key == 'message'){
                               if(mapOfFields.get(key) == 'Succes'){
                                   List<Available_Supplier__c> delSuppList = [select id from Available_Supplier__c Where Account__c =: accRecord.id];
                                   if(delSuppList.size() > 0){
                                       delete delSuppList;}
                                   List<Available_Speed__c> insertSpeedList = new List<Available_Speed__c>();
                                   insert supplierList;
                                   for(Available_Supplier__c supp : supplierList){
                                       if(mapOfBoth.containsKey(supp.name) && mapOfBoth.get(supp.name) != null){
                                           for(Available_Speed__c speed : mapOfBoth.get(supp.name)){
                                               speed.Available_Supplier__c = supp.id;
                                               insertSpeedList.add(speed);
                                           }
                                       }
                                   }
                                   system.debug('supplierList --- ' + supplierList);
                                   system.debug('insertSpeedList --- ' + insertSpeedList);
                                   insert insertSpeedList;
                                   return new PageReference('/'+accRecord.id);
                               }else {
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,mapOfFields.get(key));
                                    ApexPages.addMessage(myMsg);
                                    return null;
                                }
                           }
                       }//end for(mapOfFields)
                     }//endif(getRootElement)
                   }//endif(FResponse)
               } else {
                  errMsg += 'Required Fields are missing-\n';
                  errMsg += (acc.Id != null)?'':'Account ID,'+'\n';
                  errMsg += (acc.Name != null)?'':'Account Name,\n';
                  errMsg += (acc.Huisnummer__c != null)?'':'House Number,\n';
                  errMsg += (acc.Connectivity_portfolio__c != null)?'':'Portfolio,\n';
                  errMsg += (acc.ZipCode__c != null)?'':'ZipCode\n';
               }//end if (validation)
        }//end for(Quote query)
        
        system.debug('err msg-'+errMsg);
        if(errMsg != ''){
            errMsg = errMsg.substringBeforeLast(',');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg);
            ApexPages.addMessage(myMsg);
            return null;
        } else {
            return new PageReference('/'+accRecord.id);
        }

    }
    
    
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName() == 'message'){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }

            if(node.getName() == 'AvailableSuppliers'){
                for(Dom.XmlNode connection_node : node.getChildElements()){
                    Available_Supplier__c newSupplier = new Available_Supplier__c();
                    if(connection_node.getName() == 'AvailableSupplier'){
                        for(Dom.XmlNode connection_childnode : connection_node.getChildElements()){
                            if(connection_childnode.getName() == 'Name'){
                                newSupplier.Name = connection_childnode.getText();
                                newSupplier.Account__c = accRecord.id;
                            }
                            if(connection_childnode.getName() == 'LocationInfo'){
                                newSupplier.Location_Info__c = connection_childnode.getText();
                            }
                            
                            if(connection_childnode.getName() == 'AvailableSpeeds'){
                                for(Dom.XmlNode connection_speednode : connection_childnode.getChildElements()){
                                    if(connection_speednode.getName() == 'AvailableSpeed'){
                                        Available_Speed__c newSpeed = new Available_Speed__c();
                                        for(Dom.XmlNode connection_speednode1 : connection_speednode.getChildElements()){
                                            if(connection_speednode1.getName() == 'Availability'){
                                                newSpeed.Availability__c = connection_speednode1.getText(); }
                                            if(connection_speednode1.getName() == 'Description'){
                                                newSpeed.Description__c = connection_speednode1.getText(); }
                                            if(connection_speednode1.getName() == 'Technology'){
                                                newSpeed.Technology__c = connection_speednode1.getText(); }
                                        }//endfor connection_speednode1 
                                        speedList.add(newSpeed);
                                    }//endif availablespeed
                                }//endfor connection_speednode 
                            }//endif availablespeeds
                        }//endif AvailableSupplier node
                        if(newSupplier.Name != null){
                            supplierList.add(newSupplier); 
                            mapOfBoth.put(newSupplier.Name, speedList);
                            speedList = new List<Available_Speed__c>();
                        }
                    }//endfor connection_node                             
                } //endif AvailableSuppliers node
                bool = false;
            }
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }

}