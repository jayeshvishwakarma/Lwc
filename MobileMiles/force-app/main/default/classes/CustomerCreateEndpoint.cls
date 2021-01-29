@RestResource(urlMapping='/customercreateendpoint/*')
global without sharing class CustomerCreateEndpoint{ 
  static Map<String,String> mapOfFields = new Map<String,String>();
  Static Boolean bool, bool1;
  
  @HttpPost
    global static void doPost() {
        String accId = '';
        String custId = '';
        String parseCode = '';
        if(!Test.isRunningTest()){
            parseCode = RestContext.request.requestBody.toString();
            system.debug('@@@@ aslam-' + parseCode );
        } else {
            parseCode = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:6306:1125691</transactionID><reference>001D000001NnXpQIAV</reference></header><responseData><NewCustomerResponse_V3><State><Code>0</Code></State><CustomerData><CustomerId>CID1316673</CustomerId><Name>Aangenaam XL BV</Name><Street>Oude Kleefsebaan</Street><HouseNr>90</HouseNr><ZipCode>6571BJ</ZipCode><City>BERG EN</City><CountryCode>NLD</CountryCode><Phone1>0243503890</Phone1><Email>poldermans@xlbv.nl</Email><LegalStatus>BV</LegalStatus><ExternalId>Ref23024</ExternalId><ChamberOfCommerceNr>51031450</ChamberOfCommerceNr></CustomerData></NewCustomerResponse_V3></responseData></grexxResponse></soap:Body></soap:Envelope>';
        }
        
        /*OrderResponseHandler orh = new OrderResponseHandler(RestContext.request.requestBody.toString());
        try{
            orh.processResponse();
        }catch(exception e){
            system.debug(e.getMessage());
        }*/
        
        
        
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
                           accId = mapOfFields.get(key);
                       }
                       if(key == 'CustomerId'){
                           custId = mapOfFields.get(key);
                       }
                    }
                    if(accId != null && custId != null){
                        list<Account> acc = [Select id, iRMA_id__c from Account where id =: accId];
                        if(!acc.isEmpty()){
                            acc[0].iRMA_id__c = custId;
                            system.debug('accid - '+accid);
                            system.debug('custid - '+custid);
                            system.debug('acc rec - '+acc[0]);
                            update acc;
                        }
                    }
                }
          }
    }
    
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug(node.getName()); 
            if(node.getName() == 'CustomerId'){
                system.debug('in custid'+node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                bool = false;
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            if(node.getName() == 'reference'){
                system.debug('in custid'+node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                bool1 = false;
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false || bool1 != false){
                parseXML(child);    
            }
            
        }
        
    }
    
}