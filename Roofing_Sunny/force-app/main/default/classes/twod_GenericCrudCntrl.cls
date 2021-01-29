global with sharing class twod_GenericCrudCntrl{
    
    /*
    * To read records with query
    */ 
    @AuraEnabled
    public static OutputWrapper ReadSObjects(String query){
        OutputWrapper wrapObj = new OutputWrapper();
        String sObjectApiName='';
        String sObjectLabel='';
        Boolean success = false;
        List<SObject> sObjList = new List<SObject>();
        
        try{
            sObjList = Database.query(query);
            if(!sObjList.isEmpty()){
                SObjectType type=sObjList[0].getSObjectType();
                Schema.DescribeSObjectResult sobjectDescribe=type.getDescribe();
                sObjectApiName=String.valueof(sObjList[0].getSObjectType());
                sObjectLabel=sobjectDescribe.label;
                success = true;
            }
            wrapObj.sObjList = sObjList;
            wrapObj.sObjectLabel = sObjectLabel;
            wrapObj.sObjectApiName=sObjectApiName;
            wrapObj.success = success;
            
        }Catch(Exception e){
            wrapObj.sObjList = null; wrapObj.sObjectLabel = null; wrapObj.sObjectApiName=null; wrapObj.success = success;
        }
        return wrapObj;
    }
    
    /*
    * To insert records with sObject list
    */
    @AuraEnabled
    public static List<DMLOutputWrapper> InsertSObjects( List<SObject> inputSObjectList){
        
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        Boolean success = TRUE;
        Set <Id> idSet = new Set<Id>();
        Id sObjID = null ;
        Database.SaveResult[] srList = Database.insert(inputSObjectList, false);
        for(Database.SaveResult sr : srList){
            DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
            List<String> errorCodeList = new List<String>();
            success = TRUE;
            if(sr.isSuccess()){
                sObjID = sr.getId();
                idSet.add(sObjID );
            }
            else{
                success = FALSE;
                sObjID = null;
                for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                }
            }
            wrapDMLObj.sObjID = sObjID;
            wrapDMLObj.success = success;
            wrapDMLObj.errorCodeList =errorCodeList;
            wrapDMLObjList.add(wrapDMLObj);
            
        }
        
        return wrapDMLObjList;
    }
    
    /*
    * To update records with sObject list
    */
    @AuraEnabled
    public static List<DMLOutputWrapper> UpdateSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        Set <Id> idSet = new Set<Id>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        
        Database.SaveResult[] srList = Database.update(inputSObjectList, false);
        
        for(Database.SaveResult sr : srList){
            DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
            List<String> errorCodeList = new List<String>();
            success = TRUE;
            if(sr.isSuccess()){
                sObjID = sr.getId();
                idSet.add(sObjID );
            }
            else{
                success = FALSE;
                sObjID = null;
                for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                }
            }
            wrapDMLObj.sObjID = sObjID;
            wrapDMLObj.success = success;
            wrapDMLObj.errorCodeList =errorCodeList;
            wrapDMLObjList.add(wrapDMLObj);
        }
        return wrapDMLObjList;
    }
    
    
    /****************************to work on ******************************************************/
    /*
    * To update records forcefully if they are locked with sObject list
    */
    @AuraEnabled
    public static List<twod_GenericForceCntrl.DMLOutputLockWrapper> UpdateForceSObjects( List<SObject> inputSObjectList){
        
        List<twod_GenericForceCntrl.DMLOutputLockWrapper> wrapDMLObjList = twod_GenericForceCntrl.UpdateForceSObjects(inputSObjectList);
        return wrapDMLObjList;
    }
    /****************************to work on ******************************************************/
    
    
    /*
    * To delete records with Id list
    */
    @AuraEnabled
    public static List<DMLOutputWrapper> DeleteSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        Database.DeleteResult[] srList = Database.delete(inputSObjectList,false);
        
        for(Database.DeleteResult sr : srList){
            errorCodeList = new List<String>();
            DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
            success = TRUE;
            
            
            if(sr.isSuccess()){
                sObjID = sr.getId();
            }
            else{
                success = FALSE;
                for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                }
            }
            wrapDMLObj.sObjID = sObjID;
            wrapDMLObj.success = success;
            wrapDMLObj.errorCodeList =errorCodeList;
            wrapDMLObjList.add(wrapDMLObj);
        }
        return wrapDMLObjList;
    }
    
    // To get the record count in the report
    @AuraEnabled
    public static Integer totalRecordsCount(String reportId){        
        // Run a report synchronously
        Integer recordCount = 0; return recordCount;
    }
    
    public class OutputWrapper{
        @AuraEnabled
        public List<SObject> sObjList;
        @AuraEnabled
        public String sObjectLabel;
        @AuraEnabled
        public String sObjectApiName;
        @AuraEnabled
        public Boolean success;
        
    }
    
    public class DMLOutputWrapper{
        
        @AuraEnabled
        public Id sObjID;
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public List<String> errorCodeList ;
        @AuraEnabled
        public sObject record ;
    }
    
}