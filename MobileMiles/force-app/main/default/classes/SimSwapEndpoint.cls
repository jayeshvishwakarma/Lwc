@RestResource(urlMapping='/simswapendpoint/*')
global without sharing class SimSwapEndpoint{ 
    static Map<String,String> mapOfFields = new Map<String,String>();
    Static Boolean bool, bool1;
    Static String status;
    Static Id porteringId;
     
    @HttpPost
    global static void doPost() {
        String parseCode = '';
        String status = '';
        Id porteringId;
        if(!Test.isRunningTest()){
            parseCode = RestContext.request.requestBody.toString();
            //parseCode = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:5490:13424998</transactionID><reference>a6A0E0000005Eln</reference></header><responseData><SimCardSwapResponse_V1><Status><Code>ModifyPending</Code></Status><OrderId>4513833</OrderId><ICCId>85114113</ICCId></SimCardSwapResponse_V1></responseData></grexxResponse></soap:Body></soap:Envelope>';
            //system.debug('@@@@ aslam-' + RestContext.request.requestBody.toString() );
        } else {
            parseCode = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:5490:13424998</transactionID><reference>a6A2o0000008VmSEAU</reference></header><responseData><SimCardSwapResponse_V1><Status><Code>ModifyPending</Code></Status><OrderId>4513833</OrderId><ICCId>85114113</ICCId></SimCardSwapResponse_V1></responseData></grexxResponse></soap:Body></soap:Envelope>';
        }
        
        
         if(String.isNotBlank(parseCode)){
               Dom.Document doc = new Dom.Document();
               try{
                   doc.load(parseCode);
               }catch(Exception ee){
                   system.debug(ee.getMessage());
               }
               
               if(doc.getRootElement()!=NULL){
                   Dom.XmlNode root = doc.getRootElement();
                   parseXML(root);
                   
                   System.debug('Map Of Fields '+ mapOfFields);
                   for(String key : MapOfFields.keySet()){
                       if(key == 'reference'){
                           porteringId = mapOfFields.get(key);
                       }
                       if(key == 'Code'){
                           status = mapOfFields.get(key);
                       }
                    }
                    if(porteringId != null){
                        list<Porteringen_mobiel__c> portering = [Select id, Sim_Swap_Status__c from Porteringen_mobiel__c where id =: porteringId];
                        if(!portering.isEmpty()){
                            portering[0].Sim_Swap_Status__c = Status ;
                            system.debug('portering rec - '+portering[0]);
                            update portering;
                        }
                    }
                }
          }
    }    
    
     private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug(node.getName()); 
            if(node.getName() == 'reference'){
                mapOfFields.put(node.getName(), node.getText());
                bool = false;
            }
            if(node.getName() == 'Code'){
                mapOfFields.put(node.getName(), node.getText());
                bool1 = false;
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false || bool1 != false){
                parseXML(child);    
            }
            
        }
        
    }
}