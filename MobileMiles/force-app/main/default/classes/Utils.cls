public without sharing class Utils {
    public static sObject getOne(List<sObject> objects) {
        return getOne(objects, 'No message');
    }
    
    public static sObject getOne(List<sObject> objects, String messageIfNotFound) {
        if (objects.size() == 1) {
            return objects.get(0);
        } else if (objects.isEmpty()) {
            throw new AppException('List is empty but should contain exactly one object: '+ messageIfNotFound);
            return null;
        } else {
            throw new AppException('List has ' + objects.size() + ' elements but should contain exactly one object: ' + objects + ': ' + messageIfNotFound);
            return null;
        }
    }
    
    public static sObject getOneOrNull(List<sObject> objects) {
        return getOneOrNull(objects, 'No message');
    }

    public static sObject getOneOrNull(List<sObject> objects, String messageIfNotFound) {
        if (objects.size() == 1) {
            return objects.get(0);
        } else if (objects.isEmpty()) {
            return null;
        } else {
            throw new AppException('List has ' + objects.size() + ' elements but should contain exactly one object: ' + objects + ': ' + messageIfNotFound);
            return null;
        }
    }

/*
    
    // get all the fields of an sObject in a map<fieldName,fieldLabel>
    public static Map<String, Schema.SObjectField> getsObjectFieldMap(id objectId) {
        return getsObjectFieldMap(objectId.getsObjectType().getDescribe().getName());
    }
    
    public static Map<String, Schema.SObjectField> getsObjectFieldMap(string objectName) {
         return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
    }


    // Usage: recordTypeId(Schema.Sobjecttype.Invoice__c, 'recordtypename');
    public static ID recordTypeId(Schema.DescribeSObjectResult o, String name) {
        RecordTypeinfo rt = o.getRecordTypeInfosByName().get(name);
        System.assertNotEquals(null, rt, 'Kan RecordType ' + name + ' niet vinden voor ' + o.getName() + ': ' + o.getRecordTypeInfosByName());
        return rt.getRecordTypeId();
    }
    

    public static PageReference redirectToViewPage(ID id) {
        PageReference pageRef = new PageReference('/'+id);
        pageRef.setRedirect(true);
        return pageRef; 
    }
*/

    /**
     * @description             get a map of all recordTypes by DeveloperName DeveloperName->recordTypeId
     */
/*
    public static Map<String,Map<String,RecordType>> recordTypeMap {
        get{
            if(recordTypeMap == null){
                recordTypeMap = new Map<String,Map<String,RecordType>>();
                for(RecordType rt : [Select SObjectType, DeveloperName, Id, Name From RecordType]){
                    Map<String,RecordType> tempMap = new Map<String,RecordType>(); 
                    if(recordTypeMap.containsKey(rt.SObjectType)){
                        tempMap = recordTypeMap.get(rt.SObjectType);
                    }
                    tempMap.put(rt.DeveloperName,rt);
                    recordTypeMap.put(rt.SObjectType,tempMap);
                }               
            } 
            return recordTypeMap;
        }
        private set;
    }

    public static Map<String,Map<String,Id>> recordTypeMapbyName {
        get{
            if(recordTypeMapbyName == null){
                recordTypeMapbyName = new Map<String,Map<String,Id>>();
                for(RecordType rt : [Select SObjectType, Name, Id From RecordType]){
                    Map<String,Id> tempMap = new Map<String,Id>(); 
                    if(recordTypeMapbyName.containsKey(rt.SObjectType)){
                        tempMap = recordTypeMapbyName.get(rt.SObjectType);
                    }
                    tempMap.put(rt.Name,rt.Id);
                    system.debug(rt.name);
                    recordTypeMapbyName.put(rt.SObjectType,tempMap);
                }               
            } 
            return recordTypeMapbyName;
        }
        private set;
    }
    
    public static list<string> getPicklistValues(String table,String field) {
        list<String> returnvalues = new list<string>();
        
        Set<String> fields = new Set<String>();
        fields.add(field);
        Schema.SObjectType s = Schema.getGlobalDescribe().get(table) ;
        Map<String, Schema.DescribeFieldResult> finalMap =  Utils.getFieldMetaData(s.getDescribe(), fields);
        List<Schema.PicklistEntry> ple = finalMap.get(field).getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            returnvalues.add(f.getValue());
        }
        return returnvalues;
     }
     
    public static Map<String, Schema.DescribeFieldResult> getFieldMetaData(Schema.DescribeSObjectResult dsor, Set<String> fields) {
     
      // the map to be returned with the final data
      Map<String,Schema.DescribeFieldResult> finalMap = 
        new Map<String, Schema.DescribeFieldResult>();
      // map of all fields in the object
      Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
     
      // iterate over the requested fields and get the describe info for each one. 
      // add it to a map with field name as key
      for(String field : fields){
        // skip fields that are not part of the object
        if (objectFields.containsKey(field)) {
          Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
          // add the results to the map to be returned
          finalMap.put(field, dr); 
        }
      }
      return finalMap;
    }
    */
}