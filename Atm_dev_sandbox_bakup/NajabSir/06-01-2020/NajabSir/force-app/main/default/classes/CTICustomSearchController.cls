/**
* @File Name          : CTICustomSearchController.cls
* @Description        : Controller for all Inbound calls landing into Salesforce. This will search all the customer records as well as 
            Contact and User records for MOS related use cases. 
* @Author             : Prabhat Sharma
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 09-18-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    09-18-2020, 9:14:54 PM         Prabhat                Initial Version

**/
global class CTICustomSearchController {
    
    
    
    private static set<String> queriedObjects = new set<String>();
    private static set<String> recordtypes = new set<String>();
    private static map<String,String> fieldToSearch = new map<String,String>();
    private static map<String,String> recordTypesToSearch = new map<String,String>();
    
    
    /*  Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will be called by the CTI before the call lands onto the agent screen. The output of the method can below,
           1) Single Record - Record Id will be returned to the CTI
           2) Multiple records - Salesforce global search page will open
           3) No records found - No action will happen. Same screen will remain as it is. 
        Inputs: Phone number and DNIS Number
        Returns: JSON of Salesforce records with record Ids and name
        History:
        =================
        1.1A     09-18-2020      Sunit     Initial Version
    */
    webService static String searchAccounts(String phoneNumber, String dnis) {
         
        //Variable to store all MOS related objects
        set<String> mosobjectsToSearch = new set<String>();
        //Variable to store all NON MOS related objects
        set<String> nonMosObjectsToSearch = new set<String>();
        
        //This will hold the final JSON that will be returned to the CTI
        String JSONString='';
        
        //Base Query with Record type condition
        String BASE_QUERY_WITHRT = 'FIND {0} IN PHONE FIELDS RETURNING {1}(Id, {2} WHERE Recordtype.DeveloperName IN: recordtypes)';
        //Base Query without Record type condition
        String BASE_QUERY_WITHOUTRT = 'FIND {0} IN PHONE FIELDS RETURNING {1}(Id, {2})';
        
        //Get the objects to search from the Custom Setting
        map<String,CTI_Search_Logic__c> searchSettingMap = CTI_Search_Logic__c.getAll();
        
        //Loop through custom setting to get the MOS and NON MOS Objects
        for(String key : searchSettingMap.keySet()){
            CTI_Search_Logic__c customKey = searchSettingMap.get(key);
            if(customKey.MOS_Non_MOS__c==ConstantsUtility.CASE_TYPE_MOS){
                mosobjectsToSearch.add(customKey.Objects_To_Search__c);
            }
            else{
                nonMosObjectsToSearch.add(customKey.Objects_To_Search__c);
            }
            fieldToSearch.put(customKey.Objects_To_Search__c, customKey.Fields_To_Search__c);
            recordTypesToSearch.put(customKey.Objects_To_Search__c, customKey.RecprdType_To_Search__c);
        }
        
        //Set to store all the MOS DNIS Numbers 
        set<String> mos_dnis_nos = new set<String>();
        mos_dnis_nos.addAll(label.MOS_INBOUND_DNIS_NO.split(',')); 
        
        //If the incoming DNIS is MOS DNIS number, then search all MOS related objects else, search NON MOS objects
        if(mos_dnis_nos.contains(dnis)){
            JSONString = searchObjects(mosobjectsToSearch,phoneNumber,BASE_QUERY_WITHOUTRT);  
        }
        else{
            JSONString = searchObjects(nonMosObjectsToSearch,phoneNumber,BASE_QUERY_WITHRT); 
        } 
         
        return JSONString;
    }
    
    /*  Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create dynamic List of Sobjects 
        Inputs: Phone number and DNIS Number
        Returns: Typecasted list 
        History:
        =================
        1.2     09-18-2020      Sunit     Initial Version
    */
    public static List<sObject> dynmaicsObjectList(String sObjectType){
        String listType = 'List<' + sObjectType + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        
        return castRecords;
    }
    
    /*  Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to run SOSL on sepcified objects until all objects are searched
        Inputs: List of objects to search, Phone number and base query
        Returns: JSON of Salesforce records with record Ids and name
        History:
        =================
        1.2     09-18-2020      Sunit     Initial Version
    */
     public static String searchObjects(set<String> objectsToSearch, String phoneNumber, String base_query){
         String JSONString = '';
         //Looping through all the objects to search
         for(String objectName : objectsToSearch){
             //Get all the fields to search
             String fieldsToSearch = fieldToSearch.containsKey(objectName) ? fieldToSearch.get(objectName) : 'Id';
             
             //This wil be used in the SOSL for formatting
             List<Object> formatOptions = new List<Object>(queryMethod(objectsToSearch,fieldsToSearch,phoneNumber));
             //Get the dynamic List of sObject typecasted
             List<sObject> sObjectList = dynmaicsObjectList(objectName);
             
             //Run the SOSL
             sObjectList = Search.query(String.format(base_query, formatOptions)).get(0);
             //Create the JSON Structure
             JSONString = createObjectJSON(sObjectList,objectName);
             
             //Break the loop if results are returned
             if(sObjectList.size()>0){
                 break;
             }
         }
         return JSONString;
    }
    
    /*  Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create final JSON that will be returned to the CTI
        Inputs: Object result and Object name
        Returns: JSON of Salesforce records with record Ids and name
        History:
        =================
        1.2     09-18-2020      Sunit     Initial Version
    */
    public static String createObjectJSON(List<sObject> queryResult,String objectType){
         
        String JSONString='{';
        
        //Loop through all the results that are returned
        for (sObject object_Iter : queryResult){
            //Name field from the object
            String fieldResult = fieldToSearch.containsKey(objectType) ? fieldToSearch.get(objectType).split(',')[0] : 'Id';
            String isPersonAccount = 'false';
            String recordName = (String)object_Iter.get(fieldResult);
            String personContactId = object_Iter.Id;
            //If the object type is Account, get the PersonContactId as well. 
            if(objectType==ConstantsUtility.ACCOUNT_OBJ){
                isPersonAccount = 'true';
                personContactId = (String)object_Iter.get('PersonContactId');
            } 
            
            //JSON Structure valid for CTI. Please do not change. 
            JSONString+='"'+object_Iter.Id+'":{';
            JSONString+='"Id":'+'"'+object_Iter.Id+'",';
            JSONString+='"IsPersonAccount ":'+'"'+isPersonAccount+'",';
            JSONString+='"Name":'+'"'+recordName+'",';
            JSONString+='"PersonContactId":'+'"'+personContactId+'",';
            JSONString+='"RecordType":'+'"'+objectType+'"';
            JSONString+='},';
        }
        JSONString=JSONString.removeEnd(',');
        JSONString+='}'; 
        return JSONString;
    }
    
   
    /*  Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create the objectlist for running SOSL
        Inputs: Objects to search, fields to search and incoming phone number
        Returns: JSON of Salesforce records with record Ids and name
        History:
        =================
        1.2     09-18-2020      Sunit     Initial Version
    */
    public static List<Object> queryMethod(Set<String> objectToSearch, String fields, String incomingPhone){
        recordtypes = new set<String>();
        List<Object> objectList = new list<Object>();
        objectList.add((String)incomingPhone);
       	
        //Loop through all the objects to be searched
        for(String key : objectToSearch){ 
            //Exclude objects that has been searched already
            if(!queriedObjects.contains(key)){
                //If record types needs to be included in the Where Clause, include those record types
                String recordTypeSplit = recordTypesToSearch.containsKey(key) ? recordTypesToSearch.get(key) : '';
                if(String.isNotBlank(recordTypeSplit)){
                    recordtypes.addAll(recordTypeSplit.split(','));
                }
                //Create the object list for SOSL
                objectList = new list<Object>{'\'' + incomingPhone + '\'', key, fields};
                queriedObjects.add(key);
            }
            if(objectList.size()>1){
                break;
            }
        }   
        return objectList;
    }
}