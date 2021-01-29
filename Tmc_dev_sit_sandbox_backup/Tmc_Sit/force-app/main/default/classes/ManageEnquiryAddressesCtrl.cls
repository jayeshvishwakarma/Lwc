/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Manage Enquiry Addresses Controller

History
Date            Author             Comments
--------------------------------------------------------------------------------------
26-11-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
public with sharing class ManageEnquiryAddressesCtrl {

    @AuraEnabled(Cacheable = true)
    public static List<Field> getEnquiryAddressFields(String fieldSetName, String objectName){
        /*
        * Added By - Anuj (Techmatrix)
        * Changed on - 09-July-2020
        * Description - As part of commercial development need different fields.
        * Type of fix - Production
        */
        string currentUserChannel = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()].Channel__c;

        if(fieldSetName == 'BillTo' && currentUserChannel == 'Commercial'){
            fieldSetName = 'Commercial_Bill_To';
        }
        List<Field> fields = new List<Field>();
        Schema.FieldSet fs;
        if(objectName == 'Opportunity'){
            fs = Schema.SObjectType.Opportunity.fieldSets.getMap().get(fieldSetName);
        }else if(objectName=='Survey_Taker_CTI__c'){
            fs = Schema.SObjectType.Survey_Taker_CTI__c.fieldSets.getMap().get(fieldSetName);
        }
        if(fs != null){
            for(Schema.FieldSetMember fsm : fs.getFields()){
                fields.add(new Field(fsm));
            }
        }
        return fields;
    }

    @AuraEnabled
    public static Boolean validateDependencies(String city, String state, String pincode){
        if(String.isNotBlank(pincode)){
            List<Pincode__c> pincodeRecords = [SELECT City__c, State__c FROM Pincode__c WHERE Id =: pincode LIMIT 1];
            if(!pincodeRecords.isEmpty() && pincodeRecords[0].City__c == city){
                List<City__c> cityRecords = [SELECT State__c FROM City__c WHERE Id =: city LIMIT 1];
                if(!cityRecords.isEmpty() && cityRecords[0].State__c == state){
                    return true;
                }
            }
        }
        return false;
    }

    private static String BASE_QUERY = 'FIND {0} IN NAME FIELDS RETURNING {1}(Id, Name, {2} WHERE Name Like {3} LIMIT 200)';

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getPincodeSearchResults(String objectName, String searchTerm) {
        List<Pincode__c> records = (List<Pincode__c>) getSearchResults(objectName, searchTerm, 'City__r.Name, City__r.State__c');
        system.debug('===>'+records);
        // Prepare results
        List<Map<String, String>> results = new List<Map<String, String>>();
        for (Pincode__c record : records) {
            Map<String, String> result = new Map<String, String>{
                'id' => record.Id,
                'title' => record.Name
            };
            if(record.City__r != null){
                result.put('city', record.City__r.Id);
                result.put('city_name', record.City__r.Name);
                result.put('state', record.City__r.State__c);
            }
            results.add(result);
        }
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getCitySearchResults(String objectName, String searchTerm) {
        List<City__c> records = (List<City__c>) getSearchResults(objectName, searchTerm, 'State__c');
        // Prepare results
        List<Map<String, String>> results = new List<Map<String, String>>();
        for (City__c record : records) {
            Map<String, String> result = new Map<String, String>{
                'id' => record.Id,
                'title' => record.Name,
                'state' => record.State__c
            };
            results.add(result);
        }
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getVillageSearchResults(String objectName, String searchTerm) {
        List<Village__c> records = (List<Village__c>) getSearchResults(objectName, searchTerm, 'Tehsil__r.Name, Tehsil__r.District__c');
        // Prepare results
        List<Map<String, String>> results = new List<Map<String, String>>();
        for (Village__c record : records) {
            Map<String, String> result = new Map<String, String>{
                'id' => record.Id,
                'title' => record.Name
            };
            if(record.Tehsil__r != null){
                result.put('tehsil', record.Tehsil__r.Id);
                result.put('tehsil_name', record.Tehsil__r.Name);
                result.put('district', record.Tehsil__r.District__c);
            }
            results.add(result);
        }
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getTehsilSearchResults(String objectName, String searchTerm) {
        List<Tehsil__c> records = (List<Tehsil__c>) getSearchResults(objectName, searchTerm, 'District__c');
        // Prepare results
        List<Map<String, String>> results = new List<Map<String, String>>();
        for (Tehsil__c record : records) {
            Map<String, String> result = new Map<String, String>{
                'id' => record.Id,
                'title' => record.Name,
                'district' => record.District__c
            };
            results.add(result);
        }
        return results;
    }

    private static List<SObject> getSearchResults(String objectName, String searchTerm, String otherFields){
        List<Object> formatOptions = new List<Object>{ '\'' + searchTerm + '*\'', objectName, otherFields, '\'%' + searchTerm + '%\'' };
        return Search.query(String.format(BASE_QUERY, formatOptions)).get(0);
    }

    public class Field{
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public String referenceTo;
        @AuraEnabled public Boolean required;
        @AuraEnabled public Boolean isTextField;
        @AuraEnabled public Integer length;

        public Field(Schema.FieldSetMember fsm){
            name = fsm.getFieldPath();
            label = fsm.getLabel();
            required = fsm.getRequired();
            type = getType(fsm);
        }

        private String getType(Schema.FieldSetMember fsm){
            Schema.DescribeFieldResult dfr = fsm.getSObjectField().getDescribe();
            for(Schema.SObjectType reference : dfr.getReferenceTo()) {
                referenceTo = reference.getDescribe().getName();
                if(reference == City__c.getSObjectType()){
                    return 'city';
                } else if(reference == Pincode__c.getSObjectType()){
                    return 'pincode';
                } else if(reference == Village__c.getSObjectType()){
                    return 'village';
                } else if(reference == Tehsil__c.getSObjectType()){
                    return 'tehsil';
                }
            }
            if(name.endsWithIgnoreCase('State__c')){
                return 'state';
            } else if(name.endsWithIgnoreCase('District__c')){
                return 'district';
            } else if(name.endsWithIgnoreCase('Doc_Type__c')){
                return 'docType';
            } else if(name.endsWithIgnoreCase('Reference_Number__c')){
                return 'refNumber';
            } else if(name.endsWithIgnoreCase('Bill_To_GST__c')){
                return 'billToGST';
            } else if(name.endsWithIgnoreCase('Ship_To_GST__c')){
                return 'shipToGST';
            }
            if(dfr.getType().equals(Schema.DisplayType.STRING)){
                isTextField = true;
                length = dfr.getLength();
            }
            return null;
        }
    }
}