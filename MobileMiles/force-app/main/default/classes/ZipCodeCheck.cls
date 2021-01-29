/*
Class Name  :     ZipCodeCheck
Date        :     27th May, 2019
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/
public class ZipCodeCheck{
    static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    private Static List<Available_Supplier__c> supplierList = new List<Available_Supplier__c>();
    private Static List<Available_Speed__c> speedList = new List<Available_Speed__c>();
    private Static List<Available_Supplier__c> delSuppList = new List<Available_Supplier__c>();
    private Static Map<string, List<Available_Speed__c>> mapOfBoth = new Map<string, List<Available_Speed__c>>();
    
   // @future(callout=true)
    public static void getAccountDetailsZipCode(Set<String> accIds){   
        system.debug('getAccountDetailsZipCode called...'+accIds);
       Map<Id, Account> acctoUpdate = new Map<Id, Account>();
       
       //supplierList = new List<Available_Supplier__c>();
       //speedList = new List<Available_Speed__c>();
       //delSuppList = new List<Available_Supplier__c>();
        
       
       for(Account acc : [SELECT id, name, Connectivity_portfolio__c, Huisnummer__c, ZipCode__c, 
                          ZipCode_Response__c, ZipCode_Process_Finished__c, Check_Beschikbaarheid__c,
                          Selected_Technology_beschikbaar__c , Huisnummer_toevoeging__c
                          FROM Account WHERE Id IN: accIds]){
           bool = true;
           
           mapOfFields = new Map<String,String>();
           
           if(acc.Id != null && acc.Name != null && acc.Connectivity_portfolio__c != null && acc.Huisnummer__c != null && acc.ZipCode__c != null){
               
               executeAPI(acc.Id, acc.Connectivity_portfolio__c, acc.ZipCode__c, acc.Huisnummer__c, acc.Huisnummer_toevoeging__c);
               
               system.debug('MapOfFields.keySet() - '+MapOfFields.keySet());
               for(String key : MapOfFields.keySet()){
                   if(key == 'message'){
                       acc.ZipCode_Response__c = mapOfFields.get(key);                               
                       if(mapOfFields.get(key) == 'Succes'){
                           List<Available_Supplier__c> delList = [select id from Available_Supplier__c Where Account__c =: acc.id];
                           if(delList.size() > 0){
                               delSuppList.addAll(delList);
                           }   
                       }
                   }                           
               }//end for(mapOfFields)
                     
            } //end if (validation)
           acc.Check_Beschikbaarheid__c = false;
           acc.ZipCode_Process_Finished__c = true;  
           accToUpdate.put(acc.id, acc);  
        }//end for(Quote query)
        
        //insertion & deletion of records
        if(delSuppList.size() > 0){
            delete delSuppList;}
        List<Available_Speed__c> insertSpeedList = new List<Available_Speed__c>();
        if(supplierList.size() > 0){
            insert supplierList;
            for(Available_Supplier__c supp : supplierList){
                if(mapOfBoth.containsKey(supp.account__c+'-'+supp.name) && mapOfBoth.get(supp.account__c+'-'+supp.name) != null){
                    for(Available_Speed__c speed : mapOfBoth.get(supp.account__c+'-'+supp.name)){
                        speed.Available_Supplier__c = supp.id;
                        //done by ranu on 24th june 2019
                        speed.Account__c = supp.Account__c;
                        insertSpeedList.add(speed);
                        
                        //process builder "Account on Speed" logic
                        if(speed.Selected_Technology__c && accToUpdate.containsKey(supp.Account__c) && 
                           accToUpdate.get(supp.Account__c).Selected_Technology_beschikbaar__c == FALSE){
                            
                            Account acc = accToUpdate.get(supp.Account__c);
                            acc.Selected_Technology_beschikbaar__c = TRUE;
                            accToUpdate.put(acc.id, acc);
                        }
                    }
                }
            }
            system.debug('supplierList --- ' + supplierList);
            system.debug('insertSpeedList --- ' + insertSpeedList);
            system.debug('mapofboth---'+mapofboth);
            insert insertSpeedList;
        }
        if(accToUpdate.size() > 0){
            update accToUpdate.values();
        }                      
    }        
    private static void parseXML(DOM.XMLNode node, String accId) {
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
                                newSupplier.Account__c = accId;
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
                            mapOfBoth.put(accId +'-'+newSupplier.Name, speedList);
                            speedList = new List<Available_Speed__c>();
                        }
                    }//endfor connection_node                             
                } //endif AvailableSuppliers node
                bool = false;
            }
            
        }
        system.debug('mapOfFields'+mapOfFields);
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child, accId);    
            }
            
        }
        
    }
    
    public static void executeAPI(String accountId, String portfolio, String zipcode, String houseNr, String hourseNrExtension){
       Http http;
       HttpRequest request;
       String requestBody;
       String FResponse = ''; 
        requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
           requestBody += '<soapenv:Header/>';
           requestBody += '<soapenv:Body>';
           requestBody += '<con:grexxRequest>';
           requestBody += '<con:header>';
           requestBody += '<con:reference>'+ accountId+'</con:reference>';  
           requestBody += '</con:header>';
           requestBody += '<con:requestData>';
           requestBody += '<con:ZipCodeCheckRequest>';  
           requestBody += '<con:Portfolio>'+portfolio+'</con:Portfolio>';
           requestBody += '<con:ZipCode>'+zipcode+'</con:ZipCode>';
           requestBody += '<con:HouseNr>'+houseNr+'</con:HouseNr>';
           requestBody += '<con:HouseNrExtension>'+hourseNrExtension+'</con:HouseNrExtension>';
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
                 }
            } else {
                //for testing purpose
                FResponse = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:6306:1291375</transactionID><reference>acc.id</reference></header><status><code>0</code><message>Succes</message></status><responseData><ZipCodeCheckResponse><AvailableSuppliers><AvailableSupplier><Name>KPN</Name><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>960/5839 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>ADSL 2+</Technology></AvailableSpeed><AvailableSpeed><Availability>Yellow</Availability><Description>960/12595 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>ADSL 2+</Technology></AvailableSpeed><AvailableSpeed><Availability>Green</Availability><Description>1362/13943 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/> <Remarks/><Technology>VDSL</Technology></AvailableSpeed><AvailableSpeed><Availability>Yellow</Availability><Description>2047/17839 kbit/sec</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>VDSL</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier><AvailableSupplier><Name>KPNWEAS</Name><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>Gebiedscode A On-net fiber NLS 2</Description><NlsType>2</NlsType><Remarks/><Technology>WEAS Fiber</Technology></AvailableSpeed><AvailableSpeed><Availability>Red</Availability><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>WEAS Koper</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier><AvailableSupplier><Name>Eurofiber</Name><ErrorMessage>Door onbekende oorzaak is er momenteel geen communicatie met Eurofiber mogelijk</ErrorMessage><AvailableSpeeds/></AvailableSupplier><AvailableSupplier><Name>Tele2</Name><LocationInfo>Wijkcentrale Almere (Alr-Sc), afstand tot centrale 1286 meter</LocationInfo><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>20480/20480 Kbit/sec (4 koper paren)</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>Extended Ethernet</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier><AvailableSupplier><Name>Tele2Fiber</Name><AvailableSpeeds><AvailableSpeed><Availability>Green</Availability><Description>Gebiedscode A On-net</Description><NlsType p6:nil="true" xmlns:p6="http://www.w3.org/2001/XMLSchema-instance"/><Remarks/><Technology>Fiber</Technology></AvailableSpeed></AvailableSpeeds></AvailableSupplier></AvailableSuppliers></ZipCodeCheckResponse></responseData></grexxResponse></soap:Body></soap:Envelope>';
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
                   parseXML(root, accountId);
                }
            }
        
    }
    
    public static Map<string, List<Available_Speed__c>> getResultData(){
        
        return mapOfBoth;
    }

    public static Map<String,String> getResponseMessages(){
        
        return mapOfFields;
    }
}