/**************************************************
Name :Shashikanth Vattam
Date :19/12/2019
Purpose: Exposing Contacts information thru RestService
Associated coonected App:   RestServices_Contact
Test Class Name :Test_PriceFx
****************************************************/

@RestResource(urlMapping='/api/PriceFx/*')
global with sharing class PriceFx{
@HttpGet
    global static List<AccountContactRelation> doGetContactRelation() 
    {   
     RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String AccNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        list<AccountContactRelation> relatedcontacts = new List<AccountContactRelation>();
        
        list<AccountContactRelation> conRelation1 =[select id ,Account.name,contact.Firstname,IsDirect,contact.LastName,contact.email,Account.LOB__c,AccountId,Account.Hierarchy_Level_BPCS__c,Account.SAP_ACCOUNT__c from AccountContactRelation where ( (IsDirect = true or IsDirect = false ) and (Account.RecordType.Name IN ('Sold-To','Ship-To','Payer','Indirect Accounts') )and (Account.Hierarchy_Level_BPCS__c!='')and (Account.SAP_ACCOUNT__c LIKE '1%' )  )];
            
            list<AccountContactRelation> conRelation2 =[select id ,Account.name,contact.Firstname,IsDirect,contact.LastName,contact.email,Account.LOB__c,AccountId,Account.Hierarchy_Level_BPCS__c,Account.SAP_ACCOUNT__c from AccountContactRelation where ( (IsDirect = true or IsDirect = false ) and (Account.RecordType.Name IN ('Sold-To','Ship-To','Payer','Indirect Accounts') )and (Account.Hierarchy_Level_BPCS__c!='')and (Account.SAP_ACCOUNT__c LIKE '2%' )  )];
             
             list<AccountContactRelation> conRelation3 =[select id ,Account.name,contact.Firstname,IsDirect,contact.LastName,contact.email,Account.LOB__c,AccountId,Account.Hierarchy_Level_BPCS__c,Account.SAP_ACCOUNT__c from AccountContactRelation where ( (IsDirect = true or IsDirect = false ) and (Account.RecordType.Name IN ('Sold-To','Ship-To','Payer','Indirect Accounts') )and (Account.Hierarchy_Level_BPCS__c!='')and (Account.SAP_ACCOUNT__c LIKE '3%' )  )];
 
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
           accConList.addAll(conRelation1);
           accConList.addAll(conRelation2);
           accConList.addAll(conRelation3);
          system.debug('accConList count'+accConList.size()); 
          
          
          for( AccountContactRelation acr :accConList)
         {
         
         relatedcontacts.add(acr);
         }
         
         system.debug('relatedcontacts'+relatedcontacts);
         
         return relatedcontacts;
    }
}