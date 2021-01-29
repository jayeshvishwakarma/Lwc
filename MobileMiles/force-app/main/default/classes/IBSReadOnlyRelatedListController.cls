public with sharing class IBSReadOnlyRelatedListController {
    
    
    /**
        Name        :   getSobjectData
        Date        :   20 May 2020
        Description :   Function is use for to get records based on object name and id
        Developer   :   
     */
    @AuraEnabled 
    public static List<Sobject> getSobjectData(String objectApiName, String fieldNames, String recordId, String parentFieldApiName, String parentType, String whereClause, String orderBy, String isFromEvent){        
        if(String.isNotBlank(parentType) && parentType != 'Record Detail' && isFromEvent == 'false'){
            String userId = UserInfo.getUserId();
            if(parentType == 'Current User'){
                recordId = userId;
            }else if(parentType == 'Current Contact'){
                List<User> lstUser = [Select contactId from User  where Id = :userId];
                if(lstUser.size() > 0 && lstUser[0].contactId != null){
                    recordId = lstUser[0].contactId;
                }else{
                    throw new AuraHandledException('Contact Id not found.');
                }
            }else if(parentType == 'Current Account'){
                List<User> lstUser = [Select contact.AccountId from User  where Id = :userId];
                if(lstUser.size() > 0 && lstUser[0].contact.AccountId != null){
                    recordId = lstUser[0].contact.AccountId;
                }else{
                    throw new AuraHandledException('Account Id not found.');
                }
            }
        }
        
        if(String.isNotBlank(objectApiName) && String.isNotBlank(fieldNames)){            
            String query = 'SELECT ';
            query += fieldNames;
            query += ' FROM ';
            query += objectApiName;
            query += ' WHERE ';
            if(String.isNotBlank(whereClause)){
                query += whereClause;
                query += ' AND ';
            }        
            query += '('+parentFieldApiName+'=';
            query += '\''+recordId+'\'';
            query += ')';
            if(String.isNotBlank(orderBy)){
                query += ' ORDER BY '+ orderBy ;
            }
            system.debug('query'+query);
            List<sobject> sObjList = Database.query(query);
            system.debug('sObjList'+sObjList);
            if(sObjList.size() > 0){
                return sObjList;
            }
        }
        return null;
    }
     /**
        Name        :   getUserId
        Date        :   23 May 2020
        Description :   
        Developer   :   
     */
    @AuraEnabled
    public static String getUserId(){
        String userId = UserInfo.getUserId();
        system.debug('userId'+userId);
        List<User> lstUser = [Select contact.AccountId from User  where Id = :userId];
        system.debug('lstUser'+lstUser);
        if(lstUser.size() > 0 && lstUser[0].contact.AccountId != null){
            return lstUser[0].contact.AccountId;
        }else{
            throw new AuraHandledException('Account Id not found.');
        }
    }
    @AuraEnabled
    public static String  getFlds(String objectName, String flds){
        if(String.isNotBlank(objectName) && String.isNotBlank(flds)){
            if(Schema.getGlobalDescribe().containsKey(objectName) ){                               
                Set<string> fldSet = new Set<String>();
                List<fldWrapper> fldList = new List<fldWrapper>();
                fldSet.addAll(flds.toLowerCase().split(','));
                Map<String, Schema.SObjectField> describeFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                for( Schema.SObjectField sObjectField : describeFieldMap.values() ){
                    Schema.DescribeFieldResult field = sObjectField.getDescribe();
                    System.debug('===>'+field.getName().toLowerCase());
                    if(fldSet.contains(field.getName().toLowerCase())){
                        fldList.add(new fldWrapper(field.getLabel(),field.getName(),field.getType()+'',field.isCalculated()));
                    }            
                } 
                if(fldList.size() > 0){
                    return JSON.serialize(fldList);
                }
            }
        }
        return null;  
    }  
    public class fldWrapper{
        String label;
        String apiName;
        String dataType;
        boolean calculated;          
        public fldWrapper(String label,String apiName,String dataType,boolean calculated){
            this.label = label;
            this.apiName = apiName;
            this.dataType = dataType.toLowerCase();
            this.calculated = calculated;                     
        }
    }
}