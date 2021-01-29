public without sharing class OrderResponseHandler{
    
    OrderControlStatus ord;
    
    public OrderResponseHandler(String XMLString){        
        DOM.Document doc=new DOM.Document();
        try{
            doc.load(XMLString);
            DOM.XmlNode statusUpdate =doc.getRootElement().getChildElement('StatusUpdate', null);
            String extId = statusUpdate.getChildElement('ExternalOrderId',null).getText();                       
            String irmaClientId = statusUpdate.getChildElement('Client', null).getChildElement('IrmaClientId',null).getText();
            String clientStatusCode = statusUpdate.getChildElement('Client', null).getChildElement('ClientStatusCode',null).getText();
            String extProdId = statusUpdate.getChildElement('Product', null).getChildElement('ExternalProductId',null).getText();
            String irmaOrderId = statusUpdate.getChildElement('Product', null).getChildElement('IrmaOrderId',null).getText();
            String orderStatusCode = statusUpdate.getChildElement('Product', null).getChildElement('OrderStatusCode',null).getText();
            DateTime FirstPossiblePortingDate;
            if(XMLString.contains('FirstPossiblePortingDate')){
                String firstPossibleDtstr = statusUpdate.getChildElement('Product', null).getChildElement('FirstPossiblePortingDate',null).getText();
                if(String.isNotBlank(firstPossibleDtstr)){
                    firstPossibleDtstr= firstPossibleDtstr.left(10);
                    List<String> firstPossibleDt = firstPossibleDtstr.split('-');                                    
                    FirstPossiblePortingDate = DateTime.newInstanceGmt(Integer.valueOf(firstPossibleDt.get(0)),
                                             Integer.valueOf(firstPossibleDt.get(1)),
                                             Integer.valueOf(firstPossibleDt.get(2)));
                }
            }
            
            DateTime PlannedPortingDate ;
            if(XMLString.contains('PlannedPortingDate')){
                String PlannedPortingStr = statusUpdate.getChildElement('Product', null).getChildElement('PlannedPortingDate',null).getText();
                if(String.isNotBlank(PlannedPortingStr)){
                    PlannedPortingStr = PlannedPortingStr.left(10);
                    List<String> PlannedPortingDt = PlannedPortingStr.split('-');                                    
                    PlannedPortingDate = DateTime.newInstanceGmt(Integer.valueOf(PlannedPortingDt.get(0)),
                                                         Integer.valueOf(PlannedPortingDt.get(1)),
                                                         Integer.valueOf(PlannedPortingDt.get(2)));
                }
            } 
            String PortingState = XMLString.contains('PortingState') ? statusUpdate.getChildElement('Product', null).getChildElement('PortingState',null).getText() : '';
            String PhoneNumber = XMLString.contains('PhoneNumber') ? statusUpdate.getChildElement('Product', null).getChildElement('PhoneNumber',null).getText() : '';
           /* if(String.isNotBlank(PhoneNumber) && PhoneNumber.length() == 10)
                PhoneNumber = PhoneNumber.right(8);
            else if(String.isNotBlank(PhoneNumber) && PhoneNumber.length() == 12)
                PhoneNumber = PhoneNumber.right(9);*/
            ord = new OrderControlStatus(extId, irmaClientId, clientStatusCode, extProdId, irmaOrderId, orderStatusCode,FirstPossiblePortingDate, PlannedPortingDate, PortingState, PhoneNumber);
            
                                                                                               
        }catch(exception e){
            system.debug(e.getMessage());
        }
    }    
    public void processResponse(){
        //Check Quote to update GREXX Status            
            List<Quote> quote = new List<Quote>([select id, GREXX_status_update__c, accountid, account.iRMA_id__c from Quote where id =: ord.externalOrderId]);
            if(quote != null && quote.size() > 0){
                if(quote[0].GREXX_status_update__c != ord.clientStatusCode){
                    quote[0].GREXX_status_update__c = ord.clientStatusCode;
                    Database.update(quote[0], false);
                }
                //Check Account to update IRMA ID
                if(quote[0].accountid != null && quote[0].account.iRMA_id__c == null){
                    Account acc = new Account(id = quote[0].accountid, iRMA_id__c = ord.irmaClientId);
                    Database.update(acc, false);
                }
                //Check Porteringen_mobiel__c to update GREXX Status and IRMA ID
                List<Porteringen_mobiel__c> portMobile = new List<Porteringen_mobiel__c>([select id, GREXX_status_update__c,  
                                                                                          iRMA_id__c, Geplande_porteerdatum__c,
                                                                                          Eerst_mogelijke_porteerdatum__c ,
                                                                                          Porteerstatus__c,Name
                                                                                           from Porteringen_mobiel__c 
                                                                                          where id =: ord.externalProductId]);
                if(portMobile != null && portMobile.size() > 0){
                    //if(portMobile[0].iRMA_id__c != ord.irmaOrderId || portMobile[0].GREXX_status_update__c != ord.orderStatusCode){
                    if(ord.irmaOrderId != null){
                        portMobile[0].iRMA_id__c = ord.irmaOrderId;
                    }    
                    if(ord.orderStatusCode != null){                       
                        portMobile[0].GREXX_status_update__c = ord.orderStatusCode;
                    }
                    if(ord.FirstPossiblePortingDate != null){
                        portMobile[0].Eerst_mogelijke_porteerdatum__c = ord.FirstPossiblePortingDate;
                    }    
                    if(ord.PlannedPortingDate != null){                       
                        portMobile[0].Geplande_porteerdatum__c = ord.PlannedPortingDate;
                        portMobile[0].Datum_actief__c = Date.valueOf(ord.PlannedPortingDate);
                    }    
                    if(ord.PortingState != null){
                        portMobile[0].Porteerstatus__c = ord.PortingState;
                    }    
                    if(ord.PhoneNumber != null){                       
                        portMobile[0].GREXX_Phone_Number__c = ord.PhoneNumber;
                    }
                    system.debug('@@@@ '+portMobile[0]);
                    Database.update(portMobile[0], false);
                        
                }
                //Check Mobiel_module__c to update GREXX Status and IRMA ID
                List<Mobiel_module__c> mobileModule = new List<Mobiel_module__c>([select id, GREXX_status_update__c,  
                                                                                          iRMA_id__c from Mobiel_module__c
                                                                                          where id =: ord.externalProductId]);
                if(mobileModule != null && mobileModule.size() > 0){
                    if(mobileModule[0].iRMA_id__c != ord.irmaOrderId || mobileModule[0].GREXX_status_update__c != ord.orderStatusCode){
                        mobileModule[0].iRMA_id__c = ord.irmaOrderId;
                        mobileModule[0].GREXX_status_update__c = ord.orderStatusCode;
                        Database.update(mobileModule[0], false);
                    }    
                } 
                //Check voip__c to update GREXX Status and IRMA ID
                List<VoIP__c> voips = new List<VoIP__c>([select id, orderstatuscode__c, iRMA_id__c from VoIP__c
                                                                                          where id =: ord.externalProductId]);
                if(voips != null && voips.size() > 0){
                    if(voips [0].iRMA_id__c != ord.irmaOrderId || voips[0].orderstatuscode__c != ord.orderStatusCode){
                        voips[0].iRMA_id__c = ord.irmaOrderId;
                        voips[0].orderstatuscode__c = ord.orderStatusCode;
                        Database.update(voips[0], false);
                    }    
                }
            }                        
            
            //ranu 20th may 2019
            //Check Porteringen_mobiel__c to update GREXX Status and IRMA ID
            List<Porteringen_mobiel__c> portMobile = new List<Porteringen_mobiel__c>([select id, GREXX_status_update__c,  
                                                                                      iRMA_id__c, Geplande_porteerdatum__c,
                                                                                      Eerst_mogelijke_porteerdatum__c ,
                                                                                      Porteerstatus__c,Name
                                                                                       from Porteringen_mobiel__c 
                                                                                      where id =: ord.externalProductId]); 
                                                                                      
            if(portMobile != null && portMobile.size() > 0){
                //if(portMobile[0].iRMA_id__c != ord.irmaOrderId || portMobile[0].GREXX_status_update__c != ord.orderStatusCode){
                    portMobile[0].iRMA_id__c = ord.irmaOrderId;
                    portMobile[0].GREXX_status_update__c = ord.orderStatusCode;      
                    if(ord.FirstPossiblePortingDate != null){
                        portMobile[0].Eerst_mogelijke_porteerdatum__c = ord.FirstPossiblePortingDate;
                    }    
                    if(ord.PlannedPortingDate != null){                       
                        portMobile[0].Geplande_porteerdatum__c = ord.PlannedPortingDate;
                        portMobile[0].Datum_actief__c = Date.valueOf(ord.PlannedPortingDate);
                    }    
                    if(ord.PortingState != null){
                        portMobile[0].Porteerstatus__c = ord.PortingState;
                    } 
                    if(ord.PhoneNumber != null){                       
                        portMobile[0].GREXX_Phone_Number__c = ord.PhoneNumber;
                    }              
                    system.debug('@@@@ '+portMobile[0]);
                    Database.update(portMobile[0], false);
                //}                    
            }        
            //Check Mobiel_module__c to update GREXX Status and IRMA ID
            List<Mobiel_module__c> mobileModule = new List<Mobiel_module__c>([select id, GREXX_status_update__c,  
                                                                                      iRMA_id__c from Mobiel_module__c
                                                                                      where id =: ord.externalProductId]);
            if(mobileModule != null && mobileModule.size() > 0){
                if(mobileModule[0].iRMA_id__c != ord.irmaOrderId || mobileModule[0].GREXX_status_update__c != ord.orderStatusCode){
                    mobileModule[0].iRMA_id__c = ord.irmaOrderId;
                    mobileModule[0].GREXX_status_update__c = ord.orderStatusCode;
                    Database.update(mobileModule[0], false);
                }    
            }                                                                                
    }
}