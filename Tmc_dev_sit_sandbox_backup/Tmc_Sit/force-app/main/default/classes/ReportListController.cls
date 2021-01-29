/**
* @File Name          : ReportListController.cls
* @Description        : Class is used to show reports via quicklink as Utility bar
* @Author             :
* @Group              :
* @Last Modified By   : Prashant Gahlaut
* @Last Modified On   : 13/11/2020, 11:29:29 AM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    13/11/2020, 11:29:29 AM    Prashant Gahlaut          Initial Version
**/
public class ReportListController {
    //This method is used to fetch custom setting and model global picklist data for report links
    @AuraEnabled
    public static wrapper fetchData(){
        wrapper wrpObj = new wrapper();
        //fetching values from custom setting
        wrpObj.reportList = ATM_Utility_Bar_Quick_Links__c.getall().values();
        //fetching the picklist value from Model_Code__c from opportunity 
        Schema.DescribeFieldResult fieldResult = Opportunity.Model_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            wrpObj.picklistValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
            System.debug('Values in Rating are: '+wrpObj.picklistValuesMap);
        }
        System.debug('wrpObj'+wrpObj);
        return wrpObj;
    }
    //for searching city
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%' +searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name,For_Code__c from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    //for searching Variants
    @AuraEnabled
    public static List < sObject > fetchProductLookUpValues(String searchKeyWord, String ObjectName, string modelCode) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%' +searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        if(String.isNotBlank(modelCode)){
            String sQuery =  'select id, Name,Variant_Code__c from ' +ObjectName + ' where Name LIKE: searchKey AND RecordType.Name = \'Variants\' AND Model__c =\''+ modelCode +'\' order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }  
        }  
        return returnList;
    }
    
    public class wrapper{
        @auraEnabled public map<String,string> picklistValuesMap {get;set;}
        @auraEnabled public List<ATM_Utility_Bar_Quick_Links__c> reportList{get;set;}
        
        public wrapper(){
            picklistValuesMap = new Map<string,string>();
            reportList = new List<ATM_Utility_Bar_Quick_Links__c>();
        }
    }
}