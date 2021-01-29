/*
Class Name  :     MobileSettings
Date        :     26th June 2019
Author      :     Ibirds Software Services
Description :     This Class is Use to Make a HTTP Callout using SOAP API
*/

public class MobileSettings{
    Static Porteringen_mobiel__c pmRecord;
    public Static String errMsg{get;set;}
    static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool;
    
    //to call MobileSettings API made on 26 june 2019 by shikha
    public MobileSettings(ApexPages.StandardController stdController) {
        pmRecord = (Porteringen_mobiel__c)stdController.getRecord();
        errMsg = '';
    }    
        
    public static PageReference callMobileSettingAPI(){   
        Set<String> pmIdSet = new Set<String>{pmRecord.id};
        getMobileDetails(pmIdSet);
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
    public static void getMobileDetails(Set<String> pmIds)
    {   
        system.debug('getMobileDetails called...'+pmIds);
        List<Porteringen_mobiel__c> listofPM = new List<Porteringen_mobiel__c>();
        Http http;
        HttpRequest request;
        String requestBody='';
        String FResponse = '';
                
        for(Porteringen_mobiel__c porteringen : [Select name, id, IRMA_Id__c, BlockSim__c, BlockOutgoingCalls__c, Modify_Mobile_Settings_Response__c, 
                                        BlockCallsToInternationalNumbers__c, BlockOutgoingCallsExceptDomestic__c, BlockRoaming__c, 
                                        BlockIncomingCallsWhenRoaming__c, BlockDataRoaming__c, Blokkeren_betaalde_servicenummers__c, 
                                        BlockCallerId__c, BlockCallWaiting__c, BlockVoLte__c, BlockPremiumSms__c, 
                                        DataRoamingLimitEnabled__c, Mobiele_settings_ophalen__c, account__r.IRMA_MKB_Office__c //24 Jan 
                                        from Porteringen_mobiel__c Where id in :pmIds]){
             
          porteringen.Mobiele_settings_ophalen__c = false; 
          porteringen.Mobiele_settings_timestamp__c = system.now();                           
          requestBody='';
          bool = true;
          mapOfFields = new Map<String,String>();
          if(porteringen.Id != null && porteringen.IRMA_Id__c != null){
            requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
            requestBody += '<soapenv:Header/>';
            requestBody += '<soapenv:Body>';
            requestBody += '<con:grexxRequest>';
            requestBody += '<con:header>';
            requestBody += '<con:reference>'+porteringen.Id+'</con:reference>';   
            requestBody += '</con:header>';
            requestBody += '<con:requestData>';
            requestBody += '<con:GetMobileSettingsRequest_V1>';  
            requestBody += '<con:OrderId>'+porteringen.IRMA_Id__c +'</con:OrderId>';
            requestBody += '</con:GetMobileSettingsRequest_V1>';
            requestBody += '</con:requestData>';
            requestBody += '</con:grexxRequest>';
            requestBody += '</soapenv:Body>';
            requestBody += '</soapenv:Envelope>';
            
            system.debug('requestBody -'+requestBody );
    
            http = new Http();   
            request = new HttpRequest();
            if( porteringen.account__r.IRMA_MKB_Office__c ) {
                request.setEndPoint('callout:MKB_Grexx/mobilesettings');
            }else {
                request.setEndPoint('callout:Grexx/mobilesettings');
            } 
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml');    
            request.setBody(requestBody);
            
            if(!Test.isRunningTest()){
                try{
                   HttpResponse response = http.send(request);
                   system.debug('response.getStatusCode() -- ' + response.getStatusCode());
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
                FResponse += '<header><transactionID>1:5490:15756431</transactionID><reference></reference></header>';
                FResponse += '<status><code>0</code><message>Succes</message></status>';
                FResponse += '<responseData><GetMobileSettingsResponse_V1><Settings>';
                FResponse += '<BlockSim><Value>false</Value><IsPending>false</IsPending></BlockSim>';
                FResponse += '<BlockOutgoingCalls><Value>false</Value><IsPending>false</IsPending></BlockOutgoingCalls>';
                FResponse += '<BlockCallsToInternationalNumbers><Value>false</Value><IsPending>false</IsPending></BlockCallsToInternationalNumbers>';
                FResponse += '<BlockOutgoingCallsExceptDomestic><Value>false</Value><IsPending>false</IsPending></BlockOutgoingCallsExceptDomestic>';
                FResponse += '<BlockRoaming><Value>false</Value><IsPending>false</IsPending></BlockRoaming>';
                FResponse += '<BlockIncomingCallsWhenRoaming><Value>false</Value><IsPending>false</IsPending></BlockIncomingCallsWhenRoaming>';
                FResponse += '<BlockDataRoaming><Value>false</Value><IsPending>false</IsPending></BlockDataRoaming>';
                FResponse += '<BlockInformationNumbers><Value>false</Value><IsPending>false</IsPending></BlockInformationNumbers>';
                FResponse += '<BlockServiceNumbers><Value>false</Value><IsPending>false</IsPending></BlockServiceNumbers>';
                FResponse += '<BlockCallerId><Value>false</Value><IsPending>false</IsPending></BlockCallerId>';
                FResponse += '<BlockCallWaiting><Value>false</Value><IsPending>false</IsPending></BlockCallWaiting>';
                FResponse += '<BlockCsDataFax><Value>true</Value><IsPending>false</IsPending></BlockCsDataFax>';
                FResponse += '<BlockVoLte><Value>false</Value><IsPending>false</IsPending></BlockVoLte>';
                FResponse += '<BlockPremiumSms><Value>false</Value><IsPending>false</IsPending></BlockPremiumSms>';
                FResponse += '<DataRoamingLimitEnabled><Value>false</Value><IsPending>false</IsPending></DataRoamingLimitEnabled>';
                FResponse += '<InternationalCallForwardingEnabled><Value>false</Value><IsPending>false</IsPending></InternationalCallForwardingEnabled>';
                FResponse += '<CurrentMonthDataRoamingLimitLifted><Value>true</Value><IsPending>false</IsPending></CurrentMonthDataRoamingLimitLifted>';
                FResponse += '</Settings></GetMobileSettingsResponse_V1></responseData></grexxResponse></soap:Body></soap:Envelope>';
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
                   
                   if(mapOfFields.containsKey('ErrorMessage') && mapOfFields.get('ErrorMessage') != null){
                       porteringen.Modify_Mobile_Settings_Response__c = 'Failed';
                   } else {
                     for(String key : MapOfFields.keySet()){
                       if(key == 'BlockSim'){
                           porteringen.BlockSim__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockOutgoingCalls'){
                           porteringen.BlockOutgoingCalls__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockCallsToInternationalNumbers'){
                           porteringen.BlockCallsToInternationalNumbers__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockOutgoingCallsExceptDomestic'){
                           porteringen.BlockOutgoingCallsExceptDomestic__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockRoaming'){
                           porteringen.BlockRoaming__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockIncomingCallsWhenRoaming'){
                           porteringen.BlockIncomingCallsWhenRoaming__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockDataRoaming'){
                           porteringen.BlockDataRoaming__c = boolean.valueOf(mapOfFields.get(key));
                       //}else if(key == 'BlockInformationNumbers'){
                           //porteringen.BlockOutgoingCallsExceptDomestic__c = mapOfFields.get(key);
                       }else if(key == 'BlockServiceNumbers'){
                           porteringen.Blokkeren_betaalde_servicenummers__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockCallerId'){
                           porteringen.BlockCallerId__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockCallWaiting'){
                           porteringen.BlockCallWaiting__c = boolean.valueOf(mapOfFields.get(key));
                       //}else if(key == 'BlockCsDataFax'){
                           //porteringen.BlockOutgoingCallsExceptDomestic__c = mapOfFields.get(key);
                       }else if(key == 'BlockVoLte'){
                           porteringen.BlockVoLte__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'BlockPremiumSms'){
                           porteringen.BlockPremiumSms__c = boolean.valueOf(mapOfFields.get(key));
                       }else if(key == 'DataRoamingLimitEnabled'){
                           porteringen.DataRoamingLimitEnabled__c = boolean.valueOf(mapOfFields.get(key));
                       //}else if(key == 'InternationalCallForwardingEnabled'){
                           //porteringen.BlockOutgoingCallsExceptDomestic__c = mapOfFields.get(key);
                       //}else if(key == 'CurrentMonthDataRoamingLimitLifted'){
                           //porteringen.BlockOutgoingCallsExceptDomestic__c = mapOfFields.get(key);
                       }else if(key == 'message'){
                           porteringen.Modify_Mobile_Settings_Response__c = mapOfFields.get(key);
                       }
                     }//end for
                   }//end ErrorMessage if
                   listofPM.add(porteringen);                                         
                }//end if
             }//end outer if
           } else {
              errMsg += 'Required Fields are missing-\n';
              errMsg += (porteringen.Id != null)?'':'Portering Mobile ID,'+'\n';
              errMsg += (porteringen.IRMA_Id__c != null)?'':'Porteing Mobile IRMA ID,\n';
           }//end if (validation)
         }//end outer for query
         
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
            if(node.getName() == 'message'){
                system.debug(node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                //bool = false;
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'Settings'){
                for(Dom.XmlNode connection_node : node.getChildElements()){
                    if(connection_node.getName() == 'BlockSim'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }
                    if(connection_node.getName() == 'BlockOutgoingCalls'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockCallsToInternationalNumbers'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockOutgoingCallsExceptDomestic'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockOutgoingCalls'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockRoaming'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockIncomingCallsWhenRoaming'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockOutgoingCalls'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockDataRoaming'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockInformationNumbers'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    }   
                    if(connection_node.getName() == 'BlockServiceNumbers'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'BlockCallerId'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'BlockCallWaiting'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'BlockCsDataFax'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'BlockVoLte'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'BlockPremiumSms'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'DataRoamingLimitEnabled'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'InternationalCallForwardingEnabled'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                        }
                      }
                    } 
                    if(connection_node.getName() == 'CurrentMonthDataRoamingLimitLifted'){
                      for(Dom.XmlNode child_node : connection_node.getChildElements()){
                        if(child_node.getName() == 'Value'){
                            mapOfFields.put(connection_node.getName(), child_node.getText());
                            bool = false;
                        }
                      }
                    }              
                } 
            }
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }
}