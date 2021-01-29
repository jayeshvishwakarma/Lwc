/**
* @File Name          : LeadHandler.cls
* @Description        : This class is created to convert a lead into oppprtunity.
* @Author             : Shaik Mufiz
* @Last Modified By   : Shaik Mufiz
* @Last Modified On   : 23/10/2020
*==============================================================================
* Ver     Date            Author                    Modification
*==============================================================================
* 1.0    23/10/2020      Shaik Mufiz                Initial Version
**/
public class LeadHandler{
    
    public static void autoLeadConvert(List<Lead> leads, String recordTypeName){
        //Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<LeadStatus> leadStatus = [SELECT Id, MasterLabel, ApiName  FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        if(leadStatus.size() > 0){
            List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
            for(Lead myLead : leads){
                Database.LeadConvert leadConvertObj = new database.LeadConvert();
                leadConvertObj.setLeadId(myLead.Id);
                leadConvertObj.setConvertedStatus(leadStatus[0].ApiName);
                leadConverts.add(leadConvertObj);
            }
            if(!leadConverts.isEmpty()){
                try{
                    List<Database.LeadConvertResult> leadConvertedRecords = Database.convertLead(leadConverts);
                    Set<Id> resultIds = new Set<Id>();
                    for(Database.LeadConvertResult obj : leadConvertedRecords){
                        if(obj.isSuccess())
                            resultIds.add(obj.getLeadId());
                        else{
                            System.debug('error : '+ obj.getErrors());
                        }
                    }
                    System.debug('resultIds : '+resultIds.size());
                    /*if(resultIds.size() > 0){
                        DateTime currentTime = System.now();
                        currentTime = currentTime.addMinutes(5);
                        String hour = String.valueOf(currentTime.hour());
                        String min = String.valueOf(currentTime.minute()); 
                        String sec = String.valueOf(currentTime.second());
                        
                        UpdateLeadScheduler updateLeadSchObj = new UpdateLeadScheduler(resultIds);
                        String cronExp = sec + ' ' + min + ' ' + hour + ' * * ?';
                        System.schedule('Execute apex job at '+ String.valueOf(Datetime.now()), cronExp, updateLeadSchObj);
                    }*/
                }catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }                
            } 
        }
    }
    /*public static void updateLeadStatus(List<Lead> leads, Map<Id, Lead> oldMap){
        for(Lead obj : leads){
            Lead oldLead = oldMap.get(obj.Id);
            if(obj.Purchase_Interest__c != oldLead.Purchase_Interest__c){
                if(obj.Purchase_Interest__c == '1-2 months' || obj.Purchase_Interest__c == '2-3 months'){
                    obj.Status = 'Follow Up';
                }else if(obj.Purchase_Interest__c == 'After 3 months'){
                    obj.Status = 'Converted_Lost';
                }else if(obj.Purchase_Interest__c == '<= 1 month'){
                    obj.Enq_Mode__c = 'BAN'; // BAN => Telephone
                }
            }
        }
    }
    public static void updateDefaultValues(List<Lead> leads){
        for(Lead obj : leads){
            obj.LeadSource = 'CRM';
            if(String.isBlank(obj.Interested_in_New_Car__c))
                obj.Interested_in_New_Car__c = 'No';
        }
    }

    public static void updateColorOnLeads(list<Lead> leadlist, Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap, boolean isInsert){

        list<Lead> listIterator = new list<Lead>();

        if(isInsert){
            listIterator = leadlist;
        }else{
            listIterator = newLeadMap.values();
        }

        list<Id> ProductIDs = new list<Id> ();
        map<id,Product2> productMap = new map<id,Product2>();

        for(Lead aCRM :listIterator){
            if((isInsert)&& (aCRM.Variant__c != null)){
                ProductIDs.add(aCRM.Variant__c);
            }else if((!isInsert) && (aCRM.Variant__c != null) && (oldLeadMap.get(aCRM.Id).Variant__c != aCRM.Variant__c) && (aCRM.Color__c == null)){ 
                ProductIDs.add(aCRM.Variant__c);
            }
        }

        if(ProductIDs.size() > 0){
            productMap = new map<id,Product2>([Select Id, (Select Id from Color_Variant_Masters__r limit 1) from product2 where Id IN:ProductIDs]);

            for(Lead aCRM :listIterator){

                if(aCRM.Variant__c != null){
                    aCRM.Color__c = productMap.get(aCRM.Variant__c).Color_Variant_Masters__r[0].Id;
                }
            }
        }
    }

    public static void populateLookupValue(List<Lead> leads, Map<Id, Lead> oldMap){
        Map<String, Lead> productCodeWithLeadMap = new Map<String, Lead>();
        Map<String, Lead> productIdWithLeadMap = new Map<String, Lead>();
        for(Lead obj : leads){
            Lead oldLead = oldMap.get(obj.Id);
            // Populate Product lookup based on product code
            // Mule will provide product instead of product id
            if(oldLead.Variant_Code__c != obj.Variant_Code__c && String.isNotBlank(obj.Variant_Code__c)){
                productCodeWithLeadMap.put(obj.Variant_Code__c, obj);
            }
            if(oldLead.Enq_Mode__c != obj.Enq_Mode__c && obj.Enq_Mode__c == 'MKTC' && String.isNotBlank(obj.Variant__c) && String.isBlank(obj.Color__c)){
                productIdWithLeadMap.put(obj.Variant__c, obj);
            }
        }
        if(productCodeWithLeadMap.size() > 0)
            populateVariantLookup(productCodeWithLeadMap);
        // Color populate to convert lead for Marketing cloud
        if(productIdWithLeadMap.size() > 0)
            populateVariantLookup(productIdWithLeadMap);
    }
    private static void populateVariantLookup(Map<String, Lead> productCodeWithLeadMap){
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 productObj : [Select Id, ProductCode from product2 where RecordType.DeveloperName = 'Variants' AND ProductCode IN: productCodeWithLeadMap.keySet()]){
            productMap.put(productObj.ProductCode, productObj);
        }
        if(productMap.size() > 0){
            for(Lead leadObj : productCodeWithLeadMap.values()){
                if(productMap.containsKey(leadObj.Variant_Code__c)){
                    Product2 product = productMap.get(leadObj.Variant_Code__c);
                    leadObj.Variant__c = product.Id;
                }
            }
        }
    }

    private static void populateColorLookup(Map<String, Lead> productIdWithLeadMap){
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 productObj : [Select Id, (Select Id from Color_Variant_Masters__r limit 1) from product2 where Id IN: productIdWithLeadMap.keySet()]){
            productMap.put(productObj.Id, productObj);
        }
        if(productMap.size() > 0){
            for(Lead leadObj : productIdWithLeadMap.values()){
                if(productMap.containsKey(leadObj.Variant__c) && productMap.get(leadObj.Variant__c).Color_Variant_Masters__r.size() > 0){
                    Product2 product = productMap.get(leadObj.Variant__c);
                    leadObj.Color__c = product.Color_Variant_Masters__r[0].Id;
                }
            }
        }
    }*/
}