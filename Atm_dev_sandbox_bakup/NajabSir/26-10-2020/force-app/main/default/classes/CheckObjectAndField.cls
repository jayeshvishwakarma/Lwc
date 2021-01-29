/**
 * @File Name          : CheckObjectAndField.cls
 * @Description        : This class is used check the object and field permissions.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 29/7/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    29/7/2019 11:17 AM          Anuj Kumar            Initial Version
**/

public class CheckObjectAndField{
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method to check object is accessible, createable, updateable or not.
        @Date Of Modification :   29/7/2019
    */
    public static Boolean objectCURDPermission(String objectName, String accessType){
    
        if(String.isNotBlank(objectName) && String.isNotBlank(accessType)){
            switch on accessType{
                
                when 'isAccessible' {
                    return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isAccessible();
                }
                
                when 'isCreateable' {
                    return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isCreateable();
                }
                
                when 'isUpdateable' {
                    return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isUpdateable();
                }
                
                when else{return false;}
            }
        }
        
        return false;
    }
    
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method to check field is accessible, createable, updateable or not.
        @Date Of Modification :   29/7/2019
    */
    public static Boolean fieldCURDPermission(String sObjectType, String accessType, String fieldName){
    
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        
         switch on accessType{
                
            when 'isAccessible' {
                return fieldDescribe.isAccessible();
            }
            
            when 'isCreateable' {
                return fieldDescribe.isCreateable();
            }
            
            when 'isUpdateable' {
                return fieldDescribe.isUpdateable();
            }
            
            when else{return false;}
        }
        
    }
    
    public static Boolean isAccessible(String objectName){
    
        if(String.isNotBlank(objectName)){
            return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isAccessible();
        }else{return false;}
            
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method to check object is createable or not.
        @Date Of Modification :   29/7/2019
    */
    public static Boolean isCreateable(String objectName){
    
        if(String.isNotBlank(objectName)){
            return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isCreateable();
        }else {return false;}
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method to check object is updateable or not.
        @Date Of Modification :   29/7/2019
    */
    public static Boolean isUpdateable(String objectName){
    
        if(String.isNotBlank(objectName)){
            return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isUpdateable();
        }else {return false;}
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method to check field is accessible or not.
        @Date Of Modification :   29/7/2019
    */
    public static Boolean isFieldAccessible(String sObjectType, String fieldName){
    
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        
        return fieldDescribe.isAccessible();
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method to check field is createable or not.
        @Date Of Modification :   29/7/2019
    */
    public static Boolean isFieldCreateable(String sObjectType, String fieldName){
    
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        
        return fieldDescribe.isCreateable();
    }
}