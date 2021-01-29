/**
* @File Name          : DefaultProductCreationScript.cls
* @Description        : Class to create default product records in the org
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 10/25/2019, 17:24:21 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    10/25/2019, 17:24:21 PM                              Initial Version
**/
public class DefaultProductCreationScript {
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create default product records after taking from metadata
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     10/25/2019  Prabhat Sharma  Initial Version
    **/
    
    public static void createDefaultProductsRecord(){
        map<string,String> recordtypeIdMap = new map<string,String>();
        map<string,Default_Product_Records__mdt > producMdtMap = new map<string,Default_Product_Records__mdt >();
        List<PriceBookEntry> pbeToInsert = new list<PriceBookEntry>();
        List<Product2> productToInsert = new list<Product2>();
        
        //Loop thorugh metadata to get the list of product record types in a map
        for(Default_Product_Records__mdt  prod : [SELECT RecordType_Name__c,Unit_Price__c from Default_Product_Records__mdt  ]){
            recordtypeIdMap.put(prod.RecordType_Name__c,'');
        }
        
        //Create a Map of record type name and record type Id
        if(recordtypeIdMap.keySet().size()>0){
            for(String str : recordtypeIdMap.keySet()){
                String recordtypeId =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get(str).getRecordTypeId();
                recordtypeIdMap.put(str,recordtypeId);
            }
        }   
        
        //Loop through metadata to create the product records
        for(Default_Product_Records__mdt  prod : [SELECT MasterLabel,RecordType_Name__c,Unit_Price__c from Default_Product_Records__mdt]){
            
            Product2 productObj = new Product2();
            productObj.RecordTypeId = recordtypeIdMap.get(prod.RecordType_Name__c);
            productObj.Name = prod.MasterLabel;
            productObj.Fuel_Type__c =ConstantsUtility.FUEL_TYPE; //Setting this with default values as required on field level
            productObj.Channel__c = ConstantsUtility.CHANNEL_TYPE; //Setting this with default values as required on field level
            productObj.Start_Date__c = ConstantsUtility.START_DATE; //Setting this with default values as required on field level
            productObj.End_Date__c = ConstantsUtility.END_DATE; //Setting this with default values as required on field level
            productObj.Model__c = ConstantsUtility.MODEL; //Setting this with default values as required on field level
            productToInsert.add(productObj);
            
            producMdtMap.put(prod.MasterLabel,prod);
        }
        
        //Insert Product records
        if(productToInsert.size()>0) 
            insert productToInsert;
        
        
        //Get standard Pricebook Id from Custom Setting
        String pricebook2Id = '';
        StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance();        
        if (lsPB != null){
            pricebook2Id = lsPB.PriceBookId__c;
        }
        
        //Loop thorugh all the Products created
        if(productToInsert.size()>0){
            for(Product2 prod : productToInsert){
                PricebookEntry pbe = new PricebookEntry();
                pbe.Pricebook2Id = pricebook2Id;
                pbe.Product2Id = prod.Id;
                pbe.UnitPrice = producMdtMap.get(prod.Name).Unit_Price__c;
                pbeToInsert.add(pbe);
            }
        }
        
        //Create Pricebook Entries
        if(pbeToInsert.size()>0)
            insert pbeToInsert;
    }

}